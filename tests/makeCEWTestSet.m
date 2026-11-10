function makeCEWTestSet(nPerClass, cewRoot)
% MAKECEWTESTSET  Build a test set from the CEW (Closed Eyes in the Wild) dataset.
%   makeCEWTestSet                 25 open + 25 closed faces, searched in your Downloads folder
%   makeCEWTestSet(50)             50 + 50
%   makeCEWTestSet(25, 'D:\data\CEW')   search a specific folder instead
%
%   The CEW face images are in two folders, ClosedFace and OpenFace
%   (unzip the .rar file first with 7-Zip or WinRAR). This script:
%     1. finds every image inside those two folders,
%     2. picks nPerClass random images from each (same pick every run: rng(14)),
%     3. copies them to test_images/cew/  as open_001.jpg ... closed_001.jpg,
%     4. writes test_images/ground_truth_cew.csv  (open = alert, closed = drowsy).
%   Then run:   evaluateDataset('face', 0.30, 'ground_truth_cew.csv')
%
%   Dataset citation for the report: F. Song, X. Tan, X. Liu and S. Chen,
%   "Eyes Closeness Detection from Still Images with Multi-scale Histograms of
%   Principal Oriented Gradients," Pattern Recognition, 2014.

if nargin < 1 || isempty(nPerClass), nPerClass = 25; end
if nargin < 2 || isempty(cewRoot)
    home = getenv('USERPROFILE');                 % Windows
    if isempty(home), home = getenv('HOME'); end  % macOS / Linux
    cewRoot = fullfile(home, 'Downloads');
end
if ~exist(cewRoot, 'dir'), error('Folder not found: %s', cewRoot); end

% ---------- 1. find the images ----------
fprintf('Searching for CEW images in %s ...\n', cewRoot);
exts = {'*.jpg', '*.jpeg', '*.png', '*.bmp'};
files = [];
for e = 1:numel(exts)
    files = [files; dir(fullfile(cewRoot, '**', exts{e}))]; %#ok<AGROW>
end
if isempty(files)
    error(['No images found under %s.\nDid you unzip the CEW .rar file? ' ...
           'Right-click it and choose "Extract here" (7-Zip or WinRAR).'], cewRoot);
end
folders = lower({files.folder});
isClosed = contains(folders, 'closedface');
isOpen   = contains(folders, 'openface');
if ~any(isClosed) || ~any(isOpen)
    error(['Could not find the ClosedFace and OpenFace folders under %s.\n' ...
           'Unzip the CEW file, or pass its folder: makeCEWTestSet(25, ''C:\\path\\to\\CEW'')'], cewRoot);
end
closedFiles = files(isClosed);
openFiles   = files(isOpen);
fprintf('Found %d open and %d closed face images.\n', numel(openFiles), numel(closedFiles));

% ---------- 2. random, repeatable pick ----------
rng(14);
openPick   = openFiles(randperm(numel(openFiles),     min(nPerClass, numel(openFiles))));
closedPick = closedFiles(randperm(numel(closedFiles), min(nPerClass, numel(closedFiles))));

% ---------- 3. copy into the toolbox ----------
root   = fileparts(fileparts(mfilename('fullpath')));
outDir = fullfile(root, 'test_images', 'cew');
if exist(outDir, 'dir'), rmdir(outDir, 's'); end   % start fresh each time
mkdir(outDir);

names  = strings(0, 1);
labels = strings(0, 1);
[names, labels] = copySet(openPick,   'open',   'alert',  outDir, names, labels);
[names, labels] = copySet(closedPick, 'closed', 'drowsy', outDir, names, labels);

% ---------- 4. write the label file ----------
T = table(names, labels, 'VariableNames', {'filename', 'label'});
csvPath = fullfile(root, 'test_images', 'ground_truth_cew.csv');
writetable(T, csvPath);
fprintf('Copied %d images to %s\n', height(T), outDir);
fprintf('Labels written to %s\n', csvPath);
fprintf('Next:  evaluateDataset(''face'', 0.30, ''ground_truth_cew.csv'')\n');
end

function [names, labels] = copySet(list, prefix, label, outDir, names, labels)
for i = 1:numel(list)
    [~, ~, ext] = fileparts(list(i).name);
    newName = sprintf('%s_%03d%s', prefix, i, lower(ext));
    copyfile(fullfile(list(i).folder, list(i).name), fullfile(outDir, newName));
    names(end+1, 1)  = "cew/" + newName;   %#ok<AGROW>
    labels(end+1, 1) = label;              %#ok<AGROW>
end
end
