function [data, counts, meta] = loadPGIXSImageFile(filePath, fileFormat)
% loadPGIXSImageFile  Load one PGIXS detector image and optional counters.

    if nargin < 2 || isempty(fileFormat)
        [~, ~, fileFormat] = fileparts(filePath);
    end
    fileFormat = lower(char(fileFormat));

    counts = [];
    meta = struct();
    meta.FilePath = filePath;
    meta.FileFormat = fileFormat;

    switch fileFormat
        case '.spe'
            data = single(speopen(filePath));
        case '.mat'
            [data, meta] = loadMatImage(filePath, meta);
        case {'.txt', '.dat', '.csv'}
            data = loadNumericTextImage(filePath, fileFormat);
        case {'.tif', '.tiff'}
            data = single(imread(filePath));
        case '.h5'
            [data, counts, meta] = loadH5Image(filePath, meta);
        otherwise
            data = single(imread(filePath));
    end

    meta.DataSize = size(data);
end

function data = loadNumericTextImage(filePath, fileFormat)
    switch fileFormat
        case '.csv'
            numericData = readmatrix(filePath);
        otherwise
            numericData = readmatrix(filePath, 'FileType', 'text');
    end
    if isempty(numericData) || ~isnumeric(numericData)
        error('PGIXS:NoNumericTextData', 'No numeric matrix found in text file: %s', filePath);
    end
    data = single(numericData);
end

function [data, meta] = loadMatImage(filePath, meta)
    info = whos('-file', filePath);
    if isempty(info)
        error('PGIXS:EmptyMatFile', 'No variables found in MAT file: %s', filePath);
    end

    selected = selectMatImageVariable(info, filePath);
    s = load(filePath, selected.name);
    meta.MatVariableName = selected.name;
    meta.MatVariableSize = selected.size;
    meta.MatVariableClass = selected.class;
    data = single(s.(selected.name));
end

function selected = selectMatImageVariable(info, filePath)
    candidates = info(arrayfun(@isImageCandidate, info));
    if isempty(candidates)
        error('PGIXS:NoMatImageVariable', ...
            'No numeric 2D image-like variables found in MAT file: %s', filePath);
    end

    priorityNames = {'data', 'image', 'img', 'frame', 'I'};
    scores = zeros(numel(candidates), 1);
    for ii = 1:numel(candidates)
        scores(ii) = prod(double(candidates(ii).size));
        if any(strcmpi(candidates(ii).name, priorityNames))
            scores(ii) = scores(ii) + 1e12;
        end
    end
    [~, idx] = max(scores);
    selected = candidates(idx);
end

function tf = isImageCandidate(varInfo)
    tf = any(strcmp(varInfo.class, {'double', 'single', 'uint8', 'uint16', ...
        'uint32', 'uint64', 'int8', 'int16', 'int32', 'int64', 'logical'})) && ...
        numel(varInfo.size) >= 2 && all(varInfo.size(1:2) > 1);
end

function [data, counts, meta] = loadH5Image(filePath, meta)
    data = loadPGIXSH5Frame(filePath);

    h5Meta = readPGIXSH5Metadata(filePath);
    counts = single([h5Meta.Counter1, h5Meta.CounterBC]);
    meta.Timestamp = h5Meta.Timestamp;
    if isfield(h5Meta, 'BCCounter')
        meta.BCCounter = h5Meta.BCCounter;
    else
        meta.BCCounter = '';
    end
end
