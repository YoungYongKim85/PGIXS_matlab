function matrixData = sanitizePGIXSExportMatrix(matrixData, replacementValue)
% sanitizePGIXSExportMatrix  Replace non-finite export cells for text outputs.

    if nargin < 2 || isempty(replacementValue)
        replacementValue = 0;
    end
    matrixData(~isfinite(matrixData)) = replacementValue;
end
