function [ok, report] = exportPGIXSAxesImage(ax, filePath, resolution)
% exportPGIXSAxesImage  Export an axes image without interrupting data save.

    if nargin < 3 || isempty(resolution)
        resolution = 300;
    end

    report = struct('Path', filePath, 'Message', '');
    try
        exportgraphics(ax, filePath, 'Resolution', resolution);
        ok = true;
    catch ME
        ok = false;
        report.Message = ME.message;
        warning('PGIXS:FigureExportFailed', '%s', ...
            ['Figure export failed: ', ME.message]);
    end
end
