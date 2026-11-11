function [label, score, mask, rows] = drowsyDecision(img, thr, removeBrow)
% DROWSYDECISION  Decide whether the eye in an (enhanced) eye image is open.
%   Method: median filter -> (eyebrow removal) -> Otsu threshold on the central
%   region -> dark pixels (pupil/iris/lashes) -> morphological opening ->
%   largest dark blob. Openness score = blob height / blob width: an open eye
%   gives a rounder blob (large score), a closed eye gives a thin line (small score).
%   label = 'DROWSY' if score < thr, otherwise 'ALERT'.
%
%   Eyebrow removal (removeBrow = true, default): the eye band often contains the
%   eyebrow too. A closed-eye lash line then joins the dark eyebrow into one tall
%   blob, and the closed eye is wrongly scored as open. The row brightness profile
%   of the band has two dark valleys - the eyebrow (upper) and the eye (lower) -
%   with brighter skin between them. When both valleys are found, only the rows
%   around the LOWER valley are used. If they are not found, the default
%   rows (20%-80% of the band) are used, exactly as before.
%   rows = [r1 r2], the rows of the band that were analysed.
%   NOTE: thr is a heuristic -> tune it on your own images (tests/evaluateDataset.m).
if nargin < 2 || isempty(thr), thr = 0.30; end
if nargin < 3 || isempty(removeBrow), removeBrow = true; end
g = medianFilter(toGray(img), 3);
[h, w] = size(g);
r1 = max(1, round(0.20*h));  r2 = min(h, round(0.80*h));
c1 = max(1, round(0.10*w));  c2 = min(w, round(0.90*w));
if removeBrow
    [b1, b2, found] = eyeRows(g(:, c1:c2));
    if found, r1 = b1; r2 = b2; end
end
rows = [r1 r2];
roi = g(r1:r2, c1:c2);
m = otsuSegment(roi);
dark = morphOps(uint8(m == 0)*255, 'open', 1, 'disk') > 0;
mask = false(h, w);
score = 0;
L = bwlabel(dark, 8);
if max(L(:)) > 0
    areas = accumarray(L(L>0), 1);
    [~, k] = max(areas);
    [rr, cc] = find(L == k);
    score = (max(rr) - min(rr) + 1) / (max(cc) - min(cc) + 1);
    mask(r1:r2, c1:c2) = (L == k);
end
if score < thr, label = 'DROWSY'; else, label = 'ALERT'; end
end

function [r1, r2, found] = eyeRows(g)
% Find the eyebrow and eye rows from the row brightness profile.
h = size(g, 1);
r1 = 1;  r2 = h;  found = false;
p = mean(double(g), 2);                       % mean brightness of every row
p = movmean(p, max(3, round(0.08*h)));        % smooth
isMin = [false; p(2:end-1) < p(1:end-2) & p(2:end-1) <= p(3:end); false];
idx = find(isMin);                            % dark valleys
if numel(idx) < 2, return; end
[~, order] = sort(p(idx), 'ascend');          % darkest valleys first
idx = idx(order);
a = idx(1);  b = [];
for k = 2:numel(idx)                          % second valley, not too close
    if abs(idx(k) - a) >= 0.15*h, b = idx(k); break; end
end
if isempty(b), return; end
brow = min(a, b);  eye = max(a, b);
skin = max(p(brow:eye));                      % brighter skin between them?
if skin - max(p(brow), p(eye)) < 5, return; end
d  = eye - brow;
r1 = max(1, round((brow + eye) / 2));         % start halfway below the eyebrow
r2 = min(h, eye + d);
if r2 - r1 < 6, r1 = 1; r2 = h; return; end
found = true;
end
