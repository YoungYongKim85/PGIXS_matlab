function intensity = alignPGIXSLinecutToReference(line1d, refDistance)
% alignPGIXSLinecutToReference  Align TrXS line-cut intensity to a reference axis.

    refDistance = double(refDistance(:));
    intensity = nan(numel(refDistance), 1, 'single');

    if isempty(line1d) || size(line1d, 2) < 3 || isempty(refDistance)
        return;
    end

    distance = double(line1d(:, 1));
    values = double(line1d(:, 3));

    if numel(values) == numel(refDistance) && all(abs(distance(:) - refDistance) < 1e-4 | (isnan(distance(:)) & isnan(refDistance)))
        intensity = single(values(:));
        return;
    end

    valid = isfinite(distance);
    distance = distance(valid);
    values = values(valid);
    if numel(distance) < 2
        return;
    end

    [distance, uniqueIdx] = unique(distance, 'stable');
    values = values(uniqueIdx);
    if numel(distance) < 2
        return;
    end

    intensity = single(interp1(distance, values, refDistance, 'linear', NaN));
end
