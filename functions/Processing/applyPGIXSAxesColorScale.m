function report = applyPGIXSAxesColorScale(ax, colorScale, fallbackScale)
% applyPGIXSAxesColorScale  Apply axes color scale with a safe fallback.

    if nargin < 3 || isempty(fallbackScale)
        fallbackScale = 'linear';
    end

    report = struct('FallbackUsed', false, 'Message', '');
    requestedScale = normalizeScaleName(colorScale, fallbackScale);

    try
        set(ax, 'ColorScale', requestedScale);
    catch ME
        report.FallbackUsed = true;
        report.Message = ME.message;
        try
            set(ax, 'ColorScale', fallbackScale);
        catch fallbackME
            report.Message = [ME.message, ' | fallback failed: ', fallbackME.message];
        end
        warning('PGIXS:ColorScaleFallback', '%s', ['Color scale fallback used: ', report.Message]);
    end
end

function scaleName = normalizeScaleName(colorScale, fallbackScale)
    if isstring(colorScale)
        colorScale = char(colorScale);
    end
    if ~ischar(colorScale) || isempty(colorScale)
        scaleName = fallbackScale;
        return;
    end

    switch lower(colorScale)
        case 'log'
            scaleName = 'log';
        case 'linear'
            scaleName = 'linear';
        otherwise
            scaleName = lower(colorScale);
    end
end
