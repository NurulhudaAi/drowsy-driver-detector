function [out, stats] = shapeSegment(img, minArea, minCirc, darkObjects)
% SHAPESEGMENT  Shape-based segmentation with morphology.
%   Otsu threshold -> opening/closing -> connected components -> keep the
%   components whose area >= minArea and circularity (4*pi*A/P^2) >= minCirc.
%   darkObjects = true segments dark objects (e.g. pupil/iris).
if nargin < 2 || isempty(minArea),    minArea = 100; end
if nargin < 3 || isempty(minCirc),    minCirc = 0.3; end
if nargin < 4 || isempty(darkObjects), darkObjects = true; end
g = toGray(img);
m = otsuSegment(g);
bw = m > 0;
if darkObjects, bw = ~bw; end
bw = morphOps(uint8(bw)*255, 'open',  2, 'disk') > 0;
bw = morphOps(uint8(bw)*255, 'close', 3, 'disk') > 0;
L = bwlabel(bw, 8);
stats = regionprops(L, 'Area', 'Perimeter');
keep = false(1, numel(stats));
for i = 1:numel(stats)
    circ = 4*pi*stats(i).Area / max(stats(i).Perimeter, 1)^2;
    keep(i) = stats(i).Area >= minArea && circ >= minCirc;
end
out = uint8(ismember(L, find(keep))) * 255;
end
