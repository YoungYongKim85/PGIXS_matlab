% 1d line cut function with pixel accumulation - OPTIMIZED VERSION
function [linepos, line1d] = Accumpix_gi(param, mPix, pPix)

if isfield(param, 'Mapping')
    switch param.Mapping
        case 'Pixel',  data2d = single(param.data);
        case 'Alpha',  data2d = getPGIXSCutImage(param, 'AlphaMap');
        case 'Qxy/Qz', data2d = getPGIXSCutImage(param, 'Itrans');
        case 'Qy/Qz',  data2d = getPGIXSCutImage(param, 'Itrans');
    end
else
    data2d = single(param.Stack(:,:,1));
end

% Same 3-pixel gap shoulder every other 1D cut drops (and the Python port's
% accumulation cut) -- in detector-pixel space only; a regridded (Alpha or Q) image had
% it blanked before its regrid (buildPGIXSCutImage).
if ~isPGIXSRegriddedMapping(param) && isfield(param, 'Mask') && isequal(size(param.Mask), size(data2d))
    data2d(dilatePGIXSGapMask(param.Mask, 3)) = NaN;
end

[n, m] = size(data2d);
pixA = mPix:pPix;
beampos_x = fix(param.bpos(1));
beampos_y = fix(param.bpos(2));

if param.ang == 0 || param.ang == 180
    [qq, zq, dq] = processHorizontal(param, data2d, beampos_x, beampos_y, pixA, m);
    if param.ang == 0
        valid = dq <= 0; % Left 쪽만 추출
        dq = -dq(valid);
        qq = abs(qq(valid));
        zq = zq(valid);
    else
        valid = dq >= 0; % Right 쪽만 추출
        dq = dq(valid);
        qq = abs(qq(valid));
        zq = zq(valid);
    end
elseif param.ang == 90
    [qq, zq, dq] = processVertical(param, data2d, beampos_x, beampos_y, pixA, n);
    valid = dq >= 0; % Up 쪽만 추출
    dq = dq(valid);
    qq = abs(qq(valid));
    zq = zq(valid);
else
    warndlg('Please use angle 0, 90, or 180!', 'Warning');
    linepos = []; line1d = []; return;
end

validIdx = ~isnan(zq);
dq = dq(validIdx); qq = qq(validIdx); zq = zq(validIdx);

line1d = zeros(length(dq), 3, 'single');
line1d(:,1) = dq(:); line1d(:,2) = qq(:); line1d(:,3) = zq(:);

linepos = calculateLinePositions(param, m, n, mPix, pPix);
end

%% Process horizontal cut (0° or 180°)
function [qq, zq, dq] = processHorizontal(param, data2d, beampos_x, beampos_y, pixA, m)
    Qval = getQvalHorizontal(param);
    if isempty(Qval), qq = zeros(1, m, 'single'); else, qq = Qval(beampos_y, :); end
    
    zStart = beampos_y - param.zposmv - pixA(end); 
    zEnd = beampos_y - param.zposmv - pixA(1);
    zStart = max(1, min(size(data2d,1), zStart));
    zEnd = max(1, min(size(data2d,1), zEnd));
    if zStart > zEnd, t=zStart; zStart=zEnd; zEnd=t; end
    
    zq = mean(data2d(zStart:zEnd, :), 1, 'omitnan');
    dq = single((1:m) - beampos_x);
end

%% Process vertical cut (90°)
function [qq, zq, dq] = processVertical(param, data2d, beampos_x, beampos_y, pixA, n)
    Qval = getQvalVertical(param);
    if isempty(Qval), qq = zeros(n, 1, 'single'); else, qq = Qval(:, beampos_x)'; end
    
    xStart = beampos_x + param.yposmv + pixA(1);
    xEnd = beampos_x + param.yposmv + pixA(end);
    xStart = max(1, min(size(data2d,2), xStart));
    xEnd = max(1, min(size(data2d,2), xEnd));
    if xStart > xEnd, t=xStart; xStart=xEnd; xEnd=t; end
    
    zq = mean(data2d(:, xStart:xEnd), 2, 'omitnan')';
    dq = single(-((1:n) - beampos_y));
end

function Qval = getQvalHorizontal(param)
    switch param.QMapMet
        case 'Qxy/Qz'
            if isfield(param, 'Mapping')
                switch param.Mapping
                    case {'Pixel', 'Alpha'}
                        Qval = single(sign(param.Qr) .* param.Q);
                    case 'Qxy/Qz'
                        [Qr, ~] = meshgrid(single(param.qr), single(param.qz));
                        Qval = Qr;
                end
            else
                Qval = [];
            end
        case 'Qy/Qz'
            if isfield(param, 'Mapping')
                switch param.Mapping
                    case {'Pixel', 'Alpha'}
                        Qval = single(sign(param.Qy) .* param.Q);
                    case 'Qy/Qz'
                        [Qy, ~] = meshgrid(single(param.qy), single(param.qz));
                        Qval = Qy;
                end
            else
                Qval = [];
            end
    end
end

function Qval = getQvalVertical(param)
    if isfield(param, 'Mapping')
        switch param.Mapping
            case {'Pixel', 'Alpha'}
                Qval = single(sign(param.Qz) .* param.Q);
            case {'Qxy/Qz', 'Qy/Qz'}
                if strcmp(param.Mapping, 'Qxy/Qz')
                    [~, Qz] = meshgrid(single(param.qr), single(param.qz));
                else
                    [~, Qz] = meshgrid(single(param.qy), single(param.qz));
                end
                Qval = Qz;
        end
    else
        Qval = [];
    end
end

function linepos = calculateLinePositions(param, m, ~, mPix, pPix)
    linepos = zeros(4, 2, 'single');
    x_min_rel = -param.bpos(1);
    x_max_rel = m - param.bpos(1);
    y_max_rel = param.bpos(2); % Physical Up limit
    
    if param.ang == 0
        linepos(1,1) = 0; linepos(2,1) = x_min_rel; linepos(3,1) = param.zposmv + mPix; linepos(4,1) = param.zposmv + mPix;
        linepos(1,2) = 0; linepos(2,2) = x_min_rel; linepos(3,2) = param.zposmv + pPix; linepos(4,2) = param.zposmv + pPix;
    elseif param.ang == 180
        linepos(1,1) = 0; linepos(2,1) = x_max_rel; linepos(3,1) = param.zposmv + mPix; linepos(4,1) = param.zposmv + mPix;
        linepos(1,2) = 0; linepos(2,2) = x_max_rel; linepos(3,2) = param.zposmv + pPix; linepos(4,2) = param.zposmv + pPix;
    elseif param.ang == 90
        linepos(1,1) = param.yposmv + mPix; linepos(2,1) = param.yposmv + mPix; linepos(3,1) = 0; linepos(4,1) = y_max_rel;
        linepos(1,2) = param.yposmv + pPix; linepos(2,2) = param.yposmv + pPix; linepos(3,2) = 0; linepos(4,2) = y_max_rel;
    end
end
