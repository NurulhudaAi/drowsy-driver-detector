function out = warpForward(img, T, outSize)
% WARPFORWARD  Forward mapping: every INPUT pixel is moved to T*(x,y) and
%   rounded to the nearest output pixel. Holes/gaps can appear (that is the
%   reason reverse mapping is preferred) - use it to demonstrate the problem.
img = im2uint8(img);
[h, w, c] = size(img);
if nargin < 3 || isempty(outSize), outSize = [h w]; end
Ho = outSize(1);  Wo = outSize(2);
[x, y] = meshgrid(1:w, 1:h);
P  = T * [x(:)'; y(:)'; ones(1, numel(x))];
xo = round(P(1,:) ./ P(3,:));  xo = xo(:);
yo = round(P(2,:) ./ P(3,:));  yo = yo(:);
ok = xo >= 1 & xo <= Wo & yo >= 1 & yo <= Ho;
idx = sub2ind([Ho Wo], yo(ok), xo(ok));
out = zeros(Ho, Wo, c, 'uint8');
for k = 1:c
    ch  = img(:,:,k);   chv = ch(:);
    tmp = zeros(Ho, Wo, 'uint8');
    tmp(idx) = chv(ok);
    out(:,:,k) = tmp;
end
end
