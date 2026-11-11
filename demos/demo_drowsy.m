% DEMO_DROWSY  Full pipeline (Modules 1 + 2 + 3 + trained model) on one image.
%   Uses the trained eye-state model if models/eyeModel.mat exists (run trainEyeModel
%   first), otherwise the rule-based method. A second figure shows the rule-based
%   baseline on the same image for comparison.
clear; clc; close all;
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
img = loadSample('sample_face.jpg');

R = drowsyPipeline(img, 'face');                      % trained model (or rule if none)
vis = drawBoxes(R.enhanced, R.eyes, [255 255 0], 2);
if ~isempty(R.face), vis = drawBoxes(vis, R.face, [0 160 255], 2); end
showCompare({img, vis, R.overlay}, ...
    {'Input', sprintf('1-2) Enhanced + face/eyes (%s)', R.locator), ...
     sprintf('3-5) %s  openness %.2f  (%s)', R.label, R.score, R.method)}, ...
    'Drowsy driver pipeline');

B = drowsyPipeline(img, 'face', [], 'Method', 'rule');  % baseline
showCompare({img, B.enhanced, B.crop, B.overlay}, ...
    {'Input', '1) Enhanced', '2-3) Skin eye band (resized)', ...
     sprintf('4) %s (score %.2f)', B.label, B.score)}, ...
    'Rule-based baseline');
fprintf('Trained model: %s (openness %.2f, threshold %.2f, eyes found by %s, tilt %.0f deg)\n', ...
        R.label, R.score, R.thr, R.locator, R.tilt);
fprintf('Rule-based   : %s (score %.2f, threshold %.2f)\n', B.label, B.score, B.thr);
