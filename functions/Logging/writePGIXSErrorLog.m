function [logPath, report] = writePGIXSErrorLog(actionName, err, state)
% writePGIXSErrorLog  Persist detailed PGIXS error diagnostics.

    if nargin < 1 || isempty(actionName), actionName = 'Unknown action'; end
    if nargin < 2 || isempty(err), err = MException('PGIXS:UnknownError', 'Unknown error'); end
    if nargin < 3 || isempty(state), state = struct(); end

    report = struct('OK', false, 'Message', '');
    logPath = '';

    try
        logDir = getPGIXSLogDirectory();
        if ~exist(logDir, 'dir')
            mkdir(logDir);
        end

        stamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
        safeAction = regexprep(char(actionName), '[^\w.-]', '_');
        safeAction = regexprep(safeAction, '_+', '_');
        safeAction = safeAction(1:min(numel(safeAction), 80));
        logPath = fullfile(logDir, ['PGIXS_', stamp, '_', safeAction, '.log']);

        fid = fopen(logPath, 'w');
        if fid < 0
            error('PGIXS:LogOpenFailed', 'Could not open log file: %s', logPath);
        end
        cleanup = onCleanup(@() fclose(fid));

        fprintf(fid, 'PGIXS Error Log\n');
        fprintf(fid, '================\n');
        fprintf(fid, 'Timestamp: %s\n', char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')));
        fprintf(fid, 'Action: %s\n', char(actionName));
        fprintf(fid, 'MATLAB: %s\n', version);
        fprintf(fid, 'Computer: %s\n', computer);
        fprintf(fid, 'IsDeployed: %d\n', double(isdeployed));
        fprintf(fid, 'WorkingDirectory: %s\n\n', pwd);

        fprintf(fid, 'Error\n');
        fprintf(fid, '-----\n');
        fprintf(fid, 'Identifier: %s\n', err.identifier);
        fprintf(fid, 'Message: %s\n\n', err.message);

        fprintf(fid, 'Stack\n');
        fprintf(fid, '-----\n');
        if isempty(err.stack)
            fprintf(fid, '(empty stack)\n');
        else
            for ii = 1:numel(err.stack)
                frame = err.stack(ii);
                fprintf(fid, '#%d %s line %d\n', ii, frame.name, frame.line);
                if isfield(frame, 'file') && ~isempty(frame.file)
                    fprintf(fid, '   %s\n', frame.file);
                end
            end
        end
        fprintf(fid, '\n');

        fprintf(fid, 'State Summary\n');
        fprintf(fid, '-------------\n');
        writeStruct(fid, state, 0);

        report.OK = true;
    catch logErr
        report.Message = logErr.message;
    end
end

function logDir = getPGIXSLogDirectory()
    if ispc
        rootDir = getenv('USERPROFILE');
        if isempty(rootDir), rootDir = char(java.lang.System.getProperty('user.home')); end
        candidate = fullfile(rootDir, 'Documents');
        if exist(candidate, 'dir')
            rootDir = candidate;
        end
    else
        rootDir = getenv('HOME');
        if isempty(rootDir), rootDir = pwd; end
    end
    logDir = fullfile(rootDir, 'PGIXS_logs');
end

function writeStruct(fid, value, indent)
    pad = repmat(' ', 1, indent);
    if isstruct(value)
        if numel(value) ~= 1
            fprintf(fid, '%s(struct array %s)\n', pad, mat2str(size(value)));
            return;
        end
        fields = fieldnames(value);
        if isempty(fields)
            fprintf(fid, '%s(empty struct)\n', pad);
            return;
        end
        for ii = 1:numel(fields)
            fieldName = fields{ii};
            fieldValue = value.(fieldName);
            if isstruct(fieldValue)
                fprintf(fid, '%s%s:\n', pad, fieldName);
                writeStruct(fid, fieldValue, indent + 2);
            else
                fprintf(fid, '%s%s: %s\n', pad, fieldName, valueToText(fieldValue));
            end
        end
    else
        fprintf(fid, '%s%s\n', pad, valueToText(value));
    end
end

function txt = valueToText(value)
    try
        if ischar(value)
            txt = value;
        elseif isstring(value)
            txt = char(strjoin(value(:).', ", "));
        elseif isnumeric(value) || islogical(value)
            if isempty(value)
                txt = '[]';
            elseif isscalar(value)
                txt = num2str(value);
            elseif numel(value) <= 12
                txt = mat2str(value);
            else
                txt = sprintf('%s %s min=%g max=%g finite=%d/%d', ...
                    class(value), mat2str(size(value)), min(value(:), [], 'omitnan'), ...
                    max(value(:), [], 'omitnan'), nnz(isfinite(value(:))), numel(value));
            end
        elseif isa(value, 'datetime')
            txt = char(value);
        else
            txt = sprintf('(%s)', class(value));
        end
    catch
        txt = sprintf('(%s, display failed)', class(value));
    end
end
