function OneDplotpixelR_gui(data1d, hPix1, parentFig)
% OneDplotpixelR_gui (Modern UI v2.0)
% REVISION: Removed unnecessary Save function for cleaner UI
% parentFig: 부모(메인) figure 핸들 (창 닫힐 때 포커스 복원용, 옵션)

    if nargin < 3, parentFig = []; end

    % 변수 초기화
    X = double(data1d(:,1));
    Y = double(data1d(:,2));
    c1 = min(X); c2 = max(X);
    IS_p = [];

    % ============================ GUI Setup ==================================
    mainF = uifigure('Name','1D Radial Plot Viewer',...
        'NumberTitle','off',...
        'Position',[200 200 800 500],...
        'Color', [0.96 0.96 0.96],...
        'CloseRequestFcn', @CloseFig_Callback);

    movegui(mainF, 'center');
    
    % Main Grid
    mainGrid = uigridlayout(mainF, [1 2]);
    mainGrid.ColumnWidth = {'1x', 220};
    mainGrid.Padding = [10 10 10 10];
    
    % Left Panel (Plot)
    plotPanel = uipanel(mainGrid, 'Title', 'Radial Average Profile', 'FontSize', 12, 'FontWeight', 'bold', 'BackgroundColor', 'w');
    plotGrid = uigridlayout(plotPanel, [1 1]);
    plotGrid.Padding = [5 5 5 5];
    hAX = uiaxes(plotGrid);
    
    % Right Panel (Controls)
    ctrlPanel = uipanel(mainGrid, 'Title', 'Control', 'FontSize', 12, 'FontWeight', 'bold');
    
    % [수정] Save 관련 UI가 빠지면서 레이아웃을 9행으로 최적화
    cg = uigridlayout(ctrlPanel, [9 1]);
    cg.RowHeight = {25, 25, 25, 30, 30, 40, 25, '1x', 35};
    cg.Padding = [10 10 10 10];
    
    % --- Controls ---
    lbl1 = uilabel(cg, 'Text', 'Plot Scale:');
    lbl1.Layout.Row = 1;
    
    scaleList = {'Linear', 'Logy', 'Logx', 'Logxy'};
    hScale = uidropdown(cg, 'Items', scaleList, 'ValueChangedFcn', @Updateplot_Callback);
    hScale.Layout.Row = 2;
    
    lbl2 = uilabel(cg, 'Text', 'Analysis Tools:');
    lbl2.Layout.Row = 3;
    
    btn1 = uibutton(cg, 'Text', '1. Select Data Range', 'ButtonPushedFcn', @Getpoint_Callback);
    btn1.Layout.Row = 4;
    
    btn2 = uibutton(cg, 'Text', '2. Gaussian Fit Peak', 'FontWeight', 'bold', 'FontColor', 'r', 'ButtonPushedFcn', @Fit_Callback);
    btn2.Layout.Row = 5;
    
    % Status Text
    txtStatus = uilabel(cg, 'Text', 'Range: Not selected', 'FontSize', 10, 'WordWrap', 'on');
    txtStatus.Layout.Row = 6;
    
    % Fit Result
    txtFitResult = uilabel(cg, 'Text', 'Radius: - px', 'FontSize', 12, 'FontWeight', 'bold', 'FontColor', 'b');
    txtFitResult.Layout.Row = 7;
    
    % Send & Close Button (맨 아래로 밀어넣기 위해 8행은 '1x' 여백으로 둠)
    btn4 = uibutton(cg, 'Text', 'Send to Main & Close', 'FontWeight', 'bold', 'BackgroundColor', [0.8 0.9 1], 'ButtonPushedFcn', @Sending_Callback);
    btn4.Layout.Row = 9;

    % 초기 렌더링
    Updateplot_Callback();

    % ====================== CALLBACK FUNCTIONS ===============================
    function Updateplot_Callback(~,~)
        scaleOpt = hScale.Value;
        
        cla(hAX);
        if strcmp(scaleOpt, 'Linear'), plot(hAX, X, Y, '-k', 'LineWidth', 1.5);
        elseif strcmp(scaleOpt, 'Logy'), semilogy(hAX, X, Y, '-k', 'LineWidth', 1.5);
        elseif strcmp(scaleOpt, 'Logx'), semilogx(hAX, X, Y, '-k', 'LineWidth', 1.5);
        elseif strcmp(scaleOpt, 'Logxy'), loglog(hAX, X, Y, '-k', 'LineWidth', 1.5);
        end
        
        xlabel(hAX, 'Radius (pixel)'); ylabel(hAX, 'Intensity');
        grid(hAX, 'on'); axis(hAX, 'tight');
    end

    function Getpoint_Callback(~,~)
        txtStatus.Text = '[1/2] 피크의 시작점을 클릭하세요.';
        txtStatus.FontColor = 'r';
        p1 = drawpoint(hAX, 'Color', 'b');
        if ~isvalid(p1), return; end
        
        txtStatus.Text = '[2/2] 피크의 끝점을 클릭하세요.';
        p2 = drawpoint(hAX, 'Color', 'b');
        if ~isvalid(p2), return; end
        
        x_sel = [p1.Position(1), p2.Position(1)];
        c1 = min(x_sel); c2 = max(x_sel);
        
        delete(p1); delete(p2); % 마커 삭제
        
        hold(hAX, 'on');
        xline(hAX, c1, '--b', 'LineWidth', 1.5);
        xline(hAX, c2, '--b', 'LineWidth', 1.5);
        hold(hAX, 'off');
        
        txtStatus.Text = sprintf('Range: %.1f to %.1f px', c1, c2);
        txtStatus.FontColor = 'k';
    end

    function Fit_Callback(~,~)
        xpix1 = find(X >= c1, 1, 'first');
        xpix2 = find(X <= c2, 1, 'last');
        if isempty(xpix1) || isempty(xpix2) || (xpix1 >= xpix2), return; end
        
        X_sub = X(xpix1:xpix2);
        Y_sub = Y(xpix1:xpix2);
        
        cla(hAX);
        plot(hAX, X_sub, Y_sub, '-ok', 'MarkerFaceColor', 'k'); hold(hAX, 'on');
        
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
            
            % gof(goodness-of-fit) 정보를 함께 받아서 R² 계산
            [IS, gof] = fit(X_sub, Y_sub, Eqn, opts);
            IS_p = coeffvalues(IS);
            
            GF = IS_p(1)*exp(-(((X_sub-IS_p(2)).^2) ./ (2*(IS_p(3)^2)))) + IS_p(4);
            plot(hAX, X_sub, GF, '-r', 'LineWidth', 2);
            
            % R²에 따른 품질 표시 (R² >= 0.85: 양호, < 0.85: 경고)
            if gof.rsquare >= 0.85
                txtFitResult.FontColor = 'b';
                txtFitResult.Text = sprintf('Radius: %.2f px (R^2=%.3f)', IS_p(2), gof.rsquare);
            else
                txtFitResult.FontColor = [0.9 0.4 0]; % 주황색 경고
                txtFitResult.Text = sprintf('Radius: %.2f px (R^2=%.3f) ⚠', IS_p(2), gof.rsquare);
            end
            txtStatus.Text = 'Fitting Successful!';
            txtStatus.FontColor = [0 0.5 0]; % 초록색
        catch ME
            warning('OneDplotpixelR:FitFailed', ...
                'Radial peak fitting failed: %s', ME.message);
            uialert(mainF, sprintf('피팅에 실패했습니다. 범위를 다시 지정하세요.\n\n%s', ME.message), '에러');
        end
        hold(hAX, 'off'); grid(hAX, 'on'); axis(hAX, 'tight');
        xlabel(hAX, 'Radius (pixel)'); ylabel(hAX, 'Intensity');
    end

    function Sending_Callback(~,~)
        if isempty(IS_p)
            uialert(mainF, '먼저 피크를 피팅(Fit Peak) 하세요.', '경고');
            return;
        end
        
        % 메인 GUI의 Target Pixel 입력창(.Value) 업데이트
        hPix1.Value = round(IS_p(2), 2);
        
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
