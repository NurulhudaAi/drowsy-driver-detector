function R = drowsyPipeline(img, mode, thr)
% DROWSYPIPELINE  Full drowsy-driver pipeline that uses all three modules.
%   R = drowsyPipeline(img, 'face', thr)   img = photo of a driver's face
%   R = drowsyPipeline(img, 'eye',  thr)   img = already cropped eye image
%
%   Steps
%     1. Enhancement  (Module 1): V-channel histogram equalization + median filter
%     2. Detection    (Module 2): skin segmentation + morphology -> eye region
%     3. Transform    (Module 3): resize the eye region to a standard width (bilinear)
%     4. Decision     (Module 2): dark-blob openness score -> ALERT / DROWSY
%   Output struct fields: enhanced, crop, mask, overlay, score, label, box, thr
if nargin < 2 || isempty(mode), mode = 'face'; end
if nargin < 3 || isempty(thr),  thr  = 0.30;   end
if size(img,3) == 4, img = img(:,:,1:3); end
if size(img,3) == 1, img = repmat(im2uint8(img), [1 1 3]); end
img = im2uint8(img);

% 1) enhancement
enh = medianFilter(histEqualize(img), 3);

% 2) eye-region detection
if strcmpi(mode, 'face')
    [crop, box] = locateEyeRegion(enh);
else
    crop = enh;  box = [1 1 size(enh,2) size(enh,1)];
end

% 3) geometric normalization (standard width of 128 px)
sc = 128 / size(crop, 2);
crop = scaleImg(crop, sc, sc, 'bilinear');

% 4) decision
[label, score, mask] = drowsyDecision(crop, thr);

ov = crop;                                   % overlay: detected dark blob in red
r = ov(:,:,1); g = ov(:,:,2); b = ov(:,:,3);
r(mask) = 255;  g(mask) = 0;  b(mask) = 0;
ov = cat(3, r, g, b);

R = struct('enhanced', enh, 'crop', crop, 'mask', mask, 'overlay', ov, ...
           'score', score, 'label', label, 'box', box, 'thr', thr);
end
