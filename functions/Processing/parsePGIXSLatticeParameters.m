function [a, b, c, alpha, beta, gamma] = parsePGIXSLatticeParameters(lengthInputs, angleInputs, defaultLengths, defaultAngles)
% parsePGIXSLatticeParameters  Parse lattice lengths and angles safely.

    if nargin < 3 || isempty(defaultLengths)
        defaultLengths = [10 10 10];
    end
    if nargin < 4 || isempty(defaultAngles)
        defaultAngles = [90 90 90];
    end

    lengthInputs = normalizeCellInputs(lengthInputs, 3);
    angleInputs = normalizeCellInputs(angleInputs, 3);

    lengths = zeros(1, 3);
    angles = zeros(1, 3);
    for ii = 1:3
        lengths(ii) = parsePGIXSNumeric(lengthInputs{ii}, defaultLengths(ii), eps, Inf);
        angles(ii) = parsePGIXSNumeric(angleInputs{ii}, defaultAngles(ii), eps, 179.999);
    end

    a = lengths(1);
    b = lengths(2);
    c = lengths(3);
    alpha = angles(1);
    beta = angles(2);
    gamma = angles(3);
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
