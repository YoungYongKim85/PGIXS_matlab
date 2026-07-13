function TrXS2_gui
% TrXS2_gui v2.0 - Transmission X-ray Scattering Series (Modern UI)
% Designed for 3C beamline user at PLS-II (Designed By Y.Y.Kim)
% FIXED: NaN Propagation in Normalization & Live UI Interaction for IC/BC

if exist('uilabel', 'builtin') == 0 && exist('uilabel', 'file') == 0
    error('현재 매트랩(2024a 등 최신 버전 권장)이 모던 UI(uilabel)를 인식하지 못합니다. 버전을 확인해주세요.');
end

clc;

% ============================ GUI Setup ==================================
GUI.main = uifigure('Name','Transmission X-ray Scattering Series v2.0',...
    'NumberTitle','off', 'Position',[50 50 1500 850], ...
    'Color', [0.96 0.96 0.96]);

movegui(GUI.main, 'center');

% Color & List definitions
detectorList = {'Eiger4M', 'MarCCD', 'MX170HS', 'PI-CCD'};
NormalList = {'None','IC','BC'};
scaleList = {'Linear', 'Log'};
ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis',...
    'cubehelix','magma','kindlemann','jet2','ocean','rwb','rkb'};
expModeList = {'Time', 'Temperature'};
SForm = {'.mat', '.dat', '.csv'};

TX2 = struct(); Auto = struct();
% Auto.Met 모드 상수 정의 (매직 넘버 제거)
AUTO_CIRCULAR = 0; AUTO_LINECUT = 1; AUTO_AZIMUTHAL = 2;
param = struct(); param.data = []; param.Expinfo = 0; Auto.Met = AUTO_CIRCULAR; Auto.Nold = 0;

% ============================ Main Layout Grid ===========================
mainGrid = uigridlayout(GUI.main, [1 3]);
mainGrid.ColumnWidth = {380, '1x', '1x'};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 15;

% ========================= 1. Left Panel (Parameters) ====================
leftPanel = uipanel(mainGrid, 'Title', 'Serial Data Analysis', 'FontSize', 14, 'FontWeight', 'bold', 'Scrollable', 'on');
leftPanel.Layout.Row = 1; 
leftPanel.Layout.Column = 1;

lg = uigridlayout(leftPanel, [30 4]);
lg.RowHeight = [repmat({25}, 1, 28), {'1x'}, {30}]; 
lg.ColumnWidth = {'1x', '1x', '1x', '1x'};
lg.Padding = [10 15 10 5]; 
lg.RowSpacing = 5; 
lg.ColumnSpacing = 5;

% --- Row 1-2: Directory ---
lbl1 = uilabel(lg, 'Text', 'Directory:'); lbl1.Layout.Row = 1; lbl1.Layout.Column = [1 4];
TX2.pathset = uieditfield(lg, 'text', 'Value', pwd); TX2.pathset.Layout.Row = 2; TX2.pathset.Layout.Column = [1 3];
btn1 = uibutton(lg, 'Text', 'Set', 'ButtonPushedFcn', @pathset2_Callback); btn1.Layout.Row = 2; btn1.Layout.Column = 4;

% --- Row 3: Detector & Mode ---
lbl2 = uilabel(lg, 'Text', 'Detector:'); lbl2.Layout.Row = 3; lbl2.Layout.Column = 1;
GUI.hDetector = uidropdown(lg, 'Items', detectorList); GUI.hDetector.Layout.Row = 3; GUI.hDetector.Layout.Column = 2;
lbl3 = uilabel(lg, 'Text', 'Exp. Mode:'); lbl3.Layout.Row = 3; lbl3.Layout.Column = 3;
GUI.hinsitumode = uidropdown(lg, 'Items', expModeList); GUI.hinsitumode.Layout.Row = 3; GUI.hinsitumode.Layout.Column = 4;

% --- Row 4: Load Data ---
btnLoad = uibutton(lg, 'Text', 'LOAD DATA', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.3 0.5], 'FontColor', 'w', 'ButtonPushedFcn', @Openimage2_Callback);
btnLoad.Layout.Row = 4; btnLoad.Layout.Column = [1 4];

% --- Row 5: Filename ---
lbl4 = uilabel(lg, 'Text', 'Filename:'); lbl4.Layout.Row = 5; lbl4.Layout.Column = 1;
TX2.hFilename = uieditfield(lg, 'text', 'Value', 'ABCD'); TX2.hFilename.Layout.Row = 5; TX2.hFilename.Layout.Column = [2 3];
btnFileSet = uibutton(lg, 'Text', 'Set', 'ButtonPushedFcn', @OpenNameDef_callback); btnFileSet.Layout.Row = 5; btnFileSet.Layout.Column = 4;

% --- Row 6: Counters ---
btnIC = uibutton(lg, 'Text', 'IC', 'ButtonPushedFcn', @OpenICplot_callback); btnIC.Layout.Row = 6; btnIC.Layout.Column = 1;
btnBC = uibutton(lg, 'Text', 'BC', 'ButtonPushedFcn', @OpenBCplot_callback); btnBC.Layout.Row = 6; btnBC.Layout.Column = 2;
lbl5 = uilabel(lg, 'Text', '# of Files:'); lbl5.Layout.Row = 6; lbl5.Layout.Column = 3;
TX2.NFile = uilabel(lg, 'Text', '0', 'FontWeight', 'bold'); TX2.NFile.Layout.Row = 6; TX2.NFile.Layout.Column = 4;

% --- Row 7: Background & Sub ---
GUI.btnBkg = uibutton(lg, 'Text', 'Background', 'ButtonPushedFcn', @Bkgload2_Callback); GUI.btnBkg.Layout.Row = 7; GUI.btnBkg.Layout.Column = [1 2];
% [수정 핵심 1] Subtraction 체크 시 실시간 반영 연동
GUI.hSubract_S = uicheckbox(lg, 'Text', 'Subtraction', 'Value', 0, 'ValueChangedFcn', @RefreshAllPlots_Callback); 
GUI.hSubract_S.Layout.Row = 7; GUI.hSubract_S.Layout.Column = [3 4];

% --- Row 8-9: Exp Params ---
lblDiv1 = uilabel(lg, 'Text', '--- [ Exp. Parameters ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); lblDiv1.Layout.Row = 8; lblDiv1.Layout.Column = [1 4];
GUI.btnInfo = uibutton(lg, 'Text', 'Load Info', 'ButtonPushedFcn', @Openinfo2_Callback); GUI.btnInfo.Layout.Row = 9; GUI.btnInfo.Layout.Column = [1 2];
btnGridR = uibutton(lg, 'Text', 'Grid Remove', 'ButtonPushedFcn', @GridRemove2_Callback); btnGridR.Layout.Row = 9; btnGridR.Layout.Column = [3 4];

% --- Row 10: Expo Time ---
lbl6 = uilabel(lg, 'Text', 'Expo. Time:'); lbl6.Layout.Row = 10; lbl6.Layout.Column = 1;
TX2.hExptime = uieditfield(lg, 'numeric', 'Value', 1, 'ValueChangedFcn', @TimeUpdate_Callback); TX2.hExptime.Layout.Row = 10; TX2.hExptime.Layout.Column = 2;
TimeList = {'second', 'min', 'hour'};
GUI.hTimeP = uidropdown(lg, 'Items', TimeList, 'ValueChangedFcn', @TimeUpdate_Callback); GUI.hTimeP.Layout.Row = 10; GUI.hTimeP.Layout.Column = [3 4];

% --- Row 11: qMap ---
GUI.btnQcal = uibutton(lg, 'Text', 'q-Cal.', 'FontWeight', 'bold', 'ButtonPushedFcn', @Qcalc_Callback); GUI.btnQcal.Layout.Row = 11; GUI.btnQcal.Layout.Column = [1 2];
btnSaveStk = uibutton(lg, 'Text', 'Save Stack', 'ButtonPushedFcn', @SaveStack_Callback); btnSaveStk.Layout.Row = 11; btnSaveStk.Layout.Column = [3 4];

% --- Row 12-15: 1D Plot Process ---
lblDiv2 = uilabel(lg, 'Text', '--- [ 1D Plot Process ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); lblDiv2.Layout.Row = 12; lblDiv2.Layout.Column = [1 4];
lbl7 = uilabel(lg, 'Text', 'Ang. Avg:'); lbl7.Layout.Row = 13; lbl7.Layout.Column = 1;
TX2.hAng1dmin = uieditfield(lg, 'numeric', 'Value', 0); TX2.hAng1dmin.Layout.Row = 13; TX2.hAng1dmin.Layout.Column = 2;
TX2.hAng1dmax = uieditfield(lg, 'numeric', 'Value', 360); TX2.hAng1dmax.Layout.Row = 13; TX2.hAng1dmax.Layout.Column = 3;
btnCircExec = uibutton(lg, 'Text', 'Exec.', 'ButtonPushedFcn', @CircularAve2_Callback); btnCircExec.Layout.Row = 13; btnCircExec.Layout.Column = 4;

GUI.hStdI2 = uicheckbox(lg, 'Text', 'Std', 'Value', 0); GUI.hStdI2.Layout.Row = 14; GUI.hStdI2.Layout.Column = 1;
GUI.hMedianB = uicheckbox(lg, 'Text', 'Median', 'Value', 0); GUI.hMedianB.Layout.Row = 14; GUI.hMedianB.Layout.Column = 2;
% [수정 핵심 2] 드롭다운 변경 시 실시간 반영 연동
GUI.hNormal2 = uidropdown(lg, 'Items', NormalList, 'ValueChangedFcn', @Plot1dseries_Callback); 
GUI.hNormal2.Layout.Row = 14; GUI.hNormal2.Layout.Column = 3;

btn1dPlot = uibutton(lg, 'Text', 'Plot', 'ButtonPushedFcn', @Plot1dseries_Callback); btn1dPlot.Layout.Row = 14; btn1dPlot.Layout.Column = 4;

lbl8 = uilabel(lg, 'Text', '1D Line Ang:'); lbl8.Layout.Row = 15; lbl8.Layout.Column = 1;
TX2.h1dphi = uieditfield(lg, 'numeric', 'Value', 0); TX2.h1dphi.Layout.Row = 15; TX2.h1dphi.Layout.Column = 2;
btnLine = uibutton(lg, 'Text', 'Line', 'ButtonPushedFcn', @Drawline2_Callback); btnLine.Layout.Row = 15; btnLine.Layout.Column = 3;
btnLineExec = uibutton(lg, 'Text', 'Exec.', 'ButtonPushedFcn', @Linecut2_Callback); btnLineExec.Layout.Row = 15; btnLineExec.Layout.Column = 4;

% --- Row 16-19: Azimuthal Process ---
lblDiv3 = uilabel(lg, 'Text', '--- [ Azimuthal Process ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); lblDiv3.Layout.Row = 16; lblDiv3.Layout.Column = [1 4];
btnPoint = uibutton(lg, 'Text', 'Point Find', 'ButtonPushedFcn', @PointFind2_Callback); btnPoint.Layout.Row = 17; btnPoint.Layout.Column = [1 2];
lbl9 = uilabel(lg, 'Text', 'Pixel:'); lbl9.Layout.Row = 17; lbl9.Layout.Column = 3;
TX2.azipospix = uieditfield(lg, 'numeric', 'Value', 202); TX2.azipospix.Layout.Row = 17; TX2.azipospix.Layout.Column = 4;

lbl10 = uilabel(lg, 'Text', 'Range (-/+):'); lbl10.Layout.Row = 18; lbl10.Layout.Column = [1 2];
TX2.azipospixm = uieditfield(lg, 'numeric', 'Value', -1); TX2.azipospixm.Layout.Row = 18; TX2.azipospixm.Layout.Column = 3;
TX2.azipospixp = uieditfield(lg, 'numeric', 'Value', 1); TX2.azipospixp.Layout.Row = 18; TX2.azipospixp.Layout.Column = 4;
GUI.hMeanMedAzi = uidropdown(lg, 'Items', {'Mean', 'Median'}); GUI.hMeanMedAzi.Layout.Row = 19; GUI.hMeanMedAzi.Layout.Column = 1;

btnAziDraw = uibutton(lg, 'Text', 'Draw', 'ButtonPushedFcn', @DrawAziPlot2_Callback); btnAziDraw.Layout.Row = 19; btnAziDraw.Layout.Column = 2;
btnAziExec = uibutton(lg, 'Text', 'Exec.', 'ButtonPushedFcn', @Azilinecut2_Callback); btnAziExec.Layout.Row = 19; btnAziExec.Layout.Column = 3;

% [수정 핵심 3] 실시간 반영 연동
GUI.hNormal4 = uidropdown(lg, 'Items', NormalList, 'ValueChangedFcn', @PlotAziseries2_Callback); 
GUI.hNormal4.Layout.Row = 20; GUI.hNormal4.Layout.Column = 3;

btnAziPlot = uibutton(lg, 'Text', 'Plot', 'ButtonPushedFcn', @PlotAziseries2_Callback); btnAziPlot.Layout.Row = 20; btnAziPlot.Layout.Column = 4;

% --- Row 21-22: ROI Process ---
lblDiv4 = uilabel(lg, 'Text', '--- [ ROI Process ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); lblDiv4.Layout.Row = 21; lblDiv4.Layout.Column = [1 4];
lbl11 = uilabel(lg, 'Text', '# of ROI:'); lbl11.Layout.Row = 22; lbl11.Layout.Column = 1;
NROIList = {'1', '2', '3', '4', '5'};
GUI.hNROI = uidropdown(lg, 'Items', NROIList); GUI.hNROI.Layout.Row = 22; GUI.hNROI.Layout.Column = 2;
btnROI = uibutton(lg, 'Text', 'Draw ROI', 'ButtonPushedFcn', @ROIdef2_Callback); btnROI.Layout.Row = 22; btnROI.Layout.Column = [3 4];

% --- Row 23-26: Options ---
lblDiv5 = uilabel(lg, 'Text', '--- [ Options ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); lblDiv5.Layout.Row = 24; lblDiv5.Layout.Column = [1 4];
TmodeList = {'Temperature1', 'Temperature2', 'Time'};
GUI.hTmode = uidropdown(lg, 'Items', TmodeList, 'ValueChangedFcn', @Tmode_Callback); GUI.hTmode.Layout.Row = 25; GUI.hTmode.Layout.Column = [1 2];
GUI.hOrderT = uicheckbox(lg, 'Text', 'Temp. Sort', 'Value', 0, 'ValueChangedFcn', @Tmode_Callback); 
GUI.hOrderT.Layout.Row = 25; 
GUI.hOrderT.Layout.Column = [3 4];
btnAutoPlot = uibutton(lg, 'Text', 'Auto Refresh', 'ButtonPushedFcn', @Autoplot_Callback); 
btnAutoPlot.Layout.Row = 26; 
btnAutoPlot.Layout.Column = [1 2];
GUI.hParCom = uicheckbox(lg, 'Text', 'Parallel', 'Value', 0); GUI.hParCom.Layout.Row = 26; GUI.hParCom.Layout.Column = [3 4];

lblFooter = uilabel(lg, 'Text', 'Designed By Y.Y.Kim v2.0', 'FontSize', 9, 'FontColor', [0.5 0.5 0.5]); lblFooter.Layout.Row = 30;

% ========================= 2. Middle & Right Panels ======================
midGrid = uigridlayout(mainGrid, [2 1]); midGrid.RowHeight = {'1x', '1x'}; midGrid.Layout.Row = 1; midGrid.Layout.Column = 2; midGrid.Padding = [0 0 0 0];
rightGrid = uigridlayout(mainGrid, [2 1]); rightGrid.RowHeight = {'1x', '1x'}; rightGrid.Layout.Row = 1; rightGrid.Layout.Column = 3; rightGrid.Padding = [0 0 0 0];

% [Plot 1] Image Plot (Mid Up)
pnlImg = uipanel(midGrid, 'Title', '2D Image Plot', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w'); pnlImg.Layout.Row = 1;
gImg = uigridlayout(pnlImg, [2 1]); gImg.RowHeight = {'1x', 60}; gImg.Padding = [5 5 5 5];
hAX1 = uiaxes(gImg); hAX1.Layout.Row = 1;

cg1 = uigridlayout(gImg, [2 7]); cg1.RowHeight = {20, 25}; cg1.ColumnSpacing = 5; cg1.Padding = [0 0 0 0];

lblScale1 = uilabel(cg1, 'Text', 'ColorScale'); lblScale1.Layout.Row = 1; 
GUI.hScale1 = uidropdown(cg1, 'Items', scaleList, 'ValueChangedFcn', @Updateimage2_Callback); GUI.hScale1.Layout.Row = 2;

lblCmap1 = uilabel(cg1, 'Text', 'Colormap'); lblCmap1.Layout.Row = 1; 
GUI.hColor1 = uidropdown(cg1, 'Items', ColormapList, 'ValueChangedFcn', @Updateimage2_Callback); GUI.hColor1.Layout.Row = 2;

lblMinMax1 = uilabel(cg1, 'Text', 'Min/Max'); lblMinMax1.Layout.Row = 1; 
sub1 = uigridlayout(cg1, [1 2], 'Padding', [0 0 0 0]); sub1.Layout.Row = 2; 
TX2.cMin = uieditfield(sub1, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage2_Callback); TX2.cMax = uieditfield(sub1, 'numeric', 'Value', 1e6, 'ValueChangedFcn', @Updateimage2_Callback);

lblYRange1 = uilabel(cg1, 'Text', 'Y-Range'); lblYRange1.Layout.Row = 1; 
sub2 = uigridlayout(cg1, [1 2], 'Padding', [0 0 0 0]); sub2.Layout.Row = 2; 
TX2.cXlim1 = uieditfield(sub2, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage2_Callback); TX2.cXlim2 = uieditfield(sub2, 'numeric', 'Value', 2000, 'ValueChangedFcn', @Updateimage2_Callback);

lblZRange1 = uilabel(cg1, 'Text', 'Z-Range'); lblZRange1.Layout.Row = 1; 
sub3 = uigridlayout(cg1, [1 2], 'Padding', [0 0 0 0]); sub3.Layout.Row = 2; 
TX2.cYlim1 = uieditfield(sub3, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage2_Callback); TX2.cYlim2 = uieditfield(sub3, 'numeric', 'Value', 2000, 'ValueChangedFcn', @Updateimage2_Callback);

btnPlay1 = uibutton(cg1, 'Text', 'Play', 'ButtonPushedFcn', @Imageplay2_Callback); btnPlay1.Layout.Row = [1 2];
btnUpd1 = uibutton(cg1, 'Text', 'Update', 'ButtonPushedFcn', @Updateimage2_Callback); btnUpd1.Layout.Row = [1 2];

% [Plot 2] Azimuthal Plot (Mid Down)
pnlAzi = uipanel(midGrid, 'Title', 'Azimuthal Stack Plot', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w'); pnlAzi.Layout.Row = 2;
gAzi = uigridlayout(pnlAzi, [2 1]); gAzi.RowHeight = {'1x', 60}; gAzi.Padding = [5 5 5 5];
hAX2 = uiaxes(gAzi); hAX2.Layout.Row = 1;

cg2 = uigridlayout(gAzi, [2 6]); cg2.RowHeight = {20, 25}; cg2.ColumnSpacing = 5; cg2.Padding = [0 0 0 0];

lblPScale2 = uilabel(cg2, 'Text', 'Plot Scale'); lblPScale2.Layout.Row = 1; 
GUI.hAScale = uidropdown(cg2, 'Items', {'Linear', 'Logy'}, 'ValueChangedFcn', @updateAziplot_Callback); GUI.hAScale.Layout.Row = 2;

lblDeg2 = uilabel(cg2, 'Text', 'Deg (Min/Max)'); lblDeg2.Layout.Row = 1; 
sub4 = uigridlayout(cg2, [1 2], 'Padding', [0 0 0 0]); sub4.Layout.Row = 2; 
TX2.aziMin = uieditfield(sub4, 'numeric', 'Value', 0, 'ValueChangedFcn', @updateAziplot_Callback); TX2.aziMax = uieditfield(sub4, 'numeric', 'Value', 360, 'ValueChangedFcn', @updateAziplot_Callback);

btnNormAzi = uibutton(cg2, 'Text', 'Normalize', 'ButtonPushedFcn', @NormalFactorAzi_Callback); btnNormAzi.Layout.Row = [1 2];
btnHeatAzi = uibutton(cg2, 'Text', 'Heatmap', 'ButtonPushedFcn', @updateAziHeatmap_Callback); btnHeatAzi.Layout.Row = [1 2];
GUI.hSForm2 = uidropdown(cg2, 'Items', SForm); GUI.hSForm2.Layout.Row = [1 2];
btnSaveAzi = uibutton(cg2, 'Text', 'Save', 'ButtonPushedFcn', @Saveget2_Callback); btnSaveAzi.Layout.Row = [1 2];

% [Plot 3] Wave Vector Plot (Right Up)
pnl1D = uipanel(rightGrid, 'Title', '1D Wave Vector Plot', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w'); pnl1D.Layout.Row = 1;
g1D = uigridlayout(pnl1D, [2 1]); g1D.RowHeight = {'1x', 60}; g1D.Padding = [5 5 5 5];
hAX3 = uiaxes(g1D); hAX3.Layout.Row = 1;

cg3 = uigridlayout(g1D, [2 7]); cg3.RowHeight = {20, 25}; cg3.ColumnSpacing = 5; cg3.Padding = [0 0 0 0];
lblPScale3 = uilabel(cg3, 'Text', 'Plot Scale'); lblPScale3.Layout.Row = 1; 
GUI.hPScale = uidropdown(cg3, 'Items', {'Linear', 'Logy', 'Logxy'}, 'ValueChangedFcn', @update1Dplot_Callback); GUI.hPScale.Layout.Row = 2;

lblQ3 = uilabel(cg3, 'Text', 'Q (Min/Max)'); lblQ3.Layout.Row = 1; 
sub5 = uigridlayout(cg3, [1 2], 'Padding', [0 0 0 0]); sub5.Layout.Row = 2; 
TX2.qMin = uieditfield(sub5, 'numeric', 'Value', 0.01, 'ValueChangedFcn', @update1Dplot_Callback); TX2.qMax = uieditfield(sub5, 'numeric', 'Value', 10, 'ValueChangedFcn', @update1Dplot_Callback);

btnNorm1D = uibutton(cg3, 'Text', 'Normalize', 'ButtonPushedFcn', @NormalFactor_Callback); btnNorm1D.Layout.Row = [1 2];
btnInt1D = uibutton(cg3, 'Text', 'Integ.', 'ButtonPushedFcn', @updateIntplot_Callback); btnInt1D.Layout.Row = [1 2];
btnHeat1D = uibutton(cg3, 'Text', 'Heatmap', 'ButtonPushedFcn', @updateQHeatmap_Callback); btnHeat1D.Layout.Row = [1 2];
GUI.hSForm3 = uidropdown(cg3, 'Items', SForm); GUI.hSForm3.Layout.Row = [1 2];
btnSave1D = uibutton(cg3, 'Text', 'Save', 'ButtonPushedFcn', @Saveget3_Callback); btnSave1D.Layout.Row = [1 2];

% [Plot 4] Integration Plot (Right Down)
pnlInt = uipanel(rightGrid, 'Title', 'Integration & ROI Plot', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w'); pnlInt.Layout.Row = 2;
gInt = uigridlayout(pnlInt, [2 1]); gInt.RowHeight = {'1x', 60}; gInt.Padding = [5 5 5 5];
hAX4 = uiaxes(gInt); hAX4.Layout.Row = 1;

cg4 = uigridlayout(gInt, [2 5]); cg4.RowHeight = {20, 25}; cg4.ColumnWidth = {'1x', '1x', '1x', '1x', '1.2x'}; cg4.ColumnSpacing = 10; cg4.Padding = [0 0 0 0];
lblNorm5 = uilabel(cg4, 'Text', 'Normal:'); lblNorm5.Layout.Row = 1; lblNorm5.Layout.Column = 1;

% [수정 핵심 4] 실시간 반영 연동
GUI.hNormal5 = uidropdown(cg4, 'Items', NormalList, 'ValueChangedFcn', @PlotROI_Callback); 
GUI.hNormal5.Layout.Row = 2; GUI.hNormal5.Layout.Column = 1;

btnPlotROI = uibutton(cg4, 'Text', 'Plot ROI', 'ButtonPushedFcn', @PlotROI_Callback); btnPlotROI.Layout.Row = [1 2]; btnPlotROI.Layout.Column = 2;
btnNormROI = uibutton(cg4, 'Text', 'Norm ROI', 'ButtonPushedFcn', @NormalROII_Callback); btnNormROI.Layout.Row = [1 2]; btnNormROI.Layout.Column = 3;
lblSForm4 = uilabel(cg4, 'Text', 'Save Format:'); lblSForm4.Layout.Row = 1; lblSForm4.Layout.Column = 4;
GUI.hSForm4 = uidropdown(cg4, 'Items', SForm); GUI.hSForm4.Layout.Row = 2; GUI.hSForm4.Layout.Column = 4;
btnSaveData4 = uibutton(cg4, 'Text', 'Save Data', 'ButtonPushedFcn', @Saveget4_Callback); btnSaveData4.Layout.Row = 1; btnSaveData4.Layout.Column = 5;
btnSaveX4 = uibutton(cg4, 'Text', 'Save X-Axis', 'ButtonPushedFcn', @SavegetX_Callback); btnSaveX4.Layout.Row = 2; btnSaveX4.Layout.Column = 5;

% =========================================================================
% ====================== CALLBACK FUNCTIONS ===============================
% =========================================================================

    % [통합 플롯 리프레시 콜백 - Subtraction 변동용]
    function RefreshAllPlots_Callback(~,~)
        if isfield(param, 'data1dstack'), Plot1dseries_Callback(); end
        if isfield(param, 'dataAzistack'), PlotAziseries2_Callback(); end
        if isfield(param, 'SumIROI'), PlotROI_Callback(); end
    end

    function pathset2_Callback(~,~)
        pathway = uigetdir;
        figure(GUI.main); drawnow;
        if pathway ~= 0, TX2.pathset.Value = pathway; end
    end

    function TimeUpdate_Callback(~,~)
        param.TimeUnit = GUI.hTimeP.Value;
        param.TimeOffset = TX2.hExptime.Value;
        if isfield(param, 'data1dstackN') && ~isempty(param.data1dstackN), update1Dplot; updateIntplot; end
        if isfield(param, 'dataAzistackN') && ~isempty(param.dataAzistackN), updateAziplot_Callback; end
        if (isfield(param, 'SumIROIN') && ~isempty(param.SumIROIN)) || (isfield(param, 'SumIROI') && ~isempty(param.SumIROI)), PlotROI_Callback; end
    end

    function Openimage2_Callback(~,~)
        param.detector = GUI.hDetector.Value;
        pathway = TX2.pathset.Value;
        [XSImage, datadir]=uigetfile({'*.*','All format(*.*)'},'Select a file',pathway);
        figure(GUI.main); drawnow;
        if XSImage==0, return; end
        XSImage = fullfile(datadir, XSImage);

        [param.Path, param.FileName, param.FileFormat] = fileparts(XSImage);

        switch param.FileFormat 
            case '.h5'
                try param.data = loadPGIXSH5Frame(XSImage);
                catch ME, uialert(GUI.main, ['There is no data: ' ME.message], 'Warning'); return; end
                
                meta = readPGIXSH5Metadata(XSImage);
                param.Count = [meta.Counter1, meta.CounterBC];
                
                newStr = normalizePGIXSSeriesPrefix(param.FileName);
                TX2.hFilename.Value = newStr;
            otherwise
                uialert(GUI.main, 'Please use h5 format!!','Warning'); return
        end
        param.dataSize = single(size(param.data));

        [param.Mask, param.pixel, maskReport] = loadPGIXSDetectorMask(param.detector);
        if maskReport.FallbackUsed && ~isempty(maskReport.Message)
            uialert(GUI.main, ['Detector mask warning: ', maskReport.Message], 'Warning');
        end

        if isequal(double(param.dataSize), double(size(param.Mask)))
            param.data = param.data .* param.Mask;
        else
            uialert(GUI.main, sprintf('Detector mask size %s does not match data size %s. Mask skipped.', ...
                mat2str(size(param.Mask)), mat2str(double(param.dataSize))), 'Warning');
        end
        param.data(param.data>=1e9) = nan;

        [param.cmin, param.cmax] = computePGIXSDisplayLimits(param.data);
        TX2.cMax.Value = double(param.cmax); TX2.cMin.Value = double(param.cmin);

        if param.Expinfo == 0
            param.HD = single(1:param.dataSize(2)); param.VD = single(1:param.dataSize(1));
        else
            param.HD = single((1:param.dataSize(2)) - param.bpos(1)); param.VD = single(-((1:param.dataSize(1)) - param.bpos(2)));
        end
        
        TX2.cXlim1.Value = double(min(param.HD)); TX2.cXlim2.Value = double(max(param.HD));
        TX2.cYlim1.Value = double(min(param.VD)); TX2.cYlim2.Value = double(max(param.VD));

        GUI.btnQcal.BackgroundColor = [0.96 0.96 0.96]; 
        updateImage2; param.correctionI = 0; 
    end

    function OpenNameDef_callback(~,~)
        if ~isfield(param,'FileName'), uialert(GUI.main, 'Please load data first!','Warning'); return; end
        param.expmode = GUI.hinsitumode.Value; param.FileName = TX2.hFilename.Value;
        [names, files, N] = listPGIXSSeriesFiles(param.Path, param.FileName, '.h5');
        if N == 0, uialert(GUI.main, 'There is no such a filename!','Warning'); return; end
        
        TrowName = num2cell((1:N)'); tf = true(N,1); T = table(files',names',tf);
        f = uifigure('Name', 'File List', 'Position', [400 300 600 600]);
        fg = uigridlayout(f, [2 1]); fg.RowHeight = {'1x', 40}; fg.Padding = [10 10 10 10];
        
        uit = uitable(fg, 'Data', table2cell(T), 'RowName', TrowName, 'ColumnName', {'FullName', 'FileName', 'Check'}, 'ColumnWidth', {'auto', 'auto', 50}, 'ColumnEditable', [false false true]); uit.Layout.Row = 1;
        btn = uibutton(fg, 'Text', 'Export & Load', 'FontSize', 14, 'FontWeight', 'bold', 'ButtonPushedFcn', @(h,e)table2workspace(uit,f)); btn.Layout.Row = 2;
    end

    function table2workspace(uit,f)
        tmp = uit.Data(:, 3); exportbool = [tmp{:}]; files = uit.Data(exportbool, 1);
        
        % [핵심 1] 창을 파괴하지 않고 일단 숨기기만 함 (DestroyedObject 에러 원천 차단)
        f.Visible = 'off'; 
        drawnow; 
        
        Loadingdata(files);
        
        % 모든 로딩 프로세스가 무사히 끝난 뒤 안전하게 메모리에서 삭제
        if isvalid(f)
            delete(f); 
        end
    end

    function Loadingdata(files)
        ParallelCom = GUI.hParCom.Value; N = length(files);
        
        % ========================================================
        % [핵심 2] 이전 데이터 완전 삭제 및 메모리 공간 확보 (OOM 방지)
        if isfield(param, 'Stack'), param.Stack = []; end
        if isfield(param, 'data1dstack'), param.data1dstack = []; param.data1dstackN = []; param.std1dstack = []; param.std1dstackN = []; end
        if isfield(param, 'dataAzistack'), param.dataAzistack = []; param.dataAzistackN = []; end
        if isfield(param, 'SumIROI'), param.SumIROI = []; param.SumIROIN = []; end
        
        % MATLAB의 가비지 컬렉터(GC)가 RAM을 회수할 시간을 잠깐 부여
        pause(0.2);
        % ========================================================
        
        try 
            param.Stack = zeros(param.dataSize(1), param.dataSize(2), N, 'single'); 
        catch ME
            uialert(GUI.main, ['Not enough memory: ', ME.message], 'Error'); 
            return; 
        end
        param.loginfo = zeros(2,N, 'single'); param.timestampinfo = zeros(N,1); param.temperatureinfo = zeros(N,2, 'single');
        
        meta = readPGIXSH5Metadata(files{1}, param.expmode);
        param.RefIC = meta.Counter1;
        param.RefBC = meta.CounterBC;
        param.ts1 = meta.Timestamp;
        
        param.TimeUnit = GUI.hTimeP.Value; 
        MaskData = param.Mask; expmode_local = param.expmode;
        RefIC_local = param.RefIC; RefBC_local = param.RefBC;
        
        dlg = uiprogressdlg(GUI.main, 'Title', 'Loading Data', 'Message', sprintf('Preparing to load %d files...', N), 'Cancelable', 'on', 'Indeterminate', 'off'); t_start = tic;
        loadedCount = 0;
        loadFailed = false(1, N);
        metadataFailed = false(1, N);
        
        if ParallelCom == 1
            Stack_local = param.Stack; loginfo1 = zeros(1,N,'single'); loginfoBC = zeros(1,N,'single'); ts_info = zeros(N,1); temp_info = zeros(N,2,'single');
            try
                Q = parallel.pool.DataQueue; progress_count = 0; afterEach(Q, @(~) progressUpdate()); useQueue = true;
            catch ME
                warning('TrXS2:DataQueueUnavailable', 'Parallel progress queue unavailable: %s', ME.message);
                useQueue = false;
            end
            
            parfor ii=1:N
                [D, okFrame, loadReport] = loadPGIXSH5FrameWithRetry(files{ii}, MaskData, NaN, size(MaskData));
                Stack_local(:,:,ii)=D;
                loadFailed(ii) = ~okFrame;
                metadataFailed(ii) = false;
                if ~okFrame
                    warning('TrXS2:DataLoadFailed', 'Data load failed for frame %d after %d attempts: %s', ii, loadReport.Attempts, loadReport.Message);
                end
                
                % [수정 사항] 인수 개수 불일치 버그 수정 (5개 -> 2개)
                try 
                    [c1, cBC, ts_val, t_vec] = read_metadata_worker(files{ii}, expmode_local); 
                catch ME
                    warning('TrXS2:MetadataReadFailed', 'Metadata read failed for frame %d: %s', ii, ME.message);
                    metadataFailed(ii) = true;
                    c1 = nan; cBC = nan; ts_val = nan; t_vec = [nan nan]; 
                end
                
                normCounts = normalizePGIXSCounters([c1 cBC], [RefIC_local RefBC_local]);
                loginfo1(ii) = normCounts(1); loginfoBC(ii) = normCounts(2);
                ts_info(ii) = ts_val; temp_info(ii,:) = t_vec;
                
                if useQueue, send(Q, ii); end 
            end
            param.Stack = Stack_local; param.loginfo = [loginfo1; loginfoBC]; param.timestampinfo = ts_info; param.temperatureinfo = temp_info;
            loadedCount = N;
        else
            for ii=1:N
                if dlg.CancelRequested, break; end
                [D, okFrame, loadReport] = loadPGIXSH5FrameWithRetry(files{ii}, MaskData, NaN, size(MaskData));
                param.Stack(:,:,ii)=D;
                loadFailed(ii) = ~okFrame;
                metadataFailed(ii) = false;
                if ~okFrame
                    warning('TrXS2:DataLoadFailed', 'Data load failed for frame %d after %d attempts: %s', ii, loadReport.Attempts, loadReport.Message);
                end
                
                % [수정 사항] 인수 개수 불일치 버그 수정 (5개 -> 2개)
                try 
                    [c1, cBC, ts_val, t_vec] = read_metadata_worker(files{ii}, expmode_local); 
                catch ME
                    warning('TrXS2:MetadataReadFailed', 'Metadata read failed for frame %d: %s', ii, ME.message);
                    metadataFailed(ii) = true;
                    c1 = nan; cBC = nan; ts_val = nan; t_vec = [nan nan]; 
                end
                
                normCounts = normalizePGIXSCounters([c1 cBC], [RefIC_local RefBC_local]);
                v1 = normCounts(1); v2 = normCounts(2);
                param.loginfo(:,ii) = [v1; v2]; param.timestampinfo(ii) = ts_val; param.temperatureinfo(ii,:) = t_vec;
                loadedCount = ii;
                
                if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                    dlg.Value = ii/N;
                    dlg.Message = loadingProgressMsg(ii, N, t_start);
                    drawnow limitrate; % UI 스레드 강제 비우기
                end
            end
        end
        if exist('dlg','var') && isvalid(dlg), close(dlg); end
        if loadedCount == 0
            param.Stack = [];
            return;
        end
        if loadedCount < N
            [param.Stack, param.loginfo, param.timestampinfo, param.temperatureinfo] = trimPGIXSSeriesData( ...
                param.Stack, param.loginfo, param.timestampinfo, param.temperatureinfo, loadedCount);
            N = loadedCount;
        end
        failureSummary = summarizePGIXSFrameFailures(loadFailed, metadataFailed, N);
        param.RetryFailedFrames = failureSummary.RetryFailedFrames;
        param.MetadataFailedFrames = failureSummary.MetadataFailedFrames;
        param.data = mean(param.Stack,3,'omitnan'); [param.cmin, param.cmax] = computePGIXSDisplayLimits(param.data);
        TX2.cMax.Value = double(param.cmax); 
        TX2.cMin.Value = double(param.cmin); 
        TX2.NFile.Text = num2str(N); 
        
        Auto.Nold = N;

        updateImage2();
        failedLoadCount = failureSummary.RetryFailedCount;
        if failedLoadCount > 0
            [message, titleText] = formatPGIXSFrameFailureWarning( ...
                failedLoadCount, param.RetryFailedFrames, 'load', 'load');
            uialert(GUI.main, message, titleText, 'Icon', 'warning');
        end
        failedMetadataCount = failureSummary.MetadataFailedCount;
        if failedMetadataCount > 0
            [message, titleText] = formatPGIXSFrameFailureWarning( ...
                failedMetadataCount, param.MetadataFailedFrames, 'metadata', 'load');
            uialert(GUI.main, message, titleText, 'Icon', 'warning');
        end
        figure(GUI.main);

        function progressUpdate()
            progress_count = progress_count + 1; if isvalid(dlg), dlg.Value = min(1, progress_count / N); dlg.Message = loadingProgressMsg(progress_count, N, t_start); end
        end
        function msg = loadingProgressMsg(curr, total, t_st)
            msg = formatPGIXSProgressMessage(curr, total, toc(t_st));
        end
    end

    function OpenICplot_callback(~,~), plot_counter(param.loginfo(1,:), 'IC'); end
    function OpenBCplot_callback(~,~), plot_counter(param.loginfo(2,:), 'BC'); end
    function plot_counter(Data, Name)
        if isempty(Data), return; end
        figure('Name',[Name ' Value'],'NumberTitle','off', ...
            'CloseRequestFcn', @(src,~) closePlotCounter(src));
        plot(Data,'-ok','MarkerFaceColor','k'); axis tight; xlabel('Shot #'); ylabel('Value'); title(Name);
    end
    function closePlotCounter(src)
        delete(src);
        if isvalid(GUI.main), figure(GUI.main); drawnow; end
    end

    function updateImage2
        if isempty(param.data), return; end
        param.colorscale = GUI.hScale1.Value;
        param.colorm     = GUI.hColor1.Value;
        param.cmax       = TX2.cMax.Value;
        param.cmin       = TX2.cMin.Value;
        param.Mapping    = 'Pixel';

        % ---- 표시용 다운샘플 (원본 param.data는 건드리지 않음) -----------------
        %  uifigure(웹/CEF) 렌더러는 큰 2D 이미지 합성에 취약해, 콜백이 끝나고
        %  화면을 합성하는 순간 창이 닫힐 수 있다. 화면 표시에만 솎은 복사본을 쓴다.
        dispData = param.data;
        dispHD = []; dispVD = [];
        if isfield(param, 'HD'), dispHD = param.HD; end
        if isfield(param, 'VD'), dispVD = param.VD; end
        stepd = max(1, ceil(max(size(param.data)) / 1100));   % 큰 변을 ~1100 px로 축소
        if stepd > 1
            dispData = dispData(1:stepd:end, 1:stepd:end);
            if ~isempty(dispHD), dispHD = dispHD(1:stepd:end); end
            if ~isempty(dispVD), dispVD = dispVD(1:stepd:end); end
        end

        cla(hAX1);
        if ~isempty(dispHD) && ~isempty(dispVD)
            imagesc(hAX1, dispHD, dispVD, dispData);
        else
            imagesc(hAX1, dispData);
        end

        if param.Expinfo == 0
            set(hAX1, 'YDir', 'reverse');
            xlabel(hAX1, 'Y (pixel)'); ylabel(hAX1, 'Z (pixel)');
        else
            set(hAX1, 'YDir', 'normal');
            xlabel(hAX1, 'Y (pixel relative)'); ylabel(hAX1, 'Z (pixel relative)');
        end
        axis(hAX1, 'image');

        x_lim = [TX2.cXlim1.Value, TX2.cXlim2.Value];
        y_lim = [TX2.cYlim1.Value, TX2.cYlim2.Value];
        if x_lim(1) >= x_lim(2) || y_lim(1) >= y_lim(2)
            if isfield(param, 'HD')
                x_lim = double([min(param.HD), max(param.HD)]);
                y_lim = double([min(param.VD), max(param.VD)]);
            end
            if x_lim(1) < x_lim(2)
                TX2.cXlim1.Value = x_lim(1); TX2.cXlim2.Value = x_lim(2);
                TX2.cYlim1.Value = y_lim(1); TX2.cYlim2.Value = y_lim(2);
            end
        end
        xlim(hAX1, x_lim); ylim(hAX1, y_lim);
        clim(hAX1, [param.cmin, param.cmax]);

        applyPGIXSAxesColorScale(hAX1, param.colorscale);

        applyPGIXSColormap(hAX1, param.colorm, dispData);
        hcb = colorbar(hAX1); hcb.LineWidth = 1.5; hcb.TickDirection = 'out';
        hcb.Label.String = 'Intensity (a.u.)';
        set(hAX1, 'LineWidth', 2, 'Tickdir', 'in', 'FontSize', 12, 'FontName', 'times');
        title(hAX1, param.FileName, 'Interpreter', 'none', 'FontSize', 11);
    end

    function Updateimage2_Callback(~,~), updateImage2; end

    function Bkgload2_Callback(~,~)
        pathway = TX2.pathset.Value; [XSBKG, datadir]=uigetfile({'*.*','All format(*.*)'},'Select BKG',pathway);
        figure(GUI.main); drawnow;
        if XSBKG==0, return; end
        [~, param.BKGFile, FileFormat]=fileparts(XSBKG);
        d = uiprogressdlg(GUI.main, 'Title', 'Loading BKG', 'Message', 'Background Loading...', 'Indeterminate', 'on');
        newStr = normalizePGIXSSeriesPrefix(param.BKGFile);
        [~, files, N] = listPGIXSSeriesFiles(datadir, newStr, FileFormat); if isempty(files), files = {fullfile(datadir, XSBKG)}; N=1; end
        runSum = zeros(param.dataSize(1), param.dataSize(2), 'single');
        cntSum = zeros(2,1, 'single');
        loadedCount = 0;
        metadataCount = 0;
        d.Indeterminate = 'off';
        
        for k=1:N
            d.Value = k/N;
            [D, okFrame, loadReport] = loadPGIXSH5FrameWithRetry(files{k}, param.Mask, 0, param.dataSize);
            if ~okFrame
                warning('TrXS2:BkgDataLoadFailed', 'Background load failed for frame %d after %d attempts: %s', k, loadReport.Attempts, loadReport.Message);
            else
                runSum = runSum + D;
                loadedCount = loadedCount + 1;
            end

            try
                [c1, cBC, ~, ~] = read_metadata_worker(files{k}, param.expmode);
                cntSum = cntSum + [single(c1); single(cBC)];
                metadataCount = metadataCount + 1;
            catch ME
                warning('TrXS2:BkgMetadataReadFailed', 'Background metadata read failed for frame %d: %s', k, ME.message);
            end
        end
        if loadedCount == 0
            close(d);
            uialert(GUI.main, 'No background frames could be loaded.', 'Background Load Failed');
            return;
        end
        param.bkg = runSum ./ loadedCount;
        param.bkg(param.bkg==0) = nan;
        if metadataCount > 0
            cntAvg = cntSum ./ metadataCount;
        else
            cntAvg = [nan; nan];
        end
        if isfield(param, 'RefIC') && isfield(param, 'RefBC')
            param.Countbkg = normalizePGIXSCounters(cntAvg, [param.RefIC param.RefBC]);
        else
            param.Countbkg = cntAvg';
        end
        close(d); GUI.btnBkg.BackgroundColor = [0.75 0.95 0.75]; uialert(GUI.main, 'Background loaded successfully.', 'Success');
    end

    function Openinfo2_Callback(~,~)
        pathway = TX2.pathset.Value; [XSinfo, datadir]=uigetfile({'*.mat'},'Select info file',pathway);
        figure(GUI.main); drawnow;
        if XSinfo==0, return; end
        [S, loadReport] = loadPGIXSStandardCalibration(fullfile(datadir, XSinfo), param.detector);
        if loadReport.OK
            param.Wavelength = S.wavelength; param.bpos = S.pc; param.SDD = S.sdd; param.Energy = S.Energy;
            param.HD = single((1:param.dataSize(2)) - param.bpos(1)); param.VD = single(-((1:param.dataSize(1)) - param.bpos(2)));
            TX2.cXlim1.Value = double(min(param.HD)); TX2.cXlim2.Value = double(max(param.HD)); TX2.cYlim1.Value = double(min(param.VD)); TX2.cYlim2.Value = double(max(param.VD));
            param.Expinfo = 1; GUI.btnInfo.BackgroundColor = [0.75 0.95 0.75]; updateImage2;
            figure(GUI.main); drawnow;
        else
            uialert(GUI.main, loadReport.Message, 'Calibration Warning', 'Icon', 'warning'); 
        end
    end

    function GridRemove2_Callback(~,~)
        if ~isfield(param, 'Stack'), return; end
        N = size(param.Stack,3); d = uiprogressdlg(GUI.main, 'Title', 'Grid Remove', 'Message', 'Removing Grid...');
        failedFrames = zeros(1, N);
        nFailedFrames = 0;
        failMessage = '';
        for ii = 1:N
            D = param.Stack(:,:,ii); nmask = isnan(D); D(nmask)=0;
            try
                [D, gridReport] = Gridremover(D);
                if ~gridReport.Applied
                    nFailedFrames = nFailedFrames + 1;
                    failedFrames(nFailedFrames) = ii;
                    if isempty(failMessage), failMessage = gridReport.Message; end
                end
            catch ME
                nFailedFrames = nFailedFrames + 1;
                failedFrames(nFailedFrames) = ii;
                if isempty(failMessage), failMessage = ME.message; end
            end
            D(nmask) = nan; param.Stack(:,:,ii) = D;

            % 일정 간격으로만 상태바 업데이트 및 UI 호흡
            if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                d.Value = ii/N;
                drawnow limitrate;
            end
        end
        failedFrames = failedFrames(1:nFailedFrames);
        close(d); param.data = mean(param.Stack,3,'omitnan'); updateImage2;
        if ~isempty(failedFrames)
            warning('TrXS2:GridRemoveFailed', 'Grid remover failed for %d frame(s): %s', numel(failedFrames), failMessage);
            uialert(GUI.main, sprintf('Grid remover failed for %d frame(s).\nFrames: %s', ...
                numel(failedFrames), formatPGIXSFrameIndexList(failedFrames)), 'Grid Remove Warning', 'Icon', 'warning');
        end
    end

    function Qcalc_Callback(~,~)
        if param.correctionI == 1, uialert(GUI.main, 'Already corrected!','Warning'); return; end
        if ~isfield(param, 'Wavelength'), uialert(GUI.main, 'Load Parameters first!','Warning'); return; end
        
        k0 = (2*pi/param.Wavelength); d = uiprogressdlg(GUI.main, 'Title', 'Calculating', 'Message', 'Q-Map Generation...', 'Indeterminate', 'on');
        [~,~,~,param.Q] = Qmaping_tr(param.dataSize(2),param.dataSize(1),param.bpos,param.pixel,param.SDD,k0);
        TotalCorr = computePGIXSDetectorCorrectionFactor(param, k0);
        
        ParallelCom = GUI.hParCom.Value; N = size(param.Stack,3); Stack_local = param.Stack; InvFactor = 1 ./ TotalCorr; param.InvFactor = single(InvFactor);   % 보정인자 1회 계산·저장 (auto-refresh 재사용)
        d.Indeterminate = 'off'; d.Message = 'Applying Correction...';
        if ParallelCom == 1, d.Indeterminate = 'on'; parfor ii = 1:N, Stack_local(:,:,ii) = Stack_local(:,:,ii) .* InvFactor; end
        else
            for ii = 1:N
                Stack_local(:,:,ii) = Stack_local(:,:,ii) .* InvFactor;
                if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                    d.Value = ii/N;
                    drawnow limitrate;
                end
            end
        end
        
        param.Stack = Stack_local; param.data = mean(param.Stack,3,'omitnan');
        if isfield(param, 'bkg'), param.bkg = param.bkg .* InvFactor; end
        param.correctionI = 1; close(d); GUI.btnQcal.BackgroundColor = [0.75 0.95 0.75]; updateImage2; uialert(GUI.main, 'Q-Correction Done.', 'Success');
    end

    function Imageplay2_Callback(~,~), FrameImage(param); end

    function SaveStack_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'Do Q-Cal first!','Warning'); return; end
        [filepath, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        d = uiprogressdlg(GUI.main, 'Title', 'Saving', 'Message', 'Saving Stack...', 'Indeterminate', 'on');
        FN = [param.FileName, '_2Dinfo.mat'];
        filePath = fullfile(filepath, FN);
        info = buildPGIXSStackInfo(param, 'TrXS');
        savePGIXSStackFile(filePath, info);
        close(d); uialert(GUI.main, 'Stack Saved!', 'Success');
    end

    function BW = get_modern_mask(data, cmin, cmax, colorscale, colorm, msg)
        scr = get(groot, 'ScreenSize');                  % 모니터 크기 [1 1 W H]
        figH = scr(4) - 80;                              % 위아래로 화면 높이 꽉 채움(타이틀바/작업표시줄 여유)
        ar = size(data,2) / max(size(data,1), 1);        % 이미지 가로/세로 비
        figW = min(round(figH * ar) + 80, scr(3) - 40);  % 이미지가 세로를 꽉 채우도록 폭을 비율로 설정(화면 폭 제한)
        figL = max(20, round((scr(3) - figW) / 2));      % 가로 중앙 배치
        f1 = uifigure('Name', 'Mask Selection', 'Position', [figL 40 figW figH]);
        ax1 = uiaxes(f1, 'Units', 'normalized', 'Position', [0.04 0.04 0.92 0.90]);  % 창 크기에 맞춰 축이 채워짐
        imagesc(ax1, data); axis(ax1, 'image'); clim(ax1, [cmin, cmax]);
        applyPGIXSAxesColorScale(ax1, colorscale);
        applyPGIXSColormap(ax1, colorm, data);
        title(ax1, [msg, ' (그리기 완료 후 더블 클릭)'], 'FontSize', 13, 'Color', 'r', 'FontWeight', 'bold');
        hROI = drawpolygon(ax1, 'Color', 'r'); wait(hROI); BW = createMask(hROI, size(data,1), size(data,2)); BW = double(BW); BW = abs(BW-1); BW(BW==0) = nan; close(f1);
    end

    function CircularAve2_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'Do Q-Cal first!','Warning'); return; end
        if ~isfield(param, 'Q') || isempty(param.Q)
            uialert(GUI.main, 'Q-map (param.Q) is missing. Run qMap first.', 'Error'); return;
        end

        Angmin = TX2.hAng1dmin.Value;
        Angmax = TX2.hAng1dmax.Value;

        if Angmin == 0 && Angmax == 360
            selection = uiconfirm(GUI.main, 'Do you need a mask?', 'Mask', ...
                'Options', {'Yes','No'}, 'DefaultOption', 'Yes');
            if strcmp(selection, 'Yes')
                BW = get_modern_mask(param.data, param.cmin, param.cmax, ...
                    param.colorscale, param.colorm, '마스크 영역을 지정하세요.');
            else
                BW = ones(param.dataSize(1), param.dataSize(2), 'single');
            end
        else
            BW = ones(param.dataSize(1), param.dataSize(2), 'single');
        end
        param.BW = BW;

        Medfunct    = GUI.hMedianB.Value;
        stdfunct    = GUI.hStdI2.Value;
        ParallelCom = GUI.hParCom.Value;
        N = size(param.Stack, 3);

        d = uiprogressdlg(GUI.main, 'Title', 'Calculating', ...
            'Message', 'q-Binning Setup...', 'Indeterminate', 'on');

        try
            [n, m] = size(param.data);
            bpx = single(param.bpos(1));
            bpy = single(param.bpos(2));

            if ~(Angmin == 0 && Angmax == 360)
                [Xg, Yg] = meshgrid(single(1:m), single(1:n));
                ang = atan2d(-(Yg - bpy), -(Xg - bpx));
                ang = mod(ang, 360);
                a1 = mod(Angmin, 360); a2 = mod(Angmax, 360);
                if a1 < a2, sector_mask = (ang >= a1) & (ang <= a2);
                else,        sector_mask = (ang >= a1) | (ang <= a2); end
            else
                sector_mask = true(n, m);
            end

            geom_valid = sector_mask & (BW > 0) & isfinite(param.Q) & (param.Q > 0);
            if ~any(geom_valid(:))
                error('No valid pixels in geometry mask.');
            end
            
            radiusPrep = buildPGIXSRadiusBinMap(param.Q, [bpx, bpy], geom_valid);
            if ~radiusPrep.isValid
                error('No valid radius bins after geometry masking.');
            end

            param.qbin = radiusPrep;
            param.qbin.dataSize = [n, m];
            param.strict_mask = geom_valid;
            param.pixPlot = radiusPrep.r_axis(:);
            param.Qtr = radiusPrep.q_axis(:);

            len = radiusPrep.n_bins;
            data1dstack_temp = zeros(len, N+1, 'single');
            data1dstack_temp(:, 1) = radiusPrep.q_axis(:);
            if stdfunct
                std1dstack_temp = zeros(len, N+1, 'single');
                std1dstack_temp(:, 1) = radiusPrep.q_axis(:);
            end

            Stack_local = param.Stack;
            useMedian = (Medfunct == 1);

            if ParallelCom == 1
                if isvalid(d), d.Indeterminate = 'on'; d.Message = sprintf('병렬 연산 진행 중... (총 %d 프레임)', N); drawnow limitrate; end
                local_prep = radiusPrep;
                if stdfunct
                    parfor ii = 1:N
                        D = Stack_local(:,:,ii) .* BW;
                        [zr, zr_std] = processPGIXSRadiusBin1D(D, local_prep, useMedian, true);
                        data1dstack_temp(:, ii+1) = zr; std1dstack_temp(:, ii+1) = zr_std;
                    end
                else
                    parfor ii = 1:N
                        D = Stack_local(:,:,ii) .* BW;
                        zr = processPGIXSRadiusBin1D(D, local_prep, useMedian, false);
                        data1dstack_temp(:, ii+1) = zr;
                    end
                end
            else
                d.Indeterminate = 'off';
                for ii = 1:N
                    if mod(ii, max(1,floor(N/100)))==0 || ii==N, if isvalid(d), d.Value = ii / N; end; end
                    D = Stack_local(:,:,ii) .* BW;
                    if stdfunct
                        [zr, zr_std] = processPGIXSRadiusBin1D(D, radiusPrep, useMedian, true);
                        data1dstack_temp(:, ii+1) = zr; std1dstack_temp(:, ii+1) = zr_std;
                    else
                        zr = processPGIXSRadiusBin1D(D, radiusPrep, useMedian, false);
                        data1dstack_temp(:, ii+1) = zr;
                    end
                end
            end
            clear Stack_local D;   % 큰 작업 복사본 해제(메모리 여유 확보)
            param.data1dstack = data1dstack_temp;
            if stdfunct, param.std1dstack = std1dstack_temp; end

            if isfield(param, 'bkg') && ~isempty(param.bkg)
                D = single(param.bkg) .* BW;
                zr_bkg = processPGIXSRadiusBin1D(D, radiusPrep, useMedian, false);
                param.bkg1d = zr_bkg;
            end
            Auto.Met = AUTO_CIRCULAR;

            % [핵심 1] 상태창을 닫지 않고 유지한 채로 플롯부터 그립니다.
            if exist('d', 'var') && isvalid(d)
                d.Message = 'Drawing Plots... Please wait';
                drawnow limitrate;
            end

            Plot1dseries_Callback([], []);
            
            if Angmin ~= 0 || Angmax ~= 360
                updateImage2;
                hold(hAX1, 'on');
                maxR = max(param.dataSize) * 1.5;
                if param.Expinfo == 0
                    cx = param.bpos(1); cy = param.bpos(2); y_sign = -1;
                else
                    cx = 0; cy = 0; y_sign = 1;
                end
                x1 = cx - maxR * cosd(Angmin); y1 = cy + y_sign * maxR * sind(Angmin);
                x2 = cx - maxR * cosd(Angmax); y2 = cy + y_sign * maxR * sind(Angmax);
                plot(hAX1, [cx, x1], [cy, y1], 'w--', 'LineWidth', 2);
                plot(hAX1, [cx, x2], [cy, y2], 'w--', 'LineWidth', 2);
                hold(hAX1, 'off');
            end

            % [핵심 2] 함수 종료 전에 쌓인 그래픽 명령을 화면에 강제로 다 뿌려버립니다.
            drawnow; 
            pause(0.5); % 그래픽 엔진이 숨을 고를 시간을 0.5초 부여합니다.

            % [핵심 3] 화면이 모두 안정된 후 큐를 비우고 창을 닫습니다.
            if exist('Q_queue', 'var'), clear Q_queue; end
            if exist('Q', 'var') && isa(Q, 'parallel.pool.DataQueue'), clear Q; end
            if exist('d', 'var') && isvalid(d)
                close(d);
            end

        catch ME
            if exist('d', 'var') && isvalid(d)
                close(d); 
                pause(0.5);
            end
            uialert(GUI.main, ['Averaging error: ' ME.message], 'Error');
        end
    end

    function Plot1dseries_Callback(~,~)
        Normalway = GUI.hNormal2.Value;
        Subton = GUI.hSubract_S.Value;

        if ~isfield(param, 'data1dstack')
            return;
        end

        param.data1dstackN = param.data1dstack(:, 2:end);
        hasSTD = isfield(param, 'std1dstack') && ~isempty(param.std1dstack);

        if hasSTD
            param.std1dstackN = param.std1dstack(:, 2:end);
        end

        dataSize = size(param.data1dstackN);

        for ii = 1:dataSize(2)
            norm_val = getPGIXSNormalizationValue(param.loginfo, Normalway, ii);

            param.data1dstackN(:,ii) = param.data1dstackN(:,ii) ./ norm_val;

            if hasSTD
                param.std1dstackN(:,ii) = param.std1dstackN(:,ii) ./ norm_val;
            end

            if Subton == 1 && isfield(param, 'bkg1d')
                bkg_norm_val = getPGIXSNormalizationValue(param.Countbkg, Normalway, 1);
                param.data1dstackN(:,ii) = param.data1dstackN(:,ii) - (param.bkg1d ./ bkg_norm_val);
            end
        end

        Q = param.data1dstack(:, 1);

        % [UI Unchaining]
        TX2.qMin.Value = double(min(Q, [], 'omitnan'));
        TX2.qMax.Value = double(max(Q, [], 'omitnan'));

        update1Dplot;
        updateIntplot;
    end

    function Drawline2_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'Do Q-Cal first!','Warning'); return; end
        input_ang = mod(single(TX2.h1dphi.Value), 360); param.ang = input_ang; 
        try 
            [param.linepos, param.line1dang] = Anglecut1d(param); 
        catch ME
            uialert(GUI.main, ['Anglecut error: ' ME.message], 'Error'); return; 
        end
        % TrXS 좌표계에 맞춘 Ray(반직선) 시각화 보정
        R = 5000; th = deg2rad(input_ang); 
        x_line = [0, -R * cos(th)]; 
        y_line = [0, R * sin(th)];
        updateImage2; hold(hAX1,'on'); plot(hAX1, x_line, y_line, '-w', 'LineWidth', 2); hold(hAX1,'off');
    end

    function Linecut2_Callback(~,~)
        if ~isfield(param,'line1dang'), uialert(GUI.main, 'Draw line first!','Warning'); return; end
        N = size(param.Stack,3); Stack_local = param.Stack;
        p_worker = param; if isfield(p_worker,'Stack'), p_worker=rmfield(p_worker,'Stack'); end
        
        d = uiprogressdlg(GUI.main, 'Title', 'Calculating', 'Message', 'Line Cutting...', 'Indeterminate', 'on');
        
        try
            % 새로 구현된 Anglecut1d를 직접 호출
            [~, ref_line] = Anglecut1d(p_worker, Stack_local(:,:,1));
            ref_distance = ref_line(:,1);
            Q1d_new = ref_line(:,2); 
            
            data1dstack_temp = zeros(length(Q1d_new), N+1, 'single'); 
            data1dstack_temp(:,1) = single(Q1d_new);
            
            if GUI.hParCom.Value == 1
                d.Indeterminate = 'on'; d.Message = sprintf('Line cut (parallel): %d frames...', N);
                parfor ii = 1:N
                    [~, line1d] = Anglecut1d(p_worker, Stack_local(:,:,ii)); 
                    data1dstack_temp(:,ii+1) = alignPGIXSLinecutToReference(line1d, ref_distance);
                end
            else
                d.Indeterminate = 'off'; 
                for ii = 1:N
                    if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                        d.Value = ii/N;
                        drawnow limitrate;
                    end
                    [~, line1d] = Anglecut1d(p_worker, Stack_local(:,:,ii)); 
                    data1dstack_temp(:,ii+1) = alignPGIXSLinecutToReference(line1d, ref_distance);
                end
            end
            param.data1dstack = data1dstack_temp;
            param.linecutDistanceAxis = single(ref_distance);
            
            if isfield(param,'bkg') && ~isempty(param.bkg)
                [~, line1d] = Anglecut1d(p_worker, param.bkg); 
                param.bkg1d = alignPGIXSLinecutToReference(line1d, ref_distance); 
            end
            
            Auto.Met = AUTO_LINECUT; 

            % ==========================================
            % [크래시 방지 철벽 방어선]
            if exist('Q_queue', 'var'), clear Q_queue; end
            if exist('Q', 'var') && isa(Q, 'parallel.pool.DataQueue'), clear Q; end
            
            if exist('d', 'var') && isvalid(d)
                d.Message = 'Finishing up...';
                drawnow limitrate;
                close(d);
                pause(0.5); 
            end

            Plot1dseries_Callback([], []); 

        catch ME
            if exist('d', 'var') && isvalid(d)
                close(d); 
                pause(0.5);
            end
            uialert(GUI.main, ['Line Cut Error: ' ME.message], 'Error');
        end
    end

    function update1Dplot_Callback(~,~), update1Dplot; end
    function updateIntplot_Callback(~,~), updateIntplot; end

    function update1Dplot
        if ~isfield(param, 'data1dstackN')
            return;
        end

        PScale = GUI.hPScale.Value;
        qmin = TX2.qMin.Value;
        qmax = TX2.qMax.Value;

        Q = param.data1dstack(:, 1);
        valid = Q >= qmin & Q <= qmax;
        Qp = Q(valid);
        Yp = param.data1dstackN(valid, :);

        [X, lbl, ~] = getExperimentXAxis(param);

        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if size(Yp, 2) == numel(X)
            [X, idx] = sortPGIXSXAxis(X, emode, GUI.hOrderT.Value, false);
            Yp = Yp(:, idx);
        end

        % [치명적 버그 수정] 강제 delete 대신 객체 속성을 off로 안전하게 해제
%         colorbar(hAX3, 'off');
        cla(hAX3);
        hold(hAX3, 'on');

        N = size(Yp, 2);
        col = jet(max(N, 1));
        MAX_CURVES = 120;
        MAX_PTS    = 800;
        if N > MAX_CURVES, sel = unique(round(linspace(1, N, MAX_CURVES))); else, sel = 1:N; end
        nq = numel(Qp);
        if nq > MAX_PTS, rsel = unique(round(linspace(1, nq, MAX_PTS))); else, rsel = 1:nq; end
        set(hAX3, 'ColorOrder', col(sel, :), 'NextPlot', 'replacechildren');
        plot(hAX3, Qp(rsel), Yp(rsel, sel), 'LineWidth', 1);

        hold(hAX3, 'off');
        axis(hAX3, 'tight');

        % [UI Unchaining] 한 줄에 단일 명령 수행
        xlabel(hAX3, '$q, \textrm{\AA}^{-1}$', 'Interpreter', 'latex', 'FontSize', 12);
        ylabel(hAX3, 'Intensity', 'FontSize', 12);

        try
            switch PScale
                case 'Linear'
                    set(hAX3, 'YScale', 'linear');
                    set(hAX3, 'XScale', 'linear');
                case 'Logy'
                    set(hAX3, 'YScale', 'log');
                    set(hAX3, 'XScale', 'linear');
                case 'Logxy'
                    set(hAX3, 'YScale', 'log');
                    set(hAX3, 'XScale', 'log');
            end
        catch ME
            warning('TrXS2:AxisScaleFallback', '1D axis scale fallback used: %s', ME.message);
            set(hAX3, 'YScale', 'linear');
            set(hAX3, 'XScale', 'linear');
        end

        colormap(hAX3, col);

        c = colorbar(hAX3);
        c.Label.String = lbl;

        if length(X) > 1
            c.Ticks = [0, 1];
            c.TickLabels = {num2str(X(1), '%.1f'), num2str(X(end), '%.1f')};
        end

        title(hAX3, param.FileName, 'Interpreter', 'none', 'FontSize', 10);
    end

    function updateIntplot
        if ~isfield(param, 'data1dstackN')
            return;
        end

        qmin = TX2.qMin.Value;
        qmax = TX2.qMax.Value;

        Q = param.data1dstack(:, 1);
        valid = Q >= qmin & Q <= qmax;

        param.SumIROIN = sumPGIXSOmitNaN(param.data1dstackN(valid, :), 1);

        [X, lbl, unt] = getExperimentXAxis(param);
        Y = param.SumIROIN;

        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X) == numel(Y)
            [X, idx] = sortPGIXSXAxis(X, emode, GUI.hOrderT.Value, false);
            Y = Y(idx);
        end

        cla(hAX4);
        plot(hAX4, X, Y, '-ok', 'MarkerFaceColor', 'k');
        axis(hAX4, 'tight');

        % [UI Unchaining]
        xlabel(hAX4, [lbl ' (' unt ')']);
        ylabel(hAX4, 'Integrated I');
    end

    function NormalFactor_Callback(~,~)
        if ~isfield(param, 'data1dstackN') || isempty(param.data1dstackN), uialert(GUI.main, 'No data to normalize!', 'Warning'); return; end
        if isfield(param, 'hNormPoint') && ~isempty(param.hNormPoint) && isvalid(param.hNormPoint), delete(param.hNormPoint); end
        param.hNormPoint = drawpoint(hAX3, 'Color', 'm', 'Label', 'Norm. Target');
        addlistener(param.hNormPoint, 'MovingROI', @(src, evt) applyNormalization(src.Position(1))); addlistener(param.hNormPoint, 'ROIMoved', @(src, evt) applyNormalization(src.Position(1)));
        applyNormalization(param.hNormPoint.Position(1));
    end

    function applyNormalization(x)
        Q = param.data1dstack(:, 1); [~, qidx] = min(abs(Q - x), [], 'omitnan'); Subton = GUI.hSubract_S.Value; norm_factors = sanitizePGIXSScaleFactors(param.data1dstackN(qidx, :));
        if isfield(param, 'bkg1d') && ~isempty(param.bkg1d)
            bkg_val_at_point = sanitizePGIXSScaleFactors(param.bkg1d(qidx)); param.bkg1dN = param.bkg1d ./ bkg_val_at_point; param.data1dstackN = param.data1dstackN ./ norm_factors;
            if Subton == 1, param.data1dstackN = param.data1dstackN - param.bkg1dN; end
            if isfield(param, 'std1dstackN'), param.std1dstackN = param.std1dstackN ./ norm_factors; end
        else
            param.data1dstackN = param.data1dstackN ./ norm_factors; if isfield(param, 'std1dstackN'), param.std1dstackN = param.std1dstackN ./ norm_factors; end
        end
        update1Dplot; updateIntplot;
    end

    function updateQHeatmap_Callback(~,~), try HeatmapQ_gui(param); catch ME, uialert(GUI.main, ME.message, 'Error Running Heatmap'); end; end

    function Saveget3_Callback(~,~)
        if ~isfield(param, 'data1dstackN') || isempty(param.data1dstackN), uialert(GUI.main, 'No data to save!', 'Warning'); return; end
        SaveForm = GUI.hSForm3.Value; qmin = TX2.qMin.Value; qmax = TX2.qMax.Value; 
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end

        Q_all = param.data1dstack(:, 1); valid_idx = (Q_all >= qmin) & (Q_all <= qmax); Q_save = Q_all(valid_idx); I_save = param.data1dstackN(valid_idx, :);
        hasSTD = isfield(param, 'std1dstackN') && ~isempty(param.std1dstackN); if hasSTD, STD_save = param.std1dstackN(valid_idx, :); end
        [X_var, X_label, ~] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var) == size(I_save, 2)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, false);
            I_save = reorderPGIXSColumns(I_save, sort_idx); if hasSTD, STD_save = reorderPGIXSColumns(STD_save, sort_idx); end
        else
            X_var = 1:size(I_save, 2); X_label = 'Frame';
        end
        CombinedData = sanitizePGIXSExportMatrix([double(Q_save), double(I_save)]); if hasSTD, CombinedDataSTD = sanitizePGIXSExportMatrix([double(Q_save), double(STD_save)]); end
        FN = NewFileName(param.FileName); BaseName = [FN, '_1Dplotstack']; SavePath = fullfile(saveDir, [BaseName, SaveForm]);
        try
            saved_struct.Q = Q_save; saved_struct.Intensity = I_save; saved_struct.Matrix = CombinedData; saved_struct.X_Axis = X_var; saved_struct.X_Label = X_label;
            if hasSTD, saved_struct.STD = STD_save; saved_struct.MatrixSTD = CombinedDataSTD; end
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, CombinedData, saved_struct);
            if hasSTD && ~strcmpi(SaveForm, '.mat')
                savePGIXSDataFile(fullfile(saveDir, [BaseName, '_STD', SaveForm]), SaveForm, CombinedDataSTD, struct('STD', STD_save, 'MatrixSTD', CombinedDataSTD));
            end
            exportPGIXSAxesImage(hAX3, fullfile(saveDir, [BaseName, '.jpg']), 300);
            uialert(GUI.main, ['Saved successfully: ' SavePath], 'Success');
        catch ME
            uialert(GUI.main, ['Save failed: ' ME.message], 'Error');
        end
    end

    function PointFind2_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if isfield(param, 'hAziPoint') && ~isempty(param.hAziPoint) && isvalid(param.hAziPoint), delete(param.hAziPoint); end
        param.hAziPoint = drawpoint(hAX1, 'Color', 'm', 'Label', 'Target');
        addlistener(param.hAziPoint, 'MovingROI', @(src, evt) updateAziPoint(src.Position)); addlistener(param.hAziPoint, 'ROIMoved', @(src, evt) updateAziPoint(src.Position));
        updateAziPoint(param.hAziPoint.Position);
    end

    function updateAziPoint(pos), x = pos(1); y = pos(2); TX2.azipospix.Value = double(round(sqrt(x^2 + y^2))); end

    function DrawAziPlot2_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'Correct first!','Warning'); return; end
        pix_pos = TX2.azipospix.Value; pix_m = TX2.azipospixm.Value; pix_p = TX2.azipospixp.Value; radii = (pix_pos + pix_m) : (pix_pos + pix_p); theta = (0:0.5:360)' + 180;
        selection = uiconfirm(GUI.main, 'Do you need a mask?', 'Mask', 'Options', {'Yes','No'}, 'DefaultOption', 'Yes');
        if strcmp(selection, 'Yes'), param.BW = get_modern_mask(param.data, param.cmin, param.cmax, param.colorscale, param.colorm, '방위각 분석을 위한 마스크 영역 지정'); PlotAzi = param.data .* param.BW; else, param.BW = ones(param.dataSize(1), param.dataSize(2), 'single'); PlotAzi = param.data; end
        [ThetaGrid, RGrid] = meshgrid(theta, radii); X = round(RGrid .* cosd(ThetaGrid) + param.bpos(1)); Y = round(RGrid .* sind(ThetaGrid) + param.bpos(2));
        valid = X>=1 & X<=param.dataSize(2) & Y>=1 & Y<=param.dataSize(1); idx = sub2ind(size(PlotAzi), Y(valid), X(valid));
        DisplayImg = PlotAzi; DisplayImg(idx) = max(param.data(:)) * 1.5; 
        updateImage2; hold(hAX1,'on'); imagesc(hAX1, param.HD, param.VD, DisplayImg); if param.Expinfo==0, set(hAX1,'YDir','reverse'); else, set(hAX1,'YDir','normal'); end; xlim(hAX1, [TX2.cXlim1.Value, TX2.cXlim2.Value]); ylim(hAX1, [TX2.cYlim1.Value, TX2.cYlim2.Value]); hold(hAX1,'off');
        IndMap = nan(size(ThetaGrid), 'single'); IndMap(valid) = idx;
        SumTemp = processPGIXSAzimuthal1D(param.data, IndMap, param.BW, strcmp(GUI.hMeanMedAzi.Value, 'Median'));
        param.Azi = [single(theta(:)), single(SumTemp(:))];
        drawnow;
    end

    function Azilinecut2_Callback(~,~)
        ParallelCom = GUI.hParCom.Value; if ~isfield(param, 'Azi'), uialert(GUI.main, 'Please draw line first!!','Warning'); return; end
        if ~isfield(param, 'BW') || isempty(param.BW)
            selection = uiconfirm(GUI.main, 'Do you need a mask?', 'Mask', 'Options', {'Yes','No'}, 'DefaultOption', 'Yes');
            if strcmp(selection, 'Yes'), param.BW = get_modern_mask(param.data, param.cmin, param.cmax, param.colorscale, param.colorm, '방위각 분석용 마스크 영역 지정'); else, param.BW = ones(param.dataSize(1), param.dataSize(2), 'single'); end
        end
        BW = param.BW; isMedian = strcmp(GUI.hMeanMedAzi.Value, 'Median'); pix_pos = TX2.azipospix.Value; pix_m = TX2.azipospixm.Value; pix_p = TX2.azipospixp.Value; radii = (pix_pos + pix_m) : (pix_pos + pix_p); theta = (0:0.5:360)' + 180;
        [ThetaGrid, RGrid] = meshgrid(theta, radii); X = round(RGrid .* cosd(ThetaGrid) + param.bpos(1)); Y = round(RGrid .* sind(ThetaGrid) + param.bpos(2));
        valid = X>=1 & X<=param.dataSize(2) & Y>=1 & Y<=param.dataSize(1); IndMap = nan(size(ThetaGrid), 'single'); IndMap(valid) = sub2ind(param.dataSize, Y(valid), X(valid));
        N = size(param.Stack,3); Stack_local = param.Stack; dataAzi = zeros(length(theta), N+1, 'single'); dataAzi(:,1) = single(theta-180);
        d = uiprogressdlg(GUI.main, 'Title', 'Calculating', 'Message', 'Azi Cut...', 'Indeterminate', 'on');
        try
        
        if ParallelCom == 1
            d.Indeterminate = 'on'; d.Message = sprintf('Azimuthal cut (parallel): %d frames...', N);
            parfor ii = 1:N
                dataAzi(:,ii+1) = processPGIXSAzimuthal1D(Stack_local(:,:,ii), IndMap, BW, isMedian);
            end
        else
            d.Indeterminate = 'off';
            for ii = 1:N
                if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                    d.Value = ii/N;
                    drawnow limitrate;
                end
                dataAzi(:,ii+1) = processPGIXSAzimuthal1D(Stack_local(:,:,ii), IndMap, BW, isMedian);
            end
        end
        close(d); 
        
        param.dataAzistack = dataAzi;
            
            if isfield(param,'bkg')
                param.bkgAzi = processPGIXSAzimuthal1D(param.bkg, IndMap, BW, isMedian);
            end
            
            Auto.Met = AUTO_AZIMUTHAL; 

            % ==========================================
            % [크래시 방지 철벽 방어선]
            if exist('Q_queue', 'var'), clear Q_queue; end
            if exist('Q', 'var') && isa(Q, 'parallel.pool.DataQueue'), clear Q; end
            
            if exist('d', 'var') && isvalid(d)
                d.Message = 'Finishing up...';
                drawnow limitrate;
                close(d);
                pause(0.5); 
            end

            PlotAziseries2_Callback([], []); 

        catch ME
            if exist('d','var') && isvalid(d)
                close(d); 
                pause(0.5);
            end
            uialert(GUI.main, ['Azimuthal Cut Error: ' ME.message], 'Error');
        end
    end

    function PlotAziseries2_Callback(~,~)
        if ~isfield(param, 'dataAzistack') || isempty(param.dataAzistack), return; end
        Normalway = GUI.hNormal4.Value; Subton = GUI.hSubract_S.Value; param.dataAzistackN = param.dataAzistack(:, 2:end); [~, N] = size(param.dataAzistackN);
        for ii = 1:N
            norm_val = getPGIXSNormalizationValue(param.loginfo, Normalway, ii);
            param.dataAzistackN(:,ii) = param.dataAzistackN(:,ii) ./ norm_val;
            
            if Subton == 1 && isfield(param, 'bkgAzi') && ~isempty(param.bkgAzi)
                bkg_norm_val = getPGIXSNormalizationValue(param.Countbkg, Normalway, 1);
                param.dataAzistackN(:,ii) = param.dataAzistackN(:,ii) - (param.bkgAzi ./ bkg_norm_val);
            end
        end
        Ang = param.dataAzistack(:,1); TX2.aziMin.Value = double(min(Ang,[],'omitnan')); TX2.aziMax.Value = double(max(Ang,[],'omitnan')); updateAziplot_Callback;
    end

    function updateAziplot_Callback(~,~)
        if ~isfield(param, 'dataAzistackN'), return; end
        AScale = GUI.hAScale.Value; amin = TX2.aziMin.Value; amax = TX2.aziMax.Value;
        A = param.dataAzistack(:,1); valid = A >= amin & A <= amax; Ap = A(valid); Yp = param.dataAzistackN(valid, :);
        [X, lbl, ~] = getExperimentXAxis(param); emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if size(Yp, 2) == numel(X), [X, idx] = sortPGIXSXAxis(X, emode, GUI.hOrderT.Value, false); Yp = Yp(:, idx); end
        cla(hAX2); N = size(Yp, 2); colors = jet(max(N,1));
        MAX_CURVES = 120; MAX_PTS = 800;                           % uifigure 렌더러 보호
        if N > MAX_CURVES, sel = unique(round(linspace(1, N, MAX_CURVES))); else, sel = 1:N; end
        np = numel(Ap); if np > MAX_PTS, rsel = unique(round(linspace(1, np, MAX_PTS))); else, rsel = 1:np; end
        set(hAX2, 'ColorOrder', colors(sel,:), 'NextPlot', 'replacechildren'); plot(hAX2, Ap(rsel), Yp(rsel,sel), 'LineWidth', 1); axis(hAX2, 'tight');
        xlabel(hAX2, 'Angle (deg)', 'FontSize', 12); ylabel(hAX2, 'Intensity (a.u.)');
        try
            switch AScale
                case 'Linear'
                    set(hAX2, 'YScale', 'linear');
                case 'Logy'
                    set(hAX2, 'YScale', 'log');
            end
        catch ME
            warning('TrXS2:AxisScaleFallback', 'Azimuthal axis scale fallback used: %s', ME.message);
            set(hAX2, 'YScale', 'linear');
        end
        colormap(hAX2, colors); c = colorbar(hAX2); c.Label.String = lbl;
        if length(X) > 1, c.Ticks = [0, 1]; c.TickLabels = {num2str(X(1),'%.1f'), num2str(X(end),'%.1f')}; end; title(hAX2, 'Azimuthal Integration', 'FontSize', 11); updateAziIntplot;
    end

    function updateAziIntplot
        if ~isfield(param, 'dataAzistackN') || isempty(param.dataAzistackN), return; end
        amin = TX2.aziMin.Value; amax = TX2.aziMax.Value; A = param.dataAzistack(:,1); valid = A >= amin & A <= amax;
        param.SumIROIN = sumPGIXSOmitNaN(param.dataAzistackN(valid, :), 1);
        [X, lbl, unt] = getExperimentXAxis(param); Y = param.SumIROIN; emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X) == numel(Y), [X, idx] = sortPGIXSXAxis(X, emode, GUI.hOrderT.Value, false); Y = Y(idx); end
        cla(hAX4); plot(hAX4, X, Y, '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1.5, 'MarkerSize', 4); axis(hAX4, 'tight'); grid(hAX4, 'on');
        xlabel(hAX4, [lbl ' (' unt ')'], 'FontSize', 11); ylabel(hAX4, 'Integrated Intensity (a.u.)'); title(hAX4, ['Integration: ' num2str(amin) ' ~ ' num2str(amax) ' deg'], 'FontSize', 10);
    end

    function NormalFactorAzi_Callback(~,~)
        if ~isfield(param, 'dataAzistackN') || isempty(param.dataAzistackN), uialert(GUI.main, 'No data to normalize!', 'Warning'); return; end
        if isfield(param, 'hNormPointAzi') && ~isempty(param.hNormPointAzi) && isvalid(param.hNormPointAzi), delete(param.hNormPointAzi); end
        param.hNormPointAzi = drawpoint(hAX2, 'Color', 'm', 'Label', 'Norm. Target');
        addlistener(param.hNormPointAzi, 'MovingROI', @(src, evt) applyAziNormalization(src.Position(1))); addlistener(param.hNormPointAzi, 'ROIMoved', @(src, evt) applyAziNormalization(src.Position(1)));
        applyAziNormalization(param.hNormPointAzi.Position(1));
    end

    function applyAziNormalization(x)
        Ang = param.dataAzistack(:, 1); [~, aidx] = min(abs(Ang - x), [], 'omitnan'); Subton = GUI.hSubract_S.Value; norm_factors = sanitizePGIXSScaleFactors(param.dataAzistackN(aidx, :));
        if isfield(param, 'bkgAzi') && ~isempty(param.bkgAzi)
            bkg_val_at_point = sanitizePGIXSScaleFactors(param.bkgAzi(aidx));
            param.bkgAziN = param.bkgAzi ./ bkg_val_at_point;
            param.dataAzistackN = param.dataAzistackN ./ norm_factors;
            if Subton == 1, param.dataAzistackN = param.dataAzistackN - param.bkgAziN; end
        else
            param.dataAzistackN = param.dataAzistackN ./ norm_factors;
        end
        updateAziplot_Callback;
    end

    function updateAziHeatmap_Callback(~,~), try HeatmapAzi_gui(param); catch ME, uialert(GUI.main, ['Error opening Heatmap: ' ME.message], 'Error'); end; end
    
    function Saveget2_Callback(~,~)
        if ~isfield(param, 'dataAzistackN') || isempty(param.dataAzistackN), uialert(GUI.main, 'No Azimuthal data to save!', 'Warning'); return; end
        SaveForm = GUI.hSForm2.Value; amin = TX2.aziMin.Value; amax = TX2.aziMax.Value; 
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end

        Ang_all = param.dataAzistack(:, 1); valid_idx = (Ang_all >= amin) & (Ang_all <= amax); Ang_save = Ang_all(valid_idx); I_save = param.dataAzistackN(valid_idx, :);
        [X_var, X_label, ~] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var) == size(I_save, 2)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, false);
            I_save = reorderPGIXSColumns(I_save, sort_idx);
        else
            X_var = 1:size(I_save, 2); X_label = 'Frame';
        end
        CombinedData = sanitizePGIXSExportMatrix([double(Ang_save), double(I_save)]); 
        FN = NewFileName(param.FileName); BaseName = [FN, '_AziStack']; SavePath = fullfile(saveDir, [BaseName, SaveForm]);
        try
            saved_struct.Angle = Ang_save; saved_struct.Intensity = I_save; saved_struct.Matrix = CombinedData; saved_struct.X_Axis = X_var; saved_struct.X_Label = X_label;
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, CombinedData, saved_struct);
            exportPGIXSAxesImage(hAX2, fullfile(saveDir, [BaseName, '.jpg']), 300);
            uialert(GUI.main, ['Saved successfully: ' SavePath], 'Success');
        catch ME
            uialert(GUI.main, ['Save failed: ' ME.message], 'Error');
        end
    end

    function ROIdef2_Callback(~,~)
        NofROI = round(parsePGIXSNumeric(GUI.hNROI.Value, 1, 1, 20)); param.ROI = zeros(NofROI, 4);
        f1 = uifigure('Name', 'ROI Selection', 'Position', [200 200 800 600]); ax1 = uiaxes(f1, 'Position', [50 50 700 500]);
        imagesc(ax1, param.data); axis(ax1, 'image'); clim(ax1, [param.cmin, param.cmax]);
        applyPGIXSAxesColorScale(ax1, param.colorscale);
        applyPGIXSColormap(ax1, param.colorm, param.data);
        
        for ii = 1:NofROI
            msgText = sprintf('Draw ROI %d: 영역을 그린 후 [더블클릭] 또는 [Enter] 키를 누르세요.', ii);
            title(ax1, msgText, 'FontSize', 13, 'Color', 'r', 'FontWeight', 'bold');
            hR = drawrectangle(ax1, 'Color', 'r'); try wait(hR); catch, end 
            pos = hR.Position; param.ROI(ii,:) = round([pos(2), pos(2)+pos(4), pos(1), pos(1)+pos(3)]);
        end
        close(f1);
        
        [SumI, roiBounds, valid_roi] = processPGIXSROIStack(param.Stack, param.ROI, GUI.hParCom.Value == 1);
        param.SumIROI = SumI;
        
        updateImage2; hold(hAX1,'on'); colors = {'r','g','b','c','m'};
        for ii=1:NofROI
            if valid_roi(ii)
                y = param.VD(roiBounds(ii, [1, 2])); x = param.HD(roiBounds(ii, [3, 4]));
                rectangle(hAX1, 'Position', [x(1), y(2), x(2)-x(1), y(1)-y(2)], 'EdgeColor', colors{mod(ii-1,5)+1}, 'LineWidth', 2);
            end
        end
        hold(hAX1,'off'); PlotROI_Callback;
    end

    function PlotROI_Callback(~,~)
        if ~isfield(param,'SumIROI'), return; end
        Normalway = GUI.hNormal5.Value; Y = param.SumIROI;
        for ii = 1:size(Y,1)
            nv = getPGIXSNormalizationValue(param.loginfo, Normalway, ii);
            Y(ii,:) = Y(ii,:) ./ nv;
        end
        param.SumIROIN = Y;
        
        [X, lbl, unt] = getExperimentXAxis(param); emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if size(Y, 1) == numel(X), [X, idx] = sortPGIXSXAxis(X, emode, GUI.hOrderT.Value, false); Y = Y(idx,:); end
        cla(hAX4); hold(hAX4, 'on'); colors = {'r','g','b','c','m'};
        for i=1:size(Y,2), col = colors{mod(i-1,5)+1}; plot(hAX4, X, Y(:,i), ['-o' col], 'MarkerFaceColor', col, 'MarkerEdgeColor','k'); end
        hold(hAX4, 'off'); axis(hAX4, 'tight'); xlabel(hAX4, [lbl ' (' unt ')']); ylabel(hAX4, 'Integrated I');
    end

    function NormalROII_Callback(~,~)
        if ~isfield(param, 'SumIROIN') || isempty(param.SumIROIN), return; end
        first_vals = sanitizePGIXSScaleFactors(param.SumIROIN(1, :)); param.SumIROIN = param.SumIROIN ./ first_vals;
        [X, lbl, unt] = getExperimentXAxis(param); Y = param.SumIROIN; emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if size(Y, 1) == numel(X), [X, idx] = sortPGIXSXAxis(X, emode, GUI.hOrderT.Value, false); Y = Y(idx, :); end
        cla(hAX4); hold(hAX4, 'on'); colors = {'r','g','b','c','m'}; markers = {'o', 's', 'd', '^', 'v'};
        for i = 1:size(Y, 2)
            col = colors{mod(i-1, length(colors)) + 1}; mrk = markers{mod(i-1, length(markers)) + 1}; plot(hAX4, X, Y(:, i), ['-' mrk], 'Color', col, 'MarkerFaceColor', col, 'MarkerEdgeColor', 'k', 'LineWidth', 1.5, 'MarkerSize', 6);
        end
        hold(hAX4, 'off'); axis(hAX4, 'tight'); grid(hAX4, 'on'); xlabel(hAX4, [lbl ' (' unt ')'], 'FontSize', 11); ylabel(hAX4, 'Normalized Intensity (I / I_{0})'); title(hAX4, 'ROI Normalized by First Frame');
    end

    function Saveget4_Callback(~,~)
        if isfield(param, 'SumIROIN') && ~isempty(param.SumIROIN), Y_Data = param.SumIROIN; elseif isfield(param, 'SumIROI') && ~isempty(param.SumIROI), Y_Data = param.SumIROI; else, uialert(GUI.main, 'No Integration data to save!', 'Warning'); return; end
        SaveForm = GUI.hSForm4.Value; 
        
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        [X_var, X_label, X_unit] = getExperimentXAxis(param); X_var = X_var(:); emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if size(Y_Data, 2) == numel(X_var) && size(Y_Data, 1) ~= numel(X_var), Y_Data = Y_Data'; end
        if numel(X_var) == size(Y_Data, 1)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, false); X_var = X_var(:);
            Y_Data = reorderPGIXSRows(Y_Data, sort_idx);
        else
            X_var = (1:size(Y_Data, 1))'; X_label = 'Frame'; X_unit = '#';
        end
        CombinedData = sanitizePGIXSExportMatrix([double(X_var), double(Y_Data)]); FN = NewFileName(param.FileName); BaseName = [FN, '_Integration']; SavePath = fullfile(saveDir, [BaseName, SaveForm]);
        try
            saved_struct.X_Axis = X_var; saved_struct.X_Label = X_label; saved_struct.X_Unit = X_unit; saved_struct.Integrated_I = Y_Data; saved_struct.Matrix = CombinedData;
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, CombinedData, saved_struct);
            exportPGIXSAxesImage(hAX4, fullfile(saveDir, [BaseName, '.jpg']), 300);
            uialert(GUI.main, ['Saved successfully: ' SavePath], 'Success');
        catch ME
            uialert(GUI.main, ['Save failed: ' ME.message], 'Error');
        end
    end

    function SavegetX_Callback(~,~)
        [X_var, X_label, X_unit] = getExperimentXAxis(param); if isempty(X_var), uialert(GUI.main, 'No X-axis data available.', 'Warning'); return; end
        SaveForm = GUI.hSForm4.Value;
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        X_var = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, false);
        X_var = double(X_var(:)); SafeLabel = regexprep(X_label, '[^a-zA-Z0-9]', ''); if isempty(SafeLabel), SafeLabel = 'XAxis'; end
        FN = NewFileName(param.FileName); BaseName = [FN, '_', SafeLabel]; SavePath = fullfile(saveDir, [BaseName, SaveForm]);
        try
            saved_struct.X_Data = X_var; saved_struct.Label = X_label; saved_struct.Unit = X_unit;
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, X_var, saved_struct);
            uialert(GUI.main, [X_label ' data saved to: ' SavePath], 'Success');
        catch ME
            uialert(GUI.main, ['Save failed: ' ME.message], 'Error');
        end
    end

    function Tmode_Callback(~,~)
        param.Tmode = GUI.hTmode.Value;
        if isfield(param, 'data1dstackN') && ~isempty(param.data1dstackN), update1Dplot; updateIntplot; end
        if isfield(param, 'dataAzistackN') && ~isempty(param.dataAzistackN), updateAziplot_Callback; end
        if (isfield(param, 'SumIROIN') && ~isempty(param.SumIROIN)) || (isfield(param, 'SumIROI') && ~isempty(param.SumIROI)), PlotROI_Callback; end
    end

    function saved_struct = attachRetryMetadata(saved_struct)
        saved_struct = attachPGIXSFrameFailureMetadata(saved_struct, param);
    end

    function Autoplot_Callback(~,~)
        [~, files, Ntotal] = listPGIXSSeriesFiles(param.Path, param.FileName, '.h5');
        if Ntotal <= Auto.Nold, return; end
        Nnew = Ntotal - Auto.Nold; new_indices = (Auto.Nold + 1) : Ntotal; DoCorrection = param.correctionI; 
        
        InvFactor = 1;
        if DoCorrection
            if isfield(param, 'InvFactor') && ~isempty(param.InvFactor)
                InvFactor = param.InvFactor;   % q-Cal에서 1회 계산한 보정인자 재사용 (매번 재계산 안 함)
            else
                % (안전장치) 캐시가 없을 때만 1회 계산 후 저장
                k0 = 2*pi/param.Wavelength;
                TotalCorr = computePGIXSDetectorCorrectionFactor(param, k0);
                InvFactor = 1 ./ TotalCorr; param.InvFactor = single(InvFactor);
            end
        end
        
        Stack_new = zeros(param.dataSize(1), param.dataSize(2), Nnew, 'single'); loginfo_new = zeros(2, Nnew, 'single'); ts_new = zeros(Nnew, 1); temp_new = zeros(Nnew, 2, 'single'); Mask = param.Mask;
        param.TimeUnit = GUI.hTimeP.Value; param.TimeOffset = TX2.hExptime.Value; expmode_local = param.expmode;
        RefIC_local = nan; if isfield(param, 'RefIC'), RefIC_local = param.RefIC; end
        RefBC_local = nan; if isfield(param, 'RefBC'), RefBC_local = param.RefBC; end
        d = uiprogressdlg(GUI.main, 'Title', 'Auto Refresh', 'Message', 'Processing new files...', 'Cancelable', 'on', 'Indeterminate', 'off');
        loadedCount = 0;
        attemptedCount = 0;
        failedLoadCount = 0;
        failedMetadataCount = 0;
        
        for ii = 1:Nnew
            if d.CancelRequested, break; end
            attemptedCount = ii;
            fileIdx = new_indices(ii); fname = files{fileIdx}; d.Value = ii/Nnew;
            [D, okFrame, loadReport] = loadPGIXSH5FrameWithRetry(fname, Mask, NaN, param.dataSize);
            if ~okFrame
                warning('TrXS2:AutoDataLoadFailed', 'Auto refresh data load failed for %s after %d attempts: %s', fname, loadReport.Attempts, loadReport.Message);
                failedLoadCount = failedLoadCount + 1;
                param = appendPGIXSFrameFailureIndex(param, 'RetryFailedFrames', fileIdx);
            end
            if DoCorrection
                D = D .* InvFactor;
            end

            writeIdx = loadedCount + 1;
            Stack_new(:,:,writeIdx) = D;
            try
                [c1, cBC, ts_val, t_vec] = read_metadata_worker(fname, expmode_local);
            catch ME
                warning('TrXS2:AutoMetadataReadFailed', 'Auto refresh metadata read failed for %s: %s', fname, ME.message);
                failedMetadataCount = failedMetadataCount + 1;
                param = appendPGIXSFrameFailureIndex(param, 'MetadataFailedFrames', fileIdx);
                c1 = nan; cBC = nan; ts_val = nan; t_vec = [nan nan];
            end
            normCounts = normalizePGIXSCounters([c1 cBC], [RefIC_local RefBC_local]);
            v1 = normCounts(1); v2 = normCounts(2);
            loginfo_new(:, writeIdx) = [v1; v2];
            ts_new(writeIdx) = ts_val; temp_new(writeIdx, :) = t_vec;
            loadedCount = writeIdx;
        end
        close(d);
        if loadedCount == 0
            return;
        end
        if loadedCount < Nnew
            [Stack_new, loginfo_new, ts_new, temp_new] = trimPGIXSSeriesData( ...
                Stack_new, loginfo_new, ts_new, temp_new, loadedCount);
            Nnew = loadedCount;
        end
        
        param.Stack = cat(3, param.Stack, Stack_new); param.loginfo = cat(2, param.loginfo, loginfo_new); param.timestampinfo = cat(1, param.timestampinfo, ts_new); param.temperatureinfo = cat(1, param.temperatureinfo, temp_new);
        param.data = mean(param.Stack, 3, 'omitnan'); updateImage2;
        
        try
            switch Auto.Met
                case AUTO_CIRCULAR, updateCircularAve(Stack_new, Nnew, param);
                case AUTO_LINECUT,  updateLineCut(Stack_new, Nnew, param);
                case AUTO_AZIMUTHAL, updateAziCut(Stack_new, Nnew, param);
                case 3, updateROI(Stack_new, Nnew, param);  % ROI는 별도 상수 필요 시 추가
            end
        catch ME
            uialert(GUI.main, sprintf('Result update failed: %s', ME.message), 'Error', 'Icon', 'error');
        end
        Auto.Nold = Auto.Nold + attemptedCount; TX2.NFile.Text = num2str(Auto.Nold);
        if failedLoadCount > 0
            [message, titleText] = formatPGIXSFrameFailureWarning( ...
                failedLoadCount, param.RetryFailedFrames, 'load', 'refresh');
            uialert(GUI.main, message, titleText, 'Icon', 'warning');
        end
        if failedMetadataCount > 0
            [message, titleText] = formatPGIXSFrameFailureWarning( ...
                failedMetadataCount, param.MetadataFailedFrames, 'metadata', 'refresh');
            uialert(GUI.main, message, titleText, 'Icon', 'warning');
        end
    end

    function updateCircularAve(Stack_new, Nnew, p)
        % Auto-refresh: 새로 들어온 frame들만 radius-bin 처리
        % 사전 계산된 radius bin map 재사용 (속도 핵심)
        if ~isfield(p, 'data1dstack') || ~isfield(p, 'qbin'), return; end

        Medfunct = GUI.hMedianB.Value;
        stdfunct = GUI.hStdI2.Value;
        useMedian = (Medfunct == 1);
        BW = p.BW;

        radiusPrep = p.qbin;
        len = radiusPrep.n_bins;

        new_res = zeros(len, Nnew, 'single');
        if stdfunct, new_std = zeros(len, Nnew, 'single'); end

        for ii = 1:Nnew
            D = Stack_new(:,:,ii) .* BW;
            if stdfunct
                [zr, zr_std] = processPGIXSRadiusBin1D(D, radiusPrep, useMedian, true);
                new_res(:, ii) = zr;
                new_std(:, ii) = zr_std;
            else
                zr = processPGIXSRadiusBin1D(D, radiusPrep, useMedian, false);
                new_res(:, ii) = zr;
            end
        end

        param.data1dstack = cat(2, param.data1dstack, new_res);
        if stdfunct, param.std1dstack = cat(2, param.std1dstack, new_std); end
        Plot1dseries_Callback;
    end

    function updateLineCut(Stack_new, Nnew, p)
        if ~isfield(p, 'data1dstack'), return; end
        len = length(p.data1dstack(:,1)); new_res = zeros(len, Nnew, 'single'); 
        if isfield(p, 'linecutDistanceAxis') && numel(p.linecutDistanceAxis) == len
            ref_distance = p.linecutDistanceAxis(:);
        else
            ref_distance = p.data1dstack(:, 1);
        end
        p_worker = p; if isfield(p_worker, 'Stack'), p_worker = rmfield(p_worker, 'Stack'); end
        for ii = 1:Nnew
            [~, line1d] = Anglecut1d(p_worker, Stack_new(:,:,ii)); 
            new_res(:, ii) = alignPGIXSLinecutToReference(line1d, ref_distance);
        end
        param.data1dstack = cat(2, param.data1dstack, new_res); Plot1dseries_Callback;
    end

    function updateAziCut(Stack_new, Nnew, p)
        if ~isfield(p, 'dataAzistack'), return; end
        isMedian = strcmp(GUI.hMeanMedAzi.Value, 'Median'); pix_pos = TX2.azipospix.Value; pix_m = TX2.azipospixm.Value; pix_p = TX2.azipospixp.Value; radii = (pix_pos + pix_m) : (pix_pos + pix_p); theta = (0:0.5:360)' + 180;
        [ThetaGrid, RGrid] = meshgrid(theta, radii); X = round(RGrid .* cosd(ThetaGrid) + p.bpos(1)); Y = round(RGrid .* sind(ThetaGrid) + p.bpos(2));
        valid = X>=1 & X<=p.dataSize(2) & Y>=1 & Y<=p.dataSize(1); IndMap = nan(size(ThetaGrid), 'single'); IndMap(valid) = sub2ind(p.dataSize, Y(valid), X(valid));
        new_azi = zeros(length(theta), Nnew, 'single'); BW = p.BW;
        
        for ii = 1:Nnew
            new_azi(:, ii) = processPGIXSAzimuthal1D(Stack_new(:,:,ii), IndMap, BW, isMedian);
        end
        param.dataAzistack = cat(2, param.dataAzistack, new_azi); PlotAziseries2_Callback;
    end

    function updateROI(Stack_new, ~, p)
        if ~isfield(p, 'ROI') || isempty(p.ROI), return; end
        new_roi_sum = processPGIXSROIStack(Stack_new, p.ROI, false);
        param.SumIROI = cat(1, param.SumIROI, new_roi_sum); PlotROI_Callback;
    end

    function Resize_Callback(src, ~)
        original_units = get(src, 'Units'); set(src, 'Units', 'pixels'); pos_pix = get(src, 'Position'); set(src, 'Units', original_units); height = pos_pix(4); if height < 10, return; end
        baseFont = height / 110; uiFontSize = max(8, min(10, baseFont)); panelFontSize = max(9, min(11, baseFont + 1)); axesFontSize = max(7, min(9, baseFont - 1));
        % Modern UI 호환: uilabel, uibutton, uidropdown, uieditfield, uicheckbox
        hLabels = findall(src, 'Type', 'uilabel'); for i=1:length(hLabels), try hLabels(i).FontSize = uiFontSize; catch; end; end
        hButtons = findall(src, 'Type', 'uibutton'); for i=1:length(hButtons), try hButtons(i).FontSize = uiFontSize; catch; end; end
        hDropdowns = findall(src, 'Type', 'uidropdown'); for i=1:length(hDropdowns), try hDropdowns(i).FontSize = uiFontSize; catch; end; end
        hEdits = findall(src, 'Type', 'uieditfield'); for i=1:length(hEdits), try hEdits(i).FontSize = uiFontSize; catch; end; end
        hPanel = findall(src, 'Type', 'uipanel'); for i=1:length(hPanel), try hPanel(i).FontSize = panelFontSize; catch; end; end
        hAxes = findall(src, 'Type', 'axes'); set(hAxes, 'FontSize', axesFontSize);
        drawnow limitrate;
    end
end % <--- [Main Function End]

% =========================================================================
% ====================== LOCAL FUNCTIONS (Parfor Safe) ====================
% =========================================================================
  

function [c1, cBC, ts_out, t_vals] = read_metadata_worker(fname, mode)
    [~, ts_out, t_vals, report] = readPGIXSH5FrameMetadataRow(fname, mode, [NaN NaN], NaN, 2);
    if ~report.OK
        error('TrXS2:MetadataReadFailed', '%s', report.Message);
    end
    c1 = report.RawCounts(1);
    cBC = report.RawCounts(2);
end

function [X, Label, Unit] = getExperimentXAxis(p)
    [X, Label, Unit] = computePGIXSExperimentXAxis(p, 'TrXS');
end
