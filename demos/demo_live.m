function demo_live(source, thr, varargin)
% DEMO_LIVE  Run the drowsy-driver pipeline frame by frame on a webcam or a video file.
%   demo_live                      webcam, threshold 0.30
%   demo_live('webcam')            same
%   demo_live('clip.mp4')          video file (any format VideoReader supports)
%   demo_live(source, thr)         custom openness threshold
%   demo_live(..., 'Name', value)  options:
%       'ClosedSeconds' (1.0)  eyes must stay closed this long before the DROWSY alarm
%                              (normal blinks last 0.1-0.4 s and are ignored)
%       'Width'         (320)  frames are downscaled to this width for speed
%       'Mode'          ('face') 'face' or 'eye' (passed to drowsyPipeline)
%       'SaveAs'        ('')   e.g. 'report/live_demo.mp4' -> records the figure
%   Close the figure window to stop.
%
%   Webcam needs the free "MATLAB Support Package for USB Webcams"
%   (Home > Add-Ons > search "USB Webcams"). Video files need nothing extra.

addpath(genpath(fileparts(fileparts(mfilename('fullpath')))));
if nargin < 1 || isempty(source), source = 'webcam'; end
if nargin < 2 || isempty(thr),    thr = 0.30;        end
o = struct('ClosedSeconds', 1.0, 'Width', 320, 'Mode', 'face', 'SaveAs', '');
for i = 1:2:numel(varargin), o.(varargin{i}) = varargin{i+1}; end

% ---------------- open the source ----------------
isCam = strcmpi(source, 'webcam');
if isCam
    try
        cam = webcam();
    catch ME
        error(['Could not open the webcam (%s).\nInstall "MATLAB Support Package for ' ...
               'USB Webcams" from Add-Ons, or run demo_live(''yourvideo.mp4'').'], ME.message);
    end
    getFrame = @() snapshot(cam);
    hasMore  = @() true;
    t0 = tic;  getTime = @() toc(t0);         % wall-clock time
else
    if ~exist(source, 'file'), error('Video file not found: %s', source); end
    vr = VideoReader(source);
    getFrame = @() readFrame(vr);
    hasMore  = @() hasFrame(vr);
    getTime  = @() vr.CurrentTime;            % video time (works even if processing is slow)
end

% ---------------- figure ----------------
fig = figure('Name', 'Drowsy Driver Detection - live', 'NumberTitle', 'off', ...
             'Color', 'w', 'Position', [100 100 1000 560]);
axF = subplot(2, 2, [1 3]);  hF = imshow(zeros(240, 320, 3, 'uint8'), 'Parent', axF);  hold(axF, 'on');
hBox = rectangle(axF, 'Position', [1 1 1 1], 'EdgeColor', 'y', 'LineWidth', 2);
hTxt = title(axF, 'starting...', 'FontSize', 16);
axE = subplot(2, 2, 2);  hE = imshow(zeros(40, 128, 3, 'uint8'), 'Parent', axE);  title(axE, 'Eye region (dark blob in red)');
axS = subplot(2, 2, 4);  hold(axS, 'on');  grid(axS, 'on');
hS  = plot(axS, NaN, NaN, 'b-', 'LineWidth', 1.5);
hT  = plot(axS, [0 1], [thr thr], 'r--');
xlabel(axS, 'time (s)');  ylabel(axS, 'openness score');  ylim(axS, [0 1.2]);
legend(axS, {'score', 'threshold'}, 'Location', 'northwest');

if ~isempty(o.SaveAs)
    vw = VideoWriter(o.SaveAs, 'MPEG-4');  open(vw);
    cleanVw = onCleanup(@() close(vw));       %#ok<NASGU>
end

% ---------------- main loop ----------------
win = 15;                       % seconds of score history shown in the plot
ts = [];  sc = [];
closedSince = NaN;  alarm = false;  nFrames = 0;  tic0 = tic;
while ishandle(fig) && hasMore()
    frame = getFrame();
    if size(frame, 3) == 1, frame = repmat(frame, [1 1 3]); end
    s = o.Width / size(frame, 2);
    if s < 1, frame = scaleImg(frame, s, s, 'bilinear'); end   % Module 3 resize
    t = getTime();

    R = drowsyPipeline(frame, o.Mode, thr);
    if ~ishandle(fig), break; end                      % window closed while processing
    closedNow = strcmp(R.label, 'DROWSY');            % this frame: eye looks closed

    % temporal rule: only alarm if eyes stay closed longer than ClosedSeconds
    if closedNow
        if isnan(closedSince), closedSince = t; end
        newAlarm = (t - closedSince) >= o.ClosedSeconds;
    else
        closedSince = NaN;  newAlarm = false;
    end
    if newAlarm && ~alarm, beep; end
    alarm = newAlarm;

    % history for the plot
    ts(end+1) = t;  sc(end+1) = R.score;              %#ok<AGROW>
    keep = ts >= t - win;  ts = ts(keep);  sc = sc(keep);

    % ----- draw -----
    nFrames = nFrames + 1;
    fps = nFrames / toc(tic0);
    set(hF, 'CData', R.enhanced, 'XData', [1 size(frame,2)], 'YData', [1 size(frame,1)]);
    axis(axF, [0.5 size(frame,2)+0.5 0.5 size(frame,1)+0.5]);
    set(hBox, 'Position', R.box);
    set(hE, 'CData', R.overlay, 'XData', [1 size(R.overlay,2)], 'YData', [1 size(R.overlay,1)]);
    axis(axE, [0.5 size(R.overlay,2)+0.5 0.5 size(R.overlay,1)+0.5]);
    set(hS, 'XData', ts, 'YData', sc);
    set(hT, 'XData', [max(0, t-win) max(t, 1)]);
    xlim(axS, [max(0, t-win) max(t, 1)]);

    if alarm
        hTxt.String = sprintf('DROWSY!  eyes closed %.1f s', t - closedSince);
        hTxt.Color = [0.85 0 0];  hBox.EdgeColor = 'r';  fig.Color = [1 0.85 0.85];
    elseif closedNow
        hTxt.String = sprintf('eyes closed (%.1f s)   score %.2f', t - closedSince, R.score);
        hTxt.Color = [0.8 0.5 0];  hBox.EdgeColor = [1 0.6 0];  fig.Color = 'w';
    else
        hTxt.String = sprintf('ALERT   score %.2f   (%.1f fps)', R.score, fps);
        hTxt.Color = [0 0.5 0];  hBox.EdgeColor = 'g';  fig.Color = 'w';
    end
    drawnow limitrate;

    if ~isempty(o.SaveAs) && ishandle(fig)
        writeVideo(vw, getframe(fig));
    end
end
fprintf('Processed %d frames (%.1f fps average).\n', nFrames, nFrames / toc(tic0));
end
