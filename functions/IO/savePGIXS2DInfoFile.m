function report = savePGIXS2DInfoFile(filePath, info)
% savePGIXS2DInfoFile  Save a Tab1 -> Tab3 2D info MAT file.

    if nargin < 2 || ~isstruct(info)
        error('PGIXS:Invalid2DInfo', '2D info must be provided as a struct.');
    end
    if nargin < 1 || isempty(filePath)
        error('PGIXS:InvalidFilePath', 'A destination file path is required.');
    end

    [folderPath, ~, ext] = fileparts(filePath);
    if ~strcmpi(ext, '.mat')
        error('PGIXS:InvalidFileType', '2D info files must be saved as .mat files.');
    end
    if ~isempty(folderPath) && ~isfolder(folderPath)
        error('PGIXS:DirectoryNotFound', 'Destination folder does not exist: %s', folderPath);
    end

    save(filePath, '-struct', 'info');

    report = struct();
    report.Path = filePath;
    report.SchemaName = getStructField(info, 'SchemaName', '');
    report.SchemaVersion = getStructField(info, 'SchemaVersion', '');
    report.ValidationOK = getStructField(info, 'ValidationOK', []);
end

function value = getStructField(s, fieldName, fallback)
    if isfield(s, fieldName)
        value = s.(fieldName);
    else
        value = fallback;
    end
end
