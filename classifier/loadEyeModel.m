function model = loadEyeModel(cmd)
% LOADEYEMODEL  Load models/eyeModel.mat once and keep it in memory.
%   model = loadEyeModel            -> [] if the model has not been trained yet
%   loadEyeModel('reload')          -> forget the cached model (after training)
persistent M tried
if nargin >= 1 && strcmpi(cmd, 'reload'), M = []; tried = []; end
if isempty(tried)
    tried = true;
    f = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'models', 'eyeModel.mat');
    if exist(f, 'file')
        S = load(f, 'model');
        M = S.model;
    end
end
model = M;
end
