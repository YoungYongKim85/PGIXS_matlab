function OneDplotAzi_gi_gui(param, parentFig)
% OneDplotAzi_gi_gui_v2.0 (Modern UI Upgrade)
% parentFig: 부모 figure 핸들 (포커스 복원용, 옵션)

    if nargin < 2, parentFig = []; end
% - Converted to uifigure, uigridlayout, uieditfield, uidropdown
% - Unchained Layout properties to prevent UI crash
% - Removed legacy resizing functions (uigridlayout handles it natively)

    % =========================================================================
    % [핵심 조치: 환경 변수 꼬임 자동 복구 및 모던 UI 인식 체크]
    try evalin('base', 'clear uilabel uifigure uigridlayout uipanel uiaxes uibutton uidropdown uicheckbox uieditfield'); catch; end
    if exist('uilabel', 'builtin') == 0 && exist('uilabel', 'file') == 0, errordlg('현재 매트랩이 모던 UI(uilabel)를 인식하지 못합니다.', '버전 오류'); return; end
    % =========================================================================

    %% ==================== GUI Setup ====================
    GUI.mainF = uifigure('Name', ['1D Azimuthal Plot Viewer - ' param.FileName], ...
        'NumberTitle', 'off', 'Position', [200 200 1000 600], ...
        'Color', [0.96 0.96 0.96], ...
        'CloseRequestFcn', @CloseFig_Callback);

    mainGrid = uigridlayout(GUI.mainF, [2 1]);
    mainGrid.RowHeight = {'1x', 90};
    mainGrid.Padding = [10 10 10 10];
    mainGrid.RowSpacing = 10;

    % --- Plot Panel ---
    plotPanel = uipanel(mainGrid, 'Title', '1D Azimuthal Plot Viewer', 'FontSize', 13, 'FontWeight', 'bold', 'BackgroundColor', 'w');
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
    ctrlPanel.Layout.Column = 1;
    
    cg = uigridlayout(ctrlPanel, [2 9]);
    cg.RowHeight = {20, 25};
    cg.ColumnWidth = {'1x','1x','1x','1.2x','1.2x','0.6x','1x','1x','1.2x'};
    cg.Padding = [10 5 10 5]; 
    cg.ColumnSpacing = 8;

    % Lists
    scaleList = {'Linear', 'Logy'};
    styleList = {'-', '--', ':', '-.', '-o'};
    colorList = {'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
    SFormList = {'.mat', '.sdt', '.dat', '.txt', '.csv'};

    % Row 1: Labels
    lbl1 = uilabel(cg, 'Text', 'Plot Scale'); lbl1.Layout.Row = 1; lbl1.Layout.Column = 1;
    lbl2 = uilabel(cg, 'Text', 'Line Style'); lbl2.Layout.Row = 1; lbl2.Layout.Column = 2;
    lbl3 = uilabel(cg, 'Text', 'Line Color'); lbl3.Layout.Row = 1; lbl3.Layout.Column = 3;
    lbl4 = uilabel(cg, 'Text', 'X-Range (Deg)'); lbl4.Layout.Row = 1; lbl4.Layout.Column = 4;
    lbl5 = uilabel(cg, 'Text', 'Y-Range'); lbl5.Layout.Row = 1; lbl5.Layout.Column = 5;
    lbl6 = uilabel(cg, 'Text', 'Save Format'); lbl6.Layout.Row = 1; lbl6.Layout.Column = 8;

    % Row 2: Controls
    GUI.hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hScale.Layout.Row = 2; GUI.hScale.Layout.Column = 1;
    
    GUI.hLineStyle = uidropdown(cg, 'Items', styleList, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hLineStyle.Layout.Row = 2; GUI.hLineStyle.Layout.Column = 2;
    
    GUI.hColorStyle = uidropdown(cg, 'Items', colorList, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hColorStyle.Layout.Row = 2; GUI.hColorStyle.Layout.Column = 3;

    subX = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); 
    subX.Layout.Row = 2; subX.Layout.Column = 4;
    GUI.xMin = uieditfield(subX, 'numeric', 'Value', -180, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.xMax = uieditfield(subX, 'numeric', 'Value', 180, 'ValueChangedFcn', @Updateplot_Callback);

    subY = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); 
    subY.Layout.Row = 2; subY.Layout.Column = 5;
    GUI.yIMin = uieditfield(subY, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.yIMax = uieditfield(subY, 'numeric', 'Value', 1000, 'ValueChangedFcn', @Updateplot_Callback);

    GUI.hGridCheck = uicheckbox(cg, 'Text', 'Grid', 'Value', 0, 'ValueChangedFcn', @Updateplot_Callback); 
    GUI.hGridCheck.Layout.Row = [1 2]; GUI.hGridCheck.Layout.Column = 6;
    
    btnUpdate = uibutton(cg, 'Text', 'Update', 'ButtonPushedFcn', @Updateplot_Callback); 
    btnUpdate.Layout.Row = [1 2]; btnUpdate.Layout.Column = 7;
    
    GUI.hSForm = uidropdown(cg, 'Items', SFormList); 
    GUI.hSForm.Layout.Row = 2; GUI.hSForm.Layout.Column = 8;
    
    btnSave = uibutton(cg, 'Text', 'Save Plot', 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @Saveplot_Callback);
    btnSave.Layout.Row = [1 2]; btnSave.Layout.Column = 9;

    %% ==================== Initialize Data ====================
    inputparam.Aziangle = param.Azi(:,1) - 180;
    inputparam.AziIntensity = param.Azi(:,2);

    GUI.xMin.Value = double(min(inputparam.Aziangle));
    GUI.xMax.Value = double(max(inputparam.Aziangle));
    GUI.yIMin.Value = double(min(inputparam.AziIntensity,[],'omitnan'));
    GUI.yIMax.Value = double(max(inputparam.AziIntensity,[],'omitnan'));

    Updateplot();

    %% ==================== HELPER FUNCTIONS ====================
    function c = getColorCode(colorStr)
        switch colorStr
            case 'Black', c = 'k'; case 'Red', c = 'r'; case 'Green', c = 'g';
            case 'Blue', c = 'b'; case 'Cyan', c = 'c'; case 'Magenta', c = 'm'; case 'Yellow', c = 'y';
            otherwise, c = 'k';
        end
    end

    function p = getCurrentParams()
        p.plotscale = GUI.hScale.Value;
        p.linecolor = getColorCode(GUI.hColorStyle.Value);
        p.gridOn = GUI.hGridCheck.Value;
        p.xmin = GUI.xMin.Value;
        p.xmax = GUI.xMax.Value;
        p.ylimmin = GUI.yIMin.Value;
        p.ylimmax = GUI.yIMax.Value;
        
        % '-o' 등 축약형 LineSpec를 LineStyle + Marker로 분리
        rawStyle = GUI.hLineStyle.Value;
        if strcmp(rawStyle, '-o')
            p.linestyle = '-'; p.marker = 'o';
        else
            p.linestyle = rawStyle; p.marker = 'none';
        end
    end

    %% ==================== CALLBACK FUNCTIONS ====================
    function Updateplot_Callback(~,~), Updateplot(); end

    function Updateplot(~,~)
        p = getCurrentParams();
        
        cla(hAX1);
        
        % Filter data within x-range
        xdata = inputparam.Aziangle >= p.xmin & inputparam.Aziangle <= p.xmax;
        X = inputparam.Aziangle(xdata);
        Y = inputparam.AziIntensity(xdata);
        
        % Plot
        plot(hAX1, X, Y, 'LineStyle', p.linestyle, 'Marker', p.marker, 'Color', p.linecolor, 'LineWidth', 2);
        axis(hAX1, 'tight');
        
        % Labels
        xlabel(hAX1, 'Azimuthal angle, degree', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel(hAX1, 'Intensity, arb. units', 'FontSize', 12, 'FontWeight', 'bold');
        
        % Apply settings
        switch p.plotscale
            case 'Linear', set(hAX1, 'YScale', 'linear', 'XScale', 'linear');
            case 'Logy', set(hAX1, 'YScale', 'log', 'XScale', 'linear');
        end
        
        set(hAX1, 'XLim', [p.xmin, p.xmax], 'YLim', [p.ylimmin, p.ylimmax]);
        set(hAX1, 'FontSize', 13, 'FontName', 'times');
        
        if p.gridOn, grid(hAX1, 'on'); else, grid(hAX1, 'off'); end
    end

    function Saveplot_Callback(~,~)
        SaveForm = GUI.hSForm.Value;
        
        % Create output directory
        [filepath, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok
            uialert(GUI.mainF, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        
        % Prepare data
        X = inputparam.Aziangle;
        Y = inputparam.AziIntensity;
        
        [X, idx] = sort(X);
        Y = Y(idx);
        
        data = double([X, Y]);
        data(isnan(data)) = 0;
        
        % Filename
        SFN = [param.FileName, '_Azimuthal'];
        
        selection = uiconfirm(GUI.mainF, 'Do you need to change filename?', 'Confirmation', 'Options', {'Yes', 'No'}, 'DefaultOption', 'Yes');
        if strcmp(selection, 'Yes')
            [SFN, nameOK] = promptPGIXSSaveFileBaseName(SFN, SaveForm, 'Save Azimuthal Data As');
            if ~nameOK, return; end
        end
        
        % Save data file
        SaveFilepath = fullfile(filepath, [SFN, SaveForm]);
        savePGIXSDataFile(SaveFilepath, SaveForm, data, struct('data', data));
        
        % Save figure (정확히 Axes를 타겟팅하여 에러 방지)
        SaveFigurepath = fullfile(filepath, [SFN, '.jpg']);
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX1, SaveFigurepath, 300);
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
