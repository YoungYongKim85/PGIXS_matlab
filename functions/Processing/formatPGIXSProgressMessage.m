function message = formatPGIXSProgressMessage(done, total, elapsedSeconds)
% formatPGIXSProgressMessage  Format progress, rate, elapsed time, and ETA.

    done = max(0, double(done));
    total = max(0, double(total));
    elapsedSeconds = double(elapsedSeconds);

    if done <= 0
        message = sprintf('Loaded 0 / %d  (preparing...)', total);
        return;
    end
    if done >= total
        message = sprintf('Loaded %d / %d  (elapsed %s)', done, total, formatPGIXSDuration(elapsedSeconds));
        return;
    end

    perItem = elapsedSeconds / done;
    remainingSeconds = perItem * (total - done);
    rate = done / max(elapsedSeconds, eps);
    message = sprintf('Loaded %d / %d  |  %.1f files/s  |  elapsed %s  |  ETA %s', ...
        done, total, rate, formatPGIXSDuration(elapsedSeconds), formatPGIXSDuration(remainingSeconds));
end

function text = formatPGIXSDuration(seconds)
    if ~isfinite(seconds) || seconds < 0
        text = '--';
    elseif seconds < 60
        text = sprintf('%.0fs', seconds);
    elseif seconds < 3600
        minutes = floor(seconds / 60);
        secondsPart = round(mod(seconds, 60));
        if secondsPart == 60
            minutes = minutes + 1;
            secondsPart = 0;
        end
        text = sprintf('%dm %02ds', minutes, secondsPart);
    else
        hours = floor(seconds / 3600);
        minutes = floor(mod(seconds, 3600) / 60);
        text = sprintf('%dh %02dm', hours, minutes);
    end
end
