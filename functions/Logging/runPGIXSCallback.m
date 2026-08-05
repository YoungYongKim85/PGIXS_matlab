function ok = runPGIXSCallback(parentFig, actionName, callbackFcn, stateFcn)
% runPGIXSCallback  Execute a GUI callback with compiled-app friendly logging.

    if nargin < 4 || isempty(stateFcn)
        stateFcn = @() struct();
    end
    ok = false;
    try
        callbackFcn();
        ok = true;
    catch ME
        try
            state = stateFcn();
        catch
            state = struct();
        end
        [logPath, logReport] = writePGIXSErrorLog(actionName, ME, state);
        if logReport.OK
            msg = sprintf('%s failed.\n\n%s\n\nLog file:\n%s', actionName, ME.message, logPath);
        else
            msg = sprintf('%s failed.\n\n%s\n\nLog write failed: %s', actionName, ME.message, logReport.Message);
        end
        showPGIXSErrorAlert(parentFig, msg);
    end
end

function showPGIXSErrorAlert(parentFig, msg)
    try
        if nargin >= 1 && ~isempty(parentFig) && isvalid(parentFig)
            uialert(parentFig, msg, 'PGIXS Error', 'Icon', 'error');
        else
            errordlg(msg, 'PGIXS Error');
        end
    catch
        warning('PGIXS:CallbackError', '%s', msg);
    end
end
