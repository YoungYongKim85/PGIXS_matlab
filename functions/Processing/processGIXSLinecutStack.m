function [data1dstack, refAxis] = processGIXSLinecutStack(param, opts)
% processGIXSLinecutStack  Run GIXS line/cake/pixel cuts over an image stack.
%
% opts fields
%   AccumMode      0: line/cake cut, 1: pixel accumulation.
%   CakeMode       0: standard line/pixel accumulation, 1: cake cut.
%   CutStart       Cake start angle.
%   CutFinish      Cake finish angle.
%   PixelMinus     Pixel accumulation lower offset.
%   PixelPlus      Pixel accumulation upper offset.
%   ChangeAngle    Recompute q-map per frame using AIVar.
%   AIVar          Incident-angle vector for ChangeAngle mode.
%   K0             Wavevector, 2*pi/Wavelength.
%   RefAxis        Optional reference q axis for appending new frames.
%   UseParallel    Use parfor when true.

    if nargin < 2
        opts = struct();
    end
    opts = mergeDefaultOptions(opts);

    stackData = param.Stack;
    nFrames = size(stackData, 3);
    pRef = rmfieldIfPresent(param, 'Stack');
    pRef.data = stackData(:, :, 1);

    isCake = (opts.CakeMode == 1) && (opts.AccumMode == 0);
    cakePrep = [];
    if isCake
        cakePrep = CakeCut_gi_prep(pRef, opts.CutStart, opts.CutFinish);
    end

    if isempty(opts.RefAxis)
        refLine = [];
        for refIdx = 1:nFrames
            refLine = runFrameCut(pRef, stackData(:, :, refIdx), refIdx, opts, cakePrep);
            if ~isempty(refLine) && ~all(isnan(refLine(:)))
                break;
            end
        end
        if isempty(refLine) || all(isnan(refLine(:)))
            data1dstack = zeros(0, nFrames + 1, 'single');
            refAxis = zeros(0, 1, 'single');
            return;
        end
        refAxis = single(refLine(:, 2));
        data1dstack = zeros(numel(refAxis), nFrames + 1, 'single');
        data1dstack(:, 1) = refAxis;
        colOffset = 1;
    else
        refAxis = single(opts.RefAxis(:));
        data1dstack = zeros(numel(refAxis), nFrames, 'single');
        colOffset = 0;
    end

    if opts.UseParallel
        parfor ii = 1:nFrames
            lineRes = runFrameCut(pRef, stackData(:, :, ii), ii, opts, cakePrep);
            data1dstack(:, ii + colOffset) = alignLineToRef(lineRes, refAxis, opts.ChangeAngle);
        end
    else
        for ii = 1:nFrames
            lineRes = runFrameCut(pRef, stackData(:, :, ii), ii, opts, cakePrep);
            data1dstack(:, ii + colOffset) = alignLineToRef(lineRes, refAxis, opts.ChangeAngle);
        end
    end
end

function lineRes = runFrameCut(pRef, frameData, frameIndex, opts, cakePrep)
    pLocal = pRef;
    pLocal.data = frameData;

    if opts.ChangeAngle && ~isempty(opts.AIVar) && ~isempty(opts.K0)
        pLocal.ai = opts.AIVar(frameIndex);
        [~, pLocal.Qr, pLocal.Qz, pLocal.Q, ~, ~] = Qmaping_gi( ...
            pLocal.dataSize(2), pLocal.dataSize(1), pLocal.bpos, ...
            pLocal.pixel, pLocal.SDD, opts.K0, pLocal.ai);
    end

    lineRes = runSingleGIXSCut(pLocal, frameData, opts, cakePrep);
end

function lineRes = runSingleGIXSCut(pLocal, frameData, opts, cakePrep)
    if opts.CakeMode == 1 && opts.AccumMode == 0 && ~isempty(cakePrep) && ~opts.ChangeAngle
        [~, lineRes] = CakeCut_gi_fast(frameData, cakePrep);
    elseif opts.AccumMode == 0
        if opts.CakeMode == 0
            [~, lineRes] = Anglecut1d_gi(pLocal);
        else
            [~, lineRes] = CakeCut_gi(pLocal, opts.CutStart, opts.CutFinish);
        end
    else
        if opts.CakeMode == 0
            [~, lineRes] = Accumpix_gi(pLocal, opts.PixelMinus, opts.PixelPlus);
        else
            lineRes = [NaN, NaN, NaN];
        end
    end

    if isempty(lineRes)
        lineRes = [NaN, NaN, NaN];
    end
end

function out = alignLineToRef(lineRes, refAxis, changeAngle)
    resLen = numel(refAxis);
    if isempty(lineRes) || size(lineRes, 2) < 3 || all(isnan(lineRes(:)))
        out = nan(resLen, 1, 'single');
        return;
    end

    curX = lineRes(:, 2);
    curY = lineRes(:, 3);
    if numel(curY) == resLen && ~changeAngle
        out = single(curY);
    else
        [uX, idx] = unique(curX);
        uY = curY(idx);
        if numel(uX) > 1
            out = single(interp1(uX, uY, refAxis, 'linear', NaN));
        else
            out = nan(resLen, 1, 'single');
        end
    end
end

function s = rmfieldIfPresent(s, fieldName)
    if isfield(s, fieldName)
        s = rmfield(s, fieldName);
    end
end

function opts = mergeDefaultOptions(opts)
    defaults = struct( ...
        'AccumMode', 0, ...
        'CakeMode', 0, ...
        'CutStart', single(0), ...
        'CutFinish', single(0), ...
        'PixelMinus', single(0), ...
        'PixelPlus', single(0), ...
        'ChangeAngle', false, ...
        'AIVar', [], ...
        'K0', [], ...
        'RefAxis', [], ...
        'UseParallel', false);

    fields = fieldnames(defaults);
    for ii = 1:numel(fields)
        name = fields{ii};
        if ~isfield(opts, name) || isempty(opts.(name))
            opts.(name) = defaults.(name);
        end
    end

    opts.AccumMode = double(opts.AccumMode);
    opts.CakeMode = double(opts.CakeMode);
    opts.CutStart = single(opts.CutStart);
    opts.CutFinish = single(opts.CutFinish);
    opts.PixelMinus = single(opts.PixelMinus);
    opts.PixelPlus = single(opts.PixelPlus);
    opts.ChangeAngle = logical(opts.ChangeAngle);
    opts.UseParallel = logical(opts.UseParallel);
end
