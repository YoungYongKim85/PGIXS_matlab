function [xAxis, sortIndex] = sortPGIXSXAxis(xAxis, expMode, sortTemperature, sortAngle)
% sortPGIXSXAxis  Sort experiment X-axis when the selected mode requests it.

    sortIndex = 1:numel(xAxis);
    if nargin < 3 || isempty(sortTemperature)
        sortTemperature = false;
    end
    if nargin < 4 || isempty(sortAngle)
        sortAngle = false;
    end
    if nargin < 2 || isempty(expMode)
        return;
    end

    shouldSort = ((strcmp(expMode, 'Temperature') || strcmp(expMode, 'LowTemp.')) && sortTemperature) ...
        || (strcmp(expMode, 'Angle') && sortAngle);
    if shouldSort
        [xAxis, sortIndex] = sort(xAxis);
    end
end
