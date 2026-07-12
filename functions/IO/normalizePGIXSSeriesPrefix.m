function prefix = normalizePGIXSSeriesPrefix(baseName)
% normalizePGIXSSeriesPrefix  Return the common prefix for PGIXS series files.

    if nargin < 1 || isempty(baseName)
        prefix = '';
        return;
    end

    if isstring(baseName)
        baseName = char(baseName);
    elseif ~ischar(baseName)
        prefix = '';
        return;
    end

    [~, prefix, ~] = fileparts(baseName);
    tokens = regexp(prefix, '^(.*)_\d{4,}$', 'tokens', 'once');
    if ~isempty(tokens)
        prefix = tokens{1};
    end
end
