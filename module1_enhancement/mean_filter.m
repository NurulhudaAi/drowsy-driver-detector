
function out = mean_filter(img, kernelSize)
% MEAN_FILTER  Reduce image noise using a mean filter.
%   img        : Input grayscale or RGB image.
%   kernelSize : Size of averaging filter (default 3).
%   out        : Smoothed output image.
%
%   Each pixel is replaced by the average value
%   of its neighboring pixels.

% Set default kernel size
if nargin < 2 || isempty(kernelSize)
    kernelSize = 3;
end

% Validate kernel size
if kernelSize < 1 || mod(kernelSize, 2) == 0
    error('Kernel size must be a positive odd number.');
end

% Convert input image to double
img = im2double(img);

% Create averaging filter
h = ones(kernelSize, kernelSize) / kernelSize^2;

% Check image type
if size(img, 3) == 3

    % Apply mean filter to each RGB channel
    out = zeros(size(img));

    for k = 1:3
        out(:,:,k) = imfilter(img(:,:,k), h, 'replicate');
    end

else

    % Apply mean filter to grayscale image
    out = imfilter(img, h, 'replicate');

end

end
