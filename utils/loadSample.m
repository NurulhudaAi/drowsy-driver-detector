function img = loadSample(name, fallback)
% LOADSAMPLE  Load test_images/<name>; if it does not exist use a MATLAB
%   built-in image (default 'peppers.png') so every demo runs out of the box.
if nargin < 2, fallback = 'peppers.png'; end
root = fileparts(fileparts(mfilename('fullpath')));
p = fullfile(root, 'test_images', name);
if nargin >= 1 && ~isempty(name) && exist(p, 'file')
    img = imread(p);
else
    img = imread(fallback);
end
if size(img,3) == 4, img = img(:,:,1:3); end
end
