% DEMO_MODULE2  Student 2 - Segmentation, edges, morphology
clear; clc; close all;
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
img  = loadSample('sample_face.jpg');

compareEdges(img, 0.15);

[otsu, t] = otsuSegment(img);
rg = regionGrow(img, [], 0.1);
showCompare({img, otsu, rg}, {'Original', sprintf('Otsu (t = %d)', t), 'Region growing (center seed)'}, 'Segmentation');

[~, m1] = colorSegment(img, 'rgb');  [~, m2] = colorSegment(img, 'hsv');
showCompare({img, uint8(m1)*255, uint8(m2)*255}, {'Original', 'RGB skin mask', 'HSV skin mask'}, 'Color segmentation');

bw = otsuSegment(img);
showCompare({bw, morphOps(bw,'dilate',2), morphOps(bw,'erode',2), morphOps(bw,'open',2), morphOps(bw,'close',3)}, ...
    {'Binary', 'Dilation', 'Erosion', 'Opening', 'Closing'}, 'Morphological operations');

showCompare({img, shapeSegment(img, 150, 0.3, true)}, {'Original', 'Shape-based (dark round blobs)'}, 'Shape-based segmentation');
