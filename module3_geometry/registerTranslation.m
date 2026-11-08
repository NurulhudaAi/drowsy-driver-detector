function [aligned, shift] = registerTranslation(fixed, moving)
% REGISTERTRANSLATION  (Optional/advanced) Basic image registration by phase
%   correlation in the Fourier domain. Estimates the translation [dy dx] that
%   aligns 'moving' to 'fixed' (both must have the same size) and applies it.
f = im2double(toGray(fixed));
m = im2double(toGray(moving));
if ~isequal(size(f), size(m)), error('Images must have the same size.'); end
R = fft2(f) .* conj(fft2(m));
R = R ./ (abs(R) + eps);                     % normalized cross-power spectrum
r = real(ifft2(R));
[~, idx] = max(r(:));
[py, px] = ind2sub(size(r), idx);
dy = py - 1;  dx = px - 1;
[h, w] = size(f);
if dy > h/2, dy = dy - h; end
if dx > w/2, dx = dx - w; end
shift = [dy dx];
aligned = translateImg(moving, dx, dy, 'bilinear');
end
