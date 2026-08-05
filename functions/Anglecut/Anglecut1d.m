function [linepos, line1d] = Anglecut1d(param, imgData)
% Anglecut1d - Optimized Ray Cut for TrXS (Center to Edge)
% 1. Start from Beam Center (no yposmv/zposmv needed)
% 2. Full 360-degree support
% 3. Support for Stack processing (imgData arg)

    % [1] Data Preparation
    if nargin < 2
        if isfield(param, 'Mapping')
            switch param.Mapping
                case 'Pixel', data2d = single(param.data);
                case 'Qy/Qz', data2d = single(param.Itrans);
                otherwise,    data2d = single(param.data);
            end
        else
            data2d = single(param.data);
        end
    else
        data2d = single(imgData);
    end

    % Gap-adjacent pixels bordering the masked detector gap can carry
    % biased counts; exclude a 3-pixel shoulder (measured to cover most
    % of the edge bias on real data) so it does not bleed into the
    % bilinear interpolation below. Only applies in detector-pixel space
    % (skipped for Q-remapped Itrans, which already handles gap/edge
    % NaNs).
    if isfield(param, 'Mask') && isequal(size(param.Mask), size(data2d))
        data2d(dilatePGIXSGapMask(param.Mask, 3)) = NaN;
    end

    [n, m] = size(data2d);
    bx = single(param.bpos(1));
    by = single(param.bpos(2));
    
    % [2] Calculate Line Endpoints (Intersection Method)
    ang = mod(param.ang, 360); % 0~360 normalize
    
    % Direction Vector (0 = Left, 90 = Up in pixel space)
    vx = -cosd(ang); 
    vy = -sind(ang); 
    
    % Ray starts exactly at Beam Center (TrXS requirement)
    x0 = bx;
    y0 = by;
    
    % Find intersection with image boundaries
    t_max = 1e6;
    if vx > 1e-6,      t_max = min(t_max, (m - x0) / vx);
    elseif vx < -1e-6, t_max = min(t_max, (1 - x0) / vx); end
    if vy > 1e-6,      t_max = min(t_max, (n - y0) / vy);
    elseif vy < -1e-6, t_max = min(t_max, (1 - y0) / vy); end
    
    % Generate Query Points
    nPoints = ceil(t_max);
    if nPoints < 2
        linepos = zeros(1,4,'single'); line1d = zeros(0,3,'single'); return;
    end
    
    t = linspace(0, t_max, nPoints);
    xq = x0 + t*vx;
    yq = y0 + t*vy;
    
    % [3] Fast Interpolation
    [X, Y] = meshgrid(single(1:m), single(1:n));
    zq = interp2(X, Y, data2d, xq, yq, 'linear');
    
    % [4] Distance & Q calculation
    dq = sqrt((xq - bx).^2 + (yq - by).^2); 
    
    if isfield(param, 'Q') && ~isempty(param.Q)
        qq = interp2(X, Y, single(param.Q), xq, yq, 'linear');
    else
        qq = dq; 
    end
    
    % [5] Pack Results
    linepos = zeros(1, 4, 'single');
    linepos(1) = x0; linepos(2) = xq(end);
    linepos(3) = y0; linepos(4) = yq(end);
    
    % Keep detector gaps as NaN intensity values instead of dropping rows.
    % Series line cuts depend on a stable axis length across frames.
    valid = isfinite(dq) & isfinite(qq);
    dq = dq(valid); qq = qq(valid); zq = zq(valid);
    
    line1d = zeros(length(dq), 3, 'single');
    line1d(:,1) = single(dq(:));
    line1d(:,2) = single(qq(:));
    line1d(:,3) = single(zq(:));
end
