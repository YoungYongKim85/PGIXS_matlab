function rotation = parsePGIXSRotationVector(rawValues, defaultRotation)
% parsePGIXSRotationVector  Parse three Euler rotation values from GUI text.

    if nargin < 2 || isempty(defaultRotation)
        defaultRotation = [0 0 0];
    end

    rawValues = normalizeCellInputs(rawValues, 3);
    rotation = zeros(1, 3);
    for ii = 1:3
        rotation(ii) = parsePGIXSNumeric(rawValues{ii}, defaultRotation(ii), -3600, 3600);
    end
end

function out = normalizeCellInputs(inputs, nItems)
    if iscell(inputs)
        out = inputs;
    else
        out = num2cell(inputs);
    end
    if numel(out) < nItems
        out(end+1:nItems) = {[]};
    end
    out = out(1:nItems);
end
