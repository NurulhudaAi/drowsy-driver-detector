function out = grayTransform(img, type, a, b)
% GRAYTRANSFORM  Gray-level (point) transformations on intensities in [0,1].
%   'negative'            s = 1 - r
%   'log'                 s = log(1 + a r) / log(1 + a)
%   'gamma'               s = r ^ a
%   'linear'              s = a r + b      (a = contrast, b = brightness)
if nargin < 3 || isempty(a), a = 1; end
if nargin < 4 || isempty(b), b = 0; end
x = im2double(img);
switch lower(type)
    case 'negative', y = 1 - x;
    case 'log',      if a <= 0, a = 1; end
                     y = log(1 + a*x) / log(1 + a);
    case 'gamma',    y = x .^ a;
    case 'linear',   y = a*x + b;
    otherwise, error('Unknown gray transform: %s', type);
end
out = im2uint8(min(max(y, 0), 1));
end
