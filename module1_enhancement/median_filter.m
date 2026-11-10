
function out = median_filter(img, kernelSize)
% MEDIAN_FILTER  Remove noise using a median filter.
%   img        : Input grayscale or RGB image.
%   kernelSize : Filter size (default 3).
%   out        : Noise-reduced output image.

% Set default kernel size
if nargin < 2 || isempty(kernelSize)
    kernelSize = 3;
end

% Validate kernel size
if kernelSize < 1 || mod(kernelSize, 2) == 0 || ...
        kernelSize ~= floor(kernelSize)
    error('Kernel size must be a positive odd integer.');
end

% Apply median filter
if size(img, 3) == 3
    out = zeros(size(img));

    for k = 1:3
        out(:,:,k) = medfilt2(img(:,:,k), ...
            [kernelSize kernelSize], 'symmetric');
    end
else
    out = medfilt2(img, [kernelSize kernelSize], 'symmetric');
end

end
