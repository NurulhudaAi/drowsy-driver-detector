
function out = fourier_highpass(img, cutoff)
% FOURIER_HIGHPASS  Extract high-frequency details using FFT.
%   img    : Input grayscale or RGB image.
%   cutoff : High-pass cutoff radius (default 30).
%   out    : High-frequency output image.
%
%   Low frequencies are removed while high frequencies
%   are preserved to highlight edges and fine details.

% Set default cutoff
if nargin < 2 || isempty(cutoff)
    cutoff = 30;
end

% Validate cutoff
if cutoff <= 0
    error('Cutoff must be a positive number.');
end

% Convert input image to double
img = im2double(img);

% Get image dimensions
[M, N, C] = size(img);

% Create frequency coordinates
[u, v] = meshgrid(1:N, 1:M);

% Find center of frequency domain
centerU = floor(N/2) + 1;
centerV = floor(M/2) + 1;

% Calculate distance from center
D = sqrt((u - centerU).^2 + (v - centerV).^2);

% Create ideal high-pass mask
H = double(D > cutoff);

% Initialize output
out = zeros(size(img));

% Apply Fourier filtering
for k = 1:C

    % Fourier Transform
    F = fftshift(fft2(img(:,:,k)));

    % Apply high-pass mask
    G = F .* H;

    % Inverse Fourier Transform
    filtered = real(ifft2(ifftshift(G)));

    out(:,:,k) = filtered;

end

% Normalize output for display
for k = 1:C
    out(:,:,k) = mat2gray(out(:,:,k));
end

end
