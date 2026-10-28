function newIdx = selectPGIXSNewSeriesFiles(files, lastFile, nOld)
% selectPGIXSNewSeriesFiles  Indices of series files Auto Refresh should add.
%
%   newIdx = selectPGIXSNewSeriesFiles(files, lastFile, nOld)
%
%   files    - the series listing, sorted (listPGIXSSeriesFiles output)
%   lastFile - full path of the last file the series holds ('' if unknown)
%   nOld     - number of frames the series holds
%
%   Only files after lastFile are new. Counting nOld from the top of the
%   listing (the earlier rule) re-read files whenever the series did not
%   start at the first file or a file was left unchecked at Set/Table: with
%   0003 unchecked, 0005 came in twice and every later frame sat one place
%   off its X axis. nOld is used only when lastFile is unknown.

    if ischar(files) || isstring(files)
        files = cellstr(files);
    end
    nTotal = numel(files);
    lastIdx = [];
    if ~isempty(lastFile)
        lastIdx = find(strcmp(files, char(lastFile)), 1, 'last');
        if isempty(lastIdx)
            % The last file is gone from the listing: everything that sorts
            % after its name is still new.
            lastIdx = nnz(cellfun(@(f) issorted({f, char(lastFile)}), files));
        end
    end
    if isempty(lastIdx)
        lastIdx = nOld;
    end
    newIdx = (lastIdx + 1):nTotal;
end
