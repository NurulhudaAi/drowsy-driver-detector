
function out = histogram_equalization(img)
% HISTOGRAM_EQUALIZATION  Improve image contrast using histogram equalization.
%   img : Input grayscale or RGB image.
%   out : Histogram-equalized output image.
%
%   For RGB images, histogram equalization is applied
%   to the Value channel in HSV color space.

% Convert input image to double
img = im2double(img);

% Check image type
if size(img, 3) == 3

    % Convert RGB to HSV
    hsvImg = rgb2hsv(img);

    % Apply histogram equalization to Value channel
    hsvImg(:,:,3) = histeq(hsvImg(:,:,3));

    % Convert HSV back to RGB
    out = hsv2rgb(hsvImg);

else

    % Apply histogram equalization to grayscale image
    out = histeq(img);

end

end
