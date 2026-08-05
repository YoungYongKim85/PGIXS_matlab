function [names, files, nFiles] = listPGIXSSeriesFiles(basePath, baseName, fileFormat)
% listPGIXSSeriesFiles  List PGIXS series files with normalized prefix.

    if nargin < 3 || isempty(fileFormat)
        [~, ~, fileFormat] = fileparts(baseName);
    end
    if isempty(fileFormat)
        fileFormat = '.h5';
    end
    if ~startsWith(fileFormat, '.')
        fileFormat = ['.', fileFormat];
    end

    prefix = normalizePGIXSSeriesPrefix(baseName);
    listing = dir(basePath);
    listing = listing(~[listing.isdir]);

    allNames = {listing.name};
    if isempty(allNames)
        names = {};
        files = {};
        nFiles = 0;
        return;
    end

    hasPrefix = contains(allNames, prefix);
    hasExtension = false(size(allNames));
    for ii = 1:numel(allNames)
        [~, ~, ext] = fileparts(allNames{ii});
        hasExtension(ii) = strcmpi(ext, fileFormat);
    end

    names = allNames(hasPrefix & hasExtension);
    names = sort(names);
    files = fullfile(basePath, names);
    nFiles = numel(names);
end
