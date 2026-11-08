function out = warpReverse(img, T, outSize, method)
% WARPREVERSE  Reverse (inverse) mapping: for every OUTPUT pixel find the
%   corresponding INPUT location with inv(T) and interpolate. No holes appear.
%   T = 3x3 forward matrix, outSize = [rows cols], method = interpolation.
img = im2uint8(img);
if nargin < 3 || isempty(outSize), outSize = [size(img,1) size(img,2)]; end
if nargin < 4 || isempty(method),  method = 'bilinear'; end
Ho = outSize(1);  Wo = outSize(2);
[xo, yo] = meshgrid(1:Wo, 1:Ho);
P = T \ [xo(:)'; yo(:)'; ones(1, numel(xo))];
xs = reshape(P(1,:) ./ P(3,:), Ho, Wo);
ys = reshape(P(2,:) ./ P(3,:), Ho, Wo);
out = sampleImage(img, xs, ys, method);
end
