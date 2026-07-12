function [edgeColor, markerShape, markerFaceColor, report] = resolvePGIXSMarkerStyle(colorName, shapeName, emptyMode, fallbackStyle)
% resolvePGIXSMarkerStyle  Resolve marker style with a safe fallback.

    if nargin < 4 || isempty(fallbackStyle)
        fallbackStyle = {'k', 'o', 'none'};
    end

    report = struct('FallbackUsed', false, 'Message', '');
    try
        [edgeColor, markerShape, markerFaceColor] = ColorSelector(colorName, shapeName, emptyMode);
    catch ME
        edgeColor = fallbackStyle{1};
        markerShape = fallbackStyle{2};
        markerFaceColor = fallbackStyle{3};
        report.FallbackUsed = true;
        report.Message = ME.message;
        warning('PGIXS:MarkerStyleFallback', '%s', ...
            ['Marker style fallback used: ', ME.message]);
    end
end
