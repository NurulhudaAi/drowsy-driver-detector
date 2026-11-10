
function out = laplacian_sharpening(img, alpha)
% LAPLACIAN_SHARPENING  Sharpen image using Laplacian filtering.
%   img   : Input grayscale or RGB image.
%   alpha : Sharpening strength (default 0.5).
%   out   : Sharpened output image.

% Set default sharpening strength
if nargin < 2 || isempty(alpha)
    alpha = 0.5;
end

% Validate alpha
if alpha < 0
    error('Alpha must be non-negative.');
end

% Convert input image to double
img = im2double(img);

% Define Laplacian kernel
h = [0 -1 0; -1 4 -1; 0 -1 0];

% Apply Laplacian sharpening
if size(img, 3) == 3
    out = zeros(size(img));

    for k = 1:3
        lap = imfilter(img(:,:,k), h, 'replicate');
        out(:,:,k) = img(:,:,k) + alpha * lap;
    end
else
    lap = imfilter(img, h, 'replicate');
    out = img + alpha * lap;
end

% Limit output intensity
out = min(max(out, 0), 1);

end
