function R = drowsyPipeline(img, mode, thr, varargin)
% DROWSYPIPELINE  Full drowsy-driver pipeline that uses all three modules.
%   R = drowsyPipeline(img, 'face')            photo or video frame of a driver
%   R = drowsyPipeline(img, 'eye')             already cropped eye image
%   R = drowsyPipeline(img, mode, thr, 'Method', m)
%       m = 'auto' (default: trained model if models/eyeModel.mat exists, else rule)
%           'knn'  trained eye-state model (Viola-Jones + HOG features + KNN)
%           'rule' rule-based baseline (skin segmentation + dark-blob openness)
%   thr = openness threshold; [] -> 0.50 for 'knn', 0.30 for 'rule'
%
%   Trained-model steps ('knn')
%     1. Module 1: V-channel histogram equalization + median filter
%     2. Module 2: Viola-Jones face + eye detection (skin segmentation fallback)
%     3. Module 3: rotate the image so the eyes are level (head tilt), then
%        resize every eye to 24x24 with our bilinear interpolation
%     4. Features: Sobel-gradient orientation histograms (Module 2) + thumbnail
%     5. KNN classifier (from scratch) -> probability that each eye is closed
%     openness score = 1 - mean closed probability of the two eyes
%   Rule-based steps ('rule'): enhancement -> skin eye band -> resize -> dark blob
%     height/width (drowsyDecision).
%
%   Output fields: enhanced, crop, mask, overlay, score, label, box, thr,
%                  method, locator, eyes, face, tilt, pClosed
if nargin < 2 || isempty(mode), mode = 'face'; end
if nargin < 3, thr = []; end
method = 'auto';  removeBrow = true;
if ~isempty(varargin) && (islogical(varargin{1}) || isnumeric(varargin{1}))
    removeBrow = logical(varargin{1});  varargin(1) = [];  method = 'rule';  % old call style
end
for i = 1:2:numel(varargin)
    switch lower(varargin{i})
        case 'method',     method = lower(varargin{i+1});
        case 'removebrow', removeBrow = logical(varargin{i+1});
        otherwise, error('Unknown option %s', varargin{i});
    end
end
model = [];
if ~strcmp(method, 'rule'), model = loadEyeModel(); end
if strcmp(method, 'knn') && isempty(model)
    error('No trained model yet: run trainEyeModel first.');
end
if strcmp(method, 'auto')
    if isempty(model)
        method = 'rule';
        warning('drowsyPipeline:noModel', ['models/eyeModel.mat not found: using the rule-based ' ...
                'method. Run trainEyeModel to train the eye-state model.']);
    else
        method = 'knn';
    end
end
if isempty(thr)
    if strcmp(method, 'knn'), thr = 0.50; else, thr = 0.30; end
end

if size(img,3) == 4, img = img(:,:,1:3); end
if size(img,3) == 1, img = repmat(im2uint8(img), [1 1 3]); end
img = im2uint8(img);

% 1) enhancement (Module 1)
enh = medianFilter(histEqualize(img), 3);

if strcmp(method, 'rule')
    R = rulePath(enh, mode, thr, removeBrow);
    return;
end

% ---------------- trained-model path ----------------
[Hh, Ww, ~] = size(enh);
if strcmpi(mode, 'face')
    D = detectFaceEyes(enh);                                   % 2) Module 2
    work = enh;  eyes = D.eyes;
    if abs(D.tilt) > 5                                         % 3) Module 3: level the eyes
        work = rotateImg(enh, D.tilt, 'bilinear');
        c = [(Ww+1)/2, (Hh+1)/2];
        T = tformMatrix('translate', c(1), c(2)) * tformMatrix('rotate', D.tilt) * ...
            tformMatrix('translate', -c(1), -c(2));
        for i = 1:2
            bc = [eyes(i,1) + eyes(i,3)/2, eyes(i,2) + eyes(i,4)/2, 1]';
            p = T * bc;
            eyes(i,1:2) = [p(1) - eyes(i,3)/2, p(2) - eyes(i,4)/2];
        end
        eyes = clipBoxes(eyes, Ww, Hh);
    end
    nEye = 2;
    box = [min(D.eyes(:,1)), min(D.eyes(:,2)), ...
           max(D.eyes(:,1) + D.eyes(:,3)) - min(D.eyes(:,1)), ...
           max(D.eyes(:,2) + D.eyes(:,4)) - min(D.eyes(:,2))];
    locator = D.method;  faceBox = D.face;  tilt = D.tilt;  eyeBoxes = D.eyes;
else
    work = enh;  eyes = [1 1 Ww Hh];  nEye = 1;
    box = eyes;  locator = 'none (eye image)';  faceBox = [];  tilt = 0;  eyeBoxes = eyes;
end

pC = zeros(nEye, 1);
tiles = cell(1, nEye);
for i = 1:nEye
    b = eyes(i,:);
    e = work(b(2):b(2)+b(4)-1, b(1):b(1)+b(3)-1, :);
    [~, pC(i)] = knnPredict(model, eyeFeatures(e));            % 4-5) features + KNN
    tiles{i} = scaleImg(e, 64/size(e,2), 64/size(e,1), 'bilinear');   % for display
    tiles{i} = tiles{i}(1:64, 1:64, :);
end
pClosed = mean(pC);
score = 1 - pClosed;
if score < thr, label = 'DROWSY'; else, label = 'ALERT'; end

crop = cat(2, tiles{:});
ov = crop;
for i = 1:nEye                                                % green = open, red = closed
    if pC(i) >= 0.5, col = [255 0 0]; else, col = [0 200 0]; end
    ov = drawBoxes(ov, [(i-1)*64+1, 1, 64, 64], col, 3);
end
R = struct('enhanced', enh, 'crop', crop, 'mask', false(size(crop,1), size(crop,2)), ...
           'overlay', ov, 'score', score, 'label', label, 'box', box, 'thr', thr, ...
           'method', 'knn', 'locator', locator, 'eyes', eyeBoxes, 'face', faceBox, ...
           'tilt', tilt, 'pClosed', pC);
end

function R = rulePath(enh, mode, thr, removeBrow)
% rule-based baseline: skin eye band -> resize -> dark-blob openness
if strcmpi(mode, 'face')
    [crop, box] = locateEyeRegion(enh);                        % Module 2
else
    crop = enh;  box = [1 1 size(enh,2) size(enh,1)];
end
sc = 128 / size(crop, 2);
crop = scaleImg(crop, sc, sc, 'bilinear');                     % Module 3
[label, score, mask] = drowsyDecision(crop, thr, removeBrow);
ov = crop;
r = ov(:,:,1); g = ov(:,:,2); b = ov(:,:,3);
r(mask) = 255;  g(mask) = 0;  b(mask) = 0;
ov = cat(3, r, g, b);
R = struct('enhanced', enh, 'crop', crop, 'mask', mask, 'overlay', ov, ...
           'score', score, 'label', label, 'box', box, 'thr', thr, ...
           'method', 'rule', 'locator', 'skin', 'eyes', box, 'face', [], ...
           'tilt', 0, 'pClosed', NaN);
end
