function FrameImage(param)
% FrameImage - Slice Viewer for GIXS Stack Data
% Optimized for MATLAB R2024a
% Synced with GIXS2_gui coordinate systems and colormaps

    % 1. 데이터 검증
    if ~isfield(param, 'Stack') || isempty(param.Stack)
        errordlg('No stack data available to view.', 'Data Error');
        return;
    end

    % 2. 메인 프레임 생성
    mainF = figure('Name', ['Frame Viewer - ' param.FileName], ...
        'NumberTitle', 'off', ...
        'units', 'normalized', 'outerposition', [0.4 0.15 0.4 0.6], ...
        'MenuBar', 'none', 'ToolBar', 'figure'); % 줌/팬 기능을 위해 툴바 활성화

    coldf = [0.95 0.95 0.95];

    % 3. UI 패널 구성
    centralPanel = uipanel('Parent', mainF, 'Title', 'Frame Image Viewer', ...
        'FontSize', 12, 'Units', 'Normalized', ...
        'Position', [0.05 0.15 0.9 0.83], 'BackgroundColor', [1 1 1]);

    hAXV = axes('Parent', centralPanel, 'Position', [0.12 0.15 0.80 0.75]);

    N = size(param.Stack, 3);
 
    % 4. 컨트롤 요소 (슬라이더, 텍스트)
    obj.sld = uicontrol('Parent', mainF, 'Style', 'slider', ...
        'Units', 'normalized', 'Position', [0.25 0.03 0.5 0.05], ...
        'Min', 1, 'Max', N, 'SliderStep', [1/max(1, N-1), 0.1], 'Value', 1, ...
        'Callback', @sld_callback);    

    % 현재 프레임 번호 표시
    obj.sldtext = uicontrol('Parent', mainF, 'Style', 'text', ...
        'String', '1', 'Units', 'normalized', ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', coldf, ...
        'Position', [0.45 0.085 0.1 0.03]);

    % 최소/최대 라벨
    uicontrol('Parent', mainF, 'Style', 'text', ...
        'String', '1', 'Units', 'normalized', ...
        'FontSize', 10, 'BackgroundColor', coldf, ...
        'Position', [0.2 0.04 0.05 0.03]);

    uicontrol('Parent', mainF, 'Style', 'text', ...
        'String', num2str(N), 'Units', 'normalized', ...
        'FontSize', 10, 'BackgroundColor', coldf, ...
        'Position', [0.75 0.04 0.05 0.03]);

    % 초기 실행
    sld_callback();

    % ====================================================================
    % Slider Callback
    % ====================================================================
    function sld_callback(~,~)
        % 슬라이더 값 읽기 (정수형)
        val = round(get(obj.sld, 'Value'));
        % 범위 제한 (안전장치)
        val = max(1, min(N, val));
        
        set(obj.sldtext, 'String', num2str(val));

        % 해당 프레임 데이터 추출
        current_img = param.Stack(:,:,val);

        cla(hAXV);
        axes(hAXV);

        % 1. 이미지 그리기 (좌표계 확인)
        if isfield(param, 'HD') && isfield(param, 'VD')
            imagesc(param.HD, param.VD, current_img);
        else
            imagesc(current_img);
        end
    
        % 2. 좌표계 방향 및 라벨 설정 (Main GUI와 동기화)
        if param.Expinfo == 0
            % Pixel Mode
            set(gca, 'YDir', 'reverse');
            xlabel('Y (pixel)'); ylabel('Z (pixel)');
        else
            % Physical Mode (Beam Center Corrected)
            set(gca, 'YDir', 'normal');
            xlabel('Y (pixel relative)'); ylabel('Z (pixel relative)');
        end

        axis image;

        % 3. 축 범위 및 Contrast 설정
        % param에 저장된 설정값이 있으면 사용, 없으면 자동
        if isfield(param, 'xlimmin')
            set(hAXV, 'XLim', [param.xlimmin, param.xlimmax]);
            set(hAXV, 'YLim', [param.ylimmin, param.ylimmax]);
        end
        
        if isfield(param, 'cmin')
            clim([param.cmin, param.cmax]);
        end
        
        if isfield(param, 'colorscale')
            set(gca, 'ColorScale', param.colorscale);
        end

        % 4. 컬러맵 적용
        applyPGIXSColormap(hAXV, param.colorm, current_img);

        % 5. 컬러바 및 스타일
        hcb = colorbar;
        hcb.LineWidth = 1.5;
        hcb.TickDirection = 'out';
        hcb.Label.String = 'Intensity (a.u.)';
        hcb.Label.FontSize = 12;

        set(gca, 'LineWidth', 1.5, 'Tickdir', 'in', ...
            'FontSize', 12, 'FontName', 'times', 'Box', 'on');
            
        title(['Frame: ' num2str(val) ' / ' num2str(N)], 'FontSize', 12);
    end

end
