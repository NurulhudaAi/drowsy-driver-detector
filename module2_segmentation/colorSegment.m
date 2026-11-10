function [out, mask] = colorSegment(img, space, lo, hi)
% COLORSEGMENT  Color-based segmentation in RGB or HSV space.
%   colorSegment(img,'rgb')            classic RGB skin rule
%   colorSegment(img,'hsv')            skin range in HSV
%   colorSegment(img,space,lo,hi)      custom range, lo/hi = 1x3 vectors
%       RGB range 0-255, HSV range 0-1.
if size(img,3) ~= 3, error('colorSegment needs an RGB image.'); end
if nargin < 2, space = 'hsv'; end
switch lower(space)
    case 'rgb'
        x = double(im2uint8(img));
        R = x(:,:,1); G = x(:,:,2); B = x(:,:,3);
        if nargin < 4
            mask = R>95 & G>40 & B>20 & (max(x,[],3)-min(x,[],3))>15 & abs(R-G)>15 & R>G & R>B;
        else
            mask = all(x >= reshape(lo,1,1,3) & x <= reshape(hi,1,1,3), 3);
        end
    case 'hsv'
        x = rgb2hsv(img);
        H = x(:,:,1); S = x(:,:,2); V = x(:,:,3);
        if nargin < 4
            mask = (H <= 0.14 | H >= 0.95) & S >= 0.15 & S <= 0.75 & V >= 0.20;
        else
            mask = all(x >= reshape(lo,1,1,3) & x <= reshape(hi,1,1,3), 3);
        end
    otherwise, error('space must be ''rgb'' or ''hsv''.');
end
out = im2uint8(img) .* uint8(repmat(mask, [1 1 3]));
end
