function TrXSXtal2D_gui
%#ok<*AGROW,*NASGU,*DEFNU,*ALIGN,*INUSD>

figW = 1500;
figH = 900;
main = figure('Name','TrXS-indexing',...
    'NumberTitle','off', ...
    'Units','pixels', ...
    'Position',[100 100 figW figH], ...
    'Color',[0.95 0.95 0.95], ...
    'MenuBar','none', ...
    'ToolBar','figure');
main.SizeChangedFcn = @Resize_Callback;
main.WindowKeyPressFcn = @KeyPress_Callback;
movegui(main, 'center');

coldf = [0.95 0.95 0.95]; %[0 1 1];%[0.95 0.95 0.95];

% tgroup = uitabgroup('Parent', main);
% tab1 = uitab('Parent', tgroup, 'Title', '2D Analysis'); %tab for data analysis

% ========================================================================
% tab1 uicontrol =========================================================
leftPanelData = uipanel('Parent',main,'Title','Control Panel','FontSize',...
    12,'Units','Normalized','Position',[0.01 0.01 0.28 0.98], ...
    'BackgroundColor',coldf);

% Image position and plot ================================================
Im2Dplot = uipanel('Parent',main,'Title','TrXS-Indexing','FontSize',...
    12,'Units','Normalized','Position',[0.30 0.10 0.69 0.89],'BackgroundColor',[1 1 1]);

hAXtab = axes('Parent',Im2Dplot,'Position',[0.06 0.08 0.90 0.86]);

ImageController = uipanel('Parent',main,'Title','Image Controller','FontSize',...
    10,'Units','Normalized','Position',[0.30 0.01 0.69 0.08], ...
    'BackgroundColor',coldf);

%=========================================================================
% version
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Designed By Y.Y.Kim v1.0 (PLS-II BL3C)','Units','normalized',...
    'BackgroundColor',coldf,...
    'Position',[0.03 0.008 0.90 0.03]);

%=========================================================================
% Open data for tab1
uicontrol('Parent',leftPanelData,'String','Open data','FontSize',11,'Units','normalized',...
    'FontWeight','bold','Position',[0.125 0.92 0.75 0.055],...
    'Callback',@Opendata_Callback);

%=========================================================================
% Xtal structure line plot for tab1
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Crystal System',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.87 0.30 0.02]);

XTal.CrystalSystem = {'Layer',...
                      'Hexagonal',...
                      'HCP',...
                      'Cubic',...
                      'Orthorhombic',...
                      'Tetragonal',...
                      'Monoclinic',...
                      'Rhombohedral',...
                      'Triclinic'};

XTal.hCrystsys = uicontrol('Parent',leftPanelData,'Style','popupmenu','Units','normalized',...
    'Position',[0.05 0.82 0.30 0.05],'String',XTal.CrystalSystem,...
    'Callback',@SpaceGroup_Callback);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Space Group',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.35 0.87 0.30 0.02]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Choice',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.65 0.87 0.30 0.02]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Prefered Orientation',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.12 0.813 0.375 0.02]);

OriList = {'001', '010', '100', '101', '011', '110', '111', '121'};

uicontrol('Parent',leftPanelData,'Style','popupmenu','Units','normalized',...
    'Position',[0.53 0.788 0.32 0.05],'String',OriList);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','a [A,h]',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.03 0.78 0.15 0.02]);

TX.haunit = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.18 0.775 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','b [A,k]',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.03 0.7475 0.15 0.02]);

TX.hbunit = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.18 0.7425 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','c [A,l]',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.03 0.715 0.15 0.02]);

TX.hcunit = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.18 0.71 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','alpha',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.35 0.78 0.15 0.02]);

TX.halpha = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','90',...
    'Units','normalized','Position',[0.50 0.775 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','beta',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.35 0.7475 0.15 0.02]);

TX.hbeta = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','90',...
    'Units','normalized','Position',[0.50 0.7425 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','gamma',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.35 0.715 0.15 0.02]);

TX.hgamma = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','90',...
    'Units','normalized','Position',[0.50 0.71 0.15 0.03]);

% hkl min & max ==========================================================
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','±H',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.665 0.1 0.02]);

hHidx = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','3',...
    'Units','normalized','Position',[0.15 0.66 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','±K',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.30 0.665 0.1 0.02]);

hKidx = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','3',...
    'Units','normalized','Position',[0.40 0.66 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','±L',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.55 0.665 0.1 0.02]);

hLidx = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','3',...
    'Units','normalized','Position',[0.65 0.66 0.15 0.03]);

% ========================================================================
% Orientation
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','X-rot',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.632 0.1 0.02]);

hXrot = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','0',...
    'Units','normalized','Position',[0.15 0.627 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Y-rot',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.30 0.632 0.1 0.02]);

hYrot = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','0',...
    'Units','normalized','Position',[0.40 0.627 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Z-rot',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.55 0.632 0.1 0.02]);

hZrot = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','0',...
    'Units','normalized','Position',[0.65 0.627 0.15 0.03]);

% ========================================================================
% plot Xtal position in reciprocal space
uicontrol('Parent',leftPanelData,'String','Plot','Units','normalized',...
    'Position',[0.7 0.71 0.25 0.095],...
    'Callback',@Xtalplot_Callback);

% ========================================================================
% Special case
hSpecial = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Special','Value', 0,...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.075 0.57 0.22 0.03])    ;

% ========================================================================
% Random orientation
hRandOri = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Random Ori.','Value', 0,...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.275 0.57 0.22 0.03])    ;

% ========================================================================
% Holding the structure
hHoldingS = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Holding','Value', 0,...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.50 0.57 0.22 0.03])    ;

% ========================================================================
% Ewald effect
hEwaldS = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Ewald','Value', 0,...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.72 0.57 0.22 0.03])    ;

% ========================================================================
% hkl plot
HKLplot = uipanel('Parent',leftPanelData,'Title','HKLplot','FontSize',...
    9,'Units','Normalized','Position',[.05 0.47 .45 .09]);

hHKLCheck = uicontrol('Parent',HKLplot,'Style','checkbox',...
    'String','HKL','Value',0,...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.04 0.65 0.4 0.3])    ;

hHKLplane = uicontrol('Parent',HKLplot,'Style','checkbox',...
    'String','Plane','Value',0,...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.55 0.65 0.4 0.3])     ;

PLNpos = {'left', 'center', 'right', 'top', 'bottom'};
hPLNpos = uicontrol('Parent',HKLplot,'Style','popupmenu','Units','normalized',...
    'Position',[0.55 0.25 0.4 0.3],'String',PLNpos);

% ========================================================================
% Table
uicontrol('Parent',leftPanelData,'String','Table','FontSize',10,'Units','normalized',...
    'Position',[0.51 0.515 0.2 0.04],...
    'Callback',@HKLTable_Callback);

% ========================================================================
% Solving
uicontrol('Parent',leftPanelData,'String','Solve','FontSize',10,'Units','normalized',...
    'Position',[0.72 0.515 0.2 0.04],...
    'Callback',@Solveparam_Callback);

% ========================================================================
% Radial Average Plot
uicontrol('Parent',leftPanelData,'String','Ave. Plot','FontSize',10,'Units','normalized',...
    'Position',[0.51 0.475 0.2 0.04],...
    'Callback',@RadialAve_Callback);

% ========================================================================
% Smart HKL range
uicontrol('Parent',leftPanelData,'String','Smart','FontSize',10,'Units','normalized',...
    'Position',[0.72 0.475 0.2 0.04],...
    'Callback',@SmartRange_Callback);

% ========================================================================
% Structure plot color, shape. size changer
colorcode = {'white','black','red','orange','yellow','green','blue','magenta','purple'};

shapecode = {'circle','square','diamond','pentagram','hexagram'};

% Holding options
OptionO = uipanel('Parent',leftPanelData,'Title','Hold (opt.)','FontSize',...
    9,'Units','Normalized','Position',[0.05 0.27 0.45 0.20]);

uicontrol('Parent',OptionO,'Style','text',...
    'String','Trans.',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.5 0.865 0.3 0.1]);

uicontrol('Parent',OptionO,'Style','text',...
    'String','Color',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.67 0.25 0.1]);

hSTColorO = uicontrol('Parent',OptionO,'Style','popupmenu','Units','normalized',...
    'Position',[0.5 0.7 0.4 0.1],'String',colorcode);

uicontrol('Parent',OptionO,'Style','text',...
    'String','Shape',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.47 0.25 0.1]);

hSTShapeO = uicontrol('Parent',OptionO,'Style','popupmenu','Units','normalized',...
    'Position',[0.5 0.50 0.4 0.1],'String',shapecode);

uicontrol('Parent',OptionO,'Style','text',...
    'String','Size',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.25 0.25 0.1]);

hSTSizeO = uicontrol('Parent',OptionO,'Style','edit',...
        'String','6',...
        'Units','normalized','Position',[0.5 0.23 0.4 0.15]);

hSEmptyO = uicontrol('Parent',OptionO,'Style','checkbox',...
    'String','Empty','Value', 0,...
    'Units','normalized','Position',[0.5 0.05 0.5 0.15])    ;

% Current options
OptionN = uipanel('Parent',leftPanelData,'Title','Current (opt.)','FontSize',...
    9,'Units','Normalized','Position',[0.51 0.27 0.45 0.20]);

uicontrol('Parent',OptionN,'Style','text',...
    'String','Trans.',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.5 0.865 0.3 0.1]);

uicontrol('Parent',OptionN,'Style','text',...
    'String','Color',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.67 0.25 0.1]);

hSTColorN = uicontrol('Parent',OptionN,'Style','popupmenu','Units','normalized',...
    'Position',[0.5 0.7 0.4 0.1],'String',colorcode);

uicontrol('Parent',OptionN,'Style','text',...
    'String','Shape',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.47 0.25 0.1]);

hSTShapeN = uicontrol('Parent',OptionN,'Style','popupmenu','Units','normalized',...
    'Position',[0.5 0.50 0.4 0.1],'String',shapecode);

uicontrol('Parent',OptionN,'Style','text',...
    'String','Size',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.05 0.25 0.25 0.1]);

hSTSizeN = uicontrol('Parent',OptionN,'Style','edit',...
        'String','6',...
        'Units','normalized','Position',[0.5 0.23 0.4 0.15]);

hSEmptyN = uicontrol('Parent',OptionN,'Style','checkbox',...
    'String','Empty','Value', 0,...
    'Units','normalized','Position',[0.5 0.05 0.5 0.15])    ;

%=========================================================================
% UnitCell Image
UnitImage = uipanel('Parent',leftPanelData,'Title','Navigator','FontSize',...
    9,'Units','Normalized','Position',[.02 0.01 .95 .26]);
hImunit = axes('Parent',UnitImage,'position',[0.1 0.15 0.75 0.75]);

%=========================================================================
% color scale 
uicontrol('Parent',ImageController,'Style','text',...
    'String','ColorScale',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.015 0.70 0.06 0.2]);

scaleList = {'Linear', 'Log'};
hScale = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.015 0.225 0.06 0.4],'String',scaleList,...
    'Callback',@Updateimage_Callback);

%=========================================================================
% colormap selector
uicontrol('Parent',ImageController,'Style','text',...
    'String','Colormap',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.09 0.70 0.06 0.2]);

ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis','cubehelix','magma','kindlemann','ocean','jet2','rwb','rkb'};

hColor = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.09 0.225 0.06 0.4],'String',ColormapList,...
    'Callback',@Updateimage_Callback);

%=========================================================================
% Contrast of colormap
uicontrol('Parent',ImageController,'Style','text',...
    'String','Contrast',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.16 0.70 0.1 0.2]);

TX.cMin = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.16 0.28 0.05 0.35],...
    'Callback',@Updateimage_Callback);

TX.cMax = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1e6',...
    'Units','normalized','Position',[0.21 0.28 0.05 0.35],...
    'Callback',@Updateimage_Callback);

% ========================================================================
% map transform
uicontrol('Parent',ImageController,'Style','text',...
    'String','Map format',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.27 0.70 0.06 0.2]);

MapList = {'Pixel', 'Qy/Qz'};
hMapping = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.27 0.225 0.06 0.4],'String',MapList,...
    'Callback',@Rangecal_Callback);

%=========================================================================
% Image Range
uicontrol('Parent',ImageController,'Style','text',...
    'String','Y-range',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.34 0.70 0.1 0.2]);

TX.cXlim1 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.34 0.28 0.05 0.35],...
    'Callback',@Updateimage_Callback);

TX.cXlim2 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','2000',...
    'Units','normalized','Position',[0.39 0.28 0.05 0.35],...
    'Callback',@Updateimage_Callback);

uicontrol('Parent',ImageController,'Style','text',...
    'String','Z-range',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.445 0.70 0.1 0.2]);

TX.cYlim1 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.445 0.28 0.05 0.35],...
    'Callback',@Updateimage_Callback);

TX.cYlim2 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','2000',...
    'Units','normalized','Position',[0.495 0.28 0.05 0.35],...
    'Callback',@Updateimage_Callback);
% ========================================================================
% font size
uicontrol('Parent',ImageController,'Style','text',...
    'String','Font Size',...
    'BackgroundColor',coldf,...
    'Units','normalized','Position',[0.545 0.70 0.06 0.2]);

TX.FontSz = uicontrol('Parent',ImageController,'Style','edit',...
    'String','18',...
    'Units','normalized','Position',[0.55 0.28 0.05 0.35],...
    'Callback',@Updateimage_Callback);

%=========================================================================
% line cut for tab1
uicontrol('Parent',ImageController,'String','Line Cut','Units','normalized',...
    'FontSize',9,'Position',[0.655 0.25 0.1 0.7],...
    'Callback',@LineCut_Callback);

%=========================================================================
% update Image for tab1
uicontrol('Parent',ImageController,'String','Update Image','Units','normalized',...
    'FontSize',9,'Position',[0.77 0.25 0.1 0.7],...
    'Callback',@Updateimage_Callback);

% ========================================================================
% save image for tab1
uicontrol('Parent',ImageController,'String','Save Image','Units','normalized',...
    'FontSize',9,'Position',[0.885 0.25 0.1 0.7],...
    'Callback',@Savefile_Callback);

%========================================================================= 

%=========================================================================
% Functions
% ========================================================================
param.data = [];
params.data = [];
applyModernControlStyle(main);
Resize_Callback(main, []);
% open data
    function Opendata_Callback(~,~)
        clear param

        if ~exist('XSData','file')
            [XSData, datadir]=uigetfile({'*.*','All format(*.*)';'*.mat','Mat file(*.mat)'});
            if XSData==0
                return;
            end
            XSData = fullfile(datadir, XSData);
        end

        [param.Path, param.FileName, ~]=fileparts(XSData);

        try
            [D, loadReport] = loadPGIXS2DInfo(XSData, 'TrXS');
            if ~loadReport.OK
                warndlg(['Required field(s) missing: ', ...
                    strjoin(loadReport.MissingRequired, ', ')], 'Invalid 2D Info');
                return;
            end
            if ~isempty(loadReport.Warnings)
                warning('PGIXS:TwoDInfoLoadWarning', '%s', ...
                    ['2D info load warning: ', strjoin(loadReport.Warnings, ' | ')]);
            end

            param.datapx = single(D.data2dPix);
            param.dataq = single(D.data2dQ);
            param.Q = single(D.QMap);
            param.Qx = single(D.QxMap);
            param.Qy = single(D.QyMap);
            param.Qz = single(D.QzMap);
            param.qy = single(D.qyaxis);
            param.qz = single(D.qzaxis);
            param.dataSize = single(size(param.datapx));

            param.Wavelength = single(D.Wavelength);
            param.bpos = single(D.Beampos);
            param.SDD = single(D.SDD);
            param.pixel = single(D.pixel);
            param.SchemaVersion = loadReport.SchemaVersion;
        catch err
            errordlg(['데이터를 불러오는 중 오류가 발생했습니다: ', err.message], 'Load Error');
            return;
        end

        h = 4.1357e-15; % Plank's constant
        c = 2.99792458e8; % Speed of light in vacuum
        param.Energy = h*c/param.Wavelength*1e7; %[keV]
        param.Energy = round(param.Energy,4);

        [param.cmin, param.cmax] = computePGIXSDisplayLimits(param.datapx);

        TX.cMax.String = num2str(param.cmax);
        TX.cMin.String = num2str(param.cmin);

        param.HD = 1:param.dataSize(2); % horizontal direction
        param.HD = param.HD - param.bpos(1);
        param.HD = single(param.HD);
        param.VD = 1:param.dataSize(1); % vertical direction
        param.VD = param.VD - param.bpos(2);
        param.VD = single(-param.VD);

        [xMin, xMax] = computePGIXSRangeLimits(param.HD);
        [yMin, yMax] = computePGIXSRangeLimits(param.VD);
        TX.cXlim1.String = num2str(xMin);
        TX.cXlim2.String = num2str(xMax);
        TX.cYlim1.String = num2str(yMin);
        TX.cYlim2.String = num2str(yMax);

        param.Mapping = MapList{get(hMapping,'Value')};

        updateImage_tab;

        param.Expinfo = 1; % performance is done for reading information
        param.hklcal = 0; % Crystal fitting performance
    end

%=========================================================================
% XY Range calculation
    function Rangecal_Callback(~,~)
        param.Mapping = MapList{get(hMapping,'Value')};

        switch param.Mapping
            case 'Pixel'
                [xMin, xMax] = computePGIXSRangeLimits(param.HD);
                [yMin, yMax] = computePGIXSRangeLimits(param.VD);
                TX.cXlim1.String = num2str(xMin);
                TX.cXlim2.String = num2str(xMax);
                TX.cYlim1.String = num2str(yMin);
                TX.cYlim2.String = num2str(yMax);

                updateImage_tab;

            case 'Qy/Qz'
                if isfield(param,'qy')
                    [xMin, xMax] = computePGIXSRangeLimits(param.qy);
                    [yMin, yMax] = computePGIXSRangeLimits(param.qz);
                    TX.cXlim1.String = num2str(xMin);
                    TX.cXlim2.String = num2str(xMax);
                    TX.cYlim1.String = num2str(yMin);
                    TX.cYlim2.String = num2str(yMax);

                    updateImage_tab;
                else
                    warndlg('Error. Qy/Qz format is not exist.','Warning');
                    return
                end
        end

    end

% ========================================================================
% plot 2d image for tab1
    function updateImage_tab

        param.colorscale = scaleList{get(hScale,'Value')};
        param.colorm = ColormapList{get(hColor,'Value')};

        displayData = param.datapx;
        if isfield(param, 'dataq') && ~isempty(param.dataq)
            displayData = param.dataq;
        end
        [param.cmin, param.cmax] = sanitizePGIXSDisplayLimitPair(get(TX.cMin,'String'), get(TX.cMax,'String'), displayData);
        set(TX.cMin, 'String', num2str(param.cmin));
        set(TX.cMax, 'String', num2str(param.cmax));

        cla(hAXtab);
        axes(hAXtab);

        xFallback = param.HD;
        yFallback = param.VD;
        if strcmp(param.Mapping, 'Qy/Qz') && isfield(param, 'qy') && isfield(param, 'qz')
            xFallback = param.qy;
            yFallback = param.qz;
        end
        [param.xlimmin, param.xlimmax] = sanitizePGIXSRangeLimitPair(get(TX.cXlim1,'String'), get(TX.cXlim2,'String'), xFallback);
        [param.ylimmin, param.ylimmax] = sanitizePGIXSRangeLimitPair(get(TX.cYlim1,'String'), get(TX.cYlim2,'String'), yFallback);
        set(TX.cXlim1, 'String', num2str(param.xlimmin));
        set(TX.cXlim2, 'String', num2str(param.xlimmax));
        set(TX.cYlim1, 'String', num2str(param.ylimmin));
        set(TX.cYlim2, 'String', num2str(param.ylimmax));

        param.fontsize = parsePGIXSNumeric(get(TX.FontSz,'String'), 9, 1, 200);

        switch param.Mapping
            case 'Pixel'
                imagesc(param.HD,param.VD,param.datapx);
                 set(gca, 'YDir', 'normal');
                 xlabel('Y, pixel');
                 ylabel('Z, pixel');

            case 'Qy/Qz'
                imagesc(param.qy,param.qz,param.dataq);
                set(gca, 'YDir', 'normal');
                xlabel('q_y, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
                ylabel('q_z, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
        end

        axis image;
        set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
        set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
        clim([param.cmin,param.cmax]);
        set(gca,'colorscale',param.colorscale);

        [cmap, cmapReport] = resolvePGIXSColormap(param.colorm, param.dataq, 256);
        colormap(hAXtab, cmap);
        if cmapReport.FallbackUsed
            warning('PGIXS:ColormapFallback', ...
                'Failed to apply selected colormap. Falling back to jet: %s', cmapReport.Message);
        end

        hcb=colorbar;
        hcb.LineWidth = 2;
        hcb.Label.String = 'Intensity, arb. units';
        hcb.Label.FontSize = 20;

        set(gca, 'FontSize', param.fontsize);
        set(gca, 'FontName', 'times');
        title(param.FileName,'Interpreter', 'none','FontSize',11);

        drawnow();
    end

% ========================================================================
% Update image
    function Updateimage_Callback(~,~)
        param.Mapping = MapList{get(hMapping,'Value')};
        HKLCheckOn = get(hHKLCheck,'Value');

        if HKLCheckOn == 0
            updateImage_tab;
        else
            Xtalplot_Callback;
        end
    end

% =======================================================================
% Space Group Callback
    function SpaceGroup_Callback(~,~)
        CS = XTal.CrystalSystem{get(XTal.hCrystsys,'Value')};

        switch CS
            case 'Layer'
                XTal.SpaceGroup = {'primitive'};
                XTal.Choice = {'1'};
            case 'Hexagonal'
                XTal.SpaceGroup = {'P6/mmm'};
                XTal.Choice = {'1'};
            case 'HCP'
                XTal.SpaceGroup = {'P63/mmc','P63/mcc','P63/mcm'};
                XTal.Choice = {'1'};
            case 'Cubic'
                XTal.SpaceGroup = {'P23','F23','I23','P213','Pm-3','Pn-3',...
                                   'Fm-3','Fd-3','Im-3','Pa-3','Ia-3','P432',...
                                   'F432','F4132','I432','P4332','P4132','I4132',...
                                   'P-43m','F-43m','I-43m','P-43n','F-43c',...
                                   'I-43d','Pm-3m','Pn-3n','Pm-3n','Pn-3m','Fm-3m',...
                                   'Fm-3c','Fd-3m','Fd-3c','Im-3m','Ia-3d'};
                XTal.Choice = {'1'};
            case 'Orthorhombic'
                XTal.SpaceGroup = {'P222','P2221','P21212','P212121','C2221',...
                                   'C222','F222','I222','I212121','Pmm2','Pmc21','Pcc2','Pma2',...
                                   'Pca21','Pnc2','Pmn21','Pba2','Pna21','Pnn2','Cmm2','Cmc21',...
                                   'Ccc2','Amm2','Aem2','Ama2','Aea2','Fmm2','Fdd2',...
                                   'Imm2','Iba2','Ima2','Pmmm','Pnnn','Pccm','Pban','Pmma','Pnna',...
                                   'Pmna','Pcca','Pbam','Pccn','Pbcm','Pnnm','Pmmn','Pbcn','Pbca',...
                                   'Pnma','Cmcm','Cmce','Cmmm','Cccm','Cmme','Ccce','Fmmm','Fddd',...
                                   'Immm','Ibam','Ibca','Imma'};
                XTal.Choice = {'1'};
            case 'Tetragonal'
                XTal.SpaceGroup = {'P4','P41','P42','P43','I4','I41','P-4',...
                                   'I-4','P4/m','P42/m','P4/n','P42/n','I4/m',...
                                   'I41/a','P422','P4212','P4122','P41212','P4222',...
                                   'P42212','P4322','P43212','I422','I4122',...
                                   'P4mm','P4bm','P42cm','P42nm','P4cc','P4nc',...
                                   'P42mc','P42bc','I4mm','I4cm','I41md','I41cd',...
                                   'P-42m','P-42c','P-421m','P-421c','P-4m2','P-4c2',...
                                   'P-4b2','P-4n2','I-4m2','I-4c2','I-42m','I-42d',...
                                   'P4/mmm','P4/mcc','P4/nbm','P4/nnc','P4/mbm',...
                                   'P4/mnc','P4/nmm','P4/ncc','P42/mmc','P42/mcm',...
                                   'P42/nbc','P42/nnm','P42/mbc','P42/mnm',...
                                   'P42/nmc','P42/ncm','I4/mmm','I4/mcm','I41/amd','I41/acd'};
                XTal.Choice = {'1'};
            case 'Monoclinic'
                XTal.SpaceGroup = {'P2','P21','C2','Pm','Pc','Cm','Cc','P2/m',...
                                    'P21/m','C2/m','P2/c','P21/c','C2/c'};
                XTal.Choice = {'1','2','3'};
            case 'Rhombohedral'
                XTal.SpaceGroup = {'P3','P31','P32','R3','P-3','R-3','P321',...
                                   'P3112','P3121','P3221','R32','P3m1','P31m',...
                                   'P3c1','P31c','R3m','R3c','P-3m1','P-3c1',...
                                   'R-3m','R-3c','P6','P61','P65','P62','P64','P63',...
                                   'P-6','P63/m','P622','P6122','P6522','P6222','P6422','P6322',...
                                   'P6mm','P63cc','P63cm','P63mc','P-6m2','P-6c2','P-62m','P-62c',...
                                   };
                XTal.Choice = {'1'};
            case 'Triclinic'
                XTal.SpaceGroup = {'P1','P-1'};
                XTal.Choice = {'1'};
        end

        XTal.hSpaceGrp = uicontrol('Parent',leftPanelData,'Style','popupmenu','Units','normalized',...
            'Position',[0.35 0.82 0.30 0.05],'String',XTal.SpaceGroup,...
            'Callback',@Structure_Callback);
        XTal.hChoice = uicontrol('Parent',leftPanelData,'Style','popupmenu','Units','normalized',...
            'Position',[0.65 0.82 0.30 0.05],'String',XTal.Choice);
    end

% ========================================================================
% Structure_Callback
    function Structure_Callback(~,~)
        param.Xtal = XTal.CrystalSystem{get(XTal.hCrystsys,'Value')};
        param.Spg = XTal.SpaceGroup{get(XTal.hSpaceGrp,'Value')};
        angle = parsePGIXSRotationVector({get(hXrot,'String'), get(hYrot,'String'), get(hZrot,'String')});

        switch param.Xtal
            case 'Layer'
                a = inf; b = inf; c = 1;
                alpha = 90; beta = 90; gamma = 90;
            case 'Hexagonal'
                a = 1; b = 1; c = inf;
                alpha = 90; beta = 90; gamma = 120;
            case 'HCP'
                a = 1; b = 1; c = 1.633;
                alpha = 90; beta = 90; gamma = 120;
            case 'Cubic'
                a = 1; b = 1; c = 1;
                alpha = 90; beta = 90; gamma = 90;
            case 'Orthorhombic'
                a = 1; b = 2; c = 3;
                alpha = 90; beta = 90; gamma = 90;
            case 'Tetragonal'
                a = 1; b = 1; c = 2;
                alpha = 90; beta = 90; gamma = 90;
            case 'Monoclinic'
                a = 1; b = 2; c = 3;
                alpha = 90; beta = 70; gamma = 90;
            case 'Rhombohedral'
                a = 1; b = 1; c = 1;
                alpha = 60; beta = 60; gamma = 60;    
            case 'Triclinic'
                a = 1; b = 2; c = 3;
                alpha = 70; beta = 80; gamma = 100;      
        end
        TX.haunit.String = num2str(a);
        TX.hbunit.String = num2str(b);
        TX.hcunit.String = num2str(c);
        TX.halpha.String = num2str(alpha);
        TX.hbeta.String = num2str(beta);
        TX.hgamma.String = num2str(gamma);
        cla(hImunit);
        axes(hImunit);

        UnitCellGen_tx(a,b,c,alpha,beta,gamma,param.Xtal,param.Spg,angle);
    end

% ========================================================================
% Crytal calculation and plot
    function Xtalplot_Callback(~,~)
        param.Mapping = MapList{get(hMapping,'Value')};

        param.Xtal = XTal.CrystalSystem{get(XTal.hCrystsys,'Value')};
        param.Spg = XTal.SpaceGroup{get(XTal.hSpaceGrp,'Value')};
        param.CH = XTal.Choice{get(XTal.hChoice,'Value')};

        xFallback = param.HD;
        yFallback = param.VD;
        if strcmp(param.Mapping, 'Qy/Qz') && isfield(param, 'qy') && isfield(param, 'qz')
            xFallback = param.qy;
            yFallback = param.qz;
        end
        [param.xlimmin, param.xlimmax] = sanitizePGIXSRangeLimitPair(get(TX.cXlim1,'String'), get(TX.cXlim2,'String'), xFallback);
        [param.ylimmin, param.ylimmax] = sanitizePGIXSRangeLimitPair(get(TX.cYlim1,'String'), get(TX.cYlim2,'String'), yFallback);
        set(TX.cXlim1, 'String', num2str(param.xlimmin));
        set(TX.cXlim2, 'String', num2str(param.xlimmax));
        set(TX.cYlim1, 'String', num2str(param.ylimmin));
        set(TX.cYlim2, 'String', num2str(param.ylimmax));

        param.fontsize = parsePGIXSNumeric(get(TX.FontSz,'String'), 9, 1, 200);

        k0 = 2*pi/param.Wavelength;

        [a, b, c, alpha, beta, gamma] = parsePGIXSLatticeParameters( ...
            {get(TX.haunit,'String'), get(TX.hbunit,'String'), get(TX.hcunit,'String')}, ...
            {get(TX.halpha,'String'), get(TX.hbeta,'String'), get(TX.hgamma,'String')}, ...
            [10 10 10], [90 90 90]);

        hmax = parsePGIXSIndexLimit(get(hHidx,'String'));
        hmin = -hmax;
        kmax = parsePGIXSIndexLimit(get(hKidx,'String'));
        kmin = -kmax;
        lmax = parsePGIXSIndexLimit(get(hLidx,'String'));
        lmin = -lmax;

        Rotation = parsePGIXSRotationVector({get(hXrot,'String'), get(hYrot,'String'), get(hZrot,'String')});

        Specialplus = get(hSpecial,'Value');
        % RandOri = get(hRandOri,'Value');
        HoldingIm = get(hHoldingS,'Value');
        EwaldEffect = get(hEwaldS,'Value');

        cla(hImunit);
        axes(hImunit);

        UnitCellGen_tx(a,b,c,alpha,beta,gamma,param.Xtal,param.Spg,Rotation);

        switch param.Xtal
            case 'Layer'
                a = 1e10;
                b = 1e10;

            case 'Hexagonal'
                c = 1e10;
        end

        if HoldingIm == 0 % without holding

            param.unitold = [a,b,c,alpha,beta,gamma,Rotation];
            param.Xtalold = param.Xtal;
            param.Spgold = param.Spg;
            param.CHold = param.CH;
           
            [params.qxhkl,params.qyhkl,params.qzhkl,params.qhkl,params.hkl] = qvalhkl_tr(param,a,b,c,alpha,beta,gamma,hmax,kmax,lmax,hmin,kmin,lmin,Rotation,param.Xtal,param.Spg,param.CH,k0,Specialplus,EwaldEffect);

        else % with holding

            if isfield(param,'unitold')
                ao = param.unitold(1);
                bo = param.unitold(2);
                co = param.unitold(3);
                alphao = param.unitold(4);
                betao = param.unitold(5);
                gammao = param.unitold(6);
                Rotationo = [param.unitold(7),param.unitold(8),param.unitold(9)];

                [params.qxhklo,params.qyhklo,params.qzhklo,params.qhklo,params.hklo] = qvalhkl_tr(param,ao,bo,co,alphao,betao,gammao,hmax,kmax,lmax,hmin,kmin,lmin,Rotationo,param.Xtalold,param.Spgold,param.CHold,k0,Specialplus,EwaldEffect);
                [params.qxhkl,params.qyhkl,params.qzhkl,params.qhkl,params.hkl] = qvalhkl_tr(param,a,b,c,alpha,beta,gamma,hmax,kmax,lmax,hmin,kmin,lmin,Rotation,param.Xtal,param.Spg,param.CH,k0,Specialplus,EwaldEffect);

            else
                warndlg('please uncheck the Holding botton!!','Warning');
                return
            end
        end % end of holding

        if isempty(params.qzhkl)
            warndlg('Out of bounds!!','Warning');
            return
        end

        Imageplot2DHKL;

    end

% ========================================================================
    function Imageplot2DHKL

        HoldingIm = get(hHoldingS,'Value'); % Holding function
        
        STColorN = colorcode{get(hSTColorN,'Value')}; % Color
        STShapeN = shapecode{get(hSTShapeN,'Value')}; % Shape
        STSizeN = parsePGIXSNumeric(get(hSTSizeN,'String'), 8, 1, 200); % Size
        SEmptyN = get(hSEmptyN,'Value'); % Empty

        [TClN,TShN,TMCN] = resolvePGIXSMarkerStyle(STColorN,STShapeN,SEmptyN, {'k', 'o', 'none'}); % makes color & shape code
        
        if HoldingIm == 1
            STColorO = colorcode{get(hSTColorO,'Value')}; % Color
            STShapeO = shapecode{get(hSTShapeO,'Value')}; % Shape
            STSizeO = parsePGIXSNumeric(get(hSTSizeO,'String'), 8, 1, 200); % Size 
            SEmptyO = get(hSEmptyO,'Value');

            [TClO,TShO,TMCO] = resolvePGIXSMarkerStyle(STColorO,STShapeO,SEmptyO, {'b', '*', 'none'}); % makes color & shape code
        end

        % plot image with position
        param.colorscale = scaleList{get(hScale,'Value')};
        param.colorm = ColormapList{get(hColor,'Value')};
        displayData = param.datapx;
        if isfield(param, 'dataq') && ~isempty(param.dataq)
            displayData = param.dataq;
        end
        [param.cmin, param.cmax] = sanitizePGIXSDisplayLimitPair(get(TX.cMin,'String'), get(TX.cMax,'String'), displayData);
        set(TX.cMin, 'String', num2str(param.cmin));
        set(TX.cMax, 'String', num2str(param.cmax));

        param.PLNpos = PLNpos{get(hPLNpos,'Value')};
       
        xFallback = param.HD;
        yFallback = param.VD;
        if strcmp(param.Mapping, 'Qy/Qz') && isfield(param, 'qy') && isfield(param, 'qz')
            xFallback = param.qy;
            yFallback = param.qz;
        end
        [param.xlimmin, param.xlimmax] = sanitizePGIXSRangeLimitPair(get(TX.cXlim1,'String'), get(TX.cXlim2,'String'), xFallback);
        [param.ylimmin, param.ylimmax] = sanitizePGIXSRangeLimitPair(get(TX.cYlim1,'String'), get(TX.cYlim2,'String'), yFallback);
        set(TX.cXlim1, 'String', num2str(param.xlimmin));
        set(TX.cXlim2, 'String', num2str(param.xlimmax));
        set(TX.cYlim1, 'String', num2str(param.ylimmin));
        set(TX.cYlim2, 'String', num2str(param.ylimmax));

        param.fontsize = parsePGIXSNumeric(get(TX.FontSz,'String'), 9, 1, 200);

        HKLCheckOn = get(hHKLCheck,'Value');
        HKLPlaneOn = get(hHKLplane,'Value');
        RandOri = get(hRandOri,'Value');  % Random orientation

        cla(hAXtab);
        axes(hAXtab);

        switch param.Mapping
            case 'Pixel'
                imagesc(param.HD,param.VD,param.datapx); 
                hold on

                if HKLCheckOn == 1
                    if RandOri == 0 % Random orientation Off
                        qhor = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);
                        qver = sign(param.qz) .* param.Q(:,fix(param.bpos(1)))';

                        qxyhkl = sqrt(params.qxhkl.^2 + params.qyhkl.^2);
                        qxzhkl = sqrt(params.qxhkl.^2 + params.qzhkl.^2);

                        xp = zeros(length(qxyhkl),1);
                        yp = zeros(length(qxzhkl),1);
                        for n = 1:length(qxyhkl)
                            [~,idx_x] = min(abs(qxyhkl(n)-qhor));
                            xp(n) = idx_x;
                            [~,idx_y] = min(abs(qxzhkl(n)-qver));
                            yp(n) = idx_y;

                            plot(xp(n),yp(n),TShN,'MarkerSize',STSizeN,'MarkerFaceColor',TMCN,'MarkerEdgeColor',TClN); hold on

                            if HKLPlaneOn == 1
                                hkltext = num2str(params.hkl(n,:));
                                t = text(xp(n),yp(n),hkltext);
                                t.Color = TClN;
                                t.FontSize = 9;
                                switch param.PLNpos
                                    case 'left'
                                        t.HorizontalAlignment = 'right';
                                        t.VerticalAlignment = 'baseline';
                                    case 'center'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'baseline';
                                    case 'right'
                                        t.HorizontalAlignment = 'left';
                                        t.VerticalAlignment = 'baseline';
                                    case 'top'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'bottom';
                                    case 'bottom'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'cap';
                                end % end of switch Plane position

                            end % end of HKL plane
                        end % end of n loop

                    elseif RandOri == 1 % Random orientation On
                        q = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);

                        theta = linspace(0, pi, 100);
                        xp = zeros(length(params.qhkl),100);
                        yp = zeros(length(params.qhkl),100);
                        for n = 1:length(params.qhkl)
                            [~,rp] = min(abs(params.qhkl(n)-q));
                            xp(n,:) = rp * cos(theta);
                            yp(n,:) = rp * sin(theta);

                            plot(xp(n,:), yp(n,:), 'Color',TMCN,'LineWidth', 2); % 
                            hold on
            
                            if HKLPlaneOn == 1
                                hkltext = num2str(params.hkl(n,:));
                                t = text(xp(n),yp(n),hkltext);

                                t.Color = TClN;
                                t.FontSize = 9;
                                switch param.PLNpos
                                    case 'left'
                                        t.HorizontalAlignment = 'right';
                                        t.VerticalAlignment = 'baseline';
                                    case 'center'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'baseline';
                                    case 'right'
                                        t.HorizontalAlignment = 'left';
                                        t.VerticalAlignment = 'baseline';
                                    case 'top'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'bottom';
                                    case 'bottom'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'cap';
                                end % end of switch Plane position
                            end % end of HKL plane
                        end % end of n for loop    

                    end % end of Random Orientation

                    if HoldingIm == 1
                        if RandOri == 0 % Random orientation Off
                            qhor = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);
                            qver = sign(param.qz) .* param.Q(:,fix(param.bpos(1)))';

                            qxyhklo = sqrt(params.qxhklo.^2 + params.qyhklo.^2);
                            qxzhklo = sqrt(params.qxhklo.^2 + params.qzhklo.^2);

                            xpo = zeros(length(qxyhklo),1);
                            ypo = zeros(length(qxzhklo),1);
                            for m = 1:length(qxyhklo)
                                [~,idx_x] = min(abs(qxyhklo(m)-qhor));
                                xpo(m) = idx_x;
                                [~,idx_y] = min(abs(qxzhklo(m)-qver));
                                ypo(m) = idx_y;

                                plot(xpo(m),ypo(m),TShO,'MarkerSize',STSizeO,'MarkerFaceColor',TMCO,'MarkerEdgeColor',TClO); hold on

                                if HKLPlaneOn == 1
                                    hkltext = num2str(params.hklo(m,:));
                                    t = text(xpo(m),ypo(m),hkltext);
                                    t.Color = TClO;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of m loop

                        elseif RandOri == 1 % Random orientation On
                            q = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);

                            theta = linspace(0, pi, 100);
                            xpo = zeros(length(params.qhklo),100);
                            ypo = zeros(length(params.qhklo),100);
                            for m = 1:length(params.qhklo)
                                [~,rp] = min(abs(params.qhklo(m)-q));
                                xpo(m,:) = rp * cos(theta);
                                ypo(m,:) = rp * sin(theta);

                                plot(xpo(m,:), ypo(m,:), 'Color',TMCO,'LineWidth', 2); %
                                hold on

                                if HKLPlaneOn == 1
                                    hkltext = num2str(params.hklo(m,:));
                                    t = text(xpo(m),ypo(m),hkltext);

                                    t.Color = TClO;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of m for loop

                        end % end of Random Orientation

                    end % end of Holding image

                end % end of HKL plot
                set(gca, 'YDir', 'normal');

                xlabel('Y, pixel');
                ylabel('Z, pixel');

            case 'Qy/Qz'
                imagesc(param.qy,param.qz,param.dataq); 
                hold on
                
                if HKLCheckOn == 1
                    if RandOri == 0
                        for n = 1:length(params.qzhkl)
                            if params.qyhkl(n) > param.xlimmax || params.qzhkl(n) > param.ylimmax
                                continue
                            else
                                plot(params.qyhkl(n),params.qzhkl(n),TShN,'MarkerSize',STSizeN,'MarkerFaceColor',TMCN,'MarkerEdgeColor',TClN); hold on
                                if HKLPlaneOn == 1
                                    hkltext = num2str(params.hkl(n,:));
                                    t = text(params.qyhkl(n),params.qzhkl(n),hkltext);
                                    t.Color = TClN;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of range
                        end % end of for n loop

                    elseif RandOri == 1
                        % Sorting out duplicated position
                        [qhkl, hkl] = collapsePGIXSDuplicateRings(params.qhkl, params.hkl);

                        theta = linspace(0, 2*pi, 100);
                        xp = zeros(length(qhkl),100);
                        yp = zeros(length(qhkl),100);
                        for n = 1:length(qhkl)
                            xp(n,:) = qhkl(n) * cos(theta);
                            yp(n,:) = qhkl(n) * sin(theta);

                            plot(xp(n,:), yp(n,:), 'Color',TMCN,'LineWidth', 2);
                            hold on

                            if HKLPlaneOn == 1
                                hkltext = num2str(hkl(n,:));
                                t = text(xp(n),yp(n),hkltext);
                                t.Color = TClN;
                                t.FontSize = 9;
                                switch param.PLNpos
                                    case 'left'
                                        t.HorizontalAlignment = 'right';
                                        t.VerticalAlignment = 'baseline';
                                    case 'center'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'baseline';
                                    case 'right'
                                        t.HorizontalAlignment = 'left';
                                        t.VerticalAlignment = 'baseline';
                                    case 'top'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'bottom';
                                    case 'bottom'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'cap';
                                end % end of switch Plane position
                            end % end of HKL plane
                        end % end of n for loop

                    end % end of Random Orientation

                    if HoldingIm == 1
                        if RandOri == 0
                            for m = 1:length(params.qzhklo)
                                if params.qyhklo(m) > param.xlimmax || params.qzhklo(m) > param.ylimmax
                                    continue
                                else
                                    plot(params.qyhklo(m),params.qzhklo(m),TShO,'MarkerSize',STSizeO,'MarkerFaceColor',TMCO,'MarkerEdgeColor',TClO); hold on
                                    if HKLPlaneOn == 1
                                        hkltext = num2str(params.hklo(m,:));
                                        t = text(params.qyhklo(m),params.qzhklo(m),hkltext);
                                        t.Color = TClO;
                                        t.FontSize = 9;
                                        switch param.PLNpos
                                            case 'left'
                                                t.HorizontalAlignment = 'right';
                                                t.VerticalAlignment = 'baseline';
                                            case 'center'
                                                t.HorizontalAlignment = 'center';
                                                t.VerticalAlignment = 'baseline';
                                            case 'right'
                                                t.HorizontalAlignment = 'left';
                                                t.VerticalAlignment = 'baseline';
                                            case 'top'
                                                t.HorizontalAlignment = 'center';
                                                t.VerticalAlignment = 'bottom';
                                            case 'bottom'
                                                t.HorizontalAlignment = 'center';
                                                t.VerticalAlignment = 'cap';
                                        end
                                    end
                                end
                            end
                            clear m

                        elseif RandOri == 1
                            % Sorting out duplicated position
                            [qhklo, hklo] = collapsePGIXSDuplicateRings(params.qhklo, params.hklo);

                            theta = linspace(0, 2*pi, 100);
                            xpo = zeros(length(qhklo),100);
                            ypo = zeros(length(qhklo),100);
                            for m = 1:length(qhklo)
                                xpo(m,:) = qhklo(m) * cos(theta);
                                ypo(m,:) = qhklo(m) * sin(theta);

                                plot(xpo(m,:), ypo(m,:), 'Color',TMCN,'LineWidth', 2);
                                hold on

                                if HKLPlaneOn == 1
                                    hkltext = num2str(hklo(m,:));
                                    t = text(xpo(m),ypo(m),hkltext);
                                    t.Color = TClO;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of m for loop

                        end % end of Random Orientation

                    end % end of Holding image

                end % end of HKL plot

                set(gca, 'YDir', 'normal');

                xlabel('q_y, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
                ylabel('q_z, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
        end % end of Mapping

        axis image;
        set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
        set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
        clim([param.cmin,param.cmax]);
        set(gca,'colorscale',param.colorscale);

        [cmap, cmapReport] = resolvePGIXSColormap(param.colorm, param.dataq, 256);
        colormap(hAXtab, cmap);
        if cmapReport.FallbackUsed
            warning('PGIXS:ColormapFallback', ...
                'Failed to apply selected colormap. Falling back to jet: %s', cmapReport.Message);
        end

        hcb=colorbar;
        hcb.LineWidth = 2;
        hcb.Label.String = 'Intensity, arb. units';
        hcb.Label.FontSize = 20;
        
        set(gca, 'FontSize', param.fontsize);
        set(gca, 'FontName', 'times');

        title(param.FileName,'Interpreter', 'none','FontSize',11);

        drawnow();

    end

% ========================================================================
% Table Callback
    function HKLTable_Callback(~,~)
        TableCheck_gui;
    end

% ========================================================================
% Table gui
    function TableCheck_gui
        HKLCheckOn = get(hHKLCheck,'Value'); % HKL plot check
        RandOri = get(hRandOri,'Value');  % Random orientation
        HoldingIm = get(hHoldingS,'Value'); % Holding function

        if HKLCheckOn == 0 % HKL Check off
            warndlg('Please check HKL first!!','Warning');
            return
        elseif HKLCheckOn == 1 % HKL Check on
            if RandOri == 0 % random orientation off
                TrowName = num2cell(num2str(params.hkl),2);
                tf = true(size(params.qyhkl));
                T = table(params.qxhkl,params.qyhkl,params.qzhkl,tf);

                % Build a GUI
                f = uifigure('Name', 'HKLtable');
                uit = uitable('Parent', f, 'Data', table2cell(T), ...
                    'Units', 'Normalized', 'Position', [0.1, 0.15, 0.8, 0.8], ...
                    'RowName', TrowName, 'ColumnName', {'Qx', 'Qy', 'Qz', 'Export'}, ...
                    'ColumnEditable', [false false false true]);

                uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Export & Plot', ...
                    'Units', 'Normalized', 'Position', [0.1, 0.05, 0.4 0.1], ...
                    'Callback', @(h,e)table2workspace1(uit,f));

                uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Save', ...
                            'Units', 'Normalized', 'Position', [0.5, 0.05, 0.4 0.1], ...
                            'Callback', @(h,e)table2save1(uit)); 

                if HoldingIm == 1
                    TrowName1 = num2cell(num2str(params.hkl),2);
                    TrowName2 = num2cell(num2str(params.hklo),2);
                    tf1 = true(size(params.qyhkl));
                    tf2 = true(size(params.qyhklo));
                    T1 = table(params.qxhkl,params.qyhkl,params.qzhkl,tf1);
                    T2 = table(params.qxhklo,params.qyhklo,params.qzhklo,tf2);

                    % Build a GUI
                    f = uifigure('Name', 'HKLtable');
                    uit1 = uitable('Parent', f, 'Data', table2cell(T1), ...
                        'Units', 'Normalized', 'Position', [0.1, 0.55, 0.8, 0.35], ...
                        'RowName', TrowName1, 'ColumnName', {'Qx', 'Qy', 'Qz', 'Export'}, ...
                        'ColumnEditable', [false false false true]);

                    uit2 = uitable('Parent', f, 'Data', table2cell(T2), ...
                        'Units', 'Normalized', 'Position', [0.1, 0.15, 0.8, 0.35], ...
                        'RowName', TrowName2, 'ColumnName', {'Qx_O', 'Qy_O', 'Qz_O', 'Export'}, ...
                        'ColumnEditable', [false false false true]);

                    uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Export & Plot', ...
                        'Units', 'Normalized', 'Position', [0.1, 0.05, 0.4 0.1], ...
                        'Callback', @(h,e)table2workspace2(uit1,uit2,f));

                    uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Save', ...
                            'Units', 'Normalized', 'Position', [0.5, 0.05, 0.4 0.1], ...
                            'Callback', @(h,e)table2save2(uit1,uit2)); 
                end

            elseif RandOri == 1 % random orientation on
                TrowName = num2cell(num2str(params.hkl),2);
                tf = true(size(params.qhkl));
                T = table(params.qhkl,tf);

                % Build a GUI
                f = uifigure('Name', 'HKLtable');
                uit = uitable('Parent', f, 'Data', table2cell(T), ...
                    'Units', 'Normalized', 'Position', [0.1, 0.15, 0.8, 0.8], ...
                    'RowName', TrowName, 'ColumnName', {'Q', 'Export'}, ...
                    'ColumnEditable', [false true]);

                uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Export & Plot', ...
                    'Units', 'Normalized', 'Position', [0.1, 0.05, 0.4 0.1], ...
                    'Callback', @(h,e)table2workspace1(uit,f));
        
                uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Save', ...
                            'Units', 'Normalized', 'Position', [0.5, 0.05, 0.4 0.1], ...
                            'Callback', @(h,e)table2save1(uit));

                if HoldingIm == 1
                    TrowName1 = num2cell(num2str(params.hkl),2);
                    TrowName2 = num2cell(num2str(params.hklo),2);
                    tf1 = true(size(params.qhkl));
                    tf2 = true(size(params.qhklo));
                    T1 = table(params.qhkl,tf1);
                    T2 = table(params.qhklo,tf2);

                    % Build a GUI
                    f = uifigure('Name', 'HKLtable');
                    uit1 = uitable('Parent', f, 'Data', table2cell(T1), ...
                        'Units', 'Normalized', 'Position', [0.1, 0.55, 0.8, 0.35], ...
                        'RowName', TrowName1, 'ColumnName', {'Q', 'Export'}, ...
                        'ColumnEditable', [false true]);

                    uit2 = uitable('Parent', f, 'Data', table2cell(T2), ...
                        'Units', 'Normalized', 'Position', [0.1, 0.15, 0.8, 0.35], ...
                        'RowName', TrowName2, 'ColumnName', {'Q_O', 'Export'}, ...
                        'ColumnEditable', [false true]);

                    uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Export & Plot', ...
                        'Units', 'Normalized', 'Position', [0.1, 0.05, 0.4 0.1], ...
                        'Callback', @(h,e)table2workspace2(uit1,uit2,f));

                    uicontrol('Parent', f, 'Style', 'pushbutton', 'String', 'Save', ...
                            'Units', 'Normalized', 'Position', [0.5, 0.05, 0.4 0.1], ...
                            'Callback', @(h,e)table2save2(uit1,uit2)); 

                end % end of holding
            end % end of random orientation
        end % end of HKL check

    end % end of function
    
    function table2workspace1(uit,f) % holding off case
        HKLCheckOn = get(hHKLCheck,'Value'); % HKL check
        RandOri = get(hRandOri,'Value');  % Random orientation

        if HKLCheckOn == 0 % HKL check off
                warndlg('Please check HKL first!!','Warning');
                return
        else % HKL check on
                if RandOri == 0 % Random orientation off
                    tmp = uit.Data(:, 4);  % Get the state of our checkboxes
                    exportbool = [tmp{:}];  % Denest the logicals from the cell array

                    varargin{1} = uit.RowName(exportbool); % hkl
                    varargin{2} = cell2mat(uit.Data(exportbool, 1)); % qxhkl
                    varargin{3} = cell2mat(uit.Data(exportbool, 2)); % qyhkl
                    varargin{4} = cell2mat(uit.Data(exportbool, 3)); % qzhkl
                    
                    Imageplot2DHKLnew(varargin);
                
                elseif RandOri == 1 % Random orientation on
                    tmp = uit.Data(:, 2);  % Get the state of our checkboxes
                    exportbool = [tmp{:}];  % Denest the logicals from the cell array

                    varargin{1} = uit.RowName(exportbool); % hkl
                    varargin{2} = cell2mat(uit.Data(exportbool, 1)); % qhkl

                    Imageplot2DHKLnew(varargin);
                end
           
        end
        close(f);
    end % end of function

    function table2workspace2(uit1,uit2,f) % holding on
        HKLCheckOn = get(hHKLCheck,'Value'); % Transmission check
        RandOri = get(hRandOri,'Value');  % Random orientation

        if HKLCheckOn == 0 % HKL check off
                warndlg('Please check T or R first!!','Warning');
                return
            
        elseif HKLCheckOn == 1 % HKL check on
                if RandOri == 0 % Random orientation off
                    tmp1 = uit1.Data(:, 4);  % Get the state of our checkboxes
                    exportbool1 = [tmp1{:}];  % Denest the logicals from the cell array
                    tmp2 = uit2.Data(:, 4);  % Get the state of our checkboxes
                    exportbool2 = [tmp2{:}];  % Denest the logicals from the cell array
                   
                    varargin{1} = uit1.RowName(exportbool1); % hkl1
                    varargin{2} = cell2mat(uit1.Data(exportbool1, 1)); % qxhkl1
                    varargin{3} = cell2mat(uit1.Data(exportbool1, 2)); % qyhkl1
                    varargin{4} = cell2mat(uit1.Data(exportbool1, 3)); % qzhkl1

                    varargin{5} = uit.RowName(exportbool2); % hkl2
                    varargin{6} = cell2mat(uit2.Data(exportbool2, 1)); % qxhkl2
                    varargin{7} = cell2mat(uit2.Data(exportbool2, 2)); % qyhkl2
                    varargin{8} = cell2mat(uit2.Data(exportbool2, 3)); % qzhkl2
                    
                    Imageplot2DHKLnew(varargin);

                else % Random orientation on
                    tmp1 = uit1.Data(:, 2);  % Get the state of our checkboxes
                    exportbool1 = [tmp1{:}];  % Denest the logicals from the cell array
                    tmp2 = uit2.Data(:, 2);  % Get the state of our checkboxes
                    exportbool2 = [tmp2{:}];  % Denest the logicals from the cell array
                   
                    varargin{1} = uit1.RowName(exportbool1); % hkl1
                    varargin{2} = cell2mat(uit1.Data(exportbool1, 1)); % qhkl1

                    varargin{3} = uit2.RowName(exportbool2); % hkl2
                    varargin{4} = cell2mat(uit2.Data(exportbool2, 1)); % qhkl2

                    Imageplot2DHKLnew(varargin);

                end
        end
        close(f);
    end % end of function

    function table2save1(uit) % without holding
        HKLCheckOn = get(hHKLCheck,'Value'); % Transmission check
        RandOri = get(hRandOri,'Value');  % Random orientation

        if HKLCheckOn == 0 % HKL check off
                warndlg('Please check HKL first!!','Warning');
                return
        else % HKL check on
                if RandOri == 0 % Random orientation off
                    tmp = uit.Data(:, 4);  % Get the state of our checkboxes
                    exportbool = [tmp{:}];  % Denest the logicals from the cell array

                    varargin{1} = uit.RowName(exportbool); % hkl
                    varargin{2} = cell2mat(uit.Data(exportbool, 1)); % qxhkl
                    varargin{3} = cell2mat(uit.Data(exportbool, 2)); % qyhkl
                    varargin{4} = cell2mat(uit.Data(exportbool, 3)); % qzhkl

                    SaveHKLvalue1(varargin);

                elseif RandOri == 1 % Random orientation on
                    tmp = uit.Data(:, 2);  % Get the state of our checkboxes
                    exportbool = [tmp{:}];  % Denest the logicals from the cell array

                    varargin{1} = uit.RowName(exportbool); % hkl
                    varargin{2} = cell2mat(uit.Data(exportbool, 1)); % qhkl

                    SaveHKLvalue1(varargin);
                end
        end
     
    end % end of table save 1 function

    function table2save2(uit1, uit2) % with holding
        HKLCheckOn = get(hHKLCheck,'Value'); % Transmission check
        RandOri = get(hRandOri,'Value');  % Random orientation

        if HKLCheckOn == 0 % HKL check off
                warndlg('Please check HKL first!!','Warning');
                return
        else % HKL check on
                if RandOri == 0 % Random orientation off
                    tmp1 = uit1.Data(:, 4);  % Get the state of our checkboxes
                    exportbool1 = [tmp1{:}];  % Denest the logicals from the cell array
                    tmp2 = uit2.Data(:, 4);  % Get the state of our checkboxes
                    exportbool2 = [tmp2{:}];  % Denest the logicals from the cell array
                   
                    varargin{1} = uit1.RowName(exportbool1); % hkl1
                    varargin{2} = cell2mat(uit1.Data(exportbool1, 1)); % qxhkl1
                    varargin{3} = cell2mat(uit1.Data(exportbool1, 2)); % qyhkl1
                    varargin{4} = cell2mat(uit1.Data(exportbool1, 3)); % qzhkl1

                    varargin{5} = uit.RowName(exportbool2); % hkl2
                    varargin{6} = cell2mat(uit2.Data(exportbool2, 1)); % qxhkl2
                    varargin{7} = cell2mat(uit2.Data(exportbool2, 2)); % qyhkl2
                    varargin{8} = cell2mat(uit2.Data(exportbool2, 3)); % qzhkl2

                    SaveHKLvalue(varargin);

                elseif RandOri == 1 % Random orientation on
                    tmp1 = uit1.Data(:, 2);  % Get the state of our checkboxes
                    exportbool1 = [tmp1{:}];  % Denest the logicals from the cell array
                    tmp2 = uit2.Data(:, 2);  % Get the state of our checkboxes
                    exportbool2 = [tmp2{:}];  % Denest the logicals from the cell array
                   
                    varargin{1} = uit1.RowName(exportbool1); % hkl1
                    varargin{2} = cell2mat(uit1.Data(exportbool1, 1)); % qhkl1

                    varargin{3} = uit2.RowName(exportbool2); % hkl2
                    varargin{4} = cell2mat(uit2.Data(exportbool2, 1)); % qhkl2

                    SaveHKLvalue(varargin);
                end
        end
     
    end % end of table save 2 function

% save selection value
    function SaveHKLvalue(varargin)
        HoldingIm = get(hHoldingS,'Value');
        HKLCheckOn = get(hHKLCheck,'Value'); % Transmission check
        RandOri = get(hRandOri,'Value');  % Random orientation

        Parameter = varargin{1};

        if HKLCheckOn == 0 % HKL check off
                warndlg('Please check HKL first!!','Warning');
                return
        elseif HKLCheckOn == 1 % HKL check on
            T = buildPGIXSTrXSHKLExportTable(Parameter, HoldingIm, RandOri);
        end % end of HKL plain

        [filepath, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName);
        if ~ok
            warndlg(['Save directory error: ', saveReport.Message], 'Warning');
            return;
        end
        SaveFile = [param.FileName,'_HKLtable.xlsx'];
        SaveFilepath = fullfile(filepath,SaveFile);

        [writeOK, writeReport] = writePGIXSTableFile(T, SaveFilepath, 'Sheet', 1);
        if ~writeOK
            warndlg(['Table save failed: ', writeReport.Message], 'Warning');
            return;
        end

    end % end of function of save HKLvalue

% ========================================================================
% Table selection viewer
    function Imageplot2DHKLnew(varargin)
        HoldingIm = get(hHoldingS,'Value'); % Holding function
        HKLCheckOn = get(hHKLCheck,'Value');
        HKLPlaneOn = get(hHKLplane,'Value');
        
        RandOri = get(hRandOri,'Value');  % Random orientation

        Parameter = varargin{1};

        % Parameter selector
        if HKLCheckOn == 1 % HKL On
            if RandOri == 0 % random orientation off
                hkl = Parameter{1};
                qxhkl = Parameter{2};
                qyhkl = Parameter{3};
                qzhkl = Parameter{4};
                if HoldingIm == 1
                    hkl = Parameter{1};
                    qxhkl = Parameter{2};
                    qyhkl = Parameter{3};
                    qzhkl = Parameter{4};
                    hklo = Parameter{5};
                    qxhklo = Parameter{6};
                    qyhklo = Parameter{7};
                    qzhklo = Parameter{8};
                end % end of holding
            elseif RandOri == 1 % random orientation on
                hkl = Parameter{1};
                qhkl = Parameter{2};
                if HoldingIm == 1
                    hkl = Parameter{1};
                    qhkl = Parameter{2};
                    hklo = Parameter{3};
                    qhklo = Parameter{4};
                end % end of holding
            end % end of random orientation
        end % end of HKL plot

        STColorN = colorcode{get(hSTColorN,'Value')}; % Color
        STShapeN = shapecode{get(hSTShapeN,'Value')}; % Shape
        STSizeN = parsePGIXSNumeric(get(hSTSizeN,'String'), 8, 1, 200); % Size
        SEmptyN = get(hSEmptyN,'Value'); % Empty

        [TClN,TShN,TMCN] = resolvePGIXSMarkerStyle(STColorN,STShapeN,SEmptyN, {'k', 'o', 'none'}); % makes color & shape code
        
        if HoldingIm == 1
            STColorO = colorcode{get(hSTColorO,'Value')}; % Color
            STShapeO = shapecode{get(hSTShapeO,'Value')}; % Shape
            STSizeO = parsePGIXSNumeric(get(hSTSizeO,'String'), 8, 1, 200); % Size 
            SEmptyO = get(hSEmptyO,'Value');

            [TClO,TShO,TMCO] = resolvePGIXSMarkerStyle(STColorO,STShapeO,SEmptyO, {'b', '*', 'none'}); % makes color & shape code
        end

        % plot image with position
        param.colorscale = scaleList{get(hScale,'Value')};
        param.colorm = ColormapList{get(hColor,'Value')};
        displayData = param.datapx;
        if isfield(param, 'dataq') && ~isempty(param.dataq)
            displayData = param.dataq;
        end
        [param.cmin, param.cmax] = sanitizePGIXSDisplayLimitPair(get(TX.cMin,'String'), get(TX.cMax,'String'), displayData);
        set(TX.cMin, 'String', num2str(param.cmin));
        set(TX.cMax, 'String', num2str(param.cmax));

        param.PLNpos = PLNpos{get(hPLNpos,'Value')};
       
        xFallback = param.HD;
        yFallback = param.VD;
        if strcmp(param.Mapping, 'Qy/Qz') && isfield(param, 'qy') && isfield(param, 'qz')
            xFallback = param.qy;
            yFallback = param.qz;
        end
        [param.xlimmin, param.xlimmax] = sanitizePGIXSRangeLimitPair(get(TX.cXlim1,'String'), get(TX.cXlim2,'String'), xFallback);
        [param.ylimmin, param.ylimmax] = sanitizePGIXSRangeLimitPair(get(TX.cYlim1,'String'), get(TX.cYlim2,'String'), yFallback);
        set(TX.cXlim1, 'String', num2str(param.xlimmin));
        set(TX.cXlim2, 'String', num2str(param.xlimmax));
        set(TX.cYlim1, 'String', num2str(param.ylimmin));
        set(TX.cYlim2, 'String', num2str(param.ylimmax));

        param.fontsize = parsePGIXSNumeric(get(TX.FontSz,'String'), 9, 1, 200);

        cla(hAXtab);
        axes(hAXtab);

        switch param.Mapping
            case 'Pixel'
                imagesc(param.HD,param.VD,param.datapx); hold on

                if HKLCheckOn == 1
                    if RandOri == 0 % Random orientation Off
                        qhor = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);
                        qver = sign(param.qz) .* param.Q(:,fix(param.bpos(1)))';

                        qxyhkl = sqrt(qxhkl.^2 + qyhkl.^2);
                        qxzhkl = sqrt(qxhkl.^2 + qzhkl.^2);

                        xp = zeros(length(qxyhkl),1);
                        yp = zeros(length(qxzhkl),1);
                        for n = 1:length(qxyhkl)
                            [~,idx_x] = min(abs(qxyhkl(n)-qhor));
                            xp(n) = idx_x;
                            [~,idx_y] = min(abs(qxzhkl(n)-qver));
                            yp(n) = idx_y;

                            plot(xp(n),yp(n),TShN,'MarkerSize',STSizeN,'MarkerFaceColor',TMCN,'MarkerEdgeColor',TClN); hold on

                            if HKLPlaneOn == 1
                                hkltext = num2str(hkl{n});
                                t = text(xp(n),yp(n),hkltext);
                                t.Color = TClN;
                                t.FontSize = 9;
                                switch param.PLNpos
                                    case 'left'
                                        t.HorizontalAlignment = 'right';
                                        t.VerticalAlignment = 'baseline';
                                    case 'center'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'baseline';
                                    case 'right'
                                        t.HorizontalAlignment = 'left';
                                        t.VerticalAlignment = 'baseline';
                                    case 'top'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'bottom';
                                    case 'bottom'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'cap';
                                end % end of switch Plane position

                            end % end of HKL plane
                        end % end of n loop

                    elseif RandOri == 1 % Random orientation On
                        q = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);

                        theta = linspace(0, pi, 100);
                        xp = zeros(length(qhkl),100);
                        yp = zeros(length(qhkl),100);
                        for n = 1:length(qhkl)
                            [~,rp] = min(abs(qhkl(n)-q));
                            xp(n,:) = rp * cos(theta);
                            yp(n,:) = rp * sin(theta);

                            plot(xp(n,:), yp(n,:), 'Color',TMCN,'LineWidth', 2); % 
                            hold on
            
                            if HKLPlaneOn == 1
                                hkltext = num2str(hkl{n});
                                t = text(xp(n),yp(n),hkltext);

                                t.Color = TClN;
                                t.FontSize = 9;
                                switch param.PLNpos
                                    case 'left'
                                        t.HorizontalAlignment = 'right';
                                        t.VerticalAlignment = 'baseline';
                                    case 'center'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'baseline';
                                    case 'right'
                                        t.HorizontalAlignment = 'left';
                                        t.VerticalAlignment = 'baseline';
                                    case 'top'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'bottom';
                                    case 'bottom'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'cap';
                                end % end of switch Plane position
                            end % end of HKL plane
                        end % end of n for loop    

                    end % end of Random Orientation

                    if HoldingIm == 1
                        if RandOri == 0 % Random orientation Off
                            qhor = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);
                            qver = sign(param.qz) .* param.Q(:,fix(param.bpos(1)))';

                            qxyhklo = sqrt(qxhklo.^2 + qyhklo.^2);
                            qxzhklo = sqrt(qxhklo.^2 + qzhklo.^2);

                            xpo = zeros(length(qxyhklo),1);
                            ypo = zeros(length(qxzhklo),1);
                            for m = 1:length(qxyhklo)
                                [~,idx_x] = min(abs(qxyhklo(m)-qhor));
                                xpo(m) = idx_x;
                                [~,idx_y] = min(abs(qxzhklo(m)-qver));
                                ypo(m) = idx_y;

                                plot(xpo(m),ypo(m),TShO,'MarkerSize',STSizeO,'MarkerFaceColor',TMCO,'MarkerEdgeColor',TClO); hold on

                                if HKLPlaneOn == 1
                                    hkltext = num2str(hklo{m});
                                    t = text(xpo(m),ypo(m),hkltext);
                                    t.Color = TClO;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of m loop

                        elseif RandOri == 1 % Random orientation On
                            q = sign(param.qy) .* param.Q(fix(param.bpos(2)),:);

                            theta = linspace(0, pi, 100);
                            xpo = zeros(length(qhklo),100);
                            ypo = zeros(length(qhklo),100);
                            for m = 1:length(qhklo)
                                [~,rp] = min(abs(qhklo(m)-q));
                                xpo(m,:) = rp * cos(theta);
                                ypo(m,:) = rp * sin(theta);

                                plot(xpo(m,:), ypo(m,:), 'Color',TMCO,'LineWidth', 2); %
                                hold on

                                if HKLPlaneOn == 1
                                    hkltext = num2str(hklo{m});
                                    t = text(xpo(m),ypo(m),hkltext);

                                    t.Color = TClO;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of m for loop

                        end % end of Random Orientation

                    end % end of Holding image

                end % end of HKL plot
                set(gca, 'YDir', 'reverse');

                xlabel('Y, pixel');
                ylabel('Z, pixel');

            case 'Qy/Qz'
                imagesc(param.qy,param.qz,param.dataq); 
                hold on
                
                if HKLCheckOn == 1
                    if RandOri == 0
                        for n = 1:length(qzhkl)
                            if qyhkl(n) > param.xlimmax || qzhkl(n) > param.ylimmax
                                continue
                            else
                                plot(qyhkl(n),qzhkl(n),TShN,'MarkerSize',STSizeN,'MarkerFaceColor',TMCN,'MarkerEdgeColor',TClN); hold on
                                if HKLPlaneOn == 1
                                    hkltext = num2str(hkl{n});
                                    t = text(qyhkl(n),qzhkl(n),hkltext);
                                    t.Color = TClN;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of range
                        end % end of for n loop

                    elseif RandOri == 1
                        % Sorting out duplicated position
                        [qhkl, hkl] = collapsePGIXSDuplicateRings(qhkl, hkl);

                        theta = linspace(0, 2*pi, 100);
                        xp = zeros(length(qhkl),100);
                        yp = zeros(length(qhkl),100);
                        for n = 1:length(qhkl)
                            xp(n,:) = qhkl(n) * cos(theta);
                            yp(n,:) = qhkl(n) * sin(theta);

                            plot(xp(n,:), yp(n,:), 'Color',TMCN,'LineWidth', 2);
                            hold on

                            if HKLPlaneOn == 1
                                hkltext = num2str(hkl(n,:));
                                t = text(xp(n),yp(n),hkltext);
                                t.Color = TClN;
                                t.FontSize = 9;
                                switch param.PLNpos
                                    case 'left'
                                        t.HorizontalAlignment = 'right';
                                        t.VerticalAlignment = 'baseline';
                                    case 'center'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'baseline';
                                    case 'right'
                                        t.HorizontalAlignment = 'left';
                                        t.VerticalAlignment = 'baseline';
                                    case 'top'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'bottom';
                                    case 'bottom'
                                        t.HorizontalAlignment = 'center';
                                        t.VerticalAlignment = 'cap';
                                end % end of switch Plane position
                            end % end of HKL plane
                        end % end of n for loop

                    end % end of Random Orientation

                    if HoldingIm == 1
                        if RandOri == 0
                            for m = 1:length(qzhklo)
                                if qyhklo(m) > param.xlimmax || qzhklo(m) > param.ylimmax
                                    continue
                                else
                                    plot(qyhklo(m),qzhklo(m),TShO,'MarkerSize',STSizeO,'MarkerFaceColor',TMCO,'MarkerEdgeColor',TClO); hold on
                                    if HKLPlaneOn == 1
                                        hkltext = num2str(hklo{m});
                                        t = text(qyhklo(m),qzhklo(m),hkltext);
                                        t.Color = TClO;
                                        t.FontSize = 9;
                                        switch param.PLNpos
                                            case 'left'
                                                t.HorizontalAlignment = 'right';
                                                t.VerticalAlignment = 'baseline';
                                            case 'center'
                                                t.HorizontalAlignment = 'center';
                                                t.VerticalAlignment = 'baseline';
                                            case 'right'
                                                t.HorizontalAlignment = 'left';
                                                t.VerticalAlignment = 'baseline';
                                            case 'top'
                                                t.HorizontalAlignment = 'center';
                                                t.VerticalAlignment = 'bottom';
                                            case 'bottom'
                                                t.HorizontalAlignment = 'center';
                                                t.VerticalAlignment = 'cap';
                                        end
                                    end
                                end
                            end
                            clear m

                        elseif RandOri == 1
                            % Sorting out duplicated position
                            [qhklo, hklo] = collapsePGIXSDuplicateRings(qhklo, hklo);

                            theta = linspace(0, 2*pi, 100);
                            xpo = zeros(length(qhklo),100);
                            ypo = zeros(length(qhklo),100);
                            for m = 1:length(qhklo)
                                xpo(m,:) = qhklo(m) * cos(theta);
                                ypo(m,:) = qhklo(m) * sin(theta);

                                plot(xpo(m,:), ypo(m,:), 'Color',TMCN,'LineWidth', 2);
                                hold on

                                if HKLPlaneOn == 1
                                    hkltext = num2str(hklo(m,:));
                                    t = text(xpo(m),ypo(m),hkltext);
                                    t.Color = TClO;
                                    t.FontSize = 9;
                                    switch param.PLNpos
                                        case 'left'
                                            t.HorizontalAlignment = 'right';
                                            t.VerticalAlignment = 'baseline';
                                        case 'center'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'baseline';
                                        case 'right'
                                            t.HorizontalAlignment = 'left';
                                            t.VerticalAlignment = 'baseline';
                                        case 'top'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'bottom';
                                        case 'bottom'
                                            t.HorizontalAlignment = 'center';
                                            t.VerticalAlignment = 'cap';
                                    end % end of switch Plane position
                                end % end of HKL plane
                            end % end of m for loop

                        end % end of Random Orientation

                    end % end of Holding image

                end % end of HKL plot

                set(gca, 'YDir', 'normal');

                xlabel('q_y, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
                ylabel('q_z, A^{-1}','Interpreter','tex','Fontname','TimesNewRoman');
        end % end of Mapping
       
        axis image;
        set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
        set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
        clim([param.cmin,param.cmax]);
        set(gca,'colorscale',param.colorscale);

        [cmap, cmapReport] = resolvePGIXSColormap(param.colorm, param.dataq, 256);
        colormap(hAXtab, cmap);
        if cmapReport.FallbackUsed
            warning('PGIXS:ColormapFallback', ...
                'Failed to apply selected colormap. Falling back to jet: %s', cmapReport.Message);
        end

        hcb=colorbar;
        hcb.Label.String = 'Intensity, arb. units';
        hcb.Label.FontSize = 20;
        
        set(gca, 'FontSize', param.fontsize);
        set(gca, 'FontName', 'times');

        title(param.FileName,'Interpreter', 'none','FontSize',11);

        drawnow();

    end

% save selection value
    function Solveparam_Callback(~,~)
        if ~isfield(param, 'dataq') || isempty(param.dataq)
            warndlg('Q-space data is not loaded.', 'Warning');
            return;
        end
        if exist('getpts', 'file') == 0 && exist('getpts', 'builtin') == 0
            warndlg('Auto Index requires MATLAB getpts support for interactive peak selection.', 'Warning');
            return;
        end
        param.Mapping = MapList{get(hMapping,'Value')};
        if ~contains(param.Mapping, 'Q')
            warndlg('Please switch to Qy/Qz mode before auto indexing.', 'Warning');
            return;
        end

        msgbox({'[Auto Indexing - TrXS]', ...
                'Select at least four Qy/Qz peaks on the image.', ...
                'Press Enter when peak selection is complete.'}, 'Auto Index');
        axes(hAXtab);
        [selectedQy, selectedQz] = getpts(hAXtab);
        if numel(selectedQy) < 4
            warndlg('Please select at least four peaks.', 'Warning');
            return;
        end

        sizeLabels = {'Small (< 10 A)', 'Medium (10 - 30 A)', 'Large (> 30 A)'};
        [sizeIndex, isOK] = listdlg('PromptString', 'Expected lattice size:', ...
            'SelectionMode', 'single', 'ListString', sizeLabels, 'ListSize', [250, 100]);
        if isOK == 0
            return;
        end
        sizeClasses = {'small', 'medium', 'large'};
        sizeClass = sizeClasses{sizeIndex};

        hWait = waitbar(0, 'Auto indexing...');
        try
            fastOptions = optimset('Display', 'off', 'TolX', 1e-2, 'MaxFunEvals', 500);
            refineOptions = optimset('Display', 'off', 'TolX', 1e-5, 'MaxFunEvals', 2500);
            waitbar(0.25, hWait, 'Optimizing lattice parameters...');
            [finalParams, finalError, autoReport] = runPGIXSTrXSAutoIndex( ...
                [selectedQy, selectedQz], sizeClass, fastOptions, refineOptions);

            set(TX.haunit, 'String', num2str(finalParams(1), '%.2f'));
            set(TX.hbunit, 'String', num2str(finalParams(2), '%.2f'));
            set(TX.hcunit, 'String', num2str(finalParams(3), '%.2f'));
            set(TX.halpha, 'String', num2str(finalParams(4), '%.1f'));
            set(TX.hbeta, 'String', num2str(finalParams(5), '%.1f'));
            set(TX.hgamma, 'String', num2str(finalParams(6), '%.1f'));
            waitbar(1, hWait, 'Updating indexing overlay...');
            if isvalid(hWait), close(hWait); end

            Xtalplot_Callback();
            msgbox(sprintf('Auto Indexing Done.\nClass: %s\nPeaks: %d\nError: %.4g', ...
                autoReport.SizeClass, autoReport.ExperimentalPeakCount, finalError), 'Auto Index');
        catch ME
            if exist('hWait', 'var') && isvalid(hWait), close(hWait); end
            warndlg(['Auto indexing failed: ', ME.message], 'Auto Index');
        end

    end

    function SmartRange_Callback(~,~)
        if ~isfield(param, 'dataq') && ~isfield(param, 'datapx')
            warndlg('데이터가 로드되지 않았습니다.', 'Warning');
            return;
        end

        a = parsePGIXSNumeric(get(TX.haunit, 'String'), 10, eps, Inf);
        b = parsePGIXSNumeric(get(TX.hbunit, 'String'), 10, eps, Inf);
        c = parsePGIXSNumeric(get(TX.hcunit, 'String'), 10, eps, Inf);

        maxQ = 3.5;
        param.Mapping = MapList{get(hMapping, 'Value')};
        if contains(param.Mapping, 'Q')
            qYLimit = parsePGIXSNumeric(get(TX.cXlim2, 'String'), NaN, -Inf, Inf);
            qZLimit = parsePGIXSNumeric(get(TX.cYlim2, 'String'), NaN, -Inf, Inf);
            if isfinite(qYLimit) && isfinite(qZLimit)
                maxQ = hypot(qYLimit, qZLimit);
            end
        end

        hklLimits = computePGIXSSmartHKLLimits([a b c], maxQ);
        set(hHidx, 'String', num2str(hklLimits(1)));
        set(hKidx, 'String', num2str(hklLimits(2)));
        set(hLidx, 'String', num2str(hklLimits(3)));
        Xtalplot_Callback();
    end

% check radial average plot
    function RadialAve_Callback(~,~)

        

    end

    function LineCut_Callback(~,~)
        if ~isfield(param, 'datapx') || isempty(param.datapx)
            warndlg('No data loaded.', 'Warning');
            return;
        end
        msgbox('Draw a line on the image.', 'Info');
        hLine = drawline(hAXtab, 'Color', 'r', 'LineWidth', 2, ...
            'Label', '1D Profile Extract', 'LabelVisible', 'hover');
        if ~isvalid(hLine)
            return;
        end

        figure1D = figure('Name', 'Interactive 1D Line Profile', 'NumberTitle', 'off');
        axes1D = axes('Parent', figure1D);
        hLinePlot = plot(axes1D, NaN, NaN, 'r-', 'LineWidth', 1.5);
        grid(axes1D, 'on');
        xlabel(axes1D, 'Distance');
        ylabel(axes1D, 'Intensity');

        updateProfile = @(src, evt) extract_and_plot(src, hAXtab, hLinePlot, axes1D);
        extract_and_plot(hLine, hAXtab, hLinePlot, axes1D);
        addlistener(hLine, 'MovingROI', updateProfile);
        addlistener(hLine, 'ROIMoved', updateProfile);
    end

    function extract_and_plot(hLineObj, hAxes, plotObj, destAxes)
        if ~isvalid(hLineObj) || ~isvalid(plotObj)
            return;
        end
        pos = hLineObj.Position;
        hImgObj = findobj(hAxes, 'Type', 'Image');
        if isempty(hImgObj)
            return;
        end

        try
            [cx, cy, intensityProfile] = improfile(double(hImgObj.XData), ...
                double(hImgObj.YData), hImgObj.CData, double(pos(:, 1)), ...
                double(pos(:, 2)), 200);
            distAxis = hypot(cx - cx(1), cy - cy(1));
            set(plotObj, 'XData', distAxis, 'YData', intensityProfile);
            title(destAxes, sprintf('Line Cut: (%.2f, %.2f) to (%.2f, %.2f)', ...
                pos(1, 1), pos(1, 2), pos(2, 1), pos(2, 2)));
        catch ME
            warning('PGIXS:LinecutProfileFailed', ...
                'Line cut profile extraction failed: %s', ME.message);
        end
    end

    function Resize_Callback(src, ~)
        referenceHeight = 900;
        originalUnits = get(src, 'Units');
        set(src, 'Units', 'pixels');
        pos = get(src, 'Position');
        set(src, 'Units', originalUnits);
        scaleFactor = max(pos(4) / referenceHeight, 0.5);
        allObj = findall(src, '-property', 'FontSize');

        for ii = 1:length(allObj)
            obj = allObj(ii);
            userData = get(obj, 'UserData');
            if isempty(userData) || ~isstruct(userData) || ~isfield(userData, 'BaseFontSize')
                userData.BaseFontSize = get(obj, 'FontSize');
                set(obj, 'UserData', userData);
            end
            set(obj, 'FontSize', userData.BaseFontSize * scaleFactor);
        end
    end

    function applyModernControlStyle(parentFig)
        panels = findall(parentFig, 'Type', 'uipanel');
        for ii = 1:numel(panels)
            try
                set(panels(ii), 'BackgroundColor', coldf, 'BorderType', 'line', ...
                    'HighlightColor', [0.78 0.78 0.78], 'ShadowColor', [0.92 0.92 0.92]);
            catch
            end
        end

        controls = findall(parentFig, 'Type', 'uicontrol');
        for ii = 1:numel(controls)
            ctrl = controls(ii);
            try
                style = lower(get(ctrl, 'Style'));
            catch
                style = '';
            end
            try
                switch style
                    case 'pushbutton'
                        set(ctrl, 'BackgroundColor', [0.90 0.94 0.98], ...
                            'ForegroundColor', [0.05 0.12 0.20], ...
                            'FontWeight', 'bold');
                    case 'edit'
                        set(ctrl, 'BackgroundColor', [1 1 1], ...
                            'ForegroundColor', [0.05 0.05 0.05]);
                    case 'popupmenu'
                        set(ctrl, 'BackgroundColor', [1 1 1], ...
                            'ForegroundColor', [0.05 0.05 0.05]);
                    case 'checkbox'
                        set(ctrl, 'BackgroundColor', coldf, ...
                            'ForegroundColor', [0.05 0.05 0.05]);
                    case 'text'
                        set(ctrl, 'BackgroundColor', coldf, ...
                            'ForegroundColor', [0.15 0.15 0.15]);
                end
            catch
            end
        end
    end

    function KeyPress_Callback(~, event)
        currentObj = gco;
        if ~isempty(currentObj)
            if isprop(currentObj, 'Style') && strcmpi(get(currentObj, 'Style'), 'edit')
                return;
            end
            if isprop(currentObj, 'Type') && contains(get(currentObj, 'Type'), 'edit', 'IgnoreCase', true)
                return;
            end
        end

        stepAngle = 0.5;
        if ismember('shift', event.Modifier)
            stepAngle = 2.0;
        end

        currentRotation = parsePGIXSRotationVector( ...
            {get(hXrot, 'String'), get(hYrot, 'String'), get(hZrot, 'String')});
        currentX = currentRotation(1);
        currentY = currentRotation(2);
        currentZ = currentRotation(3);

        changed = false;
        switch event.Key
            case 'uparrow'
                currentX = currentX + stepAngle;
                changed = true;
            case 'downarrow'
                currentX = currentX - stepAngle;
                changed = true;
            case 'leftarrow'
                currentZ = currentZ - stepAngle;
                changed = true;
            case 'rightarrow'
                currentZ = currentZ + stepAngle;
                changed = true;
            case 'pageup'
                currentY = currentY + stepAngle;
                changed = true;
            case 'pagedown'
                currentY = currentY - stepAngle;
                changed = true;
        end

        if changed
            set(hXrot, 'String', num2str(currentX));
            set(hYrot, 'String', num2str(currentY));
            set(hZrot, 'String', num2str(currentZ));
            Xtalplot_Callback();
        end
    end
% ========================================================================
% save image
    function Savefile_Callback(~,~)

        HoldingIm = get(hHoldingS,'Value');

        RandOri = get(hRandOri,'Value');
        if RandOri == 0
            RandO = 'No Random Ori.';
        else
            RandO = 'Random Ori.';
        end

        if HoldingIm == 0

        Xtal = XTal.CrystalSystem{get(XTal.hCrystsys,'Value')};
        Spg = XTal.SpaceGroup{get(XTal.hSpaceGrp,'Value')};
        
        [a, b, c, alpha, beta, gamma] = parsePGIXSLatticeParameters( ...
            {get(TX.haunit,'String'), get(TX.hbunit,'String'), get(TX.hcunit,'String')}, ...
            {get(TX.halpha,'String'), get(TX.hbeta,'String'), get(TX.hgamma,'String')}, ...
            [10 10 10], [90 90 90]);

        lattice = [a, b, c, alpha, beta, gamma];
        lattice = applyPGIXSCrystalLatticeOverrides(lattice, Xtal);

        Rotation = parsePGIXSRotationVector({get(hXrot,'String'), get(hYrot,'String'), get(hZrot,'String')});

        [filepath, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName);
        if ~ok
            warndlg(['Save directory error: ', saveReport.Message], 'Warning');
            return;
        end
        SaveFile = [param.FileName,'_Fitparams.mat'];
        SaveFilepath = fullfile(filepath,SaveFile);
        fitParams = struct('Xtal', Xtal, 'Spg', Spg, 'lattice', lattice, ...
            'Rotation', Rotation, 'RandO', RandO);
        [saveOK, matSaveReport] = savePGIXSStructFile(SaveFilepath, fitParams);
        if ~saveOK
            warndlg(['Fit-parameter save failed: ', matSaveReport.Message], 'Warning');
            return;
        end
        SaveFigure = [param.FileName,'_2DImageHKL.jpg'];
        SaveFigurepath = fullfile(filepath,SaveFigure);
        [exportOK, exportReport] = exportPGIXSAxesImage(Im2Dplot, SaveFigurepath, 300);
        if ~exportOK
            warndlg(['Parameters were saved, but image export failed: ', exportReport.Message], 'Warning');
            return;
        end

        else
            ao = param.unitold(1);
            bo = param.unitold(2);
            co = param.unitold(3);
            alphao = param.unitold(4);
            betao = param.unitold(5);
            gammao = param.unitold(6);

            Xtal1 = param.Xtalold;
            Spg1 = param.Spgold;

            lattice1 = [ao, bo, co, alphao, betao, gammao];

            Rotation1 = [param.unitold(7),param.unitold(8),param.unitold(9)];

            [a, b, c, alpha, beta, gamma] = parsePGIXSLatticeParameters( ...
                {get(TX.haunit,'String'), get(TX.hbunit,'String'), get(TX.hcunit,'String')}, ...
                {get(TX.halpha,'String'), get(TX.hbeta,'String'), get(TX.hgamma,'String')}, ...
                [10 10 10], [90 90 90]);

            Xtal2 = XTal.CrystalSystem{get(XTal.hCrystsys,'Value')};
            Spg2 = XTal.SpaceGroup{get(XTal.hSpaceGrp,'Value')};
            lattice2 = [a, b, c, alpha, beta, gamma];
            lattice2 = applyPGIXSCrystalLatticeOverrides(lattice2, Xtal2);

            Rotation2 = parsePGIXSRotationVector({get(hXrot,'String'), get(hYrot,'String'), get(hZrot,'String')});

            [filepath, ok, saveReport] = ensurePGIXSSaveDir(param.Path, param.FileName);
            if ~ok
                warndlg(['Save directory error: ', saveReport.Message], 'Warning');
                return;
            end
            SaveFile = [param.FileName,'_Fitparams.mat'];
            SaveFilepath = fullfile(filepath,SaveFile);
            fitParams = struct('Xtal1', Xtal1, 'Spg1', Spg1, ...
                'lattice1', lattice1, 'Rotation1', Rotation1, ...
                'Xtal2', Xtal2, 'Spg2', Spg2, 'lattice2', lattice2, ...
                'Rotation2', Rotation2, 'RandO', RandO);
            [saveOK, matSaveReport] = savePGIXSStructFile(SaveFilepath, fitParams);
            if ~saveOK
                warndlg(['Fit-parameter save failed: ', matSaveReport.Message], 'Warning');
                return;
            end
            SaveFigure = [param.FileName,'_2DImageHKL.jpg'];
            SaveFigurepath = fullfile(filepath,SaveFigure);
            [exportOK, exportReport] = exportPGIXSAxesImage(Im2Dplot, SaveFigurepath, 300);
            if ~exportOK
                warndlg(['Parameters were saved, but image export failed: ', exportReport.Message], 'Warning');
                return;
            end

        end
    end
% ========================================================================



end % end of this gui

% ========================================================================
% John 14:6 (KSV)
% Jesus saith unto him, I am the way, the truth, and the life: no man
% cometh unto the Father, but by me.
% ========================================================================
