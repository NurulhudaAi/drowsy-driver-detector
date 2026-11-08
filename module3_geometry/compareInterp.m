function compareInterp(img, scale)
% COMPAREINTERP  Zoom a small patch with nearest / bilinear / bicubic
%   interpolation and display the three results side by side.
if nargin < 2, scale = 4; end
[h, w, ~] = size(img);
ps = min([48, h, w]);
r = floor((h-ps)/2) + 1;  c = floor((w-ps)/2) + 1;
patch = img(r:r+ps-1, c:c+ps-1, :);
n  = scaleImg(patch, scale, scale, 'nearest');
bl = scaleImg(patch, scale, scale, 'bilinear');
bc = scaleImg(patch, scale, scale, 'bicubic');
showCompare({patch, n, bl, bc}, {'Original patch', 'Nearest', 'Bilinear', 'Bicubic'}, 'Interpolation comparison');
end
