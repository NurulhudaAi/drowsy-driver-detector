function [out, mag] = edgeDetect(img, method, thr)
% EDGEDETECT  Edge detection with Sobel, Prewitt or Canny operators.
%   out = edgeDetect(img, 'sobel'|'prewitt'|'canny', thr)
%   thr is a fraction (0-1) of the maximum gradient magnitude.
%   out is a uint8 binary edge map (0/255); mag is the gradient magnitude.
if nargin < 3 || isempty(thr), thr = 0.15; end
g = im2double(toGray(img));
switch lower(method)
    case 'sobel',   kx = [-1 0 1; -2 0 2; -1 0 1];
    case 'prewitt', kx = [-1 0 1; -1 0 1; -1 0 1];
    case 'canny'
        out = uint8(cannyEdge(g, 1.4, thr)) * 255;
        mag = [];
        return;
    otherwise, error('Unknown edge method: %s', method);
end
gx = convReplicate(g, kx);          % horizontal gradient
gy = convReplicate(g, kx');         % vertical gradient
mag = hypot(gx, gy);
out = uint8(mag > thr * max(mag(:))) * 255;
end

function bw = cannyEdge(g, sigma, highRatio)
% Canny: Gaussian smoothing -> gradient -> non-maximum suppression -> hysteresis
r = ceil(3*sigma);
[x, y] = meshgrid(-r:r);
G = exp(-(x.^2 + y.^2) / (2*sigma^2));  G = G / sum(G(:));
s = convReplicate(g, G);
kx = [-1 0 1; -2 0 2; -1 0 1];
gx = convReplicate(s, kx);  gy = convReplicate(s, kx');
mag = hypot(gx, gy);
ang = mod(atan2d(gy, gx), 180);
q = zeros(size(ang));                               % quantize direction
q(ang >= 22.5  & ang < 67.5)  = 45;
q(ang >= 67.5  & ang < 112.5) = 90;
q(ang >= 112.5 & ang < 157.5) = 135;
P = padarray(mag, [1 1], 0);
nb = @(dy, dx) P(2+dy:end-1+dy, 2+dx:end-1+dx);     % shifted neighbour
nms = false(size(mag));
D = [0 0 1; 45 1 1; 90 1 0; 135 1 -1];             % angle, dy, dx of one neighbour (other is opposite)
for i = 1:4
    m  = (q == D(i,1));
    n1 = nb( D(i,2),  D(i,3));
    n2 = nb(-D(i,2), -D(i,3));
    nms(m) = mag(m) >= max(n1(m), n2(m));
end
hi = highRatio * max(mag(:));
lo = 0.4 * hi;
strong = nms & mag >= hi;
weak   = nms & mag >= lo;
bw = imreconstruct(strong, weak);                   % hysteresis (keep weak edges linked to strong)
end
