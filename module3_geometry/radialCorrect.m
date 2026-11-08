function out = radialCorrect(img, k1, k2)
% RADIALCORRECT  Radial lens-distortion correction (reverse mapping).
%   For every output pixel with normalized radius r, the source pixel is taken
%   from  r_src = r * (1 + k1*r^2 + k2*r^4).
%   k1 < 0 : corrects pincushion distortion,  k1 > 0 : corrects barrel distortion
%   (try small values in the range -0.5 ... 0.5).
if nargin < 2 || isempty(k1), k1 = 0.2; end
if nargin < 3 || isempty(k2), k2 = 0;   end
img = im2uint8(img);
[h, w, ~] = size(img);
cx = (w+1)/2;  cy = (h+1)/2;
nrm = hypot(cx, cy);                         % normalize by half the diagonal
[xo, yo] = meshgrid(1:w, 1:h);
xn = (xo - cx) / nrm;   yn = (yo - cy) / nrm;
r2 = xn.^2 + yn.^2;
f  = 1 + k1*r2 + k2*r2.^2;
xs = cx + xn .* f * nrm;
ys = cy + yn .* f * nrm;
out = sampleImage(img, xs, ys, 'bilinear');
end
