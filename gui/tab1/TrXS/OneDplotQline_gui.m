function OneDplotQline_gui(param, parentFig)
% OneDplotQline_gui v2.1 - 1D Line Plot Viewer (Modern UI)
% Upgraded By Y.Y.Kim
% FIXED: Typo in uibutton corrected, added robust NaN handling for initialization.
% parentFig: 부모 figure 핸들 (포커스 복원용, 옵션)

    if nargin < 2, parentFig = []; end

    %% ==================== GUI Setup ====================
    GUI.mainF = uifigure('Name','1D Line Plot Viewer v2.1',...
        'NumberTitle','off', 'Position',[150 150 1000 650], ...
        'Color', [0.96 0.96 0.96], ...
        'CloseRequestFcn', @CloseFig_Callback);

    movegui(GUI.mainF, 'center');

    mainGrid = uigridlayout(GUI.mainF, [1 2]);
    mainGrid.ColumnWidth = {'1x', 320};
    mainGrid.Padding = [10 10 10 10];
    mainGrid.ColumnSpacing = 15;

    % --- Left Panel: Plot ---
    plotPanel = uipanel(mainGrid, 'Title', '1D Line Plot Viewer', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'w');
    plotPanel.Layout.Row = 1; plotPanel.Layout.Column = 1;
    
    pg = uigridlayout(plotPanel, [1 1]);
    hAX1 = uiaxes(pg);

    % --- Right Panel: Controls ---
    ctrlPanel = uipanel(mainGrid, 'Title', 'Controls & Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    ctrlPanel.Layout.Row = 1; ctrlPanel.Layout.Column = 2;

    % 18행 2열의 세밀한 그리드 시스템 (잘림 방지)
    cg = uigridlayout(ctrlPanel, [18 2]);
    cg.RowHeight = num2cell(repmat(25, 1, 18));
    cg.ColumnWidth = {'1x', '1x'};
    cg.Padding = [10 10 10 10];
    cg.RowSpacing = 5;

    %% ==================== UI Controls ====================
    % [1] Plot Settings
    lbl1 = uilabel(cg, 'Text', 'Plot Unit:'); 
    lbl1.Layout.Row = 1; lbl1.Layout.Column = 1;
    PixQList = {'Pixel', 'Q'};
    GUI.hPixOrQ = uidropdown(cg, 'Items', PixQList, 'Value', 'Q', 'ValueChangedFcn', @Rangecal_Callback);
    GUI.hPixOrQ.Layout.Row = 1; GUI.hPixOrQ.Layout.Column = 2;

    lbl2 = uilabel(cg, 'Text', 'Q Unit:'); 
    lbl2.Layout.Row = 2; lbl2.Layout.Column = 1;
    unitList = {'A^{-1}', 'nm^{-1}'};
    GUI.hQunit = uidropdown(cg, 'Items', unitList, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hQunit.Layout.Row = 2; GUI.hQunit.Layout.Column = 2;

    lbl3 = uilabel(cg, 'Text', 'Scale:'); 
    lbl3.Layout.Row = 3; lbl3.Layout.Column = 1;
    scaleList = {'Linear', 'Logy', 'Logxy'};
    GUI.hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hScale.Layout.Row = 3; GUI.hScale.Layout.Column = 2;

    % [2] Style & Color
    lbl4 = uilabel(cg, 'Text', 'Line Style:'); 
    lbl4.Layout.Row = 4; lbl4.Layout.Column = 1;
    styleList = {'-', '--', ':', '-.', '-o'};
    GUI.hLineStyle = uidropdown(cg, 'Items', styleList, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hLineStyle.Layout.Row = 4; GUI.hLineStyle.Layout.Column = 2;

    lbl5 = uilabel(cg, 'Text', 'Color:'); 
    lbl5.Layout.Row = 5; lbl5.Layout.Column = 1;
    colorList = {'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
    colorCodes = {'k', 'r', 'g', 'b', 'c', 'm', 'y'};
    GUI.hColorStyle = uidropdown(cg, 'Items', colorList, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hColorStyle.Layout.Row = 5; GUI.hColorStyle.Layout.Column = 2;

    % [3] Ranges
    lbl6 = uilabel(cg, 'Text', 'X-Range (Min/Max):'); 
    lbl6.Layout.Row = 6; lbl6.Layout.Column = 1;
    subX = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 5);
    subX.Layout.Row = 6; subX.Layout.Column = 2;
    GUI.xpixMin = uieditfield(subX, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.xpixMax = uieditfield(subX, 'numeric', 'Value', 1000, 'ValueChangedFcn', @Updateplot_Callback);

    lbl7 = uilabel(cg, 'Text', 'Y-Range (Min/Max):'); 
    lbl7.Layout.Row = 7; lbl7.Layout.Column = 1;
    subY = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 5);
    subY.Layout.Row = 7; subY.Layout.Column = 2;
    GUI.yIMin = uieditfield(subY, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.yIMax = uieditfield(subY, 'numeric', 'Value', 1e6, 'ValueChangedFcn', @Updateplot_Callback);

    % [4] Update & Grid
    GUI.hGridCheck = uicheckbox(cg, 'Text', 'Grid On', 'Value', 0, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hGridCheck.Layout.Row = 8; GUI.hGridCheck.Layout.Column = 1;
    
    % 오타(uibibutton -> uibutton) 완벽 수정!
    btnUpdate = uibutton(cg, 'Text', 'Update Plot', 'FontWeight', 'bold', 'ButtonPushedFcn', @Updateplot_Callback);
    btnUpdate.Layout.Row = 8; btnUpdate.Layout.Column = 2;

    % --- Divider ---
    lblDiv1 = uilabel(cg, 'Text', '--- [ Peak Analysis ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    lblDiv1.Layout.Row = 9; lblDiv1.Layout.Column = [1 2];

    % [5] Analysis 1: D-Spacing & Peak Ratio
    btnDcal = uibutton(cg, 'Text', 'D Cal. (Click)', 'ButtonPushedFcn', @Dcal_Callback);
    btnDcal.Layout.Row = 10; btnDcal.Layout.Column = 1;
    GUI.DSP = uieditfield(cg, 'numeric', 'Value', 1);
    GUI.DSP.Layout.Row = 10; GUI.DSP.Layout.Column = 2;

    lbl8 = uilabel(cg, 'Text', 'Peak Ratio:'); 
    lbl8.Layout.Row = 11; lbl8.Layout.Column = 1;
    PeakRatioList = {'single', 'Layer', 'cubic','fcc', 'bcc', 'Pn3m', 'Ia3d', 'Hexagonal'};
    GUI.hPeakRatio = uidropdown(cg, 'Items', PeakRatioList);
    GUI.hPeakRatio.Layout.Row = 11; GUI.hPeakRatio.Layout.Column = 2;

    btnPlotRatio = uibutton(cg, 'Text', 'Plot Ratio Line', 'ButtonPushedFcn', @Analplot1_Callback);
    btnPlotRatio.Layout.Row = 12; btnPlotRatio.Layout.Column = [1 2];

    % --- Divider ---
    lblDiv2 = uilabel(cg, 'Text', '--- [ Gaussian Fit ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    lblDiv2.Layout.Row = 13; lblDiv2.Layout.Column = [1 2];

    % [6] Analysis 2: Fitting
    btnPos = uibutton(cg, 'Text', 'Pos Cal. (Click)', 'ButtonPushedFcn', @Poscal_Callback);
    btnPos.Layout.Row = 14; btnPos.Layout.Column = 1;
    GUI.QPOS = uieditfield(cg, 'numeric', 'Value', 1);
    GUI.QPOS.Layout.Row = 14; GUI.QPOS.Layout.Column = 2;

    lbl9 = uilabel(cg, 'Text', 'Fit Range (Data Pts):'); 
    lbl9.Layout.Row = 15; lbl9.Layout.Column = 1;
    GUI.PXRange = uieditfield(cg, 'numeric', 'Value', 50);
    GUI.PXRange.Layout.Row = 15; GUI.PXRange.Layout.Column = 2;

    btnFit = uibutton(cg, 'Text', 'Run Gaussian Fit', 'BackgroundColor', [0.85 0.9 0.85], 'FontWeight', 'bold', 'ButtonPushedFcn', @PreSelect_Callback);
    btnFit.Layout.Row = 16; btnFit.Layout.Column = [1 2];

    % --- Divider ---
    lblDiv3 = uilabel(cg, 'Text', '--- [ Export Data ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    lblDiv3.Layout.Row = 17; lblDiv3.Layout.Column = [1 2];

    % [7] Save
    SFormList = {'.mat', '.sdt', '.dat', '.txt', '.csv'};
    GUI.hSForm = uidropdown(cg, 'Items', SFormList, 'Value', '.dat');
    GUI.hSForm.Layout.Row = 18; GUI.hSForm.Layout.Column = 1;

    btnSave = uibutton(cg, 'Text', 'Save Data & Plot', 'BackgroundColor', [0.9 0.95 1], 'FontWeight', 'bold', 'ButtonPushedFcn', @Saveplot_Callback);
    btnSave.Layout.Row = 18; btnSave.Layout.Column = 2;

    %% ==================== Peak Ratio Structure ====================
    PeakRatioData.single = struct('ratio', 1, 'labels', {{'$1$'}});
    PeakRatioData.Layer = struct('ratio', 1:5, 'labels', {{'$1$','$2$','$3$','$4$','$5$'}});
    PeakRatioData.cubic = struct('ratio', sqrt(1:5), 'labels', {{'$1$','$\sqrt{2}$','$\sqrt{3}$','$\sqrt{4}$','$\sqrt{5}$'}});
    PeakRatioData.bcc = struct('ratio', sqrt([2,4,6,8,10]), 'labels', {{'$\sqrt{2}$','$\sqrt{4}$','$\sqrt{6}$','$\sqrt{8}$','$\sqrt{10}$'}});
    PeakRatioData.fcc = struct('ratio', sqrt([3,4,8,11,12]), 'labels', {{'$\sqrt{3}$','$\sqrt{4}$','$\sqrt{8}$','$\sqrt{11}$','$\sqrt{12}$'}});
    PeakRatioData.Pn3m = struct('ratio', sqrt([2,3,4,6,8]), 'labels', {{'$\sqrt{2}$','$\sqrt{3}$','$\sqrt{4}$','$\sqrt{6}$','$\sqrt{8}$'}});
    PeakRatioData.Ia3d = struct('ratio', sqrt([6,8,14,16,18]), 'labels', {{'$\sqrt{6}$','$\sqrt{8}$','$\sqrt{14}$','$\sqrt{16}$','$\sqrt{18}$'}});
    PeakRatioData.Hexagonal = struct('ratio', [1, sqrt(3), 2, sqrt(7), 3], 'labels', {{'$1$','$\sqrt{3}$','$\sqrt{4}$','$\sqrt{7}$','$\sqrt{9}$'}});

    %% ==================== Initialize Data ====================
    inputparam.ang = double(param.ang);
    inputparam.pixPlot = double(param.line1dang(:,1));
    inputparam.Q1d = double(param.line1dang(:,2));
    inputparam.data = double(param.line1dang(:,3));

    % 초기 범위 세팅 (NaN 에러 방지 처리 완벽 적용)
    valXmin = min(inputparam.Q1d, [], 'omitnan');
    if isempty(valXmin) || isnan(valXmin), valXmin = 0; end
    GUI.xpixMin.Value = double(valXmin);
    
    valXmax = max(inputparam.Q1d, [], 'omitnan');
    if isempty(valXmax) || isnan(valXmax), valXmax = 1000; end
    GUI.xpixMax.Value = double(valXmax);
    
    valYmin = min(inputparam.data(inputparam.data > 0), [], 'omitnan');
    if isempty(valYmin) || isnan(valYmin), valYmin = 1; end
    GUI.yIMin.Value = double(valYmin);
    
    valYmax = max(inputparam.data, [], 'omitnan');
    if isempty(valYmax) || isnan(valYmax), valYmax = 1e6; end
    GUI.yIMax.Value = double(valYmax);

    updatePlot();

    %% ==================== Helper Functions ====================
    function p = getParams()
        p.PixOrQ = GUI.hPixOrQ.Value;
        p.Qunit = GUI.hQunit.Value;
        p.plotscale = GUI.hScale.Value;
        p.linestyle = GUI.hLineStyle.Value;
        
        colorMatch = strcmp(colorList, GUI.hColorStyle.Value);
        if any(colorMatch)
            p.linecolor = colorCodes{colorMatch};
        else
            p.linecolor = 'k';
        end
        
        p.grid = GUI.hGridCheck.Value;
        p.xmin = GUI.xpixMin.Value;
        p.xmax = GUI.xpixMax.Value;
        p.ymin = GUI.yIMin.Value;
        p.ymax = GUI.yIMax.Value;
    end

    function [Qval, unitStr] = getQval(Qin, unit)
        if strcmp(unit, 'nm^{-1}')
            Qval = Qin .* 10; unitStr = 'nm^{-1}';
        else
            Qval = Qin; unitStr = 'A^{-1}'; 
        end
    end

    function setAxisFormat(ax, p)
        set(ax, 'FontSize', 13, 'FontName', 'times', 'LineWidth', 1.5, 'TickDir', 'in');
        if p.grid, grid(ax, 'on'); else, grid(ax, 'off'); end
        
        switch p.plotscale
            case 'Linear', set(ax, 'YScale', 'linear', 'XScale', 'linear');
            case 'Logy', set(ax, 'YScale', 'log', 'XScale', 'linear');
            case 'Logxy', set(ax, 'YScale', 'log', 'XScale', 'log');
        end
        
        if p.xmax > p.xmin, xlim(ax, [p.xmin, p.xmax]); end
        if p.ymax > p.ymin, ylim(ax, [p.ymin, p.ymax]); end
        
        ylabel(ax, 'Intensity, arb. units');
        if strcmp(p.PixOrQ, 'Pixel')
            xlabel(ax, 'Pixel');
        else
            if strcmp(p.Qunit, 'A^{-1}')
                xlabel(ax, 'q, A^{-1}','Interpreter','tex');
            else
                xlabel(ax, '$q, \textrm{nm}^{-1}$','Interpreter','latex');
            end
        end
    end

    %% ==================== Callbacks ====================
    function Rangecal_Callback(~,~)
        if strcmp(GUI.hPixOrQ.Value, 'Pixel')
            GUI.xpixMin.Value = min(inputparam.pixPlot, [], 'omitnan');
            GUI.xpixMax.Value = max(inputparam.pixPlot, [], 'omitnan');
        else
            GUI.xpixMin.Value = min(inputparam.Q1d, [], 'omitnan');
            GUI.xpixMax.Value = max(inputparam.Q1d, [], 'omitnan');
        end
        updatePlot();
    end

    function Updateplot_Callback(~,~), updatePlot(); end

    function updatePlot(~,~)
        p = getParams();
        cla(hAX1); 
        
        if strcmp(p.PixOrQ, 'Pixel')
            X = inputparam.pixPlot; Y = inputparam.data;
        else
            [Qval, ~] = getQval(inputparam.Q1d, p.Qunit);
            X = Qval; Y = inputparam.data;
        end
        
        plot(hAX1, X, Y, p.linestyle, 'Color', p.linecolor, 'LineWidth', 1.5);
        setAxisFormat(hAX1, p);
    end

    function Dcal_Callback(~,~)
        p = getParams();
        if strcmp(p.PixOrQ, 'Pixel'), uialert(GUI.mainF, 'Change to Q axis first!', 'Warning'); return; end
        
        tempFig = figure('Name', 'Click to Calculate D-spacing', 'MenuBar', 'none', 'ToolBar', 'none');
        tempAx = axes(tempFig);
        
        [Qval, uStr] = getQval(inputparam.Q1d, p.Qunit);
        plot(tempAx, Qval, inputparam.data, p.linestyle, 'Color', p.linecolor, 'LineWidth', 1.5);
        
        setAxisFormat(tempAx, p);
        title(tempAx, 'Click to select the Q position for D-spacing calculation.', 'FontSize', 12);
        
        [x, ~] = ginput(1);
        if ishandle(tempFig), close(tempFig); end
        
        if ~isempty(x)
            D = 2*pi/x;
            uialert(GUI.mainF, sprintf('Selected Q: %.4f %s\nCalculated D: %.4f %s', x, uStr, D, uStr), 'D-Spacing Result', 'Icon', 'info');
            GUI.DSP.Value = D;
        end
    end

    function Analplot1_Callback(~,~)
        D = GUI.DSP.Value;
        PRatio = GUI.hPeakRatio.Value;
        p = getParams();
        
        if strcmp(p.PixOrQ, 'Pixel'), uialert(GUI.mainF, 'Use Q units for peak ratio!', 'Warning'); return; end
        ratioData = PeakRatioData.(PRatio);
        qpos = 2*pi/D .* ratioData.ratio;
        
        updatePlot(); 
        hold(hAX1, 'on');
        
        for i=1:length(qpos)
            xline(hAX1, qpos(i), '--r', 'LineWidth', 1.5);
            text(hAX1, qpos(i), p.ymax * 0.95, ratioData.labels{i}, 'Interpreter','latex','HorizontalAlignment','center','FontSize',14, 'Color', 'r');
        end
        hold(hAX1, 'off');
    end

    function Poscal_Callback(~,~)
        p = getParams();
        if strcmp(p.PixOrQ, 'Pixel'), uialert(GUI.mainF, 'Change to Q axis first!', 'Warning'); return; end
        
        tempFig = figure('Name', 'Click to Select Q Position', 'MenuBar', 'none', 'ToolBar', 'none');
        tempAx = axes(tempFig);
        
        [Qval, ~] = getQval(inputparam.Q1d, p.Qunit);
        plot(tempAx, Qval, inputparam.data, p.linestyle, 'Color', p.linecolor, 'LineWidth', 1.5);
        
        setAxisFormat(tempAx, p);
        title(tempAx, 'Click to select the center Q position for Gaussian fitting.', 'FontSize', 12);
        
        [x, ~] = ginput(1);
        if ishandle(tempFig), close(tempFig); end
        
        if ~isempty(x)
            GUI.QPOS.Value = x;
        end
    end

    function PreSelect_Callback(~,~)
        p = getParams();
        if strcmp(p.PixOrQ, 'Pixel'), uialert(GUI.mainF, 'Change to Q axis first!', 'Warning'); return; end
        
        qpos = GUI.QPOS.Value;
        RR = GUI.PXRange.Value;
        
        [~, xpos] = min(abs(inputparam.Q1d - qpos));
        idx1 = max(1, xpos - fix(RR/2));
        idx2 = min(length(inputparam.Q1d), xpos + fix(RR/2));
        
        X = inputparam.Q1d(idx1:idx2);
        Y = inputparam.data(idx1:idx2);
        
        f1 = figure('Name', 'Fit Data Preview'); 
        plot(X, Y, '-ok', 'LineWidth', 1.5); axis tight;
        xlabel('Q'); ylabel('Intensity');
        
        selection = uiconfirm(GUI.mainF, 'Proceed with this region for Gaussian Fit?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'Yes');
        close(f1);
        
        if strcmp(selection, 'Yes')
            try
                delp = isnan(Y) | isinf(Y); 
                X(delp) = []; Y(delp) = [];
                
                if length(X) < 4
                    uialert(GUI.mainF, 'Not enough valid data points for fitting.', 'Error'); return;
                end
                
                Eqn = fittype('a*exp(-((x-b)^2)/(2*c^2)) + d', 'independent', 'x', 'dependent', 'y');
                
                [max_y, max_idx] = max(Y);
                a_init = max_y - min(Y);
                b_init = X(max_idx);
                c_init = (max(X) - min(X)) / 4; 
                d_init = min(Y);
                
                lb = [0, min(X), 0, 0];
                ub = [inf, max(X), inf, inf];
                
                IS = fit(X, Y, Eqn, 'StartPoint', [a_init, b_init, c_init, d_init], ...
                    'Lower', lb, 'Upper', ub, 'Robust', 'LAR');
                
                p_fin = coeffvalues(IS);
                Mean = p_fin(2); 
                FWHM = 2.3548 * p_fin(3); 
                
                updatePlot(); 
                hold(hAX1, 'on');
                
                [Qv, ~] = getQval(X, p.Qunit);
                GF = p_fin(1)*exp(-(((X-Mean).^2)./(2*p_fin(3)^2))) + p_fin(4);
                plot(hAX1, Qv, GF, 'Color', [0.85 0.32 0.1], 'LineWidth', 2);
                
                txtStr = sprintf('Mean: %.4f\\nFWHM: %.4f', Mean, FWHM);
                text(hAX1, Mean, max_y, txtStr, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'FontSize', 12, 'Color', [0.85 0.32 0.1], 'FontWeight', 'bold');
                hold(hAX1, 'off');
                
            catch ME
                uialert(GUI.mainF, ['Fitting Failed: ' ME.message], 'Error');
            end
        end
    end

    function Saveplot_Callback(~,~)
        SaveForm = GUI.hSForm.Value;
        [filepath, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok
            uialert(GUI.mainF, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        
        X = inputparam.Q1d(:); 
        Y = inputparam.data(:);
        data = double([X, Y]); 
        data(isnan(data(:,2)), :) = 0;
        
        SFN = [param.FileName, '_QLine_', num2str(param.ang)];
        selection = uiconfirm(GUI.mainF, 'Change filename?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'No');
        if strcmp(selection, 'Yes')
            [SFN, nameOK] = promptPGIXSSaveFileBaseName(SFN, SaveForm, 'Save Q-Line Data As');
            if ~nameOK, return; end
        end
        
        savePath = fullfile(filepath, [SFN, SaveForm]);
        
        savePGIXSDataFile(savePath, SaveForm, data, struct('data', data));
        
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX1, fullfile(filepath, [SFN, '.jpg']), 300);
        if ~exportOK
            warning('PGIXS:FigureExportFailed', '%s', exportReport.Message);
        end
        uialert(GUI.mainF, sprintf('Save Done!\nPath: %s', filepath), 'Success');
    end

    function CloseFig_Callback(~,~)
        delete(GUI.mainF);
        if ~isempty(parentFig) && isvalid(parentFig)
            figure(parentFig); drawnow;
        end
    end

    function Resize_Callback(src, ~) %#ok<DEFNU>
        referenceHeight = 900; 
        
        original_units = get(src, 'Units');
        set(src, 'Units', 'pixels');
        pos = get(src, 'Position');
        currHeight = pos(4);
        set(src, 'Units', original_units); 
        
        scaleFactor = currHeight / referenceHeight;
        if scaleFactor < 0.5, scaleFactor = 0.5; end
        
        allObj = findall(src, '-property', 'FontSize');
        for i = 1:length(allObj)
            obj = allObj(i);
            if isempty(get(obj, 'UserData')) || ~isstruct(get(obj, 'UserData')) || ~isfield(get(obj, 'UserData'), 'BaseFontSize')
                baseSize = get(obj, 'FontSize');
                ud.BaseFontSize = baseSize; 
                set(obj, 'UserData', ud);
            else
                ud = get(obj, 'UserData');
                baseSize = ud.BaseFontSize;
            end
            set(obj, 'FontSize', baseSize * scaleFactor);
        end
    end
end
