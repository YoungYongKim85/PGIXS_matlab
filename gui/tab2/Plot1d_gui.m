function Plot1d_gui
clear
clc

main = figure('Name','1D Plot',...
    'NumberTitle','off','units',...
    'normalized','outerposition',[0.05 0.1 0.75 0.85]);

tgroup = uitabgroup('Parent', main);
tab1 = uitab('Parent', tgroup, 'Title', '1D Plot'); %tab for data analysis

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

% ========================================================================
% version
uicontrol('Parent',tab1,'Style','text',...
    'String','Designed By Y.Y.Kim 2022 (PLS-II BL3C)','Units','normalized',...
    'Position',[0.01 0.015 0.15 0.05]);

% ========================================================================
% Open data for tab1
uicontrol('Parent',leftPanelData,'String','Open data','Units','normalized',...
    'Position',[0.125 0.905 0.75 0.08],...
    'Callback',@Opendata_Callback);

% ========================================================================
% Iq2/q plot
uicontrol('Parent',leftPanelData,'String','Iq2/q','Units','normalized',...
    'Position',[0.125 0.85 0.37 0.05],...
    'Callback',@IQ2Q_Callback);

% ========================================================================
% Invariant
uicontrol('Parent',leftPanelData,'String','Invariant','Units','normalized',...
    'Position',[0.505 0.85 0.37 0.05],...
    'Callback',@Invariant_Callback);


% ========================================================================
% plot scale
uicontrol('Parent',ImageController,'Style','text',...
    'String','Plot Scale',...
    'Units','normalized','Position',[0.01 0.6 0.08 0.3]);

scaleList = {'Linear', 'Logy', 'Logxy'};
hScale = uicontrol('Parent',ImageController,'Style','popupmenu','Units','normalized',...
    'Position',[0.01 0.225 0.08 0.4],'String',scaleList,...
    'Callback',@Updateplot_Callback);

% ========================================================================
% plot line style
uicontrol('Parent',ImageController,'Style','text',...
    'String','Line Style',...
    'Units','normalized','Position',[0.11 0.6 0.08 0.3]);

styleList = {'-', '--', ':', '-.', 'o'};
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
    'String','1',...
    'Units','normalized','Position',[0.41 0.28 0.05 0.35],...
    'Callback',@Updateplot_Callback);

XT.cXlim2 = uicontrol('Parent',ImageController,'Style','edit',...
    'String','2000',...
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

    end

% ========================================================================
% plot function
    function updatePlot(~,~)

        param.plotscale = scaleList{get(hScale,'Value')};
        param.linestyle = styleList{get(hLineStyle,'Value')};
        param.linecolor = colorList{get(hColorStyle,'Value')};
        param.linewidth = str2double(get(hLineWidth,'String'));

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
    function IQ2Q_Callback(~,~)
        param.plotscale = scaleList{get(hScale,'Value')};
        param.linestyle = styleList{get(hLineStyle,'Value')};
        param.linecolor = colorList{get(hColorStyle,'Value')};
        param.linewidth = str2double(get(hLineWidth,'String'));

        xlimmin = str2double(get(XT.cXlim1,'String'));
        xlimmax = str2double(get(XT.cXlim2,'String'));

        ylimmin = str2double(get(XT.cYlim1,'String'));
        ylimmax = str2double(get(XT.cYlim2,'String'));
 
        xdata = find(param.Q>=xlimmin & param.Q<=xlimmax);

        X = param.Q(xdata);
        Y = param.I(xdata); Y = Y.*(X.^2);

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
                ylabel('Iq^{2}, arb. units');

            case 'Logy'
                
                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); axis tight
                set(hAXtab, 'XScale', 'linear');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[xlimmin, xlimmax]);
                set(hAXtab, 'YLim',[ylimmin, ylimmax]);
                xlabel('$q, \textrm{\AA}^{-1}$','Interpreter','latex','Fontname','TimesNewRoman');
                ylabel('Iq^{2}, arb. units');

            case 'Logxy'

                plot(X,Y,param.linestyle,'Color',param.linecolor,'LineWidth',param.linewidth); axis tight
                set(hAXtab, 'XScale', 'log');
                set(hAXtab, 'YScale', 'log');
                set(hAXtab, 'XLim',[xlimmin, xlimmax]);
                set(hAXtab, 'YLim',[ylimmin, ylimmax]);
                xlabel('$q, \textrm{\AA}^{-1}$','Interpreter','latex','Fontname','TimesNewRoman');
                ylabel('Iq^{2}, arb. units');

        end
                        
        set(hAXtab, 'FontSize', 15);
        set(hAXtab, 'FontName', 'times');
        
        drawnow();

        disp('Plot updated!');

    end

% ========================================================================
% Invariant
    function Invariant_Callback(~,~)
        xlimmin = str2double(get(XT.cXlim1,'String'));
        xlimmax = str2double(get(XT.cXlim2,'String'));

        xdata = find(param.Q>=xlimmin & param.Q<=xlimmax);

        X = param.Q(xdata);
        Y = param.I(xdata); Y = Y.*(X.^2);
        
        Y(Y == 0) = nan;
        Q = sum(Y,'omitnan');

        strQ = ['Invariant: ', num2str(Q)];
        msgbox(strQ);
    end


% ========================================================================
% Update image for tab1
    function Updateplot_Callback(~,~)
            updatePlot;
    end








end % End of gui