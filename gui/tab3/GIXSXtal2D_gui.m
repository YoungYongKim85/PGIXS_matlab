function GIXSXtal2D_gui
%#ok<*AGROW,*NASGU,*DEFNU,*ALIGN,*INUSD>

    % ========================================================================
    % Global Variables & Initialization
    % ========================================================================
    param = struct();
    param.data = [];
    params = struct();
    params.data = []; 
    param.dataq = []; 
    param.Wavelength = 1.54; 
    lastCrystSys = ''; % Structure_Callback에서 "Crystal System이 실제로
                        % 바뀌었을 때만" 격자상수를 리셋하기 위한 기억값

    coldf = [0.95 0.95 0.95]; 

    % ========================================================================
    % 📌 메인 Figure 생성 및 겹침 방지를 위한 와이드 해상도 적용
    % ========================================================================
    figW = 1500; % 컴포넌트 겹침을 방지하기 위해 가로 폭 대폭 확장
    figH = 900;  
    
    main = uifigure;
    main.Name = 'GIXS-indexing';
    main.NumberTitle = 'off';
    main.Position = [100 100 figW figH];
    main.AutoResizeChildren = 'off';
    main.SizeChangedFcn = @Resize_Callback;
    main.WindowKeyPressFcn = @KeyPress_Callback;
    main.Color = coldf;
    
    movegui(main, 'center'); % 프로그램 실행 시 화면 정중앙에 띄우기

    % --- 📌 헬퍼 함수: Normalized(0~1) 값을 Pixel 값으로 자동 변환 ---
    function setPos(obj, pW, pH, normPos)
        obj.Position = [normPos(1)*pW, normPos(2)*pH, normPos(3)*pW, normPos(4)*pH];
    end
    % ----------------------------------------------------------------

    % --- 📌 헬퍼 함수: uipanel의 "내부 콘텐츠 높이"를 반환 ---
    % uipanel.Position(4)는 제목 표시줄을 포함한 전체 높이이지만, 자식
    % 위젯의 y=1(맨 위)은 제목 표시줄 "아래쪽" 내부 영역의 맨 위를 의미한다.
    % 이 차이를 보정하지 않으면 위쪽에 배치된 위젯일수록 제목 표시줄에
    % 가려지거나 밀려 보인다. 기본 FontSize(10~12pt) 기준 근사값으로 뺀다.
    TITLE_PX = 28;
    function h = innerH(panelObj)
        h = panelObj.Position(4) - TITLE_PX;
    end
    % ----------------------------------------------------------------

    % ========================================================================
    % 패널(Panel) 레이아웃 생성 (Unchaining 적용)
    % ========================================================================
    leftPanelData = uipanel(main);
    leftPanelData.Title = 'Parameter Panel';
    leftPanelData.FontSize = 12;
    setPos(leftPanelData, figW, figH, [0.01 0.01 0.28 0.98]); % 좌측 패널 넓게 확보
    lpW = leftPanelData.Position(3); lpH = innerH(leftPanelData);

    Im2Dplot = uipanel(main);
    Im2Dplot.Title = 'GIXS-Indexing';
    Im2Dplot.FontSize = 12;
    Im2Dplot.BackgroundColor = [1 1 1];
    setPos(Im2Dplot, figW, figH, [0.30 0.10 0.69 0.89]);
    imW = Im2Dplot.Position(3); imH = innerH(Im2Dplot);

    % 📌 유령 Figure 차단을 위해 uiaxes가 아닌 호환 axes 사용
    hAXtab = axes(Im2Dplot);
    hAXtab.Units = 'pixels';
    setPos(hAXtab, imW, imH, [0.06 0.06 0.90 0.90]); 

    ImageController = uipanel(main);
    ImageController.Title = 'Image Controller';
    ImageController.FontSize = 10;
    setPos(ImageController, figW, figH, [0.30 0.01 0.69 0.08]);
    icW = ImageController.Position(3); icH = innerH(ImageController);

    % [Fix] 기존에는 lblVersion이 main의 자식이라 leftPanelData(및 그 안의
    % Navigator 패널) 위에 그대로 겹쳐서 그려지고 있었음. leftPanelData의
    % 자식으로 옮기고, Navigator 패널 아래에 별도 여백을 확보해 배치.
    lblVersion = uilabel(leftPanelData);
    lblVersion.Text = ['Designed By Y.Y.Kim v', pgixsVersion(), ' (Modern UI)'];
    lblVersion.BackgroundColor = coldf;
    lblVersion.FontSize = 10;
    setPos(lblVersion, lpW, lpH, [0.03 0.008 0.90 0.03]);

    % ========================================================================
    % Left Panel: Data & Parameters (간격 재조정 완료)
    % ========================================================================
    btnOpen = uibutton(leftPanelData, 'push');
    btnOpen.Text = 'Open data';
    btnOpen.FontSize = 11;
    btnOpen.FontWeight = 'bold';
    setPos(btnOpen, lpW, lpH, [0.035 0.93 0.4 0.055]);
    btnOpen.ButtonPushedFcn = @Opendata_Callback;

    lblIncidA = uilabel(leftPanelData);
    lblIncidA.Text = 'Inci. ang. [deg]';
    lblIncidA.BackgroundColor = coldf;
    setPos(lblIncidA, lpW, lpH, [0.47 0.96 0.28 0.02]);

    hIncidA = uieditfield(leftPanelData, 'text');
    hIncidA.Value = '0.1';
    setPos(hIncidA, lpW, lpH, [0.75 0.955 0.18 0.03]);

    lblCritiA = uilabel(leftPanelData);
    lblCritiA.Text = 'Crit. ang. [deg]';
    lblCritiA.BackgroundColor = coldf;
    setPos(lblCritiA, lpW, lpH, [0.47 0.92 0.28 0.02]);

    hCritiA = uieditfield(leftPanelData, 'text');
    hCritiA.Value = '0.1';
    setPos(hCritiA, lpW, lpH, [0.75 0.915 0.18 0.03]);

    lblCalc = uilabel(leftPanelData);
    lblCalc.Text = 'Calculator';
    lblCalc.BackgroundColor = coldf;
    setPos(lblCalc, lpW, lpH, [0.47 0.88 0.28 0.02]);

    btnRefrac = uibutton(leftPanelData, 'push');
    btnRefrac.Text = 'Refrac.';
    setPos(btnRefrac, lpW, lpH, [0.75 0.875 0.18 0.03]);
    btnRefrac.ButtonPushedFcn = @Refrac_Callback;

    lblCrystal = uilabel(leftPanelData);
    lblCrystal.Text = 'Crystal System';
    lblCrystal.BackgroundColor = coldf;
    setPos(lblCrystal, lpW, lpH, [0.05 0.84 0.30 0.02]);

    XTal.CrystalSystem = {'Layer','Hexagonal','HCP','Cubic','Orthorhombic','Tetragonal','Monoclinic','Rhombohedral','Triclinic','Helical', 'Tri_Helical'};
    XTal.hCrystsys = uidropdown(leftPanelData);
    XTal.hCrystsys.Items = XTal.CrystalSystem;
    setPos(XTal.hCrystsys, lpW, lpH, [0.05 0.79 0.30 0.04]);
    XTal.hCrystsys.ValueChangedFcn = @SpaceGroup_Callback;

    lblSpaceGrp = uilabel(leftPanelData);
    lblSpaceGrp.Text = 'Space Group';
    lblSpaceGrp.BackgroundColor = coldf;
    setPos(lblSpaceGrp, lpW, lpH, [0.38 0.84 0.25 0.02]);

    XTal.hSpaceGrp = uidropdown(leftPanelData);
    XTal.hSpaceGrp.Items = {'primitive'}; 
    setPos(XTal.hSpaceGrp, lpW, lpH, [0.38 0.79 0.25 0.04]);
    XTal.hSpaceGrp.ValueChangedFcn = @Structure_Callback;

    lblChoice = uilabel(leftPanelData);
    lblChoice.Text = 'Choice';
    lblChoice.BackgroundColor = coldf;
    setPos(lblChoice, lpW, lpH, [0.68 0.84 0.25 0.02]);

    XTal.hChoice = uidropdown(leftPanelData);
    XTal.hChoice.Items = {'1'};
    setPos(XTal.hChoice, lpW, lpH, [0.68 0.79 0.25 0.04]);

    lblNorm = uilabel(leftPanelData);
    lblNorm.Text = 'Normal Direction';
    lblNorm.BackgroundColor = coldf;
    setPos(lblNorm, lpW, lpH, [0.12 0.75 0.375 0.02]);

    NormdirecList = {'001', '010', '100', '101', '011', '110', '111', '121'};
    hNormDirec = uidropdown(leftPanelData);
    hNormDirec.Items = NormdirecList;
    setPos(hNormDirec, lpW, lpH, [0.53 0.74 0.32 0.04]);

    % Lattice Parameters
    lblA = uilabel(leftPanelData);
    lblA.Text = 'a [A,h]';
    lblA.BackgroundColor = coldf;
    setPos(lblA, lpW, lpH, [0.03 0.69 0.15 0.02]);
    
    GX.haunit = uieditfield(leftPanelData, 'text');
    GX.haunit.Value = '1';
    setPos(GX.haunit, lpW, lpH, [0.18 0.685 0.15 0.03]);

    lblB = uilabel(leftPanelData);
    lblB.Text = 'b [A,k]';
    lblB.BackgroundColor = coldf;
    setPos(lblB, lpW, lpH, [0.03 0.65 0.15 0.02]);
    
    GX.hbunit = uieditfield(leftPanelData, 'text');
    GX.hbunit.Value = '1';
    setPos(GX.hbunit, lpW, lpH, [0.18 0.645 0.15 0.03]);

    lblC = uilabel(leftPanelData);
    lblC.Text = 'c [A,l]';
    lblC.BackgroundColor = coldf;
    setPos(lblC, lpW, lpH, [0.03 0.61 0.15 0.02]);
    
    GX.hcunit = uieditfield(leftPanelData, 'text');
    GX.hcunit.Value = '1';
    setPos(GX.hcunit, lpW, lpH, [0.18 0.605 0.15 0.03]);

    lblAlpha = uilabel(leftPanelData);
    lblAlpha.Text = 'alpha';
    lblAlpha.BackgroundColor = coldf;
    setPos(lblAlpha, lpW, lpH, [0.35 0.69 0.15 0.02]);
    
    GX.halpha = uieditfield(leftPanelData, 'text');
    GX.halpha.Value = '90';
    setPos(GX.halpha, lpW, lpH, [0.50 0.685 0.15 0.03]);

    lblBeta = uilabel(leftPanelData);
    lblBeta.Text = 'beta';
    lblBeta.BackgroundColor = coldf;
    setPos(lblBeta, lpW, lpH, [0.35 0.65 0.15 0.02]);
    
    GX.hbeta = uieditfield(leftPanelData, 'text');
    GX.hbeta.Value = '90';
    setPos(GX.hbeta, lpW, lpH, [0.50 0.645 0.15 0.03]);

    lblGamma = uilabel(leftPanelData);
    lblGamma.Text = 'gamma';
    lblGamma.BackgroundColor = coldf;
    setPos(lblGamma, lpW, lpH, [0.35 0.61 0.15 0.02]);
    
    GX.hgamma = uieditfield(leftPanelData, 'text');
    GX.hgamma.Value = '90';
    setPos(GX.hgamma, lpW, lpH, [0.50 0.605 0.15 0.03]);

    % Plot Button
    btnPlot = uibutton(leftPanelData, 'push');
    btnPlot.Text = 'Plot';
    btnPlot.FontWeight = 'bold';
    setPos(btnPlot, lpW, lpH, [0.68 0.62 0.28 0.09]);
    btnPlot.ButtonPushedFcn = @Xtalplot_Callback;

    % HKL Range
    lblH = uilabel(leftPanelData);
    lblH.Text = '±H';
    lblH.BackgroundColor = coldf;
    setPos(lblH, lpW, lpH, [0.06 0.57 0.1 0.02]);
    
    hHidx = uieditfield(leftPanelData, 'text');
    hHidx.Value = '3';
    setPos(hHidx, lpW, lpH, [0.16 0.565 0.15 0.03]);

    lblK = uilabel(leftPanelData);
    lblK.Text = '±K';
    lblK.BackgroundColor = coldf;
    setPos(lblK, lpW, lpH, [0.31 0.57 0.1 0.02]);
    
    hKidx = uieditfield(leftPanelData, 'text');
    hKidx.Value = '3';
    setPos(hKidx, lpW, lpH, [0.41 0.565 0.15 0.03]);

    lblL = uilabel(leftPanelData);
    lblL.Text = '±L';
    lblL.BackgroundColor = coldf;
    setPos(lblL, lpW, lpH, [0.56 0.57 0.1 0.02]);
    
    hLidx = uieditfield(leftPanelData, 'text');
    hLidx.Value = '3';
    setPos(hLidx, lpW, lpH, [0.66 0.565 0.15 0.03]);

    % Orientation
    lblXrot = uilabel(leftPanelData);
    lblXrot.Text = 'X-rot';
    lblXrot.BackgroundColor = coldf;
    setPos(lblXrot, lpW, lpH, [0.06 0.53 0.1 0.02]);
    
    hXrot = uieditfield(leftPanelData, 'text');
    hXrot.Value = '0';
    setPos(hXrot, lpW, lpH, [0.16 0.525 0.15 0.03]);

    lblYrot = uilabel(leftPanelData);
    lblYrot.Text = 'Y-rot';
    lblYrot.BackgroundColor = coldf;
    setPos(lblYrot, lpW, lpH, [0.31 0.53 0.1 0.02]);
    
    hYrot = uieditfield(leftPanelData, 'text');
    hYrot.Value = '0';
    setPos(hYrot, lpW, lpH, [0.41 0.525 0.15 0.03]);

    lblZrot = uilabel(leftPanelData);
    lblZrot.Text = 'Z-rot';
    lblZrot.BackgroundColor = coldf;
    setPos(lblZrot, lpW, lpH, [0.56 0.53 0.1 0.02]);
    
    hZrot = uieditfield(leftPanelData, 'text');
    hZrot.Value = '0';
    setPos(hZrot, lpW, lpH, [0.66 0.525 0.15 0.03]);

    % Checkboxes & Dropdowns (겹침 수정)
    hWyckoff = uidropdown(leftPanelData);
    hWyckoff.Items = {'General', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
    setPos(hWyckoff, lpW, lpH, [0.03 0.48 0.24 0.035]);
    hWyckoff.ValueChangedFcn = @Xtalplot_Callback;

    hRandOri = uicheckbox(leftPanelData);
    hRandOri.Text = 'Random Ori.';
    hRandOri.Value = false;
    setPos(hRandOri, lpW, lpH, [0.29 0.48 0.22 0.03]);

    hHoldingS = uicheckbox(leftPanelData);
    hHoldingS.Text = 'Holding';
    hHoldingS.Value = false;
    setPos(hHoldingS, lpW, lpH, [0.52 0.48 0.22 0.03]);
    hHoldingS.ValueChangedFcn = @Holding_Callback;

    hEwaldS = uicheckbox(leftPanelData);
    hEwaldS.Text = 'Ewald';
    hEwaldS.Value = false;
    setPos(hEwaldS, lpW, lpH, [0.75 0.48 0.22 0.03]);

    % HKL Plot Panel
    HKLplot = uipanel(leftPanelData);
    HKLplot.Title = 'HKLplot';
    HKLplot.FontSize = 10;
    setPos(HKLplot, lpW, lpH, [0.03 0.38 0.47 0.09]);
    hpW = HKLplot.Position(3); hpH = innerH(HKLplot);

    hHKLCheck = uicheckbox(HKLplot);
    hHKLCheck.Text = 'Trans.';
    hHKLCheck.Value = false;
    setPos(hHKLCheck, hpW, hpH, [0.05 0.60 0.4 0.3]);

    hHKLRefl = uicheckbox(HKLplot);
    hHKLRefl.Text = 'Reflec.';
    hHKLRefl.Value = false;
    setPos(hHKLRefl, hpW, hpH, [0.05 0.15 0.4 0.3]);

    hHKLplane = uicheckbox(HKLplot);
    hHKLplane.Text = 'Plane';
    hHKLplane.Value = false;
    setPos(hHKLplane, hpW, hpH, [0.50 0.60 0.3 0.3]);

    hPLNsize = uieditfield(HKLplot, 'text');
    hPLNsize.Value = '9';
    setPos(hPLNsize, hpW, hpH, [0.80 0.60 0.15 0.35]);
    hPLNsize.ValueChangedFcn = @Updateimage_Callback;

    PLNpos = {'left', 'center', 'right', 'top', 'bottom'};
    hPLNpos = uidropdown(HKLplot);
    hPLNpos.Items = PLNpos;
    setPos(hPLNpos, hpW, hpH, [0.50 0.15 0.45 0.35]);
    hPLNpos.ValueChangedFcn = @Updateimage_Callback;

    % Bottom Buttons
    % [Fix] 기존 2x2 버튼(높이 0.04짜리 2줄)을 살짝 줄여서(0.025씩) 3번째
    % 줄에 "Fine-tune" 체크박스를 넣을 자리를 만들었다. 사용자가 이미 수동
    % 조정으로 꽤 맞는 파라미터를 찾아둔 상태에서, Solve를 누르면 8개 Normal
    % Direction/여러 스케일/각도를 전부 다시 뒤지는 넓은 탐색 대신, "지금
    % 화면에 있는 값 + 지금 Normal Direction"에서만 국소적으로 미세조정하고
    % 싶다는 요청 반영.
    btnTable = uibutton(leftPanelData, 'push');
    btnTable.Text = 'Table';
    setPos(btnTable, lpW, lpH, [0.53 0.435 0.20 0.025]);
    btnTable.ButtonPushedFcn = @HKLTable_Callback;

    btnSolve = uibutton(leftPanelData, 'push');
    btnSolve.Text = 'Solve';
    setPos(btnSolve, lpW, lpH, [0.75 0.435 0.20 0.025]);
    btnSolve.ButtonPushedFcn = @Solveparam_Callback;

    btnErase = uibutton(leftPanelData, 'push');
    btnErase.Text = 'Erase Peak';
    setPos(btnErase, lpW, lpH, [0.53 0.405 0.20 0.025]);
    btnErase.ButtonPushedFcn = @ErasePeak_Callback;

    btnSmart = uibutton(leftPanelData, 'push');
    btnSmart.Text = 'Smart Range';
    setPos(btnSmart, lpW, lpH, [0.75 0.405 0.20 0.025]);
    btnSmart.ButtonPushedFcn = @SmartRange_Callback;

    hFineTune = uicheckbox(leftPanelData);
    hFineTune.Text = 'Fine-tune (현재 값에서 국소 최적화만)';
    hFineTune.Value = false;
    hFineTune.FontSize = 9;
    setPos(hFineTune, lpW, lpH, [0.53 0.375 0.44 0.025]);

    % Color/Shape Selectors
    colorcode = {'white','black','red','orange','yellow','green','blue','magenta','purple'};
    shapecode = {'circle','square','diamond','pentagram','hexagram'};
    % [Fix] Hold/Current 옵션 패널 폭이 좁아(약 190px) 원래 색상/모양 전체
    % 이름을 그대로 표시하면 "w...", "ci..." 처럼 잘려 보였음. 드롭다운에는
    % 짧은 표시용 라벨(colorLabel/shapeLabel)만 보여주고, 실제 .Value는
    % ItemsData를 통해 기존과 동일한 전체 이름(colorcode/shapecode)이 그대로
    % 반환되도록 해서 이후 로직(ColorSelector 등)은 전혀 변경하지 않아도 됨.
    colorLabel = {'White','Black','Red','Orange','Yellow','Green','Blue','Magenta','Purple'};
    shapeLabel = {'Circle','Square','Diamond','Pentagram','Hexagram'};

    % ========================================================================
    % 📌 Option 패널 재정렬 (겹침 100% 해소)
    % ========================================================================
    OptionO = uipanel(leftPanelData);
    OptionO.Title = 'Hold (opt.)';
    OptionO.FontSize = 10;
    setPos(OptionO, lpW, lpH, [0.03 0.18 0.46 0.19]);
    ooW = OptionO.Position(3); ooH = innerH(OptionO);
    
    lblHO_T = uilabel(OptionO); lblHO_T.Text = 'Trans.'; lblHO_T.BackgroundColor = coldf; setPos(lblHO_T, ooW, ooH, [0.35 0.78 0.30 0.15]);
    lblHO_R = uilabel(OptionO); lblHO_R.Text = 'Reflec.'; lblHO_R.BackgroundColor = coldf; setPos(lblHO_R, ooW, ooH, [0.65 0.78 0.30 0.15]);
    
    lblHO_C = uilabel(OptionO); lblHO_C.Text = 'Color'; lblHO_C.BackgroundColor = coldf; setPos(lblHO_C, ooW, ooH, [0.02 0.55 0.30 0.15]);
    hSTColorO = uidropdown(OptionO); hSTColorO.Items = colorLabel; hSTColorO.ItemsData = colorcode; setPos(hSTColorO, ooW, ooH, [0.35 0.55 0.28 0.18]);
    hSRColorO = uidropdown(OptionO); hSRColorO.Items = colorLabel; hSRColorO.ItemsData = colorcode; setPos(hSRColorO, ooW, ooH, [0.65 0.55 0.28 0.18]);
    
    lblHO_S = uilabel(OptionO); lblHO_S.Text = 'Shape'; lblHO_S.BackgroundColor = coldf; setPos(lblHO_S, ooW, ooH, [0.02 0.30 0.30 0.15]);
    hSTShapeO = uidropdown(OptionO); hSTShapeO.Items = shapeLabel; hSTShapeO.ItemsData = shapecode; setPos(hSTShapeO, ooW, ooH, [0.35 0.30 0.28 0.18]);
    hSRShapeO = uidropdown(OptionO); hSRShapeO.Items = shapeLabel; hSRShapeO.ItemsData = shapecode; setPos(hSRShapeO, ooW, ooH, [0.65 0.30 0.28 0.18]);
    
    lblHO_Sz = uilabel(OptionO); lblHO_Sz.Text = 'Size'; lblHO_Sz.BackgroundColor = coldf; setPos(lblHO_Sz, ooW, ooH, [0.02 0.05 0.30 0.15]);
    hSTSizeO = uieditfield(OptionO, 'text'); hSTSizeO.Value = '6'; setPos(hSTSizeO, ooW, ooH, [0.35 0.05 0.15 0.18]);
    hSRSizeO = uieditfield(OptionO, 'text'); hSRSizeO.Value = '6'; setPos(hSRSizeO, ooW, ooH, [0.52 0.05 0.15 0.18]);
    hSEmptyO = uicheckbox(OptionO); hSEmptyO.Text = 'Empty'; hSEmptyO.Value = false; setPos(hSEmptyO, ooW, ooH, [0.70 0.05 0.28 0.15]);

    OptionN = uipanel(leftPanelData);
    OptionN.Title = 'Current (opt.)';
    OptionN.FontSize = 10;
    setPos(OptionN, lpW, lpH, [0.51 0.18 0.46 0.19]);
    onW = OptionN.Position(3); onH = innerH(OptionN);
    
    lblHN_T = uilabel(OptionN); lblHN_T.Text = 'Trans.'; lblHN_T.BackgroundColor = coldf; setPos(lblHN_T, onW, onH, [0.35 0.78 0.30 0.15]);
    lblHN_R = uilabel(OptionN); lblHN_R.Text = 'Reflec.'; lblHN_R.BackgroundColor = coldf; setPos(lblHN_R, onW, onH, [0.65 0.78 0.30 0.15]);
    
    lblHN_C = uilabel(OptionN); lblHN_C.Text = 'Color'; lblHN_C.BackgroundColor = coldf; setPos(lblHN_C, onW, onH, [0.02 0.55 0.30 0.15]);
    hSTColorN = uidropdown(OptionN); hSTColorN.Items = colorLabel; hSTColorN.ItemsData = colorcode; setPos(hSTColorN, onW, onH, [0.35 0.55 0.28 0.18]);
    hSRColorN = uidropdown(OptionN); hSRColorN.Items = colorLabel; hSRColorN.ItemsData = colorcode; setPos(hSRColorN, onW, onH, [0.65 0.55 0.28 0.18]);
    
    lblHN_S = uilabel(OptionN); lblHN_S.Text = 'Shape'; lblHN_S.BackgroundColor = coldf; setPos(lblHN_S, onW, onH, [0.02 0.30 0.30 0.15]);
    hSTShapeN = uidropdown(OptionN); hSTShapeN.Items = shapeLabel; hSTShapeN.ItemsData = shapecode; setPos(hSTShapeN, onW, onH, [0.35 0.30 0.28 0.18]);
    hSRShapeN = uidropdown(OptionN); hSRShapeN.Items = shapeLabel; hSRShapeN.ItemsData = shapecode; setPos(hSRShapeN, onW, onH, [0.65 0.30 0.28 0.18]);
    
    lblHN_Sz = uilabel(OptionN); lblHN_Sz.Text = 'Size'; lblHN_Sz.BackgroundColor = coldf; setPos(lblHN_Sz, onW, onH, [0.02 0.05 0.30 0.15]);
    hSTSizeN = uieditfield(OptionN, 'text'); hSTSizeN.Value = '6'; setPos(hSTSizeN, onW, onH, [0.35 0.05 0.15 0.18]);
    hSRSizeN = uieditfield(OptionN, 'text'); hSRSizeN.Value = '6'; setPos(hSRSizeN, onW, onH, [0.52 0.05 0.15 0.18]);
    hSEmptyN = uicheckbox(OptionN); hSEmptyN.Text = 'Empty'; hSEmptyN.Value = false; setPos(hSEmptyN, onW, onH, [0.70 0.05 0.28 0.15]);

    % Navigator
    UnitImage = uipanel(leftPanelData);
    UnitImage.Title = 'Navigator';
    UnitImage.FontSize = 10;
    % [Fix] 아래쪽 0.01~0.055 구간은 lblVersion 자리로 비워둠 (겹침 방지).
    % 기존 top 경계(0.01+0.16=0.17)는 그대로 유지.
    setPos(UnitImage, lpW, lpH, [0.02 0.055 0.95 0.115]);
    uiW = UnitImage.Position(3); uiH = innerH(UnitImage);
    
    % 📌 유령 Figure 차단을 위해 uiaxes가 아닌 호환 axes 사용
    hImunit = axes(UnitImage);
    hImunit.Units = 'pixels';
    setPos(hImunit, uiW, uiH, [0.05 0.05 0.90 0.90]); 

    % ========================================================================
    % 📌 Image Controller Panel 재배치 (완벽 정렬)
    % ========================================================================
    lblScale = uilabel(ImageController); lblScale.Text = 'ColorScale'; lblScale.BackgroundColor = coldf; setPos(lblScale, icW, icH, [0.01 0.60 0.08 0.35]);
    scaleList = {'Linear', 'Log'};
    hScale = uidropdown(ImageController); hScale.Items = scaleList; setPos(hScale, icW, icH, [0.01 0.10 0.08 0.45]); hScale.ValueChangedFcn = @Updateimage_Callback;

    lblColor = uilabel(ImageController); lblColor.Text = 'Colormap'; lblColor.BackgroundColor = coldf; setPos(lblColor, icW, icH, [0.10 0.60 0.08 0.35]);
    ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis','cubehelix','magma','kindlemann','ocean','jet2','rwb','rkb'};
    hColor = uidropdown(ImageController); hColor.Items = ColormapList; setPos(hColor, icW, icH, [0.10 0.10 0.08 0.45]); hColor.ValueChangedFcn = @Updateimage_Callback;

    lblCont = uilabel(ImageController); lblCont.Text = 'Contrast'; lblCont.BackgroundColor = coldf; setPos(lblCont, icW, icH, [0.19 0.60 0.09 0.35]);
    GX.cMin = uieditfield(ImageController, 'text'); GX.cMin.Value = '1'; setPos(GX.cMin, icW, icH, [0.19 0.10 0.04 0.45]); GX.cMin.ValueChangedFcn = @Updateimage_Callback;
    GX.cMax = uieditfield(ImageController, 'text'); GX.cMax.Value = '1e6'; setPos(GX.cMax, icW, icH, [0.24 0.10 0.04 0.45]); GX.cMax.ValueChangedFcn = @Updateimage_Callback;

    lblMapF = uilabel(ImageController); lblMapF.Text = 'Map format'; lblMapF.BackgroundColor = coldf; setPos(lblMapF, icW, icH, [0.29 0.60 0.08 0.35]);
    MapList = {'Pixel', 'Alpha', 'Qxy/Qz', 'Qy/Qz'};
    hMapping = uidropdown(ImageController); hMapping.Items = MapList; setPos(hMapping, icW, icH, [0.29 0.10 0.08 0.45]); hMapping.ValueChangedFcn = @Rangecal_Callback;

    lblYran = uilabel(ImageController); lblYran.Text = 'Y-range'; lblYran.BackgroundColor = coldf; setPos(lblYran, icW, icH, [0.38 0.60 0.09 0.35]);
    GX.cXlim1 = uieditfield(ImageController, 'text'); GX.cXlim1.Value = '1'; setPos(GX.cXlim1, icW, icH, [0.38 0.10 0.04 0.45]); GX.cXlim1.ValueChangedFcn = @Updateimage_Callback;
    GX.cXlim2 = uieditfield(ImageController, 'text'); GX.cXlim2.Value = '2000'; setPos(GX.cXlim2, icW, icH, [0.43 0.10 0.04 0.45]); GX.cXlim2.ValueChangedFcn = @Updateimage_Callback;

    lblZran = uilabel(ImageController); lblZran.Text = 'Z-range'; lblZran.BackgroundColor = coldf; setPos(lblZran, icW, icH, [0.48 0.60 0.09 0.35]);
    GX.cYlim1 = uieditfield(ImageController, 'text'); GX.cYlim1.Value = '1'; setPos(GX.cYlim1, icW, icH, [0.48 0.10 0.04 0.45]); GX.cYlim1.ValueChangedFcn = @Updateimage_Callback;
    GX.cYlim2 = uieditfield(ImageController, 'text'); GX.cYlim2.Value = '2000'; setPos(GX.cYlim2, icW, icH, [0.53 0.10 0.04 0.45]); GX.cYlim2.ValueChangedFcn = @Updateimage_Callback;

    lblFontS = uilabel(ImageController); lblFontS.Text = 'Font Size'; lblFontS.BackgroundColor = coldf; setPos(lblFontS, icW, icH, [0.58 0.60 0.07 0.35]);
    GX.FontSz = uieditfield(ImageController, 'text'); GX.FontSz.Value = '18'; setPos(GX.FontSz, icW, icH, [0.58 0.10 0.04 0.45]); GX.FontSz.ValueChangedFcn = @Updateimage_Callback;

    btnLineCut = uibutton(ImageController, 'push'); btnLineCut.Text = 'Line Cut'; setPos(btnLineCut, icW, icH, [0.68 0.15 0.09 0.70]); btnLineCut.ButtonPushedFcn = @LineCut_Callback;
    btnUpdImg = uibutton(ImageController, 'push'); btnUpdImg.Text = 'Update Image'; setPos(btnUpdImg, icW, icH, [0.78 0.15 0.09 0.70]); btnUpdImg.ButtonPushedFcn = @Updateimage_Callback;
    btnSaveImg = uibutton(ImageController, 'push'); btnSaveImg.Text = 'Save Image'; setPos(btnSaveImg, icW, icH, [0.88 0.15 0.09 0.70]); btnSaveImg.ButtonPushedFcn = @Savefile_Callback;

    % GUI 초기화
    SpaceGroup_Callback([], []);
    Resize_Callback(main, []);

    % ========================================================================
    % Callbacks and Functions
    % ========================================================================

    function Opendata_Callback(~,~)
        % [Fix] 예전 "clear param;"은 param이 이 콜백 하나만의 변수가 아니라
        % Crystal System/Space Group/Normal Direction 등 다른 콜백들과 함께
        % 공유하는(nested function shared) 변수라서, 여기서 통째로 지워버리면
        % 그 값들까지 같이 날아가거나 공유 상태가 꼬일 위험이 있었다(공유
        % 변수를 자식 함수 안에서 clear하는 건 MATLAB에서도 권장되지 않는
        % 패턴). 실제로 이 함수가 필요로 하는 건 "이전 파일의 Q-map 관련
        % 필드가 새 파일에 남아있지 않게" 하는 것뿐이므로, 그 필드들만 콕
        % 집어서 비워준다.
        param.dataq = []; param.Qr = []; param.qr = []; param.Qy = []; param.qy = [];
        param.QMapMet = ''; param.AlphaMap = []; param.af = []; param.tth = [];
        if ~exist('XSData','file')
            [XSData, datadir] = uigetfile({'*.*','All format(*.*)';'*.mat','Mat file(*.mat)'});
            if XSData == 0, return; end
            XSData = fullfile(datadir, XSData); 
        end

        [param.Path, param.FileName, ext] = fileparts(XSData);
        if ~strcmp(ext,'.mat') 
            warndlg('Please use .mat file','Warning');
            return
        end

        try
            m = matfile(XSData);
            varList = who(m);
            
            if ismember('data2dPix', varList)
                param.datapx = single(m.data2dPix); 
            else
                warndlg('파일 내에 data2dPix 변수가 없습니다.', 'Error'); 
                return; 
            end
            
            if ismember('data2dQ', varList), param.dataq = single(m.data2dQ); else, param.dataq = []; end
            if ismember('QMap', varList), param.Q = single(m.QMap); end

            if ismember('QrMap', varList)
                param.Qr = single(m.QrMap); param.QMapMet = 'Qxy/Qz'; param.qr = single(m.qraxis);
            elseif ismember('QyMap', varList)
                param.Qy = single(m.QyMap); param.QMapMet = 'Qy/Qz'; param.qy = single(m.qyaxis);
            end
            if ismember('QzMap', varList), param.Qz = single(m.QzMap); param.qz = single(m.qzaxis); end
            
            param.dataSize = single(size(param.datapx));
            
            if ismember('IncAngle', varList), param.ai = single(m.IncAngle); else, param.ai = 0.1; end

            if ismember('data2dAlpha', varList)
                param.af = single(m.af); param.tth = single(m.tth); param.AlphaMap = single(m.data2dAlpha);
            end

            if ismember('Wavelength', varList), param.Wavelength = single(m.Wavelength); else, param.Wavelength = 1.54; end
            if ismember('Beampos', varList), param.bpos = single(m.Beampos); else, param.bpos = [0,0]; end
            if ismember('SDD', varList), param.SDD = single(m.SDD); else, param.SDD = 200; end
            if ismember('pixel', varList), param.pixel = single(m.pixel); else, param.pixel = 0.075; end

        catch err
            errordlg(['데이터를 불러오는 중 오류가 발생했습니다: ', err.message], 'Load Error');
            return;
        end

        h = 4.1357e-15; c = 2.99792458e8;
        param.Energy = round(h*c/param.Wavelength*1e7, 4);

        param.cmin = min(param.datapx(param.datapx>0),[],'omitnan');
        param.cmax = max(param.datapx(:),[],'omitnan');

        GX.cMax.Value = num2str(param.cmax);
        GX.cMin.Value = num2str(param.cmin);

        param.HD = single((1:param.dataSize(2)) - param.bpos(1));
        param.VD = single(-(1:param.dataSize(1)) + param.bpos(2));

        GX.cXlim1.Value = num2str(min(param.HD)); GX.cXlim2.Value = num2str(max(param.HD));
        GX.cYlim1.Value = num2str(min(param.VD)); GX.cYlim2.Value = num2str(max(param.VD));

        hIncidA.Value = num2str(param.ai);
        param.Mapping = hMapping.Value;

        updateImage_tab;
        
        param.Expinfo = 1; 
        param.hklcal = 0;
    end

    function Rangecal_Callback(~,~)
        param.Mapping = hMapping.Value;
        switch param.Mapping
            case 'Pixel'
                GX.cXlim1.Value = num2str(min(param.HD)); GX.cXlim2.Value = num2str(max(param.HD));
                GX.cYlim1.Value = num2str(min(param.VD)); GX.cYlim2.Value = num2str(max(param.VD));
            case 'Alpha'
                if isfield(param,'tth')
                    GX.cXlim1.Value = num2str(min(param.tth)); GX.cXlim2.Value = num2str(max(param.tth));
                    GX.cYlim1.Value = num2str(min(param.af)); GX.cYlim2.Value = num2str(max(param.af));
                end
            case 'Qxy/Qz'
                if isfield(param,'qr')
                    GX.cXlim1.Value = num2str(min(param.qr)); GX.cXlim2.Value = num2str(max(param.qr));
                    GX.cYlim1.Value = num2str(min(param.qz)); GX.cYlim2.Value = num2str(max(param.qz));
                end
            case 'Qy/Qz'
                if isfield(param,'qy')
                    GX.cXlim1.Value = num2str(min(param.qy)); GX.cXlim2.Value = num2str(max(param.qy));
                    GX.cYlim1.Value = num2str(min(param.qz)); GX.cYlim2.Value = num2str(max(param.qz));
                end
        end
        updateImage_tab;
    end

    function updateImage_tab
        param.colorscale = hScale.Value;
        param.colorm = hColor.Value;
        param.cmax = str2double(GX.cMax.Value);
        param.cmin = str2double(GX.cMin.Value);
        param.xlimmin = str2double(GX.cXlim1.Value);
        param.xlimmax = str2double(GX.cXlim2.Value);
        param.ylimmin = str2double(GX.cYlim1.Value);
        param.ylimmax = str2double(GX.cYlim2.Value);
        param.fontsize = str2double(GX.FontSz.Value);

        axes(hAXtab);
        cla(hAXtab); 
        set(hAXtab, 'Color', 'w'); 
        hold(hAXtab, 'on'); 

        param.Mapping = hMapping.Value;
        % [Fix] 예전에는 hasData가 오직 param.dataq(Q-변환 데이터) 존재
        % 여부만 봤다. 그런데 기본 Mapping 모드는 'Pixel'이고, 'Pixel'
        % 모드는 param.datapx만 있으면 되는데(파일 로드 시 항상 필수로
        % 채워짐), data2dQ가 없는(=Q-map을 미리 계산해두지 않은, 아주 흔한)
        % 파일을 열면 hasData가 무조건 false가 되어서 Pixel 모드조차 아예
        % imagesc를 호출하지 않고 "Simulation Mode"만 표시하고 있었다.
        % 즉 기본 상태에서 데이터 이미지가 아예 안 뜨는 문제였다.
        % 지금은 "현재 선택된 Mapping 모드에 실제로 필요한 데이터"가
        % 있는지를 모드별로 따로 확인한다.
        switch param.Mapping
            case 'Pixel',  hasData = isfield(param, 'datapx') && ~isempty(param.datapx);
            case 'Alpha',  hasData = isfield(param, 'AlphaMap') && ~isempty(param.AlphaMap);
            case 'Qxy/Qz', hasData = isfield(param, 'dataq') && ~isempty(param.dataq) && isfield(param, 'qr');
            case 'Qy/Qz',  hasData = isfield(param, 'dataq') && ~isempty(param.dataq) && isfield(param, 'qy');
            otherwise,     hasData = false;
        end
        
        if hasData
            switch param.Mapping
                case 'Pixel', imagesc(hAXtab, param.HD, param.VD, param.datapx); xlabel(hAXtab, 'Y, pixel'); ylabel(hAXtab, 'Z, pixel');
                case 'Alpha', imagesc(hAXtab, param.tth, param.af, param.AlphaMap); xlabel(hAXtab, '2\theta_{f}'); ylabel(hAXtab, '\alpha_{f}');
                case 'Qxy/Qz', imagesc(hAXtab, param.qr, param.qz, param.dataq); xlabel(hAXtab, 'q_{xy}, A^{-1}'); ylabel(hAXtab, 'q_z, A^{-1}');
                case 'Qy/Qz', imagesc(hAXtab, param.qy, param.qz, param.dataq); xlabel(hAXtab, 'q_y, A^{-1}'); ylabel(hAXtab, 'q_z, A^{-1}');
            end
            
            axis(hAXtab, 'image'); 
            
            hcb = colorbar(hAXtab); 
            hcb.LineWidth = 1.5; 
            hcb.Label.String = 'Intensity, arb. units'; 
            hcb.Label.FontSize = 14;
            
            clim(hAXtab, [param.cmin, param.cmax]);
            set(hAXtab, 'ColorScale', param.colorscale);

            try
                switch param.colorm
                    case 'rwb', cmap = balancecol(256);
                    case 'rkb', cmap = redbkblue(256);
                    case 'inferno', cmap = inferno(256);
                    case 'viridis', cmap = viridis(256);
                    case 'cubehelix', cmap = cubehelix(256);
                    case 'ocean', cmap = ocean(256);
                    case 'kindlemann', cmap = kindlemann(256);
                    case 'magma', cmap = MagmaM(256);
                    case 'jet2', cmap = Jet2(256);
                    otherwise, cmap = param.colorm;
                end
                colormap(hAXtab, cmap);
            catch
                colormap(hAXtab, 'jet');
            end
            
            if isfield(param, 'FileName')
                title(hAXtab, param.FileName, 'Interpreter', 'none', 'FontSize', 11);
            end
        else
            switch param.Mapping
                case 'Pixel'
                    xlabel(hAXtab, 'Y, pixel'); ylabel(hAXtab, 'Z, pixel');
                case 'Alpha'
                    xlabel(hAXtab, '2\theta_{f}'); ylabel(hAXtab, '\alpha_{f}');
                case {'Qxy/Qz', 'Qy/Qz'}
                    xlabel(hAXtab, 'q_{xy}, A^{-1}'); 
                    ylabel(hAXtab, 'q_z, A^{-1}');
            end
            axis(hAXtab, 'equal'); 
            title(hAXtab, 'Simulation Mode', 'Interpreter', 'none', 'FontSize', 11);
        end

        set(hAXtab, 'YDir', 'normal', 'FontSize', param.fontsize, 'FontName', 'times', 'Box', 'on');
        set(hAXtab, 'XLim', [param.xlimmin, param.xlimmax]);
        set(hAXtab, 'YLim', [param.ylimmin, param.ylimmax]);
        
        drawnow limitrate;
    end

    function Updateimage_Callback(~,~)
        param.Mapping = hMapping.Value;
        if hHKLCheck.Value == false && hHKLRefl.Value == false
            updateImage_tab;
        else
            Xtalplot_Callback;
        end
    end

    function SpaceGroup_Callback(~,~)
        CS = XTal.hCrystsys.Value;
        switch CS
            case 'Layer', XTal.SpaceGroup = {'primitive'}; XTal.Choice = {'1'};
            case 'Hexagonal', XTal.SpaceGroup = {'P6/mmm'}; XTal.Choice = {'1'};
            case 'HCP', XTal.SpaceGroup = {'P63/mmc','P63/mcc','P63/mcm'}; XTal.Choice = {'1'};
            case 'Cubic', XTal.SpaceGroup = {'P23','F23','I23','P213','Pm-3','Pn-3','Fm-3','Fd-3','Im-3','Pa-3','Ia-3','P432','F432','F4132','I432','P4332','P4132','I4132','P-43m','F-43m','I-43m','P-43n','F-43c','I-43d','Pm-3m','Pn-3n','Pm-3n','Pn-3m','Fm-3m','Fm-3c','Fd-3m','Fd-3c','Im-3m','Ia-3d'}; XTal.Choice = {'1'};
            case 'Orthorhombic', XTal.SpaceGroup = {'P222','P2221','P21212','P212121','C2221','C222','F222','I222','I212121','Pmm2','Pmc21','Pcc2','Pma2','Pca21','Pnc2','Pmn21','Pba2','Pna21','Pnn2','Cmm2','Cmc21','Ccc2','Amm2','Aem2','Ama2','Aea2','Fmm2','Fdd2','Imm2','Iba2','Ima2','Pmmm','Pnnn','Pccm','Pban','Pmma','Pnna','Pmna','Pcca','Pbam','Pccn','Pbcm','Pnnm','Pmmn','Pbcn','Pbca','Pnma','Cmcm','Cmce','Cmmm','Cccm','Cmme','Ccce','Fmmm','Fddd','Immm','Ibam','Ibca','Imma'}; XTal.Choice = {'1'};
            case 'Tetragonal', XTal.SpaceGroup = {'P4','P41','P42','P43','I4','I41','P-4','I-4','P4/m','P42/m','P4/n','P42/n','I4/m','I41/a','P422','P4212','P4122','P41212','P4222','P42212','P4322','P43212','I422','I4122','P4mm','P4bm','P42cm','P42nm','P4cc','P4nc','P42mc','P42bc','I4mm','I4cm','I41md','I41cd','P-42m','P-42c','P-421m','P-421c','P-4m2','P-4c2','P-4b2','P-4n2','I-4m2','I-4c2','I-42m','I-42d','P4/mmm','P4/mcc','P4/nbm','P4/nnc','P4/mbm','P4/mnc','P4/nmm','P4/ncc','P42/mmc','P42/mcm','P42/nbc','P42/nnm','P42/mbc','P42/mnm','P42/nmc','P42/ncm','I4/mmm','I4/mcm','I41/amd','I41/acd'}; XTal.Choice = {'1'};
            case 'Monoclinic', XTal.SpaceGroup = {'P2','P21','C2','Pm','Pc','Cm','Cc','P2/m','P21/m','C2/m','P2/c','P21/c','C2/c'}; XTal.Choice = {'1','2','3'};
            case 'Rhombohedral', XTal.SpaceGroup = {'P3','P31','P32','R3','P-3','R-3','P321','P3112','P3121','P3221','R32','P3m1','P31m','P3c1','P31c','R3m','R3c','P-3m1','P-3c1','R-3m','R-3c','P6','P61','P65','P62','P64','P63','P-6','P63/m','P622','P6122','P6522','P6222','P6422','P6322','P6mm','P63cc','P63cm','P63mc','P-6m2','P-6c2','P-62m','P-62c'}; XTal.Choice = {'1'};
            case 'Triclinic', XTal.SpaceGroup = {'P1','P-1'}; XTal.Choice = {'1'};   
            case 'Helical', XTal.SpaceGroup = {'None'}; XTal.Choice = {'1'}; 
            case 'Tri_Helical', XTal.SpaceGroup = {'None'}; XTal.Choice = {'1'}; 
        end
        XTal.hSpaceGrp.Items = XTal.SpaceGroup;
        XTal.hSpaceGrp.Value = XTal.SpaceGroup{1};
        XTal.hChoice.Items = XTal.Choice;
        XTal.hChoice.Value = XTal.Choice{1};
        
        Structure_Callback([], []);
    end

    function plotIntoNavigator(a,b,c,alpha,beta,gamma,Xtal,Spg,Normal,Rotation)
        % UnitCellGen_gixs.m은 내부적으로 자신만의 figure(예: "Figure 1")를
        % 새로 띄우는 방식으로 작성되어 있어서, axes(hImunit)를 미리
        % 지정해봤자 그 지정을 무시하고 별도 창을 띄운다. 그래서 함수를
        % 호출하기 전/후의 figure 목록을 비교해 "새로 뜬 창"을 찾아내고,
        % 그 안의 그래픽 객체(patch/line/surface 등)를 통째로 Navigator
        % 패널의 hImunit 축으로 복사한 다음, 원래 창은 닫아버린다.
        axes(hImunit); cla(hImunit);
        figsBefore = findall(groot, 'Type', 'figure');
        try
            UnitCellGen_gixs(a,b,c,alpha,beta,gamma,Xtal,Spg,Normal,Rotation);
        catch
            return;
        end
        figsAfter = findall(groot, 'Type', 'figure');
        newFigs = setdiff(figsAfter, figsBefore);
        if isempty(newFigs), return; end

        for k = 1:numel(newFigs)
            try
                srcAxList = findobj(newFigs(k), 'Type', 'axes');
                if ~isempty(srcAxList)
                    srcAx = srcAxList(1);
                    copyobj(allchild(srcAx), hImunit);
                    try
                        view(hImunit, get(srcAx, 'View'));
                        hImunit.DataAspectRatio = srcAx.DataAspectRatio;
                        hImunit.XLim = srcAx.XLim; hImunit.YLim = srcAx.YLim; hImunit.ZLim = srcAx.ZLim;
                    catch
                    end
                end
            catch
            end
            delete(newFigs(k));
        end
        axis(hImunit, 'tight');
    end

    function Structure_Callback(~,~)
        param.Xtal = XTal.hCrystsys.Value;
        param.Spg = XTal.hSpaceGrp.Value;
        param.Normal = hNormDirec.Value;
        Rotation = [str2double(hXrot.Value), str2double(hYrot.Value), str2double(hZrot.Value)];

        % [Fix] 이 함수는 Space Group 드롭다운이 바뀔 때마다(hSpaceGrp의
        % ValueChangedFcn) 호출되는데, 예전엔 Crystal System이 그대로여도
        % 매번 a,b,c,alpha,beta,gamma를 강제로 초기값으로 되돌려버렸다.
        % 리셋 값 자체가 Crystal System에만 의존하므로(Space Group과는
        % 무관), "Crystal System이 실제로 바뀌었을 때만" 리셋하고, Space
        % Group만 바뀐 경우에는 지금 입력되어 있는 값을 그대로 둔다.
        if ~strcmp(param.Xtal, lastCrystSys)
            switch param.Xtal
                case 'Layer', a = inf; b = inf; c = 1; alpha = 90; beta = 90; gamma = 90;
                case 'Hexagonal', a = 1; b = 1; c = inf; alpha = 90; beta = 90; gamma = 120;
                case 'HCP', a = 1; b = 1; c = 1.633; alpha = 90; beta = 90; gamma = 120;
                case 'Cubic', a = 1; b = 1; c = 1; alpha = 90; beta = 90; gamma = 90;
                case 'Orthorhombic', a = 1; b = 2; c = 3; alpha = 90; beta = 90; gamma = 90;
                case 'Tetragonal', a = 1; b = 1; c = 2; alpha = 90; beta = 90; gamma = 90;
                case 'Monoclinic', a = 1; b = 2; c = 3; alpha = 90; beta = 70; gamma = 90;
                case 'Rhombohedral', a = 1; b = 1; c = 1; alpha = 70; beta = 70; gamma = 70;
                case 'Triclinic', a = 1; b = 2; c = 3; alpha = 70; beta = 80; gamma = 100;
                case 'Helical', a = 10; b = 1; c = 50; alpha = 90; beta = 90; gamma = 90; 
                case 'Tri_Helical', a = 15; b = 18; c = 50; alpha = 75; beta = 80; gamma = 105; 
            end
            GX.haunit.Value = num2str(a); GX.hbunit.Value = num2str(b); GX.hcunit.Value = num2str(c);
            GX.halpha.Value = num2str(alpha); GX.hbeta.Value = num2str(beta); GX.hgamma.Value = num2str(gamma);
            lastCrystSys = param.Xtal;
        else
            % Space Group만 바뀐 경우: 지금 GUI에 입력된 값을 그대로 사용
            a = str2double(GX.haunit.Value); b = str2double(GX.hbunit.Value); c = str2double(GX.hcunit.Value);
            alpha = str2double(GX.halpha.Value); beta = str2double(GX.hbeta.Value); gamma = str2double(GX.hgamma.Value);
        end
        
        % 📌 팝업 창 차단: UnitCellGen_gixs 결과를 Navigator(hImunit)로 흡수
        plotIntoNavigator(a,b,c,alpha,beta,gamma,param.Xtal,param.Spg,param.Normal,Rotation);
    end

    function Xtalplot_Callback(~,~)
        param.Mapping = hMapping.Value;
        param.Xtal = XTal.hCrystsys.Value;
        param.Spg = XTal.hSpaceGrp.Value;
        param.CH = XTal.hChoice.Value;
        param.Normal = hNormDirec.Value;
        
        param.ai = str2double(hIncidA.Value);
        nfilm = cosd(str2double(hCritiA.Value));
        k0 = 2*pi/param.Wavelength;
        
        a = str2double(GX.haunit.Value); b = str2double(GX.hbunit.Value); c = str2double(GX.hcunit.Value);
        alpha = str2double(GX.halpha.Value); beta = str2double(GX.hbeta.Value); gamma = str2double(GX.hgamma.Value);
        
        hmax = str2double(hHidx.Value); kmax = str2double(hKidx.Value); lmax = str2double(hLidx.Value);
        hmin = -hmax; kmin = -kmax; lmin = -lmax;
        
        Rotation = [str2double(hXrot.Value), str2double(hYrot.Value), str2double(hZrot.Value)];
        
        % 📌 팝업 창 차단: UnitCellGen_gixs 결과를 Navigator(hImunit)로 흡수
        plotIntoNavigator(a,b,c,alpha,beta,gamma,param.Xtal,param.Spg,param.Normal,Rotation);
        
        switch param.Xtal
            case 'Layer', a = 1e10; b = 1e10;
            case 'Hexagonal', c = 1e10; lmin = 0; lmax = 0;
        end

        Wyckoff_Input = hWyckoff.Value; 
        isEwald = hEwaldS.Value; 

        % [Fix] "Solve 이후 데이터 이미지가 안 뜨는" 문제의 원인: 예전에는
        % updateImage_tab(실제 데이터 이미지를 그리는 부분)이 qvalhkl_gi
        % 호출과 *같은* try 블록 안에, 그것도 qvalhkl_gi *다음*에 있었다.
        % 그래서 Solve로 찾은 격자상수/각도 조합이 (예: 기하학적으로 유효하지
        % 않은 각도 조합 등으로) qvalhkl_gi 내부에서 에러를 던지면, 시뮬레이션
        % 뿐 아니라 원본 데이터 이미지 자체를 다시 그리는 과정까지 통째로
        % 건너뛰어버렸다. 결과적으로 화면이 빈 채로 남고, 에러 메시지만 뜨거나
        % (놓치기 쉬움) 그마저도 못 보고 지나가면 "이미지가 안 뜬다"로 보인다.
        % 지금은 데이터 이미지를 시뮬레이션 성공 여부와 무관하게 항상 먼저
        % 그린 뒤, hkl 시뮬레이션/마커 오버레이는 별도로 시도한다.
        updateImage_tab;

        try
            [params.Tqhor,params.Rqhor,params.Tqver,params.Rqver,params.hkl,params.Taf,params.Raf,params.Ttth,params.Rtth] = ...
                qvalhkl_gi(a,b,c,alpha,beta,gamma,hmax,kmax,lmax,hmin,kmin,lmin, ...
                           param.Normal,Rotation,param.Xtal,param.Spg,param.CH,param.Mapping, ...
                           nfilm,k0,param.ai,Wyckoff_Input,isEwald);
            Imageplot2DHKL;
        catch err
            warndlg(['Calculation error: ', err.message], 'Warning');
        end
    end

    function Imageplot2DHKL
        updateImage_tab; % (Xtalplot_Callback에서 이미 한 번 그렸지만, 이 함수가
                          % 단독으로 호출되는 다른 경로도 있어 안전하게 유지)
        hold(hAXtab, 'on'); 

        label_pos_str = hPLNpos.Value;
        label_font_size = str2double(hPLNsize.Value);
        if isnan(label_font_size) || label_font_size <= 0, label_font_size = 9; end

        HoldingIm = hHoldingS.Value;
        HKLCheckOn = hHKLCheck.Value; 
        HKLReflOn = hHKLRefl.Value;
        HKLPlaneOn = hHKLplane.Value;
        RandOri = hRandOri.Value;
        
        STColorN = hSTColorN.Value; SRColorN = hSRColorN.Value; 
        STShapeN = hSTShapeN.Value; SRShapeN = hSRShapeN.Value; 
        STSizeN = str2double(hSTSizeN.Value); SRSizeN = str2double(hSRSizeN.Value); 
        SEmptyN = hSEmptyN.Value;
        
        try [TClN,TShN,TMCN] = ColorSelector(STColorN,STShapeN,SEmptyN); catch; TClN='k'; TShN='o'; TMCN='none'; end
        try [RClN,RShN,RMCN] = ColorSelector(SRColorN,SRShapeN,SEmptyN); catch; RClN='r'; RShN='square'; RMCN='none'; end

        if HoldingIm == true
            STColorO = hSTColorO.Value; SRColorO = hSRColorO.Value; 
            STShapeO = hSTShapeO.Value; SRShapeO = hSRShapeO.Value; 
            STSizeO = str2double(hSTSizeO.Value); SRSizeO = str2double(hSRSizeO.Value); 
            SEmptyO = hSEmptyO.Value;
            try [TClO,TShO,TMCO] = ColorSelector(STColorO,STShapeO,SEmptyO); catch; TClO='b'; TShO='*'; TMCO='none'; end
            try [RClO,RShO,RMCO] = ColorSelector(SRColorO,SRShapeO,SEmptyO); catch; RClO='m'; RShO='d'; RMCO='none'; end
        end

        switch param.Mapping
            case 'Pixel'
                xTN = param.SDD .* tand(params.Ttth) ./ param.pixel; yTN = param.SDD ./ cosd(params.Ttth) .* tand(params.Taf) ./ param.pixel;
                xRN = param.SDD .* tand(params.Rtth) ./ param.pixel; yRN = param.SDD ./ cosd(params.Rtth) .* tand(params.Raf) ./ param.pixel;
                if HoldingIm == true
                     xTO = param.SDD .* tand(params.Tttho) ./ param.pixel; yTO = param.SDD ./ cosd(params.Tttho) .* tand(params.Tafo) ./ param.pixel;
                     xRO = param.SDD .* tand(params.Rttho) ./ param.pixel; yRO = param.SDD ./ cosd(params.Rttho) .* tand(params.Rafo) ./ param.pixel;
                end
            case 'Alpha'
                xTN = params.Ttth; yTN = params.Taf; xRN = params.Rtth; yRN = params.Raf;
                if HoldingIm == true, xTO = params.Tttho; yTO = params.Tafo; xRO = params.Rttho; yRO = params.Rafo; end
            case 'Qxy/Qz'
                xTN = params.Tqhor; yTN = params.Tqver; xRN = params.Rqhor; yRN = params.Rqver;
                if HoldingIm == true, xTO = params.Tqhoro; yTO = params.Tqvero; xRO = params.Rqhoro; yRO = params.Rqvero; end
            case 'Qy/Qz'
                xTN = params.Tqhor; yTN = params.Tqver; xRN = params.Rqhor; yRN = params.Rqver;
                if HoldingIm == true, xTO = params.Tqhoro; yTO = params.Tqvero; xRO = params.Rqhoro; yRO = params.Rqvero; end
        end

        if HKLCheckOn == true
             plot_markers(xTN, yTN, TShN, STSizeN, TMCN, TClN, params.hkl, HKLPlaneOn, RandOri, label_pos_str, label_font_size);
             if HoldingIm == true
                 plot_markers(xTO, yTO, TShO, STSizeO, TMCO, TClO, params.hklo, HKLPlaneOn, RandOri, label_pos_str, label_font_size);
             end
        end
        if HKLReflOn == true
             plot_markers(xRN, yRN, RShN, SRSizeN, RMCN, RClN, params.hkl, HKLPlaneOn, RandOri, label_pos_str, label_font_size);
             if HoldingIm == true
                 plot_markers(xRO, yRO, RShO, SRSizeO, RMCO, RClO, params.hklo, HKLPlaneOn, RandOri, label_pos_str, label_font_size);
             end
        end
        hold(hAXtab, 'off');
    end

    function plot_markers(x, y, shape, msize, fcolor, ecolor, hkl_list, show_label, is_rand, label_pos_str, label_font_size)
        if isempty(x), return; end
        
        valid_idx = x >= param.xlimmin & x <= param.xlimmax & y >= param.ylimmin & y <= param.ylimmax;
        x = x(valid_idx); y = y(valid_idx); hkl_list = hkl_list(valid_idx, :);
        if isempty(x), return; end

        x = x(:); y = y(:); 

        % [되돌림] 직전에 추가했던 "300개 넘으면 저차 hkl만 남기고 라벨도
        % 강제로 끔" 로직을 제거한다. 그게 정확히 "Plane(라벨) 체크해도 안
        % 나오고, hkl 개수만큼도 안 나온다"는 버그의 원인이었다 -- ±H,±K,±L로
        % 사용자가 지정한 반사는 전부 그려져야 하고, 라벨 표시 여부는 오직
        % "Plane" 체크박스(show_label 인자)로만 결정되어야 한다. 마커가
        % 화면을 하얗게 덮는 문제는 아래의 반투명 처리만으로 해결한다
        % (데이터를 숨기지 않으면서 겹침도 완화).
        switch label_pos_str
            case 'left',   halign = 'right';  valign = 'baseline';
            case 'center', halign = 'center'; valign = 'baseline';
            case 'right',  halign = 'left';   valign = 'baseline';
            case 'top',    halign = 'center'; valign = 'bottom';
            case 'bottom', halign = 'center'; valign = 'cap';
            otherwise,     halign = 'left';   valign = 'bottom';
        end

        if show_label == true
            hkl_str = cellstr(num2str(hkl_list));
        end

        if is_rand == false
            hSc = scatter(hAXtab, x, y, msize^2 + 20, shape, ...
                'MarkerFaceColor', fcolor, 'MarkerEdgeColor', ecolor, 'LineWidth', 1);
            if ~strcmpi(fcolor, 'none')
                try hSc.MarkerFaceAlpha = 0.55; catch; end
            end
            
            if show_label == true
                text(x, y, hkl_str, 'Parent', hAXtab, 'Color', ecolor, 'FontSize', label_font_size, ...
                    'HorizontalAlignment', halign, 'VerticalAlignment', valign, 'Interpreter', 'none', 'Clipping', 'on'); 
            end
        else
            theta = linspace(0, pi, 50);      
            rp = sqrt(x.^2 + y.^2);           
            X_rings = rp * cos(theta); Y_rings = rp * sin(theta);        
            X_rings(:, end+1) = NaN; Y_rings(:, end+1) = NaN;          
            X_flat = X_rings'; X_flat = X_flat(:); Y_flat = Y_rings'; Y_flat = Y_flat(:); 
            line(X_flat, Y_flat, 'Parent', hAXtab, 'Color', fcolor, 'LineWidth', 1.5);
            
            if show_label == true
                text(x, y, hkl_str, 'Parent', hAXtab, 'Color', ecolor, 'FontSize', label_font_size, ...
                    'HorizontalAlignment', halign, 'VerticalAlignment', valign, 'Clipping', 'on'); 
            end
        end
    end

    function Holding_Callback(~, ~)
        isHold = hHoldingS.Value;
        if isHold == true
            if isfield(params, 'Tqhor') && ~isempty(params.Tqhor)
                params.Tqhoro = params.Tqhor; params.Tqvero = params.Tqver;
                params.Rqhoro = params.Rqhor; params.Rqvero = params.Rqver;
                params.hklo = params.hkl;
                params.Tafo = params.Taf; params.Rafo = params.Raf;
                params.Tttho = params.Ttth; params.Rttho = params.Rtth;
                
                param.Xtalold = param.Xtal; param.Spgold = param.Spg;
                param.Normalold = param.Normal; param.CHold = param.CH;
                
                a = str2double(GX.haunit.Value); b = str2double(GX.hbunit.Value); c = str2double(GX.hcunit.Value);
                al = str2double(GX.halpha.Value); be = str2double(GX.hbeta.Value); ga = str2double(GX.hgamma.Value);
                rotX = str2double(hXrot.Value); rotY = str2double(hYrot.Value); rotZ = str2double(hZrot.Value);
                param.unitold = [a, b, c, al, be, ga, rotX, rotY, rotZ];
                
            else
                warndlg('고정할 데이터가 없습니다. 먼저 [Plot]을 실행하세요.');
                hHoldingS.Value = false; 
            end
        else
            if isfield(params, 'Tqhoro')
                params.Tqhoro = []; params.Tqvero = []; params.Rqhoro = []; params.Rqvero = []; params.hklo = [];
            end
            if isfield(param, 'unitold')
                param = rmfield(param, 'unitold'); 
            end
            Imageplot2DHKL; 
        end
    end

    function HKLTable_Callback(~,~)
        HKLCheckOn = hHKLCheck.Value; 
        HKLReflOn = hHKLRefl.Value; 
        HoldingIm = hHoldingS.Value;
        
        if HKLCheckOn == false && HKLReflOn == false
            warndlg('Please check T or R first!!'); return; 
        end
        
        f = uifigure('Name', 'HKLtable', 'Position', [100 100 600 500]);
        
        if HoldingIm == false
            if HKLCheckOn == true && HKLReflOn == true
                T = table(params.Tqhor, params.Tqver, params.Rqhor, params.Rqver, true(size(params.Tqhor)));
                colNames = {'Qxy(T)', 'Qz(T)', 'Qxy(R)', 'Qz(R)', 'Export'}; editCol = [false false false false true];
            elseif HKLCheckOn == true
                T = table(params.Tqhor, params.Tqver, true(size(params.Tqhor)));
                colNames = {'Qxy(T)', 'Qz(T)', 'Export'}; editCol = [false false true];
            else
                T = table(params.Rqhor, params.Rqver, true(size(params.Rqhor)));
                colNames = {'Qxy(R)', 'Qz(R)', 'Export'}; editCol = [false false true];
            end
            
            uit = uitable(f);
            uit.Data = table2cell(T);
            uit.Units = 'Normalized';
            uit.Position = [0.05, 0.15, 0.9, 0.8];
            uit.RowName = num2cell(num2str(params.hkl),2);
            uit.ColumnName = colNames;
            uit.ColumnEditable = editCol;
                
            btnSaveT = uibutton(f, 'push');
            btnSaveT.Text = 'Save';
            btnSaveT.Units = 'Normalized';
            btnSaveT.Position = [0.3, 0.02, 0.4 0.1];
            btnSaveT.ButtonPushedFcn = @(h,e)table2save(uit, [], HoldingIm, HKLCheckOn, HKLReflOn);
                
        else
            if HKLCheckOn == true && HKLReflOn == true
                T1 = table(params.Tqhor, params.Tqver, params.Rqhor, params.Rqver, true(size(params.Tqhor))); colNames1 = {'Qxy(T)', 'Qz(T)', 'Qxy(R)', 'Qz(R)', 'Export'};
                T2 = table(params.Tqhoro, params.Tqvero, params.Rqhoro, params.Rqvero, true(size(params.Tqhoro))); colNames2 = {'Qxy(T)_Old', 'Qz(T)_Old', 'Qxy(R)_Old', 'Qz(R)_Old', 'Export'};
            elseif HKLCheckOn == true
                T1 = table(params.Tqhor, params.Tqver, true(size(params.Tqhor))); colNames1 = {'Qxy(T)', 'Qz(T)', 'Export'};
                T2 = table(params.Tqhoro, params.Tqvero, true(size(params.Tqhoro))); colNames2 = {'Qxy(T)_Old', 'Qz(T)_Old', 'Export'};
            else
                T1 = table(params.Rqhor, params.Rqver, true(size(params.Rqhor))); colNames1 = {'Qxy(R)', 'Qz(R)', 'Export'};
                T2 = table(params.Rqhoro, params.Rqvero, true(size(params.Rqhoro))); colNames2 = {'Qxy(R)_Old', 'Qz(R)_Old', 'Export'};
            end
            
            uit1 = uitable(f);
            uit1.Data = table2cell(T1);
            uit1.Units = 'Normalized';
            uit1.Position = [0.05, 0.55, 0.9, 0.40];
            uit1.RowName = num2cell(num2str(params.hkl),2);
            uit1.ColumnName = colNames1;
            uit1.ColumnEditable = true;
                
            uit2 = uitable(f);
            uit2.Data = table2cell(T2);
            uit2.Units = 'Normalized';
            uit2.Position = [0.05, 0.12, 0.9, 0.40];
            uit2.RowName = num2cell(num2str(params.hklo),2);
            uit2.ColumnName = colNames2;
            uit2.ColumnEditable = true;
                
            btnSaveComb = uibutton(f, 'push');
            btnSaveComb.Text = 'Save Combined';
            btnSaveComb.Units = 'Normalized';
            btnSaveComb.Position = [0.3, 0.02, 0.4 0.08];
            btnSaveComb.ButtonPushedFcn = @(h,e)table2save(uit1, uit2, HoldingIm, HKLCheckOn, HKLReflOn);
        end
    end

    function table2save(uit1, uit2, HoldingIm, HKLCheckOn, HKLReflOn)
        Data = {};
        tmp1 = uit1.Data(:, end); exportbool1 = [tmp1{:}];
        Data{1} = uit1.RowName(exportbool1);
        
        if HKLCheckOn && HKLReflOn
            Data{2} = cell2mat(uit1.Data(exportbool1, 1)); Data{3} = cell2mat(uit1.Data(exportbool1, 2)); Data{4} = cell2mat(uit1.Data(exportbool1, 3)); Data{5} = cell2mat(uit1.Data(exportbool1, 4));
        else
            Data{2} = cell2mat(uit1.Data(exportbool1, 1)); Data{3} = cell2mat(uit1.Data(exportbool1, 2));
        end
        
        if HoldingIm == true
            tmp2 = uit2.Data(:, end); exportbool2 = [tmp2{:}];
            idx_offset = length(Data);
            Data{idx_offset+1} = uit2.RowName(exportbool2);
            
            if HKLCheckOn && HKLReflOn
                Data{idx_offset+2} = cell2mat(uit2.Data(exportbool2, 1)); Data{idx_offset+3} = cell2mat(uit2.Data(exportbool2, 2)); Data{idx_offset+4} = cell2mat(uit2.Data(exportbool2, 3)); Data{idx_offset+5} = cell2mat(uit2.Data(exportbool2, 4));
            else
                Data{idx_offset+2} = cell2mat(uit2.Data(exportbool2, 1)); Data{idx_offset+3} = cell2mat(uit2.Data(exportbool2, 2));
            end
        end
        SaveHKLvalue(Data, HoldingIm, HKLCheckOn, HKLReflOn);
    end

    function SaveHKLvalue(Data, HoldingIm, HKLCheckOn, HKLReflOn)
        hkl_new = Data{1};
        if HoldingIm == false
            if HKLCheckOn && HKLReflOn
                T = table(hkl_new, Data{2}, Data{3}, Data{4}, Data{5}, 'VariableNames', {'HKL','Qxy_T','Qz_T','Qxy_R','Qz_R'});
            else
                T = table(hkl_new, Data{2}, Data{3}, 'VariableNames', {'HKL','Qxy','Qz'});
            end
        else
            old_start_idx = 4;
            if HKLCheckOn && HKLReflOn, old_start_idx = 6; end
            hkl_old = Data{old_start_idx};
            max_len = max(length(hkl_new), length(hkl_old));
            
            vars_new = pad_data_column(Data(1:old_start_idx-1), length(hkl_new), max_len);
            vars_old = pad_data_column(Data(old_start_idx:end), length(hkl_old), max_len);
            
            if HKLCheckOn && HKLReflOn
                T = table(vars_new{1}, vars_new{2}, vars_new{3}, vars_new{4}, vars_new{5}, vars_old{1}, vars_old{2}, vars_old{3}, vars_old{4}, vars_old{5}, ...
                    'VariableNames', {'HKL_New','Qxy_T_New','Qz_T_New','Qxy_R_New','Qz_R_New', 'HKL_Old','Qxy_T_Old','Qz_T_Old','Qxy_R_Old','Qz_R_Old'});
            else
                T = table(vars_new{1}, vars_new{2}, vars_new{3}, vars_old{1}, vars_old{2}, vars_old{3}, ...
                    'VariableNames', {'HKL_New','Qxy_New','Qz_New', 'HKL_Old','Qxy_Old','Qz_Old'});
            end
        end
        
        filepath = fullfile(param.Path, param.FileName); 
        if ~exist(filepath, 'dir'), mkdir(filepath); end
        SaveFile = fullfile(filepath, [param.FileName,'_HKLtable.xlsx']);
        [writeOK, writeReport] = writePGIXSTableFile(T, SaveFile);
        if ~writeOK
            warndlg(writeReport.Message, 'Save failed');
            return;
        end
        msgbox('Table saved successfully!', 'Success');
    end

    function padded_cells = pad_data_column(cell_data, curr_len, target_len)
        padded_cells = cell_data;
        if curr_len < target_len
            pad_size = target_len - curr_len;
            for i = 1:length(cell_data)
                col_data = cell_data{i};
                if iscell(col_data)
                    padded_cells{i} = [col_data; repmat({''}, pad_size, 1)];
                else
                    padded_cells{i} = [col_data; NaN(pad_size, 1)];
                end
            end
        end
    end

    function Solveparam_Callback(~,~)
        param.Xtal = XTal.hCrystsys.Value; param.Spg = XTal.hSpaceGrp.Value;
        param.CH = XTal.hChoice.Value; param.Normal = hNormDirec.Value;
        param.ai = str2double(hIncidA.Value); nfilm = cosd(str2double(hCritiA.Value)); k0 = 2*pi/param.Wavelength;
        
        a0 = str2double(GX.haunit.Value); b0 = str2double(GX.hbunit.Value); c0 = str2double(GX.hcunit.Value);
        al0 = str2double(GX.halpha.Value); be0 = str2double(GX.hbeta.Value); ga0 = str2double(GX.hgamma.Value);
        
        FixedRotation = [str2double(hXrot.Value), str2double(hYrot.Value), str2double(hZrot.Value)]; 
        hmax = str2double(hHidx.Value); kmax = str2double(hKidx.Value); lmax = str2double(hLidx.Value);

        try
            [Tqhor, Rqhor, Tqver, Rqver, hkl_list] = qvalhkl_gi(a0,b0,c0,al0,be0,ga0, hmax,kmax,lmax,-hmax,-kmax,-lmax, param.Normal,FixedRotation,param.Xtal,param.Spg,param.CH,param.Mapping, nfilm,k0,param.ai, 0, 0); 
        catch, return; end
        
        % [Fix] HKLplot 패널의 "Trans."/"Reflec." 체크박스는 이미 시뮬레이션
        % 화면(Xtalplot_Callback/Imageplot2DHKL)에서 T/R 브랜치 중 어느 걸
        % 보여줄지 정하는 용도로 쓰이고 있었다. 그런데 Solve/Fine-tune의
        % 피크 매칭·자동감지는 이 체크박스를 무시하고 항상 T+R을 둘 다
        % 후보로 넣고 있어서, 사용자가 화면에서 "Reflec.만 보고 있는데"
        % Solve는 안 보이는 Transmission 반사까지 후보로 들이미는 등 서로
        % 안 맞는 상황이 생길 수 있었다. 이제 이 체크박스 상태를 그대로
        % 따라간다: 둘 다 켜져 있으면 T+R 둘 다, 하나만 켜져 있으면 그
        % 브랜치만, 둘 다 꺼져 있으면(화면엔 아무 마커도 안 보이는 상태)
        % Solve는 그래도 동작해야 하니 기본값으로 Transmission만 사용한다.
        useT = hHKLCheck.Value; useR = hHKLRefl.Value;
        if ~useT && ~useR, useT = true; end
        
        allQhor = []; allQver = []; allHKL = []; allBranch = [];
        if useT
            allQhor = [allQhor; Tqhor]; allQver = [allQver; Tqver];
            allHKL = [allHKL; hkl_list]; allBranch = [allBranch; ones(size(hkl_list,1),1)];
        end
        if useR
            allQhor = [allQhor; Rqhor]; allQver = [allQver; Rqver];
            allHKL = [allHKL; hkl_list]; allBranch = [allBranch; 2*ones(size(hkl_list,1),1)];
        end

        msgbox({'[피크 선택 모드]', 'ROI를 그려 피크를 선택하세요.', ...
            '자동 인덱싱 정확도를 높이려면 화면에 보이는 피크를 최대한 많이(4~7개 권장) 골라주세요.', ...
            '완료되면 [ESC]를 누르세요.'}, 'Peak Selection');
        
        % [변경] 클릭한 피크의 hkl 라벨은 여기서 "확정"하지 않는다. 지금 GUI에
        % 설정된 Normal Direction이 실제로 맞는지 아직 모르는 상태이기 때문에,
        % 화면에는 참고용으로 잠정 라벨만 보여주고, 실제 hkl 매칭/피팅은 아래
        % Normal Direction 자동 탐색 단계에서 후보별로 다시 계산한다. 여기서는
        % 실측 피크의 "원본 (Qx,Qz) 위치"만 저장한다.
        RawPeaks = []; TentativeHKL = []; TentativeGroups = {}; peak_count = 0;
        
        while true
            hROI = drawrectangle(hAXtab, 'Label', ['Peak ' num2str(peak_count+1)], 'Color', 'm');
            if ~isvalid(hROI) || isempty(hROI.Position), if isvalid(hROI), delete(hROI); end; break; end
            pos = hROI.Position; if isempty(pos), delete(hROI); break; end
            
            xmin = pos(1); ymin = pos(2); width = pos(3); height = pos(4);
            switch param.Mapping
                case 'Qxy/Qz', Xaxis = param.qr; Yaxis = param.qz;
                case 'Qy/Qz',  Xaxis = param.qy; Yaxis = param.qz;
                otherwise, delete(hROI); return;
            end
            
            x_idx = find(Xaxis >= xmin & Xaxis <= xmin+width); y_idx = find(Yaxis >= ymin & Yaxis <= ymin+height);
            
            if ~isempty(x_idx) && ~isempty(y_idx)
                subData = param.dataq(y_idx, x_idx); subData(isnan(subData)) = 0; subData(subData < 0) = 0; subData = subData - min(subData(:));
                total_intensity = sum(subData(:));
                if total_intensity > 0
                    [gridX, gridY] = meshgrid(Xaxis(x_idx), Yaxis(y_idx));
                    peak_Qx = sum(subData(:) .* gridX(:)) / total_intensity; peak_Qz = sum(subData(:) .* gridY(:)) / total_intensity;
                else
                    peak_Qx = mean(Xaxis(x_idx)); peak_Qz = mean(Yaxis(y_idx));
                end
                peak_count = peak_count + 1; RawPeaks(peak_count, :) = [peak_Qx, peak_Qz];
                
                % [Fix] "ROI 안에 든 hkl 하나만 detect되는" 문제 대응 +
                % [확장] Transmission/Reflection 두 브랜치 모두 후보로 고려.
                % 애초에 Fine-tune을 쓰는 이유가 "지금 격자상수가 아직 정확하지
                % 않아서" 인데, 그럴 때는 010과 012가 아직 서로 다른 위치에
                % 있을 수 있어서 딱 그려놓은 좁은 ROI 하나에 둘 다 들어오지
                % 않는 경우가 많다. 그래서 3단계로 점점 범위를 넓혀가며 찾는다
                % (T/R 두 브랜치를 합친 allQhor/allQver/allHKL/allBranch에서):
                %   1) 그린 ROI 박스 안
                %   2) 그래도 2개 미만이면, ROI를 중심 기준으로 2배 넓혀서 재시도
                %   3) 그래도 2개 미만이면, 실측 위치에서 가까운 순으로 최대 4개
                %      (박스 안에 있는지와 무관하게) -- 이러면 최소한 여러 개의
                %      "겹칠 법한" 후보를 보여주고, 사용자가 다이얼로그에서
                %      직접 골라내거나 다듬을 수 있다.
                cx = xmin + width/2; cy = ymin + height/2;
                in_roi = allQhor >= xmin & allQhor <= xmin+width & allQver >= ymin & allQver <= ymin+height;
                detected_hkl = allHKL(in_roi, :); detected_branch = allBranch(in_roi);
                
                if size(detected_hkl, 1) < 2
                    w2 = width; h2 = height; % 중심 기준 2배 폭(=원래 폭만큼 양쪽으로 확장)
                    in_roi2 = allQhor >= cx-w2 & allQhor <= cx+w2 & allQver >= cy-h2 & allQver <= cy+h2;
                    if sum(in_roi2) >= 2
                        detected_hkl = allHKL(in_roi2, :); detected_branch = allBranch(in_roi2);
                    end
                end
                
                if size(detected_hkl, 1) < 2
                    dist = sqrt((allQhor - peak_Qx).^2 + (allQver - peak_Qz).^2);
                    [dist_sorted, order_near] = sort(dist, 'ascend');
                    % 너무 먼 것까지 억지로 4개 채우지 않도록, ROI 크기의 3배
                    % (최소 0.08 A^-1) 이내인 것만 후보로 인정한다.
                    maxDist = max(3*max(width, height), 0.08);
                    keep = order_near(dist_sorted <= maxDist);
                    nTop = min(4, numel(keep));
                    if nTop == 0, nTop = 1; keep = order_near; end
                    detected_hkl = allHKL(keep(1:nTop), :); detected_branch = allBranch(keep(1:nTop));
                end
                
                % TentativeGroups{i}는 이제 Nx4 = [h k l branch] (branch: 1=T, 2=R)
                TentativeGroups{peak_count} = [detected_hkl, detected_branch];
                TentativeHKL(peak_count, :) = detected_hkl(1, :);
                
                branchStr = repmat({'T'}, numel(detected_branch), 1); branchStr(detected_branch==2) = {'R'};
                hklLabel = strjoin(compose('(%d %d %d)%s', detected_hkl(:,1), detected_hkl(:,2), detected_hkl(:,3), string(branchStr)), ' ');
                hold(hAXtab, 'on'); plot(hAXtab, peak_Qx, peak_Qz, 'rx', 'MarkerSize', 12, 'LineWidth', 2);
                text(peak_Qx, peak_Qz, ['  ' hklLabel '?'], 'Parent', hAXtab, 'Color', 'r', 'FontSize', 10, 'FontWeight', 'bold');
                hold(hAXtab, 'off');
            end
            
            choice = questdlg('피크를 더 선택하시겠습니까?', 'Next', 'Yes', 'No', 'Cancel', 'Yes');
            delete(hROI); 
            if strcmp(choice, 'No'), break; elseif strcmp(choice, 'Cancel'), return; end
        end
        if peak_count < 3, warndlg('최소 3개 이상의 피크가 필요합니다.', 'Warning'); return; end
        
        % ==================================================================
        % [Fine-tune + hkl 그룹 지정 모드] "010과 012가 한 점에, 10-2/110/
        % 11-1/10-1이 최대한 한 점에 모이게" 처럼, 여러 hkl이 같은 실측
        % 위치에서 겹쳐 보이는 걸 알고 있을 때를 위한 모드. matchpairs로
        % "피크 하나 <-> hkl 하나"를 자동으로 짝짓는 대신, 사용자가 각
        % 피크마다 "여기서 겹쳐야 하는 hkl들"을 직접 지정하고, 그 hkl들이
        % 실제로 한 점에 모이도록(그룹 내 퍼짐 최소화) + 그 점이 클릭한
        % 위치에 오도록(그룹 중심과 실측 위치 일치) 격자상수를 피팅한다.
        % ==================================================================
        if hFineTune.Value
            prompts = cell(1, peak_count);
            defaults = cell(1, peak_count);
            for i = 1:peak_count
                prompts{i} = sprintf(['Peak %d (qxy=%.3f, qz=%.3f): 겹쳐야 할 hkl들 (세미콜론으로 구분, 예: 0 1 0 T; 0 1 2 R) | ' ...
                    '끝의 T/R은 Transmission/Reflection 브랜치 (생략하면 T)'], i, RawPeaks(i,1), RawPeaks(i,2));
                % [Fix] ROI 안에서 자동 detect된 hkl들(브랜치 포함)을 기본값으로
                % 채워준다. 여전히 직접 수정/추가/삭제 가능.
                grpDefault = TentativeGroups{i}; % [h k l branch] , branch: 1=T, 2=R
                branchLbl = repmat({'T'}, size(grpDefault,1), 1); branchLbl(grpDefault(:,4)==2) = {'R'};
                defaults{i} = strjoin(compose('%d %d %d %s', grpDefault(:,1), grpDefault(:,2), grpDefault(:,3), string(branchLbl)), '; ');
            end
            answer = inputdlg(prompts, 'Fine-tune: 겹치는 hkl 그룹 지정', [1 75], defaults);
            if isempty(answer), return; end
            
            % peakGroups{i}는 Nx4 = [h k l branch] (branch: 1=Transmission, 2=Reflection)
            peakGroups = cell(1, peak_count);
            for i = 1:peak_count
                parts = strsplit(answer{i}, ';');
                hklMat = [];
                for p = 1:numel(parts)
                    tok = strtrim(parts{p});
                    if isempty(tok), continue; end
                    % T/R을 안 적었을 때의 기본값도 Trans./Reflec. 체크박스
                    % 상태를 따라간다 (Reflec.만 켜져 있으면 기본 R).
                    if useR && ~useT, branchCode = 2; else, branchCode = 1; end
                    tokUpper = upper(tok);
                    if endsWith(tokUpper, 'R')
                        branchCode = 2; tok = strtrim(tok(1:end-1));
                    elseif endsWith(tokUpper, 'T')
                        branchCode = 1; tok = strtrim(tok(1:end-1));
                    end
                    nums = sscanf(tok, '%d %d %d')';
                    if numel(nums) == 3, hklMat = [hklMat; nums, branchCode]; end
                end
                if isempty(hklMat)
                    warndlg(sprintf('Peak %d의 hkl 그룹을 해석하지 못했습니다 (예: "0 1 0 T; 0 1 2 R" 형식으로 입력해주세요).', i), 'Warning');
                    return;
                end
                peakGroups{i} = hklMat;
            end
            
            init_params_lat = [a0, b0, c0, al0, be0, ga0];
            lb_full = [1, 1, 1, 60, 60, 60]; ub_full = [60, 60, 60, 120, 120, 120];
            switch param.Xtal
                case 'Cubic',        mask = [1 0 0 0 0 0];
                case 'Hexagonal',    mask = [1 0 1 0 0 0];
                case 'Tetragonal',   mask = [1 0 1 0 0 0];
                case 'Orthorhombic', mask = [1 1 1 0 0 0];
                case 'Monoclinic',   mask = [1 1 1 0 1 0];
                case 'Triclinic',    mask = [1 1 1 1 1 1];
                case 'Rhombohedral', mask = [1 0 0 1 0 0];
                otherwise,           mask = [1 1 1 1 1 1];
            end
            % Fine-tune이니 탐색 범위를 지금 값 근처로 좁힌다 (a,b,c: ±20%, 각도: ±15도)
            tight_lb_full = max(lb_full, init_params_lat - [init_params_lat(1:3)*0.2, 15, 15, 15]);
            tight_ub_full = min(ub_full, init_params_lat + [init_params_lat(1:3)*0.2, 15, 15, 15]);
            var_init = init_params_lat(mask == 1);
            var_lb = tight_lb_full(mask == 1); var_ub = tight_ub_full(mask == 1);
            
            fineOptions = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp', ...
                'StepTolerance', 1e-7, 'OptimalityTolerance', 1e-7, 'MaxFunctionEvaluations', 3000);
            
            paramTrial = param; paramTrial.Normal = hNormDirec.Value;
            objective_fun = @(p) fit_error_func_group(p, init_params_lat, mask, peakGroups, RawPeaks, paramTrial, FixedRotation, nfilm, k0);
            try
                [opt_vals, fval] = fmincon(objective_fun, var_init, [], [], [], [], var_lb, var_ub, [], fineOptions);
            catch err
                warndlg(['Fine-tune 계산 오류: ' err.message], 'Warning'); return;
            end
            
            bestParams = init_params_lat; bestParams(mask==1) = opt_vals;
            GX.haunit.Value = num2str(bestParams(1), '%.4f'); GX.hbunit.Value = num2str(bestParams(2), '%.4f'); GX.hcunit.Value = num2str(bestParams(3), '%.4f');
            GX.halpha.Value = num2str(bestParams(4), '%.2f'); GX.hbeta.Value = num2str(bestParams(5), '%.2f'); GX.hgamma.Value = num2str(bestParams(6), '%.2f');
            
            msgbox(sprintf('Fine-tune 완료 (그룹 지정 모드). Error: %.4g', fval), 'Success');
            Xtalplot_Callback();
            return;
        end
        
        init_params_lat = [a0, b0, c0, al0, be0, ga0];
        % [Fix] a,b,c 상한을 300 -> 60으로 낮췄다. 화면에 보이는 qxy 피크
        % 간격(대략 0.2~0.3 A^-1)만 봐도 실공간 주기는 2*pi/0.2~2*pi/0.3
        % 대략 20~30A 수준이라, 300A짜리 격자는 물리적으로 말이 안 된다.
        % 실제로 이전 결과에서 a=299.5, b=285.0처럼 상한(300)에 거의 딱
        % 붙어버린 게 나왔는데, 이는 "수렴"이 아니라 최적화가 경계에 막혀
        % 멈춘 발산 신호였다. 정말 더 큰 격자가 필요하면 이 값을 늘리면 된다.
        lb_full = [1, 1, 1, 60, 60, 60]; ub_full = [60, 60, 60, 120, 120, 120];
        
        switch param.Xtal
            case 'Cubic',        mask = [1 0 0 0 0 0]; 
            case 'Hexagonal',    mask = [1 0 1 0 0 0]; 
            case 'Tetragonal',   mask = [1 0 1 0 0 0]; 
            case 'Orthorhombic', mask = [1 1 1 0 0 0]; 
            case 'Monoclinic',   mask = [1 1 1 0 1 0]; 
            case 'Triclinic',    mask = [1 1 1 1 1 1]; 
            case 'Rhombohedral', mask = [1 0 0 1 0 0]; 
            otherwise,           mask = [1 1 1 1 1 1];
        end
        
        var_lb = lb_full(mask == 1); var_ub = ub_full(mask == 1);
        
        % ==================================================================
        % [Auto-Indexing - 4차 수정] 사용자가 직접 찾은 답(예: alpha=68,
        % gamma=112 같은 skewed triclinic)과 자동 Solve 결과가 계속 어긋난
        % 이유: 멀티 스타트가 "등방(a=b=c) 스케일"만 시도하고, 각도는 항상
        % 현재 GUI 값 하나로 고정했었다. 그러면 (1) 사용자가 이미 어느 정도
        % 맞는 a,b,c 비율을 넣어놨어도 그 정보가 버려지고, (2) 90도에서 많이
        % 벗어난 각도의 진짜 구조는 애초에 시도조차 안 됐다. 지금은:
        %   1) 격자상수: "사용자가 실제로 넣어둔 a0,b0,c0(비율 그대로)" +
        %      등방 스케일 몇 개(6,10,18)를 같이 시도
        %   2) 각도: "사용자가 실제로 넣어둔 al0,be0,ga0" + 직교(90,90,90) +
        %      육방형(60,60,120)을 같이 시도 (격자상수와 조합)
        %   3) 배정 비용에서 "지수가 작은 hkl을 우선"하는 가중치를 강하게 줌
        %   4) 피팅 결과가 상한/하한 경계에 거의 붙어버리면(=발산 신호)
        %      그 후보는 통째로 버림
        % ==================================================================
        coarseOptions = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp', ...
            'StepTolerance', 1e-4, 'OptimalityTolerance', 1e-4, 'MaxFunctionEvaluations', 150);
        fineOptions = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp', ...
            'StepTolerance', 1e-6, 'OptimalityTolerance', 1e-6, 'MaxFunctionEvaluations', 1500);
        
        candidateResults = struct('fval', {}, 'params_var', {}, 'normal', {}, 'labeled', {}, 'init', {});
        
        % [Fix] 예전 버전의 진짜 약점: "사용자가 Solve 누르기 전에 미리
        % 넣어둔 a0,b0,c0,al0,be0,ga0" 값을 등방(a=b=c) 스케일로만 재활용하고
        % 각도는 항상 al0,be0,ga0 그대로 고정했다. 그러면 (1) a,b,c의 실제
        % 비율(예: b가 a보다 훨씬 크다든지) 정보가 통째로 버려지고, (2) 각도가
        % 90도에서 많이 벗어난 진짜 triclinic 구조(예: alpha=68, gamma=112
        % 같은)에는 애초에 접근조차 못 해봤다. 지금은:
        %   - 격자상수 후보: "사용자가 넣어둔 실제 a0,b0,c0(비율 그대로)"를
        %     반드시 하나 포함하고, 등방 스케일 몇 개(6,10,18)도 추가로 시도
        %   - 각도 후보: "사용자가 넣어둔 실제 al0,be0,ga0"를 반드시 하나
        %     포함하고, 직교(90,90,90)/육방형(60,60,120) 각도도 추가로 시도
        % 이 둘을 조합(cross)해서 여러 시작점에서 각각 매칭+피팅을 시도한다.
        % [정리] Fine-tune 체크 시에는 위쪽 "hkl 그룹 지정" 분기에서 이미
        % return으로 빠져나갔으므로, 여기 아래는 항상 일반(넓은 탐색) 모드다.
        latCandidates = unique([a0, 6, 10, 18], 'stable');
        latCandidates = latCandidates(latCandidates > 0 & isfinite(latCandidates) & latCandidates <= ub_full(1));
        if isempty(latCandidates), latCandidates = 10; end
        
        angleCandidates = [al0, be0, ga0; 90, 90, 90; 60, 60, 120];
        validAngRows = all(angleCandidates > 10 & angleCandidates < 170, 2);
        angleCandidates = angleCandidates(validAngRows, :);
        angleCandidates = unique(angleCandidates, 'rows', 'stable');
        if isempty(angleCandidates), angleCandidates = [90 90 90]; end
        
        % 격자상수 후보 x 각도 후보 조합: 첫 번째(사용자가 실제 넣어둔 a0,b0,c0)는
        % 비율을 그대로 살리고, 나머지는 등방(a=b=c=스케일)으로 시도한다.
        initLatList = {};
        for aIdx = 1:numel(latCandidates)
            for gIdx = 1:size(angleCandidates,1)
                if aIdx == 1 && latCandidates(1) == a0
                    triple = [a0, b0, c0];
                else
                    triple = [latCandidates(aIdx), latCandidates(aIdx), latCandidates(aIdx)];
                end
                initLatList{end+1} = [triple, angleCandidates(gIdx,:)];
            end
        end
        normalDirsToSearch = NormdirecList;
        
        boundTol = 0.02; % 상/하한의 2% 이내면 "경계에 붙었다"고 보고 버림 (아래 hitsBound에서 사용)
        
        hWaitAI = waitbar(0, 'Solve: 후보 탐색 중...', 'Name', 'Solve');
        cleanupWait = onCleanup(@() (isvalid(hWaitAI) && close(hWaitAI)));
        
        useCombo = peak_count <= 6;
        K = 3;
        totalIter = numel(initLatList) * numel(normalDirsToSearch);
        iterCount = 0;
        
        for sgIdx = 1:numel(initLatList)
            init_lat_try = initLatList{sgIdx};
            var_init_try = init_lat_try(mask == 1);
            
            for d = 1:numel(normalDirsToSearch)
                thisNormal = normalDirsToSearch{d};
                iterCount = iterCount + 1;
                try
                    [Tqhor_d, ~, Tqver_d, ~, hkl_list_d] = qvalhkl_gi(init_lat_try(1),init_lat_try(2),init_lat_try(3),init_lat_try(4),init_lat_try(5),init_lat_try(6), hmax,kmax,lmax,-hmax,-kmax,-lmax, ...
                        thisNormal, FixedRotation, param.Xtal, param.Spg, param.CH, param.Mapping, nfilm, k0, param.ai, 0, 0);
                catch
                    continue;
                end
                if isempty(hkl_list_d) || size(hkl_list_d,1) < peak_count, continue; end
                
                % --- [핵심] 최적 할당(Hungarian algorithm)으로 "각 피크 -> 서로
                % 다른 hkl"을 찾는다. shellAll(지수 크기)이 비용의 지배적인
                % 항이 되도록 크게 가중해서, 작은 지수 조합을 강하게 우선한다.
                nCand = size(hkl_list_d, 1);
                shellAll = sum(abs(hkl_list_d), 2)'; % 1 x nCand
                CostMat = zeros(peak_count, nCand);
                for i = 1:peak_count
                    distRow = sqrt((Tqhor_d - RawPeaks(i,1)).^2 + (Tqver_d - RawPeaks(i,2)).^2)';
                    CostMat(i,:) = 10*shellAll + distRow;
                end
                try
                    assignment = matchpairs(CostMat, 1e6);
                catch
                    assignment = [];
                end
                if size(assignment,1) == peak_count
                    rowIdx = zeros(1, peak_count);
                    rowIdx(assignment(:,1)) = assignment(:,2);
                    labeled = zeros(peak_count, 6);
                    for p = 1:peak_count
                        labeled(p,:) = [RawPeaks(p,1), RawPeaks(p,2), hkl_list_d(rowIdx(p),:), rowIdx(p)];
                    end
                    paramTrial = param; paramTrial.Normal = thisNormal;
                    objective_fun = @(p) fit_error_func_lattice(p, init_lat_try, mask, labeled, paramTrial, FixedRotation, hmax, kmax, lmax, nfilm, k0);
                    try
                        [opt_vals, fval] = fmincon(objective_fun, var_init_try, [], [], [], [], var_lb, var_ub, [], coarseOptions);
                        if ~hitsBound(opt_vals, var_lb, var_ub, boundTol)
                            idxNew = numel(candidateResults) + 1;
                            candidateResults(idxNew).fval = fval;
                            candidateResults(idxNew).params_var = opt_vals;
                            candidateResults(idxNew).normal = thisNormal;
                            candidateResults(idxNew).labeled = labeled;
                            candidateResults(idxNew).init = init_lat_try;
                        end
                    catch
                    end
                end
                
                % --- [보조] 피크가 적을 때만: 소규모 조합 탐색도 같이 돌려서
                % 최적 할당 하나에만 의존하지 않고 대안도 비교해본다.
                if useCombo
                    topK = zeros(peak_count, K);
                    for i = 1:peak_count
                        dist_i = sqrt((Tqhor_d - RawPeaks(i,1)).^2 + (Tqver_d - RawPeaks(i,2)).^2);
                        [~, order_by_dist] = sort(dist_i, 'ascend');
                        poolSize = min(20, numel(order_by_dist));
                        pool = order_by_dist(1:poolSize);
                        shellOrder = sum(abs(hkl_list_d(pool,:)), 2);
                        [~, order_by_shell] = sortrows([shellOrder, dist_i(pool)]);
                        poolSorted = pool(order_by_shell);
                        nK = min(K, numel(poolSorted));
                        topK(i, 1:nK) = poolSorted(1:nK)';
                        if nK < K, topK(i, nK+1:end) = poolSorted(1); end
                    end
                    
                    nCombo = K ^ peak_count;
                    for comboIdx = 0:(nCombo-1)
                        sel = zeros(1, peak_count); rem = comboIdx;
                        for p = 1:peak_count
                            sel(p) = mod(rem, K) + 1; rem = floor(rem / K);
                        end
                        rowIdx2 = zeros(1, peak_count);
                        for p = 1:peak_count, rowIdx2(p) = topK(p, sel(p)); end
                        if numel(unique(rowIdx2)) < peak_count, continue; end
                        
                        labeled2 = zeros(peak_count, 6);
                        for p = 1:peak_count
                            labeled2(p,:) = [RawPeaks(p,1), RawPeaks(p,2), hkl_list_d(rowIdx2(p),:), rowIdx2(p)];
                        end
                        
                        paramTrial2 = param; paramTrial2.Normal = thisNormal;
                        objective_fun2 = @(p) fit_error_func_lattice(p, init_lat_try, mask, labeled2, paramTrial2, FixedRotation, hmax, kmax, lmax, nfilm, k0);
                        try
                            [opt_vals2, fval2] = fmincon(objective_fun2, var_init_try, [], [], [], [], var_lb, var_ub, [], coarseOptions);
                        catch
                            continue;
                        end
                        if hitsBound(opt_vals2, var_lb, var_ub, boundTol), continue; end
                        idxNew2 = numel(candidateResults) + 1;
                        candidateResults(idxNew2).fval = fval2;
                        candidateResults(idxNew2).params_var = opt_vals2;
                        candidateResults(idxNew2).normal = thisNormal;
                        candidateResults(idxNew2).labeled = labeled2;
                        candidateResults(idxNew2).init = init_lat_try;
                    end
                end
                
                if isvalid(hWaitAI), waitbar(iterCount/totalIter, hWaitAI); end
            end
        end
        
        if isempty(candidateResults)
            warndlg({'가능한 hkl 조합을 찾지 못했습니다 (경계에 붙은 발산 결과는 자동 제외했습니다).', ...
                '±H,±K,±L 범위를 늘리거나, a,b,c 상한(현재 60A)을 늘려보세요.'}, 'Warning'); return;
        end
        
        % [정밀 재계산] 잔차가 작은 상위 후보 몇 개만 더 정밀한 옵션으로 재피팅
        [~, order] = sort([candidateResults.fval]);
        nRefine = min(10, numel(order));
        
        % [Fix] "사용자가 직접 찾은 값과 비슷하게도 못 간다" 문제 보완: coarse
        % 단계의 배정 오차(잘못된 hkl 매칭 등) 때문에, 사용자가 실제로
        % 넣어뒀던 a0,b0,c0,al0,be0,ga0에서 출발한 후보가 다른(엉뚱한) 후보
        % 보다 coarse fval이 살짝 더 나쁘게 나와 상위 N위 밖으로 밀려날 수
        % 있다. 그러면 진짜 정답에 가장 가까운 시작점이 애초에 정밀
        % 재계산에서 제외되어버린다. 그래서 "사용자가 넣어둔 값에서 출발한"
        % 후보들 중 가장 좋은 것 하나는, coarse 순위와 무관하게 항상
        % 정밀 재계산 대상에 포함시킨다.
        userInit = [a0, b0, c0, al0, be0, ga0];
        isUserStart = false(1, numel(candidateResults));
        for ci = 1:numel(candidateResults)
            isUserStart(ci) = all(abs(candidateResults(ci).init - userInit) < 1e-9);
        end
        if any(isUserStart)
            userIdx = find(isUserStart);
            [~, bestUserLocal] = min([candidateResults(userIdx).fval]);
            userBestIdx = userIdx(bestUserLocal);
            if ~ismember(userBestIdx, order(1:nRefine))
                order = [order(1:nRefine), userBestIdx];
            else
                order = order(1:nRefine);
            end
        else
            order = order(1:nRefine);
        end
        nRefine = numel(order);
        
        bestFval = Inf; bestParams = []; bestNormal = ''; bestLabeled = [];
        searchLog = {};
        for r = 1:nRefine
            cr = candidateResults(order(r));
            paramTrial = param; paramTrial.Normal = cr.normal;
            objective_fun = @(p) fit_error_func_lattice(p, cr.init, mask, cr.labeled, paramTrial, FixedRotation, hmax, kmax, lmax, nfilm, k0);
            try
                [opt_vals, fval] = fmincon(objective_fun, cr.params_var, [], [], [], [], var_lb, var_ub, [], fineOptions);
            catch
                continue;
            end
            if hitsBound(opt_vals, var_lb, var_ub, boundTol), continue; end
            
            hklStrs = cell(1, peak_count);
            for p = 1:peak_count, hklStrs{p} = sprintf('(%d %d %d)', cr.labeled(p,3), cr.labeled(p,4), cr.labeled(p,5)); end
            searchLog{end+1} = sprintf('  %s  %s  ->  err=%.4g', cr.normal, strjoin(hklStrs, ' '), fval);
            
            if fval < bestFval
                bestFval = fval; bestNormal = cr.normal; bestLabeled = cr.labeled;
                bestParams = cr.init; bestParams(mask==1) = opt_vals;
            end
        end
        
        if isempty(bestParams)
            warndlg('정밀 재계산에 실패했습니다 (모든 상위 후보가 경계에 붙었습니다). ±H,±K,±L 또는 a,b,c 상한을 조정해보세요.', 'Warning'); return;
        end
        
        GX.haunit.Value = num2str(bestParams(1), '%.4f'); GX.hbunit.Value = num2str(bestParams(2), '%.4f'); GX.hcunit.Value = num2str(bestParams(3), '%.4f');
        GX.halpha.Value = num2str(bestParams(4), '%.2f'); GX.hbeta.Value = num2str(bestParams(5), '%.2f'); GX.hgamma.Value = num2str(bestParams(6), '%.2f');
        hNormDirec.Value = bestNormal; param.Normal = bestNormal;
        
        msgbox([{sprintf('Best fit: Normal=%s, Error=%.4g', bestNormal, bestFval), '', '[상위 후보 (Normal, hkl 배정) -> 오차]'}, searchLog], 'Auto-Indexing Result');
        Xtalplot_Callback();
    end

    function bad = hitsBound(vals, lb, ub, tolFrac)
        % 피팅 결과가 상/하한 경계에 거의 붙어있으면(=발산/degenerate 신호)
        % true를 반환해서 그 후보를 버리도록 한다.
        tol = tolFrac * max(ub - lb, eps);
        bad = any(vals <= lb + tol) || any(vals >= ub - tol);
    end

    function err = fit_error_func_lattice(var_params, init_params, mask, exp_peaks, param, fixed_rot, hmax, kmax, lmax, nfilm, k0)
        % [재수정 - 진짜 원인] 직전 버전은 매 fmincon 반복마다 qvalhkl_gi로
        % "전체 hkl 그리드"를 다시 생성한 뒤, 그 안에서 목표 (h,k,l)과 정확히
        % 일치하는 행을 find()로 찾아 썼다. 그런데 qvalhkl_gi 내부의
        % ReflCond(소멸 조건) 필터링과, 특히 6번 섹션의 "중복 제거"
        % (unique(round([qxy,abs(qz)],4),'rows','stable'))는 격자상수가 조금만
        % 바뀌어도 어떤 hkl이 "대표값"으로 살아남을지가 불연속적으로 바뀐다.
        % 즉 목표 (h,k,l)이 이번 시행 파라미터에서는 다른 동등 반사에 밀려
        % 리스트에서 통째로 사라져버리는 경우가 생기고, 그러면
        % find(...)가 비어서 catch로 빠져 err=1e10이라는 "절벽"이 생긴다.
        % fmincon(sqp)은 매끄러운(연속미분 가능한) 목적함수를 가정하는
        % 그래디언트 기반 알고리즘이라, 이런 불연속 절벽이 파라미터 공간
        % 곳곳에 있으면 전혀 엉뚱한 곳으로 수렴하거나(절벽을 피해 다니다가),
        % 우연히 절벽에 안 걸리는 "그럴듯해 보이지만 사실은 틀린" 지점에서
        % 멈춰버릴 수 있다. 실제로 관측된 "정사각형 그리드처럼 딱 맞아떨어지는
        % 엉뚱한 패턴"은 바로 이런 우연한 국소해일 가능성이 높다.
        %
        % 해결: 어차피 "이 (h,k,l)이 어디에 찍히는가"만 알면 되므로, 그리드
        % 생성 + 소멸조건 필터링 + Ewald 필터링 + 중복제거를 전부 건너뛰고,
        % qvalhkl_gi의 핵심 기하 계산(B-matrix, Normal Direction 정렬 회전,
        % DWBA 굴절 보정)만 그대로 뽑아내 "이 hkl 하나"에 대해 직접 계산한다.
        % 격자상수에 대해 완전히 매끄러운(연속) 함수가 되므로 fmincon이
        % 안정적으로 수렴한다.
        curr = init_params; curr(mask==1) = var_params;
        a=curr(1); b=curr(2); c=curr(3); al=curr(4); be=curr(5); ga=curr(6);
        
        switch param.Xtal
            case 'Cubic',      b=a; c=a; al=90; be=90; ga=90;
            case 'Hexagonal',  b=a; al=90; be=90; ga=120;
            case 'Tetragonal', b=a; al=90; be=90; ga=90;
            case 'Orthorhombic', al=90; be=90; ga=90;
            case 'Rhombohedral', b=a; c=a; be=al; ga=al;
        end
        
        penalty = 0;
        if a <= 0 || b <= 0 || c <= 0, err = 1e10; return; end
        if al <= 10 || al >= 170 || be <= 10 || be >= 170 || ga <= 10 || ga >= 170, penalty = penalty + 1e5; end
        
        target_hkl = exp_peaks(:,3:5);
        n_peaks = size(exp_peaks, 1);
        try
            calc_qhor = zeros(n_peaks, 1); calc_qz = zeros(n_peaks, 1);
            for i = 1:n_peaks
                [calc_qhor(i), calc_qz(i)] = qSingleHkl(a,b,c,al,be,ga, ...
                    target_hkl(i,1), target_hkl(i,2), target_hkl(i,3), ...
                    param.Normal, fixed_rot, nfilm, k0, param.ai);
            end
            base_err = sum((exp_peaks(:,1) - calc_qhor).^2 + (exp_peaks(:,2) - calc_qz).^2);
        catch
            base_err = 1e10;
        end
        err = base_err + penalty;
    end

    function err = fit_error_func_group(var_params, init_params, mask, peakGroups, expPeaks, param, fixed_rot, nfilm, k0)
        % [Fine-tune 그룹 지정 모드용 목적함수] 각 피크마다 "겹쳐야 한다고
        % 지정된 hkl 그룹"에 대해:
        %   (1) 그룹 내 hkl들의 계산 위치가 서로 얼마나 퍼져있는지(분산) - 이걸
        %       최소화하면 "010과 012가 한 점에 모이는" 격자상수를 찾게 된다.
        %   (2) 그 그룹의 평균 위치가 실제로 클릭한 피크 위치에 오는지
        % 두 가지를 합쳐서 오차로 쓴다.
        curr = init_params; curr(mask==1) = var_params;
        a=curr(1); b=curr(2); c=curr(3); al=curr(4); be=curr(5); ga=curr(6);
        
        switch param.Xtal
            case 'Cubic',      b=a; c=a; al=90; be=90; ga=90;
            case 'Hexagonal',  b=a; al=90; be=90; ga=120;
            case 'Tetragonal', b=a; al=90; be=90; ga=90;
            case 'Orthorhombic', al=90; be=90; ga=90;
            case 'Rhombohedral', b=a; c=a; be=al; ga=al;
        end
        
        penalty = 0;
        if a <= 0 || b <= 0 || c <= 0, err = 1e10; return; end
        if al <= 10 || al >= 170 || be <= 10 || be >= 170 || ga <= 10 || ga >= 170, penalty = penalty + 1e5; end
        
        err = 0;
        try
            for i = 1:numel(peakGroups)
                grp = peakGroups{i}; % [h k l branch] , branch: 1=Transmission, 2=Reflection
                n = size(grp, 1);
                qh = zeros(n, 1); qv = zeros(n, 1);
                for j = 1:n
                    [qh(j), Tqv_j, Rqv_j] = qSingleHkl(a,b,c,al,be,ga, grp(j,1), grp(j,2), grp(j,3), ...
                        param.Normal, fixed_rot, nfilm, k0, param.ai);
                    if size(grp,2) >= 4 && grp(j,4) == 2
                        qv(j) = Rqv_j; % Reflection 브랜치로 지정된 hkl
                    else
                        qv(j) = Tqv_j; % 기본값: Transmission 브랜치
                    end
                end
                mh = mean(qh); mv = mean(qv);
                spread_err = sum((qh - mh).^2 + (qv - mv).^2);
                center_err = (mh - expPeaks(i,1))^2 + (mv - expPeaks(i,2))^2;
                err = err + spread_err + center_err;
            end
        catch
            err = 1e10;
            return;
        end
        err = err + penalty;
    end

    function [qxy, Tqver, Rqver] = qSingleHkl(a,b,c,alpha,beta,gamma,h,k,l,normaldirec,Rotation,nfilm,k0,ai)
        % qvalhkl_gi.m의 3~4, 7번 섹션(B-matrix 구성, Normal Direction 정렬
        % 회전, DWBA 굴절 보정)만 그대로 옮겨서, "그리드 생성 없이 hkl 하나"에
        % 대해서만 계산한다. 격자상수에 대해 매끄러운 함수라 fit에 적합하다.
        % [확장] Transmission(Tqver)뿐 아니라 Reflection(Rqver) 브랜치도 함께
        % 반환한다. 표면에서의 굴절(DWBA) 때문에 같은 hkl이라도 투과/반사
        % 두 경로로 서로 다른 qz에 나타날 수 있어서, 어느 쪽이 실제로 관측된
        % 피크와 맞는지 선택할 수 있어야 한다.
        alpha_rad = deg2rad(alpha); beta_rad = deg2rad(beta); gamma_rad = deg2rad(gamma);
        term1 = 1 - cos(alpha_rad)^2 - cos(beta_rad)^2 - cos(gamma_rad)^2;
        term2 = 2 * cos(alpha_rad) * cos(beta_rad) * cos(gamma_rad);
        V = a * b * c * sqrt(term1 + term2);

        ax = a; ay = 0; az = 0;
        bx = b * cos(gamma_rad); by = b * sin(gamma_rad); bz = 0;
        cx = c * cos(beta_rad);
        cy = c * (cos(alpha_rad) - cos(beta_rad) * cos(gamma_rad)) / sin(gamma_rad);
        cz = V / (a * b * sin(gamma_rad));

        A_mat = [ax, bx, cx; ay, by, cy; az, bz, cz];
        B_mat = 2 * pi * inv(A_mat).';
        q_crystal = B_mat * [h; k; l];

        if numel(Rotation) == 3
            rotX = Rotation(1); rotY = Rotation(2); rotZ = Rotation(3);
            cxr = cosd(rotX); sxr = sind(rotX);
            cyr = cosd(rotY); syr = sind(rotY);
            czr = cosd(rotZ); szr = sind(rotZ);
            Rx = [1,0,0; 0,cxr,-sxr; 0,sxr,cxr];
            Ry = [cyr,0,syr; 0,1,0; -syr,0,cyr];
            Rz = [czr,-szr,0; szr,czr,0; 0,0,1];
            R_phi = Rz * Ry * Rx;
        else
            rotZ = Rotation; czr = cosd(rotZ); szr = sind(rotZ);
            R_phi = [czr,-szr,0; szr,czr,0; 0,0,1];
        end

        if ischar(normaldirec) || isstring(normaldirec)
            s = char(normaldirec);
            if numel(s) == 3 && all(isstrprop(s, 'digit'))
                n_vec = [str2double(s(1)); str2double(s(2)); str2double(s(3))];
            else
                n_vec = [0; 0; 1];
            end
        else
            n_vec = normaldirec(:);
        end

        q_n = B_mat * n_vec;
        v1 = q_n / norm(q_n);
        v2 = [0; 0; 1];
        v_cross = cross(v1, v2);
        s_norm = norm(v_cross);
        c_dot = dot(v1, v2);
        if s_norm < 1e-7
            if c_dot > 0, R_align = eye(3); else, R_align = -eye(3); end
        else
            Vx = [0,-v_cross(3),v_cross(2); v_cross(3),0,-v_cross(1); -v_cross(2),v_cross(1),0];
            scale_fact = (1 - c_dot) / (s_norm^2);
            R_align = eye(3) + Vx + (Vx^2 * scale_fact);
        end

        R_total = R_phi * R_align;
        q_lab = R_total * q_crystal;
        qx = q_lab(1); qy = q_lab(2); qz = q_lab(3);
        qxy = sqrt(qx^2 + qy^2);

        term_taf1 = (qz / k0)^2 + sind(ai)^2;
        term_taf2 = (2 * qz / k0) * sqrt(nfilm^2 - 1 + sind(ai)^2);
        Taf = real(asind(sqrt(term_taf1 - term_taf2)));
        Raf = real(asind(sqrt(term_taf1 + term_taf2)));
        Tqver = k0 * (sind(Taf) + sind(ai));
        Rqver = k0 * (sind(Raf) + sind(ai));
    end
    
    function rot = get_normal_rotation(direc, sys, ~, ~, ~)
        rot = [0 0 0];
        switch direc
            case '001', rot = [0 0 0];
            case '010', rot = [90 0 0];
            case '100', if ismember(sys, {'Cubic','Orthorhombic','Tetragonal','Monoclinic','Rhombohedral','Triclinic'}), rot = [0 -90 0]; else, rot = [0 90 0]; end
        end
    end

    function rotated_pts = apply_rotation_matrix(pts, angles)
        alpha = angles(1); beta = angles(2); gamma = angles(3);
        Rx = [1 0 0; 0 cosd(alpha) -sind(alpha); 0 sind(alpha) cosd(alpha)];
        Ry = [cosd(beta) 0 sind(beta); 0 1 0; -sind(beta) 0 cosd(beta)];
        Rz = [cosd(gamma) -sind(gamma) 0; sind(gamma) cosd(gamma) 0; 0 0 1];
        R = Rx * Ry * Rz; rotated_pts = R * pts;
    end

    function ErasePeak_Callback(~,~)
        if isempty(params) || ~isfield(params, 'Tqhor') || isempty(params.Tqhor)
            warndlg('삭제할 피크가 없습니다. 먼저 [Plot]을 눌러 시뮬레이션을 생성하세요.', 'Warning'); return;
        end
        
        msgbox({'[피크 지우기 모드]', '1. 화면에서 지우고 싶은 피크를 클릭하세요.', '완료되면 마우스 오른쪽 버튼을 누르거나 [Enter]를 치세요.'}, 'Erase Peak');
        
        while true
            try [cx, cy, button] = ginput(1); catch, break; end
            if isempty(button) || button ~= 1, break; end
            
            xlim_val = get(hAXtab, 'XLim'); ylim_val = get(hAXtab, 'YLim');
            if cx < xlim_val(1) || cx > xlim_val(2) || cy < ylim_val(1) || cy > ylim_val(2), continue; end
            
            if contains(param.Mapping, 'Q'), x_data = params.Tqhor; y_data = params.Tqver;
            elseif strcmp(param.Mapping, 'Alpha'), x_data = params.Ttth; y_data = params.Taf;
            else, x_data = param.SDD .* tand(params.Ttth) ./ param.pixel; y_data = param.SDD ./ cosd(params.Ttth) .* tand(params.Taf) ./ param.pixel;
            end
            
            x_range = xlim_val(2) - xlim_val(1); y_range = ylim_val(2) - ylim_val(1);
            dist = sqrt(((x_data - cx)/x_range).^2 + ((y_data - cy)/y_range).^2);
            [min_dist, min_idx] = min(dist);
            
            if min_dist < 0.03
                params.Tqhor(min_idx) = []; params.Tqver(min_idx) = []; params.Rqhor(min_idx) = []; params.Rqver(min_idx) = [];
                params.hkl(min_idx, :) = []; params.Taf(min_idx) = []; params.Raf(min_idx) = []; params.Ttth(min_idx) = []; params.Rtth(min_idx) = [];
                Imageplot2DHKL;
            end
        end
    end

    function err = fit_error_weighted_z(p, exp_peaks, bounds)
        a=p(1); b=p(2); c=p(3); al=p(4); be=p(5); ga=p(6);
        penalty = 0; min_sz = bounds(1); max_sz = bounds(2);
        
        if a < min_sz || a > max_sz, penalty = penalty + 100*(min_sz-a)^2 + 100; end
        if b < min_sz || b > max_sz, penalty = penalty + 100*(min_sz-b)^2 + 100; end
        if c < min_sz || c > max_sz, penalty = penalty + 100*(min_sz-c)^2 + 100; end
        if al < 60 || al > 130, penalty = penalty + 1e6 * (abs(al-95))^2; end
        if be < 60 || be > 130, penalty = penalty + 1e6 * (abs(be-95))^2; end
        if ga < 60 || ga > 130, penalty = penalty + 1e6 * (abs(ga-95))^2; end
        if (al > 90) && (be > 90) && (ga > 90), penalty = penalty + 1e7; end
        
        try [q100, q010, q001, ar, br, gr] = lp2qp(a,b,c,al,be,ga); if q100==0, penalty = penalty + 1e10; end 
        catch, penalty = penalty + 1e10; end
        
        if penalty > 1e4, err = penalty; return; end
        [H, K, L] = ndgrid(-4:4, -4:4, 0:6);
        
        Qx_t = H(:).*(q100*sind(br)*sind(gr)); Qy_t = H(:).*(q100*cosd(gr)*sind(ar)) + K(:).*(q010*sind(ar)); Qz_t = H(:).*(q100*cosd(br)) + K(:).*(q010*cosd(ar)) + L(:).*q001;
        Qhor_t = sqrt(Qx_t.^2 + Qy_t.^2);
        
        total_dist = 0; w_z = 5.0; w_h = 1.0; 
        for i = 1:size(exp_peaks, 1)
            d_h2 = (Qhor_t - exp_peaks(i,1)).^2; d_z2 = (Qz_t - exp_peaks(i,2)).^2;
            total_dist = total_dist + min(w_h * d_h2 + w_z * d_z2);
        end
        err = total_dist + penalty;
    end

    function SmartRange_Callback(~,~)
        if ~isfield(param, 'dataq') && ~isfield(param, 'datapx')
            warndlg('데이터가 로드되지 않았습니다.', 'Warning'); return;
        end
        
        a = str2double(GX.haunit.Value); b = str2double(GX.hbunit.Value); c = str2double(GX.hcunit.Value);
        if isnan(a) || a<=0, a=10; end; if isnan(b) || b<=0, b=10; end; if isnan(c) || c<=0, c=10; end
        
        max_q = 3.0; 
        if contains(param.Mapping, 'Q')
            q_xlim = str2double(GX.cXlim2.Value); q_ylim = str2double(GX.cYlim2.Value);
            if ~isnan(q_xlim) && ~isnan(q_ylim), max_q = sqrt(q_xlim^2 + q_ylim^2); end
        else, max_q = 3.5; end
        
        req_h = ceil(max_q * a / (2*pi)) + 1; req_k = ceil(max_q * b / (2*pi)) + 1; req_l = ceil(max_q * c / (2*pi)) + 1;
        
        hHidx.Value = num2str(req_h); hKidx.Value = num2str(req_k); hLidx.Value = num2str(req_l);
        Xtalplot_Callback();
    end

    function Refrac_Callback(~,~)
        try Refraction_GUI(param, hCritiA); catch, warndlg('Refraction_GUI.m missing.', 'Error'); end
    end

    function Savefile_Callback(~,~)
        HoldingIm = hHoldingS.Value;
        if isempty(param) || ~isfield(param, 'Path'), warndlg('No data loaded to save!', 'Warning'); return; end
        
        filepath = fullfile(param.Path, param.FileName); if ~exist(filepath, 'dir'), mkdir(filepath); end
        
        CriticalAngle = str2double(hCritiA.Value); InciAng = str2double(hIncidA.Value);
        Xtal_New = XTal.hCrystsys.Value; Spg_New = XTal.hSpaceGrp.Value; Normal_New = hNormDirec.Value;
        lattice_New = [str2double(GX.haunit.Value), str2double(GX.hbunit.Value), str2double(GX.hcunit.Value), str2double(GX.halpha.Value), str2double(GX.hbeta.Value), str2double(GX.hgamma.Value)];
        Rotation_New = [str2double(hXrot.Value), str2double(hYrot.Value), str2double(hZrot.Value)];

        SaveMatFile = fullfile(filepath, [param.FileName,'_Fitparams.mat']);
        SaveImgFile = fullfile(filepath, [param.FileName,'_2DImageHKL.jpg']);

        if HoldingIm == false
            Xtal = Xtal_New; Spg = Spg_New; NormalDirec = Normal_New; lattice = lattice_New; Rotation = Rotation_New;
            save(SaveMatFile, 'CriticalAngle','InciAng','Xtal','Spg','NormalDirec','lattice','Rotation');
        else
            if isfield(param, 'unitold')
                lattice_Old = param.unitold(1:6); Rotation_Old = param.unitold(7:9);
                Xtal_Old = param.Xtalold; Spg_Old = param.Spgold; Normal_Old = param.Normalold;
            else
                Xtal_Old = ''; Spg_Old = ''; Normal_Old = ''; lattice_Old = []; Rotation_Old = [];
            end
            Xtal1 = Xtal_Old; Spg1 = Spg_Old; NormalDirec1 = Normal_Old; lattice1 = lattice_Old; Rotation1 = Rotation_Old;
            Xtal2 = Xtal_New; Spg2 = Spg_New; NormalDirec2 = Normal_New; lattice2 = lattice_New; Rotation2 = Rotation_New;
            
            save(SaveMatFile, 'CriticalAngle','InciAng', 'Xtal1','Spg1','NormalDirec1','lattice1','Rotation1', 'Xtal2','Spg2','NormalDirec2','lattice2','Rotation2');
        end
        exportgraphics(Im2Dplot, SaveImgFile);
        msgbox('Parameters and Image saved successfully!', 'Success');
    end

    function LineCut_Callback(~,~)
        if ~isfield(param, 'datapx') || isempty(param.datapx), warndlg('데이터가 로드되지 않았습니다.', 'Warning'); return; end
        msgbox('이미지 위에서 마우스 드래그로 선을 그리세요.', 'Info');
        hLine = drawline(hAXtab, 'Color', 'r', 'LineWidth', 2, 'Label', '1D Profile Extract', 'LabelVisible', 'hover');
        if ~isvalid(hLine), return; end
        
        fig1D = uifigure('Name', 'Interactive 1D Line Profile');
        ax1D = uiaxes(fig1D);
        hLinePlot = plot(ax1D, NaN, NaN, 'r-', 'LineWidth', 1.5); grid(ax1D, 'on');
        if strcmp(param.Mapping, 'Pixel'), xlabel(ax1D, 'Distance (pixel)'); else, xlabel(ax1D, 'Distance (reciprocal space, A^{-1})'); end
        ylabel(ax1D, 'Intensity');
        
        update_profile = @(src, evt) extract_and_plot(src, hAXtab, hLinePlot, ax1D);
        extract_and_plot(hLine, hAXtab, hLinePlot, ax1D);
        addlistener(hLine, 'MovingROI', update_profile);
        addlistener(hLine, 'ROIMoved', update_profile);
    end

    function extract_and_plot(hLineObj, hAxes, plotObj, destAxes)
        if ~isvalid(hLineObj) || ~isvalid(plotObj), return; end
        pos = hLineObj.Position; x1 = pos(1,1); y1 = pos(1,2); x2 = pos(2,1); y2 = pos(2,2);
        hImgObj = findobj(hAxes, 'Type', 'Image');
        if isempty(hImgObj), return; end
        
        try
            [cx, cy, c] = improfile(double(hImgObj.XData), double(hImgObj.YData), hImgObj.CData, double([x1, x2]), double([y1, y2]), 200);
            dist_axis = sqrt((cx - cx(1)).^2 + (cy - cy(1)).^2);
            set(plotObj, 'XData', dist_axis, 'YData', c);
            title(destAxes, sprintf('Line Cut: (%.2f, %.2f) to (%.2f, %.2f)', x1, y1, x2, y2));
        catch, end
    end

    function Resize_Callback(src, ~)
        referenceHeight = 900; 
        pos = src.Position;
        currHeight = pos(4);
        
        scaleFactor = max(currHeight / referenceHeight, 0.5);
        allObj = findall(src, '-property', 'FontSize');
        
        for i = 1:length(allObj)
            obj = allObj(i);
            if isempty(get(obj, 'UserData')) || ~isstruct(get(obj, 'UserData')) || ~isfield(get(obj, 'UserData'), 'BaseFontSize')
                ud.BaseFontSize = get(obj, 'FontSize'); 
                set(obj, 'UserData', ud);
            else
                ud = get(obj, 'UserData');
            end
            set(obj, 'FontSize', ud.BaseFontSize * scaleFactor);
        end
    end

    function KeyPress_Callback(~, event)
        currentObj = gco;
        if ~isempty(currentObj)
            if isprop(currentObj, 'Style')
                if strcmpi(currentObj.Style, 'edit'), return; end
            end
            if isprop(currentObj, 'Type')
                if contains(currentObj.Type, 'edit', 'IgnoreCase', true), return; end
            end
        end

        step_angle = 0.5; 
        if ismember('shift', event.Modifier), step_angle = 2.0; end 

        currentX = str2double(hXrot.Value);
        currentY = str2double(hYrot.Value);
        currentZ = str2double(hZrot.Value);

        changed = false;
        switch event.Key
            case 'uparrow',   currentX = currentX + step_angle; changed = true;
            case 'downarrow', currentX = currentX - step_angle; changed = true;
            case 'leftarrow', currentZ = currentZ - step_angle; changed = true;
            case 'rightarrow',currentZ = currentZ + step_angle; changed = true;
            case 'pageup',    currentY = currentY + step_angle; changed = true;
            case 'pagedown',  currentY = currentY - step_angle; changed = true;
        end

        if changed
            hXrot.Value = num2str(currentX);
            hYrot.Value = num2str(currentY);
            hZrot.Value = num2str(currentZ);
            Xtalplot_Callback(); 
        end
    end
end
