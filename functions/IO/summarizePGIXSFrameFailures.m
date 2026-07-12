function summary = summarizePGIXSFrameFailures(loadFailed, metadataFailed, nFrames)
% summarizePGIXSFrameFailures  Summarize frame load and metadata failures.

    if nargin < 3 || isempty(nFrames)
        nFrames = min(numel(loadFailed), numel(metadataFailed));
    end
    nFrames = floor(double(nFrames));
    if ~isfinite(nFrames) || nFrames < 0
        nFrames = 0;
    end
    nFrames = min([nFrames, numel(loadFailed), numel(metadataFailed)]);

    loadSlice = loadFailed(1:nFrames);
    metadataSlice = metadataFailed(1:nFrames);

    summary = struct();
    summary.RetryFailedFrames = find(loadSlice);
    summary.MetadataFailedFrames = find(metadataSlice);
    summary.RetryFailedCount = sum(loadSlice);
    summary.MetadataFailedCount = sum(metadataSlice);
end
