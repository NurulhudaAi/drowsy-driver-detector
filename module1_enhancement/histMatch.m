function out = histMatch(img, ref, mu, sigma)
% HISTMATCH  Histogram matching (specification).
%   out = histMatch(img, refImage)        match the histogram of refImage
%   out = histMatch(img, [], mu, sigma)   match a Gaussian target histogram
if nargin < 2, ref = []; end
if nargin < 3 || isempty(mu), mu = 128; end
if nargin < 4 || isempty(sigma), sigma = 50; end
if size(img,3) == 3
    hsv = rgb2hsv(img);
    v = histMatch(im2uint8(hsv(:,:,3)), ref, mu, sigma);
    hsv(:,:,3) = double(v)/255;
    out = im2uint8(hsv2rgb(hsv));
    return;
end
g = im2uint8(img);
cdfI = cumsum(histcounts(g(:), 0:256)) / numel(g);
if isempty(ref)
    p = exp(-((0:255) - mu).^2 / (2*sigma^2));
    p = p / sum(p);
else
    r = toGray(ref);
    p = histcounts(r(:), 0:256) / numel(r);
end
cdfR = cumsum(p);
map = zeros(1, 256, 'uint8');
for i = 1:256                       % nearest CDF value in the target
    [~, j] = min(abs(cdfR - cdfI(i)));
    map(i) = j - 1;
end
out = map(double(g) + 1);
end
