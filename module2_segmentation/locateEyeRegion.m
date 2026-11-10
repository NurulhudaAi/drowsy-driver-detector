function [crop, box] = locateEyeRegion(img)
% LOCATEEYEREGION  Find the face by skin-color segmentation (HSV) + morphology,
%   then return the band of the face where the eyes are expected
%   (15%-50% of the face height). box = [x y width height].
%   Falls back to the whole image when no skin region is found.
[~, mask] = colorSegment(img, 'hsv');
m = morphOps(uint8(mask)*255, 'close', 5, 'disk') > 0;
m = morphOps(uint8(m)*255,   'open',  3, 'disk') > 0;
L = bwlabel(m, 8);
if max(L(:)) == 0
    crop = img;  box = [1 1 size(img,2) size(img,1)];  return;
end
areas = accumarray(L(L>0), 1);
[~, k] = max(areas);
[rr, cc] = find(L == k);
top = min(rr); bot = max(rr); left = min(cc); right = max(cc);
H = bot - top + 1;
r1 = top + round(0.15*H);
r2 = max(r1+5, top + round(0.50*H));
r2 = min(r2, size(img,1));
crop = img(r1:r2, left:right, :);
box = [left r1 right-left+1 r2-r1+1];
end
