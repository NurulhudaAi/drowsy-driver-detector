function img = drawBoxes(img, B, color, t)
% DRAWBOXES  Paint the outline of boxes [x y w h] into an RGB image (no toolbox needed).
if nargin < 3 || isempty(color), color = [255 255 0]; end
if nargin < 4 || isempty(t), t = 2; end
img = im2uint8(img);
if size(img,3) == 1, img = repmat(img, [1 1 3]); end
[H, W, ~] = size(img);
B = clipBoxes(B, W, H);
for i = 1:size(B, 1)
    x1 = B(i,1); y1 = B(i,2); x2 = x1 + B(i,3) - 1; y2 = y1 + B(i,4) - 1;
    rows = [y1:min(y1+t-1,y2), max(y2-t+1,y1):y2];
    cols = [x1:min(x1+t-1,x2), max(x2-t+1,x1):x2];
    for c = 1:3
        ch = img(:,:,c);
        ch(rows, x1:x2) = color(c);
        ch(y1:y2, cols) = color(c);
        img(:,:,c) = ch;
    end
end
end
