function showCompare(imgs, titles, figTitle)
% SHOWCOMPARE  Display several images side by side in one figure.
%   showCompare({img1,img2,...}, {'title1','title2',...}, 'Figure title')
n = numel(imgs);
cols = min(n, 4);
rows = ceil(n/cols);
if nargin >= 3, f = figure('Name', figTitle, 'NumberTitle', 'off'); else, f = figure; end
set(f, 'Color', 'w');
for i = 1:n
    subplot(rows, cols, i);
    imshow(imgs{i});
    if nargin >= 2 && numel(titles) >= i, title(titles{i}, 'Interpreter', 'none'); end
end
end
