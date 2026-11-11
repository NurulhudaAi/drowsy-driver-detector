function img = loadSample(name, fallback)
% LOADSAMPLE  Load test_images/<name>. Also accepts the same name with another
%   extension (.jpeg .png .JPG ...). If no file is found, a MATLAB built-in image
%   (default 'peppers.png') is used and a WARNING tells you where to put your photo.
if nargin < 2, fallback = 'peppers.png'; end
root = fileparts(fileparts(mfilename('fullpath')));
folder = fullfile(root, 'test_images');
p = '';
if nargin >= 1 && ~isempty(name)
    [~, base] = fileparts(name);
    cands = [{name}, strcat(base, {'.jpg','.jpeg','.png','.JPG','.JPEG','.PNG','.bmp'})];
    for i = 1:numel(cands)
        if exist(fullfile(folder, cands{i}), 'file')
            p = fullfile(folder, cands{i});
            break;
        end
    end
end
if ~isempty(p)
    img = imread(p);
    fprintf('Using your image: %s\n', p);
else
    img = imread(fallback);
    warning(['%s was not found in %s\nUsing the MATLAB test image "%s" instead.\n' ...
             'Save your face photo there as %s (JPG or PNG) and run again.'], ...
            name, folder, fallback, name);
end
if size(img,3) == 4, img = img(:,:,1:3); end
end
