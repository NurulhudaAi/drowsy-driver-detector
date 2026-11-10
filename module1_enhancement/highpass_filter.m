
function out = highpass_filter(img)
% HIGHPASS_FILTER  Enhance edges using a spatial high-pass filter.
%   img : Input grayscale or RGB image.
%   out : High-pass filtered output image.

% Convert input image to double
img = im2double(img);

% Define high-pass kernel
h = [-1 -1 -1;
    -1  8 -1;
    -1 -1 -1];

% Apply high-pass filter
if size(img, 3) == 3
    out = zeros(size(img));

    for k = 1:3
        out(:,:,k) = imfilter(img(:,:,k), h, 'replicate');
    end
else
    out = imfilter(img, h, 'replicate');
end

% Normalize output for display
out = mat2gray(out);

end
