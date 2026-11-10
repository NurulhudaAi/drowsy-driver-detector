function out = medianFilter(img, k)
% MEDIANFILTER  k-by-k median filter (good against salt-and-pepper noise).
if nargin < 2, k = 3; end
k = 2*floor(k/2) + 1;
r = (k-1)/2;
x = im2double(img);
[h, w, c] = size(x);
out = zeros(h, w, c);
for ch = 1:c
    P = padarray(x(:,:,ch), [r r], 'replicate');
    stack = zeros(h, w, k*k);
    idx = 0;
    for dy = 0:k-1
        for dx = 0:k-1
            idx = idx + 1;
            stack(:,:,idx) = P(1+dy:h+dy, 1+dx:w+dx);
        end
    end
    out(:,:,ch) = median(stack, 3);
end
out = im2uint8(out);
end
