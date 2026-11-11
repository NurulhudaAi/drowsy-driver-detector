function f = eyeFeatures(eyeImg)
% EYEFEATURES  Feature vector of one eye image, built from the toolbox modules.
%   Module 3: resize to 24x24 pixels with our own bilinear interpolation (scaleImg)
%   Module 1: histogram equalization, so dark and bright photos look alike
%   Module 2: Sobel gradients (edgeDetect) -> HOG-style orientation histograms
%     24x24 image -> 4x4 cells of 6x6 px -> 9 orientation bins (0-180 deg)
%     -> blocks of 2x2 cells, each L2-normalized -> 3*3*4*9 = 324 values
%   + an 8x8 brightness thumbnail (64 values): an open eye has a dark pupil.
%   f = 1 x 388 row vector.
g = toGray(eyeImg);
[h, w] = size(g);
g = scaleImg(g, 24/w, 24/h, 'bilinear');          % Module 3
g = g(1:24, 1:24);
g = histEqualize(g);                              % Module 1
[~, ~, gx, gy] = edgeDetect(g, 'sobel');          % Module 2
mag = hypot(gx, gy);
ang = mod(atan2d(gy, gx), 180);
nb = 9;  cs = 6;  nc = 4;
bin = min(floor(ang / (180/nb)) + 1, nb);
H = zeros(nc, nc, nb);
for i = 1:nc
    for j = 1:nc
        r = (i-1)*cs + (1:cs);  c = (j-1)*cs + (1:cs);
        b = bin(r, c);  m = mag(r, c);
        H(i, j, :) = accumarray(b(:), m(:), [nb 1]);
    end
end
hog = zeros(1, (nc-1)^2 * 4 * nb);  k = 0;
for i = 1:nc-1
    for j = 1:nc-1
        v = H(i:i+1, j:j+1, :);  v = v(:)';
        v = v / (norm(v) + 1e-6);
        hog(k+1:k+numel(v)) = v;  k = k + numel(v);
    end
end
t = double(scaleImg(g, 1/3, 1/3, 'bilinear'));    % 8x8 thumbnail
t = t(:)';
t = (t - mean(t)) / (std(t) + 1e-6);
f = [hog t];
end
