
function out = histogram_matching(img, refImg)
% HISTOGRAM_MATCHING  Match image histogram to a reference image.
%   img    : Input grayscale or RGB image.
%   refImg : Reference grayscale or RGB image.
%   out    : Histogram-matched output image.
%
%   For RGB images, matching is performed on the
%   Value channel in HSV color space.

% Convert images to double
img = im2double(img);
refImg = im2double(refImg);

% Check image type
if size(img, 3) == 3 && size(refImg, 3) == 3

    % Convert RGB images to HSV
    hsvImg = rgb2hsv(img);
    hsvRef = rgb2hsv(refImg);

    % Match Value channel to reference
    hsvImg(:,:,3) = imhistmatch( ...
        hsvImg(:,:,3), hsvRef(:,:,3));

    % Convert back to RGB
    out = hsv2rgb(hsvImg);

else

    % Convert RGB reference to grayscale if necessary
    if size(refImg, 3) == 3
        refImg = rgb2gray(refImg);
    end

    % Convert RGB input to grayscale if necessary
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Perform histogram matching
    out = imhistmatch(img, refImg);

end

end
