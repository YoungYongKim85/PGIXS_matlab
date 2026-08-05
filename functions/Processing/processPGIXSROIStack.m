function [sumI, roiBounds, validROI] = processPGIXSROIStack(stackData, roiList, useParallel)
% processPGIXSROIStack  Integrate rectangular ROIs over a 3D image stack.
%
% roiList columns are [rowStart rowEnd colStart colEnd].

    if nargin < 3
        useParallel = false;
    end

    [height, width, nFrames] = size(stackData);
    nROI = size(roiList, 1);
    sumI = nan(nFrames, nROI, 'single');
    roiBounds = zeros(nROI, 4);
    validROI = false(1, nROI);

    for r = 1:nROI
        roi = roiList(r, :);
        r1 = max(1, round(roi(1)));
        r2 = min(height, round(roi(2)));
        c1 = max(1, round(roi(3)));
        c2 = min(width, round(roi(4)));

        roiBounds(r, :) = [r1, r2, c1, c2];
        validROI(r) = (r1 <= r2) && (c1 <= c2);
    end

    if useParallel
        parfor ii = 1:nFrames
            frame = stackData(:, :, ii);
            rowSum = nan(1, nROI, 'single');
            for r = 1:nROI
                if validROI(r) %#ok<PFBNS>
                    bounds = roiBounds(r, :); %#ok<PFBNS>
                    block = frame(bounds(1):bounds(2), bounds(3):bounds(4));
                    rowSum(r) = sumPGIXSOmitNaN(block(:), 1);
                end
            end
            sumI(ii, :) = rowSum;
        end
    else
        for ii = 1:nFrames
            frame = stackData(:, :, ii);
            for r = 1:nROI
                if validROI(r)
                    bounds = roiBounds(r, :);
                    block = frame(bounds(1):bounds(2), bounds(3):bounds(4));
                    sumI(ii, r) = sumPGIXSOmitNaN(block(:), 1);
                end
            end
        end
    end
end
