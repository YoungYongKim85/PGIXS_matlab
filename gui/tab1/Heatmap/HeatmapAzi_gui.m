function HeatmapAzi_gui(param)
% HeatmapAzi_gui_v2.1 (Modern UI Upgrade & Bug Fixes)
% - Unified viewer for Azimuthal Stack Data (Angle vs Time/Temp)
% - Converted to uifigure, uigridlayout, uidropdown, uieditfield
% - Fixed: Absolute time (timestamp) to relative time conversion
% - Fixed: Z-Scale Log complex number error
% - Fixed: exportgraphics targeting specific uiaxes

    % 1. 데이터 준비 (초기에 한 번만 수행)
    [plotData, plotLabels] = prepareData(param);
    [plotData, plotLabels] = normalizeHeatmapData(plotData, plotLabels, 'Azimuthal index');
    
    if isempty(plotData.I)
        errordlg('No Azimuthal data found.', 'Data Error'); return;
    end

    % 2. 메인 프레임 생성 (모던 UI)
    mainF = uifigure('Name',['Azimuthal Heatmap - ' param.FileName],...
        'NumberTitle','off', 'Position',[200 150 1200 800], 'Color', [0.96 0.96 0.96]);

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
    lbl7 = uilabel(cGrid, 'Text', 'Y Range (Deg)'); lbl7.Layout.Row = 1; lbl7.Layout.Column = 7;
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
    % Helper: Data Preparation (Angle vs ExpVar)
    % ====================================================================
    function [d, lbl] = prepareData(p)
        d.X = []; d.Y = []; d.I = [];
        lbl.X = ''; lbl.Y = 'Azimuthal Angle (deg)'; lbl.Z = 'Intensity (a.u.)';
        
        if ~isfield(p, 'dataAzistackN') || isempty(p.dataAzistackN), return; end
        
        % Y-axis: Angle
        if isfield(p, 'dataAzistack') && ~isempty(p.dataAzistack)
            d.Y = p.dataAzistack(:,1);
        end
        
        % X-axis: Time or Temperature
        expmode = '';
        if isfield(p, 'expmode'), expmode = p.expmode; end
        switch expmode
            case 'Time'
                if isfield(p, 'timestampinfo')
                    t_unit = 's'; t_div = 1; t_offset = 1;
                    if isfield(p, 'TimeUnit')
                        switch p.TimeUnit
                            case 'second', t_unit = 's'; t_div = 1;
                            case 'min', t_unit = 'min'; t_div = 60;
                            case 'hour', t_unit = 'h'; t_div = 3600;
                        end
                    end
                    if isfield(p, 'TimeOffset')
                        t_offset = p.TimeOffset;
                    end
                    
                    % [버그 수정] 절대 시간(Epoch)을 첫 프레임 기준 상대 시간으로 변환
                    ts1 = p.timestampinfo(1);
                    d.X = ((p.timestampinfo - ts1) / t_div) + t_offset;
                    
                    lbl.X = ['Time (' t_unit ')'];
                    d.I = p.dataAzistackN;
                end
                
            case {'Temperature', 'LowTemp.'}
                if isfield(p, 'temperatureinfo')
                    if isfield(p, 'Tmode')
                        switch p.Tmode
                            case 'Temperature1', d.X = p.temperatureinfo(:,1);
                            case 'Temperature2', d.X = p.temperatureinfo(:,2);
                            case 'Temperature3', d.X = p.temperatureinfo(:,3);
                            case 'Time'
                                if isfield(p, 'timestampinfo') && ~isempty(p.timestampinfo)
                                    t_unit = 's'; t_div = 1; t_offset = 1;
                                    if isfield(p, 'TimeUnit')
                                        switch p.TimeUnit
                                            case 'second', t_unit = 's'; t_div = 1;
                                            case 'min', t_unit = 'min'; t_div = 60;
                                            case 'hour', t_unit = 'h'; t_div = 3600;
                                        end
                                    end
                                    if isfield(p, 'TimeOffset'), t_offset = p.TimeOffset; end
                                    ts1 = p.timestampinfo(1);
                                    d.X = ((p.timestampinfo - ts1) / t_div) + t_offset;
                                end
                        end
                    else
                        d.X = p.temperatureinfo(:,1);
                    end
                    
                    lbl.X = 'Temperature (^\circC)';
                    if isfield(p, 'Tmode') && strcmp(p.Tmode, 'Time')
                        if exist('t_unit', 'var')
                            lbl.X = ['Time (' t_unit ')'];
                        else
                            lbl.X = 'Frame (#)';
                        end
                    end
                    
                    if isfield(p, 'OrderT') && p.OrderT == 1
                        [d.X, idx] = sort(d.X);
                        d.I = p.dataAzistackN(:, idx);
                    else
                        d.I = p.dataAzistackN;
                    end
                end
        end
        
        if iscolumn(d.X), d.X = d.X'; end
        if isrow(d.Y), d.Y = d.Y'; end
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
        
        % [버그 수정] Z 스케일 로그 적용 시 음수/0 방어 및 단일 로그 적용
        if isLogZ && strcmp(plotTypeStr, 'Heatmap')
            Z_Data(Z_Data <= 0) = NaN;
            Z_Data = log10(Z_Data);
            
            c_min = cLim(1); 
            c_max = cLim(2);
            
            if c_min <= 0
                c_min = min(plotData.I(plotData.I > 0), [], 'omitnan'); 
            end
            if c_max <= 0 || c_max <= c_min
                c_max = max(plotData.I(:), [], 'omitnan');
                if c_max <= c_min, c_max = c_min * 10; end
            end
            if isempty(c_min) || isnan(c_min), c_min = 1; c_max = 10; end
            
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
        xlabel(hAX1H, plotLabels.X, 'FontSize', 12, 'FontWeight', 'bold');
        ylabel(hAX1H, plotLabels.Y, 'FontSize', 12, 'FontWeight', 'bold');
        
        if isLogZ && strcmp(plotTypeStr, 'Heatmap')
            zlabel(hAX1H, ['Log(' plotLabels.Z ')'], 'FontSize', 11);
        else
            zlabel(hAX1H, plotLabels.Z, 'FontSize', 11); 
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
        
        set(hAX1H, 'FontSize', 12, 'LineWidth', 1.5, 'TickDir', 'out', 'Box', 'on');
        title(hAX1H, [param.FileName ' (Azimuthal)'], 'Interpreter', 'none');
    end

    function Saveplot_Callback(~,~)
        [saveDir, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok
            uialert(mainF, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        
        curType = hPlist.Value;
        SFN = [param.FileName, '_AziHeatmap_', curType];
        SaveFigurepath = fullfile(saveDir, [SFN, '.jpg']);
        
        % [버그 수정] 특정 uiaxes 객체(hAX1H)를 타겟으로 내보내기
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX1H, SaveFigurepath, 300);
        if ~exportOK
            warning('PGIXS:FigureExportFailed', '%s', exportReport.Message);
        end
        uialert(mainF, ['Saved to: ' SaveFigurepath], 'Success');
    end
end
