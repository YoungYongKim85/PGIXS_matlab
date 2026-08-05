function [ok, report] = savePGIXSStructFile(filePath, dataStruct)
% savePGIXSStructFile  Save a scalar struct to a MAT file with a report.

    report = struct('Path', filePath, 'Message', '');
    ok = false;

    if nargin < 2 || ~isstruct(dataStruct) || ~isscalar(dataStruct)
        report.Message = 'Input data must be a scalar struct.';
        return;
    end

    try
        save(filePath, '-struct', 'dataStruct');
        ok = true;
    catch ME
        report.Message = ME.message;
    end
end
