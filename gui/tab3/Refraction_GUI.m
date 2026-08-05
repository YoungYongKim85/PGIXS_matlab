function Refraction_GUI(param, hCritiA)
% Refraction Calculator GUI
% Updated to use 'refrac.m' for calculation

    % Main Figure
    Rmain = figure('Name','Refraction Calculator',...
        'NumberTitle','off','units','normalized',...
        'outerposition',[0.3 0.3 0.25 0.4]);

    coldf = [0.95 0.95 0.95];

    % Title
    uicontrol('Parent',Rmain,'Style','text',...
        'String','X-ray Refraction Calculator',...
        'FontSize',14,'FontWeight','bold',...
        'Units','normalized','Position',[0.05 0.85 0.9 0.1],...
        'BackgroundColor',coldf);

    % Input Panel
    InputP = uipanel('Parent',Rmain,'Title','Parameters','FontSize',10,...
        'Units','Normalized','Position',[0.05 0.45 0.9 0.35]);

    % Formula
    uicontrol('Parent',InputP,'Style','text','String','Formula:',...
        'Units','normalized','Position',[0.05 0.7 0.25 0.15]);
    hFormula = uicontrol('Parent',InputP,'Style','edit','String','SiO2',...
        'Units','normalized','Position',[0.35 0.7 0.55 0.15]);

    % Density
    uicontrol('Parent',InputP,'Style','text','String','Density (g/cm3):',...
        'Units','normalized','Position',[0.05 0.4 0.4 0.15]);
    hDensity = uicontrol('Parent',InputP,'Style','edit','String','2.65',...
        'Units','normalized','Position',[0.5 0.4 0.4 0.15]);

    % Energy
    uicontrol('Parent',InputP,'Style','text','String','Energy (keV):',...
        'Units','normalized','Position',[0.05 0.1 0.4 0.15]);
    hEnergy = uicontrol('Parent',InputP,'Style','edit',...
        'String',num2str(param.Energy),... % Use energy from main param
        'Units','normalized','Position',[0.5 0.1 0.4 0.15]);


    % Calculate Button
    uicontrol('Parent',Rmain,'String','Calculate',...
        'FontSize',12,'FontWeight','bold',...
        'Units','normalized','Position',[0.3 0.33 0.4 0.08],...
        'Callback',@Calculate_Callback);


    % Output Panel
    OutputP = uipanel('Parent',Rmain,'Title','Results','FontSize',10,...
        'Units','Normalized','Position',[0.05 0.02 0.9 0.28]);

    % Delta / Beta
    uicontrol('Parent',OutputP,'Style','text','String','Delta:',...
        'Units','normalized','Position',[0.05 0.7 0.2 0.2]);
    hDelta = uicontrol('Parent',OutputP,'Style','text','String','-',...
        'Units','normalized','Position',[0.25 0.7 0.25 0.2],...
        'BackgroundColor','white');

    uicontrol('Parent',OutputP,'Style','text','String','Beta:',...
        'Units','normalized','Position',[0.55 0.7 0.2 0.2]);
    hBeta = uicontrol('Parent',OutputP,'Style','text','String','-',...
        'Units','normalized','Position',[0.75 0.7 0.2 0.2],...
        'BackgroundColor','white');

    % Critical Angle
    uicontrol('Parent',OutputP,'Style','text','String','Crit. Ang (deg):',...
        'Units','normalized','Position',[0.05 0.4 0.4 0.2]);
    hCrit = uicontrol('Parent',OutputP,'Style','text','String','-',...
        'Units','normalized','Position',[0.5 0.4 0.4 0.2],...
        'BackgroundColor','white','ForegroundColor','red','FontWeight','bold');

    % Attenuation Length
    uicontrol('Parent',OutputP,'Style','text','String','Att. Len (um):',...
        'Units','normalized','Position',[0.05 0.1 0.4 0.2]);
    hAtt = uicontrol('Parent',OutputP,'Style','text','String','-',...
        'Units','normalized','Position',[0.5 0.1 0.4 0.2],...
        'BackgroundColor','white');


    % ====================================================================
    % Callback Function
    % ====================================================================
    function Calculate_Callback(~,~)
        % Get inputs
        Formula = get(hFormula,'String');
        Density = parsePGIXSNumeric(get(hDensity,'String'), NaN, eps, Inf);
        Energy = parsePGIXSNumeric(get(hEnergy,'String'), NaN, eps, Inf);

        if isnan(Density) || isnan(Energy)
            warndlg('Please check numeric inputs!','Error');
            return;
        end

        try
            R = refrac(Formula, Energy, Density);
            delta = R.dispersion(1);
            beta = R.absorption(1);
            crit_deg = R.criticalAngle(1);
            att_len_um = R.attLength(1) * 1e4;

            % Update GUI
            hDelta.String = sprintf('%.2e', delta);
            hBeta.String = sprintf('%.2e', beta);
            hCrit.String = sprintf('%.4f', crit_deg);
            hAtt.String = sprintf('%.2f', att_len_um);
            
            % Update Main GUI's Critical Angle Field
            if ~isempty(hCritiA) && isvalid(hCritiA)
                setCriticalAngleValue(hCritiA, crit_deg);
            end
            
        catch err
            errordlg(['Calculation Error: ' err.message], 'Error');
        end
    end

    function setCriticalAngleValue(hTarget, critDeg)
        if isprop(hTarget, 'Value')
            if isnumeric(hTarget.Value)
                hTarget.Value = critDeg;
            else
                hTarget.Value = sprintf('%.4f', critDeg);
            end
            return;
        end
        if isprop(hTarget, 'String')
            hTarget.String = sprintf('%.4f', critDeg);
        end
    end

end
