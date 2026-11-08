function out = affineTransform(img, A, method, mapping)
% AFFINETRANSFORM  General affine warp.
%   A       : 2x3 or 3x3 matrix mapping input (x,y) -> output (x,y)
%   method  : 'nearest' | 'bilinear' | 'bicubic'
%   mapping : 'reverse' (default, no holes) | 'forward' (may leave holes)
if nargin < 3 || isempty(method),  method  = 'bilinear'; end
if nargin < 4 || isempty(mapping), mapping = 'reverse';  end
if size(A,1) == 2, A = [A; 0 0 1]; end
if strcmpi(mapping, 'forward')
    out = warpForward(img, A);
else
    out = warpReverse(img, A, [], method);
end
end
