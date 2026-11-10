% DEMO_MODULE1  Student 1 - Image enhancement and filtering
clear; clc; close all;
addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
img  = loadSample('sample_face.jpg');
gray = toGray(img);

% Histogram processing
showCompare({gray, histEqualize(gray), histMatch(gray, [], 128, 40)}, ...
    {'Original', 'Equalized', 'Matched (Gaussian target)'}, 'Histogram processing');
showCompare({gray, grayTransform(gray,'negative'), grayTransform(gray,'gamma',0.5), ...
    grayTransform(gray,'log',10), grayTransform(gray,'linear',1.5,-0.1)}, ...
    {'Original', 'Negative', 'Gamma 0.5', 'Log', 'Contrast 1.5 / brightness -0.1'}, 'Gray-level transforms');
figure('Name','Histograms','Color','w');
subplot(1,2,1); imhist(gray); title('Original histogram');
subplot(1,2,2); imhist(histEqualize(gray)); title('Equalized histogram');

% Spatial filtering (add salt & pepper noise first)
noisy = imnoise(gray, 'salt & pepper', 0.05);
showCompare({noisy, meanFilter(noisy,3), medianFilter(noisy,3)}, ...
    {'Noisy', 'Mean 3x3', 'Median 3x3'}, 'Noise reduction');
showCompare({gray, laplacianSharpen(gray,1), highPassSharpen(gray,5,1.5)}, ...
    {'Original', 'Laplacian sharpening', 'High-boost sharpening'}, 'Sharpening');

% Frequency-domain filtering
showCompare({gray, freqFilter(gray,'lowpass',30), freqFilter(gray,'highpass',30), freqFilter(gray,'bandpass',20,80)}, ...
    {'Original', 'Low-pass', 'High-pass', 'Band-pass'}, 'Fourier filtering');
