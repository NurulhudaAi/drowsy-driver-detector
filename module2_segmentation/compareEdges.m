function compareEdges(img, thr)
% COMPAREEDGES  Show Sobel, Prewitt and Canny results side by side.
if nargin < 2, thr = 0.15; end
s = edgeDetect(img, 'sobel',   thr);
p = edgeDetect(img, 'prewitt', thr);
c = edgeDetect(img, 'canny',   max(thr, 0.2));
showCompare({img, s, p, c}, {'Original', 'Sobel', 'Prewitt', 'Canny'}, 'Edge detector comparison');
end
