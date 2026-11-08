function out = sampleImage(img, xs, ys, method)
% SAMPLEIMAGE  Interpolate img at the (non-integer) coordinates (xs, ys).
%   xs = column coordinates, ys = row coordinates (both same size, 1-based).
%   method: 'nearest' | 'bilinear' | 'bicubic' (Keys cubic convolution, a = -0.5)
%   Points that fall outside the image become black.
if nargin < 4, method = 'bilinear'; end
x = im2double(img);
[h, w, c] = size(x);
tol = 1e-6;                                    % tolerance against floating-point round-off
valid = xs >= 1-tol & xs <= w+tol & ys >= 1-tol & ys <= h+tol;
out = zeros([size(xs) c]);
method = lower(method);
switch method
    case 'nearest'
        xi  = min(max(round(xs), 1), w);
        yi  = min(max(round(ys), 1), h);
        idx = sub2ind([h w], yi, xi);
    case 'bilinear'
        x0 = min(max(floor(xs), 1), max(w-1, 1));
        y0 = min(max(floor(ys), 1), max(h-1, 1));
        x1 = min(x0+1, w);  y1 = min(y0+1, h);
        dx = xs - x0;       dy = ys - y0;
        i00 = sub2ind([h w], y0, x0);  i01 = sub2ind([h w], y0, x1);
        i10 = sub2ind([h w], y1, x0);  i11 = sub2ind([h w], y1, x1);
    case 'bicubic'
        x0 = floor(xs);  y0 = floor(ys);
        dx = xs - x0;    dy = ys - y0;
    otherwise
        error('Unknown interpolation method: %s', method);
end
for k = 1:c
    ch = x(:,:,k);
    switch method
        case 'nearest'
            v = ch(idx);
        case 'bilinear'
            v = ch(i00).*(1-dx).*(1-dy) + ch(i01).*dx.*(1-dy) + ...
                ch(i10).*(1-dx).*dy     + ch(i11).*dx.*dy;
        case 'bicubic'
            v = zeros(size(xs));
            for m = -1:2
                yi = min(max(y0 + m, 1), h);
                wy = cubicW(m - dy);
                for n = -1:2
                    xi = min(max(x0 + n, 1), w);
                    wx = cubicW(n - dx);
                    v = v + ch(sub2ind([h w], yi, xi)) .* wx .* wy;
                end
            end
    end
    out(:,:,k) = min(max(v, 0), 1) .* valid;
end
out = im2uint8(out);
end

function wgt = cubicW(t)
% Keys cubic convolution kernel (a = -0.5)
a = -0.5;
t = abs(t);
wgt = zeros(size(t));
m1 = t <= 1;
m2 = t > 1 & t < 2;
wgt(m1) = (a+2)*t(m1).^3 - (a+3)*t(m1).^2 + 1;
wgt(m2) = a*t(m2).^3 - 5*a*t(m2).^2 + 8*a*t(m2) - 4*a;
end
