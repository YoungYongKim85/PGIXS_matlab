function [logCounts, timestampValue, temperatureValues, report] = readPGIXSH5FrameMetadataRow(filePath, mode, referenceCounts, referenceTimestamp, temperatureWidth)
% readPGIXSH5FrameMetadataRow  Read one frame's normalized counters and scan metadata.

    if nargin < 2
        mode = '';
    end
    if nargin < 3 || isempty(referenceCounts)
        referenceCounts = [NaN NaN];
    end
    if nargin < 4
        referenceTimestamp = NaN;
    end
    if nargin < 5 || isempty(temperatureWidth)
        temperatureWidth = 3;
    end

    report = struct('OK', false, 'Message', '', 'RawCounts', single([NaN NaN]));
    logCounts = single([NaN NaN]);
    timestampValue = NaN;
    temperatureValues = single(nan(1, temperatureWidth));

    try
        meta = readPGIXSH5Metadata(filePath, mode, referenceTimestamp);
        rawCounts = single([meta.Counter1, meta.CounterBC]);
        logCounts = normalizePGIXSCounters(rawCounts, referenceCounts);
        timestampValue = meta.Timestamp;
        nCopy = min(temperatureWidth, numel(meta.Temperature));
        temperatureValues(1:nCopy) = meta.Temperature(1:nCopy);
        report.OK = true;
        report.RawCounts = rawCounts;
    catch ME
        report.Message = ME.message;
    end
end
