function [baseName, ok] = promptPGIXSSaveFileBaseName(defaultName, saveForm, dialogTitle)
% promptPGIXSSaveFileBaseName  Ask for a save filename base and sanitize it.
%
% The returned baseName does not include the selected output extension.

    if nargin < 2
        saveForm = '';
    end
    if nargin < 3 || isempty(dialogTitle)
        dialogTitle = 'Save Filename';
    end

    defaultName = sanitizeBaseName(defaultName, saveForm);
    ok = false;
    baseName = defaultName;

    answer = inputdlg({'Filename without extension:'}, dialogTitle, [1 80], {defaultName});
    if isempty(answer)
        return;
    end

    candidate = sanitizeBaseName(answer{1}, saveForm);
    if isempty(candidate)
        return;
    end

    baseName = candidate;
    ok = true;
end

function baseName = sanitizeBaseName(nameValue, saveForm)
    if nargin < 2
        saveForm = '';
    end

    if isstring(nameValue)
        if numel(nameValue) ~= 1
            baseName = 'output';
            return;
        end
        baseName = char(nameValue);
    elseif ischar(nameValue)
        baseName = nameValue;
    else
        baseName = 'output';
        return;
    end

    baseName = strtrim(baseName);
    if ~isempty(saveForm) && endsWith(lower(baseName), lower(saveForm))
        baseName = baseName(1:end-numel(saveForm));
        baseName = strtrim(baseName);
    end

    baseName = regexprep(baseName, '[\x00-\x1F\\/:*?"<>|]', '_');
    baseName = regexprep(baseName, '[\s\.]+$', '');
    baseName = strtrim(baseName);

    if isempty(baseName)
        baseName = 'output';
    end
end
