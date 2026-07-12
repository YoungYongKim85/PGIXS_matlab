% 1D plot
function OneDplotQlinegitab2_gui(param)

GUI.mainF = figure('Name','1D plot viewer',...
    'NumberTitle','off','units',...
    'normalized','outerposition',[0.4 0.15 0.4 0.6]);

centralPanelTransformation = uipanel('Parent',GUI.mainF,'Title','1D Plot Viewer','FontSize',...
    12,'Units','Normalized','Position',[0.1 0.1 .8 .875],'BackgroundColor',[1 1 1]);

hAX1 = axes('Parent',centralPanelTransformation,'Position',[0.1 0.15 0.85 0.75]);
hAX2 = axes('Parent',centralPanelTransformation,'Position',get(hAX1,'Position'));

%==========================================================================
%  plot unit
uicontrol('Parent',GUI.mainF,'Style','text',...
    'String','PixelOrQ',...
    'Units','normalized','Position',[0.035 0.05 0.1 0.05])    ;

PixQList = {'Pixel', 'Q', 'Alpha'};

hPixOrQ = uicontrol('Parent',GUI.mainF,'Style','popupmenu','Units','normalized',...
    'Position',[0.035 0.02 0.1 0.05],'String',PixQList,...
    'Callback',@Rangecal_Callback);

%==========================================================================
% plot scale
uicontrol('Parent',GUI.mainF,'Style','text',...
    'String','Plot Scale',...
    'Units','normalized','Position',[0.14 0.05 0.07 0.05]);

scaleList = {'Linear', 'Logy', 'Logxy'};
hScale = uicontrol('Parent',GUI.mainF,'Style','popupmenu','Units','normalized',...
    'Position',[0.14 0.02 0.07 0.05],'String',scaleList,...
    'Callback',@Updateplot_Callback);

%==========================================================================
% plot line style
uicontrol('Parent',GUI.mainF,'Style','text',...
    'String','Line Style',...
    'Units','normalized','Position',[0.215 0.05 0.07 0.05]);

styleList = {'-', '--', ':', '-.', '-o'};
hLineStyle = uicontrol('Parent',GUI.mainF,'Style','popupmenu','Units','normalized',...
    'Position',[0.215 0.02 0.07 0.05],'String',styleList,...
    'Callback',@Updateplot_Callback);

%==========================================================================
% plot line color
uicontrol('Parent',GUI.mainF,'Style','text',...
    'String','Line Color',...
    'Units','normalized','Position',[0.29 0.05 0.07 0.05]);

colorList = {'Black', 'Red', 'Green', 'Blue', 'Cyan', 'Magenta', 'Yellow'};
hColorStyle = uicontrol('Parent',GUI.mainF,'Style','popupmenu','Units','normalized',...
    'Position',[0.29 0.02 0.07 0.05],'String',colorList,...
    'Callback',@Updateplot_Callback);

%==========================================================================
% Q unit
uicontrol('Parent',GUI.mainF,'Style','text',...
    'String','Q unit',...
    'Units','normalized','Position',[0.365 0.05 0.07 0.05]);
unitList = {'A^{-1}', 'nm^{-1}'};
hQunit = uicontrol('Parent',GUI.mainF,'Style','popupmenu','Units','normalized',...
    'Position',[0.365 0.02 0.07 0.05],'String',unitList,...
    'Callback',@Updateplot_Callback);

%==========================================================================
% x-axis range
uicontrol('Parent',GUI.mainF,'Style','text',...
    'String','x-range',...
    'Units','normalized','Position',[0.455 0.05 0.07 0.05]);

GUI.xpixMin = uicontrol('Parent',GUI.mainF,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.44 0.03 0.05 0.04],...
    'Callback',@Updateplot_Callback);

GUI.xpixMax = uicontrol('Parent',GUI.mainF,'Style','edit',...
    'String','1000',...
    'Units','normalized','Position',[0.49 0.03 0.05 0.04],...
    'Callback',@Updateplot_Callback);

%==========================================================================
% y-range 
uicontrol('Parent',GUI.mainF,'Style','text',...
    'String','y-range',...
    'Units','normalized','Position',[0.575 0.05 0.07 0.05]);

GUI.yIMin = uicontrol('Parent',GUI.mainF,'Style','edit',...
    'String','1',...
    'Units','normalized','Position',[0.56 0.03 0.05 0.04],...
    'Callback',@Updateplot_Callback);

GUI.yIMax = uicontrol('Parent',GUI.mainF,'Style','edit',...
    'String','1000',...
    'Units','normalized','Position',[0.61 0.03 0.05 0.04],...
    'Callback',@Updateplot_Callback);

%==========================================================================
% plot grid on & off
hGridCheck = uicontrol('Parent',GUI.mainF,'Style','checkbox',...
    'String','Grid','Value',0,...
    'Units','normalized','Position',[0.7 0.034 0.07 0.05])    ;

%==========================================================================
% update plot
uicontrol('Parent',GUI.mainF,'String','Update Plot','FontSize',10,'Units','normalized',...
    'Position',[0.76 0.02 0.11 0.075],...
    'Callback',@Updateplot_Callback);

%==========================================================================
% save plot
uicontrol('Parent',GUI.mainF,'String','Save Plot','FontSize',10,'Units','normalized',...
    'Position',[0.875 0.02 0.11 0.075],...
    'Callback',@Saveplot_Callback);

%=========================================================================
inputparam.ang = param.ang;
inputparam.pixPlot = param.line1dang(:,1);
switch param.Mapping
    case {'Pixel', 'Qxy/Qz', 'Qy/Qz'}
        inputparam.Q1d = param.line1dang(:,2);
    case 'Alpha'
        inputparam.Theta1d = param.line1dang(:,2);
end
inputparam.data = param.line1dang(:,3);

inputparam.plotscale = scaleList{get(hScale,'Value')};
inputparam.linestyle = styleList{get(hLineStyle,'Value')};
inputparam.linecolor = colorList{get(hColorStyle,'Value')};
inputparam.grid = get(hGridCheck,'Value');

GUI.xpixMin.String = num2str(min(inputparam.pixPlot));
GUI.xpixMax.String = num2str(max(inputparam.pixPlot));

GUI.yIMin.String = num2str(min(inputparam.data,[],'omitnan'));
GUI.yIMax.String = num2str(max(inputparam.data,[],'omitnan'));

inputparam.xmin = str2double(get(GUI.xpixMin,'String'));
inputparam.xmax = str2double(get(GUI.xpixMax,'String'));

updatePlot;
%=========================================================================
% X Range calculation
    function Rangecal_Callback(~,~)
        PixOrQ = PixQList{get(hPixOrQ,'Value')};
        switch PixOrQ
            case 'Pixel'
                GUI.xpixMin.String = num2str(min(inputparam.pixPlot));
                GUI.xpixMax.String = num2str(max(inputparam.pixPlot));
                inputparam.xmin = str2double(get(GUI.xpixMin,'String'));
                inputparam.xmax = str2double(get(GUI.xpixMax,'String'));

                updatePlot;

            case 'Q'
                if isfield(inputparam,'Q1d')
                    GUI.xpixMin.String = num2str(min(inputparam.Q1d));
                    GUI.xpixMax.String = num2str(max(inputparam.Q1d));
                    inputparam.xmin = str2double(get(GUI.xpixMin,'String'));
                    inputparam.xmax = str2double(get(GUI.xpixMax,'String'));

                    updatePlot;
                else
                    error('Error. Please use Alpha format');
                end
            case 'Alpha'
                if isfield(inputparam,'Theta1d')
                    GUI.xpixMin.String = num2str(min(inputparam.Theta1d));
                    GUI.xpixMax.String = num2str(max(inputparam.Theta1d));
                    inputparam.xmin = str2double(get(GUI.xpixMin,'String'));
                    inputparam.xmax = str2double(get(GUI.xpixMax,'String'));

                    updatePlot;
                else
                    error('Error. Please use Q format');
                end
        end

    end

%=========================================================================
% plot function
    function updatePlot(~,~)

    PixOrQ = PixQList{get(hPixOrQ,'Value')};
    Qunit = unitList{get(hQunit,'Value')};
    inputparam.xmin = str2double(get(GUI.xpixMin,'String'));
    inputparam.xmax = str2double(get(GUI.xpixMax,'String'));

    ylimmin = str2double(get(GUI.yIMin,'String'));
    ylimmax = str2double(get(GUI.yIMax,'String'));

    switch PixOrQ
        case 'Pixel/Intensity'
            cla(hAX1);
            axes(hAX1);

            xdata = find(inputparam.pixPlot>=inputparam.xmin & inputparam.pixPlot<=inputparam.xmax);
           
            X = inputparam.pixPlot(xdata);
            Y = inputparam.data(xdata);

            switch inputparam.plotscale
                case 'Linear'
                    plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight

                    set(hAX1, 'YScale', 'linear', 'Ylim', [ylimmin, ylimmax]);
                    ylabel('Intensity, arb. unit');
                    set(hAX1.Children, 'XData',X);
                    set(hAX1, 'box', 'off', ...
                        'Position', get(hAX1, 'Position'), ...
                        'xScale', 'lin', ...
                        'color', 'none');
                    xlabel('Pixel');

                    hold on
                    % transform Q ticks to full period resolution in [A]
                    clear xTicksHalfPeriod
                    pause(0.1) % needed to get figure right, nasty matlab bug
                    xTicksHalfPeriod = get(hAX1, 'XTick');
                    pause(0.1) % needed to get figure right, nasty matlab bug

                    % create upper x-axis for half peridod labels
                    cla(hAX2);
                    axes(hAX2);

                    % style the upper x-axis
                    set(hAX2, ...
                        'xAxisLocation', 'top', ...
                        'yAxisLocation', 'right', ...
                        'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                        'color', 'none', ...
                        'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                        'xLim', get(hAX1, 'xLim'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'yLim', get(hAX1, 'yLim'), ...
                        'yScale', get(hAX1, 'yScale') ...
                        );
                    set(hAX2,'YTickLabel',[]);
                    xlabel('Pixel');

                 case 'Logy'
                    plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight
                    set(hAX1, 'YScale', 'log', 'Ylim', [ylimmin, ylimmax]);
                    ylabel('Intensity, arb. unit');
                    set(hAX1.Children, 'XData',X);
                    set(hAX1, 'box', 'off', ...
                        'Position', get(hAX1, 'Position'), ...
                        'xScale', 'lin', ...
                        'color', 'none');   
                    xlabel('Pixel');

                    hold on
                    % transform Q ticks to full period resolution in [A]
                    clear xTicksHalfPeriod
                    pause(0.1) % needed to get figure right, nasty matlab bug
                    xTicksHalfPeriod = get(hAX1, 'XTick');
                    pause(0.1) % needed to get figure right, nasty matlab bug

                    % create upper x-axis for half peridod labels
                    cla(hAX2);
                    axes(hAX2);

                    % style the upper x-axis
                    set(hAX2, ...
                        'xAxisLocation', 'top', ...
                        'yAxisLocation', 'right', ...
                        'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                        'color', 'none', ...
                        'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                        'xLim', get(hAX1, 'xLim'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'yLim', get(hAX1, 'yLim'), ...
                        'yScale', get(hAX1, 'yScale') ...
                        );
                    set(hAX2,'YTickLabel',[]);
                    xlabel('Pixel');

                case 'Logxy'
                    plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight
                    set(hAX1, 'YScale', 'log', 'Ylim', [ylimmin, ylimmax]);
                    ylabel('Intensity, arb. unit');
                    set(hAX1.Children, 'XData',X);
                    set(hAX1, 'box', 'off', ...
                        'Position', get(hAX1, 'Position'), ...
                        'xScale', 'log', ...
                        'color', 'none');   
                    xlabel('Pixel');

                    hold on
                    % transform Q ticks to full period resolution in [A]
                    clear xTicksHalfPeriod
                    pause(0.1) % needed to get figure right, nasty matlab bug
                    xTicksHalfPeriod = get(hAX1, 'XTick');
                    pause(0.1) % needed to get figure right, nasty matlab bug

                    % create upper x-axis for half peridod labels
                    cla(hAX2);
                    axes(hAX2);

                    % style the upper x-axis
                    set(hAX2, ...
                        'xAxisLocation', 'top', ...
                        'yAxisLocation', 'right', ...
                        'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                        'color', 'none', ...
                        'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                        'xLim', get(hAX1, 'xLim'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'yLim', get(hAX1, 'yLim'), ...
                        'yScale', get(hAX1, 'yScale') ...
                        );
                    set(hAX2,'YTickLabel',[]);
                    xlabel('Pixel');

            end
            axes(hAX1);
            linkaxes([hAX1 hAX2]);

        case 'Q/Intensity'

            switch Qunit
                case 'A^{-1}'
                    Qval = inputparam.Q1d;
                case 'nm^{-1}'
                    Qval = inputparam.Q1d.*10;
            end
            
           xdata = find(inputparam.Q1d>=inputparam.xmin & inputparam.Q1d<=inputparam.xmax);
           
            X = Qval(xdata);
            Y = inputparam.data(xdata);

            cla(hAX1);
            axes(hAX1);

            switch inputparam.plotscale
                case 'Linear'
                    plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight

                    set(hAX1, 'YScale', 'linear', 'Ylim', [ylimmin, ylimmax]);
                    ylabel('Intensity, arb. unit');
                    set(hAX1.Children, 'XData',X);
                    set(hAX1, 'box', 'off', ...
                        'Position', get(hAX1, 'Position'), ...
                        'xScale', 'lin', ...
                        'color', 'none');

                    switch Qunit
                        case 'A^{-1}'
                            if param.ang == 0 || param.ang == 180
                                switch param.QMapMet
                                    case 'Qxy/Qz'
                                        xlabel('Q_{xy}, A^{-1}');
                                    case 'Qy/Qz'
                                        xlabel('Q_{y}, A^{-1}');
                                end
                            elseif param.ang == 90 || param.ang == 180
                                xlabel('Q_{z}, A^{-1}');
                            else
                                xlabel('Q, A^{-1}');
                            end
                        case 'nm^{-1}'
                            if param.ang == 0 || param.ang == 180
                                switch param.QMapMet
                                    case 'Qxy/Qz'
                                        xlabel('Q_{xy}, nm^{-1}');
                                    case 'Qy/Qz'
                                        xlabel('Q_{y}, nm^{-1}');
                                end
                            elseif param.ang == 90 || param.ang == 180
                                xlabel('Q_{z}, nm^{-1}');
                            else
                                xlabel('Q, nm^{-1}');
                            end
                    end
                    hold on
                    % transform Q ticks to full period resolution in [A]
                    clear xTicksHalfPeriod
                    pause(0.1) % needed to get figure right, nasty matlab bug
                    xTicksHalfPeriod = 2*pi./(get(hAX1, 'XTick'));
                    pause(0.1) % needed to get figure right, nasty matlab bug

                    % create upper x-axis for half peridod labels
                    cla(hAX2);
                    axes(hAX2);

                    % style the upper x-axis
                    set(hAX2, ...
                        'xAxisLocation', 'top', ...
                        'yAxisLocation', 'right', ...
                        'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                        'color', 'none', ...
                        'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                        'xLim', get(hAX1, 'xLim'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'yLim', get(hAX1, 'yLim'), ...
                        'yScale', get(hAX1, 'yScale') ...
                        );
                    set(hAX2,'YTickLabel',[]);

                    switch Qunit
                        case 'A^{-1}'
                            xlabel('A');
                        case 'nm^{-1}'
                            xlabel('nm');
                    end

                case 'Logy'
                    plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight
                    set(hAX1, 'YScale', 'log', 'Ylim', [ylimmin, ylimmax]);
                    ylabel('Intensity, arb. unit');
                    set(hAX1.Children, 'XData',X);
                    set(hAX1, 'box', 'off', ...
                        'Position', get(hAX1, 'Position'), ...
                        'xScale', 'lin', ...
                        'color', 'none');

                    switch Qunit
                        case 'A^{-1}'
                            if param.ang == 0 || param.ang == 180
                                switch param.QMapMet
                                    case 'Qxy/Qz'
                                        xlabel('Q_{xy}, A^{-1}');
                                    case 'Qy/Qz'
                                        xlabel('Q_{y}, A^{-1}');
                                end
                            elseif param.ang == 90 || param.ang == 180
                                xlabel('Q_{z}, A^{-1}');
                            else
                                xlabel('Q, A^{-1}');
                            end
                        case 'nm^{-1}'
                            if param.ang == 0 || param.ang == 180
                                switch param.QMapMet
                                    case 'Qxy/Qz'
                                        xlabel('Q_{xy}, nm^{-1}');
                                    case 'Qy/Qz'
                                        xlabel('Q_{y}, nm^{-1}');
                                end
                            elseif param.ang == 90 || param.ang == 180
                                xlabel('Q_{z}, nm^{-1}');
                            else
                                xlabel('Q, nm^{-1}');
                            end
                    end
                    hold on
                    % transform Q ticks to full period resolution in [nm]
                    clear xTicksHalfPeriod
                    pause(0.1) % needed to get figure right, nasty matlab bug
                    xTicksHalfPeriod = 2*pi./(get(hAX1, 'XTick'));
                    pause(0.1) % needed to get figure right, nasty matlab bug

                    % create upper x-axis for half peridod labels
                    cla(hAX2);
                    axes(hAX2);

                    % style the upper x-axis
                    set(hAX2, ...
                        'xAxisLocation', 'top', ...
                        'yAxisLocation', 'right', ...
                        'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                        'color', 'none', ...
                        'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                        'xLim', get(hAX1, 'xLim'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'yLim', get(hAX1, 'yLim'), ...
                        'yScale', get(hAX1, 'yScale') ...
                        );
                    set(hAX2,'YTickLabel',[]);

                    switch Qunit
                        case 'A^{-1}'
                            xlabel('A');
                        case 'nm^{-1}'
                            xlabel('nm');
                    end

                case 'Logxy'
                    plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight
                    set(hAX1, 'YScale', 'log', 'Ylim', [ylimmin, ylimmax]);
                    ylabel('Intensity, arb. unit');
                    set(hAX1.Children, 'XData',X);
                    set(hAX1, 'box', 'off', ...
                        'Position', get(hAX1, 'Position'), ...
                        'xScale', 'log', ...
                        'color', 'none');

                    switch Qunit
                        case 'A^{-1}'
                            if param.ang == 0 || param.ang == 180
                                switch param.QMapMet
                                    case 'Qxy/Qz'
                                        xlabel('Q_{xy}, A^{-1}');
                                    case 'Qy/Qz'
                                        xlabel('Q_{y}, A^{-1}');
                                end
                            elseif param.ang == 90 || param.ang == 180
                                xlabel('Q_{z}, A^{-1}');
                            else
                                xlabel('Q, A^{-1}');
                            end
                        case 'nm^{-1}'
                            if param.ang == 0 || param.ang == 180
                                switch param.QMapMet
                                    case 'Qxy/Qz'
                                        xlabel('Q_{xy}, nm^{-1}');
                                    case 'Qy/Qz'
                                        xlabel('Q_{y}, nm^{-1}');
                                end
                            elseif param.ang == 90 || param.ang == 180
                                xlabel('Q_{z}, nm^{-1}');
                            else
                                xlabel('Q, nm^{-1}');
                            end
                    end
                    hold on
                    % transform Q ticks to full period resolution in [nm]
                    clear xTicksHalfPeriod
                    pause(0.1) % needed to get figure right, nasty matlab bug
                    xTicksHalfPeriod = 2*pi./(get(hAX1, 'XTick'));
                    pause(0.1) % needed to get figure right, nasty matlab bug

                    % create upper x-axis for half peridod labels
                    cla(hAX2);
                    axes(hAX2);

                    % style the upper x-axis
                    set(hAX2, ...
                        'xAxisLocation', 'top', ...
                        'yAxisLocation', 'right', ...
                        'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                        'color', 'none', ...
                        'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                        'xLim', get(hAX1, 'xLim'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'xScale', get(hAX1, 'xScale'), ...
                        'yLim', get(hAX1, 'yLim'), ...
                        'yScale', get(hAX1, 'yScale') ...
                        );
                    set(hAX2,'YTickLabel',[]);

                    switch Qunit
                        case 'A^{-1}'
                            xlabel('A');
                        case 'nm^{-1}'
                            xlabel('nm');
                    end

            end
            axes(hAX1);
            linkaxes([hAX1 hAX2]);

            case 'Alpha'
                    
                Thetaval = inputparam.Theta1d;
                       
                xdata = find(inputparam.Theta1d>=inputparam.xmin & inputparam.Theta1d<=inputparam.xmax);

                X = Thetaval(xdata);
                Y = inputparam.data(xdata);

                cla(hAX1);
                axes(hAX1);

                switch inputparam.plotscale
                    case 'Linear'
                        plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight

                        set(hAX1, 'YScale', 'linear', 'Ylim', [ylimmin, ylimmax]);
                        ylabel('Intensity, arb. unit');
                        set(hAX1.Children, 'XData',X);
                        set(hAX1, 'box', 'off', ...
                            'Position', get(hAX1, 'Position'), ...
                            'xScale', 'lin', ...
                            'color', 'none');
                        
                        if param.ang == 0 || param.ang == 180
                            xlabel('2\theta_{f}, deg');
                        elseif param.ang == 90
                            xlabel('\alpha_{f}, deg');
                        end

                        hold on
                        % transform Q ticks to full period resolution in [A]
                        clear xTicksHalfPeriod
                        pause(0.1) % needed to get figure right, nasty matlab bug                      
                        xTicksHalfPeriod = param.Wavelength./(2.*sind(get(hAX1, 'XTick')./2));
                        pause(0.1) % needed to get figure right, nasty matlab bug

                        % create upper x-axis for half peridod labels
                        cla(hAX2);
                        axes(hAX2);

                        % style the upper x-axis
                        set(hAX2, ...
                            'xAxisLocation', 'top', ...
                            'yAxisLocation', 'right', ...
                            'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                            'color', 'none', ...
                            'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                            'xLim', get(hAX1, 'xLim'), ...
                            'xScale', get(hAX1, 'xScale'), ...
                            'xScale', get(hAX1, 'xScale'), ...
                            'yLim', get(hAX1, 'yLim'), ...
                            'yScale', get(hAX1, 'yScale') ...
                            );
                        set(hAX2,'YTickLabel',[]);
                        xlabel('A');
  
                    case 'Logy'
                        plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight

                        set(hAX1, 'YScale', 'log', 'Ylim', [ylimmin, ylimmax]);
                        ylabel('Intensity, arb. unit');
                        set(hAX1.Children, 'XData',X);
                        set(hAX1, 'box', 'off', ...
                            'Position', get(hAX1, 'Position'), ...
                            'xScale', 'lin', ...
                            'color', 'none');
                        
                        if param.ang == 0 || param.ang == 180
                            xlabel('2\theta_{f}, deg');
                        elseif param.ang == 90
                            xlabel('\alpha_{f}, deg');
                        end

                        hold on
                        % transform Q ticks to full period resolution in [A]
                        clear xTicksHalfPeriod
                        pause(0.1) % needed to get figure right, nasty matlab bug                      
                        xTicksHalfPeriod = param.Wavelength./(2.*sind(get(hAX1, 'XTick')./2));
                        pause(0.1) % needed to get figure right, nasty matlab bug

                        % create upper x-axis for half peridod labels
                        cla(hAX2);
                        axes(hAX2);

                        % style the upper x-axis
                        set(hAX2, ...
                            'xAxisLocation', 'top', ...
                            'yAxisLocation', 'right', ...
                            'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                            'color', 'none', ...
                            'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                            'xLim', get(hAX1, 'xLim'), ...
                            'xScale', get(hAX1, 'xScale'), ...
                            'xScale', get(hAX1, 'xScale'), ...
                            'yLim', get(hAX1, 'yLim'), ...
                            'yScale', get(hAX1, 'yScale') ...
                            );
                        set(hAX2,'YTickLabel',[]);

                        xlabel('A');
                
                    case 'Logxy'
                        plot(hAX1,Y,inputparam.linestyle,'Color',inputparam.linecolor,'LineWidth',2); axis tight

                        set(hAX1, 'YScale', 'log', 'Ylim', [ylimmin, ylimmax]);
                        ylabel('Intensity, arb. unit');
                        set(hAX1.Children, 'XData',X);
                        set(hAX1, 'box', 'off', ...
                            'Position', get(hAX1, 'Position'), ...
                            'xScale', 'log', ...
                            'color', 'none');
                        
                        if param.ang == 0 || param.ang == 180
                            xlabel('2\theta_{f}, deg');
                        elseif param.ang == 90
                            xlabel('\alpha_{f}, deg');
                        end

                        hold on
                        % transform Q ticks to full period resolution in [A]
                        clear xTicksHalfPeriod
                        pause(0.1) % needed to get figure right, nasty matlab bug                      
                        xTicksHalfPeriod = param.Wavelength./(2.*sind(get(hAX1, 'XTick')./2));
                        pause(0.1) % needed to get figure right, nasty matlab bug

                        % create upper x-axis for half peridod labels
                        cla(hAX2);
                        axes(hAX2);

                        % style the upper x-axis
                        set(hAX2, ...
                            'xAxisLocation', 'top', ...
                            'yAxisLocation', 'right', ...
                            'PlotBoxAspectRatio', get(hAX1, 'PlotBoxAspectRatio'), ...
                            'color', 'none', ...
                            'XTickLabel', num2str(xTicksHalfPeriod',3), ...
                            'xLim', get(hAX1, 'xLim'), ...
                            'xScale', get(hAX1, 'xScale'), ...
                            'xScale', get(hAX1, 'xScale'), ...
                            'yLim', get(hAX1, 'yLim'), ...
                            'yScale', get(hAX1, 'yScale') ...
                            );
                        set(hAX2,'YTickLabel',[]);

                        xlabel('A');
                end
                
       
        axes(hAX1);
        linkaxes([hAX1 hAX2]);




    end

    set(gca, 'FontSize', 13);

    if inputparam.grid == 0
        grid off
    else
        grid on
    end

    drawnow();

    disp('Plot updated!');
    end

%=========================================================================
% plot update
    function Updateplot_Callback(~,~)
        inputparam.plotscale = scaleList{get(hScale,'Value')};
        inputparam.linestyle = styleList{get(hLineStyle,'Value')};
        inputparam.linecolor = colorList{get(hColorStyle,'Value')};
        inputparam.grid = get(hGridCheck,'Value');
        updatePlot;

    end

%=========================================================================
% save plot and file
    function Saveplot_Callback(~,~)
        PixOrQ = PixQList{get(hPixOrQ,'Value')};
        switch PixOrQ
            case {'Pixel', 'Q'} 
                data(:,1) =  inputparam.Q1d;
                data(:,2) = inputparam.data;
                data(isnan(data)) = 0;
                filepathadd = ['/',param.FileName];
                filepath = fullfile(param.Path,filepathadd);
                mkdir(filepath);
                AngleValue = num2str(param.ang);
                SaveFile = [param.FileName,'_',AngleValue,'degree_Q.mat'];
                SaveFilepath = fullfile(filepath,SaveFile);
                save(SaveFilepath,'data');
                SaveFile = [param.FileName,'_',AngleValue,'degree_Q.sdt'];
                SaveFilepath = fullfile(filepath,SaveFile);
                save(SaveFilepath,'data','-ascii');
                SaveFigure = [param.FileName,'_',AngleValue,'degreeplot_Q.jpg'];
                SaveFigurepath = fullfile(filepath,SaveFigure);
                exportgraphics(centralPanelTransformation,SaveFigurepath);
                disp('Save is done!')
            
            case 'Alpha'
                data(:,1) =  inputparam.Theta1d;
                data(:,2) = inputparam.data;
                data(isnan(data)) = 0;
                filepathadd = ['/',param.FileName];
                filepath = fullfile(param.Path,filepathadd);
                mkdir(filepath);
                AngleValue = num2str(param.ang);
                SaveFile = [param.FileName,'_',AngleValue,'degree_Alpha.mat'];
                SaveFilepath = fullfile(filepath,SaveFile);
                save(SaveFilepath,'data');
                SaveFile = [param.FileName,'_',AngleValue,'degree_Alpha.sdt'];
                SaveFilepath = fullfile(filepath,SaveFile);
                save(SaveFilepath,'data','-ascii');
                SaveFigure = [param.FileName,'_',AngleValue,'degreeplot_Alpha.jpg'];
                SaveFigurepath = fullfile(filepath,SaveFigure);
                exportgraphics(centralPanelTransformation,SaveFigurepath);
                disp('Save is done!')
        
        end
    end

end % end of gui