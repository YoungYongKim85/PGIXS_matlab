function [cmin, cmax] = computePGIXSDisplayLimits(data)
% computePGIXSDisplayLimits  Robust default display limits for PGIXS images.

    positiveData = data(data > 0);
    cmin = min(positiveData, [], 'omitnan');
    cmax = max(data(:), [], 'omitnan');

    if isempty(cmin) || isnan(cmin)
        cmin = 0;
    end
    if isempty(cmax) || isnan(cmax) || cmax <= cmin
        cmax = cmin + 1;
    end

    cmin = double(cmin);
    cmax = double(cmax);
end
