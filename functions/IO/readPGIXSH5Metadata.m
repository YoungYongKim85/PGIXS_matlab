function meta = readPGIXSH5Metadata(filePath, mode, referenceTimestamp)
% readPGIXSH5Metadata  Read counters, timestamp, and scan values from PGIXS H5.
%
% meta fields:
%   Counter1        Incident counter.
%   CounterBC       Beam-condition counter, Counter3 with Counter2 fallback.
%   Timestamp       Absolute timestamp, or relative to referenceTimestamp.
%   Temperature     1-by-3 single vector. Missing channels are NaN.

    if nargin < 2 || isempty(mode)
        mode = '';
    end
    if nargin < 3
        referenceTimestamp = NaN;
    end

    meta = struct();
    meta.Counter1 = readScalar(filePath, '/entry/instrument/user/params/Counter1', 'single');

    counter3 = readScalar(filePath, '/entry/instrument/user/params/Counter3', 'single');
    if isnan(counter3)
        meta.CounterBC = readScalar(filePath, '/entry/instrument/user/params/Counter2', 'single');
        meta.BCCounter = 'Counter2';
    else
        meta.CounterBC = counter3;
        meta.BCCounter = 'Counter3';
    end

    timestamp = readScalar(filePath, '/entry/instrument/user/params/TimeStamp', 'double');
    if ~isnan(timestamp) && ~isnan(referenceTimestamp)
        meta.Timestamp = timestamp - referenceTimestamp;
    else
        meta.Timestamp = timestamp;
    end

    meta.Temperature = single([NaN, NaN, NaN]);
    switch char(mode)
        case 'Temperature'
            meta.Temperature(1) = readFirstAvailable(filePath, {'Temp1', 'Temperature1'});
            meta.Temperature(2) = readFirstAvailable(filePath, {'Temp2', 'Temperature2'});
            meta.Temperature(3) = readFirstAvailable(filePath, {'Temp3', 'Temperature3'});
        case 'LowTemp.'
            meta.Temperature(1) = readFirstAvailable(filePath, {'LowTemp1'});
            meta.Temperature(2) = readFirstAvailable(filePath, {'LowTemp2'});
        case 'Angle'
            meta.Temperature(1) = readFirstAvailable(filePath, {'IncAngle'});
    end
end

function value = readFirstAvailable(filePath, names)
    value = single(NaN);
    basePath = '/entry/instrument/user/params/';
    for ii = 1:numel(names)
        value = readScalar(filePath, [basePath, names{ii}], 'single');
        if ~isnan(value)
            return;
        end
    end
end

function value = readScalar(filePath, datasetPath, precision)
    try
        raw = h5read(filePath, datasetPath);
        value = raw(1);
    catch
        value = NaN;
    end

    switch precision
        case 'single'
            value = single(value);
        otherwise
            value = double(value);
    end
end
