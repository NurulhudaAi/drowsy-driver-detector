function out = translateImg(img, tx, ty, method)
% TRANSLATEIMG  Shift the image by tx (right) and ty (down) pixels.
if nargin < 4, method = 'bilinear'; end
out = warpReverse(img, tformMatrix('translate', tx, ty), [], method);
end
