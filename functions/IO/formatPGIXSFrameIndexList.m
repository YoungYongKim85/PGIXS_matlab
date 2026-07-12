function text = formatPGIXSFrameIndexList(frames, maxCount)
% formatPGIXSFrameIndexList  Format frame indices for compact UI messages.

    if nargin < 2 || isempty(maxCount)
        maxCount = 20;
    end

    frames = frames(:)';
    frames = frames(isfinite(frames));
    if isempty(frames)
        text = 'none';
        return;
    end

    nShow = min(numel(frames), maxCount);
    shown = frames(1:nShow);
    parts = arrayfun(@(x) sprintf('%g', x), shown, 'UniformOutput', false);
    text = strjoin(parts, ', ');

    nMore = numel(frames) - nShow;
    if nMore > 0
        text = sprintf('%s, ... (+%d more)', text, nMore);
    end
end
