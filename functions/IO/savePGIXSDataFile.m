function savePGIXSDataFile(savePath, saveForm, matrixData, matData)
% savePGIXSDataFile  Save PGIXS numeric results as MAT/text/CSV.
%
% For MAT files, matData is saved as a struct. For text-like and CSV files,
% matrixData is written as numeric tabular data.

    if nargin < 4 || isempty(matData)
        matData = struct();
    end

    switch lower(saveForm)
        case '.mat'
            if isempty(fieldnames(matData))
                matData = struct('Matrix', matrixData);
            end
            save(savePath, '-struct', 'matData');
        case {'.dat', '.txt', '.sdt'}
            writematrix(matrixData, savePath, 'Delimiter', 'tab', 'FileType', 'text');
            writeFrameFailureSidecars(savePath, matData);
        case '.csv'
            writematrix(matrixData, savePath);
            writeFrameFailureSidecars(savePath, matData);
        otherwise
            error('PGIXS:UnsupportedSaveFormat', 'Unsupported save format: %s', saveForm);
    end
end

function writeFrameFailureSidecars(savePath, matData)
    writeFrameIndexSidecar(savePath, matData, 'RetryFailedFrames', 'retry_failed_frames');
    writeFrameIndexSidecar(savePath, matData, 'MetadataFailedFrames', 'metadata_failed_frames');
end

function writeFrameIndexSidecar(savePath, matData, fieldName, suffix)
    if nargin < 4 || isempty(matData) || ~isstruct(matData) || ~isfield(matData, fieldName)
        return;
    end
    frames = matData.(fieldName)(:);
    if isempty(frames)
        return;
    end

    [folderPath, baseName] = fileparts(savePath);
    sidecarPath = fullfile(folderPath, [baseName, '_', suffix, '.csv']);
    writematrix(double(frames), sidecarPath);
end
