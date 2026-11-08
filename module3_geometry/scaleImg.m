function out = scaleImg(img, sx, sy, method)
% SCALEIMG  Scaling / zooming (resize) with a chosen interpolation method.
%   Output size = round([rows*sy cols*sx]). Corners of input and output align.
if nargin < 3 || isempty(sy), sy = sx; end
if nargin < 4 || isempty(method), method = 'bilinear'; end
[h, w, ~] = size(img);
outSize = max(1, round([h*sy, w*sx]));
T = [sx 0 1-sx; 0 sy 1-sy; 0 0 1];          % x_out = sx*(x_in-1)+1
out = warpReverse(img, T, outSize, method);
end
