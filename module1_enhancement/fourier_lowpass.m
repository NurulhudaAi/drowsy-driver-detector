
function out = fourier_lowpass(img, cutoff)
% FOURIER_LOWPASS  Remove high-frequency components using FFT.
%   img    : Input grayscale or RGB image.
%   cutoff : Low-pass cutoff radius (default 30).
%   out    : Smoothed output image.
%
%   Low frequencies are preserved while high frequencies
%   are removed to reduce fine details and noise.

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

% Create ideal low-pass mask
H = double(D <= cutoff);

% Initialize output
out = zeros(size(img));

% Apply Fourier filtering
for k = 1:C

    % Fourier Transform
    F = fftshift(fft2(img(:,:,k)));

    % Apply low-pass mask
    G = F .* H;

    % Inverse Fourier Transform
    filtered = real(ifft2(ifftshift(G)));

    out(:,:,k) = filtered;

end

% Limit output intensity
out = min(max(out, 0), 1);

end
