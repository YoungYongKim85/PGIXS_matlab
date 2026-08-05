function OneDplotpixel_gui(data1d, param, direc, hYpos, hZpos, parentFig)
% OneDplotpixel_gui (Modern UI v2.0)
% REVISION: Removed Save function for cleaner UI, Symmetric Fit Preserved
% parentFig: 부모(메인) figure 핸들 (창 닫힐 때 포커스 복원용, 옵션)

    if nargin < 6, parentFig = []; end
    
    % ============================ 변수 초기화 ================================
    X = double(data1d(:,1));
    Y = double(data1d(:,2));
    
    % 피팅 영역 변수
    c1 = 0; c2 = 0;             % Single Peak 용
    cL1 = 0; cL2 = 0;           % Symmetric: Left(-) Peak 용
    cR1 = 0; cR2 = 0;           % Symmetric: Right(+) Peak 용
    IS_p = [];                  % 메인으로 보낼 피팅 파라미터 (IS_p(2)가 오프셋)

    % ============================ GUI Setup ==================================
    mainF = uifigure('Name','1D Plot Viewer (Y/Z)',...
        'NumberTitle','off',...
        'Position',[200 200 850 500],...
        'Color', [0.96 0.96 0.96],...
        'CloseRequestFcn', @CloseFig_Callback);

    movegui(mainF, 'center');
    
    % Main Grid (좌: 플롯 1x, 우: 컨트롤 230px)
    mainGrid = uigridlayout(mainF, [1 2]);
    mainGrid.ColumnWidth = {'1x', 230};
    mainGrid.Padding = [10 10 10 10];
    
    % Left Panel (Plot)
    plotPanel = uipanel(mainGrid, 'Title', '1D Line Cut Profile', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w');
    plotGrid = uigridlayout(plotPanel, [1 1]);
    plotGrid.Padding = [5 5 5 5];
    hAX = uiaxes(plotGrid);
    
    % Right Panel (Controls)
    ctrlPanel = uipanel(mainGrid, 'Title', 'Control', 'FontSize', 12, 'FontWeight', 'bold');
    
    % [수정] Save 파트 제거 후 12행 레이아웃으로 간격 최적화
    cg = uigridlayout(ctrlPanel, [12 1]);
    cg.RowHeight = {25, 25, 25, 25, 25, 25, 30, 30, 40, 25, '1x', 35};
    cg.Padding = [10 10 10 10];
    
    % --- Controls ---
    lbl1 = uilabel(cg, 'Text', 'Plot Scale:');
    lbl1.Layout.Row = 1;
    
    scaleList = {'Linear', 'Logy', 'Logx', 'Logxy'};
    hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
    hScale.Layout.Row = 2;
    
    lbl2 = uilabel(cg, 'Text', 'Plot Direction:');
    lbl2.Layout.Row = 3;
    
    plotdirList = {'Horizontal', 'Vertical'};
    hPlotdir = uidropdown(cg, 'Items', plotdirList, 'ValueChangedFcn', @Updateplot_Callback);
    hPlotdir.Layout.Row = 4;
    
    % 피팅 모드 선택
    lblMode = uilabel(cg, 'Text', 'Fit Mode:', 'FontColor', 'b', 'FontWeight', 'bold');
    lblMode.Layout.Row = 5;
    
    modeList = {'Single Peak', 'Symmetric Peaks (+/-)'};
    hFitMode = uidropdown(cg, 'Items', modeList, 'ValueChangedFcn', @Updateplot_Callback);
    hFitMode.Layout.Row = 6;
    
    btn1 = uibutton(cg, 'Text', '1. Select Data Range', 'ButtonPushedFcn', @Getpoint_Callback);
    btn1.Layout.Row = 7;
    
    btn2 = uibutton(cg, 'Text', '2. Gaussian Fit Peak(s)', 'FontWeight', 'bold', 'FontColor', 'r', 'ButtonPushedFcn', @Fit_Callback);
    btn2.Layout.Row = 8;
    
    % Status Text
    txtStatus = uilabel(cg, 'Text', 'Range: Not selected', 'FontSize', 11, 'WordWrap', 'on');
    txtStatus.Layout.Row = 9;
    
    % Fit Result (바로 위로 당겨짐)
    txtFitResult = uilabel(cg, 'Text', 'Offset: -', 'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'b');
    txtFitResult.Layout.Row = 10;
    
    % Send Button (맨 아래 고정)
    btn4 = uibutton(cg, 'Text', 'Send to Main & Close', 'FontWeight', 'bold', 'BackgroundColor', [0.8 0.9 1], 'ButtonPushedFcn', @Sending_Callback);
    btn4.Layout.Row = 12;

    % 초기 렌더링
    Updateplot_Callback();

    % ====================== CALLBACK FUNCTIONS ===============================
    function Updateplot_Callback(~,~)
        scaleOpt = hScale.Value;
        dirOpt = hPlotdir.Value;
        
        cla(hAX);
        if strcmp(dirOpt, 'Horizontal')
            if strcmp(scaleOpt, 'Linear'), plot(hAX, X, Y, '-k', 'LineWidth', 1.5);
            elseif strcmp(scaleOpt, 'Logy'), semilogy(hAX, X, Y, '-k', 'LineWidth', 1.5);
            elseif strcmp(scaleOpt, 'Logx'), semilogx(hAX, X, Y, '-k', 'LineWidth', 1.5);
            elseif strcmp(scaleOpt, 'Logxy'), loglog(hAX, X, Y, '-k', 'LineWidth', 1.5);
            end
            xlabel(hAX, 'Distance from current center (pixel)'); ylabel(hAX, 'Intensity, arb. unit');
        else
            % Vertical 모드: 화면 X축=Intensity(Y), 화면 Y축=Distance(X)
            % 'Logx'는 화면 X축(Intensity)을 log로, 'Logy'는 화면 Y축(Distance)을 log로
            if strcmp(scaleOpt, 'Linear'), plot(hAX, Y, X, '-k', 'LineWidth', 1.5);
            elseif strcmp(scaleOpt, 'Logx'), semilogx(hAX, Y, X, '-k', 'LineWidth', 1.5);
            elseif strcmp(scaleOpt, 'Logy'), semilogy(hAX, Y, X, '-k', 'LineWidth', 1.5);
            elseif strcmp(scaleOpt, 'Logxy'), loglog(hAX, Y, X, '-k', 'LineWidth', 1.5);
            end
            xlabel(hAX, 'Intensity, arb. unit'); ylabel(hAX, 'Distance from current center (pixel)');
        end
        grid(hAX, 'on'); axis(hAX, 'tight');
        xline(hAX, 0, ':k', 'Center (0)', 'LineWidth', 1); % 기준점 0 표시
    end

    % [헬퍼 함수] 2점 클릭을 받아 바운더리를 반환하고 라인을 그립니다.
    function [b1, b2, success] = getBounds(msg1, msg2, color, dirOpt)
        success = false; b1 = 0; b2 = 0;
        txtStatus.Text = msg1; txtStatus.FontColor = color;
        
        pA = drawpoint(hAX, 'Color', color); if ~isvalid(pA), return; end
        txtStatus.Text = msg2;
        pB = drawpoint(hAX, 'Color', color); if ~isvalid(pB), return; end

        if strcmp(dirOpt, 'Horizontal')
            b1 = min(pA.Position(1), pB.Position(1));
            b2 = max(pA.Position(1), pB.Position(1));
            hold(hAX, 'on'); 
            xline(hAX, b1, '--', 'Color', color, 'LineWidth', 1.5);
            xline(hAX, b2, '--', 'Color', color, 'LineWidth', 1.5); 
            hold(hAX, 'off');
        else
            b1 = min(pA.Position(2), pB.Position(2));
            b2 = max(pA.Position(2), pB.Position(2));
            hold(hAX, 'on'); 
            yline(hAX, b1, '--', 'Color', color, 'LineWidth', 1.5);
            yline(hAX, b2, '--', 'Color', color, 'LineWidth', 1.5); 
            hold(hAX, 'off');
        end
        delete(pA); delete(pB);
        success = true;
    end

    function Getpoint_Callback(~,~)
        dirOpt = hPlotdir.Value;
        modeOpt = hFitMode.Value;
        
        Updateplot_Callback(); % 기존 선택 라인 초기화
        
        if strcmp(modeOpt, 'Single Peak')
            [b1, b2, succ] = getBounds('[1/2] 피크 시작점 클릭', '[2/2] 피크 끝점 클릭', 'b', dirOpt);
            if ~succ, txtStatus.Text = '취소됨'; txtStatus.FontColor = 'k'; return; end
            c1 = b1; c2 = b2;
            txtStatus.Text = sprintf('Range: %.1f to %.1f px', c1, c2);
            
        else
            % Symmetric Mode: Minus 영역과 Plus 영역을 순차적으로 선택
            uialert(mainF, '먼저 중심 기준 왼쪽(-) 피크를 지정한 뒤, 오른쪽(+) 피크를 지정하세요.', '대칭 모드 안내', 'Icon', 'info');
            
            [bL1, bL2, succL] = getBounds('[Minus] 왼쪽 피크 시작점 클릭', '[Minus] 왼쪽 피크 끝점 클릭', 'b', dirOpt);
            if ~succL, txtStatus.Text = '취소됨'; txtStatus.FontColor = 'k'; return; end
            cL1 = bL1; cL2 = bL2;
            
            [bR1, bR2, succR] = getBounds('[Plus] 오른쪽 피크 시작점 클릭', '[Plus] 오른쪽 피크 끝점 클릭', 'r', dirOpt);
            if ~succR, txtStatus.Text = '취소됨'; txtStatus.FontColor = 'k'; return; end
            cR1 = bR1; cR2 = bR2;
            
            txtStatus.Text = sprintf('L: [%.1f, %.1f]\nR: [%.1f, %.1f]', cL1, cL2, cR1, cR2);
        end
        txtStatus.FontColor = 'k'; 
    end

    function Fit_Callback(~,~)
        dirOpt = hPlotdir.Value;
        modeOpt = hFitMode.Value;
        
        cla(hAX);
        
        if strcmp(modeOpt, 'Single Peak')
            % ============== 1. Single Peak Fitting ==============
            xpix1 = find(X >= c1, 1, 'first'); xpix2 = find(X <= c2, 1, 'last');
            if isempty(xpix1) || isempty(xpix2) || (xpix1 >= xpix2), return; end
            
            X_sub = X(xpix1:xpix2); Y_sub = Y(xpix1:xpix2);
            
            if strcmp(dirOpt, 'Horizontal')
                plot(hAX, X_sub, Y_sub, '-ok', 'MarkerFaceColor', 'k'); hold(hAX, 'on');
            else
                plot(hAX, Y_sub, X_sub, '-ok', 'MarkerFaceColor', 'k'); hold(hAX, 'on');
            end
            
            try
                Ifit = fit(X_sub, Y_sub, 'gauss1');
                Ifit_p = coeffvalues(Ifit);
                bkg = min(Y_sub, [], 'omitnan');
                Eqn = fittype('a*exp(-(((x-b).^2)./(2*(c^2)))) + d', 'independent', 'x', 'dependent', 'y');
                
                % fit options에 Lower/Upper 경계 추가 (노이즈 발산 방지)
                opts = fitoptions(Eqn);
                opts.StartPoint = [Ifit_p(1), Ifit_p(2), Ifit_p(3)/sqrt(2), bkg];
                opts.Lower = [0, min(X_sub), 0.1, 0];
                opts.Upper = [Inf, max(X_sub), abs(max(X_sub)-min(X_sub)), max(Y_sub)];
                
                IS = fit(X_sub, Y_sub, Eqn, opts);
                IS_p_temp = coeffvalues(IS);
                GF = IS_p_temp(1)*exp(-(((X_sub-IS_p_temp(2)).^2) ./ (2*(IS_p_temp(3)^2)))) + IS_p_temp(4);
                
                if strcmp(dirOpt, 'Horizontal')
                    plot(hAX, X_sub, GF, '-b', 'LineWidth', 2);
                else
                    plot(hAX, GF, X_sub, '-b', 'LineWidth', 2);
                end
                
                txtFitResult.Text = sprintf('Offset: %.2f px', IS_p_temp(2));
                IS_p = [0, IS_p_temp(2), 0, 0]; % Sending 호환성을 위해 배열 구성
                
            catch ME
                warning('OneDplotpixel:SingleFitFailed', ...
                    'Single peak fitting failed: %s', ME.message);
                uialert(mainF, sprintf('단일 피팅에 실패했습니다.\n\n%s', ME.message), '에러');
                return;
            end
            
        else
            % ============== 2. Symmetric Dual-Peak Fitting ==============
            idxL = find(X >= cL1 & X <= cL2);
            idxR = find(X >= cR1 & X <= cR2);
            if isempty(idxL) || isempty(idxR), uialert(mainF, '지정된 영역에 데이터가 없습니다.', '에러'); return; end
            
            XL = X(idxL); YL = Y(idxL);
            XR = X(idxR); YR = Y(idxR);
            
            if strcmp(dirOpt, 'Horizontal')
                plot(hAX, XL, YL, '-ok', 'MarkerFaceColor', 'b'); hold(hAX, 'on');
                plot(hAX, XR, YR, '-ok', 'MarkerFaceColor', 'r');
            else
                plot(hAX, YL, XL, '-ok', 'MarkerFaceColor', 'b'); hold(hAX, 'on');
                plot(hAX, YR, XR, '-ok', 'MarkerFaceColor', 'r');
            end
            
            try
                Eqn = fittype('a*exp(-(((x-b).^2)./(2*(c^2)))) + d', 'independent', 'x', 'dependent', 'y');
                
                % Left Fit (경계 추가)
                IfitL = fit(XL, YL, 'gauss1'); pL = coeffvalues(IfitL);
                optsL = fitoptions(Eqn);
                optsL.StartPoint = [pL(1), pL(2), pL(3)/sqrt(2), min(YL)];
                optsL.Lower = [0, min(XL), 0.1, 0];
                optsL.Upper = [Inf, max(XL), abs(max(XL)-min(XL)), max(YL)];
                ISL = fit(XL, YL, Eqn, optsL);
                pL_final = coeffvalues(ISL); c_left = pL_final(2);
                GFL = pL_final(1)*exp(-(((XL-pL_final(2)).^2) ./ (2*(pL_final(3)^2)))) + pL_final(4);
                
                % Right Fit (경계 추가)
                IfitR = fit(XR, YR, 'gauss1'); pR = coeffvalues(IfitR);
                optsR = fitoptions(Eqn);
                optsR.StartPoint = [pR(1), pR(2), pR(3)/sqrt(2), min(YR)];
                optsR.Lower = [0, min(XR), 0.1, 0];
                optsR.Upper = [Inf, max(XR), abs(max(XR)-min(XR)), max(YR)];
                ISR = fit(XR, YR, Eqn, optsR);
                pR_final = coeffvalues(ISR); c_right = pR_final(2);
                GFR = pR_final(1)*exp(-(((XR-pR_final(2)).^2) ./ (2*(pR_final(3)^2)))) + pR_final(4);
                
                % Plot Fits
                if strcmp(dirOpt, 'Horizontal')
                    plot(hAX, XL, GFL, '-c', 'LineWidth', 2);
                    plot(hAX, XR, GFR, '-m', 'LineWidth', 2);
                else
                    plot(hAX, GFL, XL, '-c', 'LineWidth', 2);
                    plot(hAX, GFR, XR, '-m', 'LineWidth', 2);
                end
                
                % Calculate True Center Offset
                true_center_offset = (c_left + c_right) / 2;
                ring_radius = abs(c_right - c_left) / 2;
                
                txtFitResult.Text = sprintf('Center Offset: %.2f px\n(Radius: %.1f px)', true_center_offset, ring_radius);
                IS_p = [0, true_center_offset, 0, 0]; % Sending 호환성을 위해 배열 구성
                
            catch ME
                warning('OneDplotpixel:SymmetricFitFailed', ...
                    'Symmetric peak fitting failed: %s', ME.message);
                uialert(mainF, sprintf('대칭 피팅에 실패했습니다. 범위를 확인하세요.\n\n%s', ME.message), '에러');
                return;
            end
        end
        
        % 업데이트된 센터를 메인 좌표와 합산하여 상태 표시
        if direc == 0
            newPos = param.position(1) + IS_p(2);
            txtStatus.Text = sprintf('New Y-Center: %.2f', newPos);
        else
            newPos = param.position(2) + IS_p(2);
            txtStatus.Text = sprintf('New Z-Center: %.2f', newPos);
        end
        txtStatus.FontColor = [0 0.5 0]; % 초록색
        
        hold(hAX, 'off'); grid(hAX, 'on'); axis(hAX, 'tight');
        if strcmp(dirOpt, 'Horizontal')
            xlabel(hAX, 'Distance from current center (pixel)'); ylabel(hAX, 'Intensity');
        else
            xlabel(hAX, 'Intensity'); ylabel(hAX, 'Distance from current center (pixel)');
        end
    end

    function Sending_Callback(~,~)
        if isempty(IS_p)
            uialert(mainF, '먼저 피크를 피팅(Fit Peak) 하세요.', '경고');
            return;
        end
        
        % 메인 GUI의 숫자 입력창(.Value) 업데이트
        if direc == 0
            hYpos.Value = round(param.position(1) + IS_p(2), 2);
        elseif direc == 1
            hZpos.Value = round(param.position(2) + IS_p(2), 2);
        end
        
        delete(mainF); % 작업 완료 후 창 닫기
        % 부모(메인) 창을 앞으로 복원
        if ~isempty(parentFig) && isvalid(parentFig)
            figure(parentFig); drawnow;
        end
    end

    function CloseFig_Callback(~,~)
        delete(mainF);
        % 부모(메인) 창을 앞으로 복원
        if ~isempty(parentFig) && isvalid(parentFig)
            figure(parentFig); drawnow;
        end
    end
end
