function normalizedCounts = normalizePGIXSCounters(counts, referenceCounts)
% normalizePGIXSCounters  Normalize IC/BC counters with safe fallbacks.

    counts = single(counts(:).');
    referenceCounts = single(referenceCounts(:).');
    nValues = numel(counts);
    normalizedCounts = counts;

    for ii = 1:nValues
        if ii <= numel(referenceCounts) && ~isnan(referenceCounts(ii)) && referenceCounts(ii) ~= 0
            normalizedCounts(ii) = counts(ii) ./ referenceCounts(ii);
        end
    end
end
