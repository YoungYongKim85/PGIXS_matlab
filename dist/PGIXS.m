% This software is designed for 3C beamline user
% This program is initially designed by Young Yong Kim
% (PAL synchrotron 3C beamline scientist & manager)
% Any requests, comments, bugs: kimyy@postech.ac.kr
%
% End-user distribution entry point: Tab1 (Console) only.
% Tab3 (2D Analysis / crystal indexing) is intentionally excluded from
% this build -- see dist/README.md.

function PGIXS
    close all; clc;

    % 1. 안전한 경로 설정 (프로그램이 실행되는 현재 위치 추적)
    % MATLAB Compiler로 컴파일된 배포 앱은 런타임에 addpath로 검색 경로를
    % 바꾸는 것을 지원하지 않는다 (MATLAB:mpath:PathAlterationNotSupported).
    % 컴파일 시에는 AdditionalFiles로 포함된 파일들이 이미 인식되므로,
    % 소스에서 직접 실행할 때만 addpath 한다.
    appPath = fileparts(mfilename('fullpath'));
    if ~isdeployed
        addpath(genpath(fullfile(appPath, 'functions')));
        addpath(genpath(fullfile(appPath, 'gui', 'tab1')));
    end

    % ============================ GUI v2.0 ==================================
    % --- Create the starting modern window (uifigure)
    % ========================================================================
    hF = findall(0, 'Type', 'figure', 'Name', 'pGIXS_console');
    if ~isempty(hF), close(hF); end

    % 모던 UI 피겨 생성
    mainF = uifigure('Name', ['pGIXS Console v', pgixsVersion()], ...
        'Position', [100, 100, 380, 600], ... % 적절한 세로형 창 크기
        'Color', [0.96 0.96 0.98]);
    movegui(mainF, 'center');

    % 전체 메인 그리드 레이아웃 (헤더, 탭, 푸터)
    mainGrid = uigridlayout(mainF, [2 1]);
    mainGrid.RowHeight = {'1x', 25}; % 탭 영역 꽉 채우고, 하단에 25px 푸터
    mainGrid.Padding = [5 5 5 5];

    % 탭 그룹 생성
    tgroup = uitabgroup(mainGrid);
    tgroup.Layout.Row = 1; tgroup.Layout.Column = 1;

    tab1 = uitab(tgroup, 'Title', 'Console');

    % 하단 푸터 (Version Info)
    footer = uilabel(mainGrid, 'Text', ['Designed by Y.Y.Kim v', pgixsVersion(), ' (PLS-II BL3C)'], ...
        'FontSize', 11, 'FontColor', [0.3 0.3 0.3], 'HorizontalAlignment', 'center');
    footer.Layout.Row = 2; footer.Layout.Column = 1;

    % ========================================================================
    % Tab 1: Console UI Setup
    % ========================================================================
    % 2열 6행의 그리드로 버튼과 이미지를 깔끔하게 배치
    g1 = uigridlayout(tab1, [6, 2]);
    g1.RowHeight = {'1.5x', 45, 45, 45, 45, '0.5x'}; % 첫 줄은 로고 공간, 중간은 버튼, 마지막은 여백
    g1.ColumnSpacing = 15;
    g1.RowSpacing = 10;

    % 로고 이미지 로드 (경로 에러 방지)
    logoPath = fullfile(appPath, 'functions', 'Others', 'Intrologo.png');
    if exist(logoPath, 'file')
        img = uiimage(g1, 'ImageSource', logoPath, 'ScaleMethod', 'fit');
        img.Layout.Row = 1; img.Layout.Column = [1 2]; % 로고는 1~2열 병합
    else
        % 로고가 없을 경우 텍스트로 대체
        lbl = uilabel(g1, 'Text', 'pGIXS Console', 'FontSize', 20, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        lbl.Layout.Row = 1; lbl.Layout.Column = [1 2];
    end

    % Row 2
    uibutton(g1, 'Text', 'SDD calculator', 'ButtonPushedFcn', @(~,~) SDDcal_gui);
    uibutton(g1, 'Text', 'Converter', 'ButtonPushedFcn', @(~,~) Converter_gui);

    % Row 3
    uibutton(g1, 'Text', 'TrXS', 'ButtonPushedFcn', @(~,~) TrXS_gui);
    uibutton(g1, 'Text', 'TrXS-series', 'ButtonPushedFcn', @(~,~) TrXS2_gui);

    % Row 4
    uibutton(g1, 'Text', 'GIXS', 'ButtonPushedFcn', @(~,~) GIXS_gui);
    uibutton(g1, 'Text', 'GIXS-series', 'ButtonPushedFcn', @(~,~) GIXS2_gui);

    % Row 5
    uibutton(g1, 'Text', 'Transmittance', 'ButtonPushedFcn', @(~,~) XTrans_GUI);
    uibutton(g1, 'Text', 'Penetration Depth', 'ButtonPushedFcn', @(~,~) Penetration_GUI);

end
% ========================================================================
% John 14:6 (KSV)
% ========================================================================
