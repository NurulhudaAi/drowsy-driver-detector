function [label, score, mask] = drowsyDecision(img, thr)
% DROWSYDECISION  Decide whether the eye in an (enhanced) eye image is open.
%   Method: median filter -> Otsu threshold on the central region ->
%   dark pixels (pupil/iris/lashes) -> morphological opening -> largest dark
%   blob. Openness score = blob height / blob width: an open eye gives a
%   rounder blob (large score), a closed eye gives a thin line (small score).
%   label = 'DROWSY' if score < thr, otherwise 'ALERT'.
%   NOTE: thr is a heuristic -> tune it on your own images (tests/evaluateDataset.m).
if nargin < 2 || isempty(thr), thr = 0.30; end
g = medianFilter(toGray(img), 3);
[h, w] = size(g);
r1 = max(1, round(0.20*h));  r2 = min(h, round(0.80*h));
c1 = max(1, round(0.10*w));  c2 = min(w, round(0.90*w));
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
