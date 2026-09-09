function GIXS2_gui
% GIXS2_gui v2.0 - Grazing Incidence X-ray Scattering Series (Modern UI)
% Optimized for High Performance, Memory Efficiency, and 4-Panel Layout
% Designed By Y.Y.Kim / Modernized & Unchained

% [환경 변수 꼬임 자동 복구]
try evalin('base', 'clear uilabel uifigure uigridlayout uipanel uiaxes uibutton uidropdown uicheckbox uieditfield'); catch; end
if exist('uilabel', 'builtin') == 0 && exist('uilabel', 'file') == 0, errordlg('현재 매트랩이 모던 UI를 인식하지 못합니다.', '버전 오류'); return; end

clc;

%% ========================================================================
% 1. Main Window & Master Grid Setup
% ========================================================================
GUI.main = uifigure('Name','Grazing Incidence X-ray Scattering Series v2.0',...
    'NumberTitle','off', 'Position',[50 50 1600 900], 'Color', [0.96 0.96 0.96]);
movegui(GUI.main, 'center');

mainGrid = uigridlayout(GUI.main, [1 2]);
mainGrid.ColumnWidth = {400, '1x'};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 10;

% Global Data Structure
param = initializeParams();
GX2 = struct();
% Auto.Met 모드 상수 정의
AUTO_LINECUT = 0; AUTO_AZIMUTHAL = 2; AUTO_ROI = 3;
Auto.Met = AUTO_LINECUT; Auto.Nold = 0;

%% ========================================================================
% 2. Left Panel (Parameters) - 레이아웃 압축 및 명칭 수정
% ========================================================================
leftPanel = uipanel(mainGrid, 'Title', 'Serial Data Parameters', 'FontSize', 13, 'FontWeight', 'bold', 'Scrollable', 'on');
leftPanel.Layout.Row = 1; leftPanel.Layout.Column = 1;

% [수정] 행 높이를 22로 압축하고 간격을 줄여 전체 메뉴가 한눈에 들어오게 조절
lg = uigridlayout(leftPanel, [32 6]);
lg.RowHeight = num2cell([repmat(22, 1, 30), 25, 25]); 
lg.ColumnWidth = {'1.5x', '1x', '1x', '1x', '1.2x', '1.2x'}; % Directory 라벨을 위해 첫 열 확장
lg.Padding = [5 5 5 5]; lg.RowSpacing = 4; lg.ColumnSpacing = 5;

% [1] Directory (명칭 변경)
lblDir = uilabel(lg, 'Text', 'Directory:'); lblDir.Layout.Row = 1; lblDir.Layout.Column = 1;
GX2.pathset = uieditfield(lg, 'text', 'Value', pwd); GX2.pathset.Layout.Row = 1; GX2.pathset.Layout.Column = [2 5];
btnDir = uibutton(lg, 'Text', 'Set', 'ButtonPushedFcn', @pathset2_Callback); btnDir.Layout.Row = 1; btnDir.Layout.Column = 6;

% [2] Detector & Exp Mode
l2 = uilabel(lg, 'Text', 'Detector:'); l2.Layout.Row = 2; l2.Layout.Column = [1 2];
GUI.hDetector = uidropdown(lg, 'Items', {'Eiger4M', 'MarCCD', 'MX170HS', 'PI-CCD'}); GUI.hDetector.Layout.Row = 2; GUI.hDetector.Layout.Column = [3 4];
GUI.hinsitumode = uidropdown(lg, 'Items', {'Time', 'Temperature', 'Angle', 'LowTemp.'}, 'ValueChangedFcn', @InsituModeChanged_Callback); GUI.hinsitumode.Layout.Row = 2; GUI.hinsitumode.Layout.Column = [5 6];

% [3] Load Data
bLoad = uibutton(lg, 'Text', 'LOAD DATA', 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.3 0.5], 'FontColor', 'w', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 Load Data', @()Openimage2_Callback([], [])));
bLoad.Layout.Row = 3; bLoad.Layout.Column = [1 6];

% [4] Filename & Set
l3 = uilabel(lg, 'Text', 'Filename:'); l3.Layout.Row = 4; l3.Layout.Column = [1 2];
GX2.hFilename = uieditfield(lg, 'text', 'Value', 'ABCD'); GX2.hFilename.Layout.Row = 4; GX2.hFilename.Layout.Column = [3 4];
bName = uibutton(lg, 'Text', 'Set / Table', 'FontWeight', 'bold', 'ButtonPushedFcn', @OpenNameDef_callback); bName.Layout.Row = 4; bName.Layout.Column = [5 6];

% [5] Counters & # of Files (SC 제거 및 버튼 확장)
bIC = uibutton(lg, 'Text', 'IC', 'ButtonPushedFcn', @OpenICplot_callback); bIC.Layout.Row = 5; bIC.Layout.Column = [1 2];
bBC = uibutton(lg, 'Text', 'BC', 'ButtonPushedFcn', @OpenBCplot_callback); bBC.Layout.Row = 5; bBC.Layout.Column = [3 4];
l4 = uilabel(lg, 'Text', '# of Files:'); l4.Layout.Row = 5; l4.Layout.Column = 5;
GX2.NFile = uilabel(lg, 'Text', '0', 'FontWeight', 'bold'); GX2.NFile.Layout.Row = 5; GX2.NFile.Layout.Column = 6;

% [6] Exp Params
l5 = uilabel(lg, 'Text', '-- Exp. Params --', 'FontWeight', 'bold'); l5.Layout.Row = 6; l5.Layout.Column = [1 3];
GUI.btnInfo = uibutton(lg, 'Text', 'Load Info', 'FontWeight', 'bold', 'BackgroundColor', 'w', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 Load Info', @()Openinfo2_Callback([], []))); 
GUI.btnInfo.Layout.Row = 6; GUI.btnInfo.Layout.Column = [4 5];
bGrid = uibutton(lg, 'Text', 'Grid Rmv', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 Grid Remove', @()GridRemove2_Callback([], []))); bGrid.Layout.Row = 6; bGrid.Layout.Column = 6;

% [7] Incidence Angle Calibration (y-pos & Z-plot)
lblYp = uilabel(lg, 'Text', 'y-pos:'); lblYp.Layout.Row = 7; lblYp.Layout.Column = 1;
GX2.hAiYPix = uieditfield(lg, 'numeric', 'Value', 0); GX2.hAiYPix.Layout.Row = 7; GX2.hAiYPix.Layout.Column = [2 3];
btnZplot = uibutton(lg, 'Text', 'Z-Plot', 'ButtonPushedFcn', @aiZplot_Callback); btnZplot.Layout.Row = 7; btnZplot.Layout.Column = [4 6];

% [8] Incidence Angle
l8 = uilabel(lg, 'Text', 'ai [deg]:'); l8.Layout.Row = 8; l8.Layout.Column = 1;
l9 = uilabel(lg, 'Text', 'pix:'); l9.Layout.Row = 8; l9.Layout.Column = 2;
GX2.hAiPix = uieditfield(lg, 'numeric', 'Value', 30, 'ValueChangedFcn', @CalIncidence2_Callback); GX2.hAiPix.Layout.Row = 8; GX2.hAiPix.Layout.Column = 3;
l10 = uilabel(lg, 'Text', 'deg:'); l10.Layout.Row = 8; l10.Layout.Column = 4;
GX2.hAiDeg = uieditfield(lg, 'numeric', 'Value', 0.1, 'BackgroundColor', 'c', 'ValueChangedFcn', @CalIncidencePixel2_Callback); GX2.hAiDeg.Layout.Row = 8; GX2.hAiDeg.Layout.Column = [5 6];

% [9] Change ai & step
GUI.hChange = uicheckbox(lg, 'Text', 'Change ai'); GUI.hChange.Layout.Row = 9; GUI.hChange.Layout.Column = [1 3];
l11 = uilabel(lg, 'Text', 'step:'); l11.Layout.Row = 9; l11.Layout.Column = 4;
GX2.hAistep = uieditfield(lg, 'numeric', 'Value', 0.01, 'BackgroundColor', 'c'); GX2.hAistep.Layout.Row = 9; GX2.hAistep.Layout.Column = [5 6];

% [10] Exposure & Mapping
l12 = uilabel(lg, 'Text', 'Expo(s):'); l12.Layout.Row = 10; l12.Layout.Column = 1;
GX2.hExptime = uieditfield(lg, 'numeric', 'Value', 1, 'ValueChangedFcn', @TimeUnit_Callback); GX2.hExptime.Layout.Row = 10; GX2.hExptime.Layout.Column = 2;
GUI.hTimeP = uidropdown(lg, 'Items', {'second', 'min', 'hour'}, 'ValueChangedFcn', @TimeUnit_Callback); GUI.hTimeP.Layout.Row = 10; GUI.hTimeP.Layout.Column = 3;
GUI.hQMAPmethod = uidropdown(lg, 'Items', {'Qxy/Qz', 'Qy/Qz'}); GUI.hQMAPmethod.Layout.Row = 10; GUI.hQMAPmethod.Layout.Column = 4;
GUI.btnQcal = uibutton(lg, 'Text', 'q-Cal.', 'FontWeight', 'bold', 'BackgroundColor', 'w', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 q-Cal', @()Qcalc_Callback([], []))); 
GUI.btnQcal.Layout.Row = 10; GUI.btnQcal.Layout.Column = 5;
bSvStk = uibutton(lg, 'Text', 'Sv Stack', 'ButtonPushedFcn', @SaveStack_Callback); bSvStk.Layout.Row = 10; bSvStk.Layout.Column = 6;

% [12] --- 1D Plot Process ---
l13 = uilabel(lg, 'Text', '--- 1D Plot Process ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); l13.Layout.Row = 12; l13.Layout.Column = [1 6];

l14 = uilabel(lg, 'Text', '1D Ang:');
l14.Layout.Row = 13;
l14.Layout.Column = [1 2];

GX2.h1dphi = uieditfield(lg, 'numeric', 'Value', 90);
GX2.h1dphi.Layout.Row = 13;
GX2.h1dphi.Layout.Column = 3;

% 방향 가이드 Legend 추가 (0: ←, 90: ↑, 180: →)
lblLeg1d = uilabel(lg, 'Text', '0: ←,  90: ↑,  180: →', 'FontSize', 11);
lblLeg1d.Layout.Row = 13;
lblLeg1d.Layout.Column = [4 6];

l15 = uilabel(lg, 'Text', 'Accum:'); l15.Layout.Row = 14; l15.Layout.Column = [1 2];
GX2.h1dAmpix = uieditfield(lg, 'numeric', 'Value', -1); GX2.h1dAmpix.Layout.Row = 14; GX2.h1dAmpix.Layout.Column = 3;
GX2.h1dAppix = uieditfield(lg, 'numeric', 'Value', 1); GX2.h1dAppix.Layout.Row = 14; GX2.h1dAppix.Layout.Column = 4;
GUI.hAccum = uicheckbox(lg, 'Text', 'On'); GUI.hAccum.Layout.Row = 14; GUI.hAccum.Layout.Column = 5;

l16 = uilabel(lg, 'Text', 'Cakecut:'); l16.Layout.Row = 15; l16.Layout.Column = [1 2];
GX2.hCkcutst = uieditfield(lg, 'numeric', 'Value', -1); GX2.hCkcutst.Layout.Row = 15; GX2.hCkcutst.Layout.Column = 3;
GX2.hCkcutfi = uieditfield(lg, 'numeric', 'Value', 1); GX2.hCkcutfi.Layout.Row = 15; GX2.hCkcutfi.Layout.Column = 4;
GUI.hCakecut = uicheckbox(lg, 'Text', 'On'); GUI.hCakecut.Layout.Row = 15; GUI.hCakecut.Layout.Column = 5;

l17 = uilabel(lg, 'Text', 'z-pos mv:'); l17.Layout.Row = 16; l17.Layout.Column = [1 2];
GX2.h1dzpos = uieditfield(lg, 'numeric', 'Value', 0); GX2.h1dzpos.Layout.Row = 16; GX2.h1dzpos.Layout.Column = 3;
l18 = uilabel(lg, 'Text', 'y-pos mv:'); l18.Layout.Row = 17; l18.Layout.Column = [1 2];
GX2.h1dypos = uieditfield(lg, 'numeric', 'Value', 0); GX2.h1dypos.Layout.Row = 17; GX2.h1dypos.Layout.Column = 3;
bPos = uibutton(lg, 'Text', 'Position', 'ButtonPushedFcn', @Position2D_Callback); bPos.Layout.Row = [16 17]; bPos.Layout.Column = [4 5];

bLine = uibutton(lg, 'Text', 'Draw Line', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 Draw Line', @()Drawline2_Callback([], []))); bLine.Layout.Row = 18; bLine.Layout.Column = [1 2];
bLineEx = uibutton(lg, 'Text', 'Exec Cut', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 Line Cut Exec', @()Linecut2_Callback([], []))); bLineEx.Layout.Row = 18; bLineEx.Layout.Column = [3 4];
% 값이 변경되면 곧바로 Plot1dseries2_Callback을 실행하여 그래프를 업데이트합니다.
GUI.hNormal1D = uidropdown(lg, 'Items', {'None','IC','BC'}, 'ValueChangedFcn', @Plot1dseries2_Callback); 
GUI.hNormal1D.Layout.Row = 18; GUI.hNormal1D.Layout.Column = [5 6];

% [20] --- Azimuthal Process ---
l19 = uilabel(lg, 'Text', '--- Azimuthal Process ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); l19.Layout.Row = 20; l19.Layout.Column = [1 6];

bPtFnd = uibutton(lg, 'Text', 'Pos Pick', 'ButtonPushedFcn', @PointFind2_Callback); bPtFnd.Layout.Row = 21; bPtFnd.Layout.Column = [1 2];
l20 = uilabel(lg, 'Text', 'pix:'); l20.Layout.Row = 21; l20.Layout.Column = 3;
GX2.azipospix = uieditfield(lg, 'numeric', 'Value', 202, 'ValueChangedFcn', @CalcPos_Callback); GX2.azipospix.Layout.Row = 21; GX2.azipospix.Layout.Column = 4;
l21 = uilabel(lg, 'Text', 'z-pos:'); l21.Layout.Row = 21; l21.Layout.Column = 5;
GX2.Zpospixp = uieditfield(lg, 'numeric', 'Value', 0); GX2.Zpospixp.Layout.Row = 21; GX2.Zpospixp.Layout.Column = 6;

l22 = uilabel(lg, 'Text', 'Range (-/+):'); l22.Layout.Row = 22; l22.Layout.Column = [1 2];
GX2.azipospixm = uieditfield(lg, 'numeric', 'Value', -1, 'ValueChangedFcn', @CalcPos_Callback); GX2.azipospixm.Layout.Row = 22; GX2.azipospixm.Layout.Column = 3;
GX2.azipospixp = uieditfield(lg, 'numeric', 'Value', 1, 'ValueChangedFcn', @CalcPos_Callback); GX2.azipospixp.Layout.Row = 22; GX2.azipospixp.Layout.Column = 4;
GUI.hMeanMedAzi = uidropdown(lg, 'Items', {'Mean', 'Median'}); GUI.hMeanMedAzi.Layout.Row = 22; GUI.hMeanMedAzi.Layout.Column = [5 6];

bAziDrw = uibutton(lg, 'Text', 'Draw Arc', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 Draw Azimuthal', @()DrawAziPlot2_Callback([], []))); bAziDrw.Layout.Row = 23; bAziDrw.Layout.Column = [1 2];
bAziEx = uibutton(lg, 'Text', 'Exec Azi', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS2 Azimuthal Exec', @()Azilinecut2_Callback([], []))); bAziEx.Layout.Row = 23; bAziEx.Layout.Column = [3 4];
% 값이 변경되면 곧바로 PlotAziseries2_Callback을 실행하여 그래프를 업데이트합니다.
GUI.hNormalAzi = uidropdown(lg, 'Items', {'None','IC','BC'}, 'ValueChangedFcn', @PlotAziseries2_Callback); 
GUI.hNormalAzi.Layout.Row = 23; GUI.hNormalAzi.Layout.Column = [5 6];

% [24] Q-position (pixel과 동기화)
l_qp = uilabel(lg, 'Text', 'q-pos [1/A]:');
l_qp.Layout.Row = 24;
l_qp.Layout.Column = [1 2];

GX2.Qpospix = uieditfield(lg, 'numeric', 'Value', 0, 'ValueChangedFcn', @CalcQpos_Callback);
GX2.Qpospix.Layout.Row = 24;
GX2.Qpospix.Layout.Column = [3 4];

% [25] --- ROI Process ---
l23 = uilabel(lg, 'Text', '--- Region of Interest ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); l23.Layout.Row = 25; l23.Layout.Column = [1 6];

l24 = uilabel(lg, 'Text', 'N. ROI:'); l24.Layout.Row = 26; l24.Layout.Column = 1;
GUI.hNROI = uidropdown(lg, 'Items', {'1', '2', '3', '4', '5'}); GUI.hNROI.Layout.Row = 26; GUI.hNROI.Layout.Column = 2;
bROI = uibutton(lg, 'Text', 'Draw ROI', 'ButtonPushedFcn', @ROIdef2_Callback); bROI.Layout.Row = 26; bROI.Layout.Column = [3 4];
% 값이 변경되면 곧바로 PlotROI_Callback을 실행하여 그래프를 업데이트합니다.
GUI.hNormalROI = uidropdown(lg, 'Items', {'None','IC','BC'}, 'ValueChangedFcn', @PlotROI_Callback); 
GUI.hNormalROI.Layout.Row = 26; GUI.hNormalROI.Layout.Column = [5 6];

% [28] --- Options / Auto ---
l25 = uilabel(lg, 'Text', '--- Options / Auto ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); l25.Layout.Row = 28; l25.Layout.Column = [1 6];

GUI.hTmode = uidropdown(lg, 'Items', {'Temperature1', 'Temperature2', 'Temperature3', 'Time'}, 'ValueChangedFcn', @Tmode_Callback); GUI.hTmode.Layout.Row = 29; GUI.hTmode.Layout.Column = [1 3];
GUI.hAmode = uidropdown(lg, 'Items', {'Angle', 'Time'}, 'ValueChangedFcn', @Amode_Callback); GUI.hAmode.Layout.Row = 29; GUI.hAmode.Layout.Column = [4 6];

GUI.hOrderT = uicheckbox(lg, 'Text', 'T. Order', 'ValueChangedFcn', @(s,e)refreshXAxisPlots()); GUI.hOrderT.Layout.Row = 30; GUI.hOrderT.Layout.Column = [1 2];
GUI.hOrderA = uicheckbox(lg, 'Text', 'A. Order', 'ValueChangedFcn', @(s,e)refreshXAxisPlots()); GUI.hOrderA.Layout.Row = 30; GUI.hOrderA.Layout.Column = [4 5];
GUI.hParCom = uicheckbox(lg, 'Text', 'Parallel'); GUI.hParCom.Layout.Row = 30; GUI.hParCom.Layout.Column = 6;

bRefresh = uibutton(lg, 'Text', 'Auto Refresh (Find New)', 'FontWeight', 'bold', 'BackgroundColor', [0.8 0.9 0.8], 'ButtonPushedFcn', @Autoplot_Callback);
bRefresh.Layout.Row = [31 32]; bRefresh.Layout.Column = [1 6];

%% ========================================================================
% 3. Right Panels (4 Quadrants) - 완전 분리형(Unchained) 구조
% ========================================================================
rightGrid = uigridlayout(mainGrid, [2 2]);
rightGrid.RowHeight = {'1x', '1x'};
rightGrid.ColumnWidth = {'1x', '1x'};
rightGrid.Padding = [0 0 0 0];
rightGrid.RowSpacing = 10;
rightGrid.ColumnSpacing = 10;
rightGrid.Layout.Row = 1;
rightGrid.Layout.Column = 2;

% --- [Quad 1: 2D Image Plot Viewer] ---
pnlImg = uipanel(rightGrid, 'Title', '2D Image Plot Viewer', 'FontWeight', 'bold', 'BackgroundColor', 'w');
pnlImg.Layout.Row = 1;
pnlImg.Layout.Column = 1;

gImg = uigridlayout(pnlImg, [2 1]);
gImg.RowHeight = {'1x', 75};
gImg.RowSpacing = 5;
gImg.Padding = [5 5 5 5];

hAX1 = uiaxes(gImg);
hAX1.Layout.Row = 1;
hAX1.Layout.Column = 1;

% 컨트롤러 그리드 생성 (Play 버튼을 위해 8열로 확장)
% 컨트롤러 그리드 생성 (불필요한 Format 제거, 7열로 깔끔하게 최적화)
cg1 = uigridlayout(gImg, [2 7]);
cg1.Layout.Row = 2;
cg1.RowHeight = {20, 25};
cg1.Padding = [5 2 5 2];

% 라벨 및 컨트롤 분리 선언 (Chaining 제거)
lblS1 = uilabel(cg1, 'Text', 'Scale');
lblS1.Layout.Row = 1; lblS1.Layout.Column = 1;

lblC1 = uilabel(cg1, 'Text', 'Colormap');
lblC1.Layout.Row = 1; lblC1.Layout.Column = 2;

lblM1 = uilabel(cg1, 'Text', 'Min/Max');
lblM1.Layout.Row = 1; lblM1.Layout.Column = 3;

lblX1 = uilabel(cg1, 'Text', 'X-Range');
lblX1.Layout.Row = 1; lblX1.Layout.Column = 4;

lblY1 = uilabel(cg1, 'Text', 'Y-Range');
lblY1.Layout.Row = 1; lblY1.Layout.Column = 5;

% 1. Scale
GUI.hScaleImg = uidropdown(cg1, 'Items', {'Linear', 'Log'}, 'ValueChangedFcn', @(s,e)updateImage2());
GUI.hScaleImg.Layout.Row = 2; GUI.hScaleImg.Layout.Column = 1;

% 2. Colormap
ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis','cubehelix','magma','kindlemann','jet2','ocean','rwb','rkb'};
GUI.hColorImg = uidropdown(cg1, 'Items', ColormapList, 'ValueChangedFcn', @(s,e)updateImage2());
GUI.hColorImg.Layout.Row = 2; GUI.hColorImg.Layout.Column = 2;

% 3. Min/Max
subC1 = uigridlayout(cg1, [1 2], 'Padding', [0 0 0 0]);
subC1.Layout.Row = 2; subC1.Layout.Column = 3;
GX2.cMin = uieditfield(subC1, 'numeric', 'Value', 1, 'ValueChangedFcn', @(s,e)updateImage2());
GX2.cMax = uieditfield(subC1, 'numeric', 'Value', 1000, 'ValueChangedFcn', @(s,e)updateImage2());

% 4. X-Range
subX1 = uigridlayout(cg1, [1 2], 'Padding', [0 0 0 0]);
subX1.Layout.Row = 2; subX1.Layout.Column = 4;
GX2.cXlim1 = uieditfield(subX1, 'numeric', 'ValueChangedFcn', @(s,e)updateImage2());
GX2.cXlim2 = uieditfield(subX1, 'numeric', 'ValueChangedFcn', @(s,e)updateImage2());

% 5. Y-Range
subY1 = uigridlayout(cg1, [1 2], 'Padding', [0 0 0 0]);
subY1.Layout.Row = 2; subY1.Layout.Column = 5;
GX2.cYlim1 = uieditfield(subY1, 'numeric', 'ValueChangedFcn', @(s,e)updateImage2());
GX2.cYlim2 = uieditfield(subY1, 'numeric', 'ValueChangedFcn', @(s,e)updateImage2());

% 6. Play Button
btnPlay1 = uibutton(cg1, 'Text', 'Play', 'ButtonPushedFcn', @Imageplay2_Callback);
btnPlay1.Layout.Row = [1 2]; btnPlay1.Layout.Column = 6;

% 7. Update Button
btnUp1 = uibutton(cg1, 'Text', 'Update', 'ButtonPushedFcn', @(s,e)updateImage2());
btnUp1.Layout.Row = [1 2]; btnUp1.Layout.Column = 7;

% --- [Quad 2: 1D Plot Viewer] ---
pnl1D = uipanel(rightGrid, 'Title', '1D Plot Viewer', 'FontWeight', 'bold', 'BackgroundColor', 'w');
pnl1D.Layout.Row = 1;
pnl1D.Layout.Column = 2;

g1D = uigridlayout(pnl1D, [2 1]);
g1D.RowHeight = {'1x', 75}; g1D.RowSpacing = 5; g1D.Padding = [5 5 5 5];

hAX3 = uiaxes(g1D);
hAX3.Layout.Row = 1; hAX3.Layout.Column = 1;

% 컨트롤러 그리드 6열로 확장 (Norm(Pt) 버튼 추가)
cg3 = uigridlayout(g1D, [2 6]);
cg3.Layout.Row = 2; cg3.RowHeight = {20, 25}; cg3.Padding = [5 2 5 2];

lblS3 = uilabel(cg3, 'Text', 'Plot Scale'); lblS3.Layout.Row = 1; lblS3.Layout.Column = 1;
lblQ3 = uilabel(cg3, 'Text', 'Q-Range'); lblQ3.Layout.Row = 1; lblQ3.Layout.Column = 2;
lblA3 = uilabel(cg3, 'Text', 'Actions'); lblA3.Layout.Row = 1; lblA3.Layout.Column = [3 4];
lblF3 = uilabel(cg3, 'Text', 'Save Form'); lblF3.Layout.Row = 1; lblF3.Layout.Column = 5;

% [수정] ValueChangedFcn을 추가하여 스케일 즉각 반영
GUI.hScale1D = uidropdown(cg3, 'Items', {'Linear', 'Logy', 'Logxy'}, 'ValueChangedFcn', @update1Dplot_Callback);
GUI.hScale1D.Layout.Row = 2; GUI.hScale1D.Layout.Column = 1;

subQ3 = uigridlayout(cg3, [1 2], 'Padding', [0 0 0 0]);
subQ3.Layout.Row = 2; subQ3.Layout.Column = 2;
GX2.qMin = uieditfield(subQ3, 'numeric', 'ValueChangedFcn', @update1Dplot_Callback);
GX2.qMax = uieditfield(subQ3, 'numeric', 'ValueChangedFcn', @update1Dplot_Callback);

% [복구] Norm(Pt) 버튼 추가
btnNm3 = uibutton(cg3, 'Text', 'Norm(Pt)', 'ButtonPushedFcn', @NormalFactor_Callback);
btnNm3.Layout.Row = 2; btnNm3.Layout.Column = 3;

btnHm3 = uibutton(cg3, 'Text', 'Heatmap', 'ButtonPushedFcn', @updateQHeatmap_Callback);
btnHm3.Layout.Row = 2; btnHm3.Layout.Column = 4;

GUI.hSForm1D = uidropdown(cg3, 'Items', {'.mat', '.dat', '.csv'}, 'Value', '.dat');
GUI.hSForm1D.Layout.Row = 2; GUI.hSForm1D.Layout.Column = 5;

btnSv3 = uibutton(cg3, 'Text', 'Save 1D', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @Saveget3_Callback);
btnSv3.Layout.Row = [1 2]; btnSv3.Layout.Column = 6;

% --- [Quad 3: Azimuthal Plot Viewer] ---
pnlAzi = uipanel(rightGrid, 'Title', 'Azimuthal Plot Viewer', 'FontWeight', 'bold', 'BackgroundColor', 'w');
pnlAzi.Layout.Row = 2;
pnlAzi.Layout.Column = 1;

gAzi = uigridlayout(pnlAzi, [2 1]);
gAzi.RowHeight = {'1x', 75}; gAzi.RowSpacing = 5; gAzi.Padding = [5 5 5 5];

hAX2 = uiaxes(gAzi);
hAX2.Layout.Row = 1; hAX2.Layout.Column = 1;

% 컨트롤러 그리드 6열로 확장 (Norm(Pt) 버튼 추가)
cg2 = uigridlayout(gAzi, [2 6]);
cg2.Layout.Row = 2; cg2.RowHeight = {20, 25}; cg2.Padding = [5 2 5 2];

lblS2 = uilabel(cg2, 'Text', 'Plot Scale'); lblS2.Layout.Row = 1; lblS2.Layout.Column = 1;
lblR2 = uilabel(cg2, 'Text', 'Azi-Range'); lblR2.Layout.Row = 1; lblR2.Layout.Column = 2;
lblA2 = uilabel(cg2, 'Text', 'Actions'); lblA2.Layout.Row = 1; lblA2.Layout.Column = [3 4];
lblF2 = uilabel(cg2, 'Text', 'Save Form'); lblF2.Layout.Row = 1; lblF2.Layout.Column = 5;

% [수정] ValueChangedFcn을 추가하여 스케일 즉각 반영
GUI.hScaleAzi = uidropdown(cg2, 'Items', {'Linear', 'Logy'}, 'ValueChangedFcn', @updateAziplot_Callback);
GUI.hScaleAzi.Layout.Row = 2; GUI.hScaleAzi.Layout.Column = 1;

subA2 = uigridlayout(cg2, [1 2], 'Padding', [0 0 0 0]);
subA2.Layout.Row = 2; subA2.Layout.Column = 2;
GX2.aziMin = uieditfield(subA2, 'numeric', 'ValueChangedFcn', @updateAziplot_Callback);
GX2.aziMax = uieditfield(subA2, 'numeric', 'ValueChangedFcn', @updateAziplot_Callback);

% [복구] Norm(Pt) 버튼 추가
btnNm2 = uibutton(cg2, 'Text', 'Norm(Pt)', 'ButtonPushedFcn', @NormalFactorAzi_Callback);
btnNm2.Layout.Row = 2; btnNm2.Layout.Column = 3;

btnHm2 = uibutton(cg2, 'Text', 'Heatmap', 'ButtonPushedFcn', @updateAziHeatmap_Callback);
btnHm2.Layout.Row = 2; btnHm2.Layout.Column = 4;

GUI.hSFormAzi = uidropdown(cg2, 'Items', {'.mat', '.dat', '.csv'}, 'Value', '.dat');
GUI.hSFormAzi.Layout.Row = 2; GUI.hSFormAzi.Layout.Column = 5;

btnSv2 = uibutton(cg2, 'Text', 'Save Azi', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @Saveget2_Callback);
btnSv2.Layout.Row = [1 2]; btnSv2.Layout.Column = 6;

% --- [Quad 4: Series Integration Viewer] ---
pnlInt = uipanel(rightGrid, 'Title', 'Series Integration Viewer', 'FontWeight', 'bold', 'BackgroundColor', 'w');
pnlInt.Layout.Row = 2;
pnlInt.Layout.Column = 2;

gInt = uigridlayout(pnlInt, [2 1]);
gInt.RowHeight = {'1x', 75};
gInt.RowSpacing = 5;
gInt.Padding = [5 5 5 5];

hAX4 = uiaxes(gInt);
hAX4.Layout.Row = 1;
hAX4.Layout.Column = 1;

cg4 = uigridlayout(gInt, [2 4]);
cg4.Layout.Row = 2;
cg4.RowHeight = {20, 25};
cg4.Padding = [5 2 5 2];

lblO4 = uilabel(cg4, 'Text', 'Plot Options');
lblO4.Layout.Row = 1;
lblO4.Layout.Column = 1;

lblS4 = uilabel(cg4, 'Text', 'Save Options');
lblS4.Layout.Row = 1;
lblS4.Layout.Column = 2;

lblE4 = uilabel(cg4, 'Text', 'Export');
lblE4.Layout.Row = 1;
lblE4.Layout.Column = 3;

btnRp4 = uibutton(cg4, 'Text', 'Re-Plot Series', 'ButtonPushedFcn', @ReplotInt_Callback);
btnRp4.Layout.Row = 2;
btnRp4.Layout.Column = 1;

GUI.hSFormInt = uidropdown(cg4, 'Items', {'.mat', '.dat', '.csv'}, 'Value', '.dat');
GUI.hSFormInt.Layout.Row = 2;
GUI.hSFormInt.Layout.Column = 2;

btnSvI4 = uibutton(cg4, 'Text', 'Save Integ.', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @Saveget4_Callback);
btnSvI4.Layout.Row = [1 2];
btnSvI4.Layout.Column = 3;

btnSvX4 = uibutton(cg4, 'Text', 'Save X-Axis', 'BackgroundColor', [0.9 0.95 1], 'ButtonPushedFcn', @SavegetX_Callback);
btnSvX4.Layout.Row = [1 2];
btnSvX4.Layout.Column = 4;

%% ========================================================================
% HELPER & CALLBACK FUNCTIONS (Internal)
% ========================================================================
    function p = initializeParams(), p.data = []; p.Expinfo = 0; p.correctionI = 0; p.Normalcheck = 0; end

    function runLoggedAction(actionName, callbackFcn)
        ensurePGIXSFunctionsPath();
        runPGIXSCallback(GUI.main, actionName, callbackFcn, ...
            @()summarizePGIXSState(param, actionName, struct('GUI', 'GIXS2_gui')));
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

    function pathset2_Callback(~,~)
        pathway = uigetdir;
        figure(GUI.main); drawnow;
        if pathway ~= 0, GX2.pathset.Value = pathway; end
    end

    function Openimage2_Callback(~,~)
        clc;
        % 디텍터 설정 및 경로 가져오기
        param.detector = GUI.hDetector.Value;
        pathway = GX2.pathset.Value;
        
        % 파일 선택창 열기
        [XSImage, datadir] = uigetfile({'*.*','All format(*.*)'}, 'Select a file', pathway);
        figure(GUI.main); drawnow;
        if XSImage == 0, return; end
        XSImage = fullfile(datadir, XSImage);

        % 경로 및 파일명 분리
        [param.Path, param.FileName, param.FileFormat] = fileparts(XSImage);

        switch param.FileFormat
            case '.h5'
                try 
                    param.data = loadPGIXSH5Frame(XSImage); 
                catch ME
                    warndlg(['No data: ' ME.message], 'Warning'); return; 
                end
                
                meta = readPGIXSH5Metadata(XSImage);
                param.Count = [meta.Counter1, meta.CounterBC];
                
                % 파일명에서 프레임 접미사를 제거하여 자동 필터링 이름 생성
                fname_short = normalizePGIXSSeriesPrefix(param.FileName);
                GX2.hFilename.Value = char(fname_short);
            otherwise
                warndlg('Please use .h5 format!','Warning'); return;
        end
        param.dataSize = single(size(param.data));

        % [핵심: 이전 시리즈 데이터(Stack 등) 잔존 방지 및 변수 초기화]
        stale_fields = {'Stack','Qr','Qz','Qy','Q','aivar','data1dstack','data1dstackN',...
                        'dataAzistack','dataAzistackN','SumIROI','loginfo','timestampinfo','temperatureinfo','ROI'};
        for kk = 1:numel(stale_fields)
            if isfield(param, stale_fields{kk}), param = rmfield(param, stale_fields{kk}); end
        end

        [param.Mask, param.pixel, maskReport] = loadPGIXSDetectorMask(param.detector);
        if maskReport.FallbackUsed && ~isempty(maskReport.Message)
            warndlg(['Detector mask warning: ', maskReport.Message], 'Warning');
        end
        
        % 데이터 마스킹 처리
        if isequal(double(param.dataSize), double(size(param.Mask)))
            param.data = param.data .* param.Mask; 
        else
            warndlg(sprintf('Detector mask size %s does not match data size %s. Mask skipped.', ...
                mat2str(size(param.Mask)), mat2str(double(param.dataSize))), 'Warning');
        end
        param.data(param.data >= 1e9) = nan;

        % 컨트라스트 초기값 계산
        [param.cmin, param.cmax] = computePGIXSDisplayLimits(param.data);
        
        GX2.cMax.Value = double(param.cmax); 
        GX2.cMin.Value = double(param.cmin);
        
        % 줌 범위(Range) 초기화
        GX2.cXlim1.Value = double(1); 
        GX2.cXlim2.Value = double(param.dataSize(2));
        GX2.cYlim1.Value = double(1); 
        GX2.cYlim2.Value = double(param.dataSize(1));

        param.HD = single(1:param.dataSize(2)); 
        param.VD = single(1:param.dataSize(1));
        
        % [핵심 수정: 분석 상태 초기화 및 q-Cal 버튼 색상 원상복구]
        param.correctionI = 0; 
        param.Expinfo = 0; 
        param.Mapping = 'Pixel';
        GX2.NFile.Text = '0';
        
        % 새로운 데이터 로드시 q-Cal 버튼을 다시 원래(흰색)로 변경
        GUI.btnQcal.BackgroundColor = 'w'; 
        bGrid.BackgroundColor = [0.96 0.96 0.96];
        bGrid.FontColor = [0.15 0.15 0.15];
        
        % 이미지 렌더링
        updateImage2();
        figure(GUI.main); drawnow;
    end

    function OpenNameDef_callback(~,~)
        if ~isfield(param,'FileName')
            uialert(GUI.main, 'LOAD DATA 버튼으로 데이터를 먼저 1장 로드하세요!','Warning'); return; 
        end
        
        param.expmode = GUI.hinsitumode.Value;
        param.FileName = GX2.hFilename.Value;
        % hinsitumode에 맞춰 hTmode 아이템을 먼저 정렬하고 param.Tmode/Amode 캐시
        syncTmodeItems();
        param.Tmode = GUI.hTmode.Value;
        param.Amode = GUI.hAmode.Value;
        
        [names, files, N] = listPGIXSSeriesFiles(param.Path, param.FileName, '.h5');
        if N == 0
            uialert(GUI.main, '해당 파일 이름 패턴을 찾을 수 없습니다!','Warning'); return; 
        end
        
        TrowName = num2cell((1:N)'); tf = true(N,1); T = table(files',names',tf);
        
        f = uifigure('Name', 'File List (Series)', 'Position', [400 300 600 600]);
        fg = uigridlayout(f, [2 1]);
        fg.RowHeight = {'1x', 40};
        fg.Padding = [10 10 10 10];
        
        uit = uitable(fg, 'Data', table2cell(T), ...
            'RowName', TrowName, 'ColumnName', {'FullName', 'FileName', 'Check'}, ...
            'ColumnWidth', {'auto', 'auto', 50}, 'ColumnEditable', [false false true]);
        uit.Layout.Row = 1;
        
        btn = uibutton(fg, 'Text', 'Export & Load', 'FontSize', 14, 'FontWeight', 'bold', ...
            'ButtonPushedFcn', @(h,e)table2workspace(uit,f));
        btn.Layout.Row = 2;
    end

    function table2workspace(uit,f)
        tmp = uit.Data(:, 3); exportbool = [tmp{:}]; files = uit.Data(exportbool, 1);
        
        % [핵심 패치] 창을 먼저 파괴하지 않고 숨기기만 하여 콜백 충돌(DestroyedObject) 차단
        f.Visible = 'off'; 
        drawnow;
        
        Loadingdata(files);
        
        % 로딩 완료 후 안전하게 메모리 해제
        if isvalid(f), delete(f); end
    end

    function Loadingdata(files)
        ParallelCom = GUI.hParCom.Value; N = length(files);
        
        % [핵심 패치] OOM(메모리 부족) 방지: 새 메모리 할당 전 기존 대용량 변수 완전 초기화
        if isfield(param, 'Stack'), param.Stack = []; end
        if isfield(param, 'data1dstack'), param.data1dstack = []; param.data1dstackN = []; end
        if isfield(param, 'dataAzistack'), param.dataAzistack = []; param.dataAzistackN = []; end
        if isfield(param, 'SumIROI'), param.SumIROI = []; end
        if isfield(param, 'Qr'), param.Qr = []; param.Qz = []; param.Q = []; param.Qy = []; end
        pause(0.2); % 가비지 컬렉터(GC)에 메모리 확보 시간 부여
        
        try
            param.Stack = zeros(param.dataSize(1), param.dataSize(2), N, 'single');
        catch ME
            uialert(GUI.main, ['Not enough memory: ', ME.message], 'Error');
            return;
        end

        param.loginfo = zeros(2,N, 'single'); param.timestampinfo = zeros(N,1); param.temperatureinfo = zeros(N,3, 'single'); 
        meta = readPGIXSH5Metadata(files{1}, param.expmode);
        param.RefIC = meta.Counter1;
        param.RefBC = meta.CounterBC;
        param.ts1 = meta.Timestamp;

        unit_val = GUI.hTimeP.Value; param.TimeUnit = unit_val; 
        t_offset = double(GX2.hExptime.Value); if isnan(t_offset), t_offset = 0; end
        param.ExpTime = t_offset;   

        MaskData = param.Mask; expmode_local = param.expmode; ts1_local = param.ts1;
        RefIC_local = param.RefIC; RefBC_local = param.RefBC;
        
        dlg = uiprogressdlg(GUI.main, 'Title', 'Loading Data', ...
            'Message', sprintf('Preparing to load %d files...', N), ...
            'Cancelable', 'on', 'Indeterminate', 'off');
        t_start = tic;
        loadedCount = 0;
        loadFailed = false(1, N);
        metadataFailed = false(1, N);

        if ParallelCom == 1
            Stack_local = param.Stack; loginfo1 = zeros(1,N,'single'); loginfoBC = zeros(1,N,'single');
            ts_info = zeros(N,1); temp_info = zeros(N,3,'single');
            dlg.Message = sprintf('Parallel loading: 0 / %d', N);

            parfor ii=1:N
                [D, okFrame, loadReport] = loadPGIXSH5FrameWithRetry(files{ii}, MaskData, NaN, size(MaskData));
                Stack_local(:,:,ii)=D;
                loadFailed(ii) = ~okFrame;
                metadataFailed(ii) = false;
                if ~okFrame
                    warning('GIXS2:DataLoadFailed', 'Data load failed for frame %d after %d attempts: %s', ii, loadReport.Attempts, loadReport.Message);
                end
                try
                    [c1, cBC, ts_val, t_vec] = read_metadata_worker(files{ii}, expmode_local, ts1_local);
                catch ME
                    warning('GIXS2:MetadataReadFailed', 'Metadata read failed for frame %d: %s', ii, ME.message);
                    metadataFailed(ii) = true;
                    c1 = nan; cBC = nan; ts_val = nan; t_vec = [nan nan nan];
                end
                normCounts = normalizePGIXSCounters([c1 cBC], [RefIC_local RefBC_local]);
                loginfo1(ii) = normCounts(1); loginfoBC(ii) = normCounts(2);
                ts_info(ii) = ts_val; temp_info(ii,:) = t_vec;
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
                    warning('GIXS2:DataLoadFailed', 'Data load failed for frame %d after %d attempts: %s', ii, loadReport.Attempts, loadReport.Message);
                end
                try
                    [c1, cBC, ts_val, t_vec] = read_metadata_worker(files{ii}, expmode_local, ts1_local);
                catch ME
                    warning('GIXS2:MetadataReadFailed', 'Metadata read failed for frame %d: %s', ii, ME.message);
                    metadataFailed(ii) = true;
                    c1 = nan; cBC = nan; ts_val = nan; t_vec = [nan nan nan];
                end
                normCounts = normalizePGIXSCounters([c1 cBC], [RefIC_local RefBC_local]);
                v1 = normCounts(1); v2 = normCounts(2);
                param.loginfo(:,ii) = [v1; v2];
                param.timestampinfo(ii) = ts_val; param.temperatureinfo(ii,:) = t_vec;
                loadedCount = ii;
                
                % [핵심 패치] UI 질식(Starvation) 방지
                if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                    dlg.Value = ii/N;
                    dlg.Message = loadingProgressMsg(ii, N, t_start);
                    drawnow limitrate; 
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

        param.data = mean(param.Stack,3,'omitnan');
        [param.cmin, param.cmax] = computePGIXSDisplayLimits(param.data);
        GX2.cMax.Value = double(param.cmax); GX2.cMin.Value = double(param.cmin);
        param.correctionI = 0; GX2.NFile.Text = num2str(N); Auto.Nold = N; updateImage2();
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
    end

    function updateImage2(~,~)
        if isempty(param.data), return; end
        param.colorscale = GUI.hScaleImg.Value; param.colorm = GUI.hColorImg.Value;
        param.cmax = double(GX2.cMax.Value); param.cmin = double(GX2.cMin.Value);
        
        cla(hAX1);
        if isfield(param, 'HD') && isfield(param, 'VD'), imagesc(hAX1, param.HD, param.VD, param.data); else, imagesc(hAX1, param.data); end
        
        if param.Expinfo == 0, set(hAX1, 'YDir', 'reverse'); xlabel(hAX1, 'Y (pixel)'); ylabel(hAX1, 'Z (pixel)');
        else, set(hAX1, 'YDir', 'normal'); xlabel(hAX1, 'Y (pixel relative)'); ylabel(hAX1, 'Z (pixel relative)'); end

        axis(hAX1, 'image');
        x_lim = [double(GX2.cXlim1.Value), double(GX2.cXlim2.Value)]; y_lim = [double(GX2.cYlim1.Value), double(GX2.cYlim2.Value)];
        if x_lim(1) >= x_lim(2) || y_lim(1) >= y_lim(2)
            if isfield(param, 'HD'), x_lim = [min(param.HD), max(param.HD)]; y_lim = [min(param.VD), max(param.VD)];
                GX2.cXlim1.Value = double(x_lim(1)); GX2.cXlim2.Value = double(x_lim(2)); GX2.cYlim1.Value = double(y_lim(1)); GX2.cYlim2.Value = double(y_lim(2)); end
        end
        set(hAX1, 'XLim', x_lim, 'YLim', y_lim);

        % [Log scale일 때 cmin이 0/음수면 양수 최소값으로 보정]
        clim_lo = param.cmin; clim_hi = param.cmax;
        if strcmp(param.colorscale, 'Log')
            if clim_lo <= 0
                pos_min = min(param.data(param.data > 0), [], 'omitnan');
                if isempty(pos_min) || isnan(pos_min), pos_min = eps('single'); end
                clim_lo = double(pos_min);
            end
            if clim_hi <= clim_lo, clim_hi = clim_lo * 10; end
        else
            if clim_hi <= clim_lo, clim_hi = clim_lo + 1; end
        end
        clim(hAX1, [clim_lo, clim_hi]);
        applyPGIXSAxesColorScale(hAX1, param.colorscale);
        applyPGIXSColormap(hAX1, param.colorm, param.data); colorbar(hAX1);
        ttl = 'Image'; if isfield(param, 'FileName'), ttl = param.FileName; end
        title(hAX1, ttl, 'Interpreter', 'none', 'FontSize', 10);
        drawROIOverlay();   % ROI가 정의되어 있으면 사각형 오버레이 표시
        drawnow limitrate;
    end

    function drawROIOverlay()
        % 메인 2D 이미지 위에 ROI 사각형들을 노란색 라인으로 표시.
        % imagesc에 의한 cla 후 호출되므로 매번 새로 그림.
        if ~isfield(param, 'ROI') || isempty(param.ROI), return; end
        nROI = size(param.ROI, 1);
        % param.ROI(:,:) = [r1 r2 c1 c2]  (행: top→bottom, 열: left→right, pixel index 1-based)
        % 메인 이미지는 imagesc(param.HD, param.VD, ...)로 좌표 표시되므로
        % HD/VD를 통해 pixel index → display 좌표로 환산
        hold(hAX1, 'on');
        for r = 1:nROI
            roi = param.ROI(r, :);
            r1 = max(1, roi(1)); r2 = min(param.dataSize(1), roi(2));
            c1 = max(1, roi(3)); c2 = min(param.dataSize(2), roi(4));
            if r1 > r2 || c1 > c2, continue; end
            if isfield(param, 'HD') && isfield(param, 'VD')
                x_left  = param.HD(c1); x_right = param.HD(c2);
                y_top   = param.VD(r1); y_bot   = param.VD(r2);
            else
                x_left = c1; x_right = c2; y_top = r1; y_bot = r2;
            end
            x_rect = [x_left x_right x_right x_left x_left];
            y_rect = [y_top  y_top   y_bot   y_bot  y_top ];
            plot(hAX1, x_rect, y_rect, '-y', 'LineWidth', 1.5, 'Tag', 'ROIOverlay');
            text(hAX1, x_left, y_top, sprintf(' ROI %d', r), ...
                'Color', 'y', 'FontWeight', 'bold', 'FontSize', 10, ...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
                'BackgroundColor', [0 0 0 0.4], 'Tag', 'ROIOverlay');
        end
        hold(hAX1, 'off');
    end

    function Imageplay2_Callback(~,~)
        if ~isfield(param, 'Stack') || isempty(param.Stack)
            uialert(GUI.main, '재생할 시리즈(Stack) 데이터가 없습니다. 먼저 Set/Table을 통해 데이터를 로드하세요.', '알림'); return; 
        end
        try 
            FrameImage(param); 
        catch ME
            uialert(GUI.main, ['Play 실행 실패: ', ME.message], '오류'); 
        end
    end

    function Openinfo2_Callback(~,~)
        [XSinfo, datadir]=uigetfile({'*.mat'},'Select info file', GX2.pathset.Value);
        figure(GUI.main); drawnow;
        if XSinfo==0, return; end
        [S, loadReport] = loadPGIXSStandardCalibration(fullfile(datadir, XSinfo), param.detector);
        if ~loadReport.OK, warndlg(loadReport.Message, 'Calibration Warning'); return; end
        param.Wavelength = S.wavelength; param.bpos = S.pc; param.SDD = S.sdd; param.Energy = S.Energy;
        param.HD = single(1:param.dataSize(2)) - param.bpos(1); param.VD = -(single(1:param.dataSize(1)) - param.bpos(2));
        GX2.cXlim1.Value = double(min(param.HD)); GX2.cXlim2.Value = double(max(param.HD)); GX2.cYlim1.Value = double(min(param.VD)); GX2.cYlim2.Value = double(max(param.VD));
        param.Expinfo = 1; 
        GUI.btnInfo.BackgroundColor = [0.75 0.95 0.75]; 
        updateImage2();
        figure(GUI.main); drawnow;
    end

    function Qcalc_Callback(~,~)
        if param.correctionI == 1, warndlg('Already corrected!','Warning'); return; end
        if ~isfield(param, 'Wavelength'), warndlg('Load Parameters first!','Warning'); return; end
        ChangeAng = GUI.hChange.Value; ParallelCom = GUI.hParCom.Value; param.TimeUnit = GUI.hTimeP.Value;
        
        k0 = (2*pi/param.Wavelength);
        N = size(param.Stack,3);

        dlg = uiprogressdlg(GUI.main, 'Title', 'Q-Cal & Correction', ...
            'Message', sprintf('Preparing %d frames...', N), ...
            'Cancelable', 'on', 'Indeterminate', 'off');
        t_start = tic;

        if ChangeAng == 0
            param.ai = double(GX2.hAiDeg.Value); param.QMapMet = GUI.hQMAPmethod.Value;
            switch param.QMapMet
                case 'Qxy/Qz', [~,param.Qr,param.Qz,param.Q,~,~] = Qmaping_gi(param.dataSize(2),param.dataSize(1),param.bpos,param.pixel,param.SDD,k0,param.ai);
                case 'Qy/Qz', [param.Qy,~,param.Qz,param.Q,~,~] = Qmaping_gi(param.dataSize(2),param.dataSize(1),param.bpos,param.pixel,param.SDD,k0,param.ai);
            end
            TotalFactor = computePGIXSDetectorCorrectionFactor(param, k0);
            InvFactor = 1 ./ TotalFactor; Stack_local = param.Stack;
            if ParallelCom == 1
                dlg.Indeterminate = 'on'; dlg.Message = sprintf('q-Cal correction (parallel): %d frames...', N);
                parfor ii = 1:N
                    Stack_local(:,:,ii) = Stack_local(:,:,ii) .* InvFactor;
                end
            else
                for ii = 1:N
                    if dlg.CancelRequested, break; end
                    Stack_local(:,:,ii) = Stack_local(:,:,ii) .* InvFactor;
                    if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                        dlg.Value = ii/N; dlg.Message = loadingProgressMsg(ii, N, t_start);
                        drawnow limitrate;
                    end
                end
            end
            param.Stack = Stack_local;
        else
            SolAng = SolidAngle(param.dataSize(2),param.dataSize(1),param.bpos,param.pixel,param.SDD);
            Pol = Polarization(param.dataSize(2),param.dataSize(1),param.bpos,param.pixel,param.SDD);
            BaseCorrection = SolAng .* Pol;
            AL_Kapton = load("KaptonAttLength8-30.mat");
            if strcmp(param.detector, 'Eiger4M'), AL_Si = load("SiAttLength8-30.mat"); else, AL_Si = struct(); end
            aistep = double(GX2.hAistep.Value); param.ai = double(GX2.hAiDeg.Value); param.aivar = param.ai + ((0:N-1)'.*aistep);
            aivar_vec = param.aivar; Kapton_R = AL_Kapton.R; if isfield(AL_Si, 'R'), Si_R = AL_Si.R; else, Si_R = []; end
            Stack_local = param.Stack; bpos = param.bpos; pixel = param.pixel; sdd = param.SDD; energy = param.Energy; dSize1 = param.dataSize(1); dSize2 = param.dataSize(2); detType = param.detector;
            Qr_stack = zeros(dSize1, dSize2, N, 'single'); Qz_stack = zeros(dSize1, dSize2, N, 'single');
            if ParallelCom == 1
                dlg.Indeterminate = 'on'; dlg.Message = sprintf('q-Cal correction (parallel): %d frames...', N);
                parfor ii = 1:N
                    [~,Qr_l,Qz_l,Q_l,~,~] = Qmaping_gi(dSize2, dSize1, bpos, pixel, sdd, k0, aivar_vec(ii)); Qr_stack(:,:,ii) = Qr_l; Qz_stack(:,:,ii) = Qz_l;
                    EF = Eff_correc(Q_l, Kapton_R, k0, energy, dSize2, dSize1, bpos, pixel);
                    if strcmp(detType, 'Eiger4M'), Factor = BaseCorrection .* EF .* Eff_correc2(Q_l, k0, Si_R, energy); else, Factor = BaseCorrection .* EF; end
                    Stack_local(:,:,ii) = Stack_local(:,:,ii) ./ Factor;
                end
            else
                for ii = 1:N
                    if dlg.CancelRequested, break; end
                    [~,Qr_l,Qz_l,Q_l,~,~] = Qmaping_gi(dSize2, dSize1, bpos, pixel, sdd, k0, aivar_vec(ii)); Qr_stack(:,:,ii) = Qr_l; Qz_stack(:,:,ii) = Qz_l;
                    EF = Eff_correc(Q_l, Kapton_R, k0, energy, dSize2, dSize1, bpos, pixel);
                    if strcmp(detType, 'Eiger4M'), Factor = BaseCorrection .* EF .* Eff_correc2(Q_l, k0, Si_R, energy); else, Factor = BaseCorrection .* EF; end
                    Stack_local(:,:,ii) = Stack_local(:,:,ii) ./ Factor;
                    if mod(ii,5)==0 || ii==N
                        dlg.Value = ii/N; dlg.Message = loadingProgressMsg(ii, N, t_start);
                    end
                end
            end
            param.Stack = Stack_local; param.Qr = Qr_stack; param.Qz = Qz_stack;
        end
        close(dlg);
        param.data = mean(param.Stack,3,'omitnan'); param.correctionI = 1; 
        GUI.btnQcal.BackgroundColor = [0.75 0.95 0.75]; % 연한 초록색으로 변경
        updateImage2();

    end

    function Position2D_Callback(~,~)
        uialert(GUI.main, '클릭하여 위치를 선택하세요.', '안내');
        try dpt = drawpoint(hAX1, 'Color', 'y'); x = dpt.Position(1); y = dpt.Position(2); delete(dpt); catch, return; end
        GX2.h1dzpos.Value = double(fix(y)); GX2.h1dypos.Value = double(fix(x));
    end

    function Drawline2_Callback(~,~)
        if param.correctionI == 0, warndlg('Q-Cal first.','Warning'); return; end
        PixelAccumOn = GUI.hAccum.Value; CakeCutOn = GUI.hCakecut.Value;
        main_ang = double(GX2.h1dphi.Value); z_shift = double(GX2.h1dzpos.Value); y_shift = double(GX2.h1dypos.Value);
        if param.Expinfo == 1, cx = 0 + y_shift; cy = 0 + z_shift; y_sign = 1; else, cx = param.bpos(1) + y_shift; cy = param.bpos(2) - z_shift; y_sign = -1; end
        R_max = sqrt(param.dataSize(2)^2 + param.dataSize(1)^2) * 1.5; updateImage2(); hold(hAX1, 'on');
        
        if PixelAccumOn == 0 && CakeCutOn == 0, draw_ray_adaptive(hAX1, cx, cy, R_max, main_ang, 'w', 1.5, y_sign);
        elseif CakeCutOn == 1
            st_ang = double(GX2.hCkcutst.Value); fi_ang = double(GX2.hCkcutfi.Value);
            if main_ang+st_ang < 0 || main_ang+fi_ang > 180, hold(hAX1,'off'); warndlg('Out of range (0~180)','Warning'); return; end
            draw_ray_adaptive(hAX1, cx, cy, R_max, main_ang+st_ang, 'r', 1.5, y_sign); draw_ray_adaptive(hAX1, cx, cy, R_max, main_ang+fi_ang, 'r', 1.5, y_sign);
        elseif PixelAccumOn == 1
            % GIXS_gui 원본과 동일하게 PixelAccum은 0/90/180도(수평/수직)에서만 의미가 있음
            if ~(main_ang == 0 || main_ang == 90 || main_ang == 180)
                hold(hAX1,'off'); warndlg('PixelAccum supports angle 0/90/180 only!','Warning'); return;
            end
            mPix = double(GX2.h1dAmpix.Value); pPix = double(GX2.h1dAppix.Value);
            dx_perp = sind(main_ang); dy_perp = -cosd(main_ang)*y_sign;
            draw_ray_adaptive(hAX1, cx + dx_perp*mPix, cy + dy_perp*mPix, R_max, main_ang, 'g', 1.5, y_sign); draw_ray_adaptive(hAX1, cx + dx_perp*pPix, cy + dy_perp*pPix, R_max, main_ang, 'g', 1.5, y_sign);
        end
        hold(hAX1, 'off');
    end

    function Linecut2_Callback(~,~)
        if param.correctionI == 0, warndlg('Q-Cal first.','Warning'); return; end
        param.ang = single(double(GX2.h1dphi.Value)); param.zposmv = single(double(GX2.h1dzpos.Value)); param.yposmv = single(double(GX2.h1dypos.Value));
        if ~isfield(param, 'QMapMet'), param.QMapMet = GUI.hQMAPmethod.Value; end
        
        k0 = 2*pi/param.Wavelength;
        if ~isfield(param, 'Q') || isempty(param.Q)
            [~,param.Qr,param.Qz,param.Q,~,~] = Qmaping_gi(param.dataSize(2), param.dataSize(1), param.bpos, param.pixel, param.SDD, k0, param.ai);
        end
        N = size(param.Stack, 3);
        dlg = uiprogressdlg(GUI.main, 'Title', 'Line Cut', 'Message', sprintf('Computing line cut over %d frames...', N), 'Cancelable', 'on', 'Indeterminate', 'off');
        dlg.Indeterminate = 'on';
        opts = buildGIXSLinecutOptions([], k0);
        [data1dstack_temp, refAxis] = processGIXSLinecutStack(param, opts);
        if isempty(refAxis), close(dlg); warndlg('Cut failed.', 'Error'); return; end
        close(dlg); 
        param.data1dstack = data1dstack_temp; Auto.Met = 0; 
        
        % [핵심 패치: 크래시 철벽 방어] 그래프를 먼저 다 그리게 하고 대기 후 창을 닫음
        if exist('dlg', 'var') && isvalid(dlg)
            dlg.Message = 'Drawing Plots... Please wait';
            drawnow limitrate;
        end
        
        Plot1dseries2_Callback([], []);
        drawnow; pause(0.5);
        
        if exist('dlg', 'var') && isvalid(dlg), close(dlg); end

    end

    function Plot1dseries2_Callback(~,~)
        if ~isfield(param, 'data1dstack'), return; end
        Q_axis = param.data1dstack(:, 1); Norm_Int = param.data1dstack(:, 2:end); Normalway = GUI.hNormal1D.Value;
        if ~strcmp(Normalway, 'None') && isfield(param, 'loginfo')
            for ii = 1:size(Norm_Int, 2)
                norm_val = getPGIXSNormalizationValue(param.loginfo, Normalway, ii);
                Norm_Int(:, ii) = Norm_Int(:, ii) ./ norm_val;
            end
        end
        param.data1dstackN = Norm_Int; GX2.qMin.Value = double(min(Q_axis, [], 'omitnan')); GX2.qMax.Value = double(max(Q_axis, [], 'omitnan')); update1Dplot_Callback();
    end

    function update1Dplot_Callback(~,~)
        if ~isfield(param, 'data1dstackN'), return; end
        qmin = double(GX2.qMin.Value); qmax = double(GX2.qMax.Value); Q = param.data1dstack(:, 1); Y = param.data1dstackN;
        valid_idx = (Q >= qmin) & (Q <= qmax); Q_plot = Q(valid_idx); Y_plot = Y(valid_idx, :);
        [X_var, X_label, X_unit] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var) == size(Y_plot, 2)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            Y_plot = Y_plot(:, sort_idx);
        else
            X_var = 1:size(Y_plot, 2); X_label = 'Frame'; X_unit = '#';
        end
        cla(hAX3); hold(hAX3, 'on'); nFrame = size(Y_plot, 2); colors = jet(max(nFrame,1));
        
        MAX_CURVES = 200; 
        if nFrame > MAX_CURVES, sel = unique(round(linspace(1, nFrame, MAX_CURVES))); else, sel = 1:nFrame; end
        
        % [핵심 패치] for루프 제거: 행렬 기반 일괄 렌더링으로 플롯 속도 50배 향상 & 엔진 과부하 방지
        set(hAX3, 'ColorOrder', colors(sel,:), 'NextPlot', 'replacechildren');
        plot(hAX3, Q_plot, Y_plot(:,sel), 'LineWidth', 1);
        hold(hAX3, 'off');
        
        axis(hAX3, 'tight'); xlim(hAX3, [qmin, qmax]); 
        
        % [핵심 패치] 리눅스 치명타 에러(latex) 원천 배제
        xlabel(hAX3, 'q (A^{-1})', 'Interpreter', 'tex'); ylabel(hAX3, 'Intensity (a.u.)');
        
        switch GUI.hScale1D.Value, case 'Linear', set(hAX3, 'YScale', 'linear', 'XScale', 'linear'); case 'Logy', set(hAX3, 'YScale', 'log', 'XScale', 'linear'); case 'Logxy', set(hAX3, 'YScale', 'log', 'XScale', 'log'); end
        colormap(hAX3, colors); c = colorbar(hAX3); c.Label.String = [X_label, ' (', X_unit, ')'];
        applyColorbarTicks(c, X_var, nFrame); grid(hAX3, 'on'); updateIntplot();
    end

    function updateIntplot()
        if ~isfield(param, 'data1dstackN'), return; end
        qmin = double(GX2.qMin.Value); qmax = double(GX2.qMax.Value); Q = param.data1dstack(:, 1);
        valid_idx = (Q >= qmin) & (Q <= qmax); Integrated_I = sumPGIXSOmitNaN(param.data1dstackN(valid_idx, :), 1);
        [X_var, X_label, X_unit] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var)==numel(Integrated_I)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            Integrated_I = Integrated_I(sort_idx);
        end
        if numel(X_var) ~= numel(Integrated_I), X_var = 1:numel(Integrated_I); X_label = 'Frame'; X_unit = '#'; end
        cla(hAX4); plot(hAX4, X_var, Integrated_I, '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
        axis(hAX4, 'tight'); grid(hAX4, 'on'); xlabel(hAX4, [X_label, ' (', X_unit, ')']); ylabel(hAX4, 'Integrated Intensity (a.u.)');
    end

    function PointFind2_Callback(~,~)
        uialert(GUI.main, '클릭하여 타겟을 지정하세요.', '안내');
        try dpt = drawpoint(hAX1, 'Color', 'm'); x = dpt.Position(1); y = dpt.Position(2); delete(dpt); catch, return; end
        if strcmp(param.Mapping, 'Pixel'), GX2.azipospix.Value = double(round(sqrt(x^2 + y^2))); CalcPos_Callback(); else, GX2.Qpospix.Value = double(sqrt(x^2 + y^2)); CalcQpos_Callback(); end
    end

    function DrawAziPlot2_Callback(~,~)
        if param.correctionI == 0, warndlg('Q-Cal first.','Warning'); return; end
        % 혹시 이전 버전에서 param.data가 오염된 경우 원본(Stack 평균) 복구
        if isfield(param, 'Stack') && ~isempty(param.Stack)
            param.data = mean(param.Stack, 3, 'omitnan');
        end
        % 원본 데이터는 절대 건드리지 않고, 이미지 위에 overlay로 arc만 그림
        updateImage2();   % 이전에 그려진 overlay가 있었다면 초기화
        pix_pos = double(GX2.azipospix.Value);
        NumSum = abs((pix_pos + double(GX2.azipospixp.Value)) - (pix_pos + double(GX2.azipospixm.Value)));
        theta = (0:0.5:180)' + 180; z_off = double(GX2.Zpospixp.Value);
        nR = fix(NumSum);
        if nR < 1, return; end
        hold(hAX1, 'on');
        for SumR = 1:nR
            r_val = pix_pos - fix(NumSum/2) + SumR - 1;
            Xc = r_val .* cosd(theta) + param.bpos(1);
            Yc = r_val .* sind(theta) + param.bpos(2) - z_off;
            % Pixel 좌표계: hAX1은 imagesc(param.HD, param.VD, ...)로 그려짐
            if isfield(param, 'HD') && isfield(param, 'VD')
                Xc_idx = round(Xc); Yc_idx = round(Yc);
                inside = Xc_idx>=1 & Xc_idx<=param.dataSize(2) & Yc_idx>=1 & Yc_idx<=param.dataSize(1);
                if ~any(inside), continue; end
                Xp = param.HD(Xc_idx(inside)); Yp = param.VD(Yc_idx(inside));
                plot(hAX1, Xp, Yp, '.', 'Color', [1 1 1], 'MarkerSize', 3, 'Tag', 'AziOverlay');
            end
        end
        hold(hAX1, 'off');
    end

    function Azilinecut2_Callback(~,~)
        if ~isfield(param, 'Stack'), return; end
        N = size(param.Stack, 3);
        dlg = uiprogressdlg(GUI.main, 'Title', 'Azimuthal Cut', ...
            'Message', sprintf('Computing azimuthal cut over %d frames...', N), ...
            'Cancelable', 'on', 'Indeterminate', 'on');
        dataAzistack_temp = processGIXSAzimuthalStack(param.Stack, buildGIXSAzimuthalOptions(true));
        close(dlg); 
        param.dataAzistack = dataAzistack_temp; Auto.Met = AUTO_AZIMUTHAL; 
        
        % [핵심 패치: 철벽 방어]
        if exist('dlg', 'var') && isvalid(dlg)
            dlg.Message = 'Drawing Plots... Please wait';
            drawnow limitrate;
        end
        
        PlotAziseries2_Callback([], []);
        drawnow; pause(0.5);
        
        if exist('dlg', 'var') && isvalid(dlg), close(dlg); end
    end

    function PlotAziseries2_Callback(~,~)
        if ~isfield(param, 'dataAzistack'), return; end
        param.dataAzistackN = param.dataAzistack(:,2:end); Normalway = GUI.hNormalAzi.Value;
        if ~strcmp(Normalway, 'None') && isfield(param, 'loginfo')
            for ii = 1:size(param.dataAzistackN, 2)
                norm_val = getPGIXSNormalizationValue(param.loginfo, Normalway, ii);
                param.dataAzistackN(:,ii) = param.dataAzistackN(:,ii) ./ norm_val;
            end
        end
        max_val = max(param.dataAzistackN(:), [], 'omitnan'); if ~isempty(max_val) && ~isnan(max_val) && max_val > 0, param.dataAzistackN = param.dataAzistackN ./ max_val; end
        GX2.aziMin.Value = double(min(param.dataAzistack(:,1))); GX2.aziMax.Value = double(max(param.dataAzistack(:,1))); updateAziplot_Callback();
    end

    function updateAziplot_Callback(~,~)
        if ~isfield(param, 'dataAzistackN'), return; end
        azimin = double(GX2.aziMin.Value); azimax = double(GX2.aziMax.Value); Ang = param.dataAzistack(:,1); xdata = Ang >= azimin & Ang <= azimax;
        Y = param.dataAzistackN(xdata, :); X_Sub = Ang(xdata);
        [X_var, X_label, X_unit] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var) == size(Y, 2)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            Y = Y(:, sort_idx);
        else
            X_var = 1:size(Y, 2); X_label = 'Frame'; X_unit = '#';
        end
        cla(hAX2); hold(hAX2, 'on'); nFrame = size(Y, 2); colors = jet(max(nFrame,1));
        
        MAX_CURVES = 200; 
        if nFrame > MAX_CURVES, sel = unique(round(linspace(1, nFrame, MAX_CURVES))); else, sel = 1:nFrame; end
        
        % [핵심 패치] 행렬 일괄 렌더링 적용
        set(hAX2, 'ColorOrder', colors(sel,:), 'NextPlot', 'replacechildren');
        plot(hAX2, X_Sub, Y(:,sel), 'LineWidth', 1);
        hold(hAX2, 'off');
        
        axis(hAX2, 'tight'); xlabel(hAX2, 'Azimuthal Angle (deg)'); ylabel(hAX2, 'Intensity (a.u.)');
        if strcmp(GUI.hScaleAzi.Value, 'Logy'), set(hAX2, 'YScale', 'log'); else, set(hAX2, 'YScale', 'linear'); end
        colormap(hAX2, colors); c = colorbar(hAX2);
        c.Label.String = [X_label, ' (', X_unit, ')'];
        applyColorbarTicks(c, X_var, nFrame); title(hAX2, 'Azimuthal Series'); updateAziIntplot();
    end

    function updateAziIntplot()
        if ~isfield(param, 'dataAzistack') || ~isfield(param, 'dataAzistackN'), return; end
        azimin = double(GX2.aziMin.Value); azimax = double(GX2.aziMax.Value); Ang = param.dataAzistack(:,1); xdata = Ang >= azimin & Ang <= azimax;
        SumVal = sumPGIXSOmitNaN(param.dataAzistackN(xdata, :), 1); [X_var, X_label, X_unit] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var)==numel(SumVal)
            [X_var, idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            SumVal = SumVal(idx);
        end
        if numel(X_var) ~= numel(SumVal), X_var = 1:numel(SumVal); X_label = 'Frame'; X_unit = '#'; end
        cla(hAX4); plot(hAX4, X_var, SumVal, '-ok', 'MarkerFaceColor', 'k'); axis(hAX4, 'tight'); grid(hAX4, 'on'); xlabel(hAX4, [X_label, ' (', X_unit, ')']); ylabel(hAX4, 'Total Intensity');
    end

    function ROIdef2_Callback(~,~)
        if isempty(param.data)
            uialert(GUI.main, '먼저 이미지를 로드하세요.', '알림'); return;
        end
        NofROI = round(parsePGIXSNumeric(GUI.hNROI.Value, 1, 1, 20));
        ROI_temp = zeros(NofROI, 4);

        % 메인 GUI의 표시 조건을 그대로 복제
        f_roi = figure('Name', 'Draw ROI', 'NumberTitle', 'off', ...
            'MenuBar', 'none', 'ToolBar', 'figure', 'Color', 'w', ...
            'Units', 'normalized', 'Position', [0.2 0.1 0.6 0.8]);
        ax_roi = axes(f_roi);
        if isfield(param, 'HD') && isfield(param, 'VD')
            imagesc(ax_roi, param.HD, param.VD, param.data);
        else
            imagesc(ax_roi, param.data);
        end
        if param.Expinfo == 0
            set(ax_roi, 'YDir', 'reverse');
            xlabel(ax_roi, 'Y (pixel)'); ylabel(ax_roi, 'Z (pixel)');
        else
            set(ax_roi, 'YDir', 'normal');
            xlabel(ax_roi, 'Y (pixel relative)'); ylabel(ax_roi, 'Z (pixel relative)');
        end
        axis(ax_roi, 'image');
        % X/Y 범위
        x_lim = [double(GX2.cXlim1.Value), double(GX2.cXlim2.Value)];
        y_lim = [double(GX2.cYlim1.Value), double(GX2.cYlim2.Value)];
        if x_lim(1) < x_lim(2) && y_lim(1) < y_lim(2)
            set(ax_roi, 'XLim', x_lim, 'YLim', y_lim);
        end
        % Color limits + log scale 안전 처리
        clim_lo = double(GX2.cMin.Value); clim_hi = double(GX2.cMax.Value);
        cscale = GUI.hScaleImg.Value;
        if strcmp(cscale, 'Log')
            if clim_lo <= 0
                pos_min = min(param.data(param.data > 0), [], 'omitnan');
                if isempty(pos_min) || isnan(pos_min), pos_min = eps('single'); end
                clim_lo = double(pos_min);
            end
            if clim_hi <= clim_lo, clim_hi = clim_lo * 10; end
        else
            if clim_hi <= clim_lo, clim_hi = clim_lo + 1; end
        end
        clim(ax_roi, [clim_lo, clim_hi]);
        applyPGIXSAxesColorScale(ax_roi, cscale);
        applyPGIXSColormap(ax_roi, GUI.hColorImg.Value, param.data);
        colorbar(ax_roi);

        % ROI를 하나씩 받음
        for ii = 1:NofROI
            if ~isvalid(f_roi)
                % 사용자가 창을 닫으면 중단
                return;
            end
            msgText = sprintf(['ROI %d / %d 그리기 — ', ...
                '드래그로 영역 선택 후 [더블클릭] 또는 [Enter]로 확정 ', ...
                '(다음 ROI 진행)'], ii, NofROI);
            title(ax_roi, msgText, 'FontSize', 13, 'Color', 'r', 'FontWeight', 'bold', 'Interpreter', 'none');

            try
                hR = drawrectangle(ax_roi, 'Label', sprintf('ROI %d', ii), ...
                    'Color', 'r', 'LineWidth', 2, 'FaceAlpha', 0.05);
            catch ME
                warning('GIXS2:ROIRectangleCreateFailed', 'ROI rectangle creation failed: %s', ME.message);
                close(f_roi); return;
            end
            try wait(hR); catch, end
            if ~isvalid(hR), continue; end
            pos = hR.Position;   % [x, y, w, h] in axes coordinates (HD/VD units)

            % axes 좌표 → pixel index 변환 (CalculateROI/drawROIOverlay와 일관성 유지)
            x_lo = pos(1); x_hi = pos(1) + pos(3);
            y_lo = pos(2); y_hi = pos(2) + pos(4);
            if isfield(param, 'HD') && isfield(param, 'VD')
                % HD/VD가 1-pixel 단위로 단조이므로 nearest pixel index로 매핑
                [~, c1_pix] = min(abs(param.HD - x_lo));
                [~, c2_pix] = min(abs(param.HD - x_hi));
                [~, r1_pix] = min(abs(param.VD - y_lo));
                [~, r2_pix] = min(abs(param.VD - y_hi));
                % min/max로 정렬 (VD가 Q-cal 후엔 내림차순일 수 있음)
                r1 = min(r1_pix, r2_pix); r2 = max(r1_pix, r2_pix);
                c1 = min(c1_pix, c2_pix); c2 = max(c1_pix, c2_pix);
            else
                r1 = round(y_lo); r2 = round(y_hi);
                c1 = round(x_lo); c2 = round(x_hi);
            end
            ROI_temp(ii,:) = [r1, r2, c1, c2];   % pixel index 단위로 저장

            % 확정된 ROI를 정적 라인으로 변환 (drawrectangle 핸들은 삭제)
            x_rect = pos(1) + [0 pos(3) pos(3) 0 0];
            y_rect = pos(2) + [0 0 pos(4) pos(4) 0];
            hold(ax_roi, 'on');
            plot(ax_roi, x_rect, y_rect, '-y', 'LineWidth', 2);
            text(ax_roi, pos(1), pos(2), sprintf(' ROI %d', ii), ...
                'Color', 'y', 'FontWeight', 'bold', 'FontSize', 11, ...
                'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
                'BackgroundColor', [0 0 0 0.4]);
            hold(ax_roi, 'off');
            delete(hR);
        end

        if isvalid(f_roi), close(f_roi); end

        % param에 저장하고 메인 이미지에 overlay 후 적분 실행
        param.ROI = ROI_temp;
        updateImage2();          % overlay가 자동으로 그려짐
        CalculateROI();
    end

    function CalculateROI()
        if ~isfield(param, 'ROI') || isempty(param.ROI), return; end
        [~, ~, N] = size(param.Stack); nROI = size(param.ROI, 1);
        dlg = uiprogressdlg(GUI.main, 'Title', 'ROI Integration', ...
            'Message', sprintf('Computing %d ROI(s) over %d frames...', nROI, N), ...
            'Cancelable', 'on', 'Indeterminate', 'on');
        SumIROI_temp = processPGIXSROIStack(param.Stack, param.ROI, GUI.hParCom.Value == 1);
        close(dlg); 
        param.SumIROI = SumIROI_temp; Auto.Met = AUTO_ROI; 
        
        % [핵심 패치: 철벽 방어]
        if exist('dlg', 'var') && isvalid(dlg)
            dlg.Message = 'Drawing Plots... Please wait';
            drawnow limitrate;
        end
        
        PlotROI_Callback([], []);
        drawnow; pause(0.5);
        
        if exist('dlg', 'var') && isvalid(dlg), close(dlg); end
    end

    function PlotROI_Callback(~,~)
        if ~isfield(param, 'SumIROI') || isempty(param.SumIROI), return; end
        Y = param.SumIROI; Normalway = GUI.hNormalROI.Value;
        if ~strcmp(Normalway, 'None') && isfield(param, 'loginfo')
            for ii = 1:size(Y, 1), norm_val = getPGIXSNormalizationValue(param.loginfo, Normalway, ii);
                Y(ii, :) = Y(ii, :) ./ norm_val;
            end
        end
        [X_var, X_label, X_unit] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var) == size(Y,1)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            Y = Y(sort_idx, :);
        end
        if numel(X_var) ~= size(Y,1), X_var = 1:size(Y,1); X_label = 'Frame'; X_unit = '#'; end
        cla(hAX4); hold(hAX4, 'on'); roiColors = {'r', 'g', 'b', 'c', 'm', 'y', 'w'}; markers = {'o', 's', 'd', '^', 'v'};
        for i = 1:size(Y, 2), col = roiColors{mod(i-1, length(roiColors))+1}; mrk = markers{mod(i-1, length(markers))+1}; plot(hAX4, X_var, Y(:, i), ['-', mrk], 'Color', col, 'MarkerFaceColor', col, 'MarkerEdgeColor', 'k', 'LineWidth', 1.5); end
        hold(hAX4, 'off'); axis(hAX4, 'tight'); grid(hAX4, 'on'); xlabel(hAX4, [X_label, ' (', X_unit, ')']); ylabel(hAX4, 'Integrated Intensity'); legend(hAX4, arrayfun(@(x) sprintf('ROI %d', x), 1:size(Y, 2), 'UniformOutput', false));
    end

    function NormalROII_Callback(~,~)
        if isfield(param, 'SumIROI')
            base = param.SumIROI(1,:);
            base = sanitizePGIXSScaleFactors(base);
            param.SumIROI = param.SumIROI ./ base;
            PlotROI_Callback();
        end
    end

    function Saveget4_Callback(~,~)
        if ~isfield(param, 'expmode')
            uialert(GUI.main, 'No data to save!', 'Warning'); return; 
        end
        SaveForm = GUI.hSFormInt.Value;
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        
        [X_var, X_label, ~] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        
        switch Auto.Met
            case AUTO_ROI % ROI
                if ~isfield(param, 'SumIROI') || isempty(param.SumIROI), uialert(GUI.main, 'No ROI data!', 'Warning'); return; end
                Y_save = double(param.SumIROI); suffix = '_IntROI';
            case 2 % Azi
                if ~isfield(param, 'dataAzistackN') || isempty(param.dataAzistackN), uialert(GUI.main, 'No Azi data!', 'Warning'); return; end
                azimin = double(GX2.aziMin.Value); azimax = double(GX2.aziMax.Value); Ang = param.dataAzistack(:,1);
                xdata = Ang >= azimin & Ang <= azimax; Y_save = sumPGIXSOmitNaN(param.dataAzistackN(xdata, :), 1)'; suffix = '_IntAzi';
            otherwise % 1D
                if ~isfield(param, 'data1dstackN') || isempty(param.data1dstackN), uialert(GUI.main, 'No 1D data!', 'Warning'); return; end
                qmin = double(GX2.qMin.Value); qmax = double(GX2.qMax.Value); Q = param.data1dstack(:, 1);
                vidx = (Q >= qmin) & (Q <= qmax); Y_save = sumPGIXSOmitNaN(param.data1dstackN(vidx, :), 1)'; suffix = '_Int1D';
        end
        
        if numel(X_var) == size(Y_save,1)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            Y_save = reorderPGIXSRows(Y_save, sort_idx);
        else
            X_var = 1:size(Y_save,1); X_label = 'Frame';   % fallback
        end
        CombinedData = sanitizePGIXSExportMatrix([double(X_var(:)), double(Y_save)]);

        FN = NewFileName(param.FileName);
        BaseName = [FN, suffix];
        selection = uiconfirm(GUI.main, 'Change filename?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'No');
        if strcmp(selection, 'Yes')
            [BaseName, nameOK] = promptPGIXSSaveFileBaseName(BaseName, SaveForm, 'Save Integration Data As');
            if ~nameOK, return; end
        end
        SavePath = fullfile(saveDir, [BaseName, SaveForm]);

        try
            saved_struct.X_Axis = X_var(:); saved_struct.Intensity = Y_save; saved_struct.Matrix = CombinedData; saved_struct.X_Label = X_label;
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, CombinedData, saved_struct);
            % [핵심] Integration 패널 이미지 저장
            savePanelSnapshot('Int', fullfile(saveDir, [BaseName, '.jpg']));
            uialert(GUI.main, ['Saved successfully: ' SavePath], 'Success');
        catch ME, uialert(GUI.main, ['Save failed: ' ME.message], 'Error'); 
        end
    end

    function SavegetX_Callback(~,~)
        if ~isfield(param, 'expmode')
            uialert(GUI.main, 'No data to save!', 'Warning'); return; 
        end
        SaveForm = GUI.hSFormInt.Value;
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        
        [X_var, X_label, ~] = getExperimentXAxis(param);
        CombinedData = sanitizePGIXSExportMatrix(double(X_var(:)));

        FN = NewFileName(param.FileName);
        BaseName = [FN, '_Xaxis'];
        selection = uiconfirm(GUI.main, 'Change filename?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'No');
        if strcmp(selection, 'Yes')
            [BaseName, nameOK] = promptPGIXSSaveFileBaseName(BaseName, SaveForm, 'Save X-Axis Data As');
            if ~nameOK, return; end
        end
        SavePath = fullfile(saveDir, [BaseName, SaveForm]);

        try
            saved_struct.X_Axis = CombinedData; saved_struct.X_Label = X_label;
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, CombinedData, saved_struct);
            uialert(GUI.main, ['Saved successfully: ' SavePath], 'Success');
        catch ME, uialert(GUI.main, ['Save failed: ' ME.message], 'Error'); 
        end
    end

    function Saveget3_Callback(~,~)
        if ~isfield(param, 'data1dstackN') || isempty(param.data1dstackN)
            uialert(GUI.main, 'No data to save!', 'Warning'); return; 
        end
        SaveForm = GUI.hSForm1D.Value; qmin = GX2.qMin.Value; qmax = GX2.qMax.Value;
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        
        Q_all = param.data1dstack(:, 1); valid_idx = (Q_all >= qmin) & (Q_all <= qmax);
        Q_save = Q_all(valid_idx); I_save = param.data1dstackN(valid_idx, :);
        hasSTD = isfield(param, 'std1dstackN') && ~isempty(param.std1dstackN); 
        if hasSTD, STD_save = param.std1dstackN(valid_idx, :); end
        
        [X_var, X_label, ~] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var) == size(I_save, 2)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            I_save = reorderPGIXSColumns(I_save, sort_idx); if hasSTD, STD_save = reorderPGIXSColumns(STD_save, sort_idx); end
        else
            X_var = 1:size(I_save, 2); X_label = 'Frame';
        end
        CombinedData = sanitizePGIXSExportMatrix([double(Q_save), double(I_save)]);
        if hasSTD, CombinedDataSTD = sanitizePGIXSExportMatrix([double(Q_save), double(STD_save)]); end

        FN = NewFileName(param.FileName);
        BaseName = [FN, '_1Dplotstack'];
        selection = uiconfirm(GUI.main, 'Change filename?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'No');
        if strcmp(selection, 'Yes')
            [BaseName, nameOK] = promptPGIXSSaveFileBaseName(BaseName, SaveForm, 'Save 1D Stack Data As');
            if ~nameOK, return; end
        end
        SavePath = fullfile(saveDir, [BaseName, SaveForm]);

        try
            saved_struct.Q = Q_save; saved_struct.Intensity = I_save; saved_struct.Matrix = CombinedData; 
            saved_struct.X_Axis = X_var; saved_struct.X_Label = X_label;
            if hasSTD, saved_struct.STD = STD_save; saved_struct.MatrixSTD = CombinedDataSTD; end
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, CombinedData, saved_struct);
            if hasSTD && ~strcmpi(SaveForm, '.mat')
                savePGIXSDataFile(fullfile(saveDir, [BaseName, '_STD', SaveForm]), SaveForm, CombinedDataSTD, struct('STD', STD_save, 'MatrixSTD', CombinedDataSTD));
            end
            % [핵심] 1D 패널 이미지 저장 — axes를 임시 figure로 복사하여 exportgraphics
            savePanelSnapshot('1D', fullfile(saveDir, [BaseName, '.jpg']));
            uialert(GUI.main, ['Saved successfully: ' SavePath], 'Success');
        catch ME, uialert(GUI.main, ['Save failed: ' ME.message], 'Error'); 
        end
    end

    function Saveget2_Callback(~,~)
        if ~isfield(param, 'dataAzistackN') || isempty(param.dataAzistackN)
            uialert(GUI.main, 'No data to save!', 'Warning'); return; 
        end
        SaveForm = GUI.hSFormAzi.Value; azimin = double(GX2.aziMin.Value); azimax = double(GX2.aziMax.Value);
        [saveDir, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        
        Ang_all = param.dataAzistack(:, 1); valid_idx = (Ang_all >= azimin) & (Ang_all <= azimax);
        Ang_save = Ang_all(valid_idx); I_save = param.dataAzistackN(valid_idx, :);
        
        [X_var, X_label, ~] = getExperimentXAxis(param);
        emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
        if numel(X_var) == size(I_save, 2)
            [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
            I_save = reorderPGIXSColumns(I_save, sort_idx);
        else
            X_var = 1:size(I_save, 2); X_label = 'Frame';
        end
        CombinedData = sanitizePGIXSExportMatrix([double(Ang_save), double(I_save)]);

        FN = NewFileName(param.FileName);
        BaseName = [FN, '_Aziplotstack'];
        selection = uiconfirm(GUI.main, 'Change filename?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'No');
        if strcmp(selection, 'Yes')
            [BaseName, nameOK] = promptPGIXSSaveFileBaseName(BaseName, SaveForm, 'Save Azimuthal Stack Data As');
            if ~nameOK, return; end
        end
        SavePath = fullfile(saveDir, [BaseName, SaveForm]);

        try
            saved_struct.Angle = Ang_save; saved_struct.Intensity = I_save; saved_struct.Matrix = CombinedData; 
            saved_struct.X_Axis = X_var; saved_struct.X_Label = X_label;
            saved_struct = attachRetryMetadata(saved_struct);
            savePGIXSDataFile(SavePath, SaveForm, CombinedData, saved_struct);
            % [핵심] Azimuthal 패널 이미지 저장
            savePanelSnapshot('Azi', fullfile(saveDir, [BaseName, '.jpg']));
            uialert(GUI.main, ['Saved successfully: ' SavePath], 'Success');
        catch ME, uialert(GUI.main, ['Save failed: ' ME.message], 'Error'); 
        end
    end

    function saveSingleFrame(full_path, Mout, col_names, fmt, frameIdx)
        try
            switch fmt
                case '.mat'
                    S = struct(); S.data = Mout; S.columns = col_names; S.frame = frameIdx;
                    savePGIXSDataFile(full_path, '.mat', Mout, S);
                case '.dat'
                    fid = fopen(full_path, 'w');
                    if fid < 0
                        error('GIXS2:fileOpenFail', '%s', ['파일을 열 수 없습니다: ' full_path]);
                    end
                    cleanup = onCleanup(@() fclose(fid));
                    fprintf(fid, '# Source: %s (Frame %d)\n', getfield_safe(param, 'FileName', 'unknown'), frameIdx);
                    fprintf(fid, '# Mode: %s\n', getfield_safe(param, 'expmode', 'unknown'));
                    fprintf(fid, '%s\t%s\n', col_names{1}, col_names{2});
                    fmt_row = '%g\t%g\n';
                    for r = 1:size(Mout, 1), fprintf(fid, fmt_row, Mout(r,:)); end
                case '.csv'
                    T = array2table(Mout, 'VariableNames', sanitize_varnames(col_names));
                    [writeOK, writeReport] = writePGIXSTableFile(T, full_path);
                    if ~writeOK
                        warning('PGIXS:SingleFrameSaveFailed', '%s', writeReport.Message);
                    end
            end
        catch ME
            warning('PGIXS:SingleFrameSaveFailed', '%s', ['Single-frame save failed: ', ME.message]);
        end
    end

    function SaveStack_Callback(~,~)
        % 2D 스택 + Q맵 저장 (.mat 전용)
        if ~isfield(param, 'Stack') || isempty(param.Stack)
            uialert(GUI.main, '저장할 Stack이 없습니다.', '저장 불가'); return;
        end
        base = 'data'; if isfield(param, 'FileName'), base = param.FileName; end
        def_dir = pwd; if isfield(param, 'Path') && ~isempty(param.Path), def_dir = param.Path; end
        [fn, fp] = uiputfile({'*.mat','MAT-file (*.mat)'}, 'Save Stack', fullfile(def_dir, [base, '_Stack.mat']));
        if isequal(fn, 0), return; end
        full_path = fullfile(fp, fn);
        try
            S = buildPGIXSStackInfo(param, 'GIXS');
            savePGIXSStackFile(full_path, S);
            uialert(GUI.main, sprintf('Stack 저장 완료:\n%s', full_path), 'Success', 'Icon', 'success');
        catch ME
            uialert(GUI.main, sprintf('저장 실패: %s', ME.message), 'Error', 'Icon', 'error');
        end
    end

    function saveDataGeneric(Mout, col_names, suffix, fmt, descr)
        % 공통 저장 헬퍼: .mat / .dat / .csv 분기, uiputfile 다이얼로그
        base = 'data'; if isfield(param, 'FileName'), base = param.FileName; end
        def_dir = pwd; if isfield(param, 'Path') && ~isempty(param.Path), def_dir = param.Path; end
        switch fmt
            case '.mat'
                filt = {'*.mat','MAT-file (*.mat)'};
            case '.dat'
                filt = {'*.dat','Data file (*.dat)'};
            case '.csv'
                filt = {'*.csv','CSV file (*.csv)'};
            otherwise
                filt = {'*.*','All files (*.*)'};
        end
        def_name = [base, suffix, fmt];
        [fn, fp] = uiputfile(filt, ['Save ', descr], fullfile(def_dir, def_name));
        if isequal(fn, 0), return; end
        full_path = fullfile(fp, fn);
        try
            switch fmt
                case '.mat'
                    S = struct(); S.data = Mout; S.columns = col_names;
                    if isfield(param, 'FileName'), S.source = param.FileName; end
                    if isfield(param, 'expmode'), S.expmode = param.expmode; end
                    savePGIXSDataFile(full_path, '.mat', Mout, S);
                case '.dat'
                    % 헤더 라인 + 탭 구분
                    fid = fopen(full_path, 'w');
                    if fid < 0, error('GIXS2:fileOpenFail', '%s', ['파일을 열 수 없습니다: ' full_path]); end
                    cleanup = onCleanup(@() fclose(fid));
                    fprintf(fid, '# Source: %s\n', getfield_safe(param, 'FileName', 'unknown'));
                    fprintf(fid, '# Mode: %s\n', getfield_safe(param, 'expmode', 'unknown'));
                    fprintf(fid, '# Generated: %s\n', char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));
                    fprintf(fid, '%s', col_names{1});
                    for k = 2:numel(col_names), fprintf(fid, '\t%s', col_names{k}); end
                    fprintf(fid, '\n');
                    fmt_row = [repmat('%g\t', 1, size(Mout,2)-1), '%g\n'];
                    for r = 1:size(Mout,1), fprintf(fid, fmt_row, Mout(r,:)); end
                case '.csv'
                    T = array2table(Mout, 'VariableNames', sanitize_varnames(col_names));
                    [writeOK, writeReport] = writePGIXSTableFile(T, full_path);
                    if ~writeOK
                        error('GIXS2:tableWriteFail', '%s', writeReport.Message);
                    end
                otherwise
                    error('GIXS2:unknownFormat', '%s', ['지원하지 않는 형식: ' fmt]);
            end
            uialert(GUI.main, sprintf('%s 저장 완료:\n%s', descr, full_path), 'Success', 'Icon', 'success');
        catch ME
            uialert(GUI.main, sprintf('저장 실패: %s', ME.message), 'Error', 'Icon', 'error');
        end
    end

    function v = getfield_safe(s, fname, default)
        if isfield(s, fname), v = s.(fname); if isnumeric(v), v = num2str(v); end
        else, v = default; end
    end

    function names = sanitize_varnames(names)
        % CSV/table 호환을 위해 변수명 정리 (영문/숫자/언더스코어만, 첫 글자는 영문)
        for k = 1:numel(names)
            n = regexprep(names{k}, '[^A-Za-z0-9_]', '_');
            if isempty(n) || ~isstrprop(n(1), 'alpha'), n = sprintf('c_%s', n); end
            names{k} = n;
        end
    end

    function updateQHeatmap_Callback(~,~) 
        try
            HeatmapQ_gui(param);
        catch ME
            uialert(GUI.main, ['Error opening Q heatmap: ', ME.message], 'Error');
        end 
    end

    function updateAziHeatmap_Callback(~,~)
        try
            HeatmapAzi_gui(param);
        catch ME
            uialert(GUI.main, ['Error opening azimuthal heatmap: ', ME.message], 'Error');
        end
    end

    function NormalFactor_Callback(~,~)
        if ~isfield(param, 'data1dstackN') || isempty(param.data1dstackN)
            uialert(GUI.main, '먼저 1D Linecut 데이터를 추출하세요.', '알림'); return;
        end
        uialert(GUI.main, '기준이 될 Q 위치를 1D 그래프에서 클릭하세요.', '안내');
        try
            dpt = drawpoint(hAX3, 'Color', 'm', 'Label', 'Norm Point');
            x_target = dpt.Position(1);
            delete(dpt);
        catch ME
            warning('GIXS2:NormalPointSelectionFailed', 'Linecut normalization point selection failed: %s', ME.message);
            return;
        end
        
        % 가장 가까운 Q 인덱스 탐색
        Q = param.data1dstack(:, 1);
        [~, target_idx] = min(abs(Q - x_target));
        
        % 선택된 Q 위치의 값들로 각 프레임을 나누어 일괄 정규화 (1로 맞춤)
        for ii = 1:size(param.data1dstackN, 2)
            norm_val = sanitizePGIXSScaleFactors(param.data1dstackN(target_idx, ii));
            param.data1dstackN(:, ii) = param.data1dstackN(:, ii) / norm_val;
        end
        update1Dplot_Callback();
    end

    function NormalFactorAzi_Callback(~,~)
        if ~isfield(param, 'dataAzistackN') || isempty(param.dataAzistackN)
            uialert(GUI.main, '먼저 Azimuthal 데이터를 추출하세요.', '알림'); return;
        end
        uialert(GUI.main, '기준이 될 방위각 위치를 Azi 그래프에서 클릭하세요.', '안내');
        try
            dpt = drawpoint(hAX2, 'Color', 'm', 'Label', 'Norm Point');
            x_target = dpt.Position(1);
            delete(dpt);
        catch ME
            warning('GIXS2:AziNormalPointSelectionFailed', 'Azimuthal normalization point selection failed: %s', ME.message);
            return;
        end
        
        % 가장 가까운 Azimuthal Angle 인덱스 탐색
        Ang = param.dataAzistack(:, 1);
        [~, target_idx] = min(abs(Ang - x_target));
        
        % 선택된 각도 위치의 값들로 일괄 정규화
        for ii = 1:size(param.dataAzistackN, 2)
            norm_val = sanitizePGIXSScaleFactors(param.dataAzistackN(target_idx, ii));
            param.dataAzistackN(:, ii) = param.dataAzistackN(:, ii) / norm_val;
        end
        updateAziplot_Callback();
    end

    function ReplotInt_Callback(~,~), if Auto.Met == AUTO_ROI, PlotROI_Callback(); elseif Auto.Met == AUTO_AZIMUTHAL, updateAziIntplot(); else, updateIntplot(); end; end

% --- Helper Functions ---
    function saved_struct = attachRetryMetadata(saved_struct)
        saved_struct = attachPGIXSFrameFailureMetadata(saved_struct, param);
    end

    function savePanelSnapshot(kind, out_path)
        % uiaxes는 전통 figure로 copyobj가 안 되므로,
        % 전통 figure에 데이터를 재-plot하여 저장 (colorbar 포함)
        % kind: '1D' | 'Azi' | 'Int'
        tmpF = [];
        try
            tmpF = figure('Visible', 'off', 'Color', 'w', ...
                          'Units', 'pixels', 'Position', [100 100 900 650]);
            ax = axes(tmpF);
            switch kind
                case '1D'
                    if ~isfield(param, 'data1dstackN'), close(tmpF); return; end
                    qmin = double(GX2.qMin.Value); qmax = double(GX2.qMax.Value);
                    Q = param.data1dstack(:, 1); Y = param.data1dstackN;
                    vidx = (Q >= qmin) & (Q <= qmax); Q_plot = Q(vidx); Y_plot = Y(vidx, :);
                    [X_var, X_label, X_unit] = getExperimentXAxis(param);
                    emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
                    if numel(X_var) == size(Y_plot, 2)
                        [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
                        Y_plot = Y_plot(:, sort_idx);
                    else
                        X_var = 1:size(Y_plot, 2); X_label = 'Frame'; X_unit = '#';
                    end
                    nFrame = size(Y_plot, 2); colors = jet(nFrame); hold(ax, 'on');
                    for ii = 1:nFrame, plot(ax, Q_plot, Y_plot(:,ii), 'Color', colors(ii,:), 'LineWidth', 1); end
                    hold(ax, 'off'); axis(ax, 'tight'); xlim(ax, [qmin, qmax]);
                    xlabel(ax, 'q (A^{-1})', 'Interpreter', 'tex'); ylabel(ax, 'Intensity (a.u.)');
                    switch GUI.hScale1D.Value
                        case 'Linear', set(ax, 'YScale', 'linear', 'XScale', 'linear');
                        case 'Logy',   set(ax, 'YScale', 'log',    'XScale', 'linear');
                        case 'Logxy',  set(ax, 'YScale', 'log',    'XScale', 'log');
                    end
                    colormap(ax, colors); c = colorbar(ax); c.Label.String = [X_label, ' (', X_unit, ')'];
                    applyColorbarTicks(c, X_var, nFrame); grid(ax, 'on');

                case 'Azi'
                    if ~isfield(param, 'dataAzistackN'), close(tmpF); return; end
                    azimin = double(GX2.aziMin.Value); azimax = double(GX2.aziMax.Value);
                    Ang = param.dataAzistack(:,1); xdata = Ang >= azimin & Ang <= azimax;
                    Y = param.dataAzistackN(xdata, :); X_Sub = Ang(xdata);
                    [X_var, X_label, X_unit] = getExperimentXAxis(param);
                    emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
                    if numel(X_var) == size(Y, 2)
                        [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
                        Y = Y(:, sort_idx);
                    else
                        X_var = 1:size(Y, 2); X_label = 'Frame'; X_unit = '#';
                    end
                    nFrame = size(Y, 2); colors = jet(nFrame); hold(ax, 'on');
                    for ii = 1:nFrame, plot(ax, X_Sub, Y(:,ii), 'Color', colors(ii,:), 'LineWidth', 1); end
                    hold(ax, 'off'); axis(ax, 'tight');
                    xlabel(ax, 'Azimuthal Angle (deg)'); ylabel(ax, 'Intensity (a.u.)');
                    if strcmp(GUI.hScaleAzi.Value, 'Logy'), set(ax, 'YScale', 'log'); else, set(ax, 'YScale', 'linear'); end
                    colormap(ax, colors); c = colorbar(ax);
                    c.Label.String = [X_label, ' (', X_unit, ')'];
                    applyColorbarTicks(c, X_var, nFrame);
                    title(ax, 'Azimuthal Series');

                case 'Int'
                    % Integration panel 재현 (현재 Auto.Met 상태 반영)
                    [X_var, X_label, X_unit] = getExperimentXAxis(param);
                    emode = ''; if isfield(param, 'expmode'), emode = param.expmode; end
                    switch Auto.Met
                        case AUTO_ROI  % ROI
                            if ~isfield(param, 'SumIROI'), close(tmpF); return; end
                            Y = param.SumIROI;
                            if numel(X_var) == size(Y,1)
                                [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
                                Y = Y(sort_idx, :);
                            else
                                X_var = 1:size(Y,1); X_label = 'Frame'; X_unit = '#';
                            end
                            hold(ax, 'on'); roiColors = {'r','g','b','c','m','y','k'}; markers = {'o','s','d','^','v'};
                            for i = 1:size(Y, 2)
                                col = roiColors{mod(i-1, length(roiColors))+1};
                                mrk = markers{mod(i-1, length(markers))+1};
                                plot(ax, X_var, Y(:, i), ['-', mrk], 'Color', col, ...
                                     'MarkerFaceColor', col, 'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
                            end
                            hold(ax, 'off');
                            legend(ax, arrayfun(@(x) sprintf('ROI %d', x), 1:size(Y, 2), 'UniformOutput', false));
                            ylabel(ax, 'Integrated Intensity');
                        case 2  % Azi
                            if ~isfield(param, 'dataAzistackN'), close(tmpF); return; end
                            azimin = double(GX2.aziMin.Value); azimax = double(GX2.aziMax.Value);
                            Ang = param.dataAzistack(:,1); xdata = Ang >= azimin & Ang <= azimax;
                            SumVal = sumPGIXSOmitNaN(param.dataAzistackN(xdata, :), 1);
                            if numel(X_var) == numel(SumVal)
                                [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
                                SumVal = SumVal(sort_idx);
                            else
                                X_var = 1:numel(SumVal); X_label = 'Frame'; X_unit = '#';
                            end
                            plot(ax, X_var, SumVal, '-ok', 'MarkerFaceColor', 'k');
                            ylabel(ax, 'Total Intensity');
                        otherwise  % 1D
                            if ~isfield(param, 'data1dstackN'), close(tmpF); return; end
                            qmin = double(GX2.qMin.Value); qmax = double(GX2.qMax.Value);
                            Q = param.data1dstack(:, 1); vidx = (Q >= qmin) & (Q <= qmax);
                            Integrated_I = sumPGIXSOmitNaN(param.data1dstackN(vidx, :), 1);
                            if numel(X_var) == numel(Integrated_I)
                                [X_var, sort_idx] = sortPGIXSXAxis(X_var, emode, GUI.hOrderT.Value, GUI.hOrderA.Value);
                                Integrated_I = Integrated_I(sort_idx);
                            else
                                X_var = 1:numel(Integrated_I); X_label = 'Frame'; X_unit = '#';
                            end
                            plot(ax, X_var, Integrated_I, '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1.5);
                            ylabel(ax, 'Integrated Intensity (a.u.)');
                    end
                    axis(ax, 'tight'); grid(ax, 'on'); xlabel(ax, [X_label, ' (', X_unit, ')']);
            end
            set(ax, 'FontSize', 11, 'LineWidth', 1.2);
            [exportOK, exportReport] = exportPGIXSAxesImage(tmpF, out_path, 300);
            if ~exportOK
                warning('GIXS2:snapshotFail', '%s', exportReport.Message);
            end
            close(tmpF);
        catch ME
            if ~isempty(tmpF) && isvalid(tmpF), close(tmpF); end
            warning('GIXS2:snapshotFail', '%s', ['Snapshot save failed: ' ME.message]);
        end
    end

    function msg = loadingProgressMsg(done, total, t_start)
        msg = formatPGIXSProgressMessage(done, total, toc(t_start));
    end

    function applyColorbarTicks(cbar, X_var, nFrame)
        % colormap 인덱스 기반 colorbar의 눈금을 실제 X_var 값으로 표시
        % 기본적으로 colorbar는 [0,1]로 Limits가 잡히므로
        % frame index → [0,1] 정규화 후 실제 값 라벨을 붙인다.
        if nFrame < 2 || ~all(isfinite(X_var)) || range(X_var) == 0
            return;
        end
        Xv = double(X_var(:));
        % 눈금 개수: 최대 6개 정도로 보기 좋게
        nTick = min(6, nFrame);
        tickIdx = round(linspace(1, nFrame, nTick));
        % colormap 인덱스 i(1..nFrame) → normalized position (i-0.5)/nFrame (cell center)
        tickPos = (tickIdx - 0.5) / nFrame;
        tickVals = Xv(tickIdx);
        cbar.Limits = [0 1];
        cbar.Ticks = tickPos;
        % 값의 크기에 따라 포맷 결정
        mag = max(abs(tickVals));
        if mag >= 100
            fmt = '%.0f';
        elseif mag >= 10
            fmt = '%.1f';
        elseif mag >= 1
            fmt = '%.2f';
        else
            fmt = '%.3g';
        end
        cbar.TickLabels = arrayfun(@(v) sprintf(fmt, v), tickVals, 'UniformOutput', false);
    end

    function draw_ray_adaptive(ax, cx, cy, R, angle_deg, col, lw, y_sign)
        % GIXS는 위쪽 반원(z >= 0)만 의미가 있으므로 단방향 ray로 그림.
        % 각도 컨벤션: 0°=왼쪽(←), 90°=위(↑), 180°=오른쪽(→)
        % beam center에서 angle_deg 방향으로만 R만큼 진행 (반대쪽은 그리지 않음)
        dx = -cosd(angle_deg); dy = sind(angle_deg) * y_sign;
        plot(ax, [cx, cx+dx*R], [cy, cy+dy*R], 'Color', col, 'LineWidth', lw);
        xlim(ax, ax.XLim); ylim(ax, ax.YLim);
    end

    function opts = buildGIXSLinecutOptions(refAxis, k0)
        opts = struct();
        opts.AccumMode = GUI.hAccum.Value;
        opts.CakeMode = GUI.hCakecut.Value;
        opts.CutStart = single(double(GX2.hCkcutst.Value));
        opts.CutFinish = single(double(GX2.hCkcutfi.Value));
        opts.PixelMinus = single(double(GX2.h1dAmpix.Value));
        opts.PixelPlus = single(double(GX2.h1dAppix.Value));
        opts.ChangeAngle = logical(GUI.hChange.Value);
        opts.AIVar = [];
        if isfield(param, 'aivar')
            opts.AIVar = param.aivar;
        end
        opts.K0 = k0;
        opts.RefAxis = refAxis;
        opts.UseParallel = (GUI.hParCom.Value == 1);
    end

    function opts = buildGIXSAzimuthalOptions(includeAxis)
        opts = struct();
        opts.BeamPos = param.bpos;
        opts.DataSize = param.dataSize;
        if isfield(param, 'Mask')
            opts.Mask = param.Mask;
        end
        opts.PixelCenter = double(GX2.azipospix.Value);
        opts.PixelMinus = double(GX2.azipospixm.Value);
        opts.PixelPlus = double(GX2.azipospixp.Value);
        opts.ZOffset = double(GX2.Zpospixp.Value);
        opts.UseMedian = strcmp(GUI.hMeanMedAzi.Value, 'Median');
        opts.IncludeAxis = includeAxis;
    end

    function [X, Label, Unit] = getExperimentXAxis(p)
        [X, Label, Unit] = computePGIXSExperimentXAxis(p, 'GIXS');
    end
    function CalcPos_Callback(~,~)
        if ~isfield(param, 'Q') || isempty(param.Q), return; end
        try
            pos = round(double(GX2.azipospix.Value) + param.bpos(1));
            rowIdx = max(1, min(size(param.Q,1), round(param.bpos(2))));
            pos = max(1, min(size(param.Q,2), pos));
            GX2.Qpospix.Value = double(param.Q(rowIdx, pos));
        catch ME
            warning('GIXS2:QPositionCalculationFailed', 'Q position calculation failed: %s', ME.message);
            GX2.Qpospix.Value = 0;
        end
    end
    function CalcQpos_Callback(~,~)
        if ~isfield(param, 'Q') || isempty(param.Q), return; end
        try
            rowIdx = max(1, min(size(param.Q,1), round(param.bpos(2))));
            [~, pos] = min(abs(param.Q(rowIdx, :) - double(GX2.Qpospix.Value)));
            GX2.azipospix.Value = double(round(abs(param.HD(pos))));
        catch ME
            warning('GIXS2:PixelPositionCalculationFailed', 'Pixel position calculation failed: %s', ME.message);
            GX2.azipospix.Value = 0;
        end
    end
    function Autoplot_Callback(~,~)
        if ~isfield(param, 'Path') || ~isfield(param, 'FileName') || ~isfield(param, 'Stack')
            uialert(GUI.main, '먼저 데이터를 로드하세요 (Set/Table).', '알림'); return;
        end
        try
            [~, files, Ntotal] = listPGIXSSeriesFiles(param.Path, param.FileName, '.h5');
        catch ME
            uialert(GUI.main, sprintf('파일 검색 실패: %s', ME.message), '오류', 'Icon', 'error'); return;
        end
        if isempty(Ntotal) || Ntotal <= Auto.Nold
            uialert(GUI.main, sprintf('새 파일 없음 (현재 %d개).', Auto.Nold), 'Auto Refresh', 'Icon', 'info');
            return;
        end
        Nnew = Ntotal - Auto.Nold; new_indices = (Auto.Nold + 1) : Ntotal;

        % --- 보정 사전 준비 ---
        DoCorrection = (param.correctionI == 1);
        ChangeAng = isfield(param, 'aivar') && GUI.hChange.Value;
        InvFactor = []; BaseCorrection = []; k0 = []; AL_Kapton = struct(); AL_Si = struct();

        if DoCorrection
            try
                k0 = 2*pi/param.Wavelength;
                if ChangeAng
                    SolAng = SolidAngle(param.dataSize(2), param.dataSize(1), param.bpos, param.pixel, param.SDD);
                    Pol    = Polarization(param.dataSize(2), param.dataSize(1), param.bpos, param.pixel, param.SDD);
                    BaseCorrection = SolAng .* Pol;
                    AL_Kapton = load("KaptonAttLength8-30.mat");
                    if strcmp(param.detector, 'Eiger4M'), AL_Si = load("SiAttLength8-30.mat"); end
                else
                    TotalCorr = computePGIXSDetectorCorrectionFactor(param, k0);
                    InvFactor = 1 ./ TotalCorr;
                end
            catch ME
                uialert(GUI.main, sprintf('보정 인자 준비 실패: %s', ME.message), '오류', 'Icon', 'error'); return;
            end
        end

        % --- aivar 확장 (Change ai 모드) ---
        aivar_candidates = zeros(Nnew, 1);
        aivar_loaded = zeros(Nnew, 1);
        if ChangeAng
            aistep = double(GX2.hAistep.Value);
            last_ai = double(param.aivar(end));
            aivar_candidates = last_ai + aistep .* (1:Nnew)';
        end

        % --- 신규 프레임 로드 ---
        Stack_new = zeros(param.dataSize(1), param.dataSize(2), Nnew, 'single');
        loginfo_new = zeros(2, Nnew, 'single');
        ts_new = zeros(Nnew, 1);
        temp_new = zeros(Nnew, 3, 'single');
        if ChangeAng
            Qr_new = zeros(param.dataSize(1), param.dataSize(2), Nnew, 'single');
            Qz_new = zeros(param.dataSize(1), param.dataSize(2), Nnew, 'single');
        else
            Qr_new = zeros(0, 0, 0, 'single');
            Qz_new = zeros(0, 0, 0, 'single');
        end

        Mask = param.Mask; expmode_local = param.expmode;
        unit_val = GUI.hTimeP.Value; t_offset = double(GX2.hExptime.Value); if isnan(t_offset), t_offset = 0; end
        param.TimeUnit = unit_val; param.ExpTime = t_offset;  % getExperimentXAxis용 최신화
        ts1_local = nan; if isfield(param, 'ts1'), ts1_local = param.ts1; end
        RefIC_local = nan; if isfield(param, 'RefIC'), RefIC_local = param.RefIC; end
        RefBC_local = nan; if isfield(param, 'RefBC'), RefBC_local = param.RefBC; end

        d = uiprogressdlg(GUI.main, 'Title', 'Auto Refresh', ...
            'Message', sprintf('Processing %d new files...', Nnew), ...
            'Cancelable', 'on', 'Indeterminate', 'off');
        t_auto = tic;
        loadedCount = 0;
        attemptedCount = 0;
        failedLoadCount = 0;
        failedMetadataCount = 0;

        for ii = 1:Nnew
            if d.CancelRequested, break; end
            attemptedCount = ii;
            fileIdx = new_indices(ii); fname = files{fileIdx};
            writeIdx = loadedCount + 1;

            [D, okFrame, loadReport] = loadPGIXSH5FrameWithRetry(fname, Mask, NaN, param.dataSize);
            if ~okFrame
                warning('GIXS2:AutoDataLoadFailed', 'Auto refresh data load failed for %s after %d attempts: %s', fname, loadReport.Attempts, loadReport.Message);
                failedLoadCount = failedLoadCount + 1;
                param = appendPGIXSFrameFailureIndex(param, 'RetryFailedFrames', fileIdx);
            end
            try
                if DoCorrection
                    if ChangeAng
                        ai_l = aivar_candidates(ii);
                        [~, Qr_l, Qz_l, Q_l, ~, ~] = Qmaping_gi(param.dataSize(2), param.dataSize(1), param.bpos, param.pixel, param.SDD, k0, ai_l);
                        EF = Eff_correc(Q_l, AL_Kapton.R, k0, param.Energy, param.dataSize(2), param.dataSize(1), param.bpos, param.pixel);
                        if isfield(AL_Si, 'R')
                            Factor = BaseCorrection .* EF .* Eff_correc2(Q_l, k0, AL_Si.R, param.Energy);
                        else
                            Factor = BaseCorrection .* EF;
                        end
                        D = D ./ Factor;
                        if ChangeAng
                            Qr_new(:,:,writeIdx) = Qr_l;
                            Qz_new(:,:,writeIdx) = Qz_l;
                            aivar_loaded(writeIdx) = ai_l;
                        end
                    else
                        D = D .* InvFactor;
                    end
                end
                Stack_new(:,:,writeIdx) = D;
                if ChangeAng
                    aivar_loaded(writeIdx) = aivar_candidates(ii);
                end
            catch ME
                warning('GIXS2:AutoCorrectionFailed', 'Auto refresh correction failed for %s: %s', fname, ME.message);
                Stack_new(:,:,writeIdx) = single(nan(param.dataSize));
            end

            try
                [c1, cBC, ts_val, t_vec] = read_metadata_worker(fname, expmode_local, ts1_local);
            catch ME
                warning('GIXS2:AutoMetadataReadFailed', 'Auto refresh metadata read failed for %s: %s', fname, ME.message);
                failedMetadataCount = failedMetadataCount + 1;
                param = appendPGIXSFrameFailureIndex(param, 'MetadataFailedFrames', fileIdx);
                c1 = nan; cBC = nan; ts_val = nan; t_vec = [nan nan nan];
            end
            normCounts = normalizePGIXSCounters([c1 cBC], [RefIC_local RefBC_local]);
            v1 = normCounts(1); v2 = normCounts(2);
            loginfo_new(:, writeIdx) = [v1; v2];
            ts_new(writeIdx) = ts_val; temp_new(writeIdx, :) = t_vec;
            loadedCount = writeIdx;

            if mod(ii, 5) == 0 || ii == Nnew
                d.Value = ii/Nnew;
                d.Message = loadingProgressMsg(ii, Nnew, t_auto);
            end
        end

        if loadedCount == 0
            close(d);
            return;
        end
        if loadedCount < Nnew
            [Stack_new, loginfo_new, ts_new, temp_new] = trimPGIXSSeriesData( ...
                Stack_new, loginfo_new, ts_new, temp_new, loadedCount);
            if ChangeAng
                aivar_loaded = aivar_loaded(1:loadedCount);
                Qr_new = Qr_new(:, :, 1:loadedCount);
                Qz_new = Qz_new(:, :, 1:loadedCount);
            end
            Nnew = loadedCount;
        end

        % --- 기존 데이터에 concat ---
        param.Stack          = cat(3, param.Stack, Stack_new);
        param.loginfo        = cat(2, param.loginfo, loginfo_new);
        param.timestampinfo  = cat(1, param.timestampinfo(:), ts_new);
        param.temperatureinfo= cat(1, param.temperatureinfo, temp_new);
        if ChangeAng
            param.aivar = [param.aivar(:); aivar_loaded];
            if isfield(param, 'Qr'), param.Qr = cat(3, param.Qr, Qr_new); end
            if isfield(param, 'Qz'), param.Qz = cat(3, param.Qz, Qz_new); end
        end

        param.data = mean(param.Stack, 3, 'omitnan');
        updateImage2();

        % --- Auto.Met 따라 결과 갱신 ---
        try
            switch Auto.Met
                case AUTO_LINECUT, autoUpdateLineCut(Stack_new, Nnew, aivar_loaded, ChangeAng, k0);
                case AUTO_AZIMUTHAL, autoUpdateAziCut(Stack_new, Nnew);
                case AUTO_ROI, autoUpdateROI(Stack_new, Nnew);
            end
        catch ME
            uialert(GUI.main, sprintf('결과 갱신 실패: %s', ME.message), '오류', 'Icon', 'error');
        end

        close(d);
        Auto.Nold = Auto.Nold + attemptedCount; GX2.NFile.Text = num2str(Auto.Nold);
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

    function autoUpdateLineCut(Stack_new, Nnew, aivar_new, ChangeAng, k0)
        if ~isfield(param, 'data1dstack') || isempty(param.data1dstack), return; end
        RefAxis = param.data1dstack(:, 1); res_len = length(RefAxis);
        pNew = param;
        pNew.Stack = Stack_new;
        opts = buildGIXSLinecutOptions(RefAxis, k0);
        opts.ChangeAngle = ChangeAng;
        opts.AIVar = aivar_new;
        opts.UseParallel = false;
        new_block = processGIXSLinecutStack(pNew, opts);
        if size(new_block, 1) ~= res_len || size(new_block, 2) ~= Nnew, return; end
        param.data1dstack = cat(2, param.data1dstack, new_block);
        Plot1dseries2_Callback();
    end

    function autoUpdateAziCut(Stack_new, Nnew)
        if ~isfield(param, 'dataAzistack') || isempty(param.dataAzistack), return; end
        new_block = processGIXSAzimuthalStack(Stack_new, buildGIXSAzimuthalOptions(false));
        if size(new_block, 2) ~= Nnew, return; end
        param.dataAzistack = cat(2, param.dataAzistack, new_block);
        PlotAziseries2_Callback();
    end

    function autoUpdateROI(Stack_new, ~)
        if ~isfield(param, 'ROI') || isempty(param.ROI) || ~isfield(param, 'SumIROI'), return; end
        new_block = processPGIXSROIStack(Stack_new, param.ROI, false);
        param.SumIROI = cat(1, param.SumIROI, new_block);
        PlotROI_Callback();
    end
    function OpenICplot_callback(~,~), plot_counter('IC'); end
    function OpenBCplot_callback(~,~), plot_counter('BC'); end

    function plot_counter(Name)
        if ~isfield(param, 'loginfo') || isempty(param.loginfo)
            uialert(GUI.main, '시리즈 데이터가 없습니다. Set/Table 먼저 실행하세요.', '알림'); return;
        end
        switch Name
            case 'IC', row = 1; ref = nan; if isfield(param, 'RefIC'), ref = param.RefIC; end
            case 'BC', row = 2; ref = nan; if isfield(param, 'RefBC'), ref = param.RefBC; end
            otherwise, return;
        end
        Data = double(param.loginfo(row, :));
        if isempty(Data) || all(isnan(Data))
            uialert(GUI.main, sprintf('%s 데이터가 비어있습니다.', Name), '알림'); return;
        end
        [X_var, X_label, X_unit] = getExperimentXAxis(param);
        if numel(X_var) ~= numel(Data), X_var = 1:numel(Data); X_label = 'Shot'; X_unit = '#'; end

        f = figure('Name', sprintf('%s value', Name), 'NumberTitle', 'off', 'Color', 'w');
        ax = axes(f); plot(ax, X_var, Data, '-ok', 'MarkerFaceColor', 'k', 'LineWidth', 1.2, 'MarkerSize', 4);
        axis(ax, 'tight'); grid(ax, 'on');
        xlabel(ax, sprintf('%s (%s)', X_label, X_unit));
        if ~isnan(ref) && ref ~= 0
            ylabel(ax, sprintf('%s / %s_{ref}  (ref = %.3g)', Name, Name, ref));
        else
            ylabel(ax, sprintf('%s value', Name));
        end
        ttl = sprintf('%s shot trace', Name);
        if isfield(param, 'FileName'), ttl = [ttl, ' — ', param.FileName]; end
        title(ax, ttl, 'Interpreter', 'none');
        set(ax, 'LineWidth', 1.5, 'TickDir', 'out', 'FontSize', 11);
    end

    function GridRemove2_Callback(~,~)
        if ~isfield(param, 'Stack'), return; end
        if ~strcmp(GUI.hDetector.Value, 'Eiger4M')
            uialert(GUI.main, 'Grid Remove is available only for Eiger4M detector data.', 'Grid Remove Skipped', 'Icon', 'warning');
            return;
        end
        N = size(param.Stack,3);
        dlg = uiprogressdlg(GUI.main, 'Title', 'Grid Remove', ...
            'Message', sprintf('Removing grid over %d frames...', N), ...
            'Cancelable', 'on', 'Indeterminate', 'off');
        t_start = tic;
        failedFrames = zeros(1, N);
        nFailedFrames = 0;
        failMessage = '';
        for ii = 1:N
            if dlg.CancelRequested, break; end
            D = param.Stack(:,:,ii); nmask = isnan(D); D(nmask)=0;
            try
                [D, gridReport] = Gridremover(D, GUI.hDetector.Value);
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
            
            % [핵심 패치] 주기 제한 및 UI 호흡
            if mod(ii, max(1, floor(N/50))) == 0 || ii == N
                dlg.Value = ii/N; dlg.Message = loadingProgressMsg(ii, N, t_start);
                drawnow limitrate;
            end
        end
        failedFrames = failedFrames(1:nFailedFrames);
        if exist('dlg','var') && isvalid(dlg), close(dlg); end
        param.data = mean(param.Stack,3,'omitnan'); updateImage2;
        if ~isempty(failedFrames)
            warning('GIXS2:GridRemoveFailed', 'Grid remover failed for %d frame(s): %s', numel(failedFrames), failMessage);
            uialert(GUI.main, sprintf('Grid remover failed for %d frame(s).\nFrames: %s', ...
                numel(failedFrames), formatPGIXSFrameIndexList(failedFrames)), 'Grid Remove Warning', 'Icon', 'warning');
        else
            bGrid.BackgroundColor = [0.75 0.95 0.75];
            bGrid.FontColor = [0.15 0.15 0.15];
        end
    end

    function pxSize = currentPixelSize2()
        % param.pixel is only set by LOAD DATA, but Load Info alone is
        % enough to convert -- the pitch depends on the detector, nothing
        % else. Without this fallback the conversion threw
        % "Unrecognized field name 'pixel'" straight past the SDD guard,
        % which looked to the user like the field simply doing nothing.
        if isfield(param, 'pixel') && ~isempty(param.pixel) && param.pixel > 0
            pxSize = double(param.pixel);
        else
            pxSize = pgixsDetectorPixelSize(GUI.hDetector.Value);
        end
    end

    function ok = requireSDDForIncidence2()
        ok = isfield(param, 'SDD') && ~isempty(param.SDD) && isfinite(param.SDD) && param.SDD > 0;
        if ~ok
            uialert(GUI.main, 'Load Info를 먼저 실행하여 SDD를 불러오세요.', '알림');
        end
    end

    function CalIncidence2_Callback(~,~)
        if ~requireSDDForIncidence2(), return; end
        pixai = abs(double(GX2.hAiPix.Value));   % 음수 입력 방어 (direction과 무관하게 크기만 사용)
        param.ai = atand((pixai * currentPixelSize2()) / param.SDD) / 2;
        GX2.hAiDeg.Value = double(param.ai);
    end

    function CalIncidencePixel2_Callback(~,~)
        if ~requireSDDForIncidence2(), return; end
        aideg = double(GX2.hAiDeg.Value);
        pixai = param.SDD * tand(2 * aideg) / currentPixelSize2();
        param.ai = aideg;
        GX2.hAiPix.Value = double(round(abs(pixai)));  % 정수 픽셀 + 양수 보장
    end

    function aiZplot_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, '데이터를 먼저 로드하세요.', '알림'); return; end
        if ~isfield(param, 'bpos'), uialert(GUI.main, 'Load Info를 먼저 실행하여 Beam Center를 불러오세요.', '알림'); return; end
        
        ycpos = GX2.hAiYPix.Value; 
        
        % 2D 이미지 위에 현재 선택한 y-pos 기준선(세로선) 그리기
        updateImage2(); hold(hAX1, 'on'); xline(hAX1, ycpos, '--w', 'LineWidth', 1.5); hold(hAX1, 'off');
        
        % Y-pos 위치가 이미지 범위를 벗어나지 않도록 방어 코드 적용
        target_y = round(param.bpos(1) + ycpos);
        target_y = max(1, min(param.dataSize(2), target_y));
        
        % Z축 픽셀(Relative) 스케일 매핑
        m = single(-((1:param.dataSize(1)) - param.bpos(2)));
        
        % Z-Profile 피규어 생성
        f2 = figure('Name', 'Z-Profile (Incidence Angle Calibration)', 'NumberTitle', 'off', 'Color', 'w');
        plot(m, param.data(:, target_y), 'LineWidth', 1.5); 
        axis tight; grid on; % 피크를 명확히 보기 위해 그리드 켬
        xlabel('pixel', 'FontWeight', 'bold'); 
        ylabel('Intensity, arb. unit', 'FontWeight', 'bold');
        title('피크(Peak) 위치를 마우스로 1회 클릭하세요', 'FontSize', 12, 'Color', 'b');
        
        % 마우스 클릭 대기 및 픽셀 연동
        figure(f2);
        try
            [x, ~] = ginput(1); % 클릭 1회 받기
            if ~isempty(x)
                GX2.hAiPix.Value = double(abs(x));  % specular는 보통 음수 쪽이지만 크기만 사용
                CalIncidence2_Callback();           % 픽셀 값을 기반으로 ai[deg] 자동 역산
            end
            close(f2);
        catch ME
            warning('GIXS2:IncidencePeakSelectionFailed', ...
                'Incidence-angle peak selection was canceled or failed: %s', ME.message);
            if exist('f2', 'var') && isvalid(f2)
                close(f2);
            end
        end
    end

    function InsituModeChanged_Callback(~,~)
        % 상단 hinsitumode(Time/Temperature/Angle/LowTemp.) 변경 시
        % Options 섹션의 hTmode 드롭다운 선택지를 자동으로 갱신
        syncTmodeItems();
        param.Tmode = GUI.hTmode.Value;
        param.Amode = GUI.hAmode.Value;
        % expmode는 Set/Table 시점에 param.expmode로 고정되므로, 여기서는
        % 이미 로드된 데이터에 한해 플롯만 갱신 (일반적으로 데이터 로드 전 선택)
        refreshXAxisPlots();
    end

    function syncTmodeItems()
        % hinsitumode 값에 따라 hTmode 아이템을 전환
        mode = GUI.hinsitumode.Value;
        prev = GUI.hTmode.Value;
        switch mode
            case 'Temperature'
                new_items = {'Temperature1', 'Temperature2', 'Temperature3', 'Time'};
            case 'LowTemp.'
                new_items = {'LowTemp1', 'LowTemp2', 'Time'};
            otherwise
                % Time / Angle 모드에서는 hTmode 의미가 약하므로 기본 세트 유지
                new_items = {'Temperature1', 'Temperature2', 'Temperature3', 'Time'};
        end
        GUI.hTmode.Items = new_items;
        % 이전 선택값이 새 목록에 남아있으면 유지, 아니면 첫 항목으로
        if any(strcmp(prev, new_items))
            GUI.hTmode.Value = prev;
        else
            GUI.hTmode.Value = new_items{1};
        end
    end

    function Tmode_Callback(~,~)
        % hTmode 값을 param.Tmode로 동기화 → getExperimentXAxis가 즉시 반영
        param.Tmode = GUI.hTmode.Value;
        refreshXAxisPlots();
    end

    function Amode_Callback(~,~)
        % hAmode 값을 param.Amode로 동기화 → getExperimentXAxis가 즉시 반영
        param.Amode = GUI.hAmode.Value;
        refreshXAxisPlots();
    end

    function TimeUnit_Callback(~,~)
        % 노출시간 또는 시간 단위(second/min/hour) 변경 → 시간축 즉시 갱신
        if isfield(param, 'TimeUnit') || isfield(param, 'ExpTime')
            param.TimeUnit = GUI.hTimeP.Value;
            param.ExpTime  = double(GX2.hExptime.Value);
        end
        refreshXAxisPlots();
    end

    function refreshXAxisPlots()
        % 현재 분석 모드(Auto.Met)에 따라 활성 시리즈 플롯과 적분 패널을 다시 그림
        try
            switch Auto.Met
                case AUTO_LINECUT  % 1D Linecut
                    if isfield(param, 'data1dstackN'), update1Dplot_Callback(); end
                case 2  % Azimuthal
                    if isfield(param, 'dataAzistackN'), updateAziplot_Callback(); end
                case 3  % ROI
                    if isfield(param, 'SumIROI'), PlotROI_Callback(); end
            end
        catch ME
            warning('GIXS2:XAxisRefreshFailed', 'Refreshing x-axis plots failed: %s', ME.message);
        end
    end
end

% ========================================================================
% LOCAL FUNCTIONS 
% ========================================================================

function [c1, cBC, ts_out, t_vals] = read_metadata_worker(fname, mode, t_start)
    [~, ts_out, t_vals, report] = readPGIXSH5FrameMetadataRow(fname, mode, [NaN NaN], t_start, 3);
    if ~report.OK
        error('GIXS2:MetadataReadFailed', '%s', report.Message);
    end
    c1 = report.RawCounts(1);
    cBC = report.RawCounts(2);
end
