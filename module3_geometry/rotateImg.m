function out = rotateImg(img, angleDeg, method, expand)
% ROTATEIMG  Rotate about the image center (positive angle = counter-clockwise).
%   expand = true enlarges the canvas so nothing is cropped.
if nargin < 3 || isempty(method), method = 'bilinear'; end
if nargin < 4 || isempty(expand), expand = false; end
[h, w, ~] = size(img);
cx = (w+1)/2;  cy = (h+1)/2;
R = tformMatrix('rotate', angleDeg);
if expand
    th = deg2rad(angleDeg);
    newW = ceil(abs(w*cos(th)) + abs(h*sin(th)) - 1e-9);   % -1e-9 avoids float round-up
    newH = ceil(abs(w*sin(th)) + abs(h*cos(th)) - 1e-9);
    T = tformMatrix('translate', (newW+1)/2, (newH+1)/2) * R * tformMatrix('translate', -cx, -cy);
    out = warpReverse(img, T, [newH newW], method);
else
    T = tformMatrix('translate', cx, cy) * R * tformMatrix('translate', -cx, -cy);
    out = warpReverse(img, T, [h w], method);
end
end
