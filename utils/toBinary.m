function bw = toBinary(img)
% TOBINARY  Return a logical image. Binary/two-level images are kept as is,
%   other images are thresholded with Otsu's method.
if islogical(img), bw = img; return; end
if size(img,3) == 1 && numel(unique(img(:))) <= 2
    bw = img > 0; return;
end
g = toGray(img);
[~, t] = otsuSegment(g);
bw = g > t;
end
