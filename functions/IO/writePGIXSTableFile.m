function [ok, report] = writePGIXSTableFile(tableData, filePath, varargin)
% writePGIXSTableFile  Write a table and report failures without throwing.

    report = struct('Path', filePath, 'Message', '');
    try
        writetable(tableData, filePath, varargin{:});
        ok = true;
    catch ME
        ok = false;
        report.Message = ME.message;
        warning('PGIXS:TableWriteFailed', '%s', ...
            ['Table write failed: ', ME.message]);
    end
end
