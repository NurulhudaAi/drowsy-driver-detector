function DrowsyToolbox()
% DROWSYTOOLBOX  GUI of the Smart Image Processing Toolbox (topic 14: Drowsy Driver
%   Detection). Load an image, choose a module and a technique, set the
%   parameters and press "Apply". Written programmatically (uifigure) so that
%   the file is plain text and can be merged with Git.
%   Requires MATLAB R2019b+ and the Image Processing Toolbox.

img = [];  res = [];  seed = [];  T = struct('module',{},'name',{},'p1',{},'p2',{},'fn',{});

% ---------------- build UI ----------------
fig = uifigure('Name', 'Smart Image Processing Toolbox - Drowsy Driver Detection', ...
               'Position', [80 60 1150 650]);
gl = uigridlayout(fig, [1 2]);  gl.ColumnWidth = {300, '1x'};
ctrl = uipanel(gl, 'Title', 'Controls');
cl = uigridlayout(ctrl, [12 1]);
cl.RowHeight = {34, 20, 28, 20, 28, 20, 36, 20, 36, 34, 34, '1x'};
btnLoad  = uibutton(cl, 'Text', 'Load image...', 'ButtonPushedFcn', @onLoad);
uilabel(cl, 'Text', 'Module');
ddModule = uidropdown(cl, 'Items', {'Enhancement','Segmentation & Edges','Geometry','Drowsy Driver Detection'}, ...
                      'ValueChangedFcn', @onModule);
uilabel(cl, 'Text', 'Technique');
ddTech   = uidropdown(cl, 'Items', {' '}, 'ValueChangedFcn', @onTech);
lbl1 = uilabel(cl, 'Text', 'Parameter 1');
sl1  = uislider(cl, 'ValueChangingFcn', @(s,e) setLbl(lbl1, 1, e.Value), 'ValueChangedFcn', @(s,e) setLbl(lbl1, 1, s.Value));
lbl2 = uilabel(cl, 'Text', 'Parameter 2');
sl2  = uislider(cl, 'ValueChangingFcn', @(s,e) setLbl(lbl2, 2, e.Value), 'ValueChangedFcn', @(s,e) setLbl(lbl2, 2, s.Value));
btnApply = uibutton(cl, 'Text', 'Apply', 'FontWeight', 'bold', 'ButtonPushedFcn', @onApply);
btnSave  = uibutton(cl, 'Text', 'Save result...', 'ButtonPushedFcn', @onSave);
lblStatus = uilabel(cl, 'Text', 'Load an image to begin.', 'WordWrap', 'on', 'VerticalAlignment', 'top', 'FontSize', 14);

al = uigridlayout(gl, [1 2]);
axOrig = uiaxes(al);  title(axOrig, 'Original');  axis(axOrig, 'off');
axRes  = uiaxes(al);  title(axRes,  'Result');    axis(axRes,  'off');

% ---------------- technique table ----------------
P = @(label, mn, mx, v) struct('label', label, 'min', mn, 'max', mx, 'val', v);
none = [];
% Module 1
addT('Enhancement', 'Histogram equalization', none, none, @(I,a,b) histEqualize(I));
addT('Enhancement', 'Histogram matching (Gaussian target)', P('Target mean',0,255,128), P('Target sigma',10,100,50), @(I,a,b) histMatch(I, [], a, b));
addT('Enhancement', 'Negative', none, none, @(I,a,b) grayTransform(I,'negative'));
addT('Enhancement', 'Log transform', P('Log constant',1,100,10), none, @(I,a,b) grayTransform(I,'log',a));
addT('Enhancement', 'Gamma (power-law)', P('Gamma',0.2,3,1), none, @(I,a,b) grayTransform(I,'gamma',a));
addT('Enhancement', 'Brightness / contrast', P('Contrast',0.2,3,1.2), P('Brightness',-0.5,0.5,0), @(I,a,b) grayTransform(I,'linear',a,b));
addT('Enhancement', 'Mean filter (smoothing)', P('Kernel size',3,15,3), none, @(I,a,b) meanFilter(I, round(a)));
addT('Enhancement', 'Median filter (noise)', P('Kernel size',3,15,3), none, @(I,a,b) medianFilter(I, round(a)));
addT('Enhancement', 'Laplacian sharpening', P('Strength',0,2,1), none, @(I,a,b) laplacianSharpen(I, a));
addT('Enhancement', 'High-pass (high-boost) sharpening', P('Kernel size',3,15,5), P('Boost',0,3,1), @(I,a,b) highPassSharpen(I, round(a), b));
addT('Enhancement', 'Fourier low-pass', P('Cutoff D0',5,200,40), none, @(I,a,b) freqFilter(I,'lowpass',a));
addT('Enhancement', 'Fourier high-pass', P('Cutoff D0',5,200,30), none, @(I,a,b) freqFilter(I,'highpass',a));
addT('Enhancement', 'Fourier band-pass', P('Inner D0',5,150,20), P('Outer D1',10,250,80), @(I,a,b) freqFilter(I,'bandpass',a,b));
% Module 2
addT('Segmentation & Edges', 'Sobel edges', P('Threshold',0.02,0.8,0.15), none, @(I,a,b) edgeDetect(I,'sobel',a));
addT('Segmentation & Edges', 'Prewitt edges', P('Threshold',0.02,0.8,0.15), none, @(I,a,b) edgeDetect(I,'prewitt',a));
addT('Segmentation & Edges', 'Canny edges', P('High threshold',0.05,0.8,0.25), none, @(I,a,b) edgeDetect(I,'canny',a));
addT('Segmentation & Edges', 'Compare edge detectors (new figure)', P('Threshold',0.02,0.8,0.15), none, @cmpEdges);
addT('Segmentation & Edges', 'Otsu thresholding', none, none, @(I,a,b) otsuSegment(I));
addT('Segmentation & Edges', 'Region growing (click seed on original)', P('Tolerance',0.01,0.5,0.1), none, @(I,a,b) regionGrow(I, seed, a));
addT('Segmentation & Edges', 'Color segmentation - RGB (skin)', none, none, @(I,a,b) colorSegment(I,'rgb'));
addT('Segmentation & Edges', 'Color segmentation - HSV (skin)', none, none, @(I,a,b) colorSegment(I,'hsv'));
addT('Segmentation & Edges', 'Dilation', P('Radius',1,10,2), none, @(I,a,b) morphOps(I,'dilate',round(a)));
addT('Segmentation & Edges', 'Erosion', P('Radius',1,10,2), none, @(I,a,b) morphOps(I,'erode',round(a)));
addT('Segmentation & Edges', 'Opening', P('Radius',1,10,2), none, @(I,a,b) morphOps(I,'open',round(a)));
addT('Segmentation & Edges', 'Closing', P('Radius',1,10,2), none, @(I,a,b) morphOps(I,'close',round(a)));
addT('Segmentation & Edges', 'Shape-based segmentation (dark blobs)', P('Min area',10,3000,150), P('Min circularity',0,1,0.3), @(I,a,b) shapeSegment(I, a, b, true));
% Module 3
addT('Geometry', 'Translation', P('Shift X (px)',-300,300,40), P('Shift Y (px)',-300,300,20), @(I,a,b) translateImg(I, a, b, 'bilinear'));
addT('Geometry', 'Scaling / zoom (bilinear)', P('Scale',0.25,4,1.5), none, @(I,a,b) scaleImg(I, a, a, 'bilinear'));
addT('Geometry', 'Rotation (bilinear)', P('Angle (deg)',-180,180,30), none, @(I,a,b) rotateImg(I, a, 'bilinear', true));
addT('Geometry', 'Affine shear', P('Shear X',-1,1,0.3), P('Shear Y',-1,1,0), @(I,a,b) shearImg(I, a, b, 'bilinear'));
addT('Geometry', 'Resize - nearest neighbor', P('Scale',0.25,6,3), none, @(I,a,b) scaleImg(I, a, a, 'nearest'));
addT('Geometry', 'Resize - bilinear', P('Scale',0.25,6,3), none, @(I,a,b) scaleImg(I, a, a, 'bilinear'));
addT('Geometry', 'Resize - bicubic', P('Scale',0.25,6,3), none, @(I,a,b) scaleImg(I, a, a, 'bicubic'));
addT('Geometry', 'Forward mapping rotation (shows holes)', P('Angle (deg)',-180,180,30), none, @fwdRotate);
addT('Geometry', 'Radial distortion correction', P('k1',-0.6,0.6,0.2), P('k2',-0.3,0.3,0), @(I,a,b) radialCorrect(I, a, b));
% Drowsy driver
addT('Drowsy Driver Detection', 'Full pipeline on FACE image', P('Openness threshold',0.05,1,0.30), none, @runFace);
addT('Drowsy Driver Detection', 'Pipeline on cropped EYE image', P('Openness threshold',0.05,1,0.30), none, @runEye);

onModule();

% ---------------- callbacks ----------------
    function addT(module, name, p1, p2, fn)
        T(end+1) = struct('module', module, 'name', name, 'p1', {p1}, 'p2', {p2}, 'fn', fn);
    end

    function onModule(~, ~)
        names = {T(strcmp({T.module}, ddModule.Value)).name};
        ddTech.Items = names;
        ddTech.Value = names{1};
        onTech();
    end

    function onTech(~, ~)
        t = currentTech();
        configSlider(sl1, lbl1, t.p1, 1);
        configSlider(sl2, lbl2, t.p2, 2);
    end

    function configSlider(sl, lbl, p, which)
        if isempty(p)
            sl.Enable = 'off';
            lbl.Text = sprintf('Parameter %d: (not used)', which);
            return;
        end
        sl.Enable = 'on';
        lo = min(p.min, sl.Value);  hi = max(p.max, sl.Value);   % widen first so the old value stays valid
        sl.Limits = [lo hi];
        sl.Value  = p.val;
        sl.Limits = [p.min p.max];
        setLbl(lbl, which, p.val);
    end

    function setLbl(lbl, which, v)
        t = currentTech();
        if which == 1, p = t.p1; else, p = t.p2; end
        if ~isempty(p), lbl.Text = sprintf('%s: %.3g', p.label, v); end
    end

    function t = currentTech()
        idx = find(strcmp({T.module}, ddModule.Value) & strcmp({T.name}, ddTech.Value), 1);
        t = T(idx);
    end

    function onLoad(~, ~)
        [f, p] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', 'Images'});
        if isequal(f, 0), return; end
        try
            I = imread(fullfile(p, f));
            if size(I,3) == 4, I = I(:,:,1:3); end
            img = I;  seed = [];  res = [];
            showOrig();  cla(axRes);  title(axRes, 'Result');
            lblStatus.Text = ['Loaded: ' f];  lblStatus.FontColor = [0 0 0];
        catch ME
            uialert(fig, ME.message, 'Could not read image');
        end
    end

    function showOrig()
        h = imshow(img, 'Parent', axOrig);
        h.ButtonDownFcn = @onClickOrig;            % click = choose seed for region growing
        title(axOrig, 'Original');
    end

    function onClickOrig(~, e)
        pt = e.IntersectionPoint;
        seed = [round(pt(2)) round(pt(1))];
        lblStatus.Text = sprintf('Seed set at row %d, col %d', seed(1), seed(2));
        lblStatus.FontColor = [0 0 0];
    end

    function onApply(~, ~)
        if isempty(img), uialert(fig, 'Please load an image first.', 'No image'); return; end
        t = currentTech();
        lblStatus.Text = '';  lblStatus.FontColor = [0 0 0];
        try
            out = t.fn(img, sl1.Value, sl2.Value);
            res = out;
            imshow(out, 'Parent', axRes);
            title(axRes, t.name, 'Interpreter', 'none');
        catch ME
            uialert(fig, ME.message, 'Processing error');
        end
    end

    function onSave(~, ~)
        if isempty(res), uialert(fig, 'Nothing to save yet.', 'No result'); return; end
        [f, p] = uiputfile({'*.png'; '*.jpg'}, 'Save result', 'result.png');
        if isequal(f, 0), return; end
        imwrite(res, fullfile(p, f));
    end

% ----- special handlers -----
    function out = cmpEdges(I, a, ~)
        compareEdges(I, a);
        out = edgeDetect(I, 'canny', max(a, 0.2));
    end

    function out = fwdRotate(I, a, ~)
        [h, w, ~] = size(I);
        cx = (w+1)/2;  cy = (h+1)/2;
        M = tformMatrix('translate', cx, cy) * tformMatrix('rotate', a) * tformMatrix('translate', -cx, -cy);
        out = warpForward(I, M);
    end

    function out = runFace(I, thr, ~)
        out = showDrowsy(drowsyPipeline(I, 'face', thr));
    end

    function out = runEye(I, thr, ~)
        out = showDrowsy(drowsyPipeline(I, 'eye', thr));
    end

    function out = showDrowsy(R)
        out = R.overlay;
        lblStatus.Text = sprintf('%s\nOpenness score = %.2f (threshold %.2f)', R.label, R.score, R.thr);
        if strcmp(R.label, 'DROWSY'), lblStatus.FontColor = [0.8 0 0]; else, lblStatus.FontColor = [0 0.5 0]; end
    end
end
