function out = meanFilter(img, k)
% MEANFILTER  k-by-k averaging (smoothing) filter for noise reduction.
if nargin < 2, k = 3; end
k = 2*floor(k/2) + 1;                          % force odd size
y = convReplicate(im2double(img), ones(k)/k^2);
out = im2uint8(min(max(y, 0), 1));
end
