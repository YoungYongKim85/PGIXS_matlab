function report = diagnosePGIXSSectorAverage(data2d, qMap, center, angleRange, useMedian)
% diagnosePGIXSSectorAverage  Report coverage for a TrXS angular average.
%
% This mirrors TrXS_gui Ang. Avg binning: select an angular sector, bin by
% detector-pixel radius, and attach mean Q per radius bin. The extra coverage
% fields help identify detector-gap artifacts.

    if nargin < 5 || isempty(useMedian)
        useMedian = false;
    end

    validateattributes(data2d, {'numeric'}, {'2d'});
    validateattributes(qMap, {'numeric'}, {'size', size(data2d)});
    validateattributes(center, {'numeric'}, {'numel', 2, 'finite'});
    validateattributes(angleRange, {'numeric'}, {'numel', 2, 'finite'});

    data2d = single(data2d);
    qMap = single(qMap);
    center = double(center(:)');
    angleRange = double(angleRange(:)');

    finiteQ = isfinite(qMap) & qMap > 0;
    sectorMask = makeSectorMask(size(data2d), center, angleRange);
    sectorGeomMask = finiteQ & sectorMask;

    prepSector = buildPGIXSRadiusBinMap(qMap, center, sectorGeomMask);
    if prepSector.isValid
        [intensity, ~, dataCounts] = processPGIXSRadiusBin1D(data2d, prepSector, useMedian, false);
    else
        intensity = single([]);
        dataCounts = [];
    end

    prepFull = buildPGIXSRadiusBinMap(qMap, center, finiteQ);
    sectorGeomCounts = zeros(prepSector.n_bins, 1);
    fullCountsForSectorBins = zeros(prepSector.n_bins, 1);
    if prepSector.isValid
        sectorGeomCounts = double(prepSector.geom_counts(:));
    end
    if prepSector.isValid && prepFull.isValid
        fullCountsForSectorBins = estimateFullCountsForSectorBins(center, finiteQ, prepSector.r_axis);
    end

    coverage = nan(prepSector.n_bins, 1);
    validDenom = sectorGeomCounts > 0;
    coverage(validDenom) = double(dataCounts(validDenom)) ./ double(sectorGeomCounts(validDenom));

    report = struct();
    report.AngleRange = angleRange;
    report.Center = center;
    report.UseMedian = logical(useMedian);
    report.RadiusAxis = prepSector.r_axis(:);
    report.QAxis = prepSector.q_axis(:);
    report.Intensity = intensity(:);
    report.ValidDataCounts = dataCounts(:);
    report.SectorGeomCounts = sectorGeomCounts(:);
    report.FullRingCounts = fullCountsForSectorBins(:);
    report.CoverageFraction = single(coverage(:));
    report.LowCoverageBins = find(coverage < 0.15);
    report.CoverageDropBins = findCoverageDropBins(coverage);
    report.SectorPixelCount = nnz(sectorGeomMask);
    report.FullPixelCount = nnz(finiteQ);
    report.IsValid = prepSector.isValid;
end

function mask = makeSectorMask(dataSize, center, angleRange)
    nRows = dataSize(1);
    nCols = dataSize(2);
    [xGrid, yGrid] = meshgrid(1:nCols, 1:nRows);

    angle = atan2d(-(double(yGrid) - center(2)), -(double(xGrid) - center(1)));
    angle = mod(angle, 360);
    a1 = mod(angleRange(1), 360);
    a2 = mod(angleRange(2), 360);

    if angleRange(1) == angleRange(2)
        mask = true(dataSize);
    elseif a1 < a2
        mask = angle >= a1 & angle <= a2;
    else
        mask = angle >= a1 | angle <= a2;
    end
end

function counts = estimateFullCountsForSectorBins(center, finiteQ, sectorRadiusAxis)
    [row, col] = find(finiteQ);
    radius = hypot(double(col) - center(1), double(row) - center(2));
    binIdx = floor(radius) + 1;
    nBins = max(binIdx);
    fullCounts = accumarray(binIdx, 1, [nBins, 1], @sum, 0);

    sectorBinIdx = floor(double(sectorRadiusAxis(:))) + 1;
    counts = zeros(numel(sectorBinIdx), 1);
    valid = sectorBinIdx >= 1 & sectorBinIdx <= numel(fullCounts);
    counts(valid) = fullCounts(sectorBinIdx(valid));

end

function dropBins = findCoverageDropBins(coverage)
    coverage = double(coverage(:));
    finiteCoverage = isfinite(coverage);
    if nnz(finiteCoverage) < 5
        dropBins = [];
        return;
    end

    c = coverage;
    c(~finiteCoverage) = NaN;
    dc = [NaN; abs(diff(c))];
    medDrop = median(dc(isfinite(dc)), 'omitnan');
    if ~isfinite(medDrop) || medDrop <= 0
        medDrop = 0.05;
    end
    dropBins = find(dc > max(0.10, 5 * medDrop));
end
