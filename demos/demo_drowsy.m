% DEMO_DROWSY  Full pipeline (Modules 1 + 2 + 3) on one image
clear; clc; close all;
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
img = loadSample('sample_face.jpg');
R = drowsyPipeline(img, 'face', 0.30);
showCompare({img, R.enhanced, R.crop, R.overlay}, ...
    {'Input', '1) Enhanced', '2-3) Eye region (resized)', sprintf('4) %s (score %.2f)', R.label, R.score)}, ...
    'Drowsy driver pipeline');
