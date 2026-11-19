function ai = readPGIXSFileIncidence(filePath)
% readPGIXSFileIncidence  Incidence angle [deg] the beamline wrote into an H5 file.
%
% Read from /entry/instrument/user/params: IncAngle, or IAngle as the Eiger
% files of 2026-10 name it. NaN when the file records neither (or is not an
% H5 file at all), so callers keep the typed angle.

    ai = NaN;
    names = {'IncAngle', 'IAngle'};
    for ii = 1:numel(names)
        try
            raw = h5read(filePath, ['/entry/instrument/user/params/', names{ii}]);
            value = double(raw(1));
        catch
            value = NaN;
        end
        if isfinite(value)
            % Stored as single: 0.15 comes back as 0.15000000596...
            ai = round(value, 6);
            return;
        end
    end
end
