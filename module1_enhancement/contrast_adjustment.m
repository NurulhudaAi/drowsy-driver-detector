
function out = contrast_adjustment(img, low, high)
% CONTRAST_ADJUSTMENT  Adjust image contrast using intensity stretching.
%   img  : Input grayscale or RGB image.
%   low  : Lower intensity limit (default 0.1).
%   high : Upper intensity limit (default 0.9).
%   out  : Contrast-adjusted output image.
%
%   Intensity values are stretched to the range [0, 1].

% Set default intensity limits
if nargin < 2 || isempty(low)
    low = 0.1;
end

if nargin < 3 || isempty(high)
    high = 0.9;
end

% Validate intensity limits
if low < 0 || high > 1 || low >= high
    error('Limits must satisfy 0 <= low < high <= 1.');
end

% Convert input image to double
img = im2double(img);

% Check image type
if size(img, 3) == 3

    % Convert RGB to HSV
    hsvImg = rgb2hsv(img);

    % Adjust contrast of Value channel
    hsvImg(:,:,3) = imadjust(hsvImg(:,:,3), [low high], [0 1]);

    % Convert HSV back to RGB
    out = hsv2rgb(hsvImg);

else

    % Adjust grayscale image contrast
    out = imadjust(img, [low high], [0 1]);

end

end
