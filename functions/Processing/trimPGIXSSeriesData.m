function [stackData, logInfo, timestampInfo, temperatureInfo] = trimPGIXSSeriesData(stackData, logInfo, timestampInfo, temperatureInfo, nFrames)
% trimPGIXSSeriesData  Trim series arrays to the number of loaded frames.

    nFrames = max(0, min(nFrames, size(stackData, 3)));
    stackData = stackData(:, :, 1:nFrames);

    if ~isempty(logInfo)
        logInfo = logInfo(:, 1:min(nFrames, size(logInfo, 2)));
    end
    if ~isempty(timestampInfo)
        timestampInfo = timestampInfo(1:min(nFrames, numel(timestampInfo)));
    end
    if ~isempty(temperatureInfo)
        temperatureInfo = temperatureInfo(1:min(nFrames, size(temperatureInfo, 1)), :);
    end
end
