function [data, ok, report] = loadPGIXSH5FrameWithRetry(filePath, mask, saturatedValue, fallbackSize, retryCount)
% loadPGIXSH5FrameWithRetry  Load one H5 frame, retry once, then return NaNs.

    if nargin < 2
        mask = [];
    end
    if nargin < 3 || isempty(saturatedValue)
        saturatedValue = NaN;
    end
    if nargin < 4
        fallbackSize = [];
    end
    if nargin < 5 || isempty(retryCount)
        retryCount = 1;
    end

    if isempty(fallbackSize) && ~isempty(mask)
        fallbackSize = size(mask);
    end

    ok = false;
    report = struct('OK', false, 'Attempts', 0, 'FirstMessage', '', 'Message', '');

    for attempt = 1:(retryCount + 1)
        report.Attempts = attempt;
        try
            data = loadPGIXSH5Frame(filePath, mask, saturatedValue);
            ok = true;
            report.OK = true;
            return;
        catch ME
            if attempt == 1
                report.FirstMessage = ME.message;
            end
            report.Message = ME.message;
            if attempt <= retryCount
                pause(0.05);
            end
        end
    end

    if isempty(fallbackSize)
        error('PGIXS:H5RetryFailed', 'H5 frame load failed after %d attempts: %s', report.Attempts, report.Message);
    end

    data = single(nan(fallbackSize));
end
