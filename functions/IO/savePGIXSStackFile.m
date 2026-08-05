function useV73 = savePGIXSStackFile(filePath, info)
% savePGIXSStackFile  Save PGIXS stack info, using v7.3 for large stacks.

    if ~isfield(info, 'Stack') || isempty(info.Stack)
        error('PGIXS:MissingStack', 'Stack data is required.');
    end

    stackBytes = numel(info.Stack) * bytesPerElement(info.Stack);
    useV73 = stackBytes > 2e9;
    if useV73
        save(filePath, '-struct', 'info', '-v7.3');
    else
        save(filePath, '-struct', 'info');
    end
end

function nBytes = bytesPerElement(data)
    switch class(data)
        case {'single', 'int32', 'uint32'}
            nBytes = 4;
        case {'double', 'int64', 'uint64'}
            nBytes = 8;
        case {'int16', 'uint16'}
            nBytes = 2;
        case {'int8', 'uint8', 'logical'}
            nBytes = 1;
        otherwise
            nBytes = 8;
    end
end
