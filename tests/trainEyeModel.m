function trainEyeModel(eyeRoot)
% TRAINEYEMODEL  Train the open/closed eye classifier on the CEW eye patches.
%   trainEyeModel                  searches your Downloads folder
%   trainEyeModel('/path/to/dataset_B_Eye_Images')
%
%   The CEW eye-patch download contains four folders: closedLeftEyes,
%   closedRightEyes, openLeftEyes, openRightEyes (24x24 images).
%   Steps
%     1. features of every eye (eyeFeatures: Modules 1, 2, 3)
%     2. random, stratified split: 80% training, 20% test (same split every run)
%     3. choose k (1,3,...,11) on a validation part of the training set
%     4. train KNN on all training eyes, measure accuracy on the test eyes
%     5. run the rule-based baseline on the SAME test eyes for comparison
%     6. save models/eyeModel.mat (used automatically by drowsyPipeline)
%        and tests/results_eyes.csv (one row per test eye)
%
%   Dataset: F. Song, X. Tan, X. Liu and S. Chen, "Eyes Closeness Detection from
%   Still Images with Multi-scale Histograms of Principal Oriented Gradients,"
%   Pattern Recognition, 2014.
root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(root));
if nargin < 1 || isempty(eyeRoot)
    home = getenv('USERPROFILE');
    if isempty(home), home = getenv('HOME'); end
    eyeRoot = fullfile(home, 'Downloads');
end
if ~exist(eyeRoot, 'dir'), error('Folder not found: %s', eyeRoot); end

% ---------- 1. find and read the eye images ----------
fprintf('Searching for CEW eye patches in %s ...\n', eyeRoot);
exts = {'*.jpg', '*.jpeg', '*.png', '*.bmp'};
files = [];
for e = 1:numel(exts)
    files = [files; dir(fullfile(eyeRoot, '**', exts{e}))]; %#ok<AGROW>
end
if isempty(files), error('No images found under %s', eyeRoot); end
fl = lower({files.folder});
nm = {files.name};
ok = ~startsWith(nm, '._') & ~contains(fl, '__macosx') & ~contains(fl, lower(root));
isEye    = ok & contains(fl, 'eye') & ~contains(fl, 'face');
isClosed = isEye & contains(fl, 'closed');
isOpen   = isEye & contains(fl, 'open') & ~isClosed;
if ~any(isClosed) || ~any(isOpen)
    error(['Could not find the CEW eye folders (closedLeftEyes, openLeftEyes, ...) under %s.\n' ...
           'Unzip the eye-patch file, or pass its folder: trainEyeModel(''/path/to/folder'')'], eyeRoot);
end
paths = fullfile({files.folder}, nm);
sel = find(isClosed | isOpen);
n = numel(sel);
y = double(isClosed(sel))';                          % 1 = closed, 0 = open
fprintf('Found %d open and %d closed eye images. Computing features ...\n', sum(y==0), sum(y==1));
X = [];
for i = 1:n
    f = eyeFeatures(imread(paths{sel(i)}));
    if i == 1, X = zeros(n, numel(f)); end
    X(i,:) = f;
    if mod(i, 500) == 0, fprintf('  %d / %d\n', i, n); end
end

% ---------- 2. stratified 80/20 split ----------
rng(14);
test = false(n, 1);
for c = [0 1]
    idx = find(y == c);
    idx = idx(randperm(numel(idx)));
    test(idx(1:round(0.2*numel(idx)))) = true;
end
trn = ~test;

% ---------- 3. choose k on a validation part of the training set ----------
ks = [1 3 5 7 9 11];
tIdx = find(trn);  tIdx = tIdx(randperm(numel(tIdx)));
nv = round(0.2 * numel(tIdx));
vIdx = tIdx(1:nv);  fIdx = tIdx(nv+1:end);
acc = zeros(size(ks));
for j = 1:numel(ks)
    m = knnTrain(X(fIdx,:), y(fIdx), ks(j));
    acc(j) = mean(knnPredict(m, X(vIdx,:)) == y(vIdx));
    fprintf('  k = %2d   validation accuracy %.1f %%\n', ks(j), 100*acc(j));
end
[~, j] = max(acc);  k = ks(j);

% ---------- 4. final model + test accuracy ----------
model = knnTrain(X(trn,:), y(trn), k);
[pred, pC] = knnPredict(model, X(test,:));
yt = y(test);
accKnn = mean(pred == yt);
fprintf('\nTRAINED MODEL (KNN, k = %d) on %d test eyes: accuracy = %.1f %%\n', k, numel(yt), 100*accKnn);
printConfusion(pred, yt);

% ---------- 5. rule-based baseline on the same test eyes ----------
fprintf('\nRule-based baseline on the same test eyes ...\n');
ti = sel(test);
sc = zeros(numel(ti), 1);
for i = 1:numel(ti)
    R = drowsyPipeline(imread(paths{ti(i)}), 'eye', 0.30, 'Method', 'rule');
    sc(i) = R.score;
end
accRule = mean((sc < 0.30) == yt);
ths = 0:0.01:1.5;
a = arrayfun(@(t) mean((sc < t) == yt), ths);
[accRuleBest, kk] = max(a);
fprintf('RULE-BASED: accuracy = %.1f %% at threshold 0.30, best %.1f %% at threshold %.2f\n', ...
        100*accRule, 100*accRuleBest, ths(kk));
printConfusion(sc < 0.30, yt);

% ---------- 6. save ----------
info = struct('k', k, 'nTrain', sum(trn), 'nTest', sum(test), 'testAccuracy', accKnn, ...
              'ruleAccuracy', accRule, 'ruleBestAccuracy', accRuleBest, ...
              'ruleBestThreshold', ths(kk), 'source', eyeRoot, 'date', datestr(now));
if ~exist(fullfile(root, 'models'), 'dir'), mkdir(fullfile(root, 'models')); end
save(fullfile(root, 'models', 'eyeModel.mat'), 'model', 'info');
labels = {'open', 'closed'};
T = table(string(paths(ti))', string(labels(yt+1))', pC, sc, ...
          'VariableNames', {'file', 'truth', 'knnClosedProbability', 'ruleOpennessScore'});
writetable(T, fullfile(root, 'tests', 'results_eyes.csv'));
loadEyeModel('reload');
fprintf('\nSaved models/eyeModel.mat and tests/results_eyes.csv\n');
fprintf('The GUI, evaluateDataset and demo_live now use the trained model automatically.\n');
end

function printConfusion(pred, truth)
pred = logical(pred(:));  truth = logical(truth(:));
TN = sum(~pred & ~truth);  FP = sum(pred & ~truth);
FN = sum(~pred & truth);   TP = sum(pred & truth);
fprintf('Confusion matrix  (rows = truth, cols = predicted)\n');
fprintf('            OPEN  CLOSED\n  OPEN    %6d  %6d\n  CLOSED  %6d  %6d\n', TN, FP, FN, TP);
end
