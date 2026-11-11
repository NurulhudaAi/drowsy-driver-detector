function saveFigures(prefix, closeAfter)
% SAVEFIGURES  Save every open figure window as a PNG in the report/ folder.
%   saveFigures('m1')        -> report/m1_01_<figure name>.png, m1_02_..., ...
%   saveFigures('m2', true)  -> same, then closes the figures
%   Run it right after a demo, e.g.  run demos/demo_module1.m; saveFigures('m1', true)
if nargin < 1 || isempty(prefix), prefix = 'fig'; end
if nargin < 2, closeAfter = false; end
root = fileparts(fileparts(mfilename('fullpath')));
outDir = fullfile(root, 'report');
if ~exist(outDir, 'dir'), mkdir(outDir); end
figs = findobj('Type', 'figure');
if isempty(figs), fprintf('No open figures to save.\n'); return; end
[~, order] = sort([figs.Number]);          % save in the order they were opened
figs = figs(order);
for i = 1:numel(figs)
    f = figs(i);
    name = f.Name;
    if isempty(name), name = sprintf('figure%d', f.Number); end
    name = regexprep(lower(strtrim(name)), '[^a-z0-9]+', '_');
    file = fullfile(outDir, sprintf('%s_%02d_%s.png', prefix, i, name));
    if exist('exportgraphics', 'file')     % R2020a and newer
        exportgraphics(f, file, 'Resolution', 200);
    else
        saveas(f, file);
    end
    fprintf('Saved %s\n', file);
end
if closeAfter, close(figs); end
end
