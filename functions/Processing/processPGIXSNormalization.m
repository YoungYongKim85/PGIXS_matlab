function [dataOut, report] = processPGIXSNormalization(data, bkg, count, countBkg, method, plusData)
% processPGIXSNormalization  Apply background subtraction and IC/BC normalization.

    if nargin < 2, bkg = []; end
    if nargin < 3, count = []; end
    if nargin < 4, countBkg = []; end
    if nargin < 5 || isempty(method), method = 'None'; end
    if nargin < 6 || isempty(plusData), plusData = 1; end

    report = struct('Success', true, 'Message', '');

    switch char(method)
        case 'None'
            if ~isempty(bkg)
                dataOut = data - (plusData .* bkg);
            else
                dataOut = data;
            end
        case 'IC'
            [ok, message] = hasValidCounter(count, 1, 'IC value is 0 or missing!');
            if ~ok
                [dataOut, report] = failed(data, message);
                return;
            end
            if ~isempty(bkg)
                [ok, message] = hasValidCounter(countBkg, 1, 'Background IC value is 0!');
                if ~ok
                    [dataOut, report] = failed(data, message);
                    return;
                end
                dataOut = (data ./ count(1)) - (plusData .* bkg ./ countBkg(1));
            else
                dataOut = data ./ count(1);
            end
        case 'BC'
            [ok, message] = hasValidCounter(count, 2, 'BC value is 0 or missing!');
            if ~ok
                [dataOut, report] = failed(data, message);
                return;
            end
            if ~isempty(bkg)
                [ok, message] = hasValidCounter(countBkg, 2, 'Background BC value is 0!');
                if ~ok
                    [dataOut, report] = failed(data, message);
                    return;
                end
                dataOut = (data ./ count(2)) - (plusData .* bkg ./ countBkg(2));
            else
                dataOut = data ./ count(2);
            end
        otherwise
            dataOut = data;
    end

    dataOut(dataOut < 0) = 0;
end

function [ok, message] = hasValidCounter(count, index, message)
    ok = numel(count) >= index && isfinite(count(index)) && count(index) ~= 0;
end

function [dataOut, report] = failed(data, message)
    dataOut = data;
    report = struct('Success', false, 'Message', message);
end
