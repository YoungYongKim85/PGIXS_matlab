function TrXS_gui
% TrXS_gui v2.0 - Transmission X-ray Scattering Analysis GUI (Modern UI)
% Designed for 3C beamline user at PLS-II (Designed By Y.Y.Kim)
% FIXED: Completely unchained all Layout property assignments to prevent index errors.

% [환경 진단 방어 코드]
if exist('uilabel', 'builtin') == 0 && exist('uilabel', 'file') == 0
    errordlg(['현재 매트랩이 모던 UI(uilabel)를 전혀 인식하지 못합니다. ' ...
              '바탕화면의 실행 아이콘이 구버전 매트랩을 가리키고 있는지 확인해 주세요! ' ...
              '(명령창에 ''version''을 입력해 보세요)'], '버전 오류');
    return;
end

clc;

% ============================ GUI Setup ==================================
GUI.main = uifigure('Name','Transmission X-ray Scattering v2.0',...
    'NumberTitle','off', 'Position',[100 50 1200 850], ...
    'Color', [0.96 0.96 0.96]);

movegui(GUI.main, 'center');

% Color & List definitions
detectorList = {'Eiger4M', 'MarCCD', 'MX170HS', 'PI_CCD'};
NormalList = {'None','IC','BC'};
scaleList = {'Linear', 'Log'};
ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis',...
    'cubehelix','magma','kindlemann','jet2','ocean','rwb','rkb'};
MapList = {'Pixel', 'Qy/Qz'};
SvForm = {'.jpg', '.png', '.tif'};

TX = struct();

% ============================ Main Layout Grid ===========================
mainGrid = uigridlayout(GUI.main, [1 2]);
mainGrid.ColumnWidth = {380, '1x'};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 15;

% ========================= 1. Left Panel (Parameters) ====================
leftPanel = uipanel(mainGrid, 'Title', 'Single Data Analysis', 'FontSize', 14, 'FontWeight', 'bold');
leftPanel.Layout.Row = 1; leftPanel.Layout.Column = 1;

lg = uigridlayout(leftPanel, [23 6]);
lg.RowHeight = num2cell([repmat(25, 1, 21), 20, 20]);
lg.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
lg.Padding = [10 10 10 10];
lg.RowSpacing = 8; lg.ColumnSpacing = 5;

% --- Row 1: Directory ---
lbl1 = uilabel(lg, 'Text', 'Directory'); 
lbl1.Layout.Row = 1; lbl1.Layout.Column = 1;
TX.pathset = uieditfield(lg, 'text', 'Value', pwd); 
TX.pathset.Layout.Row = 1; TX.pathset.Layout.Column = [2 5];
btn1 = uibutton(lg, 'Text', 'Set', 'ButtonPushedFcn', @pathset_Callback); 
btn1.Layout.Row = 1; btn1.Layout.Column = 6;

% --- Row 2: Detector & Multishot ---
lbl2 = uilabel(lg, 'Text', 'Detector:'); 
lbl2.Layout.Row = 2; lbl2.Layout.Column = [1 2];
GUI.hDetector = uidropdown(lg, 'Items', detectorList); 
GUI.hDetector.Layout.Row = 2; GUI.hDetector.Layout.Column = [3 4];
GUI.hMultishot = uicheckbox(lg, 'Text', 'Multishot', 'Value', 0); 
GUI.hMultishot.Layout.Row = 2; GUI.hMultishot.Layout.Column = [5 6];

% --- Row 3: Load Data Button ---
btnLoad = uibutton(lg, 'Text', 'LOAD DATA', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.3 0.5], 'FontColor', 'w', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Load Data', @()Openimage_Callback([], [])));
btnLoad.Layout.Row = 3; btnLoad.Layout.Column = [1 6];

% --- Row 4: IC SC BC ---
lbl3 = uilabel(lg, 'Text', 'IC:'); 
lbl3.Layout.Row = 4; lbl3.Layout.Column = 1;
TX.IC = uilabel(lg, 'Text', '0'); 
TX.IC.Layout.Row = 4; TX.IC.Layout.Column = 2;

lbl5 = uilabel(lg, 'Text', 'BC:'); 
lbl5.Layout.Row = 4; lbl5.Layout.Column = 3;
TX.BC = uilabel(lg, 'Text', '0'); 
TX.BC.Layout.Row = 4; TX.BC.Layout.Column = 4;

% --- Row 5: Energy & SDD ---
lbl6 = uilabel(lg, 'Text', 'Energy [keV]:'); 
lbl6.Layout.Row = 5; lbl6.Layout.Column = [1 2];
TX.hEnergy = uieditfield(lg, 'numeric', 'Value', 9.5); 
TX.hEnergy.Layout.Row = 5; TX.hEnergy.Layout.Column = [3 4];
btnLoadInfo = uibutton(lg, 'Text', 'Load Info', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Load Info', @()Openinfo_Callback([], []))); 
btnLoadInfo.Layout.Row = 5; btnLoadInfo.Layout.Column = [5 6];

% --- Row 6: SDD ---
lbl7 = uilabel(lg, 'Text', 'SDD [mm]:'); 
lbl7.Layout.Row = 6; lbl7.Layout.Column = [1 2];
TX.hSDD = uieditfield(lg, 'numeric', 'Value', 3000); 
TX.hSDD.Layout.Row = 6; TX.hSDD.Layout.Column = [3 4];

% --- Row 7: Center ---
lbl8 = uilabel(lg, 'Text', 'Center [y,z]:'); 
lbl8.Layout.Row = 7; lbl8.Layout.Column = [1 2];
TX.hyPOS = uieditfield(lg, 'numeric', 'Value', 1000); 
TX.hyPOS.Layout.Row = 7; TX.hyPOS.Layout.Column = 3;
TX.hzPOS = uieditfield(lg, 'numeric', 'Value', 1800); 
TX.hzPOS.Layout.Row = 7; TX.hzPOS.Layout.Column = 4;

% --- Row 8: Bkg ---
lbl9 = uilabel(lg, 'Text', 'Background:'); 
lbl9.Layout.Row = 8; lbl9.Layout.Column = [1 2];
btnBkg = uibutton(lg, 'Text', 'Load Bkg.', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Load Background', @()Bkgload_Callback([], []))); 
btnBkg.Layout.Row = 8; btnBkg.Layout.Column = [3 6];

% --- Row 9: Normal ---
lbl10 = uilabel(lg, 'Text', 'Normal:'); 
lbl10.Layout.Row = 9; lbl10.Layout.Column = 1;
GUI.hNormal = uidropdown(lg, 'Items', NormalList); 
GUI.hNormal.Layout.Row = 9; GUI.hNormal.Layout.Column = [2 3];

lbl11 = uilabel(lg, 'Text', 'Multi:'); 
lbl11.Layout.Row = 9; lbl11.Layout.Column = 4;
TX.Plusdata = uieditfield(lg, 'numeric', 'Value', 1); 
TX.Plusdata.Layout.Row = 9; TX.Plusdata.Layout.Column = [5 6];

% --- Row 10: Bkg Sub ---
btnSub = uibutton(lg, 'Text', 'BKG Sub. & Norm', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Background Subtract Normalize', @()Subtraction_Callback([], []))); 
btnSub.Layout.Row = 10; btnSub.Layout.Column = [1 6];

% --- Row 11: Grid Remove & Q-map ---
btnGrid = uibutton(lg, 'Text', 'Grid Remove', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Grid Remove', @()GridRemove_Callback([], []))); 
btnGrid.Layout.Row = 11; btnGrid.Layout.Column = [1 3];
btnQmap = uibutton(lg, 'Text', 'q-Map Cal.', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS q-Map Cal', @()Correction_Callback([], []))); 
btnQmap.Layout.Row = 11; btnQmap.Layout.Column = [4 6];

% --- Row 12: Divider 1 ---
lbl12 = uilabel(lg, 'Text', '--- [ 1D Plot Process ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
lbl12.Layout.Row = 12; lbl12.Layout.Column = [1 6];

% --- Row 13: Median / Std ---
lblMinCoverage = uilabel(lg, 'Text', 'Min cov:');
lblMinCoverage.Layout.Row = 13; lblMinCoverage.Layout.Column = 1;
TX.hMinCoverage = uieditfield(lg, 'numeric', 'Value', 0.80, ...
    'Limits', [0 1], 'LowerLimitInclusive', 'on', 'UpperLimitInclusive', 'on');
TX.hMinCoverage.Layout.Row = 13; TX.hMinCoverage.Layout.Column = 2;
GUI.hMedianB = uicheckbox(lg, 'Text', 'Median', 'Value', 0); 
GUI.hMedianB.Layout.Row = 13; GUI.hMedianB.Layout.Column = [3 4]; % 시작점은 '0' 위로 맞추되 폭을 넉넉히 줌
GUI.hStdI = uicheckbox(lg, 'Text', 'Std', 'Value', 0); 
GUI.hStdI.Layout.Row = 13; GUI.hStdI.Layout.Column = [5 6];

% --- Row 14: Ang Avg ---
lbl13 = uilabel(lg, 'Text', 'Ang. Avg:'); 
lbl13.Layout.Row = 14; lbl13.Layout.Column = [1 2];
TX.hAng1dmin = uieditfield(lg, 'numeric', 'Value', 0); 
TX.hAng1dmin.Layout.Row = 14; TX.hAng1dmin.Layout.Column = 3;
TX.hAng1dmax = uieditfield(lg, 'numeric', 'Value', 360); 
TX.hAng1dmax.Layout.Row = 14; TX.hAng1dmax.Layout.Column = 4;
btnPlotAvg = uibutton(lg, 'Text', 'Plot', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Circular Average', @()CircularAve_Callback([], []))); 
btnPlotAvg.Layout.Row = 14; btnPlotAvg.Layout.Column = [5 6];

% --- Row 15: 1D Line ---
lbl14 = uilabel(lg, 'Text', '1D Line Ang:'); 
lbl14.Layout.Row = 15; lbl14.Layout.Column = [1 2];
TX.h1dphi = uieditfield(lg, 'numeric', 'Value', 0); 
TX.h1dphi.Layout.Row = 15; TX.h1dphi.Layout.Column = [3 4];
btnLine = uibutton(lg, 'Text', 'Line', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Draw Line', @()Drawline_Callback([], []))); 
btnLine.Layout.Row = 15; btnLine.Layout.Column = 5;
btnLinePlot = uibutton(lg, 'Text', 'Plot', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Line Plot', @()Lineplot_Callback([], []))); 
btnLinePlot.Layout.Row = 15; btnLinePlot.Layout.Column = 6;

% --- Row 16: Divider 2 ---
lbl15 = uilabel(lg, 'Text', '--- [ Azimuthal Process ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
lbl15.Layout.Row = 16; lbl15.Layout.Column = [1 6];

% --- Row 17: Pixel ---
lbl16 = uilabel(lg, 'Text', 'Pixel:'); 
lbl16.Layout.Row = 17; lbl16.Layout.Column = 1;
TX.azipospix = uieditfield(lg, 'numeric', 'Value', 202, 'ValueChangedFcn', @CalcPos_Callback); 
TX.azipospix.Layout.Row = 17; TX.azipospix.Layout.Column = [2 3];
lbl17 = uilabel(lg, 'Text', 'Rng (-/+):'); 
lbl17.Layout.Row = 17; lbl17.Layout.Column = [4 5];

% --- Row 18: Range min max ---
TX.azipospixm = uieditfield(lg, 'numeric', 'Value', -1, 'ValueChangedFcn', @CalcPos_Callback); 
TX.azipospixm.Layout.Row = 18; TX.azipospixm.Layout.Column = 4;
TX.azipospixp = uieditfield(lg, 'numeric', 'Value', 1, 'ValueChangedFcn', @CalcPos_Callback); 
TX.azipospixp.Layout.Row = 18; TX.azipospixp.Layout.Column = 5;

% --- Row 19: Q ---
lbl18 = uilabel(lg, 'Text', 'Q [1/A]:'); 
lbl18.Layout.Row = 19; lbl18.Layout.Column = 1;
TX.Qpospix = uieditfield(lg, 'numeric', 'Value', 1, 'Editable', 'off'); 
TX.Qpospix.Layout.Row = 19; TX.Qpospix.Layout.Column = [2 3];
TX.Qpospixm = uieditfield(lg, 'numeric', 'Value', 0, 'Editable', 'off'); 
TX.Qpospixm.Layout.Row = 19; TX.Qpospixm.Layout.Column = 4;
TX.Qpospixp = uieditfield(lg, 'numeric', 'Value', 0, 'Editable', 'off'); 
TX.Qpospixp.Layout.Row = 19; TX.Qpospixp.Layout.Column = 5;

% --- Row 20: Actions ---
btnPoint = uibutton(lg, 'Text', 'Point Find', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Point Find', @()PointFind_Callback([], []))); 
btnPoint.Layout.Row = 20; btnPoint.Layout.Column = [1 2];
GUI.hMeanMed = uidropdown(lg, 'Items', {'Mean', 'Median'}); 
GUI.hMeanMed.Layout.Row = 20; GUI.hMeanMed.Layout.Column = [3 4];

% --- Row 21: Draw / Plot ---
btnAziDraw = uibutton(lg, 'Text', 'Draw', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Draw Azimuthal', @()DrawPlot_Callback([], []))); 
btnAziDraw.Layout.Row = 21; btnAziDraw.Layout.Column = [3 4];
btnAziPlot = uibutton(lg, 'Text', 'Plot', 'ButtonPushedFcn', @(~,~)runLoggedAction('TrXS Azimuthal Plot', @()AziPlot_Callback([], []))); 
btnAziPlot.Layout.Row = 21; btnAziPlot.Layout.Column = [5 6];

lbl19 = uilabel(lg, 'Text', 'Designed By Y.Y.Kim v2.0', 'FontSize', 9, 'FontColor', [0.5 0.5 0.5]);
lbl19.Layout.Row = 23; lbl19.Layout.Column = [1 6];

% ========================= 2. Right Panel (Plot & Control) ===============
rightGrid = uigridlayout(mainGrid, [2 1]);
rightGrid.RowHeight = {'1x', 110};
rightGrid.RowSpacing = 10;
rightGrid.Layout.Row = 1; rightGrid.Layout.Column = 2;

% Plot Area
plotPanel = uipanel(rightGrid, 'Title', '2D Plot Viewer', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'w');
plotPanel.Layout.Row = 1; plotPanel.Layout.Column = 1;
pgPlot = uigridlayout(plotPanel, [1 1]); hAX = uiaxes(pgPlot);

% Controller Area
ctrlPanel = uipanel(rightGrid, 'Title', 'Image Controller', 'FontSize', 11, 'FontWeight', 'bold');
ctrlPanel.Layout.Row = 2; ctrlPanel.Layout.Column = 1;

cg = uigridlayout(ctrlPanel, [2 8]);
cg.RowHeight = {25, 30}; 
cg.ColumnWidth = {'1x', '1x', '1.2x', '1x', '1.2x', '1.2x', '0.8x', '1.2x'};
cg.Padding = [10 5 10 5]; cg.ColumnSpacing = 8;

% Col 1: ColorScale
lbl20 = uilabel(cg, 'Text', 'ColorScale:'); 
lbl20.Layout.Row = 1; lbl20.Layout.Column = 1;
GUI.hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateimage_Callback); 
GUI.hScale.Layout.Row = 2; GUI.hScale.Layout.Column = 1;

% Col 2: Colormap
lbl21 = uilabel(cg, 'Text', 'Colormap:'); 
lbl21.Layout.Row = 1; lbl21.Layout.Column = 2;
GUI.hColor = uidropdown(cg, 'Items', ColormapList, 'ValueChangedFcn', @Updateimage_Callback); 
GUI.hColor.Layout.Row = 2; GUI.hColor.Layout.Column = 2;

% Col 3: C-Min/Max
lbl22 = uilabel(cg, 'Text', 'Min / Max:'); 
lbl22.Layout.Row = 1; lbl22.Layout.Column = 3;
subC1 = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); 
subC1.Layout.Row = 2; subC1.Layout.Column = 3;
TX.cMin = uieditfield(subC1, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage_Callback); 
TX.cMax = uieditfield(subC1, 'numeric', 'Value', 1e6, 'ValueChangedFcn', @Updateimage_Callback);

% Col 4: Map Format
lbl23 = uilabel(cg, 'Text', 'Map format:'); 
lbl23.Layout.Row = 1; lbl23.Layout.Column = 4;
GUI.hMapping = uidropdown(cg, 'Items', MapList, 'ValueChangedFcn', @Rangecal_Callback); 
GUI.hMapping.Layout.Row = 2; GUI.hMapping.Layout.Column = 4;

% Col 5: Y-Range
lbl24 = uilabel(cg, 'Text', 'Y-Range:'); 
lbl24.Layout.Row = 1; lbl24.Layout.Column = 5;
subC2 = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); 
subC2.Layout.Row = 2; subC2.Layout.Column = 5;
TX.cXlim1 = uieditfield(subC2, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage_Callback);
TX.cXlim2 = uieditfield(subC2, 'numeric', 'Value', 2000, 'ValueChangedFcn', @Updateimage_Callback);

% Col 6: Z-Range
lbl25 = uilabel(cg, 'Text', 'Z-Range:'); 
lbl25.Layout.Row = 1; lbl25.Layout.Column = 6;
subC3 = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); 
subC3.Layout.Row = 2; subC3.Layout.Column = 6;
TX.cYlim1 = uieditfield(subC3, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage_Callback);
TX.cYlim2 = uieditfield(subC3, 'numeric', 'Value', 2000, 'ValueChangedFcn', @Updateimage_Callback);

% Col 7: Font 
lbl26 = uilabel(cg, 'Text', 'Font Sz:'); 
lbl26.Layout.Row = 1; lbl26.Layout.Column = 7;
TX.FontSz = uieditfield(cg, 'numeric', 'Value', 18, 'ValueChangedFcn', @Updateimage_Callback); 
TX.FontSz.Layout.Row = 2; TX.FontSz.Layout.Column = 7;

% Col 8: Save
GUI.hSvForm = uidropdown(cg, 'Items', SvForm); 
GUI.hSvForm.Layout.Row = 1; GUI.hSvForm.Layout.Column = 8;
btnSaveImg = uibutton(cg, 'Text', 'Save Image', 'BackgroundColor', [0.9 0.95 1], 'FontWeight', 'bold', 'ButtonPushedFcn', @Savefile_Callback); 
btnSaveImg.Layout.Row = 2; btnSaveImg.Layout.Column = 8;

param = initializeParams();

% =========================================================================
% ====================== HELPER & CALLBACK FUNCTIONS ======================
% =========================================================================

    function runLoggedAction(actionName, callbackFcn)
        ensurePGIXSFunctionsPath();
        runPGIXSCallback(GUI.main, actionName, callbackFcn, ...
            @()summarizePGIXSState(param, actionName, struct('GUI', 'TrXS_gui')));
    end

    function ensurePGIXSFunctionsPath()
        if exist('runPGIXSCallback', 'file') == 2
            return;
        end
        guiDir = fileparts(mfilename('fullpath'));
        repoRoot = fileparts(fileparts(fileparts(guiDir)));
        functionsDir = fullfile(repoRoot, 'functions');
        if isfolder(functionsDir)
            addpath(genpath(functionsDir));
        end
    end

    function [BW, userSelected] = selectROIMask(data2d, p)
        % ROI 마스크 선택 헬퍼 (CircularAve / DrawPlot 공용)
        % 반환: BW (NaN mask), userSelected (true/false)
        BW = []; userSelected = false;
        
        selection = uiconfirm(GUI.main, 'Do you need a mask?', ...
            'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'Yes');
        if ~strcmp(selection, 'Yes'), return; end
        
        scrSize = get(0, 'ScreenSize');
        scrW = scrSize(3); scrH = scrSize(4);
        [imgH, imgW] = size(data2d);
        imgRatio = imgW / imgH;
        figH = scrH * 0.9; figW = figH * imgRatio;
        if figW > scrW * 0.9, figW = scrW * 0.9; figH = figW / imgRatio; end
        figX = (scrW - figW) / 2; figY = (scrH - figH) / 2;
        
        f1 = figure('Name','Select ROI', 'Units', 'pixels', ...
            'Position', [figX, figY, figW, figH], ...
            'Menubar','none','ToolBar','none','DockControls','off');
        
        targetAx = axes(f1);
        imagesc(targetAx, data2d); axis(targetAx, 'image');
        
        applyPGIXSAxesColorScale(targetAx, p.colorscale);
        clim(targetAx, [p.cmin, p.cmax]);
        applyColormap(p.colorm, data2d, targetAx);
        
        BW = roipoly;
        BW = double(BW); BW = abs(BW-1); BW(BW==0) = nan;
        close(f1);
        userSelected = true;
    end

    function applyColormap(colormapName, data, targetAx)
        if nargin < 3
            targetAx = hAX; % 별도 지정이 없으면 메인 화면(hAX)에 색상 적용
        end
        applyPGIXSColormap(targetAx, colormapName, data);
    end

    function hcb = setupColorbar()
        hcb = colorbar(hAX);
        hcb.LineWidth = 2;
        hcb.TickDirection = 'out';
        hcb.Label.String = 'Intensity, arb. units';
        hcb.Label.FontSize = 16;
    end

    function setupAxesStyle(fontsize, titleStr)
        set(hAX, 'LineWidth', 2, 'Tickdir', 'in', 'FontSize', fontsize, 'FontName', 'times');
        if nargin > 1 && ~isempty(titleStr)
            title(hAX, titleStr, 'Interpreter', 'none', 'FontSize', 11);
        end
    end

    function p = getUIParams()
        p.colorscale = GUI.hScale.Value;
        p.colorm = GUI.hColor.Value;
        p.Mapping = GUI.hMapping.Value;
        p.cmax = TX.cMax.Value;
        p.cmin = TX.cMin.Value;
        p.xlimmin = TX.cXlim1.Value;
        p.xlimmax = TX.cXlim2.Value;
        p.ylimmin = TX.cYlim1.Value;
        p.ylimmax = TX.cYlim2.Value;
        p.fontsize = TX.FontSz.Value;
    end

    function renderImage(overlayFunc)
        uiParams = getUIParams();
        param.colorscale = uiParams.colorscale; param.colorm = uiParams.colorm;
        param.Mapping = uiParams.Mapping; param.cmax = uiParams.cmax;
        param.cmin = uiParams.cmin; param.xlimmin = uiParams.xlimmin;
        param.xlimmax = uiParams.xlimmax; param.ylimmin = uiParams.ylimmin;
        param.ylimmax = uiParams.ylimmax; param.fontsize = uiParams.fontsize;
        
        cla(hAX);
        
        switch param.Mapping
            case 'Pixel'
                imagesc(hAX, param.HD, param.VD, param.data);
                if param.Expinfo == 0, set(hAX, 'YDir', 'reverse');
                else, set(hAX, 'YDir', 'normal'); end
                xlabel(hAX, 'Y, pixel'); ylabel(hAX, 'Z, pixel');
                
            case 'Qy/Qz'
                if isfield(param, 'Itrans')
                    imagesc(hAX, param.qy, param.qz, param.Itrans);
                    set(hAX, 'YDir', 'normal');
                    xlabel(hAX, '$q_y, \textrm{\AA}^{-1}$','Interpreter','latex','Fontname','TimesNewRoman');
                    ylabel(hAX, '$q_z, \textrm{\AA}^{-1}$','Interpreter','latex','Fontname','TimesNewRoman');
                else
                    uialert(GUI.main, 'Please do Q-Map correction first!','Warning'); return; 
                end
        end
        
        axis(hAX, 'image');
        set(hAX, 'XLim', [param.xlimmin, param.xlimmax], 'YLim', [param.ylimmin, param.ylimmax]);
        clim(hAX, [param.cmin, param.cmax]);
        
        applyPGIXSAxesColorScale(hAX, param.colorscale);
        
        applyColormap(param.colorm, param.data);
        setupColorbar();
        
        if nargin > 0 && ~isempty(overlayFunc)
            hold(hAX, 'on'); overlayFunc(); hold(hAX, 'off');
        end
        
        setupAxesStyle(param.fontsize, param.FileName);
        drawnow();
    end

    function [Mask, pixel, report] = loadDetectorMask(detectorType)
        [Mask, pixel, report] = loadPGIXSDetectorMask(detectorType);
    end

    function [data, counts] = loadImageFile(filepath, fileFormat)
        [data, counts] = loadPGIXSImageFile(filepath, fileFormat);
    end

    function data = applyMaskToData(data, mask), data = applyPGIXSMask(data, mask); end
    function p = initializeParams(), p.data = []; p.Expinfo = 0; p.correctionI = 0; p.Normalcheck = 0; end

% --- Callbacks ---
    function pathset_Callback(~,~)
        pathway = uigetdir;
        figure(GUI.main); drawnow;  % 메인 창 포커스 복원
        if pathway ~= 0, TX.pathset.Value = pathway; end
    end

    function Openimage_Callback(~,~)
        param.detector = GUI.hDetector.Value;
        Multi_img = GUI.hMultishot.Value;
        pathway = TX.pathset.Value;
        
        [XSImage, datadir] = uigetfile({'*.*','All format(*.*)'}, 'Select a file', pathway);
        figure(GUI.main); drawnow;  % 메인 창 포커스 복원
        if XSImage == 0, return; end
        XSImage = fullfile(datadir, XSImage);
        [param.Path, param.FileName, FileFormat] = fileparts(XSImage);
        [param.Mask, param.pixel, maskReport] = loadDetectorMask(param.detector);
        if maskReport.FallbackUsed && ~isempty(maskReport.Message)
            uialert(GUI.main, ['Detector mask warning: ', maskReport.Message], 'Warning');
        end
        
        if Multi_img == 0
            [param.data, param.Count] = loadImageFile(XSImage, FileFormat);
            param.dataSize = single(size(param.data));
            if ~isequal(double(param.dataSize), double(size(param.Mask)))
                uialert(GUI.main, 'Please use other detector menu','Warning'); return;
            else
                param.data = applyMaskToData(param.data, param.Mask);
            end
        else
             param = loadMultishot(param, FileFormat);
             if isempty(param.data), return; end
        end
        
        param.data = single(param.data); param.dataSize = single(size(param.data));
        param.cmin = min(param.data(param.data > 0), [], 'omitnan'); param.cmax = max(param.data(:), [], 'omitnan');
        TX.cMax.Value = double(param.cmax); TX.cMin.Value = double(param.cmin);
        
        if param.Expinfo == 0
            param.HD = single(1:param.dataSize(2)); param.VD = single(1:param.dataSize(1));
        else
            param.HD = single((1:param.dataSize(2)) - TX.hyPOS.Value); param.VD = single(-( (1:param.dataSize(1)) - TX.hzPOS.Value ));
        end
        
        TX.cXlim1.Value = double(min(param.HD)); TX.cXlim2.Value = double(max(param.HD));
        TX.cYlim1.Value = double(min(param.VD)); TX.cYlim2.Value = double(max(param.VD));
        param.correctionI = 0; param.Normalcheck = 0; updateCounterDisplay(param);

        btnQmap.BackgroundColor = [0.96 0.96 0.96]; % 기본 회색
        btnQmap.FontColor = [0.15 0.15 0.15];       % 기본 텍스트 색상(검정)
        btnGrid.BackgroundColor = [0.96 0.96 0.96];
        btnGrid.FontColor = [0.15 0.15 0.15];
        
        GUI.hMapping.Value = 'Pixel'; 
        param.Mapping = 'Pixel';
        
        renderImage();
        figure(GUI.main); drawnow;  % renderImage 후 최종 포커스 복원
    end

    function p = loadMultishot(p, FileFormat)
        d = uiprogressdlg(GUI.main, 'Title', 'Loading Data', 'Message', 'Multishot Processing...');
        try
            result = loadPGIXSMultishotAverage(p.Path, p.FileName, FileFormat, ...
                p.Mask, @(ii, n) set(d, 'Value', ii / n));
            p.FileName = result.Prefix;
            p.dataSize = result.DataSize;
            p.data = result.Data;
            p.Count = result.Count;
        catch ME
            p.data = [];
            close(d);
            uialert(GUI.main, ME.message, 'Multishot Error');
            return;
        end
        close(d);
    end

    function updateCounterDisplay(p)
        if isfield(p,'Count') && ~isempty(p.Count)
            if isscalar(p.Count), TX.IC.Text = num2str(p.Count(1)); TX.BC.Text = 'None';
            elseif length(p.Count) >= 2, TX.IC.Text = num2str(p.Count(1)); TX.BC.Text = num2str(p.Count(2));
            end
        else
            TX.IC.Text = 'None'; TX.BC.Text = 'None';
        end
    end

    function Openinfo_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        [XSinfo, datadir] = uigetfile({'*.mat'}, 'Select info file', TX.pathset.Value);
        figure(GUI.main); drawnow;  % 메인 창 포커스 복원
        if XSinfo == 0, return; end
        [S, loadReport] = loadPGIXSStandardCalibration(fullfile(datadir, XSinfo), GUI.hDetector.Value);
        param.detector = GUI.hDetector.Value;
        
        if loadReport.OK
            param.Wavelength = S.wavelength; param.bpos = S.pc; param.SDD = S.sdd;
            param.Energy = S.Energy;
            
            TX.hEnergy.Value = double(param.Energy); TX.hEnergy.BackgroundColor = [0.8 1 1];
            TX.hSDD.Value = double(param.SDD); TX.hSDD.BackgroundColor = [0.8 1 1];
            TX.hyPOS.Value = double(param.bpos(1)); TX.hyPOS.BackgroundColor = [0.8 1 1];
            TX.hzPOS.Value = double(param.bpos(2)); TX.hzPOS.BackgroundColor = [0.8 1 1];
            
            param.HD = single((1:param.dataSize(2)) - param.bpos(1)); param.VD = single(-( (1:param.dataSize(1)) - param.bpos(2) ));
            TX.cXlim1.Value = double(min(param.HD)); TX.cXlim2.Value = double(max(param.HD));
            TX.cYlim1.Value = double(min(param.VD)); TX.cYlim2.Value = double(max(param.VD));
            
            param.Expinfo = 1; renderImage();
            figure(GUI.main); drawnow;  % renderImage 후 최종 포커스 복원
        else 
            uialert(GUI.main, loadReport.Message, 'Calibration Warning', 'Icon', 'warning'); 
        end
    end

    function Bkgload_Callback(~,~)
        [XSBKG, datadir] = uigetfile({'*.*','All format(*.*)'}, 'Select a file', TX.pathset.Value);
        figure(GUI.main); drawnow;  % 메인 창 포커스 복원
        if XSBKG == 0; return; end
        bkgFilePath = fullfile(datadir, XSBKG);
        [BKGPath, param.BKGFile, FileFormat] = fileparts(bkgFilePath);
        
        d = uiprogressdlg(GUI.main, 'Title', 'Loading BKG', 'Message', 'Background Loading...', 'Indeterminate', 'on');
        
        if GUI.hMultishot.Value == 0
            [param.bkg, param.Countbkg] = loadImageFile(bkgFilePath, FileFormat);
            if size(param.bkg, 1) ~= size(param.Mask, 1), uialert(GUI.main, 'Size mismatch','Warning'); close(d); return; end
            param.bkg = applyMaskToData(param.bkg, param.Mask);
        else
             d.Indeterminate = 'off';
             try
                 result = loadPGIXSMultishotAverage(BKGPath, param.BKGFile, ...
                     FileFormat, param.Mask, @(ii, n) set(d, 'Value', ii / n));
                 param.BKGFile = result.Prefix;
                 param.bkg = result.Data;
                 param.Countbkg = result.Count;
             catch ME
                 close(d);
                 uialert(GUI.main, ME.message, 'Background Error');
                 return;
             end
        end
        close(d);
        figure(GUI.main); drawnow;  % 최종 포커스 복원
        uialert(GUI.main, 'Background loaded successfully.', 'Success');
    end

    function Subtraction_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if param.correctionI == 1, uialert(GUI.main, 'Please perform subtraction before correction!','Warning'); return; end
        if param.Normalcheck == 1, uialert(GUI.main, 'Normalization is already done!','Warning'); return; end
        
        Normalway = GUI.hNormal.Value; PlusD = TX.Plusdata.Value;
        bkgData = []; bkgCounts = [];
        if isfield(param,'bkg') && ~isempty(param.bkg)
            bkgData = param.bkg;
            if isfield(param,'Countbkg'), bkgCounts = param.Countbkg; end
        end
        
        [datatemp, normReport] = processPGIXSNormalization(param.data, bkgData, param.Count, bkgCounts, Normalway, PlusD);
        if ~normReport.Success
            uialert(GUI.main, normReport.Message, 'Warning');
            return;
        end

        if normReport.Success
             origData = param.data;  
             param.data = datatemp;
             cmin_new = min(datatemp(datatemp>0),[],'omitnan');
             cmax_new = max(datatemp(:),[],'omitnan');
             TX.cMax.Value = double(cmax_new); TX.cMin.Value = double(cmin_new);
             renderImage();
             
             selection = uiconfirm(GUI.main, 'Do you want to keep the result?', ...
                 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'Yes');
             if strcmp(selection, 'Yes')
                 param.Normalcheck = 1;
                 param.cmin = cmin_new; param.cmax = cmax_new;
                 uialert(GUI.main, 'BKG Subtracted & Normalized.', 'Success');
             else
                 param.data = origData;
                 param.cmin = min(origData(origData>0),[],'omitnan');
                 param.cmax = max(origData(:),[],'omitnan');
                 TX.cMax.Value = double(param.cmax); TX.cMin.Value = double(param.cmin);
                 renderImage();
             end
        end
    end

    function GridRemove_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if ~strcmp(GUI.hDetector.Value, 'Eiger4M')
            uialert(GUI.main, 'Grid Remove is available only for Eiger4M detector data.', 'Grid Remove Skipped', 'Icon', 'warning');
            return;
        end
        Nanpos = find(isnan(param.data)); param.data(Nanpos) = 0;
        try
            [param.data, gridReport] = Gridremover(param.data, GUI.hDetector.Value);
            param.data(Nanpos) = nan;
            renderImage();
            if ~gridReport.Applied
                uialert(GUI.main, gridReport.Message, 'Grid Remove Skipped', 'Icon', 'warning');
            else
                btnGrid.BackgroundColor = [0.3 0.6 0.4];
                btnGrid.FontColor = [1 1 1];
            end
        catch ME
            param.data(Nanpos) = nan;
            uialert(GUI.main, ['Grid remover error: ', ME.message], 'Error');
        end
    end

    function Correction_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if param.correctionI == 1, uialert(GUI.main, 'qMap is already done!!','Warning'); return; end
        
        d = uiprogressdlg(GUI.main, 'Title', 'Calculating', 'Message', 'qMap calculation is ongoing...', 'Indeterminate', 'on');

        try
            opts = struct();
            opts.Energy = TX.hEnergy.Value;
            opts.SDD = TX.hSDD.Value;
            opts.Beampos = [TX.hyPOS.Value, TX.hzPOS.Value];
            opts.Detector = param.detector;
            param = processTrXS2D(param, opts);

            close(d);
            renderImage(); uialert(GUI.main, 'qMap correction completed.', 'Success');

            btnQmap.BackgroundColor = [0.3 0.6 0.4]; % 차분한 녹색
            btnQmap.FontColor = [1 1 1];             % 흰색 글씨

        catch ME
            close(d);
            uialert(GUI.main, ['Error during Q-Map: ' ME.message], 'Error');
        end
    end

    function Updateimage_Callback(~,~), if isempty(param.data), return; end; renderImage(); end
    
    function Rangecal_Callback(~,~)
        if isempty(param.data), return; end
        param.Mapping = GUI.hMapping.Value;
        switch param.Mapping
            case 'Pixel'
                TX.cXlim1.Value = double(min(param.HD)); TX.cXlim2.Value = double(max(param.HD));
                TX.cYlim1.Value = double(min(param.VD)); TX.cYlim2.Value = double(max(param.VD));
            case 'Qy/Qz'
                if isfield(param,'qy')
                    TX.cXlim1.Value = double(min(param.qy)); TX.cXlim2.Value = double(max(param.qy)); 
                    TX.cYlim1.Value = double(min(param.qz)); TX.cYlim2.Value = double(max(param.qz));
                else
                    uialert(GUI.main, 'Please do correction first!!','Warning'); GUI.hMapping.Value = 'Pixel'; return; 
                end
        end
        renderImage();
    end

    function CircularAve_Callback(~,~)
        % =================================================================
        % q-Binned Azimuthal Average with Huber M-estimator (Nearest-bin)
        %
        % 핵심 설계
        %  1) Polar interpolation 제거. q-map 자체에서 직접 binning하므로
        %     q-축 비선형(=등r 그리드일 때 q가 균일하지 않음) 문제 자체가 사라짐.
        %     사용자가 q-축 등간격(linear in q)을 그대로 보장받음.
        %  2) Detector gap은 NaN/0 픽셀을 binning에서 단순히 제외하여 처리.
        %     interp2 기반 보간이 없으므로 gap 경계 오염(픽셀 NaN 전파)이 0임.
        %  3) 저강도 영역 robust 통계: Huber M-estimator (c = 1.345).
        %     - 초기 location estimate: bin median
        %     - scale: 1.4826 * MAD
        %     - 가중평균 1~2회 반복으로 outlier(gap edge spike, hot pixel)에 강함
        %  4) Vectorization: accumarray 기반. interp2-polar 대비 대략 3~5배 빠름.
        %     단일 numel(I2d) 사이즈 인덱스 벡터 한 개만 사용 → 메모리도 절감.
        %
        % 출력 호환성: 기존 param.pixPlot / param.Qtr / param.r1d / param.r1dstd
        %             모두 동일하게 채워서 OneDplotQrad_gui와 호환 유지.
        % =================================================================

        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if param.correctionI == 0, uialert(GUI.main, 'Please doing the QMap first!!','Warning'); return; end
        if ~isfield(param, 'Q') || isempty(param.Q)
            uialert(GUI.main, 'Q-map (param.Q) is missing. Run qMap first.', 'Error'); return;
        end

        Angmin = TX.hAng1dmin.Value;
        Angmax = TX.hAng1dmax.Value;
        I2d = param.data;

        % 360° 전체 영역인 경우에만 ROI 마스크 옵션 제공 (기존 동작 유지)
        if Angmin == 0 && Angmax == 360
            [BW, userSelected] = selectROIMask(param.data, param);
            if userSelected && ~isempty(BW)
                I2d = param.data; I2d(BW <= 0) = NaN;   % ROI 밖 = NaN(0으로 만들지 않음)
            end
        end

        d = uiprogressdlg(GUI.main, 'Title', 'Calculating', ...
            'Message', 'q-Binned Integration (Huber M-estimator)...', 'Indeterminate', 'on');

        try
            % --------------------------------------------------------------
            % [STEP 0] 입력 정리: NaN/0/음수는 모두 무효 픽셀 처리
            % --------------------------------------------------------------
            I = single(I2d);
            Q = single(param.Q);

            % gap/hot pixel은 상위 mask에서 이미 NaN. 측정된 0/음수는 평균에 포함
            % (제외하면 고각이 위로 편향됨).
            invalid_pix = ~isfinite(I) | ~isfinite(Q) | (Q <= 0);

            % --------------------------------------------------------------
            % [STEP 1] Angular sector mask (필요한 경우)
            % --------------------------------------------------------------
            if ~(Angmin == 0 && Angmax == 360)
                [n, m] = size(I);
                bpx = single(param.bpos(1));
                bpy = single(param.bpos(2));
                [Xg, Yg] = meshgrid(single(1:m), single(1:n));
                % 기존 코드 컨벤션과 일치: cosT=-cosd, sinT=sind, y가 위로 증가
                ang = atan2d(-(Yg - bpy), -(Xg - bpx));   % [-180, 180]
                ang = mod(ang, 360);                      % [0, 360)
                a1 = mod(Angmin, 360);
                a2 = mod(Angmax, 360);
                if a1 < a2
                    sector_mask = (ang >= a1) & (ang <= a2);
                else
                    sector_mask = (ang >= a1) | (ang <= a2);  % wrap-around
                end
                invalid_pix = invalid_pix | ~sector_mask;
            end

            % --------------------------------------------------------------
            % [STEP 2] radius-bin first, Q-axis second (legacy FastRAvg2DQ)
            % --------------------------------------------------------------
            valid_pix = ~invalid_pix;
            if ~any(valid_pix(:))
                error('No valid pixels after masking.');
            end

            radiusPrep = buildPGIXSRadiusBinMap(Q, [param.bpos(1), param.bpos(2)], valid_pix);
            if ~radiusPrep.isValid
                error('No valid radius bins after masking.');
            end

            useMedian = strcmp(GUI.hMeanMed.Value, 'Median');
            [mu, r1dstd, dataCounts] = processPGIXSRadiusBin1D(I, radiusPrep, useMedian, true);
            sectorCounts = double(radiusPrep.geom_counts(:));
            coverage = nan(size(mu), 'single');
            hasSector = sectorCounts > 0;
            coverage(hasSector) = single(double(dataCounts(hasSector)) ./ sectorCounts(hasSector));

            minCoverage = double(TX.hMinCoverage.Value);
            if ~isfinite(minCoverage)
                minCoverage = 0.80;
            end
            minCoverage = max(0, min(1, minCoverage));
            lowCoverage = coverage < minCoverage;
            mu(lowCoverage) = NaN;
            r1dstd(lowCoverage) = NaN;

            param.pixPlot = radiusPrep.r_axis(:);
            param.Qtr    = radiusPrep.q_axis(:);
            param.r1d    = single(mu);
            param.r1dCoverage = single(coverage);
            param.r1dValidCounts = single(dataCounts(:));
            param.r1dSectorCounts = single(sectorCounts(:));
            param.r1dMinCoverage = single(minCoverage);
            param.r1dLowCoverageBins = find(lowCoverage);
            if GUI.hStdI.Value == 1
                param.r1dstd = single(r1dstd);
            end

            close(d);

            % 기존 sector 가이드라인 동작 유지
            if Angmin ~= 0 || Angmax ~= 360
                if strcmp(param.Mapping, 'Pixel')
                    renderImage(@() drawSectorLines(param, Angmin, Angmax));
                else
                    renderImage();
                end
            else
                renderImage();
            end

        catch ME
            if exist('d', 'var') && isvalid(d), close(d); end
            uialert(GUI.main, ['Averaging error: ' ME.message], 'Error');
            return;
        end

        try
            OneDplotQrad_gui(param, GUI.main);
        catch ME
            uialert(GUI.main, ['Radial plot error: ', ME.message], 'Error');
        end
    end

    function drawSectorLines(p, angMin, angMax)
        maxR = max(p.dataSize) * 1.5;
        if p.Expinfo == 0
            cx = p.bpos(1); cy = p.bpos(2); y_sign = -1; 
        else
            cx = 0; cy = 0; y_sign = 1;  
        end
        x1 = cx - maxR * cosd(angMin); y1 = cy + y_sign * maxR * sind(angMin);
        x2 = cx - maxR * cosd(angMax); y2 = cy + y_sign * maxR * sind(angMax);
        plot(hAX, [cx, x1], [cy, y1], 'w--', 'LineWidth', 2);
        plot(hAX, [cx, x2], [cy, y2], 'w--', 'LineWidth', 2);
        plot(hAX, cx, cy, 'rx', 'MarkerSize', 10, 'LineWidth', 2);
    end

    function Drawline_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if param.correctionI == 0, uialert(GUI.main, 'Please doing the qMap first!!','Warning'); return; end
        param.ang = mod(single(TX.h1dphi.Value), 360); % 360도 전 영역 허용
        try 
            [param.linepos, param.line1dang] = Anglecut1d(param); 
            param.linepos = single(param.linepos); 
            renderImage(@() plotLineOverlay(param)); 
        catch ME
            uialert(GUI.main, ['Anglecut1d error: ' ME.message], 'Error'); 
        end
    end

    function plotLineOverlay(p)
        xmin = p.linepos(1); xmax = p.linepos(2); ymin = p.linepos(3); ymax = p.linepos(4);
        if strcmp(p.Mapping, 'Pixel')
            if p.Expinfo == 1, x1=xmin-p.bpos(1); x2=xmax-p.bpos(1); y1=-(ymin-p.bpos(2)); y2=-(ymax-p.bpos(2)); else, x1=xmin; x2=xmax; y1=ymin; y2=ymax; end
            plot(hAX, [x1, x2], [y1, y2], '-w', 'LineWidth', 2);
        else
            xmin=max(1,min(p.dataSize(2),xmin)); xmax=max(1,min(p.dataSize(2),xmax)); ymin=max(1,min(p.dataSize(1),ymin)); ymax=max(1,min(p.dataSize(1),ymax));
            if isfield(p, 'qy') && isfield(p, 'qz'), plot(hAX, [p.qy(round(xmin)), p.qy(round(xmax))], [p.qz(round(ymin)), p.qz(round(ymax))], '-w', 'LineWidth', 2); end
        end
    end

    function Lineplot_Callback(~,~)
        try
            OneDplotQline_gui(param, GUI.main);
        catch ME
            uialert(GUI.main, ['Line plot error: ', ME.message], 'Error');
        end
    end

    function CalcPos_Callback(~,~)
        if isempty(param.data), return; end
        try
            pix_pos = TX.azipospix.Value; 
            pix_pos_minus = TX.azipospixm.Value; 
            pix_pos_plus = TX.azipospixp.Value;
            
            pos_pix = pix_pos + round(param.bpos(1));
            TX.Qpospix.Value = double(param.Q(round(param.bpos(2)), pos_pix));
            TX.Qpospixm.Value = double(param.Q(round(param.bpos(2)), pos_pix + pix_pos_minus));
            TX.Qpospixp.Value = double(param.Q(round(param.bpos(2)), pos_pix + pix_pos_plus));
        catch ME
            warning('TrXS:QPositionCalculationFailed', 'Q position calculation failed: %s', ME.message);
            % 계산 불가 상태일 때는 Q값을 0으로 안전하게 초기화
            TX.Qpospix.Value = 0;
            TX.Qpospixm.Value = 0;
            TX.Qpospixp.Value = 0;
        end
    end

    function CalcQpos_Callback(~,~)
        if isempty(param.data), return; end
        try 
            Q_pos = TX.Qpospix.Value; 
            [~, pix_pos] = min(abs(param.Q(round(param.bpos(2)), :) - Q_pos)); 
            TX.azipospix.Value = double(round(abs(param.HD(pix_pos)))); 
        catch ME
            warning('TrXS:PixelPositionCalculationFailed', 'Pixel position calculation failed: %s', ME.message);
            % 계산 불가 상태일 때는 Pixel 값을 0으로 초기화
            TX.azipospix.Value = 0;
        end 
    end
    
    function PointFind_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        
        % 1. 기존에 찍어둔 ROI 마커가 있다면 삭제하여 중복 방지
        if isfield(param, 'hROI') && ~isempty(param.hROI) && isvalid(param.hROI)
            delete(param.hROI); 
        end
        
        % 2. drawpoint 실행 (사용자가 클릭할 때까지 대기하며, 클릭 시 마커 생성)
        % (마젠타 색상('m')으로 눈에 띄게 표시)
        param.hROI = drawpoint(hAX, 'Color', 'm', 'Label', 'Target');
        
        % 3. 마커를 마우스로 드래그할 때 실시간으로 값이 바뀌도록 이벤트 리스너 추가
        addlistener(param.hROI, 'MovingROI', @(src, evt) updatePointFromROI(src.Position));
        addlistener(param.hROI, 'ROIMoved', @(src, evt) updatePointFromROI(src.Position));
        
        % 4. 점을 찍은 직후 즉시 1회 업데이트
        updatePointFromROI(param.hROI.Position);
    end

    % --- 마커 실시간 업데이트를 위한 헬퍼 함수 ---
    function updatePointFromROI(pos)
        x = pos(1);
        y = pos(2);
        if strcmp(param.Mapping, 'Pixel') 
            TX.azipospix.Value = double(round(sqrt(x^2 + y^2))); 
            CalcPos_Callback(); 
        else 
            TX.Qpospix.Value = double(sqrt(x^2 + y^2)); 
            CalcQpos_Callback(); 
        end 
    end

    function DrawPlot_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if param.correctionI == 0, uialert(GUI.main, 'Please doing the QMap first!!','Warning'); return; end
        try
            pix_pos = TX.azipospix.Value; pix_pos_minus = TX.azipospixm.Value; pix_pos_plus = TX.azipospixp.Value;
            pos_pix = pix_pos + round(param.bpos(1)); NumSum = (pos_pix + pix_pos_plus) - (pos_pix + pix_pos_minus);
            theta = (0:0.2:360)' + 180;
            
            PlotAzi = param.data;
            
            [BW, userSelected] = selectROIMask(param.data, param);
            if userSelected && ~isempty(BW)
                PlotAzi(BW <= 0) = NaN;   % ROI 밖 = NaN
            end
            
            d = uiprogressdlg(GUI.main, 'Title', 'Calculating', 'Message', 'Azimuthal Integrating...', 'Indeterminate', 'on');
            
            % 1. 연산용 그리드 생성
            radii = (pix_pos - fix(NumSum/2)) : (pix_pos - fix(NumSum/2) + fix(NumSum) - 1); 
            [ThetaGrid, RGrid] = meshgrid(theta, radii);
            X_idx = round(RGrid .* cosd(ThetaGrid) + param.bpos(1)); 
            Y_idx = round(RGrid .* sind(ThetaGrid) + param.bpos(2));
            
            % 유효 픽셀 마스크
            valid_mask = (X_idx >= 1) & (X_idx <= param.dataSize(2)) & (Y_idx >= 1) & (Y_idx <= param.dataSize(1));
            
            % 2. 데이터 추출: gap/hot은 이미 NaN. 측정된 0/음수는 유지(고각 bias 방지)
            D = PlotAzi;
            
            IndMap = nan(size(ThetaGrid), 'single'); 
            IndMap(valid_mask) = sub2ind(param.dataSize, Y_idx(valid_mask), X_idx(valid_mask));
            
            Vals = nan(size(IndMap), 'single'); 
            good = ~isnan(IndMap); 
            Vals(good) = D(IndMap(good)); 
            Vals = Vals'; % Shape: [theta x radii]
            
            % 3. Mean 또는 Median 연산 (omitnan 적용)
            if strcmp(GUI.hMeanMed.Value, 'Mean')
                SumTemp = mean(Vals, 2, 'omitnan'); 
            else
                SumTemp = median(Vals, 2, 'omitnan'); 
            end
            
            % --- [NaN/갭 처리 정책: 보간·평활 없이 단순 제외] -----------------
            % 각 theta bin은 radii 픽셀들의 omitnan 평균/중앙값이다.
            %   · 유효 픽셀이 하나도 없는 방향(=detector gap / 이미지 밖)은 자연히 NaN.
            %   · NaN은 평균에서 제외될 뿐, 보간/평활로 메우거나 갭 너머와 섞지 않는다.
            valid_counts = sum(~isnan(Vals), 2);   % 각 각도별 유효 픽셀 수
            SumTemp(valid_counts < 1) = NaN;        % 유효 픽셀 0개 방향만 NaN

            % 4. 2D 이미지 창에 적분 링(Ring) 영역 시각적으로 강조
            DisplayImg = param.data;
            if userSelected && ~isempty(BW)
                DisplayImg = DisplayImg .* BW;
            end
            good_idx = IndMap(good);
            DisplayImg(good_idx) = max(param.data(:), [], 'omitnan') * 1.5;
            
            % 화면 업데이트 수행 후 데이터 원상복구
            tempData = param.data; 
            param.data = DisplayImg; 
            renderImage(); 
            param.data = tempData; 
            
            param.Azi = [single(theta), single(SumTemp)]; 
            
            close(d);
            uialert(GUI.main, 'Azimuthal done.', 'Success');
        catch ME
            if exist('d', 'var'), close(d); end
            uialert(GUI.main, ['Azimuthal error: ' ME.message], 'Error');
        end
    end

    function AziPlot_Callback(~,~)
        try
            OneDplotAzi_gui(param, GUI.main);
        catch ME
            uialert(GUI.main, ['Azimuthal plot error: ', ME.message], 'Error');
        end
    end

    function Savefile_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if param.correctionI == 0, uialert(GUI.main, 'Please doing the qMap first!!','Warning'); return; end
        
        SaveForm = GUI.hSvForm.Value;
        [filepath, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        
        selection = uiconfirm(GUI.main, 'Change filename?', ...
            'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'No');
        if strcmp(selection, 'Yes')
            FN = NewFileName(param.FileName);
        else
            FN = param.FileName;
        end
        
        d = uiprogressdlg(GUI.main, 'Title', 'Saving', 'Message', 'Saving Images and Data...', 'Indeterminate', 'on');
        
        try
            saveData = buildPGIXS2DInfo(param, 'TrXS');
            savePGIXS2DInfoFile(fullfile(filepath, [FN,'_2Dinfo.mat']), saveData);
        catch ME
            close(d);
            uialert(GUI.main, ['2D info save failed: ' ME.message], 'Save Error');
            return;
        end
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX, fullfile(filepath, [FN,'_2DImage',SaveForm]), 300);
        if ~exportOK
            uialert(GUI.main, ['Image export failed: ', exportReport.Message], 'Warning');
        end
        
        close(d);
        uialert(GUI.main, 'Save done!', 'Success');
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
