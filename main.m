% MAIN  Launch the Smart Image Processing Toolbox (Drowsy Driver Detection).
%   Run this file from MATLAB. Requires the Image Processing Toolbox.
rootDir = fileparts(mfilename('fullpath'));
addpath(genpath(rootDir));      % make every module visible (no hardcoded paths)
DrowsyToolbox;                  % open the GUI
