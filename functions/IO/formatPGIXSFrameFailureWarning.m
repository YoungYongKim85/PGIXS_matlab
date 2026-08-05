function [message, titleText] = formatPGIXSFrameFailureWarning(count, frames, failureType, contextName)
% formatPGIXSFrameFailureWarning  Build compact UI text for frame failures.

    if nargin < 4 || isempty(contextName)
        contextName = 'load';
    end
    failureType = lower(char(failureType));
    contextName = lower(char(contextName));
    frameList = formatPGIXSFrameIndexList(frames);

    switch failureType
        case 'load'
            if strcmp(contextName, 'refresh')
                message = sprintf(['%d refreshed frame(s) failed after retry and were stored as NaN.\n', ...
                    'Retry-failed frames so far: %s'], count, frameList);
                titleText = 'Auto Refresh Warning';
            else
                message = sprintf('%d frame(s) failed after retry and were stored as NaN.\nFrames: %s', ...
                    count, frameList);
                titleText = 'Load Warning';
            end
        case 'metadata'
            if strcmp(contextName, 'refresh')
                message = sprintf(['%d refreshed frame(s) had metadata read failures.\n', ...
                    'Metadata-failed frames so far: %s'], count, frameList);
                titleText = 'Auto Refresh Metadata Warning';
            else
                message = sprintf('%d frame(s) had metadata read failures.\nFrames: %s', ...
                    count, frameList);
                titleText = 'Metadata Warning';
            end
        otherwise
            error('PGIXS:InvalidFrameFailureType', 'Unsupported frame-failure type: %s', failureType);
    end
end
