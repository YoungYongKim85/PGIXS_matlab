function [xAxis, label, unit] = computePGIXSExperimentXAxis(param, mode)
% computePGIXSExperimentXAxis  Build experiment X-axis for PGIXS series plots.

    if nargin < 2 || isempty(mode)
        mode = 'TrXS';
    end

    switch lower(char(mode))
        case 'trxs'
            [xAxis, label, unit] = computeTrXSXAxis(param);
        case 'gixs'
            [xAxis, label, unit] = computeGIXSXAxis(param);
        otherwise
            error('PGIXS:UnsupportedXAxisMode', 'Unsupported X-axis mode: %s', mode);
    end
end

function [xAxis, label, unit] = computeGIXSXAxis(param)
    label = 'Frame';
    unit = '#';
    nFrames = inferGIXSLength(param);
    xAxis = 1:nFrames;
    if ~isfield(param, 'expmode')
        return;
    end

    [timeUnit, timeDivisor] = parseTimeUnit(param);
    timeOffsetSeconds = 0;
    if isfield(param, 'ExpTime')
        timeOffsetSeconds = double(param.ExpTime);
    end

    switch param.expmode
        case 'Time'
            [xAxis, label, unit] = computeGIXSTimeAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, xAxis);
        case 'Temperature'
            [xAxis, label, unit] = computeGIXSTemperatureAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, xAxis);
        case 'LowTemp.'
            [xAxis, label, unit] = computeGIXSLowTemperatureAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, xAxis);
        case 'Angle'
            [xAxis, label, unit] = computeGIXSAngleAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, xAxis);
    end

    if iscolumn(xAxis)
        xAxis = xAxis';
    end
end

function [xAxis, label, unit] = computeTrXSXAxis(param)
    label = 'Frame';
    unit = '#';
    nFrames = inferSeriesLength(param);
    xAxis = 1:nFrames;
    if ~isfield(param, 'expmode')
        return;
    end

    [timeUnit, timeDivisor] = parseTimeUnit(param);
    timeOffset = 1;
    if isfield(param, 'TimeOffset')
        timeOffset = double(param.TimeOffset);
    end

    switch param.expmode
        case 'Time'
            [xAxis, label, unit] = computeTrXSTimeAxis(param, nFrames, timeDivisor, timeUnit, timeOffset);
        case 'Temperature'
            currentMode = 'Temperature1';
            if isfield(param, 'Tmode')
                currentMode = param.Tmode;
            end
            if isfield(param, 'temperatureinfo')
                switch currentMode
                    case 'Temperature1'
                        xAxis = param.temperatureinfo(:, 1);
                        label = 'Temperature';
                        unit = '^\circC';
                    case 'Temperature2'
                        xAxis = param.temperatureinfo(:, 2);
                        label = 'Temperature 2';
                        unit = '^\circC';
                    case 'Time'
                        [xAxis, label, unit] = computeTrXSTimeAxis(param, nFrames, timeDivisor, timeUnit, timeOffset);
                end
            end
    end

    if iscolumn(xAxis)
        xAxis = xAxis';
    end
end

function nFrames = inferSeriesLength(param)
    if isfield(param, 'data1dstackN') && ~isempty(param.data1dstackN)
        nFrames = size(param.data1dstackN, 2);
    elseif isfield(param, 'dataAzistackN') && ~isempty(param.dataAzistackN)
        nFrames = size(param.dataAzistackN, 2);
    elseif isfield(param, 'SumIROIN') && ~isempty(param.SumIROIN)
        nFrames = size(param.SumIROIN, 1);
    elseif isfield(param, 'Stack')
        nFrames = size(param.Stack, 3);
    else
        nFrames = 0;
    end
end

function nFrames = inferGIXSLength(param)
    if isfield(param, 'data1dstackN')
        nFrames = size(param.data1dstackN, 2);
    elseif isfield(param, 'dataAzistackN')
        nFrames = size(param.dataAzistackN, 2);
    elseif isfield(param, 'SumIROI')
        nFrames = size(param.SumIROI, 1);
    elseif isfield(param, 'Stack')
        nFrames = size(param.Stack, 3);
    else
        nFrames = 1;
    end
end

function [timeUnit, timeDivisor] = parseTimeUnit(param)
    timeUnit = 's';
    timeDivisor = 1;
    if ~isfield(param, 'TimeUnit')
        return;
    end
    switch param.TimeUnit
        case 'min'
            timeUnit = 'min';
            timeDivisor = 60;
        case 'hour'
            timeUnit = 'h';
            timeDivisor = 3600;
    end
end

function [xAxis, label, unit] = computeTrXSTimeAxis(param, nFrames, timeDivisor, timeUnit, timeOffset)
    label = 'Time';
    unit = timeUnit;
    if isfield(param, 'timestampinfo') && ~all(isnan(param.timestampinfo))
        timestamps = param.timestampinfo;
        xAxis = ((timestamps - timestamps(1)) / timeDivisor) + timeOffset;
    else
        xAxis = (0:nFrames - 1) * timeOffset + timeOffset;
    end
end

function [xAxis, label, unit] = computeGIXSTimeAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, defaultAxis)
    xAxis = defaultAxis;
    label = 'Frame';
    unit = '#';
    if isfield(param, 'timestampinfo') && numel(param.timestampinfo) == nFrames && ~all(isnan(param.timestampinfo))
        timestamps = double(param.timestampinfo(:));
        xAxis = ((timestamps - timestamps(1)) + timeOffsetSeconds) / timeDivisor;
        label = 'Time';
        unit = timeUnit;
    elseif timeOffsetSeconds > 0
        xAxis = ((0:nFrames - 1) * timeOffsetSeconds + timeOffsetSeconds) / timeDivisor;
        label = 'Time';
        unit = timeUnit;
    end
end

function [xAxis, label, unit] = computeGIXSTemperatureAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, defaultAxis)
    xAxis = defaultAxis;
    label = 'Frame';
    unit = '#';
    temperatureMode = '';
    if isfield(param, 'Tmode')
        temperatureMode = param.Tmode;
    end
    switch temperatureMode
        case 'Temperature2'
            if hasTemperatureColumn(param, nFrames, 2)
                xAxis = param.temperatureinfo(:, 2);
                label = 'Temperature 2';
                unit = '^\circC';
            end
        case 'Temperature3'
            if hasTemperatureColumn(param, nFrames, 3)
                xAxis = param.temperatureinfo(:, 3);
                label = 'Temperature 3';
                unit = '^\circC';
            end
        case 'Time'
            [xAxis, label, unit] = computeGIXSTimeAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, defaultAxis);
        otherwise
            if hasTemperatureColumn(param, nFrames, 1)
                xAxis = param.temperatureinfo(:, 1);
                label = 'Temperature';
                unit = '^\circC';
            end
    end
end

function [xAxis, label, unit] = computeGIXSLowTemperatureAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, defaultAxis)
    xAxis = defaultAxis;
    label = 'Frame';
    unit = '#';
    temperatureMode = '';
    if isfield(param, 'Tmode')
        temperatureMode = param.Tmode;
    end
    switch temperatureMode
        case 'LowTemp2'
            if hasTemperatureColumn(param, nFrames, 2)
                xAxis = param.temperatureinfo(:, 2);
                label = 'Low Temperature 2';
                unit = '^\circC';
            end
        case 'Time'
            [xAxis, label, unit] = computeGIXSTimeAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, defaultAxis);
        otherwise
            if hasTemperatureColumn(param, nFrames, 1)
                xAxis = param.temperatureinfo(:, 1);
                label = 'Low Temperature';
                unit = '^\circC';
            end
    end
end

function [xAxis, label, unit] = computeGIXSAngleAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, defaultAxis)
    xAxis = defaultAxis;
    label = 'Frame';
    unit = '#';
    angleMode = '';
    if isfield(param, 'Amode')
        angleMode = param.Amode;
    end
    switch angleMode
        case 'Time'
            [xAxis, label, unit] = computeGIXSTimeAxis(param, nFrames, timeOffsetSeconds, timeDivisor, timeUnit, defaultAxis);
        otherwise
            if isfield(param, 'aivar') && numel(param.aivar) == nFrames
                xAxis = param.aivar;
                label = 'Incidence Angle';
                unit = 'deg';
            end
    end
end

function tf = hasTemperatureColumn(param, nFrames, columnIndex)
    tf = isfield(param, 'temperatureinfo') ...
        && size(param.temperatureinfo, 1) == nFrames ...
        && size(param.temperatureinfo, 2) >= columnIndex;
end
