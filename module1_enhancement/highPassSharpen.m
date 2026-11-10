function out = highPassSharpen(img, k, boost)
% HIGHPASSSHARPEN  High-boost filtering: g = f + boost * (f - smooth(f)).
if nargin < 2, k = 3; end
if nargin < 3, boost = 1; end
k = 2*floor(k/2) + 1;
x = im2double(img);
hp = x - convReplicate(x, ones(k)/k^2);        % high-pass = original - low-pass
out = im2uint8(min(max(x + boost*hp, 0), 1));
end
