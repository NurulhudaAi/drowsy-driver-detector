% DEMO_MODULE3  Student 3 - Geometric transformations and interpolation
clear; clc; close all;
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
img = loadSample('sample_face.jpg');

showCompare({img, translateImg(img,60,30), scaleImg(img,0.5), rotateImg(img,30,'bilinear',true), shearImg(img,0.3,0)}, ...
    {'Original', 'Translation', 'Scaling x0.5', 'Rotation 30 deg', 'Shear'}, 'Geometric transformations');

M = tformMatrix('translate',(size(img,2)+1)/2,(size(img,1)+1)/2) * tformMatrix('rotate',30) * ...
    tformMatrix('translate',-(size(img,2)+1)/2,-(size(img,1)+1)/2);
showCompare({warpForward(img, M), warpReverse(img, M, [], 'bilinear')}, ...
    {'Forward mapping (holes)', 'Reverse mapping (no holes)'}, 'Forward vs reverse mapping');

compareInterp(img, 4);

dist = radialCorrect(img, 0.25, 0);          % simulate a distorted image
fix  = radialCorrect(dist, -0.2, 0);         % and correct it
showCompare({img, dist, fix}, {'Original', 'Distorted (simulated)', 'Corrected'}, 'Radial distortion correction');

% Optional: registration by phase correlation
moved = translateImg(img, 25, -15);
[aligned, shift] = registerTranslation(img, moved);
showCompare({img, moved, aligned}, {'Reference', 'Shifted', sprintf('Aligned (shift %d,%d)', shift(1), shift(2))}, 'Image registration');
