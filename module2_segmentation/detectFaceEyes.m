function D = detectFaceEyes(img)
% DETECTFACEEYES  Find the driver's face and the two eyes.
%   1. Viola-Jones face detector (Computer Vision Toolbox, 'FrontalFaceCART');
%      the largest face is used.
%   2. Viola-Jones eye-pair detector ('EyePairBig', then 'EyePairSmall') in the
%      upper 60% of the face. The pair box is split into a left and a right eye.
%   3. No eye pair found -> eye boxes from standard face proportions.
%   4. No face found (or no Computer Vision Toolbox) -> skin-colour segmentation
%      + morphology (locateEyeRegion), split into two halves.
%   Each eye centre = centroid of the darkest blob in its box (Otsu, Module 2).
%   Head tilt = angle of the line between the two eye centres (degrees).
%
%   D.face    [x y w h] of the face ([] if none)
%   D.eyes    2x4 [x y w h]: row 1 = eye on the left of the image, row 2 = right
%   D.centers 2x2 [x y] eye centres
%   D.tilt    head tilt in degrees (0 if it could not be measured reliably)
%   D.method  'viola-jones' | 'face-geometry' | 'skin'
persistent faceDet pairBig pairSmall hasCV
if isempty(hasCV)
    hasCV = false;
    try
        faceDet   = vision.CascadeObjectDetector('FrontalFaceCART', 'MergeThreshold', 4);
        pairBig   = vision.CascadeObjectDetector('EyePairBig');
        pairSmall = vision.CascadeObjectDetector('EyePairSmall');
        hasCV = true;
    catch
        warning('detectFaceEyes:noCV', ['Computer Vision Toolbox not available: ' ...
                'the eyes are found with skin-colour segmentation instead.']);
    end
end

g = toGray(img);
[H, W] = size(g);
D = struct('face', [], 'eyes', zeros(2,4), 'centers', zeros(2,2), 'tilt', 0, 'method', 'skin');

face = [];
if hasCV
    bb = step(faceDet, g);
    if ~isempty(bb)
        [~, k] = max(bb(:,3) .* bb(:,4));
        face = double(bb(k,:));
    end
end

if ~isempty(face)
    D.face = face;
    x = face(1);  y = face(2);  w = face(3);  h = face(4);
    r1 = max(1, round(y));  r2 = min(H, round(y + 0.6*h));
    c1 = max(1, round(x));  c2 = min(W, round(x + w - 1));
    roi = g(r1:r2, c1:c2);
    pair = [];
    if size(roi,1) >= 11 && size(roi,2) >= 45, pair = step(pairBig, roi); end
    if isempty(pair) && size(roi,1) >= 5 && size(roi,2) >= 22, pair = step(pairSmall, roi); end
    if ~isempty(pair)
        [~, k] = max(pair(:,3));
        p = double(pair(k,:));
        p(1) = p(1) + c1 - 1;   p(2) = p(2) + r1 - 1;
        ey = p(2) - 0.3*p(4);   eh = 1.6*p(4);   % pair boxes are tight: add room above/below
        ew = p(3) / 2;
        D.eyes = [p(1) ey ew eh; p(1)+ew ey ew eh];
        D.method = 'viola-jones';
    else
        ey = y + 0.22*h;  eh = 0.26*h;            % standard face proportions
        D.eyes = [x+0.13*w ey 0.34*w eh; x+0.53*w ey 0.34*w eh];
        D.method = 'face-geometry';
    end
else
    [~, box] = locateEyeRegion(img);              % skin segmentation fallback
    bw = box(3) / 2;
    D.eyes = [box(1) box(2) bw box(4); box(1)+bw box(2) bw box(4)];
    D.method = 'skin';
end
D.eyes = clipBoxes(D.eyes, W, H);

for i = 1:2
    D.centers(i,:) = darkCenter(g, D.eyes(i,:));
end
d = D.centers(2,:) - D.centers(1,:);
t = atan2d(d(2), d(1));
if abs(t) <= 30, D.tilt = t; end                  % larger angles are measurement errors
end

function c = darkCenter(g, b)
% centroid of the largest dark (Otsu) blob inside box b; box centre if none
c = [b(1) + b(3)/2, b(2) + b(4)/2];
patch = g(b(2):b(2)+b(4)-1, b(1):b(1)+b(3)-1);
m = otsuSegment(patch) == 0;
L = bwlabel(m, 8);
if max(L(:)) == 0, return; end
areas = accumarray(L(L>0), 1);
[~, k] = max(areas);
[rr, cc] = find(L == k);
c = [b(1) - 1 + mean(cc), b(2) - 1 + mean(rr)];
end
