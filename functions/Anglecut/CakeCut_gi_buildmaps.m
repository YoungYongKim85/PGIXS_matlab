function [Qmap, AngMap] = CakeCut_gi_buildmaps(param, modeName)
    if nargin < 2 || isempty(modeName), modeName = 'Pixel'; end

    switch modeName
        case 'Pixel'
            Qmap = single(param.Q);
            [n, m] = size(Qmap);
            bpx = single(param.bpos(1));
            bpy = single(param.bpos(2));
            [Xg, Yg] = meshgrid(single(1:m), single(1:n));
            % image-polar: 왼쪽=0°, 위=90°, 오른쪽=180°
            ang = atan2d(-(Yg - bpy), -(Xg - bpx)); 
            AngMap = single(ang); % 하반부 강제 삭제 로직 제거 (전체 360도 보존)

        case 'Alpha'
            tth = single(param.tth(:)');
            af  = single(param.af(:));
            ai  = single(param.ai);
            lambda = single(param.Wavelength);
            k0 = 2*pi/lambda;

            [TTH, AF] = meshgrid(tth, af);
            af_lab = AF + ai;

            qy_lab = k0 * sind(TTH) .* cosd(af_lab);
            qz_lab = k0 * sind(af_lab);
            qx_lab = k0 * (cosd(TTH) .* cosd(af_lab) - 1);

            Qx_s = cosd(ai)*qx_lab + sind(ai)*qz_lab;
            Qy_s = qy_lab;
            Qz_s = -sind(ai)*qx_lab + cosd(ai)*qz_lab;

            Qr_s = sign(Qy_s) .* hypot(Qx_s, Qy_s);
            Qmap = single(hypot(Qr_s, Qz_s));

            ang = atan2d(AF, -TTH);
            AngMap = single(ang); % 하반부 강제 삭제 로직 제거

        case {'Qxy/Qz', 'Qy/Qz'}
            if strcmp(modeName, 'Qxy/Qz')
                xax = single(param.qr(:)'); yax = single(param.qz(:));
            else
                xax = single(param.qy(:)'); yax = single(param.qz(:));
            end
            [Xg, Yg] = meshgrid(xax, yax);
            Qmap = single(hypot(Xg, Yg));

            ang = atan2d(Yg, -Xg);
            AngMap = single(ang); % 하반부 강제 삭제 로직 제거

        otherwise
            error('CakeCut_gi_buildmaps: unknown mode "%s"', modeName);
    end
end