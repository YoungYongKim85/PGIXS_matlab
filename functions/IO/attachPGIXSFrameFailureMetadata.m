function target = attachPGIXSFrameFailureMetadata(target, source)
% attachPGIXSFrameFailureMetadata  Copy frame-failure metadata fields.

    if nargin < 2
        error('PGIXS:MissingMetadataSource', 'A source struct is required.');
    end
    if ~isstruct(target) || ~isstruct(source)
        error('PGIXS:InvalidMetadataStruct', 'Target and source must be structs.');
    end

    fields = {'RetryFailedFrames', 'MetadataFailedFrames'};
    for ii = 1:numel(fields)
        fieldName = fields{ii};
        if isfield(source, fieldName)
            target.(fieldName) = source.(fieldName);
        end
    end
end
