function [saveDir, ok, report] = ensurePGIXSSaveDir(basePath, fileName, fallbackRoot)
% ensurePGIXSSaveDir  Create the standard PGIXS result directory.
%
% The standard directory is fullfile(basePath, fileName). If creation fails
% because of permission problems, the user is asked for an alternate root.

    if nargin < 3 || isempty(fallbackRoot)
        fallbackRoot = pwd;
    end

    report = struct('Message', '', 'UsedFallback', false);
    ok = true;
    saveDir = fullfile(basePath, fileName);

    [status, msg] = mkdir(saveDir);
    if status ~= 0
        return;
    end

    if contains(msg, 'Permission denied', 'IgnoreCase', true) || ...
            contains(msg, 'Access is denied', 'IgnoreCase', true)
        altPath = uigetdir(fallbackRoot, 'Select Save Directory');
        if altPath == 0
            ok = false;
            report.Message = 'Save directory selection was canceled.';
            return;
        end

        saveDir = fullfile(altPath, fileName);
        [status, msg] = mkdir(saveDir);
        report.UsedFallback = true;
    end

    if status == 0
        ok = false;
        report.Message = msg;
    end
end
