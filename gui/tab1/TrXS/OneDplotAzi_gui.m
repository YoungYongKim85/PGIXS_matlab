function OneDplotAzi_gui(param, parentFig)
% OneDplotAzi_gui v2.0 - 1D Azimuthal Plot Viewer (Modern UI)
% Upgraded By Y.Y.Kim
% FIXED: Applied Modern UI (uifigure, uigridlayout), moved controls to Right Panel
%        for family look, used uieditfield('numeric'), robust NaN handling.
% parentFig: 부모 figure 핸들 (포커스 복원용, 옵션)

    if nargin < 2, parentFig = []; end

    %% ==================== GUI Setup ====================
    GUI.mainF = uifigure('Name',['1D Azimuthal Plot Viewer v', pgixsVersion()],...
        'NumberTitle','off', 'Position',[150 150 1000 650], ...
        'Color', [0.96 0.96 0.96], ...
        'CloseRequestFcn', @CloseFig_Callback);

    movegui(GUI.mainF, 'center');

    mainGrid = uigridlayout(GUI.mainF, [1 2]);
    mainGrid.ColumnWidth = {'1x', 320};
    mainGrid.Padding = [10 10 10 10];
    mainGrid.ColumnSpacing = 15;

    % --- Left Panel: Plot ---
    plotPanel = uipanel(mainGrid, 'Title', '1D Azimuthal Plot Viewer', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'w');
    plotPanel.Layout.Row = 1; plotPanel.Layout.Column = 1;
    
    pg = uigridlayout(plotPanel, [1 1]);
    hAX1 = uiaxes(pg);

    % --- Right Panel: Controls ---
    ctrlPanel = uipanel(mainGrid, 'Title', 'Controls & Export', 'FontSize', 14, 'FontWeight', 'bold');
    ctrlPanel.Layout.Row = 1; ctrlPanel.Layout.Column = 2;

    % 12행 2열의 그리드 시스템 (여유로운 배치)
    cg = uigridlayout(ctrlPanel, [12 2]);
    cg.RowHeight = num2cell(repmat(30, 1, 12));
    cg.ColumnWidth = {'1x', '1x'};
    cg.Padding = [15 15 15 15];
    cg.RowSpacing = 10;

    %% ==================== UI Controls ====================
    % [1] Scale
    lbl1 = uilabel(cg, 'Text', 'Scale:'); 
    lbl1.Layout.Row = 1; lbl1.Layout.Column = 1;
    scaleList = {'Linear', 'Logy'};
    GUI.hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hScale.Layout.Row = 1; GUI.hScale.Layout.Column = 2;

    % [2] Style & Color
    lbl2 = uilabel(cg, 'Text', 'Line Style:'); 
    lbl2.Layout.Row = 2; lbl2.Layout.Column = 1;
    styleList = {'-', '--', ':', '-.', '-o'};
    GUI.hLineStyle = uidropdown(cg, 'Items', styleList, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hLineStyle.Layout.Row = 2; GUI.hLineStyle.Layout.Column = 2;

    lbl3 = uilabel(cg, 'Text', 'Color:'); 
    lbl3.Layout.Row = 3; lbl3.Layout.Column = 1;
    colorList = {'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
    colorCodes = {'k', 'r', 'g', 'b', 'c', 'm', 'y'};
    GUI.hColorStyle = uidropdown(cg, 'Items', colorList, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hColorStyle.Layout.Row = 3; GUI.hColorStyle.Layout.Column = 2;

    % [3] X-Range
    lbl4 = uilabel(cg, 'Text', 'X-Range (Min/Max):'); 
    lbl4.Layout.Row = 4; lbl4.Layout.Column = 1;
    subX = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 5);
    subX.Layout.Row = 4; subX.Layout.Column = 2;
    GUI.xMin = uieditfield(subX, 'numeric', 'Value', -180, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.xMax = uieditfield(subX, 'numeric', 'Value', 180, 'ValueChangedFcn', @Updateplot_Callback);

    % [4] Y-Range
    lbl5 = uilabel(cg, 'Text', 'Y-Range (Min/Max):'); 
    lbl5.Layout.Row = 5; lbl5.Layout.Column = 1;
    subY = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 5);
    subY.Layout.Row = 5; subY.Layout.Column = 2;
    GUI.yIMin = uieditfield(subY, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.yIMax = uieditfield(subY, 'numeric', 'Value', 1000, 'ValueChangedFcn', @Updateplot_Callback);

    % [5] Grid & Update
    GUI.hGridCheck = uicheckbox(cg, 'Text', 'Grid On', 'Value', 0, 'ValueChangedFcn', @Updateplot_Callback);
    GUI.hGridCheck.Layout.Row = 6; GUI.hGridCheck.Layout.Column = 1;
    
    btnUpdate = uibutton(cg, 'Text', 'Update Plot', 'FontWeight', 'bold', 'ButtonPushedFcn', @Updateplot_Callback);
    btnUpdate.Layout.Row = 6; btnUpdate.Layout.Column = 2;

    % --- Divider ---
    lblDiv1 = uilabel(cg, 'Text', '--- [ Export Data ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    lblDiv1.Layout.Row = 8; lblDiv1.Layout.Column = [1 2];

    % [6] Save
    lbl6 = uilabel(cg, 'Text', 'Save Format:'); 
    lbl6.Layout.Row = 9; lbl6.Layout.Column = 1;
    SFormList = {'.mat', '.sdt', '.dat', '.txt', '.csv'};
    GUI.hSForm = uidropdown(cg, 'Items', SFormList, 'Value', '.dat');
    GUI.hSForm.Layout.Row = 9; GUI.hSForm.Layout.Column = 2;

    btnSave = uibutton(cg, 'Text', 'Save Data & Plot', 'BackgroundColor', [0.9 0.95 1], 'FontWeight', 'bold', 'ButtonPushedFcn', @Saveplot_Callback);
    btnSave.Layout.Row = 10; btnSave.Layout.Column = [1 2];

    %% ==================== Initialize Data ====================
    inputparam.Aziangle = double(param.Azi(:,1) - 180); % 각도 보정 (-180 offset)
    inputparam.AziIntensity = double(param.Azi(:,2));

    % 데이터 Min/Max 강건한 초기화 (NaN 방어)
    valXmin = min(inputparam.Aziangle, [], 'omitnan');
    if isempty(valXmin) || isnan(valXmin), valXmin = -180; end
    GUI.xMin.Value = double(valXmin);
    
    valXmax = max(inputparam.Aziangle, [], 'omitnan');
    if isempty(valXmax) || isnan(valXmax), valXmax = 180; end
    GUI.xMax.Value = double(valXmax);
    
    valYmin = min(inputparam.AziIntensity(inputparam.AziIntensity > 0), [], 'omitnan');
    if isempty(valYmin) || isnan(valYmin), valYmin = 1; end
    GUI.yIMin.Value = double(valYmin);
    
    valYmax = max(inputparam.AziIntensity, [], 'omitnan');
    if isempty(valYmax) || isnan(valYmax), valYmax = 1e6; end
    GUI.yIMax.Value = double(valYmax);

    updatePlot();

    %% ==================== Helper Functions ====================
    function p = getParams()
        p.plotscale = GUI.hScale.Value;
        p.linestyle = GUI.hLineStyle.Value;
        
        colorMatch = strcmp(colorList, GUI.hColorStyle.Value);
        if any(colorMatch)
            p.linecolor = colorCodes{colorMatch};
        else
            p.linecolor = 'k';
        end
        
        p.grid = GUI.hGridCheck.Value;
        p.xmin = GUI.xMin.Value;
        p.xmax = GUI.xMax.Value;
        p.ymin = GUI.yIMin.Value;
        p.ymax = GUI.yIMax.Value;
    end

    %% ==================== Callbacks ====================
    function Updateplot_Callback(~,~), updatePlot(); end

    function updatePlot(~,~)
        p = getParams();
        cla(hAX1); 
        
        % 데이터를 자르지 않고 전체를 그린 뒤 화면만 축소/확대함 (안전성 및 속도 확보)
        X = inputparam.Aziangle; 
        Y = inputparam.AziIntensity;
        
        plot(hAX1, X, Y, p.linestyle, 'Color', p.linecolor, 'LineWidth', 1.5);
        
        if strcmp(p.plotscale, 'Linear')
            set(hAX1, 'YScale', 'linear', 'XScale', 'linear');
        else
            set(hAX1, 'YScale', 'log', 'XScale', 'linear');
        end
        
        if p.xmax > p.xmin, xlim(hAX1, [p.xmin, p.xmax]); end
        if p.ymax > p.ymin, ylim(hAX1, [p.ymin, p.ymax]); end
        
        xlabel(hAX1, 'Azimuthal angle, degree');
        ylabel(hAX1, 'Intensity, arb. units');
        set(hAX1, 'FontSize', 14, 'FontName', 'times', 'LineWidth', 1.5, 'TickDir', 'in'); 
        
        if p.grid, grid(hAX1, 'on'); else, grid(hAX1, 'off'); end
    end

    function Saveplot_Callback(~,~)
        SaveForm = GUI.hSForm.Value;
        [filepath, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok
            uialert(GUI.mainF, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        
        X = inputparam.Aziangle(:); 
        Y = inputparam.AziIntensity(:);
        [X, idx] = sort(X); 
        Y = Y(idx);
        data = double([X, Y]); 
        data(isnan(data(:,2)), :) = 0;
        
        SFN = [param.FileName, '_Azimuthal'];
        selection = uiconfirm(GUI.mainF, 'Change filename?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'No');
        if strcmp(selection, 'Yes')
            [SFN, nameOK] = promptPGIXSSaveFileBaseName(SFN, SaveForm, 'Save Azimuthal Data As');
            if ~nameOK, return; end
        end
        
        d = uiprogressdlg(GUI.mainF, 'Title', 'Saving', 'Message', 'Saving Images and Data...', 'Indeterminate', 'on');
        
        savePath = fullfile(filepath, [SFN, SaveForm]);
        savePGIXSDataFile(savePath, SaveForm, data, struct('data', data));
        
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX1, fullfile(filepath, [SFN, '.jpg']), 300);
        if ~exportOK
            warning('PGIXS:FigureExportFailed', '%s', exportReport.Message);
        end
        close(d);
        uialert(GUI.mainF, sprintf('Save Done!\nPath: %s', filepath), 'Success');
    end

    function CloseFig_Callback(~,~)
        delete(GUI.mainF);
        if ~isempty(parentFig) && isvalid(parentFig)
            figure(parentFig); drawnow;
        end
    end

    function Resize_Callback(src, ~) %#ok<DEFNU>
        referenceHeight = 650; 
        
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
