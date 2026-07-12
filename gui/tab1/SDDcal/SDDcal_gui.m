function SDDcal_gui
% SDDcal_Unified_v2.0 - Sample to Detector Distance Calculator
% Feature: Modern UI + HDF5 Auto-Finder + External 1D GUI Link

clc;

% ============================ GUI Setup (v2.0 Modern UI) =================
GUI.main = uifigure('Name','SDD Calculator v2.0 (Interactive Dashboard)',...
    'NumberTitle','off',...
    'Position', [100 100 1250 850],...
    'Color', [0.96 0.96 0.96]);

movegui(GUI.main, 'center');

% ============================ Main Layout (Grid) =========================
mainGrid = uigridlayout(GUI.main, [1 2]);
mainGrid.ColumnWidth = {380, '1x'}; 
mainGrid.Padding = [10 10 10 10];
mainGrid.ColumnSpacing = 15;

leftPanel = uipanel(mainGrid, 'Title', 'Control & Parameters', 'FontSize', 14, 'FontWeight', 'bold');
leftPanel.Layout.Row = 1; leftPanel.Layout.Column = 1;

rightGrid = uigridlayout(mainGrid, [2 1]);
rightGrid.RowHeight = {'2x', '1x'}; 
rightGrid.Layout.Row = 1; rightGrid.Layout.Column = 2;
rightGrid.Padding = [0 0 0 0];

panel2D = uipanel(rightGrid, 'Title', '2D Image Mapping', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w');
panel2D.Layout.Row = 1; panel2D.Layout.Column = 1;
grid2D = uigridlayout(panel2D, [1 1]); grid2D.Padding = [5 5 5 5];
hAX = uiaxes(grid2D); 

panel1D = uipanel(rightGrid, 'Title', '1D Profile Dashboard (Real-time View)', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w');
panel1D.Layout.Row = 2; panel1D.Layout.Column = 1;
grid1D = uigridlayout(panel1D, [1 1]); grid1D.Padding = [5 5 5 5];
hAX1D = uiaxes(grid1D); 

% ============================ List Definitions ===========================
detectorList = {'Eiger4M', 'MarCCD', 'MX170HS', 'PI-CCD', 'MAR345'};
STD_List = {'SEBS', 'Silver behenate', 'Mesoporous Silica',  'Sucrose'};
scaleList = {'Linear', 'Log'};
ColormapList = {'parula','hot','gray','jet','turbo','inferno','viridis',...
    'cubehelix','magma','kindlemann','ocean','jet2','rwb','rkb'};
Order_List = {'1st', '2nd', '3rd', '4th', '5th', '6th', '7th'}; 

% ============================ Left Panel UI Controls =====================
lg = uigridlayout(leftPanel, [22, 4]);
lg.RowHeight = repmat({25}, 1, 22);
lg.RowHeight{4} = 40;  
lg.RowHeight{15} = 45; 
lg.RowHeight{18} = 35; 
lg.ColumnWidth = {'1x', '1x', '1x', '1x'};
lg.Padding = [10 10 10 10];
lg.RowSpacing = 8;

% --- 1. Directory ---
lbl1 = uilabel(lg, 'Text', 'Directory');
lbl1.Layout.Row = 1; lbl1.Layout.Column = [1 4];

GUI.pathset = uieditfield(lg, 'text', 'Value', pwd);
GUI.pathset.Layout.Row = 2; GUI.pathset.Layout.Column = [1 3];

btn_set = uibutton(lg, 'Text', 'Set', 'ButtonPushedFcn', @pathset_Callback);
btn_set.Layout.Row = 2; btn_set.Layout.Column = 4;

% --- 2. Detector ---
lbl2 = uilabel(lg, 'Text', 'Detector Type');
lbl2.Layout.Row = 3; lbl2.Layout.Column = [1 2];

hDetector = uidropdown(lg, 'Items', detectorList);
hDetector.Layout.Row = 3; hDetector.Layout.Column = [3 4];

% --- 3. Load Button ---
btn_load = uibutton(lg, 'Text', 'Load Image Data', 'FontWeight', 'bold', 'FontSize', 14, 'ButtonPushedFcn', @Openimage_Callback);
btn_load.Layout.Row = 4; btn_load.Layout.Column = [1 4];

% --- 4. Sample & Energy ---
lbl3 = uilabel(lg, 'Text', 'Standard Sample');
lbl3.Layout.Row = 6; lbl3.Layout.Column = [1 2];

hStandard = uidropdown(lg, 'Items', STD_List);
hStandard.Layout.Row = 6; hStandard.Layout.Column = [3 4];

lbl4 = uilabel(lg, 'Text', 'Photon Energy [keV]');
lbl4.Layout.Row = 7; lbl4.Layout.Column = [1 2];

hEnergy = uieditfield(lg, 'numeric', 'Value', 9.5);
hEnergy.Layout.Row = 7; hEnergy.Layout.Column = [3 4];

% --- 5. Manual Calibration ---
lbl5 = uilabel(lg, 'Text', '--- Manual Calibration ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
lbl5.Layout.Row = 9; lbl5.Layout.Column = [1 4];

lbl6 = uilabel(lg, 'Text', 'Center [Y, Z]');
lbl6.Layout.Row = 10; lbl6.Layout.Column = [1 2];

hYpos = uieditfield(lg, 'numeric', 'Value', 1000);
hYpos.Layout.Row = 10; hYpos.Layout.Column = 3;
hZpos = uieditfield(lg, 'numeric', 'Value', 1000);
hZpos.Layout.Row = 10; hZpos.Layout.Column = 4;

btn_setc = uibutton(lg, 'Text', 'Set C', 'ButtonPushedFcn', @Center_Callback);
btn_setc.Layout.Row = 11; btn_setc.Layout.Column = [1 2];

btn_mark = uibutton(lg, 'Text', 'Mark', 'ButtonPushedFcn', @Marking_Callback);
btn_mark.Layout.Row = 11; btn_mark.Layout.Column = [3 4];

% [변경] 외부 GUI 연동을 위한 버튼 재배치
btn_yplot = uibutton(lg, 'Text', 'Y_Plot (Fit)', 'ButtonPushedFcn', @Yplot_Callback);
btn_yplot.Layout.Row = 12; btn_yplot.Layout.Column = [1 2];

btn_zplot = uibutton(lg, 'Text', 'Z_Plot (Fit)', 'ButtonPushedFcn', @Zplot_Callback);
btn_zplot.Layout.Row = 12; btn_zplot.Layout.Column = [3 4];

btn_rad = uibutton(lg, 'Text', 'Rad.Ave (Fit)', 'ButtonPushedFcn', @CircularAve_Callback);
btn_rad.Layout.Row = 13; btn_rad.Layout.Column = [1 4];

% --- 6. Smart Auto Calibration ---
lbl7 = uilabel(lg, 'Text', '--- Smart Auto Calibration ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
lbl7.Layout.Row = 14; lbl7.Layout.Column = [1 4];

btn_auto = uibutton(lg, 'Text', 'SMART AUTO RUN', 'FontWeight', 'bold', 'FontSize', 14, 'FontColor', 'w', 'BackgroundColor', [0.8 0.2 0.2], 'ButtonPushedFcn', @AutoRun_Callback);
btn_auto.Layout.Row = 15; btn_auto.Layout.Column = [1 4];

lbl8 = uilabel(lg, 'Text', 'Order / Pixel');
lbl8.Layout.Row = 16; lbl8.Layout.Column = [1 2];

hOrdpix = uidropdown(lg, 'Items', Order_List);
hOrdpix.Layout.Row = 16; hOrdpix.Layout.Column = 3;

hPix1 = uieditfield(lg, 'numeric', 'Value', 200);
hPix1.Layout.Row = 16; hPix1.Layout.Column = 4;

btn_calc = uibutton(lg, 'Text', 'Calc SDD', 'FontWeight', 'bold', 'ButtonPushedFcn', @SDDval_Callback);
btn_calc.Layout.Row = 17; btn_calc.Layout.Column = [1 2];

GUI.txtSDD = uilabel(lg, 'Text', 'Result: - mm', 'FontWeight', 'bold', 'FontColor', 'b');
GUI.txtSDD.Layout.Row = 17; GUI.txtSDD.Layout.Column = [3 4];

btn_save = uibutton(lg, 'Text', 'Save Calibration', 'FontWeight', 'bold', 'ButtonPushedFcn', @Savepara_Callback);
btn_save.Layout.Row = 18; btn_save.Layout.Column = [1 4];

% --- 7. Image Controls ---
lbl9 = uilabel(lg, 'Text', '--- Image Controls ---', 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
lbl9.Layout.Row = 20; lbl9.Layout.Column = [1 4];

lbl10 = uilabel(lg, 'Text', 'Scale:');
lbl10.Layout.Row = 21; lbl10.Layout.Column = 1;

hScale = uidropdown(lg, 'Items', scaleList, 'ValueChangedFcn', @Updateimage_Callback);
hScale.Layout.Row = 21; hScale.Layout.Column = 2;

lbl11 = uilabel(lg, 'Text', 'Color:');
lbl11.Layout.Row = 21; lbl11.Layout.Column = 3;

hColor = uidropdown(lg, 'Items', ColormapList, 'ValueChangedFcn', @Updateimage_Callback);
hColor.Layout.Row = 21; hColor.Layout.Column = 4;

lbl12 = uilabel(lg, 'Text', 'Min:');
lbl12.Layout.Row = 22; lbl12.Layout.Column = 1;

GUI.hCMin = uieditfield(lg, 'numeric', 'Value', 1, 'ValueChangedFcn', @Updateimage_Callback);
GUI.hCMin.Layout.Row = 22; GUI.hCMin.Layout.Column = 2;

lbl13 = uilabel(lg, 'Text', 'Max:');
lbl13.Layout.Row = 22; lbl13.Layout.Column = 3;

GUI.hCMax = uieditfield(lg, 'numeric', 'Value', 1000000, 'ValueChangedFcn', @Updateimage_Callback);
GUI.hCMax.Layout.Row = 22; GUI.hCMax.Layout.Column = 4;

% ============================ Global State ===============================
param = struct(); param.data = []; param.hROI = []; 

% =========================================================================
% ====================== CALLBACK FUNCTIONS ===============================
% =========================================================================

    function pathset_Callback(~,~)
        pathway = uigetdir;
        figure(GUI.main); drawnow;  % 메인 창을 앞으로 복원
        if pathway ~= 0, GUI.pathset.Value = pathway; end
    end

    function Openimage_Callback(~,~)
        param.detector = hDetector.Value;
        pathway = GUI.pathset.Value;
        [XSImage, datadir] = uigetfile({'*.*','All format(*.*)'}, 'Select a file', pathway);
        figure(GUI.main); drawnow;  % 메인 창을 앞으로 복원
        if XSImage == 0, return; end
        XSImage = fullfile(datadir, XSImage);
        [param.Path, param.FileName, FileFormat] = fileparts(XSImage);
        
        d = uiprogressdlg(GUI.main, 'Title', 'Loading Data', 'Indeterminate', 'on');
        try
            switch lower(FileFormat)
                case '.h5'
                    info = h5info(XSImage); targetPath = findH5DataPath(info);
                    if isempty(targetPath), error('No image array found in H5.'); end
                    tmp = squeeze(h5read(XSImage, targetPath));
                    if ~ismatrix(tmp), tmp = tmp(:,:,1); end
                    param.data = single(tmp');
                otherwise
                    param.data = loadPGIXSImageFile(XSImage, FileFormat);
            end
        catch err
            close(d); uialert(GUI.main, ['Load Error: ' err.message], 'Error'); return; 
        end
        
        param.dataSize = size(param.data);
        [param.Mask, param.pixelSize, expectedY] = loadDetectorParams(param.detector);
        
        if expectedY > 0 && param.dataSize(1) ~= expectedY
            uialert(GUI.main, ['Expected Y-dim: ' num2str(expectedY) '. Check Detector Type.'],'Warning');
        end
        
        if ~isempty(param.Mask) && all(size(param.Mask) == param.dataSize)
            param.data = param.data .* param.Mask;
        end
        param.data(param.data >= 1e9) = nan;
        
        cmin_val = min(param.data(param.data > 0), [], 'omitnan');
        if isempty(cmin_val), cmin_val = 1; end
        GUI.hCMin.Value = double(cmin_val);
        GUI.hCMax.Value = double(max(param.data(:), [], 'omitnan'));
        
        close(d); renderImage();
        cla(hAX1D); title(hAX1D, '1D Profile Dashboard Ready');
    end

    function renderImage(overlayFunc)
        if isempty(param.data), return; end
        
        cmin = GUI.hCMin.Value; cmax = GUI.hCMax.Value;
        if cmin >= cmax, cmax = cmin + 1; end
        
        plotData = param.data;
        if strcmpi(hScale.Value, 'Log'), plotData(plotData <= 0) = NaN; end
        
        cla(hAX); 
        imObj = imagesc(hAX, plotData); 
        axis(hAX, 'image');
        clim(hAX, [cmin, cmax]);
        hAX.ColorScale = lower(hScale.Value);
        imObj.AlphaData = ~isnan(plotData); 
        
        applyPGIXSColormap(hAX, hColor.Value, plotData);
        xlabel(hAX, 'Y, pixel'); ylabel(hAX, 'Z, pixel');
        
        if nargin > 0 && ~isempty(overlayFunc), hold(hAX, 'on'); overlayFunc(); hold(hAX, 'off'); end
    end

    function Updateimage_Callback(~,~), renderImage(); end

    function Center_Callback(~,~)
        if isempty(param.data), return; end
        if isfield(param, 'hROI') && ~isempty(param.hROI) && isvalid(param.hROI), delete(param.hROI); end
        param.hROI = drawpoint(hAX, 'Position', [hYpos.Value, hZpos.Value], 'Color', 'r', 'Label', 'Center');
        addlistener(param.hROI, 'MovingROI', @(src, evt) updateFromROI(src.Position));
        addlistener(param.hROI, 'ROIMoved', @(src, evt) updateFromROI(src.Position));
    end

    function updateFromROI(pos)
        hYpos.Value = round(pos(1), 1); hZpos.Value = round(pos(2), 1);
        plotProfilesDashboard(param.data, [hYpos.Value, hZpos.Value]);
    end

    function plotProfilesDashboard(data, pos)
        Y = (1:size(data,2)) - pos(1); Z = (1:size(data,1)) - pos(2);
        YI = data(round(pos(2)), :)'; ZI = data(:, round(pos(1)));
        yp = Y >= 0; ym = Y < 0; zp = Z >= 0; zm = Z < 0;
        
        cla(hAX1D); hold(hAX1D, 'on');
        plot(hAX1D, Y(yp), YI(yp), '-r', 'LineWidth', 1.5, 'DisplayName', 'Hor+');
        plot(hAX1D, abs(Y(ym)), YI(ym), '--m', 'LineWidth', 1.5, 'DisplayName', 'Hor-');
        plot(hAX1D, Z(zp), ZI(zp), '-b', 'LineWidth', 1.5, 'DisplayName', 'Ver+');
        plot(hAX1D, abs(Z(zm)), ZI(zm), '--c', 'LineWidth', 1.5, 'DisplayName', 'Ver-');
        hold(hAX1D, 'off');
        legend(hAX1D, 'Location', 'northeast'); grid(hAX1D, 'on');
        xlabel(hAX1D, '|Pixel| Distance from Center'); ylabel(hAX1D, 'Intensity');
        title(hAX1D, sprintf('Center Symmetry Check at [%.1f, %.1f]', pos(1), pos(2)));
        xlim(hAX1D, [0, min(size(data))/2]);
    end

    function Marking_Callback(~,~)
        if isempty(param.data), return; end
        pos = [hYpos.Value, hZpos.Value];
        renderImage(@() drawCrosshair(pos, param.dataSize));
        plotProfilesDashboard(param.data, pos);
    end

    function drawCrosshair(pos, dataSize)
        plot(hAX, [1, dataSize(2)], [pos(2), pos(2)], '-r', 'LineWidth', 1.5);
        plot(hAX, [pos(1), pos(1)], [1, dataSize(1)], '-r', 'LineWidth', 1.5);
    end

    % =====================================================================
    % [변경] 외부 GUI(OneDplotpixel, OneDplotpixelR) 호출 연동
    % =====================================================================
    function Yplot_Callback(~,~)
        if isempty(param.data), return; end
        pos = [round(hYpos.Value, 1), round(hZpos.Value, 1)];
        param.position = pos; % 외부 GUI로 보낼 파라미터 업데이트
        
        Yline(:,1) = (1:round(param.dataSize(2))) - round(pos(1));
        Yline(:,2) = param.data(round(pos(2)),:)';
        
        % 대시보드 렌더링 (참고용)
        cla(hAX1D); plot(hAX1D, Yline(:,1), Yline(:,2), 'b-', 'LineWidth', 1.5);
        title(hAX1D, ['Y-direction Line Cut (Z = ' num2str(pos(2)) ')']);
        xlabel(hAX1D, 'Distance (pixel)'); ylabel(hAX1D, 'Intensity'); grid(hAX1D, 'on');
        
        % 외부 GUI 팝업 호출 (방향코드: 0 = Y)
        OneDplotpixel_gui(Yline, param, 0, hYpos, hZpos, GUI.main);
    end

    function Zplot_Callback(~,~)
        if isempty(param.data), return; end
        pos = [round(hYpos.Value, 1), round(hZpos.Value, 1)];
        param.position = pos; % 외부 GUI로 보낼 파라미터 업데이트
        
        Zline(:,1) = (1:round(param.dataSize(1))) - round(pos(2));
        Zline(:,2) = param.data(:,round(pos(1)));
        
        % 대시보드 렌더링 (참고용)
        cla(hAX1D); plot(hAX1D, Zline(:,1), Zline(:,2), 'r-', 'LineWidth', 1.5);
        title(hAX1D, ['Z-direction Line Cut (Y = ' num2str(pos(1)) ')']);
        xlabel(hAX1D, 'Distance (pixel)'); ylabel(hAX1D, 'Intensity'); grid(hAX1D, 'on');
        
        % 외부 GUI 팝업 호출 (방향코드: 1 = Z)
        OneDplotpixel_gui(Zline, param, 1, hYpos, hZpos, GUI.main);
    end

    function CircularAve_Callback(~,~)
        if isempty(param.data), return; end
        [r_ax, I_rad] = computeRadialProfile(param.data, [hYpos.Value, hZpos.Value], []);
        data1d = [r_ax, I_rad]; % N x 2 배열로 패키징
        
        % 대시보드 렌더링 (참고용)
        cla(hAX1D); plot(hAX1D, r_ax, I_rad, 'k-', 'LineWidth', 1.5);
        title(hAX1D, 'Radial Average Profile');
        xlabel(hAX1D, 'Radius (pixel)'); ylabel(hAX1D, 'Azimuthally Averaged Intensity'); grid(hAX1D, 'on');
        
        % 외부 GUI 팝업 호출
        OneDplotpixelR_gui(data1d, hPix1, GUI.main);
    end
    % =====================================================================

    function AutoRun_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'Load data first!', 'Error'); return; end
        
        d = uiprogressdlg(GUI.main, 'Title', 'Smart Auto Run', 'Message', '1. Initial Center Refinement...');
        
        approxCY = hYpos.Value; approxCZ = hZpos.Value;
        try [refinedCY, refinedCZ] = refineCenter(param.data, [approxCY, approxCZ]);
        catch, refinedCY = approxCY; refinedCZ = approxCZ; end
        
        d.Value = 0.3; d.Message = '2. Fine-Tuning Center...';
        try
            [r_axis, I_radial] = computeRadialProfile(param.data, [refinedCY, refinedCZ], []);
            [~, locs] = findpeaks(I_radial(r_axis > 80), 'MinPeakProminence', max(I_radial)*0.05, 'SortStr', 'descend');
            
            if ~isempty(locs)
                targetRadius = r_axis(locs(1) + find(r_axis>80,1)-1);
                [finalCY, finalCZ] = fineTuneCenter(param.data, [refinedCY, refinedCZ], targetRadius);
                hYpos.Value = finalCY; hZpos.Value = finalCZ;
                renderImage(@() drawCrosshair([finalCY, finalCZ], param.dataSize));
                drawnow; refinedCY = finalCY; refinedCZ = finalCZ;
            end
        catch ME
            warning('SDDcal:FineTuneFailed', ...
                'Fine-tuning center failed; using refined initial center: %s', ME.message);
        end
        
        d.Value = 0.5; d.Message = '3. Analyzing Peaks...';
        
        [r_axis, I_radial] = computeRadialProfile(param.data, [refinedCY, refinedCZ], []);
        validIdx = r_axis > 50; 
        [~, locs] = findpeaks(I_radial(validIdx), 'MinPeakProminence', max(I_radial)*0.03, 'SortStr', 'none'); 
        
        if isempty(locs), close(d); uialert(GUI.main, 'No rings found.', 'Fail'); return; end
        
        offset = find(validIdx, 1, 'first') - 1; locs = locs + offset;
        detectedPixPos = r_axis(locs);
        currentSample = hStandard.Value;
        
        if strcmp(currentSample, 'SEBS')
            targetCands = detectedPixPos(detectedPixPos > 80);
            if ~isempty(targetCands), roughTargetPixel = targetCands(1); else, roughTargetPixel = detectedPixPos(1); end
            finalOrder = 1;
        elseif strcmp(currentSample, 'Silver behenate')
            candidatesPos = detectedPixPos(detectedPixPos > 80);
            if isempty(candidatesPos), close(d); uialert(GUI.main, 'AgBh: No peaks > 80px found.', 'Fail'); return; end
            firstCandPos = candidatesPos(1);
            if length(candidatesPos) >= 2
                ratio = candidatesPos(2) / firstCandPos;
                if abs(ratio - 2.0) < 0.2, finalOrder = 1; 
                    roughTargetPixel = firstCandPos;
                elseif abs(ratio - 1.5) < 0.2, finalOrder = 2; 
                    roughTargetPixel = firstCandPos;
                elseif abs(ratio - 1.33) < 0.2, finalOrder = 3; 
                    roughTargetPixel = firstCandPos;
                else, finalOrder = 1; 
                    roughTargetPixel = firstCandPos; 
                end
            else
                finalOrder = 1; roughTargetPixel = firstCandPos;
            end
        else
            roughTargetPixel = detectedPixPos(1); finalOrder = 1;
        end
        
        d.Value = 0.9; d.Message = 'Gaussian Fitting...';
        [fittedPixel, fittedCurveX, fittedCurveY] = fitGaussianPeak(r_axis, I_radial, roughTargetPixel);
        
        hPix1.Value = fittedPixel; hOrdpix.Value = Order_List{finalOrder};
        SDDval_Callback();
        
        cla(hAX1D);
        plot(hAX1D, r_axis, I_radial, 'k', 'LineWidth', 1.5); hold(hAX1D, 'on');
        plot(hAX1D, fittedCurveX, fittedCurveY, 'r-', 'LineWidth', 2.5);
        plot(hAX1D, fittedPixel, interp1(fittedCurveX, fittedCurveY, fittedPixel), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        if strcmp(currentSample, 'Silver behenate'), xline(hAX1D, 80, '--b', 'Min 80px'); end
        title(hAX1D, ['Gaussian Fit Verification - ' currentSample ' (Order ' num2str(finalOrder) ')']);
        xlabel(hAX1D, 'Radius (pixel)'); ylabel(hAX1D, 'Intensity'); grid(hAX1D, 'on'); 
        xlim(hAX1D, [fittedPixel - 50, fittedPixel + 50]);
        hold(hAX1D, 'off');
        close(d);
    end

    function SDDval_Callback(~,~)
        param.detector = hDetector.Value; param.standardS = hStandard.Value;
        param.Energy = hEnergy.Value; param.Pixorder = hPix1.Value;
        orderMatch = strcmp(Order_List, hOrdpix.Value);
        if any(orderMatch)
            orderIdx = find(orderMatch, 1);
        else
            orderIdx = 1;
            warning('SDDcal:OrderFallback', ...
                'Unknown order selection "%s"; using first order.', hOrdpix.Value);
        end
        [~, param.pixelSize, ~] = loadDetectorParams(param.detector);
        param.qval = getStandardSampleQ(param.standardS, orderIdx);
        h_const = 4.1357e-15; c_const = 2.99792458e8; 
        param.wavelength = h_const * c_const / (param.Energy * 1e3) * 1e10; 
        TT = 2 * asind(param.wavelength * param.qval / (4 * pi));
        param.SDD = param.Pixorder * param.pixelSize / tand(TT); % mm
        GUI.txtSDD.Text = ['Result: ', sprintf('%.2f', param.SDD), ' mm'];
    end

    function Savepara_Callback(~,~)
        if isempty(param.data), uialert(GUI.main, 'No data loaded!', 'Error'); return; end
        
        % [가드] SDD 계산이 선행되어야 저장 가능 (param.SDD, .Pixorder, .qval 등 의존)
        if ~isfield(param, 'SDD') || isempty(param.SDD) || ...
           ~isfield(param, 'Pixorder') || isempty(param.Pixorder)
            uialert(GUI.main, ...
                sprintf(['SDD 값이 계산되지 않았습니다.\n' ...
                         '먼저 [Calc SDD] 또는 [SMART AUTO RUN]을 실행하세요.']), ...
                'Calculation Required', 'Icon', 'warning');
            return;
        end
        
        % 1. 기존 saveData 구성 (MAT & STD 용: MATLAB 1-based index)
        saveData.pc = [hYpos.Value, hZpos.Value]; % YZ 반전 주의 유지
        saveData.STpeak = param.Pixorder; 
        saveData.STqvalue = param.qval;
        saveData.wavelength = param.wavelength; 
        saveData.pixelsize = param.pixelSize;
        saveData.sdd = param.SDD; 
        saveData.dttypename = param.detector;
        saveData.imgdim = param.dataSize;
        
        switch param.detector
            case 'Eiger4M', saveData.index_dt = 'eiger4m';
            case 'MarCCD', saveData.index_dt = 'marccd';
            case 'SX165', saveData.index_dt = 'sx165';
            case 'MX170HS', saveData.index_dt = 'mx170hs';
            case 'PI-CCD', saveData.index_dt = 'piccd';
            otherwise, saveData.index_dt = 'unknown';
        end
        
        % 2. Python 연동을 위한 JSON 데이터 구성 (0-based index 적용)
        jsonData = saveData;
        jsonData.pc = [hYpos.Value - 1, hZpos.Value - 1]; % Center 좌표를 1씩 빼줌
        
        % 3. 저장 파일 경로 설정
        matFile = fullfile(param.Path, [param.FileName, '_standard.mat']);
        stdFile = strrep(matFile, '.mat', '.std');
        jsonFile = strrep(matFile, '.mat', '.json');
        
        % 4. 파일 저장 실행
        % (1) MAT 파일 저장
        [matSuccess, matSaveReport] = savePGIXSStructFile(matFile, saveData);
        if ~matSuccess
            warning('SDDcal:MatSaveFailed', ...
                'MAT calibration file writing failed: %s', matSaveReport.Message);
            uialert(GUI.main, ['MAT calibration file save failed: ' matSaveReport.Message], ...
                'Save Error', 'Icon', 'error');
            return;
        end
        
        % (2) JSON 파일 저장 (Python에서 읽기 편하게 구조화)
        try
            % MATLAB R2021a 이상에서는 PrettyPrint 지원, 하위 버전 호환을 위해 try-catch
            try
                jsonStr = jsonencode(jsonData, 'PrettyPrint', true); 
            catch ME
                warning('SDDcal:JsonPrettyPrintFallback', ...
                    'Pretty JSON encoding failed; using compact JSON: %s', ME.message);
                jsonStr = jsonencode(jsonData); 
            end
            
            fid = fopen(jsonFile, 'w');
            if fid == -1, error('JSON 파일 쓰기 권한이 없습니다.'); end
            jsonCleanup = onCleanup(@() fclose(fid));
            fprintf(fid, '%s', jsonStr);
            jsonSuccess = true;
        catch ME
            jsonSuccess = false;
            warning('SDDcal:JsonWriteFailed', ...
                'JSON calibration file writing failed: %s', ME.message);
        end
        
        % (3) STD 파일 저장 및 최종 알림
        try
            chk_save = stdsave(stdFile, saveData.pc, saveData.STpeak, ...
                saveData.STqvalue, saveData.wavelength, saveData.pixelsize, saveData.sdd, saveData.index_dt, saveData.dttypename);
            
            if chk_save == 1 && jsonSuccess
                uialert(GUI.main, sprintf('Calibration saved perfectly!\n.mat, .std, and .json files are created.'), 'Success', 'Icon', 'success');
            elseif chk_save == 1
                uialert(GUI.main, 'Saved .mat and .std, but JSON creation failed.', 'Partial Success', 'Icon', 'warning');
            else
                uialert(GUI.main, 'Saved .mat and .json, but STD format failed.', 'Partial Success', 'Icon', 'warning');
            end
        catch ME
            warning('SDDcal:StdSaveFailed', ...
                'STD calibration file writing failed: %s', ME.message);
            if jsonSuccess
                uialert(GUI.main, sprintf('Saved .mat and .json successfully.\n(stdsave function not found)'), 'Partial Success', 'Icon', 'info');
            else
                uialert(GUI.main, ['Saved only .mat file: ' matFile], 'Partial Success', 'Icon', 'info');
            end
        end
    end

    % ====================== HELPER FUNCTIONS =================================
    function path = findH5DataPath(info)
        path = '';
        for i = 1:length(info.Datasets)
            if length(info.Datasets(i).Dataspace.Size) >= 2, path = [info.Name '/' info.Datasets(i).Name]; path = strrep(path, '//', '/'); return; end
        end
        for i = 1:length(info.Groups), path = findH5DataPath(info.Groups(i)); if ~isempty(path), return; end; end
    end

    function [Mask, pixel, dimY] = loadDetectorParams(detectorType)
        switch detectorType
            case 'Eiger4M', dimY = 2167;
            case {'MarCCD','SX165'}, dimY = 2048;
            case 'MX170HS', dimY = 1920;
            case 'PI-CCD', dimY = 1042;
            case 'MAR345', dimY = 3450;
            otherwise, dimY = 0;
        end
        [Mask, pixel, maskReport] = loadPGIXSDetectorMask(detectorType);
        if maskReport.FallbackUsed && ~isempty(maskReport.Message)
            warning('SDDcal:MaskFallback', '%s', maskReport.Message);
        end
    end

    function qval = getStandardSampleQ(sampleName, order)
        baseQ = 0;
        switch sampleName
            case 'SEBS', baseQ = 0.01916;
            case 'Silver behenate', baseQ = 0.1052;
            case 'Mesoporous Silica', baseQ = 0.059264;
            case 'Sucrose', baseQ = 0.5933;
        end
        qval = baseQ * order;
    end

    function [r_axis, I_radial] = computeRadialProfile(data, center, ~)
        [dimY, dimX] = size(data); [X, Y] = meshgrid(1:dimX, 1:dimY);
        R = sqrt((X - center(1)).^2 + (Y - center(2)).^2); R = R(:); I = data(:);
        valid = ~isnan(I) & ~isnan(R); R = R(valid); I = I(valid);
        if isempty(R), r_axis = []; I_radial = []; return; end
        maxR = ceil(max(R)); edges = 0:1:maxR;
        [~, ~, binIdx] = histcounts(R, edges); mask = binIdx > 0; b = binIdx(mask); v = I(mask);
        nbins = length(edges) - 1; I_sum = accumarray(b, v, [nbins, 1]); count = accumarray(b, 1, [nbins, 1]);
        I_radial = I_sum ./ count; nanIdx = isnan(I_radial) | (count == 0); x_indices = (1:length(I_radial))';
        if any(nanIdx) && sum(~nanIdx) > 2, I_radial(nanIdx) = interp1(x_indices(~nanIdx), I_radial(~nanIdx), x_indices(nanIdx), 'linear'); end
        r_axis = (edges(1:end-1) + 0.5)'; I_radial = smoothdata(I_radial, 'gaussian', 5);
    end

    function [newCY, newCZ] = refineCenter(data, initCenter)
        [r_axis, I_r] = computeRadialProfile(data, initCenter, []);
        validRange = r_axis > 80; if sum(validRange) < 10, validRange = r_axis > 30; end
        [~, maxIdx] = max(I_r(validRange)); maxIdx = maxIdx + find(validRange, 1) - 1;
        approxRadius = r_axis(maxIdx);
        [dimY, dimX] = size(data); [X, Y] = meshgrid(1:dimX, 1:dimY);
        R_map = sqrt((X - initCenter(1)).^2 + (Y - initCenter(2)).^2);
        ringMask = (R_map > (approxRadius - 10)) & (R_map < (approxRadius + 10));
        ringPixels = data(ringMask); coordsX = X(ringMask); coordsY = Y(ringMask);
        threshold = quantile(ringPixels, 0.80);
        validIdx = ringPixels > threshold; finalX = coordsX(validIdx); finalY = coordsY(validIdx);
        costFunc = @(c) std(sqrt((finalX - c(1)).^2 + (finalY - c(2)).^2));
        options = optimset('Display', 'off', 'TolX', 0.1);
        refinedCenter = fminsearch(costFunc, initCenter, options);
        newCY = refinedCenter(1); newCZ = refinedCenter(2);
    end

    function [center, fitX, fitY] = fitGaussianPeak(x, y, roughCenter)
        idx = (x >= (roughCenter - roughCenter/2)) & (x <= (roughCenter + roughCenter/2));
        x_roi = double(x(idx)'); y_roi = double(y(idx)');
        if length(x_roi) < 4, center = roughCenter; fitX = x_roi; fitY = y_roi; return; end
        ft = fittype('a*exp(-((x-b)^2)/(2*c^2)) + d'); amp_guess = max(y_roi) - min(y_roi);
        opts = fitoptions(ft); opts.StartPoint = [amp_guess, roughCenter, 2.0, min(y_roi)];
        opts.Lower = [0, min(x_roi), 0.1, 0]; opts.Upper = [Inf, max(x_roi), 50, max(y_roi)];
        try [f, ~] = fit(x_roi, y_roi, ft, opts); center = f.b; fitX = linspace(min(x_roi), max(x_roi), 100); fitY = f(fitX);
        catch, center = roughCenter; fitX = x_roi; fitY = y_roi; end
    end

    function [finalCY, finalCZ] = fineTuneCenter(data, initCenter, targetRadius)
        % iCol: column 인덱스 (Y 방향, 가로축), iRow: row 인덱스 (Z 방향, 세로축)
        curCY = initCenter(1); curCZ = initCenter(2); [H, W] = size(data);
        for iter = 1:10
            iCol = round(curCY); iRow = round(curCZ);
            if iCol < 1 || iCol > W || iRow < 1 || iRow > H, break; end
            searchRange = round(targetRadius) + (-20:20); searchRange = searchRange(searchRange > 0);
            idxR = iCol + searchRange; idxR = idxR(idxR <= W); profR = data(iRow, idxR);
            idxL = iCol - searchRange; idxL = idxL(idxL > 0); profL = data(iRow, idxL);
            idxD = iRow + searchRange; idxD = idxD(idxD <= H); profD = data(idxD, iCol); 
            idxU = iRow - searchRange; idxU = idxU(idxU > 0); profU = data(idxU, iCol);
            try [pR, ~, ~] = fitGaussianPeak(searchRange, profR, targetRadius); catch, pR = NaN; end
            try [pL, ~, ~] = fitGaussianPeak(searchRange, profL, targetRadius); catch, pL = NaN; end
            try [pD, ~, ~] = fitGaussianPeak(searchRange, profD', targetRadius); catch, pD = NaN; end
            try [pU, ~, ~] = fitGaussianPeak(searchRange, profU', targetRadius); catch, pU = NaN; end
            shiftY = 0; shiftZ = 0; countY = 0; countZ = 0;
            if ~isnan(pR) && ~isnan(pL), shiftY = (pR - pL) / 2; countY = 1; end
            if ~isnan(pD) && ~isnan(pU), shiftZ = (pD - pU) / 2; countZ = 1; end
            if countY == 0 && countZ == 0, break; end 
            curCY = curCY + shiftY * 0.8; curCZ = curCZ + shiftZ * 0.8;
            if abs(shiftY) < 0.05 && abs(shiftZ) < 0.05, break; end
        end
        finalCY = curCY; finalCZ = curCZ;
    end
end
