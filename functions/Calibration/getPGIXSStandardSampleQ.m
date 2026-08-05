function qValue = getPGIXSStandardSampleQ(sampleName, order)
% getPGIXSStandardSampleQ  Return expected q value for SDD standards.

    if nargin < 2 || isempty(order)
        order = 1;
    end
    validateattributes(order, {'numeric'}, {'scalar', 'positive', 'finite'}, ...
        mfilename, 'order');

    switch char(sampleName)
        case 'SEBS'
            baseQ = 0.01916;
        case 'Silver behenate'
            baseQ = 0.1052;
        case 'Mesoporous Silica'
            baseQ = 0.059264;
        case 'Sucrose'
            baseQ = 0.5933;
        otherwise
            error('PGIXS:UnknownStandardSample', ...
                'Unknown SDD standard sample: %s', char(sampleName));
    end

    qValue = double(baseQ) * double(order);
end
