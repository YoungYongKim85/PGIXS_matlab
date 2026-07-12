function [cmap, report] = resolvePGIXSColormap(colormapName, data, nColors)
% resolvePGIXSColormap  Resolve PGIXS colormap names with a safe fallback.

    if nargin < 2
        data = [];
    end
    if nargin < 3 || isempty(nColors)
        nColors = 256;
    end

    report = struct('Requested', string(colormapName), 'FallbackUsed', false, 'Message', '');

    try
        switch char(colormapName)
            case 'rwb'
                cmap = balancecol(data);
            case 'rkb'
                cmap = redbkblue(data);
            case 'inferno'
                cmap = inferno(nColors);
            case 'viridis'
                cmap = viridis(nColors);
            case 'cubehelix'
                cmap = cubehelix(nColors);
            case 'ocean'
                cmap = ocean(nColors);
            case 'kindlemann'
                cmap = kindlemann(nColors);
            case 'magma'
                cmap = MagmaM(nColors);
            case 'jet2'
                cmap = Jet2(nColors);
            otherwise
                cmap = colormapName;
        end
    catch ME
        report.FallbackUsed = true;
        report.Message = ME.message;
        cmap = 'jet';
    end
end
