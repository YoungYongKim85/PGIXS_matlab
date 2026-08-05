function report = applyPGIXSColormap(ax, colormapName, data, fallbackName)
% applyPGIXSColormap  Apply a PGIXS colormap with a diagnostic fallback.

    if nargin < 4 || isempty(fallbackName)
        fallbackName = 'jet';
    end

    report = struct('FallbackUsed', false, 'Message', '');
    try
        switch colormapName
            case 'rwb'
                colormap(ax, balancecol(data));
            case 'rkb'
                colormap(ax, redbkblue(data));
            case 'inferno'
                colormap(ax, inferno(256));
            case 'viridis'
                colormap(ax, viridis(256));
            case 'cubehelix'
                colormap(ax, cubehelix(256));
            case 'ocean'
                colormap(ax, ocean(256));
            case 'kindlemann'
                colormap(ax, kindlemann(256));
            case 'magma'
                colormap(ax, MagmaM(256));
            case 'jet2'
                colormap(ax, Jet2(256));
            otherwise
                colormap(ax, colormapName);
        end
    catch ME
        report.FallbackUsed = true;
        report.Message = ME.message;
        try
            colormap(ax, fallbackName);
        catch fallbackME
            report.Message = [ME.message, ' | fallback failed: ', fallbackME.message];
        end
        warning('PGIXS:ColormapFallback', '%s', ['Colormap fallback used: ', report.Message]);
    end
end
