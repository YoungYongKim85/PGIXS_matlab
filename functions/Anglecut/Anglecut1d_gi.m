% 1d line cut function - OPTIMIZED VERSION
function [linepos, line1d] = Anglecut1d_gi(param)

if isfield(param, 'Mapping')
    switch param.Mapping
        case 'Pixel',  data2d = single(param.data);
        case 'Alpha',  data2d = single(param.AlphaMap);
        case 'Qxy/Qz', data2d = single(param.Itrans);
        case 'Qy/Qz',  data2d = single(param.Itrans);
    end
else
    data2d = single(param.Stack(:,:,1));
end

% Gap-adjacent pixels bordering the masked detector gap can carry biased
% counts; exclude a 3-pixel shoulder (measured to cover most of the edge
% bias on real data) so it does not bleed into the bilinear interpolation
% below. Only applies in detector-pixel space (skipped for Q-remapped
% Itrans, which already handles gap/edge NaNs).
if isfield(param, 'Mask') && isequal(size(param.Mask), size(data2d))
    data2d(dilatePGIXSGapMask(param.Mask, 3)) = NaN;
end

[n, m] = size(data2d);
beampos_x = fix(param.bpos(1));
beampos_y = fix(param.bpos(2));

x = single((1:m) - beampos_x);
y = single(-((1:n) - beampos_y));

bval = ceil(sqrt(single(m)^2 + single(n)^2));
ang = param.ang;

% [2] Calculate line coordinates (ALL Rays: Starts from 0)
if ang > 0 && ang < 90
    tanAng = single(tand(ang)); y2 = -x * tanAng;
    valid = (x < 0) & (y2 > min(y)) & (y2 <= max(y));
    validIdx = find(valid, 1, 'first');
    if isempty(validIdx), linepos = zeros(1, 4, 'single'); line1d = zeros(0, 3, 'single'); return; end
    xmin = 0; xmax = x(validIdx); ymin = 0; ymax = y2(validIdx);
elseif ang == 90
    xmin = single(param.yposmv + eps); xmax = xmin;
    ymin = 0; ymax = max(y);
elseif ang > 90 && ang < 180
    tanAng = single(tand(ang)); y2 = -x * tanAng;
    valid = (x > 0) & (y2 > min(y)) & (y2 <= max(y));
    validIdx = find(valid, 1, 'last');
    if isempty(validIdx), linepos = zeros(1, 4, 'single'); line1d = zeros(0, 3, 'single'); return; end
    xmin = 0; xmax = x(validIdx); ymin = 0; ymax = y2(validIdx);
elseif ang == 0
    y2val = single(param.zposmv);
    xmin = 0; xmax = min(x); ymin = y2val; ymax = y2val;
elseif ang == 180
    y2val = single(param.zposmv);
    xmin = 0; xmax = max(x); ymin = y2val; ymax = y2val;
end

xq = linspace(xmin, xmax, bval);
yq = linspace(ymin, ymax, bval);

[X, Y] = meshgrid(x, y);
zq = interp2(X, Y, data2d, xq, yq, 'linear');

dq = sqrt(xq.^2 + yq.^2);
qq = calculateQValues(param, x, y, xq, yq, ang);

if ang == 0
    qq = abs(qq); % 1D Plot 방향 통일
end

linepos = calculateLinePos(ang, xmin, xmax, ymin, ymax, param);

validIdx2 = ~isnan(zq);
dq = dq(validIdx2); qq = qq(validIdx2); zq = zq(validIdx2);

line1d = zeros(length(dq), 3, 'single');
line1d(:,1) = single(dq(:)); line1d(:,2) = single(qq(:)); line1d(:,3) = single(zq(:));

end

function qq = calculateQValues(param, x, y, xq, yq, ang)
    if ang == 0 || ang == 180
        qq = calcQ_Horizontal(param, x, y, xq, yq);
    elseif ang == 90
        qq = calcQ_Vertical(param, x, y, xq, yq);
    else
        qq = calcQ_Diagonal(param, x, y, xq, yq);
    end
end

function qq = calcQ_Horizontal(param, x, y, xq, yq)
    switch param.QMapMet
        case 'Qxy/Qz'
            if isfield(param, 'Mapping')
                switch param.Mapping
                    case {'Pixel', 'Alpha'}
                        if param.zposmv == 0, Qdata = single(sign(param.Qr) .* param.Q); else, Qdata = single(param.Qr); end
                    case 'Qxy/Qz'
                        [Qr, ~] = meshgrid(single(param.qr), single(param.qz));
                        Q = sqrt(Qr.^2 + meshgrid(single(param.qz), single(param.qr))'.^2);
                        if param.zposmv == 0, Qdata = sign(Qr) .* Q; else, Qdata = Qr; end
                end
            else
                qq = zeros(size(xq), 'single'); return
            end
        case 'Qy/Qz'
            if isfield(param, 'Mapping')
                switch param.Mapping
                    case {'Pixel', 'Alpha'}
                        if param.zposmv == 0, Qdata = single(sign(param.Qy) .* param.Q); else, Qdata = single(param.Qy); end
                    case 'Qy/Qz'
                        [Qy, Qz] = meshgrid(single(param.qy), single(param.qz));
                        Q = sqrt(Qy.^2 + Qz.^2);
                        if param.zposmv == 0, Qdata = sign(Qy) .* Q; else, Qdata = Qy; end
                end
            else
                qq = zeros(size(xq), 'single'); return
            end
    end
    qq = interp2(x, y, Qdata, xq, yq, 'linear');
end

function qq = calcQ_Vertical(param, x, y, xq, yq)
    if isfield(param, 'Mapping')
        switch param.Mapping
            case {'Pixel', 'Alpha'}
                if param.yposmv == 0, Qdata = single(sign(param.Qz) .* param.Q); else, Qdata = single(param.Qz); end
            case {'Qxy/Qz', 'Qy/Qz'}
                if strcmp(param.Mapping, 'Qxy/Qz'), [~, Qz] = meshgrid(single(param.qr), single(param.qz));
                else, [~, Qz] = meshgrid(single(param.qy), single(param.qz)); end
                if param.yposmv == 0, Qdata = sign(Qz) .* abs(Qz); else, Qdata = Qz; end
        end
    else
        qq = zeros(size(xq), 'single'); return
    end
    qq = interp2(x, y, Qdata, xq, yq, 'linear');
end

function qq = calcQ_Diagonal(param, x, y, xq, yq)
    if isfield(param, 'Mapping')
        switch param.Mapping
            case {'Pixel', 'Alpha'}
                Qdata = single(param.Q); if ndims(Qdata) == 3, Qdata = Qdata(:,:,1); end
            case {'Qxy/Qz', 'Qy/Qz'}
                if strcmp(param.Mapping, 'Qxy/Qz'), [Qr, Qz] = meshgrid(single(param.qr), single(param.qz));
                else, [Qr, Qz] = meshgrid(single(param.qy), single(param.qz)); end
                Qdata = sqrt(Qr.^2 + Qz.^2);
        end
    else
        qq = zeros(size(xq), 'single'); return
    end
    qq = interp2(x, y, Qdata, xq, yq, 'linear');
end

function linepos = calculateLinePos(ang, ~, xmax, ~, ymax, param)
    linepos = zeros(1, 4, 'single');
    if ang == 0 || ang == 180
        linepos(1) = 0; linepos(2) = fix(xmax); linepos(3) = param.zposmv; linepos(4) = param.zposmv;
    elseif ang == 90
        linepos(1) = param.yposmv + eps; linepos(2) = param.yposmv + eps; linepos(3) = 0; linepos(4) = fix(ymax);
    else
        linepos(1) = 0; linepos(2) = fix(xmax); linepos(3) = 0; linepos(4) = fix(ymax); 
    end
end
