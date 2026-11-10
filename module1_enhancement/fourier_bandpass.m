
function out = fourier_bandpass(img, lowCutoff, highCutoff)
% FOURIER_BANDPASS  Preserve selected frequency range using FFT.
%   img         : Input grayscale or RGB image.
%   lowCutoff   : Lower frequency radius (default 10).
%   highCutoff  : Upper frequency radius (default 50).
%   out         : Band-pass filtered output image.
%
%   Frequencies between the lower and upper cutoff
%   are preserved while other frequencies are removed.

% Set default cutoff values
if nargin < 2 || isempty(lowCutoff)
    lowCutoff = 10;
end

if nargin < 3 || isempty(highCutoff)
    highCutoff = 50;
end

% Validate cutoff values
if lowCutoff < 0 || highCutoff <= lowCutoff
    error('Cutoffs must satisfy 0 <= lowCutoff < highCutoff.');
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

% Create ideal band-pass mask
H = double(D >= lowCutoff & D <= highCutoff);

% Initialize output
out = zeros(size(img));

% Apply Fourier filtering
for k = 1:C

    % Fourier Transform
    F = fftshift(fft2(img(:,:,k)));

    % Apply band-pass mask
    G = F .* H;

    % Inverse Fourier Transform
    filtered = real(ifft2(ifftshift(G)));

    % Normalize output for display
    out(:,:,k) = mat2gray(filtered);

end

end
