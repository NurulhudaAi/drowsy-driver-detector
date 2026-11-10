function out = laplacianSharpen(img, c)
% LAPLACIANSHARPEN  g = f - c * Laplacian(f)   (center coefficient is negative).
if nargin < 2, c = 1; end
x = im2double(img);
lap = convReplicate(x, [0 1 0; 1 -4 1; 0 1 0]);
out = im2uint8(min(max(x - c*lap, 0), 1));
end
