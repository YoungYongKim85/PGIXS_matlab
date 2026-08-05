function state = summarizePGIXSState(param, actionName, extra)
% summarizePGIXSState  Build a compact diagnostic state snapshot.

    if nargin < 1 || isempty(param), param = struct(); end
    if nargin < 2, actionName = ''; end
    if nargin < 3 || isempty(extra), extra = struct(); end

    state = struct();
    state.Action = char(string(actionName));
    state.Timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
    state.IsDeployed = isdeployed;
    state.MATLAB = version;
    state.Platform = computer;
    state.WorkingDirectory = pwd;

    fields = {'FileName', 'Path', 'detector', 'Mapping', 'QMapMet', ...
        'correctionI', 'Normalcheck', 'Expinfo', 'Energy', 'Wavelength', ...
        'SDD', 'pixel', 'bpos', 'dataSize', 'ang', 'ai'};
    for ii = 1:numel(fields)
        if isfield(param, fields{ii})
            state.(fields{ii}) = compactValue(param.(fields{ii}));
        end
    end

    state.HasData = isfield(param, 'data') && ~isempty(param.data);
    if state.HasData, state.Data = summarizeArray(param.data); end
    state.HasStack = isfield(param, 'Stack') && ~isempty(param.Stack);
    if state.HasStack, state.Stack = summarizeArray(param.Stack); end
    if isfield(param, 'Itrans') && ~isempty(param.Itrans)
        state.Itrans = summarizeArray(param.Itrans);
    end
    if isfield(param, 'Q') && ~isempty(param.Q)
        state.Q = summarizeArray(param.Q);
    end

    extraFields = fieldnames(extra);
    for ii = 1:numel(extraFields)
        state.(extraFields{ii}) = compactValue(extra.(extraFields{ii}));
    end
end

function out = compactValue(value)
    if isnumeric(value) || islogical(value)
        if isempty(value) || numel(value) <= 12
            out = value;
        else
            out = summarizeArray(value);
        end
    elseif isstring(value)
        out = char(strjoin(value(:).', ", "));
    elseif ischar(value)
        out = value;
    else
        out = sprintf('(%s)', class(value));
    end
end

function summary = summarizeArray(value)
    summary = struct();
    summary.Class = class(value);
    summary.Size = size(value);
    if isnumeric(value) || islogical(value)
        finiteMask = isfinite(value);
        summary.Numel = numel(value);
        summary.Finite = nnz(finiteMask);
        summary.NaN = nnz(isnan(value));
        if any(finiteMask(:))
            finiteValues = value(finiteMask);
            summary.Min = min(finiteValues(:));
            summary.Max = max(finiteValues(:));
            summary.Mean = mean(double(finiteValues(:)), 'omitnan');
        end
    end
end
