function B = clipBoxes(B, W, H)
% CLIPBOXES  Round boxes [x y w h] to whole pixels and keep them inside a W x H image.
for i = 1:size(B, 1)
    x1 = min(max(1, round(B(i,1))), max(1, W-3));
    y1 = min(max(1, round(B(i,2))), max(1, H-3));
    x2 = min(W, max(x1+3, round(B(i,1) + B(i,3) - 1)));
    y2 = min(H, max(y1+3, round(B(i,2) + B(i,4) - 1)));
    B(i,:) = [x1 y1 x2-x1+1 y2-y1+1];
end
end
