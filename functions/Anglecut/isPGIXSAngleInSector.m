function mask = isPGIXSAngleInSector(angleDiff, startAngle, finishAngle)
% isPGIXSAngleInSector  Select relative angles, including +/-180 wrap.

    angleDiff = normalizeAngle180(angleDiff);

    if ~isfinite(startAngle) || ~isfinite(finishAngle)
        mask = false(size(angleDiff));
        return;
    end

    if abs(double(finishAngle) - double(startAngle)) >= 360
        mask = isfinite(angleDiff);
        return;
    end

    startAngle = normalizeAngle180(startAngle);
    finishAngle = normalizeAngle180(finishAngle);

    if startAngle <= finishAngle
        mask = isfinite(angleDiff) & angleDiff >= startAngle & angleDiff <= finishAngle;
    else
        mask = isfinite(angleDiff) & (angleDiff >= startAngle | angleDiff <= finishAngle);
    end
end

function angle = normalizeAngle180(angle)
    angle = mod(double(angle) + 180, 360) - 180;
end
