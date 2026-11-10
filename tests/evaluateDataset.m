function evaluateDataset(mode, thr, csvName)
% EVALUATEDATASET  Run the drowsy pipeline on every image listed in
%   test_images/ground_truth.csv (columns: filename,label  with label = alert|drowsy),
%   print accuracy + confusion matrix, search the best threshold and save
%   tests/results.csv  (use these numbers in the report's accuracy table).
%     evaluateDataset('eye', 0.30)    for cropped eye images (e.g. MRL Eye dataset)
%     evaluateDataset('face', 0.30)   for full face images
%     evaluateDataset('face', 0.30, 'ground_truth_cew.csv')   another label file in test_images/
%   Results go to tests/results.csv (or tests/results_<csv name>.csv for another label file).
if nargin < 1 || isempty(mode), mode = 'eye'; end
if nargin < 2 || isempty(thr),  thr  = 0.30;  end
if nargin < 3 || isempty(csvName), csvName = 'ground_truth.csv'; end
root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(root));
imgDir = fullfile(root, 'test_images');
Tb = readtable(fullfile(imgDir, csvName), 'TextType', 'string');
names  = string(Tb.filename);
truth  = strcmpi(string(Tb.label), 'drowsy');
n = numel(names);  scores = zeros(n, 1);
for i = 1:n
    R = drowsyPipeline(imread(fullfile(imgDir, names(i))), mode, thr);
    scores(i) = R.score;
end
pred = scores < thr;
TP = sum(pred & truth);  TN = sum(~pred & ~truth);  FP = sum(pred & ~truth);  FN = sum(~pred & truth);
fprintf('Images: %d | threshold %.2f | accuracy = %.1f %%\n', n, thr, 100*mean(pred == truth));
fprintf('Confusion matrix  (rows = truth, cols = predicted)\n            ALERT  DROWSY\n  ALERT   %6d  %6d\n  DROWSY  %6d  %6d\n', TN, FP, FN, TP);
ths = 0:0.01:1.5;
accs = arrayfun(@(t) mean((scores < t) == truth), ths);
[best, k] = max(accs);
fprintf('Best threshold on this set: %.2f -> accuracy %.1f %%\n', ths(k), 100*best);
out = table(names, string(Tb.label), scores, pred, 'VariableNames', {'filename','truth','score','predicted_drowsy'});
if strcmpi(csvName, 'ground_truth.csv')
    resName = 'results.csv';
else
    [~, b] = fileparts(csvName);
    resName = ['results_' strrep(b, 'ground_truth_', '') '.csv'];
end
writetable(out, fullfile(root, 'tests', resName));
fprintf('Scores saved to tests/%s\n', resName);
end
