function [ai, vary] = summarizePGIXSFileIncidence(angles)
% summarizePGIXSFileIncidence  What a series' files say about the incidence angle.
%
% ai    The first file's angle when every file records one, else NaN (a
%       partly-logged series keeps the typed angle).
% vary  true when every file records one and they differ: an angle scan,
%       which needs a q-map per frame (Change ai).

    angles = double(angles(:));
    ai = NaN;
    vary = false;
    if isempty(angles) || ~all(isfinite(angles))
        return;
    end
    ai = angles(1);
    vary = numel(angles) > 1 && (max(angles) - min(angles)) > 1e-6;
end
