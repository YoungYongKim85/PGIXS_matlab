function XTrans_GUI
% XTrans_GUI v2.0 (Modern UI Update - Layout Fixed)
% Based on Zhang Jiang's Toolbox: X-ray Refraction of Matter
% FIXED: Properly aligned components in the Controls panel.

clc;

% ============================ GUI Setup ==================================
GUI.main = uifigure('Name',['X-ray Parameters Calculator v', pgixsVersion()],...
    'NumberTitle','off', 'Position',[200 200 900 550], 'Color', [0.96 0.96 0.96]);

% Main Grid
mainGrid = uigridlayout(GUI.main, [1 2]);
mainGrid.ColumnWidth = {280, '1x'};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 15;

% ========================= 1. Left Panel (Parameters) ====================
leftPanel = uipanel(mainGrid, 'Title', 'Parameters', 'FontSize', 14, 'FontWeight', 'bold');
leftPanel.Layout.Row = 1; leftPanel.Layout.Column = 1;

lg = uigridlayout(leftPanel, [11 2]);
lg.RowHeight = num2cell([25 25 25 25 25 25 25 25 25 45 20]);
lg.ColumnWidth = {'1x', '1x'};
lg.Padding = [10 15 10 10];
lg.RowSpacing = 10;

% Chemical Formula
lbl1 = uilabel(lg, 'Text', 'Chem. Formula:');
lbl1.Layout.Row = 1;

GUI.ChemForm = uieditfield(lg, 'text', 'Value', 'C8H8');
GUI.ChemForm.Layout.Row = 1; GUI.ChemForm.Layout.Column = 2;

% Mass Density
lbl2 = uilabel(lg, 'Text', 'Mass density [g/cm3]:');
lbl2.Layout.Row = 2;

GUI.MDensity = uieditfield(lg, 'numeric', 'Value', 1.05);
GUI.MDensity.Layout.Row = 2; GUI.MDensity.Layout.Column = 2;

% Thickness
lbl3 = uilabel(lg, 'Text', 'Thickness [um]:');
lbl3.Layout.Row = 3;

GUI.Thick = uieditfield(lg, 'numeric', 'Value', 100);
GUI.Thick.Layout.Row = 3; GUI.Thick.Layout.Column = 2;

% Energy Range
lbl4 = uilabel(lg, 'Text', 'Energy Range [keV]:', 'FontWeight', 'bold');
lbl4.Layout.Row = 5;

lbl5 = uilabel(lg, 'Text', 'Min:');
lbl5.Layout.Row = 6;

GUI.PE1 = uieditfield(lg, 'numeric', 'Value', 8.5);
GUI.PE1.Layout.Row = 6; GUI.PE1.Layout.Column = 2;

lbl6 = uilabel(lg, 'Text', 'Max:');
lbl6.Layout.Row = 7;

GUI.PE2 = uieditfield(lg, 'numeric', 'Value', 15.0);
GUI.PE2.Layout.Row = 7; GUI.PE2.Layout.Column = 2;

% Number of Points
lbl7 = uilabel(lg, 'Text', '# of points:');
lbl7.Layout.Row = 8;

GUI.NP = uieditfield(lg, 'numeric', 'Value', 50); 
GUI.NP.Layout.Row = 8; GUI.NP.Layout.Column = 2;

% Calculation Mode
lbl8 = uilabel(lg, 'Text', 'Mode:');
lbl8.Layout.Row = 9;

ModeList = {'Transmittance', 'Critical Angle', 'SLD (Real)', 'SLD (Imag)'};
GUI.hMode = uidropdown(lg, 'Items', ModeList);
GUI.hMode.Layout.Row = 9; GUI.hMode.Layout.Column = 2;

% Calculate Button
btnCalc = uibutton(lg, 'Text', 'RUN CALCULATION', 'FontSize', 13, 'FontWeight', 'bold', ...
    'BackgroundColor', [0.1 0.3 0.5], 'FontColor', 'w', 'ButtonPushedFcn', @Calc_Callback);
btnCalc.Layout.Row = 10; btnCalc.Layout.Column = [1 2];

lblVer = uilabel(lg, 'Text', ['Designed By Y.Y.Kim v', pgixsVersion()], 'FontSize', 9, 'FontColor', [0.5 0.5 0.5]);
lblVer.Layout.Row = 11; lblVer.Layout.Column = [1 2];

% ========================= 2. Right Panel (Plot & Control) ===============
rightGrid = uigridlayout(mainGrid, [2 1]);
rightGrid.RowHeight = {'1x', 80};
rightGrid.RowSpacing = 10;
rightGrid.Layout.Row = 1; rightGrid.Layout.Column = 2;

plotPanel = uipanel(rightGrid, 'Title', 'Result Plot', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'w');
plotPanel.Layout.Row = 1; plotPanel.Layout.Column = 1;
pg = uigridlayout(plotPanel, [1 1]); hAX = uiaxes(pg);

ctrlPanel = uipanel(rightGrid, 'Title', 'Controls', 'FontSize', 11, 'FontWeight', 'bold');
ctrlPanel.Layout.Row = 2; ctrlPanel.Layout.Column = 1;

% [버그 수정] 정확한 열(Column) 할당을 위해 2행 5열 레이아웃으로 변경
cg = uigridlayout(ctrlPanel, [2 5]);
cg.RowHeight = {20, 25}; 
cg.ColumnWidth = {80, 80, 70, '1x', '1x'};
cg.Padding = [10 10 10 10];
cg.ColumnSpacing = 15;

scaleList = {'linear', 'log'};

% Col 1: X Scale
lblX = uilabel(cg, 'Text', 'X Scale:');
lblX.Layout.Row = 1; lblX.Layout.Column = 1;

GUI.hXScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
GUI.hXScale.Layout.Row = 2; GUI.hXScale.Layout.Column = 1;

% Col 2: Y Scale
lblY = uilabel(cg, 'Text', 'Y Scale:');
lblY.Layout.Row = 1; lblY.Layout.Column = 2;

GUI.hYScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
GUI.hYScale.Layout.Row = 2; GUI.hYScale.Layout.Column = 2;

% Col 3: Grid Checkbox (가운데 정렬)
GUI.hGridCheck = uicheckbox(cg, 'Text', 'Grid On', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
GUI.hGridCheck.Layout.Row = [1 2]; GUI.hGridCheck.Layout.Column = 3;

% Col 4: Data Table
btnTable = uibutton(cg, 'Text', 'Data Table', 'FontWeight', 'bold', 'ButtonPushedFcn', @Table_Callback);
btnTable.Layout.Row = [1 2]; btnTable.Layout.Column = 4;

% Col 5: Save Data
btnSave = uibutton(cg, 'Text', 'Save Data', 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @SAVE_Callback);
btnSave.Layout.Row = [1 2]; btnSave.Layout.Column = 5;

param = struct();

% ============================ FUNCTIONS ==================================
    function Calc_Callback(~,~)
        Chem = GUI.ChemForm.Value; Mass = GUI.MDensity.Value;
        PE1 = GUI.PE1.Value; PE2 = GUI.PE2.Value; NP = round(GUI.NP.Value);
        PE = linspace(PE1, PE2, NP); T = GUI.Thick.Value;

        try
            R = refrac(Chem, PE, Mass);
        catch ME
            uialert(GUI.main, ['Refract function error: ', ME.message], 'Error');
            return; 
        end

        param.XData = PE(:)'; 
        
        M = GUI.hMode.Value;
        switch M
            case 'Transmittance'
                att = R.attLength(:)' .* 10; % cm to mm
                T_mm = T * 1e-3;
                param.YData = exp(-T_mm ./ cosd(0) ./ att);
                
            case 'Critical Angle'
                param.YData = R.criticalAngle(:)';
                
            case 'SLD (Real)'
                param.YData = R.reSLD(:)' .* 1e6; 
                
            case 'SLD (Imag)'
                param.YData = R.imSLD(:)' .* 1e6; 
        end 
        
        updateplot();
    end

    function updateplot()
        if ~isfield(param, 'YData'), return; end
        
        cla(hAX); 
        plot(hAX, param.XData, param.YData, '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
        xlabel(hAX, 'Photon Energy [keV]'); 
        
        if contains(GUI.hMode.Value, 'SLD')
            ylabel(hAX, 'SLD (10^{-6} A^{-2})', 'Interpreter', 'tex');
        else
            ylabel(hAX, GUI.hMode.Value, 'Interpreter', 'none');
        end
        
        set(hAX, 'XScale', GUI.hXScale.Value, 'YScale', GUI.hYScale.Value);
        if GUI.hGridCheck.Value, grid(hAX, 'on'); else, grid(hAX, 'off'); end
    end

    function Table_Callback(~,~)
        if ~isfield(param, 'YData'), return; end
        
        colName = strrep(GUI.hMode.Value, ' ', '_');
        colName = strrep(colName, '(', '');
        colName = strrep(colName, ')', '');
        
        T = table(param.XData', param.YData', 'VariableNames', {'Energy_keV', colName});
        f = uifigure('Name', 'Data Table', 'Position', [400 300 300 400]);
        uitable(f, 'Data', T, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.9]);
    end

    function SAVE_Callback(~,~)
        if ~isfield(param, 'YData'), return; end
        
        folderName = strrep(GUI.hMode.Value, ' ', '_');
        folderName = strrep(folderName, '(', '');
        folderName = strrep(folderName, ')', '');
        
        [basePath, ok, saveReport] = ensurePGIXSSaveDir(pwd, folderName, pwd);
        if ~ok
            uialert(GUI.main, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        
        SFN = sprintf('%s_%g_to_%g', folderName, GUI.PE1.Value, GUI.PE2.Value);
        
        saveData = [param.XData', param.YData'];
        savePGIXSDataFile(fullfile(basePath, [SFN, '.dat']), '.dat', saveData, struct('saveData', saveData));
        
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX, fullfile(basePath, [SFN, '.jpg']), 300);
        if ~exportOK
            warning('PGIXS:FigureExportFailed', '%s', exportReport.Message);
        end
        uialert(GUI.main, ['Saved to: ', basePath], 'Success');
    end

    function Updateplot_Callback(~,~), updateplot(); end
end
