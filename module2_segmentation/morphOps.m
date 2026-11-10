function out = morphOps(img, op, r, shape)
% MORPHOPS  Binary morphology implemented from scratch.
%   op    : 'dilate' | 'erode' | 'open' | 'close'
%   r     : structuring-element radius (default 1)
%   shape : 'disk' (default) | 'square'
%   The input is binarized (Otsu) if it is not already binary.
if nargin < 2, op = 'dilate'; end
if nargin < 3 || isempty(r), r = 1; end
if nargin < 4 || isempty(shape), shape = 'disk'; end
bw = toBinary(img);
r = max(1, round(r));
[X, Y] = meshgrid(-r:r);
if strcmpi(shape, 'square'), se = true(2*r+1); else, se = (X.^2 + Y.^2) <= r^2; end
switch lower(op)
    case 'dilate', R = dilateBW(bw, se);
    case 'erode',  R = erodeBW(bw, se);
    case 'open',   R = dilateBW(erodeBW(bw, se), se);
    case 'close',  R = erodeBW(dilateBW(bw, se), se);
    otherwise, error('Unknown morphological op: %s', op);
end
out = uint8(R) * 255;
end

function R = dilateBW(bw, se)
r = (size(se,1)-1)/2;  [h, w] = size(bw);
P = false(h+2*r, w+2*r);  P(r+1:r+h, r+1:r+w) = bw;
R = false(h, w);
for dy = -r:r
    for dx = -r:r
        if se(dy+r+1, dx+r+1)
            R = R | P(r+1+dy:r+h+dy, r+1+dx:r+w+dx);
        end
    end
end
end

function R = erodeBW(bw, se)
r = (size(se,1)-1)/2;  [h, w] = size(bw);
P = true(h+2*r, w+2*r);  P(r+1:r+h, r+1:r+w) = bw;
R = true(h, w);
for dy = -r:r
    for dx = -r:r
        if se(dy+r+1, dx+r+1)
            R = R & P(r+1+dy:r+h+dy, r+1+dx:r+w+dx);
        end
    end
end
end
