function Penetration_GUI
% Penetration_GUI v2.0 (Modern UI Update)
% Based on Zhang Jiang's Toolbox: X-ray Refraction of Matter
% Designed By Y.Y.Kim (PLS-II BL3C) / UI Upgraded
% FIXED: Unchained all Layout property assignments, fixed typos.

clc;

% ============================ GUI Setup ==================================
GUI.main = uifigure('Name',['X-ray Penetration Depth Calculator v', pgixsVersion()],...
    'NumberTitle','off', 'Position',[200 200 900 600], 'Color', [0.96 0.96 0.96]);

% Main Grid (Left: Parameters & Info, Right: Plot & Control)
mainGrid = uigridlayout(GUI.main, [1 2]);
mainGrid.ColumnWidth = {300, '1x'};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 15;

% ========================= 1. Left Panel =================================
leftGrid = uigridlayout(mainGrid, [2 1]);
leftGrid.RowHeight = {'1.5x', '1x'};
leftGrid.Padding = [0 0 0 0];
leftGrid.RowSpacing = 15;
leftGrid.Layout.Row = 1; leftGrid.Layout.Column = 1;

% --- 1A. Parameters Panel ---
paramPanel = uipanel(leftGrid, 'Title', 'Parameters', 'FontSize', 14, 'FontWeight', 'bold');
paramPanel.Layout.Row = 1; paramPanel.Layout.Column = 1;

pg = uigridlayout(paramPanel, [8 2]);
pg.RowHeight = num2cell([25 25 25 25 25 25 35 20]);
pg.ColumnWidth = {'1x', '1x'};
pg.Padding = [10 15 10 10];
pg.RowSpacing = 10;

% Chemical Formula
lbl1 = uilabel(pg, 'Text', 'Chem. Formula:');
lbl1.Layout.Row = 1;

GUI.ChemForm = uieditfield(pg, 'text', 'Value', 'Si');
GUI.ChemForm.Layout.Row = 1; GUI.ChemForm.Layout.Column = 2;

% Mass Density
lbl2 = uilabel(pg, 'Text', 'Mass density [g/cm3]:');
lbl2.Layout.Row = 2;

GUI.MDensity = uieditfield(pg, 'numeric', 'Value', 2.329);
GUI.MDensity.Layout.Row = 2; GUI.MDensity.Layout.Column = 2;

% Photon Energy
lbl3 = uilabel(pg, 'Text', 'Photon Energy [keV]:');
lbl3.Layout.Row = 3;

GUI.hEnergy = uieditfield(pg, 'numeric', 'Value', 11.3);
GUI.hEnergy.Layout.Row = 3; GUI.hEnergy.Layout.Column = 2;

% Incidence Angle Range
lbl4 = uilabel(pg, 'Text', 'Angle Range [deg]:', 'FontWeight', 'bold');
lbl4.Layout.Row = 4;

lbl5 = uilabel(pg, 'Text', 'Min:');
lbl5.Layout.Row = 5;

GUI.hAng1 = uieditfield(pg, 'numeric', 'Value', 0);
GUI.hAng1.Layout.Row = 5; GUI.hAng1.Layout.Column = 2;

lbl6 = uilabel(pg, 'Text', 'Max:');
lbl6.Layout.Row = 6;

GUI.hAng2 = uieditfield(pg, 'numeric', 'Value', 1);
GUI.hAng2.Layout.Row = 6; GUI.hAng2.Layout.Column = 2;

% Calculate Button
btnCalc = uibutton(pg, 'Text', 'RUN CALCULATION', 'FontSize', 13, 'FontWeight', 'bold', ...
    'BackgroundColor', [0.1 0.3 0.5], 'FontColor', 'w', 'ButtonPushedFcn', @Calc_Callback);
btnCalc.Layout.Row = 7; btnCalc.Layout.Column = [1 2];

lblVer = uilabel(pg, 'Text', ['Designed By Y.Y.Kim v', pgixsVersion()], 'FontSize', 9, 'FontColor', [0.5 0.5 0.5]);
lblVer.Layout.Row = 8; lblVer.Layout.Column = [1 2];


% --- 1B. Info Panel ---
infoPanel = uipanel(leftGrid, 'Title', 'Information', 'FontSize', 14, 'FontWeight', 'bold');
infoPanel.Layout.Row = 2; infoPanel.Layout.Column = 1;

ig = uigridlayout(infoPanel, [3 1]);
ig.RowHeight = {30, 30, 30};
ig.Padding = [15 15 15 15];

GUI.lblDelta = uilabel(ig, 'Text', 'Delta (\delta): -', 'FontSize', 13);
GUI.lblDelta.Layout.Row = 1; GUI.lblDelta.Layout.Column = 1;

GUI.lblBeta = uilabel(ig, 'Text', 'Beta (\beta): -', 'FontSize', 13);
GUI.lblBeta.Layout.Row = 2; GUI.lblBeta.Layout.Column = 1;

GUI.lblCrit = uilabel(ig, 'Text', 'Critical Angle: -', 'FontSize', 13, 'FontColor', 'r', 'FontWeight', 'bold');
GUI.lblCrit.Layout.Row = 3; GUI.lblCrit.Layout.Column = 1;


% ========================= 2. Right Panel (Plot & Control) ===============
rightGrid = uigridlayout(mainGrid, [2 1]);
rightGrid.RowHeight = {'1x', 80};
rightGrid.RowSpacing = 10;
rightGrid.Layout.Row = 1; rightGrid.Layout.Column = 2;

% Plot Area
plotPanel = uipanel(rightGrid, 'Title', 'Result Plot', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'w');
plotPanel.Layout.Row = 1; plotPanel.Layout.Column = 1;
pgPlot = uigridlayout(plotPanel, [1 1]); hAX = uiaxes(pgPlot);

% Controller Area
ctrlPanel = uipanel(rightGrid, 'Title', 'Controls', 'FontSize', 11, 'FontWeight', 'bold');
ctrlPanel.Layout.Row = 2; ctrlPanel.Layout.Column = 1;

cg = uigridlayout(ctrlPanel, [2 4]);
cg.RowHeight = {20, 25}; 
cg.ColumnWidth = {80, 80, '1x', '1x'};
cg.Padding = [10 10 10 10];
cg.ColumnSpacing = 15;

scaleList = {'linear', 'log'};

% Y Scale
lblY = uilabel(cg, 'Text', 'Y Scale:');
lblY.Layout.Row = 1; lblY.Layout.Column = 1;

GUI.hYScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
GUI.hYScale.Layout.Row = 2; GUI.hYScale.Layout.Column = 1;

% Grid Checkbox
GUI.hGridCheck = uicheckbox(cg, 'Text', 'Grid On', 'Value', 1, 'ValueChangedFcn', @Updateplot_Callback);
GUI.hGridCheck.Layout.Row = [1 2]; GUI.hGridCheck.Layout.Column = 2;

% Data Table
btnTable = uibutton(cg, 'Text', 'Data Table', 'FontWeight', 'bold', 'ButtonPushedFcn', @Table_Callback);
btnTable.Layout.Row = [1 2]; btnTable.Layout.Column = 3;

% Save Data
btnSave = uibutton(cg, 'Text', 'Save Data', 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @SAVE_Callback);
btnSave.Layout.Row = [1 2]; btnSave.Layout.Column = 4;

param = struct();

% ============================ FUNCTIONS ==================================
    function Calc_Callback(~,~)
        Chem = GUI.ChemForm.Value; 
        Mass = GUI.MDensity.Value;
        PE = GUI.hEnergy.Value;
        Ang1 = GUI.hAng1.Value;
        Ang2 = GUI.hAng2.Value;
        
        % 200 points for smooth curve
        param.alphai = linspace(Ang1, Ang2, 200);
        
        try
            R = refrac(Chem, PE, Mass);
        catch ME
            uialert(GUI.main, ['Refract function error: ', ME.message], 'Error');
            return;
        end

        % Original physics calculation logic
        h = 4.1357e-15; % Plank's constant
        c = 2.99792458e8; % Speed of light in vacuum
        wavelength = h * c / (PE * 1e3) * 1e10;

        delta = R.dispersion;
        beta = R.absorption;
        alpha_c = R.criticalAngle;

        % Penetration depth calculation
        th_i = deg2rad(param.alphai);
        th_c = deg2rad(alpha_c);
        
        inner_sqrt = sqrt((th_i.^2 - th_c.^2).^2 + (4 .* beta.^2));
        lp = wavelength ./ ( (4 .* pi ./ sqrt(2)) .* sqrt(inner_sqrt - (th_i.^2 - th_c.^2)) );
    
        param.alphac = alpha_c;
        param.lp = lp;

        % Update Info Panel (using scientific notation for delta/beta for readability)
        GUI.lblDelta.Text = sprintf('Delta (\\delta): %1.4e', delta);
        GUI.lblBeta.Text = sprintf('Beta (\\beta): %1.4e', beta);
        GUI.lblCrit.Text = sprintf('Critical Angle: %.4f deg', alpha_c);

        updateplot();
    end

    function updateplot()
        if ~isfield(param, 'lp'), return; end
        
        col = [0 0.4470 0.7410];
        YSc = GUI.hYScale.Value;
        
        cla(hAX); 
        
        % Plot penetration depth in nm (lp/10)
        plot(hAX, param.alphai, param.lp ./ 10, '-o', 'MarkerFaceColor', col, 'LineWidth', 1.5, 'Color', col); 
        hold(hAX, 'on');
        
        % Draw critical angle vertical line
        xline(hAX, param.alphac, '--r', 'LineWidth', 1.5); 
        hold(hAX, 'off');
        
        axis(hAX, 'tight');
        xlabel(hAX, 'Incidence Angle [deg]');
        ylabel(hAX, 'Penetration Depth [nm]');
        
        set(hAX, 'YScale', YSc);
        if GUI.hGridCheck.Value, grid(hAX, 'on'); else, grid(hAX, 'off'); end
    end

    function Table_Callback(~,~)
        if ~isfield(param, 'lp'), return; end
        
        Data = cat(2, param.alphai', (param.lp ./ 10)');
        Tb = array2table(Data, 'VariableNames', {'Incidence_Angle_deg', 'Penetration_Depth_nm'});

        f = uifigure('Name', 'Data Table', 'Position', [400 300 300 400]);
        uitable(f, 'Data', Tb, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.9]);
    end

    function SAVE_Callback(~,~)
        if ~isfield(param, 'lp'), return; end
        
        Ang1 = GUI.hAng1.Value;
        Ang2 = GUI.hAng2.Value;
        
        % Create directory in current path
        [basePath, ok, saveReport] = ensurePGIXSSaveDir(pwd, 'PenetrationDepth', pwd);
        if ~ok
            uialert(GUI.main, ['Save directory error: ', saveReport.Message], 'Error');
            return;
        end
        
        SFN = sprintf('PenetrationDepth_%g_to_%g', Ang1, Ang2);
        
        % Save Data
        Data = cat(2, param.alphai', (param.lp ./ 10)');
        savePGIXSDataFile(fullfile(basePath, [SFN, '.dat']), '.dat', Data, struct('Data', Data));

        % Save Figure
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX, fullfile(basePath, [SFN, '.jpg']), 300);
        if ~exportOK
            warning('PGIXS:FigureExportFailed', '%s', exportReport.Message);
        end
        
        uialert(GUI.main, sprintf('Saved successfully!\n%s', basePath), 'Success');
    end

    function Updateplot_Callback(~,~), updateplot(); end
end
