function [linepos, line1d] = Anglecut1d_giplus(param)
% Anglecut1d_giplus - Optimized Version

switch param.Mapping
    case 'Pixel',  data2d = single(param.data);
    case 'Alpha',  data2d = single(param.AlphaMap);
    case 'Qxy/Qz', data2d = getPGIXSCutItrans(param);
    case 'Qy/Qz',  data2d = getPGIXSCutItrans(param);
end

% Gap-adjacent pixels bordering the masked detector gap can carry biased
% counts; exclude a 3-pixel shoulder (measured to cover most of the edge
% bias on real data) so it does not bleed into the bilinear interpolation
% below. The mask is in detector-pixel space: a Q-remapped image already
% had the shoulder blanked before its regrid (buildPGIXSCutItrans).
if ~isPGIXSQMapping(param) && isfield(param, 'Mask') && isequal(size(param.Mask), size(data2d))
    data2d(dilatePGIXSGapMask(param.Mask, 3)) = NaN;
end

[n, m] = size(data2d);
beampos_x = fix(param.bpos(1)); beampos_y = fix(param.bpos(2));

x = single((1:m) - beampos_x);
y = single(-((1:n) - beampos_y)); 

bval = ceil(sqrt(m^2 + n^2));
% Normalize to [0,360) so negative angles and angles beyond 180 deg (e.g.
% 270) are handled instead of silently degenerating to a zero-length ray
% -- CakeCut_gi already supports the full 360 deg via
% isPGIXSAngleInSector, so single-ray line cuts should too. Written back
% into param.ang (local copy only) so selectQGrids below, which reads
% param.ang directly, sees the same normalized value.
param.ang = mod(single(param.ang), 360);
ang = param.ang;
[xmin, xmax, ymin, ymax] = calculateLineCoords(ang, x, y, param.yposmv, param.zposmv);

xq = linspace(xmin, xmax, bval);
yq = linspace(ymin, ymax, bval);

[X, Y] = meshgrid(x, y);
zq = interp2(X, Y, data2d, xq, yq, 'linear');
dq = hypot(xq, yq); 

[Grid_Q, Grid_Std, Grid_Min, Grid_Max] = selectQGrids(param, X, Y);

qq    = interp2(X, Y, Grid_Q, xq, yq, 'linear');
qqstd = interp2(X, Y, Grid_Std, xq, yq, 'linear');
qqmin = interp2(X, Y, Grid_Min, xq, yq, 'linear');
qqmax = interp2(X, Y, Grid_Max, xq, yq, 'linear');

if ang == 0
    qq = abs(qq); qqmin = abs(qqmin); qqmax = abs(qqmax);
end

validIdx = ~isnan(zq);
line1d_raw = [dq(:), qq(:), zq(:), qqstd(:), qqmin(:), qqmax(:)];
line1d_raw = line1d_raw(validIdx, :);

line1d = single(line1d_raw); 
linepos = getDrawLinePos(ang, xmin, xmax, ymin, ymax, param);

end

function [xmin, xmax, ymin, ymax] = calculateLineCoords(ang, x, y, yposmv, zposmv)
    if ang == 0
        xmin = 0; xmax = min(x); ymin = single(zposmv); ymax = single(zposmv);
    elseif ang == 180
        xmin = 0; xmax = max(x); ymin = single(zposmv); ymax = single(zposmv);
    elseif ang == 90
        xmin = single(yposmv + eps); xmax = xmin; ymin = 0; ymax = max(y);
    elseif ang == 270
        xmin = single(yposmv + eps); xmax = xmin; ymin = 0; ymax = min(y);
    elseif ang > 0 && ang < 90
        tanAng = single(tand(ang)); y2 = -x * tanAng;
        validMask = (x < 0) & (y2 > min(y)) & (y2 <= max(y));
        validIdx = find(validMask, 1, 'first');
        if isempty(validIdx), xmin=0; xmax=0; ymin=0; ymax=0; return; end
        xmin = 0; xmax = x(validIdx); ymin = 0; ymax = y2(validIdx);
    elseif ang > 90 && ang < 180
        tanAng = single(tand(ang)); y2 = -x * tanAng;
        validMask = (x > 0) & (y2 > min(y)) & (y2 <= max(y));
        validIdx = find(validMask, 1, 'last');
        if isempty(validIdx), xmin=0; xmax=0; ymin=0; ymax=0; return; end
        xmin = 0; xmax = x(validIdx); ymin = 0; ymax = y2(validIdx);
    else
        % ang in (180,270) or (270,360): the discrete per-quadrant search
        % above only ever covered [0,180], so use a general direction/box
        % intersection instead (equivalent geometry, works for any angle).
        dx = -cosd(ang); dy = sind(ang);
        tMax = Inf;
        if dx > 1e-6,      tMax = min(tMax, double(max(x)) / double(dx));
        elseif dx < -1e-6, tMax = min(tMax, double(min(x)) / double(dx)); end
        if dy > 1e-6,      tMax = min(tMax, double(max(y)) / double(dy));
        elseif dy < -1e-6, tMax = min(tMax, double(min(y)) / double(dy)); end
        if ~isfinite(tMax) || tMax <= 0
            xmin=0; xmax=0; ymin=0; ymax=0; return;
        end
        xmin = 0; ymin = 0;
        xmax = single(tMax * dx); ymax = single(tMax * dy);
    end
end

function [Grid_Q, Grid_Std, Grid_Min, Grid_Max] = selectQGrids(param, ~, ~)
    Mapping = param.Mapping; QMapMet = param.QMapMet; ang = param.ang;
    
    if ang == 0 || ang == 180
        if strcmp(QMapMet, 'Qxy/Qz')
            TargetQ = single(param.Qr); TargetStd = single(param.Qr_std); TargetMin = single(param.Qrmin); TargetMax = single(param.Qrmax);
        else 
            TargetQ = single(param.Qy); TargetStd = single(param.Qy_std); TargetMin = single(param.Qymin); TargetMax = single(param.Qymax);
        end
        switch Mapping
            case {'Pixel', 'Alpha'}
                if param.zposmv == 0
                    Grid_Q = sign(TargetQ) .* single(param.Q);
                    if strcmp(QMapMet, 'Qxy/Qz')
                        QTotalMin = sqrt(single(param.Qrmin).^2 + single(param.Qzmin).^2); QTotalMax = sqrt(single(param.Qrmax).^2 + single(param.Qzmax).^2);
                    else
                        QTotalMin = sqrt(single(param.Qymin).^2 + single(param.Qzmin).^2); QTotalMax = sqrt(single(param.Qymax).^2 + single(param.Qzmax).^2);
                    end
                    Grid_Min = sign(TargetMin) .* QTotalMin; Grid_Max = sign(TargetMax) .* QTotalMax;
                else
                    Grid_Q = TargetQ; Grid_Min = TargetMin; Grid_Max = TargetMax;
                end
            case {'Qxy/Qz', 'Qy/Qz'}
                if param.zposmv == 0 && isfield(param, 'Q'), Grid_Q = sign(TargetQ) .* single(param.Q); else, Grid_Q = TargetQ; end
                Grid_Min = TargetMin; Grid_Max = TargetMax;
        end
        Grid_Std = TargetStd;

    elseif ang == 90 || ang == 270
        TargetQ = single(param.Qz); TargetStd = single(param.Qz_std);
        switch Mapping
            case {'Pixel', 'Alpha'}
                if param.yposmv == 0
                    Grid_Q = sign(TargetQ) .* single(param.Q);
                    QTotalMin = sqrt(single(param.Qrmin).^2 + single(param.Qzmin).^2); QTotalMax = sqrt(single(param.Qrmax).^2 + single(param.Qzmax).^2);
                    Grid_Min = sign(single(param.Qzmin)) .* QTotalMin; Grid_Max = sign(single(param.Qzmax)) .* QTotalMax;
                else
                    Grid_Q = TargetQ; Grid_Min = single(param.Qzmin); Grid_Max = single(param.Qzmax);
                end
            case {'Qxy/Qz', 'Qy/Qz'}
                if param.yposmv == 0 && isfield(param, 'Q'), Grid_Q = sign(TargetQ) .* single(param.Q); else, Grid_Q = TargetQ; end
                Grid_Min = single(param.Qzmin); Grid_Max = single(param.Qzmax);
        end
        Grid_Std = TargetStd;
    else
        Grid_Q = single(param.Q); Grid_Std = single(param.Q_std);
        if strcmp(QMapMet, 'Qxy/Qz')
            Grid_Min = sqrt(single(param.Qrmin).^2 + single(param.Qzmin).^2); Grid_Max = sqrt(single(param.Qrmax).^2 + single(param.Qzmax).^2);
        else
            Grid_Min = sqrt(single(param.Qymin).^2 + single(param.Qzmin).^2); Grid_Max = sqrt(single(param.Qymax).^2 + single(param.Qzmax).^2);
        end
    end
end

function linepos = getDrawLinePos(ang, ~, xmax, ~, ymax, param)
    if ang == 0 || ang == 180
        linepos = [0, fix(xmax), param.zposmv, param.zposmv];
    elseif ang == 90 || ang == 270
        linepos = [param.yposmv+eps, param.yposmv+eps, 0, fix(ymax)];
    else
        linepos = [0, fix(xmax), 0, fix(ymax)];
    end
end
