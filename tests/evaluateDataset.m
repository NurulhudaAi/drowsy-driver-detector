function evaluateDataset(mode, thr, csvName, method)
% EVALUATEDATASET  Run the drowsy pipeline on every image listed in a label file
%   in test_images/ (columns: filename,label  with label = alert|drowsy),
%   print accuracy + confusion matrix, search the best threshold and save the scores.
%     evaluateDataset('face')                                   your photos, trained model
%     evaluateDataset('face', [], 'ground_truth_cew.csv')       CEW faces, trained model
%     evaluateDataset('face', [], 'ground_truth_cew.csv', 'rule')   rule-based baseline
%     evaluateDataset('face', 0.30, 'ground_truth_cew.csv', false)  rule, no eyebrow removal
%   thr = [] -> default of the method (0.50 trained model, 0.30 rule-based).
%   method = 'auto' (default) | 'knn' | 'rule' | true/false (rule with/without eyebrow removal)
%   Results go to tests/results.csv, or tests/results_<name>_<method>.csv.
if nargin < 1 || isempty(mode), mode = 'face'; end
if nargin < 2, thr = []; end
if nargin < 3 || isempty(csvName), csvName = 'ground_truth.csv'; end
if nargin < 4 || isempty(method), method = 'auto'; end
root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(root));
imgDir = fullfile(root, 'test_images');
csvPath = fullfile(imgDir, csvName);                 % label files live in test_images/
if ~isfile(csvPath), csvPath = fullfile(root, 'tests', csvName); end   % or in tests/
if ~isfile(csvPath)
    error('CSV file not found in test_images/ or tests/: %s', csvName);
end
Tb = readtable(csvPath, 'TextType', 'string');
names  = string(Tb.filename);
truth  = strcmpi(string(Tb.label), 'drowsy');
n = numel(names);  scores = zeros(n, 1);  usedThr = thr;  usedMethod = '';
for i = 1:n
    I = imread(fullfile(imgDir, names(i)));
    if islogical(method)
        R = drowsyPipeline(I, mode, thr, method);
    else
        R = drowsyPipeline(I, mode, thr, 'Method', method);
    end
    scores(i) = R.score;  usedThr = R.thr;  usedMethod = R.method;
end
pred = scores < usedThr;
TP = sum(pred & truth);  TN = sum(~pred & ~truth);  FP = sum(pred & ~truth);  FN = sum(~pred & truth);
fprintf('Method: %s | images: %d | threshold %.2f | accuracy = %.1f %%\n', ...
        usedMethod, n, usedThr, 100*mean(pred == truth));
fprintf('Confusion matrix  (rows = truth, cols = predicted)\n            ALERT  DROWSY\n  ALERT   %6d  %6d\n  DROWSY  %6d  %6d\n', TN, FP, FN, TP);
ths = 0:0.01:1.5;
accs = arrayfun(@(t) mean((scores < t) == truth), ths);
[best, k] = max(accs);
fprintf('Best threshold on this set: %.2f -> accuracy %.1f %%\n', ths(k), 100*best);
out = table(names, string(Tb.label), scores, pred, 'VariableNames', {'filename','truth','score','predicted_drowsy'});
if strcmpi(csvName, 'ground_truth.csv')
    base = 'results';
else
    [~, b] = fileparts(csvName);
    base = ['results_' strrep(b, 'ground_truth_', '')];
end
resName = sprintf('%s_%s.csv', base, usedMethod);
writetable(out, fullfile(root, 'tests', resName));
fprintf('Scores saved to tests/%s\n', resName);
end
