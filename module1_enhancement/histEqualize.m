function out = histEqualize(img)
% HISTEQUALIZE  Histogram equalization implemented from scratch.
%   Gray image: s_k = (L-1) * CDF(r_k).  Color image: equalize the V channel
%   of HSV so colors are preserved.
if size(img,3) == 3
    hsv = rgb2hsv(img);
    v = histEqualize(im2uint8(hsv(:,:,3)));
    hsv(:,:,3) = double(v)/255;
    out = im2uint8(hsv2rgb(hsv));
    return;
end
g = im2uint8(img);
counts = histcounts(g(:), 0:256);
cdf = cumsum(counts) / numel(g);
map = uint8(round(255 * cdf));
out = map(double(g) + 1);
end
