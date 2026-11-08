% SMOKE_TEST  Runs every function once on built-in images to catch errors early.
clear; clc; close all;
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
rgb  = imread('peppers.png');   gry = toGray(rgb);
check('histEqualize', histEqualize(rgb));   check('histMatch', histMatch(rgb, [], 100, 40));
check('grayTransform', grayTransform(rgb,'gamma',0.5)); check('meanFilter', meanFilter(rgb,5));
check('medianFilter', medianFilter(rgb,3)); check('laplacianSharpen', laplacianSharpen(rgb,1));
check('highPassSharpen', highPassSharpen(rgb,5,1)); check('freqFilter-lp', freqFilter(rgb,'lowpass',30));
check('freqFilter-hp', freqFilter(gry,'highpass',30)); check('freqFilter-bp', freqFilter(gry,'bandpass',20,80));
check('sobel', edgeDetect(rgb,'sobel')); check('prewitt', edgeDetect(rgb,'prewitt')); check('canny', edgeDetect(rgb,'canny'));
check('otsu', otsuSegment(rgb)); check('regionGrow', regionGrow(rgb,[],0.1));
check('colorSegment-rgb', colorSegment(rgb,'rgb')); check('colorSegment-hsv', colorSegment(rgb,'hsv'));
for op = {'dilate','erode','open','close'}, check(['morph-' op{1}], morphOps(gry, op{1}, 2)); end
check('shapeSegment', shapeSegment(rgb, 100, 0.3, true));
check('translateImg', translateImg(rgb,20,10)); check('scaleImg', scaleImg(rgb,0.5));
for m = {'nearest','bilinear','bicubic'}, check(['scale-' m{1}], scaleImg(rgb,1.7,1.7,m{1})); end
check('rotateImg', rotateImg(rgb,30,'bilinear',true)); check('shearImg', shearImg(rgb,0.3,0));
check('warpForward', warpForward(rgb, tformMatrix('rotate',20))); check('radialCorrect', radialCorrect(rgb,0.2,0));
[~,s] = registerTranslation(gry, translateImg(gry,12,-7)); fprintf('  registration shift = [%d %d] (expect about [7 -12])\n', s);
R = drowsyPipeline(rgb, 'face', 0.3); check('drowsyPipeline', R.overlay);
fprintf('\nAll smoke tests passed.\n');

function check(name, v)
% local function (must be at the end of a script file)
if isempty(v), error('%s returned empty', name); end
fprintf('  ok  %s\n', name);
end
