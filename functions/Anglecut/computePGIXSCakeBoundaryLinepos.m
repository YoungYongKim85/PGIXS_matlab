function linepos = computePGIXSCakeBoundaryLinepos(param, relativeAngle)
% computePGIXSCakeBoundaryLinepos  Best-effort display line for cake bounds.

    param_temp = param;
    angleForLine = mod(double(param.ang) + double(relativeAngle), 360);
    if angleForLine > 180
        angleForLine = 360 - angleForLine;
    end
    param_temp.ang = single(angleForLine);

    try
        [linepos, ~] = Anglecut1d_gi(param_temp);
    catch
        linepos = zeros(1, 4, 'single');
    end
end
