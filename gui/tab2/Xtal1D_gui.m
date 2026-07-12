function Xtal1D_gui
clear
clc;

main = figure('Name','Xtal-1D Fitting',...
    'NumberTitle','off','units',...
    'normalized','outerposition',[0.05 0.1 0.75 0.85]);

tgroup = uitabgroup('Parent', main);
tab1 = uitab('Parent', tgroup, 'Title', '1D Xtal'); %tab for data analysis

% ========================================================================
% tab1 uicontrol =========================================================
leftPanelData = uipanel('Parent',tab1,'Title','Control Panel','FontSize',...
    12,'Units','Normalized','Position',[.02 0.1 .225 .9]);

ImageController = uipanel('Parent',tab1,'Title','Plot Controller','FontSize',...
    10,'Units','Normalized','Position',[0.27 0.001 0.71 .105]);

% Image position and plot ================================================
Im2Dplot = uipanel('Parent',tab1,'Title','1D plot','FontSize',...
    12,'Units','Normalized','Position',[0.27 0.099 0.6 0.9],'BackgroundColor',[1 1 1]);

hAXtab = axes('Parent',Im2Dplot,'Position',[0.15 0.15 0.75 0.75]);

%=========================================================================
% version
uicontrol('Parent',tab1,'Style','text',...
    'String','Designed By Y.Y.Kim v0.1 (PLS-II BL3C)','Units','normalized',...
    'Position',[0.01 0.015 0.15 0.05]);

%=========================================================================
% Open data for tab1
uicontrol('Parent',leftPanelData,'String','Open data','FontSize',11,'Units','normalized',...
    'FontWeight','bold','Position',[0.055 0.94 0.4 0.055],...
    'Callback',@Opendata_Callback);

% Select mode
hTrMode = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Tr-mode','Value', 0,...
    'Units','normalized','Position',[0.52 0.97 0.3 0.03])    ;

hGIMode = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','GI-mode','Value', 0,...
    'Units','normalized','Position',[0.52 0.94 0.3 0.03])    ;

% ========================================================================
% Film incidence angle
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Inci. ang. [deg]',...
    'Units','normalized','Position',[0.02 0.902 0.3 0.03]);

hIncidA = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','0.1',...
    'Units','normalized','Position',[0.30 0.905 0.15 0.03]);

% Film critical angle
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Crit. ang. [deg]',...
    'Units','normalized','Position',[0.47 0.902 0.3 0.03]);

hCritiA = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','0.1',...
    'Units','normalized','Position',[0.75 0.905 0.15 0.03]);

%=========================================================================
% Xtal structure line plot for tab1
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Crystal System',...
    'Units','normalized','Position',[0.10 0.845 0.375 0.05]);

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
    'Position',[0.13 0.82 0.32 0.05],'String',XTal.CrystalSystem,...
    'Callback',@SpaceGroup_Callback);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Space Group',...
    'Units','normalized','Position',[0.50 0.845 0.375 0.05]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Normal Direction',...
    'Units','normalized','Position',[0.11 0.78 0.375 0.05]);

NormdirecList = {'001', '010', '100', '101', '011', '110', '111', '121'};

hNormDirec = uicontrol('Parent',leftPanelData,'Style','popupmenu','Units','normalized',...
    'Position',[0.53 0.785 0.32 0.05],'String',NormdirecList);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','a [A,h]',...
    'Units','normalized','Position',[0.03 0.764 0.15 0.03]);

XT.haunit = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.18 0.765 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','b [A,k]',...
    'Units','normalized','Position',[0.03 0.73 0.15 0.03]);

XT.hbunit = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.18 0.7325 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','c [A,l]',...
    'Units','normalized','Position',[0.03 0.6975 0.15 0.03]);

XT.hcunit = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.18 0.70 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','alpha',...
    'Units','normalized','Position',[0.35 0.764 0.15 0.03]);

XT.halpha = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','90',...
    'Units','normalized','Position',[0.50 0.765 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','beta',...
    'Units','normalized','Position',[0.35 0.73 0.15 0.03]);

XT.hbeta = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','90',...
    'Units','normalized','Position',[0.50 0.7325 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','gamma',...
    'Units','normalized','Position',[0.35 0.6975 0.15 0.03]);

XT.hgamma = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','90',...
    'Units','normalized','Position',[0.50 0.70 0.15 0.03]);

% hkl min & max ==========================================================
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','h_min',...
    'Units','normalized','Position',[0.03 0.657 0.15 0.03]);

hHmin = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','-3',...
    'Units','normalized','Position',[0.18 0.66 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','h_max',...
    'Units','normalized','Position',[0.35 0.657 0.15 0.03]);

hHmax = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','3',...
    'Units','normalized','Position',[0.5 0.66 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','k_min',...
    'Units','normalized','Position',[0.03 0.622 0.15 0.03]);

hKmin = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','-3',...
    'Units','normalized','Position',[0.18 0.627 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','k_max',...
    'Units','normalized','Position',[0.35 0.622 0.15 0.03]);

hKmax = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','3',...
    'Units','normalized','Position',[0.5 0.627 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','l_min',...
    'Units','normalized','Position',[0.03 0.59 0.15 0.03]);

hLmin = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','-3',...
    'Units','normalized','Position',[0.18 0.5925 0.15 0.03]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','l_max',...
    'Units','normalized','Position',[0.35 0.59 0.15 0.03]);

hLmax = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','3',...
    'Units','normalized','Position',[0.5 0.5925 0.15 0.03]);

% ========================================================================
% plot Xtal position in reciprocal space
uicontrol('Parent',leftPanelData,'String','Plot','Units','normalized',...
    'Position',[0.7 0.695 0.25 0.1],...
    'Callback',@Xtalplot_Callback);

% ========================================================================
% Special case
hSpecial = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Special','Value', 0,...
    'Units','normalized','Position',[0.075 0.56 0.25 0.03])    ;

% ========================================================================
% Random orientation
hRandOri = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Random Ori.','Value', 0,...
    'Units','normalized','Position',[0.275 0.56 0.25 0.03])    ;

% ========================================================================
% Holding the structure
hHoldingS = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Holding','Value', 0,...
    'Units','normalized','Position',[0.55 0.56 0.25 0.03])    ;

% ========================================================================
% hkl plot
HKLplot = uipanel('Parent',leftPanelData,'Title','HKLplot','FontSize',...
    9,'Units','Normalized','Position',[.05 0.47 .45 .09]);

hHKLCheck = uicontrol('Parent',HKLplot,'Style','checkbox',...
    'String','Trans.','Value',0,...
    'Units','normalized','Position',[0.04 0.65 0.4 0.3])    ;

hHKLRefl = uicontrol('Parent',HKLplot,'Style','checkbox',...
    'String','Reflec.','Value',0,...
    'Units','normalized','Position',[0.04 0.2 0.4 0.3])     ;

hHKLplane = uicontrol('Parent',HKLplot,'Style','checkbox',...
    'String','Plane','Value',0,...
    'Units','normalized','Position',[0.55 0.65 0.4 0.3])     ;

PLNpos = {'left', 'center', 'right', 'top', 'bottom'};
hPLNpos = uicontrol('Parent',HKLplot,'Style','popupmenu','Units','normalized',...
    'Position',[0.55 0.25 0.4 0.3],'String',PLNpos);

% ========================================================================
% Table
uicontrol('Parent',leftPanelData,'String','Table','FontSize',10,'Units','normalized',...
    'Position',[0.51 0.51 0.2 0.04],...
    'Callback',@HKLTable_Callback);

% ========================================================================
% Solving
uicontrol('Parent',leftPanelData,'String','Solve','FontSize',10,'Units','normalized',...
    'Position',[0.72 0.51 0.2 0.04],...
    'Callback',@Solveparam_Callback);




%=========================================================================
% UnitCell Image
UnitImage = uipanel('Parent',leftPanelData,'Title','Navigator','FontSize',...
    9,'Units','Normalized','Position',[.02 0.01 .95 .26]);
hImunit = axes('Parent',UnitImage,'position',[0.1 0.15 0.75 0.75]);

%==========================================================================
% plot scale
uicontrol('Parent',ImageController,'Style','text',...
    'String','Plot Scale',...
    'Units','normalized','Position',[0.01 0.6 0.08 0.3]);

scaleList = {'Linear', 'Logy', 'Logxy'};
hScale = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.01 0.225 0.08 0.4],'String',scaleList,...
    'Callback',@Updateplot_Callback);

%==========================================================================
% plot line style
uicontrol('Parent',ImageController,'Style','text',...
    'String','Line Style',...
    'Units','normalized','Position',[0.11 0.6 0.08 0.3]);

styleList = {'-', '--', ':', '-.', '-o'};
hLineStyle = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.11 0.225 0.08 0.4],'String',styleList,...
    'Callback',@Updateplot_Callback);

%==========================================================================
% plot line color
uicontrol('Parent',ImageController,'Style','text',...
    'String','Line Color',...
    'Units','normalized','Position',[0.21 0.6 0.08 0.3]);

colorList = {'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
hColorStyle = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.21 0.225 0.08 0.4],'String',colorList,...
    'Callback',@Updateplot_Callback);

%=========================================================================
% plot line width
uicontrol('Parent',ImageController,'Style','text',...
    'String','Line Width',...
    'Units','normalized','Position',[0.31 0.6 0.08 0.3]);

hLineWidth = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.325 0.225 0.05 0.4],...
    'Callback',@Updateplot_Callback);


%=========================================================================
% Image Range
uicontrol('Parent',ImageController,'Style','text',...
    'String','X-range',...
    'Units','normalized','Position',[0.40 0.6 0.08 0.3]);

XT.cXlim1 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.39 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

XT.cXlim2 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','2000',...
    'Units','normalized','Position',[0.44 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

uicontrol('Parent',ImageController,'Style','text',...
    'String','Y-range',...
    'Units','normalized','Position',[0.51 0.6 0.08 0.3]);

XT.cYlim1 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.50 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

XT.cYlim2 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','2000',...
    'Units','normalized','Position',[0.55 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

%=========================================================================
% update plot
uicontrol('Parent',ImageController,'String','Update Plot','Units','normalized',...
    'FontSize',9,'Position',[0.78 0.25 0.1 0.7],...
    'Callback',@Updateplot_Callback);

% ========================================================================
% save image 
uicontrol('Parent',ImageController,'String','Save Plot','Units','normalized',...
    'FontSize',9,'Position',[0.885 0.25 0.1 0.7],...
    'Callback',@Savefile_Callback);

% ========================================================================

% ========================================================================
% tab 1 Functions
% ========================================================================
param.I = [];
    function Opendata_Callback(~,~)
        clear param

        if ~exist('XSData','file')
            [XSData, datadir]=uigetfile({'*.*','All format(*.*)';'*.mat','Mat file(*.mat)'});
            if XSData==0
                return;
            end
            XSData = [datadir, XSData];
        end

        [param.Path, param.FileName, ~]=fileparts(XSData);

        D = load(XSData);

        param.Q = single(D.data(:,1));
        param.I = single(D.data(:,2));

        XT.cXlim1.String = num2str(min(param.Q));
        XT.cXlim2.String = num2str(max(param.Q));
        XT.cYlim1.String = num2str(min(param.I));
        XT.cYlim2.String = num2str(max(param.I));

        updatePlot;

        param.Expinfo = 1; % performance is done for reading information
        param.hklcal = 0; % Crystal fitting performance
    end

% ========================================================================
% plot function
    function updatePlot(~,~)

        param.plotscale = scaleList{get(hScale,'Value')};
        param.linestyle = styleList{get(hLineStyle,'Value')};
        param.linecolor = colorList{get(hColorStyle,'Value')};
        param.linewidth = str2double(get(hLineWidth,'String'));

%         param.hklplot = get(hHKLCheck,'Value');

        xlimmin = str2double(get(XT.cXlim1,'String'));
        xlimmax = str2double(get(XT.cXlim2,'String'));

        ylimmin = str2double(get(XT.cYlim1,'String'));
        ylimmax = str2double(get(XT.cYlim2,'String'));
 
        xdata = find(param.Q>=xlimmin & param.Q<=xlimmax);

        X = param.Q(xdata);
        Y = param.I(xdata);

        cla(hAXtab);
        axes(hAXtab);

        switch param.plotscale
            case 'Linear'

                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); axis tight
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'linear');
                set(hAXtab, 'XLim',[xlimmin, xlimmax]);
                set(hAXtab, 'YLim',[ylimmin, ylimmax]);
                xlabel('$q, \textrm{\AA}^{-1}$','Interpreter','latex','Fontname','TimesNewRoman');
                ylabel('Intensity, arb. units');

            case 'Logy'
                
                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); axis tight
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[xlimmin, xlimmax]);
                set(hAXtab, 'YLim',[ylimmin, ylimmax]);
                xlabel('$q, \textrm{\AA}^{-1}$','Interpreter','latex','Fontname','TimesNewRoman');
                ylabel('Intensity, arb. units');

            case 'Logxy'

                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); axis tight
                set(hAXtab, 'XScale', 'log');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[xlimmin, xlimmax]);
                set(hAXtab, 'YLim',[ylimmin, ylimmax]);
                xlabel('$q, \textrm{\AA}^{-1}$','Interpreter','latex','Fontname','TimesNewRoman');
                ylabel('Intensity, arb. units');

        end
                        
        set(hAXtab, 'FontSize', 15);
        set(hAXtab, 'FontName', 'times');
        
        drawnow();

        disp('Plot updated!');
    end

% ========================================================================
% Update image for tab1
    function Updateplot_Callback(~,~)
        HKLCheckOn = get(hHKLCheck,'Value');

        if HKLCheckOn == 0
            updatePlot;
        else
            Xtalplot_Callback;
        end
    end

% ========================================================================
% Space Group Callback
    function SpaceGroup_Callback(~,~)
        CS = XTal.CrystalSystem{get(XTal.hCrystsys,'Value')};

        switch CS
            case 'Layer'
                XTal.SpaceGroup = {'primitive'};
            case 'Hexagonal'
                XTal.SpaceGroup = {'P6/mmm'};
            case 'HCP'
                XTal.SpaceGroup = {'P63/mmc'};
            case 'Cubic'
                XTal.SpaceGroup = {'Im-3','Ia-3','Pm-3m','Pm-3n','Pn-3m','Fm-3m','Fd-3m','Im-3m','Ia-3d'};
            case 'Orthorhombic'
                XTal.SpaceGroup = {'P222','P2221','P21212','P212121','C2221','C222','F222','I222','I212121','Pca21','Pbca','Pnma','Fmmm','Fddd'};
            case 'Tetragonal'
                XTal.SpaceGroup = {'P4','I4','P42/nmc'};
            case 'Monoclinic'
                XTal.SpaceGroup = {'P2','P21','C2','Pm','Pc','Cm','Cc','P2/m','P21/m','C2/m','P2/c','P21/c'};
            case 'Rhombohedral'
                XTal.SpaceGroup = {'P3'};
            case 'Triclinic'
                XTal.SpaceGroup = {'P1','P-1'};
        end

        XTal.hSpaceGrp = uicontrol('Parent',leftPanelData,'Style','popupmenu','Units','normalized',...
            'Position',[0.53 0.82 0.32 0.05],'String',XTal.SpaceGroup,...
            'Callback',@Structure_Callback);
    end

% ========================================================================
% Structure_Callback
    function Structure_Callback(~,~)
        param.Xtal = XTal.CrystalSystem{get(XTal.hCrystsys,'Value')};
        param.Spg = XTal.SpaceGroup{get(XTal.hSpaceGrp,'Value')};
        Xrot = single(str2double(get(hXrot,'String'))); % clockwise
        Yrot = single(str2double(get(hYrot,'String'))); % anti-clockwise
        Zrot = single(str2double(get(hZrot,'String'))); % clockwise
        angle = [Xrot, Yrot, Zrot];

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











% ========================================================================
% save image
%     function Savefile_Callback(~,~)
% 
%         HoldingIm = get(hHoldingS,'Value');
% 
%         if HoldingIm == 0
% 
% %         Xtal = StructureList{get(hStructure,'Value')};
%         
%         a = str2double(get(XT.haunit,'String'));
%         b = str2double(get(XT.hbunit,'String'));
%         c = str2double(get(XT.hcunit,'String'));
%         alpha = str2double(get(XT.halpha,'String'));
%         beta = str2double(get(XT.hbeta,'String'));
%         gamma = str2double(get(XT.hgamma,'String'));
% 
%         lattice = [a, b, c, alpha, beta, gamma];
% 
%         filepathadd = ['/',param.FileName];
%         filepath = fullfile(param.Path,filepathadd);
%         mkdir(filepath);
%         SaveFile = [param.FileName,'_HKL1dparams.mat'];
%         SaveFilepath = fullfile(filepath,SaveFile);
%         save(SaveFilepath,'Xtal','lattice');
%         SaveFigure = [param.FileName,'_1DplotHKL.jpg'];
%         SaveFigurepath = fullfile(filepath,SaveFigure);
%         exportgraphics(Im2Dplot,SaveFigurepath);
%         disp('Save is done!')
% 
%         else
%             ao = param.unitold(1);
%             bo = param.unitold(2);
%             co = param.unitold(3);
%             alphao = param.unitold(4);
%             betao = param.unitold(5);
%             gammao = param.unitold(6);
% 
%             Xtal1 = param.Xtalold;
% 
%             lattice1 = [ao, bo, co, alphao, betao, gammao];
% 
%             a = str2double(get(XT.haunit,'String'));
%             b = str2double(get(XT.hbunit,'String'));
%             c = str2double(get(XT.hcunit,'String'));
%             alpha = str2double(get(XT.halpha,'String'));
%             beta = str2double(get(XT.hbeta,'String'));
%             gamma = str2double(get(XT.hgamma,'String'));
% 
%             lattice2 = [a, b, c, alpha, beta, gamma];
% 
%             Xtal2 = StructureList{get(hStructure,'Value')};
% 
%             filepathadd = ['/',param.FileName];
%             filepath = fullfile(param.Path,filepathadd);
%             mkdir(filepath);
%             SaveFile = [param.FileName,'_HKL1dparams.mat'];
%             SaveFilepath = fullfile(filepath,SaveFile);
%             save(SaveFilepath,'Xtal1','lattice1','Xtal2','lattice2');
%             SaveFigure = [param.FileName,'_1DplotHKL.jpg'];
%             SaveFigurepath = fullfile(filepath,SaveFigure);
%             exportgraphics(Im2Dplot,SaveFigurepath);
%             disp('Save is done!')
% 
%         end
%     end
% ========================================================================

end % End of GUI
% ========================================================================
% John 14:6 (KSV)
% Jesus saith unto him, I am the way, the truth, and the life: no man
% cometh unto the Father, but by me.
% ========================================================================
