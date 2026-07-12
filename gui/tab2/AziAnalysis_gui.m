function AziAnalysis_gui
clear
clc;

main = figure('Name','Azimuthal Analysis',...
    'NumberTitle','off','units',...
    'normalized','outerposition',[0.05 0.1 0.75 0.85]);

tgroup = uitabgroup('Parent', main);
tab1 = uitab('Parent', tgroup, 'Title', 'Azimuthal Analysis'); %tab for data analysis

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
    'String','Designed By Y.Y.Kim 2022 (PLS-II BL3C)','Units','normalized',...
    'Position',[0.01 0.015 0.15 0.05]);

%=========================================================================
% Open data for tab1
uicontrol('Parent',leftPanelData,'String','Open data','Units','normalized',...
    'Position',[0.125 0.905 0.75 0.08],...
    'Callback',@Opendata_Callback);

% ========================================================================
% Delete position
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Delete position',...
    'Units','normalized','Position',[0.2 0.85 0.3 0.04]);

hDelpos = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','-30, -10, 0, 10, 30',...
    'Units','normalized','Position',[0.075 0.83 0.52 0.03]);

uicontrol('Parent',leftPanelData,'String','Delete','Units','normalized',...
            'FontSize',9,'Position',[0.65 0.83 0.3 0.05],...
            'Callback',@Delexecute_Callback);

% ========================================================================
% Flip Correction
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Flip center',...
    'Units','normalized','Position',[0.1 0.775 0.2 0.04]);

hFpos = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','0',...
    'Units','normalized','Position',[0.1 0.76 0.2 0.03]);

hPFlip = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Plus Flip','Value',0,...
    'Units','normalized','Position',[0.375 0.78 0.25 0.04]);

hMFlip = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Minus Flip','Value',0,...
    'Units','normalized','Position',[0.375 0.75 0.25 0.04]);

uicontrol('Parent',leftPanelData,'String','Flip','Units','normalized',...
            'FontSize',9,'Position',[0.65 0.76 0.3 0.05],...
            'Callback',@FlipC_Callback);

% ========================================================================
% Define the background
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Background','FontWeight','bold',...
    'Units','normalized','Position',[0.05 0.68 0.25 0.05]);

uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Lin. bkg',...
    'Units','normalized','Position',[0.35 0.705 0.15 0.04]);

XT.BLinbkg = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.35 0.69 0.15 0.03]);

uicontrol('Parent',leftPanelData,'String','Plot','Units','normalized',...
            'FontSize',9,'Position',[0.65 0.69 0.3 0.05],...
            'Callback',@BkgPlot_Callback);

% ========================================================================
% Select the Number of peaks (max 8) & types
uicontrol('Parent',leftPanelData,'Style','text',...
    'String','Fit param. (pseudoVoigt)','FontWeight','bold',...
    'Units','normalized','Position',[0.035 0.63 0.5 0.05]);

uicontrol('Parent',leftPanelData,'Style','text',...
          'String','Use',...
          'Units','normalized','Position',[0.04 0.615 0.15 0.04]);

uicontrol('Parent',leftPanelData,'Style','text',...
          'String','Amp.',...
          'Units','normalized','Position',[0.22 0.615 0.15 0.04]);
                
uicontrol('Parent',leftPanelData,'Style','text',...
          'String','Ratio',...
          'Units','normalized','Position',[0.40 0.615 0.15 0.04]);

uicontrol('Parent',leftPanelData,'Style','text',...
          'String','Mean',...
          'Units','normalized','Position',[0.58 0.615 0.15 0.04]);

uicontrol('Parent',leftPanelData,'Style','text',...
          'String','FWHM',...
          'Units','normalized','Position',[0.76 0.615 0.15 0.04]);

hUseP1 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','1','Value',0,...
    'Units','normalized','Position',[0.07 0.59 0.15 0.04])    ;

XT.Amp1 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.59 0.15 0.04]);

XT.Ratio1 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.59 0.15 0.04]);

XT.Cen1 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.59 0.15 0.04]);

XT.FWHM1 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.59 0.15 0.04]);

hUseP2 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','2','Value',0,...
    'Units','normalized','Position',[0.07 0.54 0.15 0.04])    ;

XT.Amp2 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.54 0.15 0.04]);

XT.Ratio2 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.54 0.15 0.04]);

XT.Cen2 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.54 0.15 0.04]);

XT.FWHM2 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.54 0.15 0.04]);

hUseP3 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','3','Value',0,...
    'Units','normalized','Position',[0.07 0.49 0.15 0.04])    ;

XT.Amp3 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.49 0.15 0.04]);

XT.Ratio3 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.49 0.15 0.04]);

XT.Cen3 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.49 0.15 0.04]);

XT.FWHM3 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.49 0.15 0.04]);

hUseP4 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','4','Value',0,...
    'Units','normalized','Position',[0.07 0.44 0.15 0.04])    ;

XT.Amp4 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.44 0.15 0.04]);

XT.Ratio4 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.44 0.15 0.04]);

XT.Cen4 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.44 0.15 0.04]);

XT.FWHM4 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.44 0.15 0.04]);

hUseP5 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','5','Value',0,...
    'Units','normalized','Position',[0.07 0.39 0.15 0.04])    ;

XT.Amp5 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.39 0.15 0.04]);

XT.Ratio5 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.39 0.15 0.04]);

XT.Cen5 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.39 0.15 0.04]);

XT.FWHM5 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.39 0.15 0.04]);

hUseP6 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','6','Value',0,...
    'Units','normalized','Position',[0.07 0.34 0.15 0.04])    ;

XT.Amp6 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.34 0.15 0.04]);

XT.Ratio6 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.34 0.15 0.04]);

XT.Cen6 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.34 0.15 0.04]);

XT.FWHM6 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.34 0.15 0.04]);

hUseP7 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','7','Value',0,...
    'Units','normalized','Position',[0.07 0.29 0.15 0.04])    ;

XT.Amp7 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.29 0.15 0.04]);

XT.Ratio7 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.29 0.15 0.04]);

XT.Cen7 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.29 0.15 0.04]);

XT.FWHM7 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.29 0.15 0.04]);

hUseP8 = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','8','Value',0,...
    'Units','normalized','Position',[0.07 0.24 0.15 0.04])    ;

XT.Amp8 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.22 0.24 0.15 0.04]);

XT.Ratio8 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.40 0.24 0.15 0.04]);

XT.Cen8 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.58 0.24 0.15 0.04]);

XT.FWHM8 = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.76 0.24 0.15 0.04]);

uicontrol('Parent',leftPanelData,'String','Plot','Units','normalized',...
    'FontSize',9,'Position',[0.62 0.18 0.3 0.05],...
    'Callback',@PeakPlot_Callback);

% ========================================================================
% Excluding area
ExclOnOff = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Excluding Range (Even)',...
    'Units','normalized','Position',[0.07 0.14 0.45 0.04]);

hExclR = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','-90, -85, 85, 90',...
    'Units','normalized','Position',[0.075 0.1 0.52 0.04]);

% ========================================================================
% Boundary 
hBoundary = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Bound, [%] ','Value',0,...
    'Units','normalized','Position',[0.07 0.055 0.35 0.04]);

hBoundR = uicontrol('Parent',leftPanelData,'Style','edit',...
    'String','50',...
    'Units','normalized','Position',[0.39 0.055 0.2 0.04]);

% ========================================================================
% Weight
hWeight = uicontrol('Parent',leftPanelData,'Style','checkbox',...
    'String','Weight','Value',0,...
    'Units','normalized','Position',[0.07 0.02 0.25 0.04]);

% ========================================================================
% Fit function
uicontrol('Parent',leftPanelData,'String','Auto Fit','Units','normalized',...
    'Position',[0.62 0.1 0.3 0.045],...
    'Callback',@AutoFit_Callback);

% ========================================================================
% View result of Area value
uicontrol('Parent',leftPanelData,'String','Area','Units','normalized',...
    'Position',[0.62 0.055 0.3 0.04],...
    'Callback',@AreaR_Callback);

% ========================================================================
% plot scale
uicontrol('Parent',ImageController,'Style','text',...
    'String','Plot Scale',...
    'Units','normalized','Position',[0.01 0.6 0.08 0.3]);

scaleList = {'Linear', 'Logy'};
hScale = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.01 0.225 0.08 0.4],'String',scaleList,...
    'Callback',@Updateplot_Callback);

% ========================================================================
% plot line style
uicontrol('Parent',ImageController,'Style','text',...
    'String','Line Style',...
    'Units','normalized','Position',[0.11 0.6 0.08 0.3]);

styleList = {'-', '--', ':', '-.', '-o'};
hLineStyle = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.11 0.225 0.08 0.4],'String',styleList,...
    'Callback',@Updateplot_Callback);

% ========================================================================
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
    'Units','normalized','Position',[0.42 0.6 0.08 0.3]);

XT.cXlim1 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','-90',...
    'Units','normalized','Position',[0.41 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

XT.cXlim2 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','90',...
    'Units','normalized','Position',[0.46 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

uicontrol('Parent',ImageController,'Style','text',...
    'String','Y-range',...
    'Units','normalized','Position',[0.53 0.6 0.08 0.3]);

XT.cYlim1 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.52 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

XT.cYlim2 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','2000',...
    'Units','normalized','Position',[0.57 0.28 0.05 0.35],...
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
% Azimuthal Analysis Functions
% ========================================================================
param.I = [];

% ========================================================================
% Open function
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

        param.Ang = single(D.data(:,1))-90;
        param.I = single(D.data(:,2));
        param.I(param.I == 0) = nan;

        XT.cXlim1.String = num2str(min(param.Ang));
        XT.cXlim2.String = num2str(max(param.Ang));
        XT.cYlim1.String = num2str(min(param.I));
        XT.cYlim2.String = num2str(max(param.I));

        updatePlot;

    end

% ========================================================================
% Delete position
    function Delexecute_Callback(~,~)
        Delstr = get(hDelpos,'String');
        DelAng = str2num(Delstr);
        Delpix = zeros(length(DelAng),1);
        for ii = 1:length(DelAng)
            Delpix(ii) = find(param.Ang == DelAng(ii));
        end
        
        param.I(Delpix) = nan;

        updatePlot;

    end

% ========================================================================
% Flip copy (if pattern is not perfect)
    function FlipC_Callback(~,~)
        Fcen = str2double(get(hFpos,'String'));
        PlusFlip = get(hPFlip,'Value');
        MinusFlip = get(hMFlip,'Value');
              
        if PlusFlip == 1 && MinusFlip == 0
            f_idx = find(param.Ang> Fcen);
            Ic = param.I(f_idx);
            Ic = flipud(Ic);

            c_idx = find(param.Ang <-Fcen);
            param.I(c_idx) = Ic;

        elseif MinusFlip == 1 && PlusFlip == 0
            f_idx = find(param.Ang< -Fcen);
            Ic = param.I(f_idx);    
            Ic = flipud(Ic);

            c_idx = find(param.Ang > Fcen);
            param.I(c_idx) = Ic;
        else
            msgbox('Select plus or minus flip checkbox!!');
            return
        end
        
        updatePlot;
    end

% ========================================================================
% Linear background
    function BkgPlot_Callback(~,~)
        param.plotscale = scaleList{get(hScale,'Value')};
        param.linestyle = styleList{get(hLineStyle,'Value')};
        param.linecolor = colorList{get(hColorStyle,'Value')};
        param.linewidth = str2double(get(hLineWidth,'String'));

        param.xlimmin = str2double(get(XT.cXlim1,'String'));
        param.xlimmax = str2double(get(XT.cXlim2,'String'));

        param.ylimmin = str2double(get(XT.cYlim1,'String'));
        param.ylimmax = str2double(get(XT.cYlim2,'String'));    

        bkgcolor = [0.6350 0.0780 0.1840];

        xdata = find(param.Ang>=param.xlimmin & param.Ang<=param.xlimmax);

        X = param.Ang(xdata);
        Y = param.I(xdata);

        bkg = str2double(get(XT.BLinbkg,'String'));

        cla(hAXtab);
        axes(hAXtab);

        switch param.plotscale
            case 'Linear'

                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); hold on
                yline(bkg,'-','Color',bkgcolor,'LineWidth',param.linewidth); hold off
                   
                axis tight
                legend('Data','Bkg');
                legend('boxoff');
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'linear');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

            case 'Logy'

                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); hold on
                yline(bkg,'-','Color',bkgcolor,'LineWidth',param.linewidth); hold off
                
                axis tight
                legend('Data','Bkg');
                legend('boxoff');
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

            case 'Logxy'

                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); hold on
                yline(bkg,'-','Color',bkgcolor,'LineWidth',param.linewidth); hold off
                
                axis tight
                legend('data','bkg');
                legend('boxoff');
                set(hAXtab, 'XScale', 'log');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

        end

        set(hAXtab, 'FontSize', 15);
        set(hAXtab, 'FontName', 'times');

        drawnow();

        disp('Plot updated!');

    end

% ========================================================================
% Peak plot callback
    function PeakPlot_Callback(~,~)
        param.plotscale = scaleList{get(hScale,'Value')};
        param.linestyle = styleList{get(hLineStyle,'Value')};
        param.linecolor = colorList{get(hColorStyle,'Value')};
        param.linewidth = str2double(get(hLineWidth,'String'));

        param.xlimmin = str2double(get(XT.cXlim1,'String'));
        param.xlimmax = str2double(get(XT.cXlim2,'String'));

        param.ylimmin = str2double(get(XT.cYlim1,'String'));
        param.ylimmax = str2double(get(XT.cYlim2,'String'));    

        % check the number of checkbox for # of peaks 
        Nupc(1) = get(hUseP1,'Value');
        Nupc(2) = get(hUseP2,'Value');
        Nupc(3) = get(hUseP3,'Value');
        Nupc(4) = get(hUseP4,'Value');
        Nupc(5) = get(hUseP5,'Value');
        Nupc(6) = get(hUseP6,'Value');
        Nupc(7) = get(hUseP7,'Value');
        Nupc(8) = get(hUseP8,'Value');

        param.Npeaks = sum(Nupc(:));

        % define the X, Y
        xdata = find(param.Ang>=param.xlimmin & param.Ang<=param.xlimmax);

        X = param.Ang(xdata);
        Y = param.I(xdata);

        % Peaks
        if param.Npeaks == 1
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            param.P = [p1,p2,p3,p4];
        elseif param.Npeaks == 2
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            p5 = str2double(get(XT.Amp2,'String'));
            p6 = str2double(get(XT.Ratio2,'String'));
            p7 = str2double(get(XT.Cen2,'String'));
            p8 = str2double(get(XT.FWHM2,'String'));
            param.P = [p1,p2,p3,p4,p5,p6,p7,p8];
        elseif param.Npeaks == 3
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            p5 = str2double(get(XT.Amp2,'String'));
            p6 = str2double(get(XT.Ratio2,'String'));
            p7 = str2double(get(XT.Cen2,'String'));
            p8 = str2double(get(XT.FWHM2,'String'));
            p9 = str2double(get(XT.Amp3,'String'));
            p10 = str2double(get(XT.Ratio3,'String'));
            p11 = str2double(get(XT.Cen3,'String'));
            p12 = str2double(get(XT.FWHM3,'String'));
            param.P = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12];
        elseif param.Npeaks == 4
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            p5 = str2double(get(XT.Amp2,'String'));
            p6 = str2double(get(XT.Ratio2,'String'));
            p7 = str2double(get(XT.Cen2,'String'));
            p8 = str2double(get(XT.FWHM2,'String'));
            p9 = str2double(get(XT.Amp3,'String'));
            p10 = str2double(get(XT.Ratio3,'String'));
            p11 = str2double(get(XT.Cen3,'String'));
            p12 = str2double(get(XT.FWHM3,'String'));
            p13 = str2double(get(XT.Amp4,'String'));
            p14 = str2double(get(XT.Ratio4,'String'));
            p15 = str2double(get(XT.Cen4,'String'));
            p16 = str2double(get(XT.FWHM4,'String'));
            param.P = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16];
        elseif param.Npeaks == 5
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            p5 = str2double(get(XT.Amp2,'String'));
            p6 = str2double(get(XT.Ratio2,'String'));
            p7 = str2double(get(XT.Cen2,'String'));
            p8 = str2double(get(XT.FWHM2,'String'));
            p9 = str2double(get(XT.Amp3,'String'));
            p10 = str2double(get(XT.Ratio3,'String'));
            p11 = str2double(get(XT.Cen3,'String'));
            p12 = str2double(get(XT.FWHM3,'String'));
            p13 = str2double(get(XT.Amp4,'String'));
            p14 = str2double(get(XT.Ratio4,'String'));
            p15 = str2double(get(XT.Cen4,'String'));
            p16 = str2double(get(XT.FWHM4,'String'));
            p17 = str2double(get(XT.Amp5,'String'));
            p18 = str2double(get(XT.Ratio5,'String'));
            p19 = str2double(get(XT.Cen5,'String'));
            p20 = str2double(get(XT.FWHM5,'String'));
            param.P = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20];
        elseif param.Npeaks == 6
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            p5 = str2double(get(XT.Amp2,'String'));
            p6 = str2double(get(XT.Ratio2,'String'));
            p7 = str2double(get(XT.Cen2,'String'));
            p8 = str2double(get(XT.FWHM2,'String'));
            p9 = str2double(get(XT.Amp3,'String'));
            p10 = str2double(get(XT.Ratio3,'String'));
            p11 = str2double(get(XT.Cen3,'String'));
            p12 = str2double(get(XT.FWHM3,'String'));
            p13 = str2double(get(XT.Amp4,'String'));
            p14 = str2double(get(XT.Ratio4,'String'));
            p15 = str2double(get(XT.Cen4,'String'));
            p16 = str2double(get(XT.FWHM4,'String'));
            p17 = str2double(get(XT.Amp5,'String'));
            p18 = str2double(get(XT.Ratio5,'String'));
            p19 = str2double(get(XT.Cen5,'String'));
            p20 = str2double(get(XT.FWHM5,'String'));
            p21 = str2double(get(XT.Amp6,'String'));
            p22 = str2double(get(XT.Ratio6,'String'));
            p23 = str2double(get(XT.Cen6,'String'));
            p24 = str2double(get(XT.FWHM6,'String'));
            param.P = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24];
        elseif param.Npeaks == 7
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            p5 = str2double(get(XT.Amp2,'String'));
            p6 = str2double(get(XT.Ratio2,'String'));
            p7 = str2double(get(XT.Cen2,'String'));
            p8 = str2double(get(XT.FWHM2,'String'));
            p9 = str2double(get(XT.Amp3,'String'));
            p10 = str2double(get(XT.Ratio3,'String'));
            p11 = str2double(get(XT.Cen3,'String'));
            p12 = str2double(get(XT.FWHM3,'String'));
            p13 = str2double(get(XT.Amp4,'String'));
            p14 = str2double(get(XT.Ratio4,'String'));
            p15 = str2double(get(XT.Cen4,'String'));
            p16 = str2double(get(XT.FWHM4,'String'));
            p17 = str2double(get(XT.Amp5,'String'));
            p18 = str2double(get(XT.Ratio5,'String'));
            p19 = str2double(get(XT.Cen5,'String'));
            p20 = str2double(get(XT.FWHM5,'String'));
            p21 = str2double(get(XT.Amp6,'String'));
            p22 = str2double(get(XT.Ratio6,'String'));
            p23 = str2double(get(XT.Cen6,'String'));
            p24 = str2double(get(XT.FWHM6,'String'));
            p25 = str2double(get(XT.Amp7,'String'));
            p26 = str2double(get(XT.Ratio7,'String'));
            p27 = str2double(get(XT.Cen7,'String'));
            p28 = str2double(get(XT.FWHM7,'String'));
            param.P = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28];
        elseif param.Npeaks == 8
            p1 = str2double(get(XT.Amp1,'String'));
            p2 = str2double(get(XT.Ratio1,'String'));
            p3 = str2double(get(XT.Cen1,'String'));
            p4 = str2double(get(XT.FWHM1,'String'));
            p5 = str2double(get(XT.Amp2,'String'));
            p6 = str2double(get(XT.Ratio2,'String'));
            p7 = str2double(get(XT.Cen2,'String'));
            p8 = str2double(get(XT.FWHM2,'String'));
            p9 = str2double(get(XT.Amp3,'String'));
            p10 = str2double(get(XT.Ratio3,'String'));
            p11 = str2double(get(XT.Cen3,'String'));
            p12 = str2double(get(XT.FWHM3,'String'));
            p13 = str2double(get(XT.Amp4,'String'));
            p14 = str2double(get(XT.Ratio4,'String'));
            p15 = str2double(get(XT.Cen4,'String'));
            p16 = str2double(get(XT.FWHM4,'String'));
            p17 = str2double(get(XT.Amp5,'String'));
            p18 = str2double(get(XT.Ratio5,'String'));
            p19 = str2double(get(XT.Cen5,'String'));
            p20 = str2double(get(XT.FWHM5,'String'));
            p21 = str2double(get(XT.Amp6,'String'));
            p22 = str2double(get(XT.Ratio6,'String'));
            p23 = str2double(get(XT.Cen6,'String'));
            p24 = str2double(get(XT.FWHM6,'String'));
            p25 = str2double(get(XT.Amp7,'String'));
            p26 = str2double(get(XT.Ratio7,'String'));
            p27 = str2double(get(XT.Cen7,'String'));
            p28 = str2double(get(XT.FWHM7,'String'));
            p29 = str2double(get(XT.Amp8,'String'));
            p30 = str2double(get(XT.Ratio8,'String'));
            p31 = str2double(get(XT.Cen8,'String'));
            p32 = str2double(get(XT.FWHM8,'String'));
            param.P = [p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32];
        end

        totG = zeros(length(X),param.Npeaks);
        for ii = 1:param.Npeaks
            totG(:,ii) = pseudoVoigt(X,param.P(4*ii-3),param.P(4*ii-2),param.P(4*ii-1),param.P(4*ii));
        end

        % define the background
        bkgcolor = [0.6350 0.0780 0.1840];

        bkg = str2double(get(XT.BLinbkg,'String'));

        FY = sum(totG,2) + bkg;

        cla(hAXtab);
        axes(hAXtab);

        % plot the result
        colS = jet(param.Npeaks);
        switch param.plotscale
            case 'Linear'
                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); hold on
                for ii = 1:param.Npeaks
                    hold on
                    plot(X,totG(:,ii),'-','Color',colS(ii,:),'LineWidth',2);
                end
                yline(bkg,'-','Color',bkgcolor,'LineWidth',param.linewidth); hold on
                plot(X,FY,'--m','LineWidth',1); hold off   
                axis tight
                
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'linear');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

            case 'Logy'
                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); hold on
                for ii = 1:param.Npeaks
                    hold on
                    plot(X,totG(:,ii),'-','Color',colS(ii,:),'LineWidth',2);
                end
                yline(bkg,'-','Color',bkgcolor,'LineWidth',param.linewidth); hold on
                plot(X,FY,'--m','LineWidth',1); hold off
                axis tight
 
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

        end

        set(hAXtab, 'FontSize', 15);
        set(hAXtab, 'FontName', 'times');

        drawnow();

        disp('Plot updated!');

    end
% ========================================================================
% Auto Fit
    function AutoFit_Callback(~,~)
        param.plotscale = scaleList{get(hScale,'Value')};
        param.linestyle = styleList{get(hLineStyle,'Value')};
        param.linecolor = colorList{get(hColorStyle,'Value')};
        param.linewidth = str2double(get(hLineWidth,'String'));

        param.xlimmin = str2double(get(XT.cXlim1,'String'));
        param.xlimmax = str2double(get(XT.cXlim2,'String'));

        param.ylimmin = str2double(get(XT.cYlim1,'String'));
        param.ylimmax = str2double(get(XT.cYlim2,'String'));

        ExclOn = get(ExclOnOff,'Value'); % excluding Range On & Off

        % define the X, Y
        xdata = find(param.Ang>=param.xlimmin & param.Ang<=param.xlimmax);

        X = param.Ang(xdata);
        Y = param.I(xdata);

        x = X; % for fitting x axis
        y = Y; % for fitting y axis

        delp = find(isnan(y));
        x(delp) = [];
        y(delp) = [];

        bkgparam = str2double(get(XT.BLinbkg,'String'));

        initialparam = cat(2,param.P,bkgparam); % define the initial parameter

        if param.Npeaks == 1
            Eqn = fittype('PVFt1LB(x,p1,p2,p3,p4,p5)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5'});
        elseif param.Npeaks == 2
            Eqn = fittype('PVFt2LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5','p6','p7','p8','p9'});
        elseif param.Npeaks == 3
            Eqn = fittype('PVFt3LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5','p6','p7','p8','p9','p10','p11','p12','p13'});
        elseif param.Npeaks == 4
            Eqn = fittype('PVFt4LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5','p6','p7','p8','p9','p10','p11','p12','p13','p14','p15','p16','p17'});
        elseif param.Npeaks == 5
            Eqn = fittype('PVFt5LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5','p6','p7','p8','p9','p10','p11','p12','p13','p14','p15','p16','p17','p18','p19','p20','p21'});
        elseif param.Npeaks == 6
            Eqn = fittype('PVFt6LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5','p6','p7','p8','p9','p10','p11','p12','p13','p14','p15','p16','p17','p18','p19','p20','p21','p22','p23','p24','p25'});
        elseif param.Npeaks == 7
            Eqn = fittype('PVFt7exB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5','p6','p7','p8','p9','p10','p11','p12','p13','p14','p15','p16','p17','p18','p19','p20','p21','p22','p23','p24','p25','p26','p27','p28','p29','p30','p31'});
        elseif param.Npeaks == 8
            Eqn = fittype('PVFt8LB(x,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24,p25,p26,p27,p28,p29,p30,p31,p32,p33)',...
                'independent',{'x'},...
                'coefficients',{'p1','p2','p3','p4','p5','p6','p7','p8','p9','p10','p11','p12','p13','p14','p15','p16','p17','p18','p19','p20','p21','p22','p23','p24','p25','p26','p27','p28','p29','p30','p31','p32','p33'});
        end

        % Excluding range
        if ExclOn == 1
            Exclstr = get(hExclR,'String');
            Excl = str2num(Exclstr); % excluding range selection
            for ii = 1:(length(Excl)/2)
                excR = find(x>Excl(2*ii-1) & x<Excl(2*ii));
                if ii == 1
                    excT = excR;
                else
                    excT = cat(1,excT,excR);
                end
            end
            clear excR
        end

        BoundOn = get(hBoundary,'Value'); % Bound on & off
        if BoundOn == 1
            BR = str2double(get(hBoundR,'String'));
        end

        WeightOn = get(hWeight,'Value'); % Weight on & off
        if WeightOn == 1
            W = y.^2;
            W(isnan(W)) = 0;
        end

        if ExclOn == 0
            if BoundOn == 0
                if WeightOn == 0
                    IS = fit(x,y,Eqn,'Start',initialparam,'Robust','LAR');
                elseif WeightOn == 1
                    IS = fit(x,y,Eqn,'Start',initialparam,'Weight',W,'Robust','LAR');
                end
            elseif BoundOn == 1
                BoundVal = zeros(4*param.Npeaks,2);
                for ii = 1:param.Npeaks
                    BoundVal(4*ii-3,1) = 0;
                    BoundVal(4*ii-3,2) = inf;
                    BoundVal(4*ii-2,1) = 0;
                    BoundVal(4*ii-2,2) = 1;
                    if initialparam(4*ii-1) >= 0
                        BoundVal(4*ii-1,1) = initialparam(4*ii-1)-(initialparam(4*ii-1)*(10/100));
                        BoundVal(4*ii-1,2) = initialparam(4*ii-1)+(initialparam(4*ii-1)*(10/100));
                    else
                        BoundVal(4*ii-1,2) = initialparam(4*ii-1)-(initialparam(4*ii-1)*(10/100));
                        BoundVal(4*ii-1,1) = initialparam(4*ii-1)+(initialparam(4*ii-1)*(10/100));
                    end
                    BoundVal(4*ii,1) = initialparam(4*ii)-(initialparam(4*ii)*(BR/100));
                    BoundVal(4*ii,2) = initialparam(4*ii)+(initialparam(4*ii)*(BR/100));
                end
                % background
                BoundVal(4*param.Npeaks+1,1) = initialparam(4*param.Npeaks+1)-(initialparam(4*param.Npeaks+1)*0.05);
                BoundVal(4*param.Npeaks+1,2) = initialparam(4*param.Npeaks+1)+(initialparam(4*param.Npeaks+1)*0.05);

                if WeightOn == 0
                    IS = fit(x,y,Eqn,'Start',initialparam,'Lower',BoundVal(:,1),'Upper',BoundVal(:,2),'Robust','LAR');
                elseif WeightOn == 1
                    IS = fit(x,y,Eqn,'Start',initialparam,'Lower',BoundVal(:,1),'Upper',BoundVal(:,2),'Weight',W,'Robust','LAR');
                end

            end
        elseif ExclOn == 1
            if BoundOn == 0
                if WeightOn == 0
                    IS = fit(x,y,Eqn,'Start',initialparam,'Exclude',excT,'Robust','LAR');
                elseif WeightOn == 1
                    IS = fit(x,y,Eqn,'Start',initialparam,'Exclude',excT,'Weight',W,'Robust','LAR');
                end
            elseif BoundOn == 1
                BoundVal = zeros(4*param.Npeaks,2);
                for ii = 1:param.Npeaks
                    BoundVal(4*ii-3,1) = 0;
                    BoundVal(4*ii-3,2) = inf;
                    BoundVal(4*ii-2,1) = 0;
                    BoundVal(4*ii-2,2) = 1;
                    if initialparam(4*ii-1) >= 0
                        BoundVal(4*ii-1,1) = initialparam(4*ii-1)-(initialparam(4*ii-1)*(10/100));
                        BoundVal(4*ii-1,2) = initialparam(4*ii-1)+(initialparam(4*ii-1)*(10/100));
                    else
                        BoundVal(4*ii-1,2) = initialparam(4*ii-1)-(initialparam(4*ii-1)*(10/100));
                        BoundVal(4*ii-1,1) = initialparam(4*ii-1)+(initialparam(4*ii-1)*(10/100));
                    end
                    BoundVal(4*ii,1) = initialparam(4*ii)-(initialparam(4*ii)*(BR/100));
                    BoundVal(4*ii,2) = initialparam(4*ii)+(initialparam(4*ii)*(BR/100));
                end
                % background
                BoundVal(4*param.Npeaks+1,1) = initialparam(4*param.Npeaks+1)-(initialparam(4*param.Npeaks+1)*0.05);
                BoundVal(4*param.Npeaks+1,2) = initialparam(4*param.Npeaks+1)+(initialparam(4*param.Npeaks+1)*0.05);
                if WeightOn == 0
                    IS = fit(x,y,Eqn,'Start',initialparam,'Exclude',excT,'Lower',BoundVal(:,1),'Upper',BoundVal(:,2),'Robust','LAR');
                elseif WeightOn == 1
                    IS = fit(x,y,Eqn,'Start',initialparam,'Exclude',excT,'Lower',BoundVal(:,1),'Upper',BoundVal(:,2),'Weight',W,'Robust','LAR');
                end
            end
        end

        param.ISp = coeffvalues(IS);
        ISp_Err = confint(IS); % with 95% confidence bounds
        param.ISpErr = (abs(ISp_Err(1,:) - param.ISp) + abs(ISp_Err(2,:) - param.ISp))./2;

        PL = zeros(length(X),param.Npeaks);
        Area = zeros(param.Npeaks,1);
        for ii = 1:param.Npeaks
            a1 = param.ISp(4*ii-3);
            a2 = param.ISp(4*ii-2);
            a3 = param.ISp(4*ii-1);
            a4 = param.ISp(4*ii-0);
            PL(:,ii) = pseudoVoigt(X,a1,a2,a3,a4);
            Area(ii) = sum(PL(:,ii));
        end
        param.Area = Area;

        bkg = param.ISp(param.Npeaks*4+1);

        FY = sum(PL,2)+bkg;

        % Plot the autofit result
        colS = jet(param.Npeaks);
        bkgcolor = [0.6350 0.0780 0.1840];

        switch param.plotscale
            case 'Linear'
                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); hold on
                for ii = 1:param.Npeaks
                    plot(X,PL(:,ii),'-','Color',colS(ii,:),'LineWidth',param.linewidth);
                    hold on
                end
                yline(bkg,'-','Color',bkgcolor,'LineWidth',param.linewidth); hold on
                plot(X,FY,'--m','LineWidth',param.linewidth); hold off
                axis tight
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'linear');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

            case 'Logy'
                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); hold on
                for ii = 1:param.Npeaks
                    plot(X,PL(:,ii),'-','Color',colS(ii,:),'LineWidth',param.linewidth);
                    hold on
                end
                yline(bkg,'-','Color',bkgcolor,'LineWidth',param.linewidth); hold on
                plot(X,FY,'--m','LineWidth',param.linewidth); hold off
                axis tight
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

        end

        set(hAXtab, 'FontSize', 15);
        set(hAXtab, 'FontName', 'times');

        drawnow();

        disp('Plot updated!');

        % recall the fitting parameter
        if param.Npeaks == 1
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.BLinbkg.String = param.ISp(5);
        elseif param.Npeaks == 2
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.Amp2.String = param.ISp(5);
            XT.Ratio2.String = param.ISp(6);
            XT.Cen2.String = param.ISp(7);
            XT.FWHM2.String = param.ISp(8);
            XT.BLinbkg.String = param.ISp(9);
        elseif param.Npeaks == 3
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.Amp2.String = param.ISp(5);
            XT.Ratio2.String = param.ISp(6);
            XT.Cen2.String = param.ISp(7);
            XT.FWHM2.String = param.ISp(8);
            XT.Amp3.String = param.ISp(9);
            XT.Ratio3.String = param.ISp(10);
            XT.Cen3.String = param.ISp(11);
            XT.FWHM3.String = param.ISp(12);
            XT.BLinbkg.String = param.ISp(13);
        elseif param.Npeaks == 4
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.Amp2.String = param.ISp(5);
            XT.Ratio2.String = param.ISp(6);
            XT.Cen2.String = param.ISp(7);
            XT.FWHM2.String = param.ISp(8);
            XT.Amp3.String = param.ISp(9);
            XT.Ratio3.String = param.ISp(10);
            XT.Cen3.String = param.ISp(11);
            XT.FWHM3.String = param.ISp(12);
            XT.Amp4.String = param.ISp(13);
            XT.Ratio4.String = param.ISp(14);
            XT.Cen4.String = param.ISp(15);
            XT.FWHM4.String = param.ISp(16);
            XT.BLinbkg.String = param.ISp(17);
        elseif param.Npeaks == 5
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.Amp2.String = param.ISp(5);
            XT.Ratio2.String = param.ISp(6);
            XT.Cen2.String = param.ISp(7);
            XT.FWHM2.String = param.ISp(8);
            XT.Amp3.String = param.ISp(9);
            XT.Ratio3.String = param.ISp(10);
            XT.Cen3.String = param.ISp(11);
            XT.FWHM3.String = param.ISp(12);
            XT.Amp4.String = param.ISp(13);
            XT.Ratio4.String = param.ISp(14);
            XT.Cen4.String = param.ISp(15);
            XT.FWHM4.String = param.ISp(16);
            XT.Amp5.String = param.ISp(17);
            XT.Ratio5.String = param.ISp(18);
            XT.Cen5.String = param.ISp(19);
            XT.FWHM5.String = param.ISp(20);
            XT.BLinbkg.String = param.ISp(21);
        elseif param.Npeaks == 6
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.Amp2.String = param.ISp(5);
            XT.Ratio2.String = param.ISp(6);
            XT.Cen2.String = param.ISp(7);
            XT.FWHM2.String = param.ISp(8);
            XT.Amp3.String = param.ISp(9);
            XT.Ratio3.String = param.ISp(10);
            XT.Cen3.String = param.ISp(11);
            XT.FWHM3.String = param.ISp(12);
            XT.Amp4.String = param.ISp(13);
            XT.Ratio4.String = param.ISp(14);
            XT.Cen4.String = param.ISp(15);
            XT.FWHM4.String = param.ISp(16);
            XT.Amp5.String = param.ISp(17);
            XT.Ratio5.String = param.ISp(18);
            XT.Cen5.String = param.ISp(19);
            XT.FWHM5.String = param.ISp(20);
            XT.Amp6.String = param.ISp(21);
            XT.Ratio6.String = param.ISp(22);
            XT.Cen6.String = param.ISp(23);
            XT.FWHM6.String = param.ISp(24);
            XT.BLinbkg.String = param.ISp(25);
        elseif param.Npeaks == 7
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.Amp2.String = param.ISp(5);
            XT.Ratio2.String = param.ISp(6);
            XT.Cen2.String = param.ISp(7);
            XT.FWHM2.String = param.ISp(8);
            XT.Amp3.String = param.ISp(9);
            XT.Ratio3.String = param.ISp(10);
            XT.Cen3.String = param.ISp(11);
            XT.FWHM3.String = param.ISp(12);
            XT.Amp4.String = param.ISp(13);
            XT.Ratio4.String = param.ISp(14);
            XT.Cen4.String = param.ISp(15);
            XT.FWHM4.String = param.ISp(16);
            XT.Amp5.String = param.ISp(17);
            XT.Ratio5.String = param.ISp(18);
            XT.Cen5.String = param.ISp(19);
            XT.FWHM5.String = param.ISp(20);
            XT.Amp6.String = param.ISp(21);
            XT.Ratio6.String = param.ISp(22);
            XT.Cen6.String = param.ISp(23);
            XT.FWHM6.String = param.ISp(24);
            XT.Amp7.String = param.ISp(25);
            XT.Ratio7.String = param.ISp(26);
            XT.Cen7.String = param.ISp(27);
            XT.FWHM7.String = param.ISp(28);
            XT.BLinbkg.String = param.ISp(29);
        elseif param.Npeaks == 8
            XT.Amp1.String = param.ISp(1);
            XT.Ratio1.String = param.ISp(2);
            XT.Cen1.String = param.ISp(3);
            XT.FWHM1.String = param.ISp(4);
            XT.Amp2.String = param.ISp(5);
            XT.Ratio2.String = param.ISp(6);
            XT.Cen2.String = param.ISp(7);
            XT.FWHM2.String = param.ISp(8);
            XT.Amp3.String = param.ISp(9);
            XT.Ratio3.String = param.ISp(10);
            XT.Cen3.String = param.ISp(11);
            XT.FWHM3.String = param.ISp(12);
            XT.Amp4.String = param.ISp(13);
            XT.Ratio4.String = param.ISp(14);
            XT.Cen4.String = param.ISp(15);
            XT.FWHM4.String = param.ISp(16);
            XT.Amp5.String = param.ISp(17);
            XT.Ratio5.String = param.ISp(18);
            XT.Cen5.String = param.ISp(19);
            XT.FWHM5.String = param.ISp(20);
            XT.Amp6.String = param.ISp(21);
            XT.Ratio6.String = param.ISp(22);
            XT.Cen6.String = param.ISp(23);
            XT.FWHM6.String = param.ISp(24);
            XT.Amp7.String = param.ISp(25);
            XT.Ratio7.String = param.ISp(26);
            XT.Cen7.String = param.ISp(27);
            XT.FWHM7.String = param.ISp(28);
            XT.Amp8.String = param.ISp(29);
            XT.Ratio8.String = param.ISp(30);
            XT.Cen8.String = param.ISp(31);
            XT.FWHM8.String = param.ISp(32);
            XT.BLinbkg.String = param.ISp(33);
        end

    end
% ========================================================================
% Area Result function
    function AreaR_Callback(~,~)
        if isfield(param,'Area')
            AreaViewer(param)
        else
            msgbox('Please do fitting first!');
            return
        end
    end

% ========================================================================
% plot function
    function updatePlot
        param.plotscale = scaleList{get(hScale,'Value')};
        param.linestyle = styleList{get(hLineStyle,'Value')};
        param.linecolor = colorList{get(hColorStyle,'Value')};
        param.linewidth = str2double(get(hLineWidth,'String'));

        param.xlimmin = str2double(get(XT.cXlim1,'String'));
        param.xlimmax = str2double(get(XT.cXlim2,'String'));

        param.ylimmin = str2double(get(XT.cYlim1,'String'));
        param.ylimmax = str2double(get(XT.cYlim2,'String'));
 
        xdata = find(param.Ang>=param.xlimmin & param.Ang<=param.xlimmax);

        X = param.Ang(xdata);
        Y = param.I(xdata);

        cla(hAXtab);
        axes(hAXtab);

        switch param.plotscale
            case 'Linear'

                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); axis tight
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'linear');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

            case 'Logy'
                
                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); axis tight
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[param.xlimmin, param.xlimmax]);
                set(hAXtab, 'YLim',[param.ylimmin, param.ylimmax]);
                xlabel('Azimuthal, \Phi');
                ylabel('Intensity, arb. units');

        end
                        
        set(hAXtab, 'FontSize', 15);
        set(hAXtab, 'FontName', 'times');
        
        drawnow();

        disp('Plot updated!');
    end

% ========================================================================
% Update image
    function Updateplot_Callback(~,~)
            updatePlot;
    end

% ========================================================================
% Save plot and parameters
    function Savefile_Callback(~,~)
        filepathadd = ['/',param.FileName];
        filepath = fullfile(param.Path,filepathadd);
        mkdir(filepath);
        Fitname = param.Ptype;
        Fitparam = double(param.ISp);
        Fiterrparam = double(param.ISpErr);
        Fitarea = double(param.Area);
        SaveFile = [param.FileName,'_',Fitname,'_Fitresult.mat'];
        SaveFilepath = fullfile(filepath,SaveFile);
        save(SaveFilepath,'Fitparam','Fiterrparam','Fitarea');
        SaveFigure = [param.FileName,'_',Fitname,'_Fitresult.jpg'];
        SaveFigurepath = fullfile(filepath,SaveFigure);
        exportgraphics(Im2Dplot,SaveFigurepath);
    end



end % end of gui