function azi = processPGIXSAzimuthal1D(D, indMap, mask, useMedian)
% processPGIXSAzimuthal1D  Extract azimuthal intensity from one 2D frame.
%
% D         2D image.
% indMap    radii-by-theta linear-index map. NaN entries are ignored.
% mask      detector/user mask. Pixels with mask <= 0 become NaN.
% useMedian true: median over radii, false: mean over radii.

    if nargin < 4
        useMedian = false;
    end

    D = single(D);
    if nargin >= 3 && ~isempty(mask)
        D(mask <= 0) = NaN;
    end

    vals = nan(size(indMap), 'single');
    good = ~isnan(indMap);
    vals(good) = D(indMap(good));

    if useMedian
        azi = median(vals, 1, 'omitnan')';
    else
        azi = mean(vals, 1, 'omitnan')';
    end

    valid_counts = sum(~isnan(vals), 1)';
    azi = postprocessAzimuthal(azi, valid_counts);
    azi = single(azi);
end

function v = postprocessAzimuthal(v, valid_counts)
    v = v(:);
    valid_counts = valid_counts(:);
    v(valid_counts < 1) = NaN;
end
