function GIXS_gui
% GIXS_gui - Grazing Incidence X-ray Scattering Analysis GUI (Modern UI)
% Optimized & Modernized for 3C beamline user at PLS-II
% Upgraded with uifigure, uigridlayout, and unchained properties.
% Includes Azimuthal gap/spike removal logic and exportgraphics fixes.

% [환경 변수 꼬임 자동 복구]
try evalin('base', 'clear uilabel uifigure uigridlayout uipanel uiaxes uibutton uidropdown uicheckbox uieditfield'); catch; end

if exist('uilabel', 'builtin') == 0 && exist('uilabel', 'file') == 0
    errordlg('현재 매트랩이 모던 UI(uilabel)를 인식하지 못합니다.', '버전 오류'); return;
end

clc;

% ============================ GUI Setup ==================================
GUI.main = uifigure('Name','Grazing Incidence X-ray Scattering v2.0',...
    'NumberTitle','off', 'Position',[100 50 1400 850], ...
    'Color', [0.96 0.96 0.96]);

movegui(GUI.main, 'center');

% Color & List definitions
detectorList = {'Eiger4M', 'MarCCD', 'MX170HS', 'PI-CCD', 'MAR345'};
NormalList = {'None', 'IC', 'BC'};
QMAPList = {'Qxy/Qz', 'Qy/Qz'};
scaleList = {'Linear', 'Log'};
ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis',...
    'cubehelix','magma','kindlemann','ocean','jet2','rwb','rkb'};
MapList = {'Pixel', 'Alpha', 'Qxy/Qz', 'Qy/Qz'};
SvForm = {'.jpg', '.png', '.tif'};

GX = struct();
param = initializeParams();

% ============================ Main Layout Grid ===========================
mainGrid = uigridlayout(GUI.main, [2 2]);
mainGrid.ColumnWidth = {420, '1x'};
mainGrid.RowHeight = {'1x', 110};
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 15;
mainGrid.RowSpacing = 10;

% ========================= 1. Left Panel (Parameters) ====================
leftPanelData = uipanel(mainGrid, 'Title', 'Single Data Analysis', 'FontSize', 14, 'FontWeight', 'bold', 'Scrollable', 'on');
leftPanelData.Layout.Row = [1 2]; 
leftPanelData.Layout.Column = 1;

% [수정] 행 개수를 30개로 줄이고 위아래 여백과 행간 간격을 좁혀 화면 잘림 완벽 방지
lg = uigridlayout(leftPanelData, [30 6]);
lg.RowHeight = [repmat({24}, 1, 28), {'1x'}, {20}]; % 기본 높이를 25->24로 축소
lg.ColumnWidth = {'1.2x', '1x', '1x', '1x', '1x', '1.2x'}; 
lg.Padding = [5 10 5 5]; % 상하 패딩 축소 (10->5)
lg.RowSpacing = 4;       % 행간 간격 축소 (6->4)
lg.ColumnSpacing = 4;

% --- Row 1: Directory (한 줄로 통합) ---
lblDir = uilabel(lg, 'Text', 'Directory:'); lblDir.Layout.Row = 1; lblDir.Layout.Column = 1;
GX.pathset = uieditfield(lg, 'text', 'Value', pwd); GX.pathset.Layout.Row = 1; GX.pathset.Layout.Column = [2 5];
btnSet = uibutton(lg, 'Text', 'Set', 'ButtonPushedFcn', @pathset_Callback); btnSet.Layout.Row = 1; btnSet.Layout.Column = 6;

% --- Row 2: Detector & Multishot ---
lblDet = uilabel(lg, 'Text', 'Detector:'); lblDet.Layout.Row = 2; lblDet.Layout.Column = [1 2];
GX.hDetector = uidropdown(lg, 'Items', detectorList); GX.hDetector.Layout.Row = 2; GX.hDetector.Layout.Column = [3 4];
GX.hMultishot = uicheckbox(lg, 'Text', 'Multishot'); GX.hMultishot.Layout.Row = 2; GX.hMultishot.Layout.Column = [5 6];

% --- Row 3: Load Data ---
btnLoad = uibutton(lg, 'Text', 'LOAD DATA', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.3 0.5], 'FontColor', 'w', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Load Data', @()Openimage_Callback([], [])));
btnLoad.Layout.Row = 3; btnLoad.Layout.Column = [1 6];

% --- Row 4: Counters ---
lblIC = uilabel(lg, 'Text', 'IC:'); lblIC.Layout.Row = 4; lblIC.Layout.Column = 1;
GX.IC = uilabel(lg, 'Text', '0', 'FontWeight', 'bold'); GX.IC.Layout.Row = 4; GX.IC.Layout.Column = 2;
lblBC = uilabel(lg, 'Text', 'BC:'); lblBC.Layout.Row = 4; lblBC.Layout.Column = 3;
GX.BC = uilabel(lg, 'Text', '0', 'FontWeight', 'bold'); GX.BC.Layout.Row = 4; GX.BC.Layout.Column = 4;

% --- Row 5: Energy & SDD ---
lblE = uilabel(lg, 'Text', 'Energy [keV]:'); lblE.Layout.Row = 5; lblE.Layout.Column = [1 2];
GX.hEnergy = uieditfield(lg, 'numeric', 'Value', 9.5); GX.hEnergy.Layout.Row = 5; GX.hEnergy.Layout.Column = 3;
lblS = uilabel(lg, 'Text', 'SDD [mm]:'); lblS.Layout.Row = 5; lblS.Layout.Column = [4 5];
GX.hSDD = uieditfield(lg, 'numeric', 'Value', 3000); GX.hSDD.Layout.Row = 5; GX.hSDD.Layout.Column = 6;

% --- Row 6: Center ---
lblC = uilabel(lg, 'Text', 'Center [y,z]:'); lblC.Layout.Row = 6; lblC.Layout.Column = [1 2];
GX.hyPOS = uieditfield(lg, 'numeric', 'Value', 1000); GX.hyPOS.Layout.Row = 6; GX.hyPOS.Layout.Column = [3 4];
GX.hzPOS = uieditfield(lg, 'numeric', 'Value', 1800); GX.hzPOS.Layout.Row = 6; GX.hzPOS.Layout.Column = [5 6];

% --- Row 7: Footprint & Load Info ---
lblF = uilabel(lg, 'Text', 'Footprint [mm]:'); lblF.Layout.Row = 7; lblF.Layout.Column = [1 2];
GX.hSample = uieditfield(lg, 'numeric', 'Value', 1); GX.hSample.Layout.Row = 7; GX.hSample.Layout.Column = 3;
btnInfo = uibutton(lg, 'Text', 'Load Info', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Load Info', @()Openinfo_Callback([], [])));
btnInfo.Layout.Row = 7; btnInfo.Layout.Column = [4 6];

% --- Row 8: Grid Remove ---
btnGridR = uibutton(lg, 'Text', 'Grid Remove', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Grid Remove', @()GridRemove_Callback([], [])));
btnGridR.Layout.Row = 8; btnGridR.Layout.Column = [4 6];

% [X-rot 완전 삭제됨]

% --- Row 9: Incidence Angle & Y-pos ---
lblAi = uilabel(lg, 'Text', 'ai [deg]:'); lblAi.Layout.Row = 9; lblAi.Layout.Column = 1;
lblYp = uilabel(lg, 'Text', 'y-pos:'); lblYp.Layout.Row = 9; lblYp.Layout.Column = 2;
GX.hAiYPix = uieditfield(lg, 'numeric', 'Value', 0); GX.hAiYPix.Layout.Row = 9; GX.hAiYPix.Layout.Column = [3 4];
btnZplot = uibutton(lg, 'Text', 'z-plot', 'ButtonPushedFcn', @aiZplot_Callback); btnZplot.Layout.Row = 9; btnZplot.Layout.Column = [5 6];

% --- Row 10: Pixel <-> Degree Calc ---
lblPx = uilabel(lg, 'Text', 'pixel'); lblPx.Layout.Row = 10; lblPx.Layout.Column = 1;
GX.hAiPix = uieditfield(lg, 'numeric', 'Value', 30, 'ValueChangedFcn', @CalIncidence_Callback); GX.hAiPix.Layout.Row = 10; GX.hAiPix.Layout.Column = [2 3];
lblDg = uilabel(lg, 'Text', 'degree'); lblDg.Layout.Row = 10; lblDg.Layout.Column = 4;
GX.hAiDeg = uieditfield(lg, 'numeric', 'Value', 0.1, 'BackgroundColor', [0.8 1 1], 'ValueChangedFcn', @CalIncidencePixel_Callback); GX.hAiDeg.Layout.Row = 10; GX.hAiDeg.Layout.Column = [5 6];

% --- Row 11: Background ---
lblBkg = uilabel(lg, 'Text', 'Background:'); lblBkg.Layout.Row = 11; lblBkg.Layout.Column = [1 2];
btnBkg = uibutton(lg, 'Text', 'Load Bkg.', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Load Background', @()Bkgload_Callback([], []))); btnBkg.Layout.Row = 11; btnBkg.Layout.Column = [3 4];
lblP = uilabel(lg, 'Text', '*Data:'); lblP.Layout.Row = 11; lblP.Layout.Column = 5;
GX.Plusdata = uieditfield(lg, 'numeric', 'Value', 1); GX.Plusdata.Layout.Row = 11; GX.Plusdata.Layout.Column = 6;

% --- Row 12: Normalization ---
lblN = uilabel(lg, 'Text', 'Normalization:'); lblN.Layout.Row = 12; lblN.Layout.Column = [1 2];
GX.hNormal = uidropdown(lg, 'Items', NormalList); GX.hNormal.Layout.Row = 12; GX.hNormal.Layout.Column = [3 4];
btnSub = uibutton(lg, 'Text', 'BKG sub. & Norm', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Background Subtract Normalize', @()Subtraction_Callback([], []))); btnSub.Layout.Row = 12; btnSub.Layout.Column = [5 6];

% --- Row 13-14: Q-Map Cal ---
GX.hQuncertain = uicheckbox(lg, 'Text', 'q uncertainty', 'Value', 0); GX.hQuncertain.Layout.Row = 13; GX.hQuncertain.Layout.Column = [1 3];
lblMap = uilabel(lg, 'Text', 'Mapping:'); lblMap.Layout.Row = 13; lblMap.Layout.Column = 4;
GX.hQMAPmethod = uidropdown(lg, 'Items', QMAPList); GX.hQMAPmethod.Layout.Row = 13; GX.hQMAPmethod.Layout.Column = [5 6];

GX.btnQcal = uibutton(lg, 'Text', 'q-Map Cal.', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS q-Map Cal', @()Correction_Callback([], [])));
GX.btnQcal.Layout.Row = 14; GX.btnQcal.Layout.Column = [4 6];

% --- Row 15: [ 1D Plot Process ] ---
lblDiv1 = uilabel(lg, 'Text', '--- [ 1D Plot Process ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); lblDiv1.Layout.Row = 15; lblDiv1.Layout.Column = [1 6];

% --- Row 16: 1d line Angle & Legend (한 줄로 통합) ---
lbl1d = uilabel(lg, 'Text', '1d line Angle:'); lbl1d.Layout.Row = 16; lbl1d.Layout.Column = [1 2];
GX.h1dphi = uieditfield(lg, 'numeric', 'Value', 90); GX.h1dphi.Layout.Row = 16; GX.h1dphi.Layout.Column = 3;
lblLeg = uilabel(lg, 'Text', '0: ←,  90: ↑,  180: →', 'FontSize', 11); lblLeg.Layout.Row = 16; lblLeg.Layout.Column = [4 6];

% --- Row 17: Accum Pixel ---
lblAc = uilabel(lg, 'Text', 'Accum. Pixel (-/+):'); lblAc.Layout.Row = 17; lblAc.Layout.Column = [1 2];
GX.h1dAmpix = uieditfield(lg, 'numeric', 'Value', -1); GX.h1dAmpix.Layout.Row = 17; GX.h1dAmpix.Layout.Column = 3;
GX.h1dAppix = uieditfield(lg, 'numeric', 'Value', 1); GX.h1dAppix.Layout.Row = 17; GX.h1dAppix.Layout.Column = 4;
GX.hAccum = uicheckbox(lg, 'Text', 'On', 'Value', 0); GX.hAccum.Layout.Row = 17; GX.hAccum.Layout.Column = [5 6];

% --- Row 18: Cakecut Angle ---
lblCk = uilabel(lg, 'Text', 'Cakecut Ang (-/+):'); lblCk.Layout.Row = 18; lblCk.Layout.Column = [1 2];
GX.hCkcutst = uieditfield(lg, 'numeric', 'Value', -1); GX.hCkcutst.Layout.Row = 18; GX.hCkcutst.Layout.Column = 3;
GX.hCkcutfi = uieditfield(lg, 'numeric', 'Value', 1); GX.hCkcutfi.Layout.Row = 18; GX.hCkcutfi.Layout.Column = 4;
GX.hCakecut = uicheckbox(lg, 'Text', 'On', 'Value', 0); GX.hCakecut.Layout.Row = 18; GX.hCakecut.Layout.Column = [5 6];

% --- Row 19-20: z/y pos move & Position Button (통합 배치) ---
lblZm = uilabel(lg, 'Text', 'z-pos move (pix):'); lblZm.Layout.Row = 19; lblZm.Layout.Column = [1 2];
GX.h1dzpos = uieditfield(lg, 'numeric', 'Value', 0); GX.h1dzpos.Layout.Row = 19; GX.h1dzpos.Layout.Column = 3;

lblYm = uilabel(lg, 'Text', 'y-pos move (pix):'); lblYm.Layout.Row = 20; lblYm.Layout.Column = [1 2];
GX.h1dypos = uieditfield(lg, 'numeric', 'Value', 0); GX.h1dypos.Layout.Row = 20; GX.h1dypos.Layout.Column = 3;

% Position 버튼을 19~20행 우측에 2줄 높이로 걸쳐서 배치 (직관성 강화)
btnPos = uibutton(lg, 'Text', 'Position', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Line Position', @()PointFindLine_Callback([], []))); 
btnPos.Layout.Row = [19 20]; btnPos.Layout.Column = [4 6];

% --- Row 21: Actions (Line & 1d Plot) ---
% 남은 공간을 활용해 Line과 1d Plot 버튼을 시원하게 좌우로 절반씩 분할 배치합니다.
btnLine = uibutton(lg, 'Text', 'Line', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Draw Line', @()Drawline_Callback([], []))); btnLine.Layout.Row = 21; btnLine.Layout.Column = [1 3];
btn1dP = uibutton(lg, 'Text', '1d Plot', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS 1D Line Plot', @()Lineplot_Callback([], []))); btn1dP.Layout.Row = 21; btn1dP.Layout.Column = [4 6];

% --- Row 23: [ Azimuthal Process ] ---
lblDiv2 = uilabel(lg, 'Text', '--- [ Azimuthal Process ] ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center'); lblDiv2.Layout.Row = 23; lblDiv2.Layout.Column = [1 6];

% --- Row 24: Azi Pixel & Range ---
lblAzP = uilabel(lg, 'Text', 'pixel:'); lblAzP.Layout.Row = 24; lblAzP.Layout.Column = 1;
GX.azipospix = uieditfield(lg, 'numeric', 'Value', 202, 'ValueChangedFcn', @CalcPos_Callback); GX.azipospix.Layout.Row = 24; GX.azipospix.Layout.Column = 2;
lblRg = uilabel(lg, 'Text', 'Range(-/+):'); lblRg.Layout.Row = 24; lblRg.Layout.Column = [3 4];
GX.azipospixm = uieditfield(lg, 'numeric', 'Value', -1, 'ValueChangedFcn', @CalcPos_Callback); GX.azipospixm.Layout.Row = 24; GX.azipospixm.Layout.Column = 5;
GX.azipospixp = uieditfield(lg, 'numeric', 'Value', 1, 'ValueChangedFcn', @CalcPos_Callback); GX.azipospixp.Layout.Row = 24; GX.azipospixp.Layout.Column = 6;

% --- Row 25: Azi z-pos ---
lblAzZ = uilabel(lg, 'Text', 'z-pos:'); lblAzZ.Layout.Row = 25; lblAzZ.Layout.Column = 1;
GX.Zpospixp = uieditfield(lg, 'numeric', 'Value', 0); GX.Zpospixp.Layout.Row = 25; GX.Zpospixp.Layout.Column = 2;

% --- Row 26: Azi Q ---
lblAzQ = uilabel(lg, 'Text', 'q [1/A]:'); lblAzQ.Layout.Row = 26; lblAzQ.Layout.Column = 1;
GX.Qpospix = uieditfield(lg, 'numeric', 'Value', 1, 'BackgroundColor', [0.8 1 1], 'ValueChangedFcn', @CalcQpos_Callback); GX.Qpospix.Layout.Row = 26; GX.Qpospix.Layout.Column = [2 3];
GX.Qpospixm = uieditfield(lg, 'numeric', 'Value', 0, 'BackgroundColor', [0.9 0.9 0.9], 'Editable', 'off'); GX.Qpospixm.Layout.Row = 26; GX.Qpospixm.Layout.Column = 4;
GX.Qpospixp = uieditfield(lg, 'numeric', 'Value', 0, 'BackgroundColor', [0.9 0.9 0.9], 'Editable', 'off'); GX.Qpospixp.Layout.Row = 26; GX.Qpospixp.Layout.Column = 5;

% --- Row 27-28: Azi Actions ---
btnAzPos = uibutton(lg, 'Text', 'Position', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Azimuthal Position', @()PointFindAzi_Callback([], []))); btnAzPos.Layout.Row = 27; btnAzPos.Layout.Column = [1 2];
GX.hMeanMed = uidropdown(lg, 'Items', {'Mean', 'Median'}); GX.hMeanMed.Layout.Row = 27; GX.hMeanMed.Layout.Column = [3 4];

btnAzDrw = uibutton(lg, 'Text', 'Draw', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Draw Azimuthal', @()DrawPlot_Callback([], []))); btnAzDrw.Layout.Row = 28; btnAzDrw.Layout.Column = [3 4];
btnAzPlt = uibutton(lg, 'Text', 'Plot', 'ButtonPushedFcn', @(~,~)runLoggedAction('GIXS Azimuthal Plot', @()AziPlot_Callback([], []))); btnAzPlt.Layout.Row = 28; btnAzPlt.Layout.Column = [5 6];

% --- Row 30: Footer ---
lblFooter = uilabel(lg, 'Text', 'Designed By Y.Y.Kim v2.0', 'FontSize', 9, 'FontColor', [0.5 0.5 0.5]);
lblFooter.Layout.Row = 30; lblFooter.Layout.Column = [1 6];

% ========================= 2. Right Plot Panel ===========================
pnlPlot = uipanel(mainGrid, 'Title', '2D Image Plot', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'w');
pnlPlot.Layout.Row = 1; pnlPlot.Layout.Column = 2;

gPlot = uigridlayout(pnlPlot, [1 1]); gPlot.Padding = [10 10 10 10];
hAX = uiaxes(gPlot); hAX.Layout.Row = 1; hAX.Layout.Column = 1;

% ========================= 3. Image Controller ===========================
pnlCtrl = uipanel(mainGrid, 'Title', 'Image Controller', 'FontSize', 11, 'FontWeight', 'bold');
pnlCtrl.Layout.Row = 2; pnlCtrl.Layout.Column = 2;

cg = uigridlayout(pnlCtrl, [2 10]);
cg.RowHeight = {20, 25};
cg.ColumnWidth = {'1x','1x','1.2x','1x','1.2x','1.2x','0.8x','1x','1x','1x'};
cg.Padding = [10 5 10 5]; cg.ColumnSpacing = 8;

% Col 1-2: Scale, Colormap
lblScl = uilabel(cg, 'Text', 'ColorScale'); lblScl.Layout.Row = 1; lblScl.Layout.Column = 1;
GX.hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateimage_Callback); GX.hScale.Layout.Row = 2; GX.hScale.Layout.Column = 1;

lblCmp = uilabel(cg, 'Text', 'Colormap'); lblCmp.Layout.Row = 1; lblCmp.Layout.Column = 2;
GX.hColor = uidropdown(cg, 'Items', ColormapList, 'ValueChangedFcn', @Updateimage_Callback); GX.hColor.Layout.Row = 2; GX.hColor.Layout.Column = 2;

% Col 3: Contrast
lblCtr = uilabel(cg, 'Text', 'Contrast'); lblCtr.Layout.Row = 1; lblCtr.Layout.Column = 3;
subC1 = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); subC1.Layout.Row = 2; subC1.Layout.Column = 3;
GX.cMin = uieditfield(subC1, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage_Callback);
GX.cMax = uieditfield(subC1, 'numeric', 'Value', 1e6, 'ValueChangedFcn', @Updateimage_Callback);

% Col 4: Map format
lblMapF = uilabel(cg, 'Text', 'Map format'); lblMapF.Layout.Row = 1; lblMapF.Layout.Column = 4;
GX.hMapping = uidropdown(cg, 'Items', MapList, 'ValueChangedFcn', @Rangecal_Callback); GX.hMapping.Layout.Row = 2; GX.hMapping.Layout.Column = 4;

% Col 5-6: Y/Z Range
lblYR = uilabel(cg, 'Text', 'Y-Range'); lblYR.Layout.Row = 1; lblYR.Layout.Column = 5;
subC2 = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); subC2.Layout.Row = 2; subC2.Layout.Column = 5;
GX.cXlim1 = uieditfield(subC2, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage_Callback);
GX.cXlim2 = uieditfield(subC2, 'numeric', 'Value', 2000, 'ValueChangedFcn', @Updateimage_Callback);

lblZR = uilabel(cg, 'Text', 'Z-Range'); lblZR.Layout.Row = 1; lblZR.Layout.Column = 6;
subC3 = uigridlayout(cg, [1 2], 'Padding', [0 0 0 0], 'ColumnSpacing', 2); subC3.Layout.Row = 2; subC3.Layout.Column = 6;
GX.cYlim1 = uieditfield(subC3, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage_Callback);
GX.cYlim2 = uieditfield(subC3, 'numeric', 'Value', 2000, 'ValueChangedFcn', @Updateimage_Callback);

% Col 7-10: Font, Update, SaveForm, Save
lblFnt = uilabel(cg, 'Text', 'Font Sz'); lblFnt.Layout.Row = 1; lblFnt.Layout.Column = 7;
GX.FontSz = uieditfield(cg, 'numeric', 'Value', 18, 'ValueChangedFcn', @Updateimage_Callback); GX.FontSz.Layout.Row = 2; GX.FontSz.Layout.Column = 7;

btnUpd = uibutton(cg, 'Text', 'Update', 'ButtonPushedFcn', @Updateimage_Callback); btnUpd.Layout.Row = [1 2]; btnUpd.Layout.Column = 8;

lblSvF = uilabel(cg, 'Text', 'Format'); lblSvF.Layout.Row = 1; lblSvF.Layout.Column = 9;
GX.hSvForm = uidropdown(cg, 'Items', SvForm); GX.hSvForm.Layout.Row = 2; GX.hSvForm.Layout.Column = 9;

btnSvI = uibutton(cg, 'Text', 'Save Img', 'BackgroundColor', [0.9 0.95 1], 'FontWeight', 'bold', 'ButtonPushedFcn', @Savefile_Callback);
btnSvI.Layout.Row = [1 2]; btnSvI.Layout.Column = 10;

% Optional Q-Range displays
GX.qXlim1 = []; GX.qXlim2 = []; GX.qYlim1 = []; GX.qYlim2 = [];


% =========================================================================
% ====================== HELPER FUNCTIONS =================================
% =========================================================================

    function applyColormap(colormapName, data)
        applyPGIXSColormap(hAX, colormapName, data);
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
        p.colorscale = GX.hScale.Value;
        p.colorm = GX.hColor.Value;
        p.Mapping = GX.hMapping.Value;
        p.cmax = GX.cMax.Value;
        p.cmin = GX.cMin.Value;
        p.xlimmin = GX.cXlim1.Value;
        p.xlimmax = GX.cXlim2.Value;
        p.ylimmin = GX.cYlim1.Value;
        p.ylimmax = GX.cYlim2.Value;
        p.fontsize = GX.FontSz.Value;
    end

    function displayImage(xdata, ydata, imgdata, xlbl, ylbl, ydir)
        imagesc(hAX, xdata, ydata, imgdata);
        set(hAX, 'YDir', ydir);
        xlabel(hAX, xlbl);
        ylabel(hAX, ylbl);
    end

    function renderImage(overlayFunc)
        uiParams = getUIParams();
        param.colorscale = uiParams.colorscale; param.colorm = uiParams.colorm;
        param.Mapping = uiParams.Mapping; param.cmax = uiParams.cmax; param.cmin = uiParams.cmin;
        param.xlimmin = uiParams.xlimmin; param.xlimmax = uiParams.xlimmax;
        param.ylimmin = uiParams.ylimmin; param.ylimmax = uiParams.ylimmax; param.fontsize = uiParams.fontsize;
        
        cla(hAX);
        
        switch param.Mapping
            case 'Pixel'
                displayImage(param.HD, param.VD, param.data, 'Y, pixel', 'Z, pixel', getYDir(param.Expinfo));
            case 'Alpha'
                if isfield(param,'tth') && isfield(param,'af')
                    displayImage(param.tth, param.af, param.AlphaMap, '$2\theta_f$', '$\alpha_f$', 'normal');
                    xlabel(hAX, '$2\theta_f$', 'Interpreter', 'latex', 'Fontname', 'TimesNewRoman');
                    ylabel(hAX, '$\alpha_f$', 'Interpreter', 'latex', 'Fontname', 'TimesNewRoman');
                else
                    uialert(GUI.main, 'Alpha format is not exist.','Warning'); return;
                end
            case 'Qxy/Qz'
                if isfield(param,'qr')
                    displayImage(param.qr, param.qz, param.Itrans, 'q_{xy}, A^{-1}', 'q_z, A^{-1}', 'normal');
                    xlabel(hAX, 'q_{xy}, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
                    ylabel(hAX, 'q_z, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
                else
                    uialert(GUI.main, 'Please use Qy/Qz mode!!','Warning'); return;
                end
            case 'Qy/Qz'
                if isfield(param,'qy')
                    displayImage(param.qy, param.qz, param.Itrans, 'q_y, A^{-1}', 'q_z, A^{-1}', 'normal');
                    xlabel(hAX, 'q_y, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
                    ylabel(hAX, 'q_z, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
                else
                    uialert(GUI.main, 'Please use Qxy/Qz mode!!','Warning'); return;
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

    function ydir = getYDir(expinfo)
        if expinfo == 0, ydir = 'reverse'; else, ydir = 'normal'; end
    end

    function [Mask, pixel, report] = loadDetectorMask(detectorType)
        [Mask, pixel, report] = loadPGIXSDetectorMask(detectorType);
    end

    function [data, counts] = loadImageFile(filepath, fileFormat)
        [data, counts] = loadPGIXSImageFile(filepath, fileFormat);
    end

    function data = applyMaskToData(data, mask), data = applyPGIXSMask(data, mask); end
    function p = initializeParams(), p.data = []; p.Expinfo = 0; p.correctionI = 0; p.Normalcheck = 0; end

% =========================================================================
% ====================== CALLBACK FUNCTIONS ===============================
% =========================================================================

    function runLoggedAction(actionName, callbackFcn)
        ensurePGIXSFunctionsPath();
        runPGIXSCallback(GUI.main, actionName, callbackFcn, ...
            @()summarizePGIXSState(param, actionName, struct('GUI', 'GIXS_gui')));
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

    function pathset_Callback(~,~)
        pathway = uigetdir;
        figure(GUI.main); drawnow;
        if pathway ~= 0, GX.pathset.Value = pathway; end
    end

    function Openimage_Callback(~,~)
        param.detector = GX.hDetector.Value;
        Multi_img = GX.hMultishot.Value;
        pathway = GX.pathset.Value;
        
        [XSImage, datadir] = uigetfile({'*.*','All format(*.*)'}, 'Select a file', pathway);
        figure(GUI.main); drawnow;
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
            end
            param.data = applyMaskToData(param.data, param.Mask);
        else
            param = loadMultishot(param, FileFormat);
            if isempty(param.data), return; end
        end
        
        param.correctionI = 0; param.Normalcheck = 0;
        param.cmin = min(param.data(param.data > 0), [], 'omitnan'); param.cmax = max(param.data(:), [], 'omitnan');
        GX.cMax.Value = double(param.cmax); GX.cMin.Value = double(param.cmin);
        GX.btnQcal.BackgroundColor = [0.96 0.96 0.96];
        btnGridR.BackgroundColor = [0.96 0.96 0.96];
        btnGridR.FontColor = [0.15 0.15 0.15];

        % 새 데이터 로드 시 Load Info로 채워졌던 필드의 강조색을 default(흰색)로 복귀
        % (Load Info → fields turn cyan; Load Data → fields back to white)
        GX.hEnergy.BackgroundColor = [1 1 1];
        GX.hSDD.BackgroundColor    = [1 1 1];
        GX.hyPOS.BackgroundColor   = [1 1 1];
        GX.hzPOS.BackgroundColor   = [1 1 1];
        
        if ~isempty(param.Count), GX.IC.Text = num2str(param.Count(1)); GX.BC.Text = num2str(param.Count(2)); end
        
        if isfield(param, 'Expinfo') && param.Expinfo == 1 && isfield(param, 'bpos')
            param.HD = single(1:param.dataSize(2)) - param.bpos(1);
            param.VD = -(single(1:param.dataSize(1)) - param.bpos(2));
        else
            param.HD = single(1:param.dataSize(2)); param.VD = single(1:param.dataSize(1)); param.Expinfo = 0; 
        end
        
        GX.cXlim1.Value = double(min(param.HD)); GX.cXlim2.Value = double(max(param.HD));
        GX.cYlim1.Value = double(min(param.VD)); GX.cYlim2.Value = double(max(param.VD));
        
        % [추가] 새로운 데이터를 로드하면 Map format 콤보박스와 상태를 무조건 'Pixel'로 초기화
        GX.hMapping.Value = 'Pixel';
        param.Mapping = 'Pixel';
        
        renderImage();
        figure(GUI.main); drawnow;
    end

    function p = loadMultishot(p, FileFormat)
        d = uiprogressdlg(GUI.main, 'Title', 'Loading', 'Message', 'Multishot Data...');
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

    function Openinfo_Callback(~,~)
        pathway = GX.pathset.Value; [XSinfo, datadir] = uigetfile({'*.mat'}, 'Select info file', pathway);
        figure(GUI.main); drawnow;
        if XSinfo == 0, return; end
        [S, loadReport] = loadPGIXSStandardCalibration(fullfile(datadir, XSinfo), param.detector);
        
        if loadReport.OK
            param.Wavelength = S.wavelength; param.bpos = S.pc; param.SDD = S.sdd;
            param.Energy = S.Energy;
            
            GX.hEnergy.Value = double(param.Energy); GX.hEnergy.BackgroundColor = [0.8 1 1];
            GX.hSDD.Value = double(param.SDD); GX.hSDD.BackgroundColor = [0.8 1 1];
            GX.hyPOS.Value = double(param.bpos(1)); GX.hyPOS.BackgroundColor = [0.8 1 1];
            GX.hzPOS.Value = double(param.bpos(2)); GX.hzPOS.BackgroundColor = [0.8 1 1];
            
            param.HD = single(1:param.dataSize(2)) - param.bpos(1);
            param.VD = -(single(1:param.dataSize(1)) - param.bpos(2));
            
            GX.cXlim1.Value = double(min(param.HD)); GX.cXlim2.Value = double(max(param.HD));
            GX.cYlim1.Value = double(min(param.VD)); GX.cYlim2.Value = double(max(param.VD));
            
            param.Expinfo = 1; renderImage();
            figure(GUI.main); drawnow;
        else
            uialert(GUI.main, loadReport.Message, 'Calibration Warning', 'Icon', 'warning');
        end
    end

    function Rangecal_Callback(~,~)
        param.Mapping = GX.hMapping.Value;
        switch param.Mapping
            case 'Pixel', GX.cXlim1.Value = double(min(param.HD)); GX.cXlim2.Value = double(max(param.HD)); GX.cYlim1.Value = double(min(param.VD)); GX.cYlim2.Value = double(max(param.VD));
            case 'Alpha', if isfield(param,'tth'), GX.cXlim1.Value = double(min(param.tth)); GX.cXlim2.Value = double(max(param.tth)); GX.cYlim1.Value = double(min(param.af)); GX.cYlim2.Value = double(max(param.af)); else, uialert(GUI.main, 'Alpha format missing.','Warning'); end
            case 'Qxy/Qz', if isfield(param,'qr'), GX.cXlim1.Value = double(min(param.qr)); GX.cXlim2.Value = double(max(param.qr)); GX.cYlim1.Value = double(min(param.qz)); GX.cYlim2.Value = double(max(param.qz)); else, uialert(GUI.main, 'Qxy/Qz format missing.','Warning'); end
            case 'Qy/Qz', if isfield(param,'qy'), GX.cXlim1.Value = double(min(param.qy)); GX.cXlim2.Value = double(max(param.qy)); GX.cYlim1.Value = double(min(param.qz)); GX.cYlim2.Value = double(max(param.qz)); else, uialert(GUI.main, 'Qy/Qz format missing.','Warning'); end
        end
        renderImage();
    end

    function Updateimage_Callback(~,~), renderImage(); end

    function GridRemove_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if ~strcmp(GX.hDetector.Value, 'Eiger4M')
            uialert(GUI.main, 'Grid Remove is available only for Eiger4M detector data.', 'Grid Remove Skipped', 'Icon', 'warning');
            return;
        end
        Nanpos = find(isnan(param.data)); param.data(Nanpos) = 0;
        try
            [param.data, gridReport] = Gridremover(param.data, GX.hDetector.Value);
            param.data(Nanpos) = nan;
            renderImage();
            if ~gridReport.Applied
                uialert(GUI.main, gridReport.Message, 'Grid Remove Skipped', 'Icon', 'warning');
            else
                btnGridR.BackgroundColor = [0.75 0.95 0.75];
                btnGridR.FontColor = [0.15 0.15 0.15];
            end
        catch ME
            param.data(Nanpos) = nan;
            uialert(GUI.main, ['Grid remover error: ', ME.message], 'Error');
        end
    end

    function pxSize = currentPixelSize()
        % param.pixel only exists once LOAD DATA has run, but the
        % pixel<->degree conversion is normally used *before* loading -- it
        % is how the user works out which incidence angle to ask for. Fall
        % back to the detector dropdown, which is all the pitch depends on.
        if isfield(param, 'pixel') && ~isempty(param.pixel) && param.pixel > 0
            pxSize = double(param.pixel);
        else
            pxSize = pgixsDetectorPixelSize(GX.hDetector.Value);
        end
    end

    function ok = requireSDDForIncidence()
        ok = false;
        sdd = double(GX.hSDD.Value);
        if ~isfinite(sdd) || sdd <= 0
            uialert(GUI.main, ['SDD를 먼저 입력하거나 Load Info로 불러오세요. ' ...
                '(현재 SDD [mm] = ', num2str(sdd), ')'], 'Incidence angle');
            return;
        end
        param.SDD = sdd;
        ok = true;
    end

    function drawIncidenceGuide(pixai)
        % The guide line is a nicety; the converted number is the point.
        % renderImage needs param.HD/VD, which only exist once an image has
        % been loaded, so skip the redraw rather than let it throw and
        % swallow the conversion with it.
        if isempty(param.data) || ~isfield(param, 'HD'), return; end
        renderImage(@() yline(hAX, fix(pixai), '--w', 'LineWidth', 1.5));
    end

    function CalIncidence_Callback(~,~)
        if ~requireSDDForIncidence(), return; end
        pixai = abs(double(GX.hAiPix.Value));
        param.ai = atand((pixai * currentPixelSize()) / param.SDD) / 2;
        GX.hAiDeg.Value = double(param.ai);
        drawIncidenceGuide(pixai);
    end

    function CalIncidencePixel_Callback(~,~)
        if ~requireSDDForIncidence(), return; end
        aideg = double(GX.hAiDeg.Value);
        pixai = abs(param.SDD * tand(2 * aideg) / currentPixelSize());
        param.ai = aideg;
        GX.hAiPix.Value = double(pixai);
        drawIncidenceGuide(pixai);
    end

    function aiZplot_Callback(~,~)
        ycpos = GX.hAiYPix.Value; 
        renderImage(@() xline(hAX, ycpos, '--w', 'LineWidth', 1.5));
        
        param.bpos(1) = GX.hyPOS.Value; 
        param.bpos(2) = GX.hzPOS.Value; 
        
        % Y-pos 위치가 이미지 범위를 벗어나지 않도록 방어 코드 추가
        target_y = round(param.bpos(1) + ycpos);
        target_y = max(1, min(param.dataSize(2), target_y));
        
        m = single(-((1:param.dataSize(1)) - param.bpos(2)));
        
        % Z-Profile 피규어 생성
        f2 = figure('Name', 'Z-Profile (Incidence Angle Calibration)', 'NumberTitle', 'off');
        plot(m, param.data(:, target_y), 'LineWidth', 1.5); 
        axis tight; grid on; % 피크를 더 잘 볼 수 있도록 그리드 추가
        xlabel('pixel', 'FontWeight', 'bold'); 
        ylabel('Intensity, arb. unit', 'FontWeight', 'bold');
        title('피크(Peak) 위치를 마우스로 1회 클릭하세요', 'FontSize', 12, 'Color', 'b');
        
        % 새로 뜬 창에 포커스를 맞추고 ginput 대기
        figure(f2);
        try
            [x, ~] = ginput(1); % 마우스 클릭 1회 받기
            if ~isempty(x)
                % 1. 클릭한 위치의 X좌표를 pixel 필드에 자동 입력
                GX.hAiPix.Value = double(x);
                
                % 2. pixel 값을 바탕으로 ai [deg] 자동 계산 및 2D 창 업데이트
                CalIncidence_Callback();
            end
        catch ME
            warning('GIXS:IncidencePeakSelectionFailed', ...
                'Incidence-angle peak selection was canceled or failed: %s', ME.message);
        end
    end

    function Bkgload_Callback(~,~)
        Multi_img = GX.hMultishot.Value; pathway = GX.pathset.Value;
        % [수정] 확장자 필터 배열의 짝을 완벽하게 맞춰줍니다 (2x2 셀 배열)
        [XSBKG, datadir] = uigetfile({'*.*', 'All format(*.*)'; '*.mat', 'MAT-files (*.mat)'}, 'Select a file', pathway);
        figure(GUI.main); drawnow;
        if XSBKG == 0, return; end
        [BKGPath, param.BKGFile, FileFormat] = fileparts(fullfile(datadir, XSBKG));
        
        d = uiprogressdlg(GUI.main, 'Title', 'Background', 'Message', 'Loading BKG...', 'Indeterminate', 'on');
        
        if Multi_img == 0
            [param.bkg, param.Countbkg] = loadImageFile(fullfile(datadir, XSBKG), FileFormat);
            if size(param.bkg, 1) == size(param.Mask, 1), param.bkg = applyMaskToData(param.bkg, param.Mask); else, uialert(GUI.main, 'BKG size mismatch','Warning'); close(d); return; end
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
        figure(GUI.main); drawnow;
        uialert(GUI.main, 'Background loaded.', 'Success');
    end

    function Subtraction_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Please load data first!', 'Error'); return; end
        if param.correctionI == 1, uialert(GUI.main, 'Please perform subtraction before correction!','Warning'); return; end
        if param.Normalcheck == 1, uialert(GUI.main, 'Normalization is already done!','Warning'); return; end
        
        Normalway = GX.hNormal.Value; PlusD = GX.Plusdata.Value;
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
             GX.cMax.Value = double(cmax_new); GX.cMin.Value = double(cmin_new);
             renderImage();
             
             % [추가] 변경된 이미지를 먼저 보여준 후 유지 여부 묻기
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
                 GX.cMax.Value = double(param.cmax); GX.cMin.Value = double(param.cmin);
                 renderImage();
             end
        end
    end

    function Correction_Callback(~,~)
        if param.correctionI == 1, uialert(GUI.main, 'qMap already done!!','Warning'); return; end
        d = uiprogressdlg(GUI.main, 'Title', 'qMap', 'Message', 'qMap is ongoing. Please wait...', 'Indeterminate', 'on');

        opts = struct();
        opts.Energy = GX.hEnergy.Value;
        opts.SDD = GX.hSDD.Value;
        opts.Beampos = [GX.hyPOS.Value, GX.hzPOS.Value];
        opts.SamplePath = GX.hSample.Value;
        opts.IncAngle = GX.hAiDeg.Value;
        opts.Detector = GX.hDetector.Value;
        opts.QMapMethod = GX.hQMAPmethod.Value;
        opts.QUncertainty = GX.hQuncertain.Value;

        try
            param = processGIXS2D(param, opts);
            switch param.QMapMet
                case 'Qxy/Qz'
                    GX.qXlim1 = min(param.qr); GX.qXlim2 = max(param.qr);
                    GX.qYlim1 = min(param.qz); GX.qYlim2 = max(param.qz);
                case 'Qy/Qz'
                    GX.qXlim1 = min(param.qy); GX.qXlim2 = max(param.qy);
                    GX.qYlim1 = min(param.qz); GX.qYlim2 = max(param.qz);
            end
            param.cmin = min(param.data(param.data > 0), [], 'omitnan');
            param.cmax = max(param.data(:), [], 'omitnan');
            GX.cMax.Value = double(param.cmax);
            GX.cMin.Value = double(param.cmin);
            close(d);
            renderImage();
            GX.btnQcal.BackgroundColor = [0.75 0.95 0.75];
        catch ME
            close(d);
            uialert(GUI.main, ['Error during Q-Map: ' ME.message], 'Error');
        end
    end

    function PointFindLine_Callback(~,~)
        if isfield(param, 'hPLine') && isvalid(param.hPLine), delete(param.hPLine); end
        param.hPLine = drawpoint(hAX, 'Color', 'y', 'Label', 'Target');
        x = param.hPLine.Position(1); y = param.hPLine.Position(2);
        
        switch param.Mapping
            case 'Pixel', GX.h1dzpos.Value = double(fix(y)); GX.h1dypos.Value = double(fix(x));
            case 'Alpha', uialert(GUI.main, 'Please use pixel map or Qmap','Warning'); return;
            case 'Qxy/Qz', [~, xpos] = min(abs(param.qr - x)); [~, ypos] = min(abs(param.qz - y)); GX.h1dzpos.Value = double(fix(param.bpos(2) - ypos)); GX.h1dypos.Value = double(fix(xpos - param.bpos(1)));
            case 'Qy/Qz', [~, xpos] = min(abs(param.qy - x)); [~, ypos] = min(abs(param.qz - y)); GX.h1dzpos.Value = double(fix(param.bpos(2) - ypos)); GX.h1dypos.Value = double(fix(xpos - param.bpos(1)));
        end
    end

    function Drawline_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'QMap first!!','Warning'); return; end
        param.Mapping = GX.hMapping.Value; PixelAccumOn = GX.hAccum.Value; CakeCutOn = GX.hCakecut.Value;
        
        param.ang = single(GX.h1dphi.Value); param.zposmv = single(GX.h1dzpos.Value); param.yposmv = single(GX.h1dypos.Value); param.fontsize = GX.FontSz.Value;
        linepos = calculateLinePositions(PixelAccumOn, CakeCutOn); if isempty(linepos), return; end
        renderImage(@() drawLineOverlay(linepos, PixelAccumOn, CakeCutOn));
    end

    function linepos = calculateLinePositions(PixelAccumOn, CakeCutOn)
        Quncertain = GX.hQuncertain.Value;
        if PixelAccumOn == 0
            if CakeCutOn == 0
                if isfield(param, 'Q_std'), [linepos, param.line1dang] = Anglecut1d_giplus(param); else, [linepos, param.line1dang] = Anglecut1d_gi(param); end
            else
                stCKang = single(GX.hCkcutst.Value); fiCKang = single(GX.hCkcutfi.Value);
                if param.ang + stCKang < 0 || param.ang + fiCKang > 180, uialert(GUI.main, 'Invalid Cakecut degree!!','Warning'); linepos=[]; return; end
                [linepos, param.line1dang] = CakeCut_gi(param, stCKang, fiCKang);
                if Quncertain == 1, uialert(GUI.main, 'Cakecut not working for Q uncertainty!','Warning'); end
            end
        else
            if CakeCutOn == 1, uialert(GUI.main, 'Turn off Cakecut!!','Warning'); linepos=[]; return; end
            mPix = single(GX.h1dAmpix.Value); pPix = single(GX.h1dAppix.Value);
            if param.ang == 0 || param.ang == 90 || param.ang == 180, [linepos, param.line1dang] = Accumpix_gi(param, mPix, pPix); else, uialert(GUI.main, 'Use angle 0/90/180!!','Warning'); linepos=[]; return; end
        end
        linepos = single(linepos); param.line1dang = single(param.line1dang);
    end

    function drawLineOverlay(linepos, PixelAccumOn, CakeCutOn)
        if PixelAccumOn == 0 && CakeCutOn == 0
            [x1, y1, x2, y2] = convertLineCoords(linepos(1), linepos(2), linepos(3), linepos(4));
            plot(hAX, [x1, x2], [y1, y2], '-w', 'LineWidth', 2);
        else
            if size(linepos, 2) < 2, uialert(GUI.main, 'Input right angle','Warning'); return; end
            [x11, y11, x21, y21] = convertLineCoords(linepos(1,1), linepos(2,1), linepos(3,1), linepos(4,1));
            [x12, y12, x22, y22] = convertLineCoords(linepos(1,2), linepos(2,2), linepos(3,2), linepos(4,2));
            plot(hAX, [x11, x21], [y11, y21], '-w', 'LineWidth', 2); plot(hAX, [x12, x22], [y12, y22], '-w', 'LineWidth', 2);
        end
    end

    function [x1, y1, x2, y2] = convertLineCoords(xmin, xmax, ymin, ymax)
        switch param.Mapping
            case 'Pixel', x1 = xmin; x2 = xmax; y1 = ymin; y2 = ymax;
            case 'Alpha', [~, xp1] = min(abs(param.HD - xmin)); [~, xp2] = min(abs(param.HD - xmax)); [~, yp1] = min(abs(param.VD - ymin)); [~, yp2] = min(abs(param.VD - ymax)); x1 = param.tth(xp1); x2 = param.tth(xp2); y1 = param.af(yp1); y2 = param.af(yp2);
            case 'Qxy/Qz', [~, xp1] = min(abs(param.HD - xmin)); [~, xp2] = min(abs(param.HD - xmax)); [~, yp1] = min(abs(param.VD - ymin)); [~, yp2] = min(abs(param.VD - ymax)); x1 = param.qr(xp1); x2 = param.qr(xp2); y1 = param.qz(yp1); y2 = param.qz(yp2);
            case 'Qy/Qz', [~, xp1] = min(abs(param.HD - xmin)); [~, xp2] = min(abs(param.HD - xmax)); [~, yp1] = min(abs(param.VD - ymin)); [~, yp2] = min(abs(param.VD - ymax)); x1 = param.qy(xp1); x2 = param.qy(xp2); y1 = param.qz(yp1); y2 = param.qz(yp2);
        end
    end

    function Lineplot_Callback(~,~)
        try
            OneDplotQlinegi_gui(param, GUI.main);
        catch ME
            uialert(GUI.main, ['Line plot error: ', ME.message], 'Error');
        end
    end

    function CalcPos_Callback(~,~)
        if ~isfield(param, 'Q') || isempty(param.Q)
            uialert(GUI.main, 'Q-Map이 아직 계산되지 않았습니다. q-Map Cal.을 먼저 실행하세요.', 'Warning');
            return;
        end
        
        pix_pos = GX.azipospix.Value; pix_pos_minus = GX.azipospixm.Value; pix_pos_plus = GX.azipospixp.Value;
        pos_pix = round(pix_pos + param.bpos(1));
        rowIdx = round(param.bpos(2));
        [H, W] = size(param.Q);
        
        % 인덱스 범위 클리핑 (배열 초과 방지)
        rowIdx = max(1, min(H, rowIdx));
        pos_pix = max(1, min(W, pos_pix));
        pos_m = max(1, min(W, round(pos_pix + pix_pos_minus)));
        pos_p = max(1, min(W, round(pos_pix + pix_pos_plus)));
        
        GX.Qpospix.Value = double(param.Q(rowIdx, pos_pix));
        GX.Qpospixm.Value = double(param.Q(rowIdx, pos_m));
        GX.Qpospixp.Value = double(param.Q(rowIdx, pos_p));
    end

    function CalcQpos_Callback(~,~)
        if ~isfield(param, 'Q') || isempty(param.Q), return; end
        Q_pos = GX.Qpospix.Value;
        rowIdx = max(1, min(size(param.Q,1), round(param.bpos(2))));
        [~, pix_pos] = min(abs(param.Q(rowIdx, :) - Q_pos));
        GX.azipospix.Value = double(round(abs(param.HD(pix_pos))));
    end

    function PointFindAzi_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'Q-Map first!','Warning'); return; end
        if isfield(param, 'hAPline') && isvalid(param.hAPline), delete(param.hAPline); end
        param.hAPline = drawpoint(hAX, 'Color', 'm', 'Label', 'Azi Target');
        x = param.hAPline.Position(1); y = param.hAPline.Position(2);
        
        switch param.Mapping
            case 'Pixel', GX.azipospix.Value = round(double(sqrt(x^2 + y^2))); CalcPos_Callback();
            case 'Alpha', uialert(GUI.main, 'Please use pixel map or Qmap','Warning'); return;
            case {'Qxy/Qz', 'Qy/Qz'}, GX.Qpospix.Value = double(sqrt(x^2 + y^2)); CalcQpos_Callback();
        end
    end

    % [핵심 수정] Azimuthal 연산 로직에 Gap & Spike 제거 이식
    function DrawPlot_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'qMap first!!','Warning'); return; end
        
        param.Mapping = GX.hMapping.Value;
        pix_pos = GX.azipospix.Value; pix_pos_minus = GX.azipospixm.Value; pix_pos_plus = GX.azipospixp.Value;
        pix_zposp = GX.Zpospixp.Value; param.fontsize = GX.FontSz.Value;
        
        theta = (0:0.2:180)' + 180;
        
        switch param.Mapping
            case 'Pixel', PlotAzi = param.data;
            case 'Alpha', PlotAzi = param.AlphaMap;
            case {'Qxy/Qz', 'Qy/Qz'}, PlotAzi = param.Itrans;
        end
        
        % [수정] radii 범위 계산: pix_pos + minus ~ pix_pos + plus (직관적)
        radii = (pix_pos + pix_pos_minus) : (pix_pos + pix_pos_plus);
        
        [ThetaGrid, RGrid] = meshgrid(theta, radii);
        X_idx = round(RGrid .* cosd(ThetaGrid) + param.bpos(1));
        Y_idx = round(RGrid .* sind(ThetaGrid) + param.bpos(2) - pix_zposp);
        
        valid = (X_idx >= 1) & (X_idx <= param.dataSize(2)) & (Y_idx >= 1) & (Y_idx <= param.dataSize(1));

        % 데이터 추출 (1회만 수행)
        D = PlotAzi;

        % gap 경계에 바로 붙은 실측 픽셀(하드웨어 edge bias 가능)은 3픽셀 버퍼로 추가 제외.
        % detector-pixel 공간(Pixel/Alpha)에서만 유효; Q-remapped Itrans는 크기가 달라 자동 skip.
        if isfield(param, 'Mask') && isequal(size(param.Mask), size(D))
            gapAdj = dilatePGIXSGapMask(param.Mask, 3);
            idxTmp = sub2ind(size(D), Y_idx(valid), X_idx(valid));
            validSub = ~gapAdj(idxTmp);
            valid(valid) = validSub;
        end

        IndMap = nan(size(ThetaGrid), 'single');
        IndMap(valid) = sub2ind(size(D), Y_idx(valid), X_idx(valid));
        
        Vals = nan(size(IndMap), 'single');
        good = ~isnan(IndMap);
        Vals(good) = D(IndMap(good));
        Vals = Vals';  % shape: [length(theta) x length(radii)]
        
        % Mean/Median 평균
        if strcmp(GX.hMeanMed.Value, 'Mean')
            SumTemp = mean(Vals, 2, 'omitnan');
        else
            SumTemp = median(Vals, 2, 'omitnan');
        end
        
        % --- NaN/갭 처리 정책: 보간·평활 없이 단순 제외 ---
        %   유효 픽셀 0개 방향만 NaN. (omitnan 평균이 이미 갭을 제외함)
        valid_counts = sum(~isnan(Vals), 2);
        SumTemp(valid_counts < 1) = NaN;

        % 시각적 표시 처리 — 적분 링 강조
        valid_indices = IndMap(good);
        PlotAzi(valid_indices) = max(param.data(:)) * 1.5;
        cla(hAX);
        switch param.Mapping
            case 'Pixel', imagesc(hAX, param.HD, param.VD, PlotAzi); set(hAX, 'YDir', 'normal'); xlabel(hAX, 'Y, pixel'); ylabel(hAX, 'Z, pixel');
            case 'Alpha', imagesc(hAX, param.tth, param.af, PlotAzi); set(hAX, 'YDir', 'normal'); xlabel(hAX, '$2\theta_f$', 'Interpreter', 'latex', 'Fontname', 'TimesNewRoman'); ylabel(hAX, '$\alpha_f$', 'Interpreter', 'latex', 'Fontname', 'TimesNewRoman');
            case 'Qxy/Qz', imagesc(hAX, param.qr, param.qz, PlotAzi); set(hAX, 'YDir', 'normal'); xlabel(hAX, 'q_{xy}, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman'); ylabel(hAX, 'q_z, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
            case 'Qy/Qz', imagesc(hAX, param.qy, param.qz, PlotAzi); set(hAX, 'YDir', 'normal'); xlabel(hAX, 'q_y, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman'); ylabel(hAX, 'q_z, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
        end
        axis(hAX, 'image'); clim(hAX, [param.cmin, param.cmax]);
        applyPGIXSAxesColorScale(hAX, param.colorscale);
        applyColormap(param.colorm, param.data); setupColorbar();
        setupAxesStyle(param.fontsize, param.FileName);
        
        param.Azi = zeros(length(theta), 2, 'single'); param.Azi(:,1) = single(theta); param.Azi(:,2) = single(SumTemp);
        drawnow();
    end

    function AziPlot_Callback(~,~)
        try
            OneDplotAzi_gi_gui(param, GUI.main);
        catch ME
            uialert(GUI.main, ['Azimuthal plot error: ', ME.message], 'Error');
        end
    end

    function Savefile_Callback(~,~)
        if param.correctionI == 0, uialert(GUI.main, 'QMap first!!','Warning'); return; end
        SaveForm = GX.hSvForm.Value;
        [filepath, ok, report] = ensurePGIXSSaveDir(param.Path, param.FileName, pwd);
        if ~ok, uialert(GUI.main, ['Save directory failed: ' report.Message], 'Error'); return; end
        
        FN = param.FileName;
        selection = uiconfirm(GUI.main, 'Change filename?', 'Confirmation', 'Options', {'Yes','No'}, 'DefaultOption', 'Yes');
        if strcmp(selection, 'Yes')
            [FN, nameOK] = promptPGIXSSaveFileBaseName(NewFileName(param.FileName), SaveForm, 'Save 2D Data As');
            if ~nameOK, return; end
        end
        
        d = uiprogressdlg(GUI.main, 'Title', 'Saving', 'Message', 'Saving...', 'Indeterminate', 'on');
        
        try
            saveData = prepareSaveData();
            SaveFilepath = fullfile(filepath, [FN, '_2Dinfo.mat']);
            savePGIXS2DInfoFile(SaveFilepath, saveData);
        catch ME
            close(d);
            uialert(GUI.main, ['2D info save failed: ' ME.message], 'Save Error');
            return;
        end
        
        % [핵심 수정] exportgraphics 타겟을 명확히 uiaxes(hAX)로 지정
        SaveFigurepath = fullfile(filepath, [FN, '_2DImage', SaveForm]);
        [exportOK, exportReport] = exportPGIXSAxesImage(hAX, SaveFigurepath, 300);
        if ~exportOK
            uialert(GUI.main, ['Image export failed: ', exportReport.Message], 'Warning');
        end
        
        close(d); uialert(GUI.main, 'Save is done!', 'Success');
    end

    function saveData = prepareSaveData()
        saveData = buildPGIXS2DInfo(param, 'GIXS');
    end

    function Resize_Callback(src, ~)
        referenceHeight = 900; 
        original_units = get(src, 'Units'); set(src, 'Units', 'pixels'); pos = get(src, 'Position'); currHeight = pos(4); set(src, 'Units', original_units); 
        
        scaleFactor = max(0.5, currHeight / referenceHeight);
        allObj = findall(src, '-property', 'FontSize');
        
        for i = 1:length(allObj)
            obj = allObj(i);
            if isempty(get(obj, 'UserData')) || ~isstruct(get(obj, 'UserData')) || ~isfield(get(obj, 'UserData'), 'BaseFontSize')
                baseSize = get(obj, 'FontSize'); ud.BaseFontSize = baseSize; set(obj, 'UserData', ud);
            else
                ud = get(obj, 'UserData');
                baseSize = ud.BaseFontSize;
            end
            set(obj, 'FontSize', baseSize * scaleFactor);
        end
    end
end
