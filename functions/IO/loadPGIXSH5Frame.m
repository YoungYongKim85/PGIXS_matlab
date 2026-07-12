function data = loadPGIXSH5Frame(filePath, mask, saturatedValue)
% loadPGIXSH5Frame  Load one PGIXS H5 detector frame with optional masking.

    if nargin < 2
        mask = [];
    end
    if nargin < 3
        saturatedValue = NaN;
    end

    rawData = h5read(filePath, '/entry/data/data');
    data = single(rawData');

    if ~isempty(mask)
        data = data .* single(mask);
    end

    data(data > 1e9) = single(saturatedValue);
end
