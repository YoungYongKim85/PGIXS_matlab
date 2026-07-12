function target = appendPGIXSFrameFailureIndex(target, fieldName, frameIndex)
% appendPGIXSFrameFailureIndex  Append failed frame indices to metadata.

    if nargin < 3
        error('PGIXS:MissingFrameFailureInput', 'Target, field name, and frame index are required.');
    end
    if ~isstruct(target)
        error('PGIXS:InvalidMetadataStruct', 'Target must be a struct.');
    end
    fieldName = char(fieldName);
    validFields = {'RetryFailedFrames', 'MetadataFailedFrames'};
    if ~any(strcmp(fieldName, validFields))
        error('PGIXS:InvalidFrameFailureField', 'Unsupported frame-failure field: %s', fieldName);
    end

    frameIndex = frameIndex(:);
    if isfield(target, fieldName) && ~isempty(target.(fieldName))
        frameIndex = [target.(fieldName)(:); frameIndex];
    end
    target.(fieldName) = unique(frameIndex);
end
