function out = regionGrow(img, seed, tol)
% REGIONGROW  Region growing from a seed pixel (8-connectivity).
%   seed = [row col] (default: image center); tol = max intensity difference
%   (0-1) from the seed intensity. Output is a uint8 mask (255 = region).
g = im2double(toGray(img));
[h, w] = size(g);
if nargin < 2 || isempty(seed), seed = round([h w] / 2); end
if nargin < 3 || isempty(tol),  tol = 0.1; end
seed = min(max(round(seed), 1), [h w]);
r1 = max(seed(1)-1,1); r2 = min(seed(1)+1,h);
c1 = max(seed(2)-1,1); c2 = min(seed(2)+1,w);
ref = mean(mean(g(r1:r2, c1:c2)));         % robust seed intensity
mask = false(h, w);  visited = false(h, w);
queue = zeros(h*w, 2);
head = 1; tail = 1;
queue(1,:) = seed;  visited(seed(1), seed(2)) = true;
while head <= tail
    p = queue(head,:);  head = head + 1;
    if abs(g(p(1), p(2)) - ref) <= tol
        mask(p(1), p(2)) = true;
        for dy = -1:1
            for dx = -1:1
                q = p + [dy dx];
                if q(1) >= 1 && q(1) <= h && q(2) >= 1 && q(2) <= w && ~visited(q(1), q(2))
                    visited(q(1), q(2)) = true;
                    tail = tail + 1;
                    queue(tail,:) = q;
                end
            end
        end
    end
end
out = uint8(mask) * 255;
end
