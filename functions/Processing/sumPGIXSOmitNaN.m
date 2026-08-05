function out = sumPGIXSOmitNaN(data, dim)
% sumPGIXSOmitNaN  Sum while preserving all-NaN slices as NaN.

    if nargin < 2 || isempty(dim)
        dim = find(size(data) ~= 1, 1);
        if isempty(dim)
            dim = 1;
        end
    end

    out = sum(data, dim, 'omitnan');
    allNan = all(isnan(data), dim);
    out(allNan) = NaN;

    if isa(data, 'single')
        out = single(out);
    end
end
