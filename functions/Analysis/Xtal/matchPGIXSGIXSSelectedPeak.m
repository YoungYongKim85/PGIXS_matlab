function [selectedPeak, nearestIndex, nearestDistance] = matchPGIXSGIXSSelectedPeak(peakPosition, simulatedQHorizontal, simulatedQZ, hklList)
% matchPGIXSGIXSSelectedPeak  Attach the nearest simulated HKL to a picked GIXS peak.

    validateattributes(peakPosition, {'numeric'}, {'vector', 'numel', 2, 'real'}, ...
        mfilename, 'peakPosition');
    validateattributes(simulatedQHorizontal, {'numeric'}, {'vector', 'real'}, ...
        mfilename, 'simulatedQHorizontal');
    validateattributes(simulatedQZ, {'numeric'}, {'vector', 'real'}, mfilename, 'simulatedQZ');
    validateattributes(hklList, {'numeric'}, {'2d', 'ncols', 3, 'real'}, mfilename, 'hklList');

    simulatedQHorizontal = double(simulatedQHorizontal(:));
    simulatedQZ = double(simulatedQZ(:));
    hklList = double(hklList);
    if isempty(simulatedQHorizontal) || numel(simulatedQHorizontal) ~= numel(simulatedQZ) || ...
            size(hklList, 1) ~= numel(simulatedQHorizontal)
        error('PGIXS:InvalidGIXSPeakMatchInputs', ...
            'Simulated peak arrays and HKL list must have matching nonzero lengths.');
    end

    peakPosition = double(peakPosition(:).');
    distances = hypot(simulatedQHorizontal - peakPosition(1), simulatedQZ - peakPosition(2));
    [nearestDistance, nearestIndex] = min(distances);
    selectedPeak = [peakPosition, hklList(nearestIndex, :)];
end
