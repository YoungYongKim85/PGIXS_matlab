function result = loadPGIXSMultishotAverage(basePath, baseName, fileFormat, mask, progressFcn)
% loadPGIXSMultishotAverage  Load, mask, and average a PGIXS image series.

    if nargin < 5
        progressFcn = [];
    end

    prefix = normalizePGIXSSeriesPrefix(baseName);
    [~, files, nFiles] = listPGIXSSeriesFiles(basePath, prefix, fileFormat);
    if nFiles == 0
        error('PGIXS:NoSeriesFiles', ...
            'No files found for prefix "%s" and format "%s".', prefix, fileFormat);
    end

    runningSum = [];
    loginfo = nan(2, nFiles, 'single');
    dataSize = [];

    for ii = 1:nFiles
        if ~isempty(progressFcn)
            progressFcn(ii, nFiles);
        end

        [data, counts] = loadPGIXSImageFile(files{ii}, fileFormat);
        if ii == 1
            dataSize = single(size(data));
            assertMaskCompatible(data, mask);
            runningSum = zeros(size(data), 'single');
        end

        data = applyPGIXSMask(data, mask);
        runningSum = runningSum + data;

        if ~isempty(counts)
            nCounts = min(numel(counts), 2);
            loginfo(1:nCounts, ii) = single(counts(1:nCounts));
        end
    end

    result = struct();
    result.Prefix = prefix;
    result.Files = files;
    result.N = nFiles;
    result.Data = runningSum ./ nFiles;
    result.DataSize = dataSize;
    result.LogInfo = loginfo;

    if all(isnan(loginfo(:)))
        result.Count = [];
    else
        result.Count = single(mean(loginfo, 2, 'omitnan')');
    end
end

function assertMaskCompatible(data, mask)
    if isempty(mask)
        return;
    end
    if size(data, 1) ~= size(mask, 1) || size(data, 2) ~= size(mask, 2)
        error('PGIXS:MaskSizeMismatch', ...
            'Data size [%d %d] does not match mask size [%d %d].', ...
            size(data, 1), size(data, 2), size(mask, 1), size(mask, 2));
    end
end
