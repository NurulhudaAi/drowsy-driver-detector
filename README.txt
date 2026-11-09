Smart Image Processing Toolbox - Topic 14: Drowsy Driver Detection System
=========================================================================
Requirements : MATLAB R2019b or newer + Image Processing Toolbox
               (check with:  ver   ->  "Image Processing Toolbox")
How to run   : open this folder in MATLAB and run   main.m
               (it adds every sub-folder to the path and opens the GUI)

Folder structure / owner
------------------------
module1_enhancement/   Student 1  histogram equalization & matching, gray-level transforms,
                                  mean/median, Laplacian & high-pass sharpening, Fourier LP/HP/BP
module2_segmentation/  Student 2  Sobel/Prewitt/Canny, Otsu, region growing, RGB/HSV color
                                  segmentation, dilation/erosion/opening/closing, shape-based
                                  segmentation, eye-region detection, drowsiness decision
module3_geometry/      Student 3  translation, scaling, rotation, affine/shear, forward & reverse
                                  mapping, radial distortion correction, nearest/bilinear/bicubic
                                  interpolation, registration (phase correlation, optional)
pipeline/              Student 3  drowsyPipeline.m = Enhance -> Detect -> Transform -> Decide
gui/                   Student 3  DrowsyToolbox.m (programmatic GUI, plain text = Git friendly)
utils/                 shared     helpers (toGray, toBinary, convReplicate, showCompare, loadSample)
demos/                 each       demo_module1/2/3.m and demo_drowsy.m  (figures for the report)
tests/                 Student 3  smoke_test.m (runs every function) and evaluateDataset.m (accuracy)
test_images/           everyone   your images + ground_truth.csv (filename,label = alert|drowsy)
report/                everyone   figures, screenshots, report

Function convention:  out = fn(img, params...)   (image in -> image out)

Suggested workflow
------------------
1. Run  tests/smoke_test.m   -> every function must print "ok".
2. Put 15-20 images in test_images/ (sample_face.jpg is used by the demos) and fill ground_truth.csv.
3. Run the demos, save the figures into report/.
4. Run  evaluateDataset('eye')  or  evaluateDataset('face')  and copy the accuracy table into the report.
5. Tune the openness threshold (GUI slider / evaluateDataset) on your own images.

Notes
-----
- Core algorithms (histogram equalization/matching, filters, Otsu, region growing, morphology,
  Sobel/Prewitt/Canny, all warps and interpolations) are implemented from scratch; the Image
  Processing Toolbox is only used for helpers (rgb2hsv, padarray, bwlabel, regionprops, imreconstruct...).
- The drowsiness decision is a classical image-processing heuristic (dark-blob openness ratio),
  not a trained model: lighting, glasses and head pose affect it. Report this honestly as a limitation.
