function g = toGray(img)
% TOGRAY  Convert any input image to a uint8 grayscale image.
if size(img,3) == 3
    g = rgb2gray(img);
elseif size(img,3) > 3
    g = rgb2gray(img(:,:,1:3));
else
    g = img;
end
g = im2uint8(g);
end
