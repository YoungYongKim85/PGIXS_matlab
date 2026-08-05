function HeatmapQ_gui(param)
% HeatmapQ_gui_v2.3 (Modern UI Upgrade)
% - Unified viewer for GIXS & TrXS
% - Converted to uifigure, uigridlayout, uidropdown, uieditfield
% - Unchained all Layout property assignments

    % 1. 데이터 준비 (초기에 한 번만 수행)
    [plotData, plotLabels] = prepareData(param);
    [plotData, plotLabels] = normalizeHeatmapData(plotData, plotLabels, 'q index');
    
    % 데이터가 없으면 종료
    if isempty(plotData.I)
        errordlg('No Heatmap Data Available.', 'Data Error'); return;
    end

    % 2. 메인 프레임 생성 (모던 UI)
    mainF = uifigure('Name', ['Heatmap Analysis - ' param.FileName], ...
        'NumberTitle', 'off', 'Position', [200 150 1200 800], 'Color', [0.96 0.96 0.96]);

    % 메인 그리드 (위: 플롯 1x, 아래: 컨트롤 패널 90px 고정)
    mainGrid = uigridlayout(mainF, [2 1]);
    mainGrid.RowHeight = {'1x', 90};
    mainGrid.Padding = [10 10 10 10];
    mainGrid.RowSpacing = 10;

    % 3. 플롯 패널 구성
    plotPanel = uipanel(mainGrid, 'Title', 'Visualization', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w');
    plotPanel.Layout.Row = 1; 
    plotPanel.Layout.Column = 1;
    
    pGrid = uigridlayout(plotPanel, [1 1]);
    pGrid.Padding = [5 5 5 5];
    
    hAX1H = uiaxes(pGrid);
    hAX1H.Layout.Row = 1; 
    hAX1H.Layout.Column = 1;

    % 4. 컨트롤 패널 구성
    ctrlPanel = uipanel(mainGrid);
    ctrlPanel.Layout.Row = 2; 
    ctrlPanel.Layout.Column = 1;
    
    % 컨트롤 그리드 (2행 9열 배치)
    cGrid = uigridlayout(ctrlPanel, [2 9]);
    cGrid.RowHeight = {20, 25};
    cGrid.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1.5x', '1.5x', '1.5x', '1x'};
    cGrid.RowSpacing = 5; 
    cGrid.ColumnSpacing = 10;
    cGrid.Padding = [10 5 10 10];

    % 리스트 정의
    plotTypeList = {'Heatmap', 'Surf', 'Waterfall'};
    ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis','cubehelix','magma','kindlemann','ocean','jet2','rwb','rkb'};
    scaleList = {'linear', 'log'};

    % --- Row 1: Labels ---
    lbl1 = uilabel(cGrid, 'Text', 'Plot Type'); lbl1.Layout.Row = 1; lbl1.Layout.Column = 1;
    lbl2 = uilabel(cGrid, 'Text', 'Colormap');  lbl2.Layout.Row = 1; lbl2.Layout.Column = 2;
    lbl3 = uilabel(cGrid, 'Text', 'X Scale');   lbl3.Layout.Row = 1; lbl3.Layout.Column = 3;
    lbl4 = uilabel(cGrid, 'Text', 'Y Scale');   lbl4.Layout.Row = 1; lbl4.Layout.Column = 4;
    lbl5 = uilabel(cGrid, 'Text', 'Z Scale');   lbl5.Layout.Row = 1; lbl5.Layout.Column = 5;
    lbl6 = uilabel(cGrid, 'Text', 'X Range');   lbl6.Layout.Row = 1; lbl6.Layout.Column = 6;
    lbl7 = uilabel(cGrid, 'Text', 'Y Range (Q)'); lbl7.Layout.Row = 1; lbl7.Layout.Column = 7;
    lbl8 = uilabel(cGrid, 'Text', 'Contrast');  lbl8.Layout.Row = 1; lbl8.Layout.Column = 8;

    % --- Row 2: Controls ---
    hPlist = uidropdown(cGrid, 'Items', plotTypeList, 'ValueChangedFcn', @Updateplot_Callback);
    hPlist.Layout.Row = 2; hPlist.Layout.Column = 1;

    hColor = uidropdown(cGrid, 'Items', ColormapList, 'ValueChangedFcn', @Updateplot_Callback);
    hColor.Layout.Row = 2; hColor.Layout.Column = 2;
    if isfield(param, 'colorm') && any(strcmp(ColormapList, param.colorm))
        hColor.Value = param.colorm;
    else
        hColor.Value = 'jet';
    end

    hXScale = uidropdown(cGrid, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
    hXScale.Layout.Row = 2; hXScale.Layout.Column = 3;

    hYScale = uidropdown(cGrid, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
    hYScale.Layout.Row = 2; hYScale.Layout.Column = 4;

    hZScale = uidropdown(cGrid, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
    hZScale.Layout.Row = 2; hZScale.Layout.Column = 5;

    % Range Sub-grids (min, max edit fields side-by-side)
    subX = uigridlayout(cGrid, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 5);
    subX.Layout.Row = 2; subX.Layout.Column = 6;
    [xMin0, xMax0] = finiteRange(plotData.X, [1 2]);
    HM.xMin = uieditfield(subX, 'numeric', 'Value', xMin0, 'ValueChangedFcn', @Updateplot_Callback);
    HM.xMax = uieditfield(subX, 'numeric', 'Value', xMax0, 'ValueChangedFcn', @Updateplot_Callback);

    subY = uigridlayout(cGrid, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 5);
    subY.Layout.Row = 2; subY.Layout.Column = 7;
    [yMin0, yMax0] = finiteRange(plotData.Y, [1 2]);
    HM.yMin = uieditfield(subY, 'numeric', 'Value', yMin0, 'ValueChangedFcn', @Updateplot_Callback);
    HM.yMax = uieditfield(subY, 'numeric', 'Value', yMax0, 'ValueChangedFcn', @Updateplot_Callback);

    subC = uigridlayout(cGrid, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 5);
    subC.Layout.Row = 2; subC.Layout.Column = 8;
    [cMin0, cMax0] = finiteRange(plotData.I(:), [0 1]);
    HM.cMin = uieditfield(subC, 'numeric', 'Value', cMin0, 'ValueChangedFcn', @Updateplot_Callback);
    HM.cMax = uieditfield(subC, 'numeric', 'Value', cMax0, 'ValueChangedFcn', @Updateplot_Callback);

    % Save Button (Rowspan 1 to 2)
    btnSave = uibutton(cGrid, 'Text', 'Save Plot', 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @Saveplot_Callback);
    btnSave.Layout.Row = [1 2]; btnSave.Layout.Column = 9;

    % Initial Plot Draw
    Updateplot();

    % ====================================================================
    % Helper: Data Preparation & Label Logic
    % ====================================================================
    function [d, lbl] = prepareData(p)
        d.X = []; d.Y = []; d.I = [];
        lbl.X = ''; lbl.Y = 'q (A^{-1})'; lbl.Z = 'Intensity (a.u.)';
        
        if ~isfield(p, 'data1dstackN') || isempty(p.data1dstackN), return; end
        d.I = p.data1dstackN;
        
        if isfield(p, 'data1dstack') && ~isempty(p.data1dstack)
            d.Y = p.data1dstack(:,1);
        end
        
        [xAxis, xLabel, xUnit] = computePGIXSExperimentXAxis(p, inferHeatmapMode(p));
        if numel(xAxis) == size(d.I, 2)
            orderT = isfield(p, 'OrderT') && logical(p.OrderT);
            orderA = isfield(p, 'OrderA') && logical(p.OrderA);
            expmode = ''; if isfield(p, 'expmode'), expmode = p.expmode; end
            [d.X, idx] = sortPGIXSXAxis(xAxis, expmode, orderT, orderA);
            d.I = d.I(:, idx);
            lbl.X = formatAxisLabel(xLabel, xUnit);
        end
        
        if isfield(p, 'QMapMet') && isfield(p, 'ang')
            if p.ang == 0
                 if strcmp(p.QMapMet, 'Qxy/Qz'), lbl.Y = 'q_{xy} (A^{-1})';
                 else, lbl.Y = 'q_{y} (A^{-1})'; end
            elseif p.ang == 90
                 lbl.Y = 'q_{z} (A^{-1})';
            else
                 lbl.Y = 'q (A^{-1})';
            end
        else
            lbl.Y = 'q (A^{-1})';
        end
        
        if iscolumn(d.X), d.X = d.X'; end
        if isrow(d.Y), d.Y = d.Y'; end
    end

    function mode = inferHeatmapMode(p)
        mode = 'TrXS';
        if isfield(p, 'QMapMet') || isfield(p, 'Amode') || isfield(p, 'aivar') || ...
                (isfield(p, 'temperatureinfo') && size(p.temperatureinfo, 2) >= 3)
            mode = 'GIXS';
        end
    end

    function label = formatAxisLabel(axisLabel, axisUnit)
        label = axisLabel;
        if ~isempty(axisUnit)
            label = [axisLabel, ' (', axisUnit, ')'];
        end
    end

    function [d, lbl] = normalizeHeatmapData(d, lbl, defaultYLabel)
        if isempty(d.I), return; end
        nRows = size(d.I, 1);
        nCols = size(d.I, 2);
        if isempty(d.Y) || numel(d.Y) ~= nRows || ~any(isfinite(double(d.Y(:))))
            d.Y = (1:nRows)';
            lbl.Y = defaultYLabel;
        end
        if isempty(d.X) || numel(d.X) ~= nCols || ~any(isfinite(double(d.X(:))))
            d.X = 1:nCols;
            lbl.X = 'Frame (#)';
        end
        if iscolumn(d.X), d.X = d.X'; end
        if isrow(d.Y), d.Y = d.Y'; end
    end

    function [lo, hi] = finiteRange(values, fallback)
        vals = double(values(:));
        vals = vals(isfinite(vals));
        if isempty(vals)
            lo = fallback(1); hi = fallback(2);
        else
            lo = min(vals); hi = max(vals);
            if lo >= hi
                delta = max(abs(lo) * 0.01, 1);
                lo = lo - delta; hi = hi + delta;
            end
        end
    end

    function Updateplot_Callback(~,~), Updateplot; end

    function Updateplot
        if isempty(plotData.X) || isempty(plotData.Y), return; end
        
        plotTypeStr = hPlist.Value; 
        cMapName = hColor.Value;
        xSc = hXScale.Value;
        ySc = hYScale.Value;
        zSc = hZScale.Value;
        
        xLim = [HM.xMin.Value, HM.xMax.Value];
        yLim = [HM.yMin.Value, HM.yMax.Value];
        cLim = [HM.cMin.Value, HM.cMax.Value];
        
        % Ensure Limits are strictly ascending
        if xLim(1) >= xLim(2), xLim = [min(plotData.X), max(plotData.X)]; end
        if yLim(1) >= yLim(2), yLim = [min(plotData.Y), max(plotData.Y)]; end
        if cLim(1) >= cLim(2), cLim = [min(plotData.I(:),[],'omitnan'), max(plotData.I(:),[],'omitnan')]; end
        
        cla(hAX1H);
        
        Z_Data = plotData.I;
        isLogZ = strcmp(zSc, 'log');
        
        if isLogZ && strcmp(plotTypeStr, 'Heatmap')
            Z_Data(Z_Data <= 0) = NaN;
            Z_Data = log10(Z_Data);
            
            c_min = cLim(1); 
            c_max = cLim(2);
            
            % 원본 데이터(plotData.I)를 기준으로 0 이하 값 방어
            if c_min <= 0
                c_min = min(plotData.I(plotData.I > 0), [], 'omitnan'); 
            end
            if c_max <= 0 || c_max <= c_min
                c_max = max(plotData.I(:), [], 'omitnan');
                if c_max <= c_min, c_max = c_min * 10; end
            end
            if isempty(c_min) || isnan(c_min), c_min = 1; c_max = 10; end
            
            % 이미 복소수 위험을 없앤 양수값에만 1회 로그 적용
            cLim = [log10(c_min), log10(c_max)];
        end
        
        switch plotTypeStr
            case 'Heatmap'
                pcolor(hAX1H, plotData.X, plotData.Y, Z_Data); 
                shading(hAX1H, 'interp');
                view(hAX1H, 2); 
            case 'Surf'
                [XX, YY] = meshgrid(plotData.X, plotData.Y);
                surf(hAX1H, XX, YY, Z_Data, 'EdgeColor', 'none'); 
                view(hAX1H, 3); 
            case 'Waterfall'
                [XX, YY] = meshgrid(plotData.X, plotData.Y);
                hW = waterfall(hAX1H, XX', YY', Z_Data'); 
                cd = get(hW, 'CData');
                if size(cd,1) > 10, cd(1:5,:) = NaN; cd(end-4:end,:) = NaN; set(hW, 'CData', cd); end
                view(hAX1H, 3);
        end
        
        axis(hAX1H, 'tight');
        xlabel(hAX1H, plotLabels.X, 'Interpreter', 'tex', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel(hAX1H, plotLabels.Y, 'Interpreter', 'tex', 'FontSize', 12, 'FontWeight', 'bold');
        
        if isLogZ && strcmp(plotTypeStr, 'Heatmap')
            zlabel(hAX1H, ['Log(' plotLabels.Z ')'], 'Interpreter', 'tex', 'FontSize', 11);
        else
            zlabel(hAX1H, plotLabels.Z, 'Interpreter', 'tex', 'FontSize', 11); 
        end
        
        xlim(hAX1H, xLim); ylim(hAX1H, yLim); clim(hAX1H, cLim); 
        if ~strcmp(plotTypeStr, 'Heatmap'), zlim(hAX1H, cLim); end 
        
        set(hAX1H, 'XScale', xSc, 'YScale', ySc);
        set(hAX1H, 'YDir', 'reverse');
        if ~strcmp(plotTypeStr, 'Heatmap'), set(hAX1H, 'ZScale', zSc, 'ColorScale', zSc); end
        
        applyPGIXSColormap(hAX1H, cMapName, plotData.I);
        
        hcb = colorbar(hAX1H); hcb.LineWidth = 1.5;
        if isLogZ && strcmp(plotTypeStr, 'Heatmap')
            hcb.Label.String = ['Log_{10} [ ' plotLabels.Z ' ]'];
        else
            hcb.Label.String = plotLabels.Z; 
        end
        hcb.Label.Interpreter = 'tex';
        
        set(hAX1H, 'FontSize', 12, 'LineWidth', 1.5, 'TickDir', 'out', 'Box', 'on');
        title(hAX1H, param.FileName, 'Interpreter', 'none');
    end

    function Saveplot_Callback(~,~)
        [saveDir, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok
            uialert(mainF, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        
        curType = hPlist.Value;
        SFN = [param.FileName, '_1D_', curType];
        SaveFigurepath = fullfile(saveDir, [SFN, '.jpg']);
        
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX1H, SaveFigurepath, 300);
        if ~exportOK
            warning('PGIXS:FigureExportFailed', '%s', exportReport.Message);
        end
        uialert(mainF, ['Saved to: ' SaveFigurepath], 'Success');
    end
end
