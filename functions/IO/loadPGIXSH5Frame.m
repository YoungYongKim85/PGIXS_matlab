function data = loadPGIXSH5Frame(filePath, mask, saturatedValue)
% loadPGIXSH5Frame  Load one PGIXS H5 detector frame with optional masking.

    if nargin < 2
        mask = [];
    end
    if nargin < 3
        saturatedValue = NaN;
    end

    datasetPath = '/entry/data/data';
    info = h5info(filePath, datasetPath);
    dataSize = double(info.Dataspace.Size);
    if numel(dataSize) < 2
        error('PGIXS:InvalidH5FrameDataset', ...
            'H5 detector dataset must have at least two dimensions: %s', filePath);
    end

    start = ones(1, numel(dataSize));
    count = dataSize;
    if numel(dataSize) > 2
        count(3:end) = 1;
    end

    rawData = squeeze(h5read(filePath, datasetPath, start, count));
    if ~ismatrix(rawData)
        error('PGIXS:InvalidH5FrameShape', ...
            'Could not reduce H5 detector dataset to one 2D frame: %s', filePath);
    end
    data = single(rawData');

    if ~isempty(mask)
        data = data .* single(mask);
    end

    data(data > 1e9) = single(saturatedValue);
end
