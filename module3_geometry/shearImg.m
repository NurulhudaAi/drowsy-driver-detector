function out = shearImg(img, shx, shy, method)
% SHEARIMG  Shear about the image center (a special affine transform).
if nargin < 4, method = 'bilinear'; end
[h, w, ~] = size(img);
cx = (w+1)/2;  cy = (h+1)/2;
T = tformMatrix('translate', cx, cy) * tformMatrix('shear', shx, shy) * tformMatrix('translate', -cx, -cy);
out = affineTransform(img, T, method, 'reverse');
end
