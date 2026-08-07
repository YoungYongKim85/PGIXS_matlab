function OneDplotQlinegi_gui(param, parentFig)
% OneDplotQlinegi_gui_v2.0 (Modern UI Upgrade & Layout Fix)
% - Converted to uifigure, uigridlayout, uieditfield, uidropdown
% - Fixed Ginput issues by using drawpoint
% - Unchained Layout properties to prevent UI crash
% - Fixed overlapping Save Button and Save Format dropdown
% parentFig: 부모 figure 핸들 (포커스 복원용, 옵션)

    if nargin < 2, parentFig = []; end

    % =========================================================================
    % [핵심 조치: 환경 변수 꼬임 자동 복구 및 모던 UI 인식 체크]
    try evalin('base', 'clear uilabel uifigure uigridlayout uipanel uiaxes uibutton uidropdown uicheckbox uieditfield'); catch; end
    if exist('uilabel', 'builtin') == 0 && exist('uilabel', 'file') == 0, errordlg('현재 매트랩이 모던 UI(uilabel)를 인식하지 못합니다.', '버전 오류'); return; end
    % =========================================================================

    %% ==================== GUI Setup ====================
    GUI.mainF = uifigure('Name', ['1D Plot Viewer - ' param.FileName], ...
        'NumberTitle', 'off', 'Position', [150 150 1300 750], ...
        'Color', [0.96 0.96 0.96], ...
        'CloseRequestFcn', @CloseFig_Callback);

    mainGrid = uigridlayout(GUI.mainF, [2 2]);
    mainGrid.RowHeight = {'1x', 110};
    mainGrid.ColumnWidth = {'1x', 280};
    mainGrid.Padding = [10 10 10 10];
    mainGrid.RowSpacing = 10;
    mainGrid.ColumnSpacing = 10;

    % --- Plot Panel ---
    plotPanel = uipanel(mainGrid, 'Title', '1D Plot Viewer', 'FontSize', 13, 'FontWeight', 'bold', 'BackgroundColor', 'w');
    plotPanel.Layout.Row = 1; 
    plotPanel.Layout.Column = 1;
    
    pg = uigridlayout(plotPanel, [1 1]); 
    pg.Padding = [5 5 5 5];
    hAX1 = uiaxes(pg); 
    hAX1.Layout.Row = 1; 
    hAX1.Layout.Column = 1;

    % --- Control Panel (Bottom) ---
    ctrlPanel = uipanel(mainGrid, 'Title', 'Plot Controls', 'FontSize', 11, 'FontWeight', 'bold');
    ctrlPanel.Layout.Row = 2; 
    ctrlPanel.Layout.Column = [1 2];
    
    % [수정] Grid 칸을 11칸으로 확장하고 비율을 재조정했습니다.
    cg = uigridlayout(ctrlPanel, [2 11]);
    cg.RowHeight = {20, 25};
    cg.ColumnWidth = {'1x','1x','1x','1x','1x','1.2x','1.2x','0.6x','0.8x','1.2x','1.4x'};
    cg.Padding = [10 5 10 5]; 
    cg.ColumnSpacing = 8;

    % Lists
    PixQList = {'Pixel', 'Q', 'Alpha', 'Qstd', 'Istd'};
    scaleList = {'Linear', 'Logy', 'Logxy'};
    styleList = {'-', '--', ':', '-.', '-o'};
    colorList = {'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
    unitList = {'A^{-1}', 'nm^{-1}'};
    SFormList = {'.mat', '.sdt', '.dat', '.txt', '.csv'};

    % Row 1: Labels (Unchained)
    lbl1 = uilabel(cg, 'Text', 'Plot Unit'); 
    lbl1.Layout.Row = 1; lbl1.Layout.Column = 1;
    
    lbl2 = uilabel(cg, 'Text', 'Plot Scale'); 
    lbl2.Layout.Row = 1; lbl2.Layout.Column = 2;
    
    lbl3 = uilabel(cg, 'Text', 'Line Style'); 
    lbl3.Layout.Row = 1; lbl3.Layout.Column = 3;
    
    lbl4 = uilabel(cg, 'Text', 'Line Color'); 
    lbl4.Layout.Row = 1; lbl4.Layout.Column = 4;
    
    lbl5 = uilabel(cg, 'Text', 'Q unit'); 
    lbl5.Layout.Row = 1; lbl5.Layout.Column = 5;
    
    lbl6 = uilabel(cg, 'Text', 'X-Range'); 
    lbl6.Layout.Row = 1; lbl6.Layout.Column = 6;
    
    lbl7 = uilabel(cg, 'Text', 'Y-Range'); 
    lbl7.Layout.Row = 1; lbl7.Layout.Column = 7;
    
    lbl8 = uilabel(cg, 'Text', 'Save Format'); 
    lbl8.Layout.Row = 1; lbl8.Layout.Column = 10;

    % Row 2: Controls (Unchained)
    GUI.hPixOrQ = uidropdown(cg, 'Items', PixQList, 'ValueChangedFcn', @Rangecal_Callback); 
    GUI.hPixOrQ.Layout.Row = 2; GUI.hPixOrQ.Layout.Column = 1;
    
    GUI.hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hScale.Layout.Row = 2; GUI.hScale.Layout.Column = 2;
    
    GUI.hLineStyle = uidropdown(cg, 'Items', styleList, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hLineStyle.Layout.Row = 2; GUI.hLineStyle.Layout.Column = 3;
    
    GUI.hColorStyle = uidropdown(cg, 'Items', colorList, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hColorStyle.Layout.Row = 2; GUI.hColorStyle.Layout.Column = 4;
    
    GUI.hQunit = uidropdown(cg, 'Items', unitList, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hQunit.Layout.Row = 2; GUI.hQunit.Layout.Column = 5;

    subX = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); 
    subX.Layout.Row = 2; subX.Layout.Column = 6;
    GUI.xpixMin = uieditfield(subX, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.xpixMax = uieditfield(subX, 'numeric', 'Value', 1000, 'ValueChangedFcn', @Updateplot_Callback);

    subY = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); 
    subY.Layout.Row = 2; subY.Layout.Column = 7;
    GUI.yIMin = uieditfield(subY, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.yIMax = uieditfield(subY, 'numeric', 'Value', 1000, 'ValueChangedFcn', @Updateplot_Callback);

    GUI.hGridCheck = uicheckbox(cg, 'Text', 'Grid', 'Value', 0, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hGridCheck.Layout.Row = [1 2]; GUI.hGridCheck.Layout.Column = 8;
    
    btnUpdate = uibutton(cg, 'Text', 'Update', 'ButtonPushedFcn', @Updateplot_Callback); 
    btnUpdate.Layout.Row = [1 2]; btnUpdate.Layout.Column = 9;
    
    % [수정] 겹쳐있던 포맷 드롭다운을 10번째 칸에 안정적으로 배치
    GUI.hSForm = uidropdown(cg, 'Items', SFormList, 'Value', '.dat');
    GUI.hSForm.Layout.Row = 2; GUI.hSForm.Layout.Column = 10;

    % [수정] 메인 그리드 위에 떠서 가려버리던 Save 버튼을 ctrlPanel(cg) 내부 11번째 칸으로 이동
    btnSave = uibutton(cg, 'Text', 'Save Data & Plot', 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @Saveplot_Callback);
    btnSave.Layout.Row = [1 2]; btnSave.Layout.Column = 11;

    % --- Analysis Panels Container (Right) ---
    analContainer = uigridlayout(mainGrid, [3 1]); 
    analContainer.Layout.Row = 1; analContainer.Layout.Column = 2;
    analContainer.RowHeight = {'1.4x', '1.6x', '1.2x'};
    analContainer.Padding = [0 0 0 0]; analContainer.RowSpacing = 8;

    % [Analysis 1] Peak Ratio
    pnlA1 = uipanel(analContainer, 'Title', 'Analysis 1 (Peak Ratio)', 'FontWeight', 'bold'); 
    pnlA1.Layout.Row = 1;
    
    gA1 = uigridlayout(pnlA1, [5 2]); 
    gA1.RowHeight = {20, 20, 20, 20, 25}; gA1.Padding = [5 5 5 5];
    
    lblA1_1 = uilabel(gA1, 'Text', 'D-spacing [A]:'); 
    lblA1_1.Layout.Row = 1; 
    GUI.DSP1 = uieditfield(gA1, 'numeric', 'Value', 1); 
    GUI.DSP1.Layout.Row = 1; GUI.DSP1.Layout.Column = 2;
    
    lblA1_2 = uilabel(gA1, 'Text', 'Peak Ratio:'); 
    lblA1_2.Layout.Row = 2;
    
    PeakRatioList = {'single', 'Layer', 'cubic','fcc', 'bcc', 'Pn3m', 'Ia3d', 'Hexagonal'};
    GUI.hPeakRatio = uidropdown(gA1, 'Items', PeakRatioList); 
    GUI.hPeakRatio.Layout.Row = 2; GUI.hPeakRatio.Layout.Column = 2;
    
    GUI.hQminmax = uicheckbox(gA1, 'Text', 'Qmin & Qmax', 'Value', 0); 
    GUI.hQminmax.Layout.Row = 3; GUI.hQminmax.Layout.Column = [1 2];

    btnDcal1 = uibutton(gA1, 'Text', 'D-Cal. (Click)', 'ButtonPushedFcn', @Dcal_Callback); 
    btnDcal1.Layout.Row = 4; btnDcal1.Layout.Column = [1 2];

    btnPlot1 = uibutton(gA1, 'Text', 'Plot', 'ButtonPushedFcn', @Analplot1_Callback); 
    btnPlot1.Layout.Row = 5; btnPlot1.Layout.Column = [1 2];

    % [Analysis 2] DWBA
    pnlA2 = uipanel(analContainer, 'Title', 'Analysis 2 (DWBA)', 'FontWeight', 'bold'); 
    pnlA2.Layout.Row = 2;
    
    gA2 = uigridlayout(pnlA2, [6 2]); 
    gA2.RowHeight = {20, 20, 20, 20, 25, 25}; gA2.Padding = [5 5 5 5];
    
    lblA2_1 = uilabel(gA2, 'Text', 'Energy [keV]:'); 
    lblA2_1.Layout.Row = 1; 
    GUI.PE = uieditfield(gA2, 'numeric', 'Value', 11.3); 
    GUI.PE.Layout.Row = 1; GUI.PE.Layout.Column = 2;
    
    lblA2_2 = uilabel(gA2, 'Text', 'D-spacing [A]:'); 
    lblA2_2.Layout.Row = 2; 
    GUI.DSP2 = uieditfield(gA2, 'numeric', 'Value', 1); 
    GUI.DSP2.Layout.Row = 2; GUI.DSP2.Layout.Column = 2;
    
    lblA2_3 = uilabel(gA2, 'Text', 'ai [deg]:'); 
    lblA2_3.Layout.Row = 3; 
    GUI.alpha_i = uieditfield(gA2, 'numeric', 'Value', 0.15); 
    GUI.alpha_i.Layout.Row = 3; GUI.alpha_i.Layout.Column = 2;
    
    lblA2_4 = uilabel(gA2, 'Text', 'ac [deg]:'); 
    lblA2_4.Layout.Row = 4; 
    GUI.alpha_c = uieditfield(gA2, 'numeric', 'Value', 0.15); 
    GUI.alpha_c.Layout.Row = 4; GUI.alpha_c.Layout.Column = 2;
    
    btnDcal = uibutton(gA2, 'Text', 'D-Cal. (Click)', 'ButtonPushedFcn', @Dcal_Callback); 
    btnDcal.Layout.Row = 5; btnDcal.Layout.Column = [1 2];
    
    btnPlot2 = uibutton(gA2, 'Text', 'Plot', 'ButtonPushedFcn', @Analplot2_Callback); 
    btnPlot2.Layout.Row = 6; btnPlot2.Layout.Column = [1 2];

    % [Analysis 3] Peak Fitting
    pnlA3 = uipanel(analContainer, 'Title', 'Analysis 3 (Gaussian Fit)', 'FontWeight', 'bold'); 
    pnlA3.Layout.Row = 3;
    
    gA3 = uigridlayout(pnlA3, [3 3]); 
    gA3.RowHeight = {20, 20, 25}; gA3.Padding = [5 5 5 5];
    
    btnPos = uibutton(gA3, 'Text', 'Pos. Pick', 'ButtonPushedFcn', @Poscal_Callback); 
    btnPos.Layout.Row = [1 2]; btnPos.Layout.Column = 1;
    
    lblA3_1 = uilabel(gA3, 'Text', 'q pos:'); 
    lblA3_1.Layout.Row = 1; 
    GUI.QPOS = uieditfield(gA3, 'numeric', 'Value', 1); 
    GUI.QPOS.Layout.Row = 1; GUI.QPOS.Layout.Column = 3;
    
    lblA3_2 = uilabel(gA3, 'Text', 'Range (pix):'); 
    lblA3_2.Layout.Row = 2; 
    GUI.PXRange = uieditfield(gA3, 'numeric', 'Value', 50); 
    GUI.PXRange.Layout.Row = 2; GUI.PXRange.Layout.Column = 3;
    
    btnFit = uibutton(gA3, 'Text', 'Fitting Selection', 'ButtonPushedFcn', @PreSelect_Callback); 
    btnFit.Layout.Row = 3; btnFit.Layout.Column = [1 3];

    %% ==================== Data Initialization ====================
    PeakRatioData.single = struct('ratio', 1, 'labels', {{'$1$'}});
    PeakRatioData.Layer = struct('ratio', [1, 2, 3, 4, 5], 'labels', {{'$1$', '$2$', '$3$', '$4$', '$5$'}});
    PeakRatioData.cubic = struct('ratio', [1, sqrt(2), sqrt(3), 2, sqrt(5)], 'labels', {{'$1$', '$\sqrt{2}$', '$\sqrt{3}$', '$\sqrt{4}$', '$\sqrt{5}$'}});
    PeakRatioData.bcc = struct('ratio', [sqrt(2), 2, sqrt(6), sqrt(8), sqrt(10)], 'labels', {{'$\sqrt{2}$', '$\sqrt{4}$', '$\sqrt{6}$', '$\sqrt{8}$', '$\sqrt{10}$'}});
    PeakRatioData.fcc = struct('ratio', [sqrt(3), 2, sqrt(8), sqrt(11), sqrt(12)], 'labels', {{'$\sqrt{3}$', '$\sqrt{4}$', '$\sqrt{8}$', '$\sqrt{11}$', '$\sqrt{12}$'}});
    PeakRatioData.Pn3m = struct('ratio', [sqrt(2), sqrt(3), 2, sqrt(6), sqrt(8)], 'labels', {{'$\sqrt{2}$', '$\sqrt{3}$', '$\sqrt{4}$', '$\sqrt{6}$', '$\sqrt{8}$'}});
    PeakRatioData.Ia3d = struct('ratio', [sqrt(6), sqrt(8), sqrt(14), 4, sqrt(18)], 'labels', {{'$\sqrt{6}$', '$\sqrt{8}$', '$\sqrt{14}$', '$\sqrt{16}$', '$\sqrt{18}$'}});
    PeakRatioData.Hexagonal = struct('ratio', [1, sqrt(3), 2, sqrt(7), 3], 'labels', {{'$1$', '$\sqrt{3}$', '$\sqrt{4}$', '$\sqrt{7}$', '$\sqrt{9}$'}});

    inputparam.ang = param.ang;
    inputparam.Mapping = param.Mapping;
    inputparam.pixPlot = param.line1dang(:,1);

    switch param.Mapping
        case {'Pixel', 'Qxy/Qz', 'Qy/Qz'}
            inputparam.Q1d = param.line1dang(:,2);
        case 'Alpha'
            inputparam.Theta1d = param.line1dang(:,2);
    end
    inputparam.data = param.line1dang(:,3);

    if size(param.line1dang,2) == 6
        inputparam.Q1dstd = param.line1dang(:,4);
        inputparam.Q1dmin = param.line1dang(:,5);
        inputparam.Q1dmax = param.line1dang(:,6);
    end

    GUI.xpixMin.Value = double(min(inputparam.pixPlot, [], 'omitnan'));
    GUI.xpixMax.Value = double(max(inputparam.pixPlot, [], 'omitnan'));
    GUI.yIMin.Value = double(min(inputparam.data,[],'omitnan'));
    GUI.yIMax.Value = double(max(inputparam.data,[],'omitnan'));

    Updateplot();

    %% ==================== HELPER FUNCTIONS ====================
    function c = getColorCode(colorStr)
        switch colorStr
            case 'Black', c = 'k'; case 'Red', c = 'r'; case 'Green', c = 'g';
            case 'Blue', c = 'b'; case 'Cyan', c = 'c'; case 'Magenta', c = 'm'; case 'Yellow', c = 'y';
            otherwise, c = 'k';
        end
    end

    function xlbl = getXLabel(ang, QMapMet, Qunit, PixOrQ)
        if strcmp(PixOrQ, 'Pixel')
            xlbl = 'Pixel';
            return;
        end
        if strcmp(PixOrQ, 'Alpha')
            if ang == 0 || ang == 180
                xlbl = '2\theta_{f}, deg';
            elseif ang == 90
                xlbl = '\alpha_{f}, deg';
            else
                xlbl = 'angle, deg';
            end
            return;
        end
        unit_str = 'A^{-1}';
        if strcmp(Qunit, 'nm^{-1}')
            unit_str = '\textrm{nm}^{-1}';
        end
        if ang == 0 || ang == 180
            if strcmp(QMapMet, 'Qxy/Qz')
                xlbl = ['$q_{xy}, ', unit_str, '$'];
            elseif strcmp(QMapMet, 'Qy/Qz')
                xlbl = ['$q_y, ', unit_str, '$'];
            else
                xlbl = ['$q, ', unit_str, '$'];
            end
        elseif ang == 90
            xlbl = ['$q_z, ', unit_str, '$'];
        else
            xlbl = ['$q, ', unit_str, '$'];
        end
    end

    function [Qval, Qstd_out] = getQvalWithUnit(Q1d, Qunit, Q1dstd)
        if strcmp(Qunit, 'nm^{-1}'), Qval = Q1d .* 10; if nargin > 2 && ~isempty(Q1dstd), Qstd_out = Q1dstd .* 10; else, Qstd_out = []; end
        else, Qval = Q1d; if nargin > 2 && ~isempty(Q1dstd), Qstd_out = Q1dstd; else, Qstd_out = []; end
        end
    end

    function p = getCurrentParams()
        p.PixOrQ = GUI.hPixOrQ.Value; p.Qunit = GUI.hQunit.Value;
        p.plotscale = GUI.hScale.Value;
        p.linecolor = getColorCode(GUI.hColorStyle.Value); p.gridOn = GUI.hGridCheck.Value;
        p.xmin = GUI.xpixMin.Value; p.xmax = GUI.xpixMax.Value;
        p.ylimmin = GUI.yIMin.Value; p.ylimmax = GUI.yIMax.Value;
        
        rawStyle = GUI.hLineStyle.Value;
        if strcmp(rawStyle, '-o')
            p.linestyle = '-'; p.marker = 'o';
        else
            p.linestyle = rawStyle; p.marker = 'none';
        end
    end

    function [X, Y, Xstd, Ystd] = getPlotData(p)
        Xstd = []; Ystd = [];
        switch p.PixOrQ
            case 'Pixel'
                valid = inputparam.pixPlot >= p.xmin & inputparam.pixPlot <= p.xmax;
                X = inputparam.pixPlot(valid); Y = inputparam.data(valid);
            case 'Q'
                [Qval, ~] = getQvalWithUnit(inputparam.Q1d, p.Qunit);
                valid = inputparam.Q1d >= p.xmin & inputparam.Q1d <= p.xmax;
                X = Qval(valid); Y = inputparam.data(valid);
            case 'Alpha'
                valid = inputparam.Theta1d >= p.xmin & inputparam.Theta1d <= p.xmax;
                X = inputparam.Theta1d(valid); Y = inputparam.data(valid);
            case 'Qstd'
                [Qval, Xstd_full] = getQvalWithUnit(inputparam.Q1d, p.Qunit, inputparam.Q1dstd);
                valid = inputparam.Q1d >= p.xmin & inputparam.Q1d <= p.xmax;
                X = Qval(valid); Y = inputparam.data(valid); Xstd = Xstd_full(valid);
            case 'Istd'
                [Qval, ~] = getQvalWithUnit(inputparam.Q1d, p.Qunit);
                valid = inputparam.Q1d >= p.xmin & inputparam.Q1d <= p.xmax;
                X = Qval(valid); Y = inputparam.data(valid); Ystd = sqrt(abs(Y));
        end
    end

    %% ==================== CALLBACK FUNCTIONS ====================
    function Rangecal_Callback(~,~)
        PixOrQ = GUI.hPixOrQ.Value;
        switch PixOrQ
            case 'Pixel'
                GUI.xpixMin.Value = double(min(inputparam.pixPlot)); GUI.xpixMax.Value = double(max(inputparam.pixPlot));
            case {'Q','Qstd','Istd'}
                if isfield(inputparam,'Q1d'), GUI.xpixMin.Value = double(min(inputparam.Q1d)); GUI.xpixMax.Value = double(max(inputparam.Q1d));
                else, uialert(GUI.mainF, 'Error. Please use Alpha format','Warning'); return; end
            case 'Alpha'
                if isfield(inputparam,'Theta1d'), GUI.xpixMin.Value = double(min(inputparam.Theta1d)); GUI.xpixMax.Value = double(max(inputparam.Theta1d));
                else, uialert(GUI.mainF, 'Error. Please use Q format','Warning'); return; end
        end
        Updateplot();
    end

    function Updateplot_Callback(~,~), Updateplot(); end

    function Updateplot(~,~)
        p = getCurrentParams();
        if strcmp(p.PixOrQ, 'Alpha') && ~isfield(inputparam, 'Theta1d'), uialert(GUI.mainF, 'Please use Q format', 'Warning'); return; end
        if strcmp(p.PixOrQ, 'Qstd') && ~isfield(inputparam, 'Q1dstd'), uialert(GUI.mainF, 'No Q standard deviation info!', 'Warning'); return; end
        
        cla(hAX1); [X, Y, Xstd, Ystd] = getPlotData(p);
        
        switch p.PixOrQ
            case {'Pixel', 'Q', 'Alpha'}, plot(hAX1, X, Y, 'LineStyle', p.linestyle, 'Marker', p.marker, 'Color', p.linecolor, 'LineWidth', 2);
            case 'Qstd', errorbar(hAX1, X, Y, Xstd, 'horizontal', 'LineStyle', p.linestyle, 'Marker', p.marker, 'Color', p.linecolor, 'LineWidth', 2);
            case 'Istd', errorbar(hAX1, X, Y, Ystd, 'LineStyle', p.linestyle, 'Marker', p.marker, 'Color', p.linecolor, 'LineWidth', 2);
        end
        
        axis(hAX1, 'tight');
        xlbl = getXLabel(param.ang, param.QMapMet, p.Qunit, p.PixOrQ);
        if contains(xlbl, '$'), xlabel(hAX1, xlbl, 'Interpreter', 'latex', 'FontName', 'TimesNewRoman'); else, xlabel(hAX1, xlbl); end
        ylabel(hAX1, 'Intensity, arb. units');
        
        switch p.plotscale
            case 'Linear', set(hAX1, 'YScale', 'linear', 'XScale', 'linear');
            case 'Logy', set(hAX1, 'YScale', 'log', 'XScale', 'linear');
            case 'Logxy', set(hAX1, 'YScale', 'log', 'XScale', 'log');
        end
        set(hAX1, 'XLim', [p.xmin, p.xmax], 'YLim', [p.ylimmin, p.ylimmax]);
        set(hAX1, 'FontSize', 13, 'FontName', 'times');
        if p.gridOn, grid(hAX1, 'on'); else, grid(hAX1, 'off'); end
    end

    function Dcal_Callback(~,~)
        p = getCurrentParams();
        if strcmp(p.PixOrQ, 'Pixel'), uialert(GUI.mainF, 'Please change to Q axis!','Warning'); return; end
        
        if isfield(inputparam, 'hDcalPoint') && isvalid(inputparam.hDcalPoint), delete(inputparam.hDcalPoint); end
        uialert(GUI.mainF, '그래프에서 원하는 피크 위치를 1회 클릭하세요.', '안내');
        inputparam.hDcalPoint = drawpoint(hAX1, 'Color', 'r');
        x = inputparam.hDcalPoint.Position(1);
        delete(inputparam.hDcalPoint);
        
        switch p.PixOrQ
            case {'Q', 'Qstd', 'Istd'}
                D = 2*pi/x;
                if strcmp(p.Qunit, 'A^{-1}'), msg = sprintf('Q: %.2f 1/A, D: %.2f A', x, D); else, msg = sprintf('Q: %.2f 1/nm, D: %.2f nm', x, D); end
                GUI.DSP1.Value = double(D); GUI.DSP2.Value = double(D);
            case 'Alpha'
                D = param.Wavelength/(2*sind(x/2)); msg = sprintf('2theta: %.2f deg., D: %.2f A', x, D);
        end
        uialert(GUI.mainF, msg, 'D-spacing Result');
    end

    function Analplot1_Callback(~,~)
        D = GUI.DSP1.Value; PRatio = GUI.hPeakRatio.Value; showQminmax = GUI.hQminmax.Value; p = getCurrentParams();
        if strcmp(p.PixOrQ, 'Pixel'), uialert(GUI.mainF, 'Please use it at Q units','Warning'); return; end
        
        ratioData = PeakRatioData.(PRatio); qpos = 2*pi/D .* ratioData.ratio; labels = ratioData.labels;
        Qminpos = [];
        Qmaxpos = [];
        if showQminmax && isfield(inputparam,'Q1dmin')
            Qminpos = zeros(size(qpos));
            Qmaxpos = zeros(size(qpos));
            for i = 1:length(qpos)
                [~, idx] = min(abs(inputparam.Q1d - qpos(i)), [], 'omitnan');
                Qminpos(i) = inputparam.Q1dmin(idx); Qmaxpos(i) = inputparam.Q1dmax(idx);
            end
        end
        Updateplot();
        hold(hAX1, 'on'); xline(hAX1, qpos, '--r', 'LineWidth', 1.5);
        for i = 1:length(qpos)
            if i <= length(labels), text(hAX1, qpos(i), 1.015*p.ylimmax, labels{i}, 'Interpreter', 'latex', 'HorizontalAlignment', 'center', 'FontSize', 12); end
        end
        if showQminmax && ~isempty(Qminpos), xline(hAX1, Qminpos, ':g', 'LineWidth', 1.5); xline(hAX1, Qmaxpos, ':b', 'LineWidth', 1.5); end
        hold(hAX1, 'off');
    end

    function Analplot2_Callback(~,~)
        Energy = GUI.PE.Value; D = GUI.DSP2.Value; ai = GUI.alpha_i.Value; ac = GUI.alpha_c.Value; p = getCurrentParams();
        if param.ang ~= 90, uialert(GUI.mainF, 'Please use this function at 90 degree cutting','Warning'); return; end
        if strcmp(p.PixOrQ, 'Pixel') || strcmp(p.PixOrQ, 'Alpha'), uialert(GUI.mainF, 'Please use it at Q units','Warning'); return; end
        
        nfilm = cosd(ac); wavelength = 4.1357e-15 * 2.99792458e8 / (Energy * 1e3) * 1e10; k0 = 2*pi / wavelength;
        qpos = 2*pi/D .* [1, 2, 3];
        Taf = real(asind(sqrt((qpos./k0).^2 + sind(ai)^2 - 2.*qpos./k0.*sqrt(nfilm.^2 - 1 + sind(ai).^2))));
        Raf = real(asind(sqrt((qpos./k0).^2 + sind(ai)^2 + 2.*qpos./k0.*sqrt(nfilm.^2 - 1 + sind(ai).^2))));
        qpos_T = k0 * (sind(Taf) + sind(ai)); qpos_R = k0 * (sind(Raf) + sind(ai));
        
        Updateplot();
        hold(hAX1, 'on'); xline(hAX1, qpos_T, ':r', 'LineWidth', 1.5); xline(hAX1, qpos_R, '--b', 'LineWidth', 1.5);
        text(hAX1, qpos_T(1), 1.015*p.ylimmax, '$T$', 'Interpreter', 'latex', 'HorizontalAlignment', 'right', 'FontSize', 12, 'Color', 'r');
        text(hAX1, qpos_R(1), 1.015*p.ylimmax, '$R$', 'Interpreter', 'latex', 'HorizontalAlignment', 'left', 'FontSize', 12, 'Color', 'b');
        hold(hAX1, 'off');
    end

    function Poscal_Callback(~,~)
        if strcmp(GUI.hPixOrQ.Value, 'Pixel') || strcmp(GUI.hPixOrQ.Value, 'Alpha'), uialert(GUI.mainF, 'Please change Q axis!','Warning'); return; end
        uialert(GUI.mainF, '그래프에서 원하는 피크 위치를 클릭하세요.', '안내');
        hPt = drawpoint(hAX1, 'Color', 'm'); x = hPt.Position(1); delete(hPt);
        GUI.QPOS.Value = double(x);
    end

    function PreSelect_Callback(~,~)
        p = getCurrentParams();
        if strcmp(p.PixOrQ, 'Pixel') || strcmp(p.PixOrQ, 'Alpha'), uialert(GUI.mainF, 'Please change Q axis!','Warning'); return; end
        
        qpos = GUI.QPOS.Value; [~, xpos] = min(abs(inputparam.Q1d - qpos), [], 'omitnan');
        RR = GUI.PXRange.Value; xpix1 = max(1, xpos - fix(RR/2)); xpix2 = min(length(inputparam.Q1d), xpos + fix(RR/2));
        X = inputparam.Q1d(xpix1:xpix2); Y = inputparam.data(xpix1:xpix2);
        
        % Preview 창 생성
        fPreview = uifigure('Name', 'Preview', 'Position', [400 300 500 400]);
        
        axPreview = uiaxes(fPreview, 'Position', [50 120 400 250]); 
        plot(axPreview, X, Y, '-ok', 'MarkerFaceColor', 'k'); axis(axPreview, 'tight');
        
        uilabel(fPreview, 'Text', 'Right Position for Fitting?', 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'Position', [100 75 300 30]);
        
        fPreview.UserData = 'No'; 
        uibutton(fPreview, 'Text', 'Yes', 'Position', [120 30 100 35], 'ButtonPushedFcn', @(src, event) resumePreview(fPreview, 'Yes'));
        uibutton(fPreview, 'Text', 'No', 'Position', [280 30 100 35], 'ButtonPushedFcn', @(src, event) resumePreview(fPreview, 'No'));
        
        drawnow;
        uiwait(fPreview);
        
        if isvalid(fPreview)
            selection = fPreview.UserData;
            delete(fPreview); 
        else
            selection = 'No';
        end
        
        if strcmp(selection, 'Yes')
            delp = isnan(double(Y)); X(delp) = []; Y(delp) = [];
            if isempty(X) || length(X) < 4, uialert(GUI.mainF, 'Not enough data points for fitting', 'Warning'); return; end
            
            try
                Ifit = fit(double(X), double(Y), 'gauss1'); Ifit_p = abs(coeffvalues(Ifit)); bkg = min(Y, [], 'omitnan');
                Eqn = fittype('GFbkg(x,a,b,c,d)');
                IS = fit(double(X), double(Y), Eqn, 'Start', [Ifit_p(1), Ifit_p(2), Ifit_p(3)/sqrt(2), bkg]);
                IS_p = coeffvalues(IS); Meanval = IS_p(2); FWHM = 2.355 * IS_p(3);
                
                Updateplot(); hold(hAX1, 'on');
                GF = IS_p(1) * exp(-((X - IS_p(2)).^2) ./ (2 * IS_p(3)^2)) + IS_p(4);
                plot(hAX1, X, GF, 'Color', [0.85 0.325 0.098], 'LineWidth', 1.5);
                txt = sprintf('Mean: %.4f\nFWHM: %.4f', Meanval, FWHM);
                text(hAX1, Meanval, 0.9*p.ylimmax, txt, 'HorizontalAlignment', 'left', 'BackgroundColor', 'w', 'EdgeColor', 'k');
                hold(hAX1, 'off');
            catch ME
                uialert(GUI.mainF, ['Fitting failed: ', ME.message], 'Warning');
            end
        end
    end

    function resumePreview(fig, choice)
        fig.UserData = choice;
        uiresume(fig);
    end

    function Saveplot_Callback(~,~)
        SaveForm = GUI.hSForm.Value;
        [filepath, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok
            uialert(GUI.mainF, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        AngleValue = num2str(param.ang);
        
        switch GUI.hPixOrQ.Value
            case {'Pixel', 'Q', 'Qstd', 'Istd'}
                X = inputparam.Q1d; Y = inputparam.data;
                [X, idx] = sort(X); Y = Y(idx);
                if isfield(inputparam, 'Q1dstd')
                    Ystd = sqrt(abs(Y));
                    data = double([X, Y, Ystd]);
                else
                    data = double([X, Y]);
                end
                data(isnan(data)) = 0; SFN = [param.FileName, '_', AngleValue, 'degree_Q'];
            case 'Alpha'
                X = inputparam.Theta1d; Y = inputparam.data; [X, idx] = sort(X); Y = Y(idx);
                data = double([X, Y]); data(isnan(data)) = 0; SFN = [param.FileName, '_', AngleValue, 'degree_Alpha'];
        end
        
        selection = uiconfirm(GUI.mainF, 'Do you need to change filename?', 'Confirmation', 'Options', {'Yes', 'No'}, 'DefaultOption', 'Yes');
        if strcmp(selection, 'Yes')
            [SFN, nameOK] = promptPGIXSSaveFileBaseName(SFN, SaveForm, 'Save 1D Data As');
            if ~nameOK, return; end
        end
        
        SaveFilepath = fullfile(filepath, [SFN, SaveForm]);
        savePGIXSDataFile(SaveFilepath, SaveForm, data, struct('data', data));
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX1, fullfile(filepath, [SFN, '.jpg']), 300);
        if ~exportOK
            warning('PGIXS:FigureExportFailed', '%s', exportReport.Message);
        end
        uialert(GUI.mainF, sprintf('Save Done!\nPath: %s', SaveFilepath), 'Success');
    end

    function CloseFig_Callback(~,~)
        delete(GUI.mainF);
        if ~isempty(parentFig) && isvalid(parentFig)
            figure(parentFig); drawnow;
        end
    end

end
