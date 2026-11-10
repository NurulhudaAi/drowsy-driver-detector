
function out = brightness_adjustment(img, brightness)
% BRIGHTNESS_ADJUSTMENT  Adjust image brightness.
%   img        : Input grayscale or RGB image.
%   brightness : Brightness adjustment value.
%                Positive values make the image brighter.
%                Negative values make the image darker.
%                Default value is 0.1.
%   out        : Brightness-adjusted output image.
%
%   Pixel values are clipped to the range [0, 1].

% Set default brightness value
if nargin < 2 || isempty(brightness)
    brightness = 0.1;
end

% Convert input image to double
img = im2double(img);

% Check image type
if size(img, 3) == 3

    % Convert RGB to HSV
    hsvImg = rgb2hsv(img);

    % Adjust brightness using Value channel
    hsvImg(:,:,3) = hsvImg(:,:,3) + brightness;

    % Limit pixel values
    hsvImg(:,:,3) = min(max(hsvImg(:,:,3), 0), 1);

    % Convert HSV back to RGB
    out = hsv2rgb(hsvImg);

else

    % Adjust grayscale image brightness
    out = img + brightness;

    % Limit pixel values
    out = min(max(out, 0), 1);

end

end
