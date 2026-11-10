function out = freqFilter(img, type, D0, D1, n)
% FREQFILTER  Butterworth filtering in the Fourier domain.
%   type 'lowpass'  : cutoff D0
%        'highpass' : cutoff D0   (result is rescaled for display)
%        'bandpass' : passes frequencies between D0 and D1 (D0 < D1)
%   n = Butterworth order (default 2).
if nargin < 3 || isempty(D0), D0 = 30; end
if nargin < 4 || isempty(D1), D1 = 80; end
if nargin < 5 || isempty(n),  n  = 2;  end
if D0 > D1, t = D0; D0 = D1; D1 = t; end
x = im2double(img);
out = zeros(size(x));
for c = 1:size(x,3)
    ch = x(:,:,c);
    [M, N] = size(ch);
    [u, v] = meshgrid(1:N, 1:M);
    D = sqrt((u - (floor(N/2)+1)).^2 + (v - (floor(M/2)+1)).^2);   % distance from DC
    lp = @(d0) 1 ./ (1 + (D ./ max(d0, eps)).^(2*n));
    switch lower(type)
        case 'lowpass',  H = lp(D0);
        case 'highpass', H = 1 - lp(D0);
        case 'bandpass', H = (1 - lp(D0)) .* lp(D1);
        otherwise, error('Unknown frequency filter: %s', type);
    end
    F = fftshift(fft2(ch));
    y = real(ifft2(ifftshift(F .* H)));
    if ~strcmpi(type, 'lowpass'), y = mat2gray(y); end
    out(:,:,c) = y;
end
out = im2uint8(min(max(out, 0), 1));
end
