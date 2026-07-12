function Converter_gui

clc;

% ============================ GUI Setup ==================================
mainF = figure('Name', 'H5 to TIFF Converter v2.0', ...
    'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
    'Units', 'pixels', 'Position', [300, 300, 500, 540], ...
    'Resize', 'off', 'Color', [0.94 0.94 0.94]);

movegui(mainF, 'center');

% Title
uicontrol('Parent', mainF, 'Style', 'text', 'String', 'H5 to TIFF Converter', ...
    'FontSize', 16, 'FontWeight', 'bold', 'Units', 'pixels', ...
    'Position', [20 480 460 40], 'BackgroundColor', [0.94 0.94 0.94]);

% Experiment Mode
uicontrol('Parent', mainF, 'Style', 'text', 'String', 'Experiment Mode:', ...
    'FontSize', 11, 'HorizontalAlignment', 'left', 'Units', 'pixels', ...
    'Position', [40 425 140 25], 'BackgroundColor', [0.94 0.94 0.94]);

expModeList = {'Static', 'Time', 'Temperature', 'LowTemp'};
hExpmode = uicontrol('Parent', mainF, 'Style', 'popupmenu', 'String', expModeList, ...
    'FontSize', 10, 'Units', 'pixels', 'Position', [190 425 200 25]);

% Detector Type (마스크 적용용)
uicontrol('Parent', mainF, 'Style', 'text', 'String', 'Detector:', ...
    'FontSize', 11, 'HorizontalAlignment', 'left', 'Units', 'pixels', ...
    'Position', [40 385 140 25], 'BackgroundColor', [0.94 0.94 0.94]);

detList = {'None (Raw)', 'Eiger4M', 'MarCCD'};
hDetector = uicontrol('Parent', mainF, 'Style', 'popupmenu', 'String', detList, ...
    'FontSize', 10, 'Units', 'pixels', 'Position', [190 385 200 25]);

% Path Setting
uicontrol('Parent', mainF, 'Style', 'text', 'String', 'Directory:', ...
    'FontSize', 11, 'HorizontalAlignment', 'left', 'Units', 'pixels', ...
    'Position', [40 335 140 25], 'BackgroundColor', [0.94 0.94 0.94]);

pathset = uicontrol('Parent', mainF, 'Style', 'edit', 'String', pwd, ...
    'FontSize', 10, 'HorizontalAlignment', 'left', 'Units', 'pixels', ...
    'Position', [190 335 220 25]);

uicontrol('Parent', mainF, 'Style', 'pushbutton', 'String', 'Set', ...
    'FontSize', 10, 'Units', 'pixels', 'Position', [420 335 50 25], ...
    'Callback', @pathset_Callback);

% Options (Checkboxes)
hSerialshot = uicontrol('Parent', mainF, 'Style', 'checkbox', ...
    'String', 'Serial Shots (_0001 Group)', 'Value', 0, ...
    'FontSize', 11, 'Units', 'pixels', 'Position', [40 280 300 25], ...
    'BackgroundColor', [0.94 0.94 0.94]);

hAlldata = uicontrol('Parent', mainF, 'Style', 'checkbox', ...
    'String', 'Convert All H5 in Folder', 'Value', 0, ...
    'FontSize', 11, 'Units', 'pixels', 'Position', [40 245 300 25], ...
    'BackgroundColor', [0.94 0.94 0.94]);

% Output Bit Depth (#5 uint16 saturation 대응)
uicontrol('Parent', mainF, 'Style', 'text', 'String', 'TIFF Bit Depth:', ...
    'FontSize', 11, 'HorizontalAlignment', 'left', 'Units', 'pixels', ...
    'Position', [40 200 140 25], 'BackgroundColor', [0.94 0.94 0.94]);

bitList = {'uint16 (default)', 'uint32 (Eiger high-DR)'};
hBitdepth = uicontrol('Parent', mainF, 'Style', 'popupmenu', 'String', bitList, ...
    'FontSize', 10, 'Units', 'pixels', 'Position', [190 200 200 25]);

% Execution Button
uicontrol('Parent', mainF, 'Style', 'pushbutton', 'String', 'LOAD & CONVERT', ...
    'FontSize', 14, 'FontWeight', 'bold', 'ForegroundColor', [0 0.2 0.6], ...
    'Units', 'pixels', 'Position', [50 40 400 60], ...
    'Callback', @Execute_Callback);

% ========================== CALLBACKS & LOGIC ============================

    function pathset_Callback(~,~)
        pathway = uigetdir;
        if pathway ~= 0, set(pathset, 'String', pathway); end
    end

    function Execute_Callback(~,~)
        pathway = get(pathset, 'String');
        mode = expModeList{get(hExpmode, 'Value')};
        isSerial = get(hSerialshot, 'Value');
        isAll = get(hAlldata, 'Value');
        detIdx = get(hDetector, 'Value');
        bitIdx = get(hBitdepth, 'Value');
        
        % [#6] 두 체크박스 동시 활성화 시 사전 경고
        if isAll && isSerial
            choice = questdlg(['Both ''Convert All'' and ''Serial Shots'' are checked.', newline, ...
                              '''Convert All'' will take priority. Continue?'], ...
                              'Conflicting Options', 'Continue', 'Cancel', 'Cancel');
            if ~strcmp(choice, 'Continue'), return; end
        end
        
        % 파일 목록 결정
        if isAll
            files = dir(fullfile(pathway, '*.h5'));
            fileNames = {files.name};
        elseif isSerial
            [f, d] = uigetfile(fullfile(pathway, '*.h5'));
            if f == 0, return; end
            
            % [#4] Serial prefix 안전 추출 — _0001 패턴 가드
            if ~contains(f, '_0001')
                errordlg(sprintf(['Selected file does not contain ''_0001'' pattern.', newline, ...
                                  'Selected: %s', newline, newline, ...
                                  'Please select the FIRST frame (e.g. yourname_0001.h5)', newline, ...
                                  'or use ''Convert All H5 in Folder'' instead.'], f), ...
                         'Invalid Serial Selection');
                return;
            end
            prefix = extractBefore(f, '_0001');
            files = dir(fullfile(d, [prefix, '_*.h5']));  % '_*'로 더 엄격한 매칭
            fileNames = {files.name};
            pathway = d;
        else
            [f, d] = uigetfile(fullfile(pathway, '*.h5'));
            if f == 0, return; end
            fileNames = {f};
            pathway = d;
        end
        
        if isempty(fileNames) || isequal(fileNames{1}, 0)
            return;
        end
        
        N = length(fileNames);
        
        % [#3] 검출기 마스크 사전 로딩 (선택적)
        mask = loadDetectorMask(detIdx);
        
        % 비트 심도 결정
        if bitIdx == 1, useBits = 16; else, useBits = 32; end
        
        % [#7] 취소 가능 waitbar 생성
        % - setappdata로 cancel 상태 저장 (nested function 캡처 이슈 회피)
        % - onCleanup으로 어떤 종료 경로에서든 waitbar 핸들 보장 정리
        fwait = waitbar(0, sprintf('Converting 0/%d ...', N), ...
                        'Name', 'Processing Data', ...
                        'CreateCancelBtn', @(src,~) setappdata(ancestor(src, 'figure'), 'cancelling', true));
        setappdata(fwait, 'cancelling', false);
        
        % onCleanup: 함수가 어떻게 끝나도(error, return, normal) waitbar 정리 보장
        cleanupObj = onCleanup(@() closeWaitbarSafely(fwait));
        
        % [#1, #8] try-catch로 robust batch + 결과 추적
        % Preallocation: 최대 N개까지 가능하므로 N으로 사전 할당
        logRows = cell(N, 1);
        successList = cell(N, 1);
        failList = cell(N, 2);   % {파일명, 에러메시지} 쌍
        nSuccess = 0;
        nFail = 0;
        saturationCount = 0;
        userCancelled = false;
        
        for ii = 1:N
            % 취소 버튼 확인 (setappdata로 안전하게 읽기)
            if ~ishandle(fwait)
                userCancelled = true; break;  % X로 닫힌 경우
            end
            if getappdata(fwait, 'cancelling')
                userCancelled = true; break;  % Cancel 버튼 눌린 경우
            end
            
            waitbar(ii/N, fwait, sprintf('Processing %d/%d : %s', ii, N, fileNames{ii}));
            
            try
                [logEntry, satFlag] = convertFile(fullfile(pathway, fileNames{ii}), mode, mask, useBits);
                nSuccess = nSuccess + 1;
                logRows{nSuccess} = logEntry;
                successList{nSuccess} = fileNames{ii};
                if satFlag, saturationCount = saturationCount + 1; end
            catch err
                nFail = nFail + 1;
                failList(nFail, :) = {fileNames{ii}, err.message};
                fprintf('[Converter] FAIL: %s — %s\n', fileNames{ii}, err.message);
                % 다음 파일로 계속 진행
            end
        end
        
        % waitbar를 결과 요약 표시 전에 명시적으로 즉시 닫기
        % (onCleanup도 백업 정리하지만, 사용자에게 깔끔한 UX를 위해 여기서 먼저)
        closeWaitbarSafely(fwait);
        
        % 사전 할당된 cell array의 미사용 영역 잘라내기
        successList = successList(1:nSuccess);
        failList = failList(1:nFail, :);
        if nSuccess > 0
            logContainer = vertcat(logRows{1:nSuccess});
        else
            logContainer = cell(0, 0);
        end
        
        % 로그 작성 (성공한 항목이 1개 이상일 때만)
        if ~isempty(logContainer)
            try
                writeIntegratedLog(pathway, logContainer, mode, isAll, isSerial);
            catch err
                warndlg(['Log file writing failed: ' err.message], 'Log Error');
            end
        end
        
        % [#8] 결과 요약 보고
        showSummary(N, successList, failList, saturationCount, userCancelled, pathway);
    end

    function [logEntry, satFlag] = convertFile(fullPath, mode, mask, useBits)
        [fPath, fName, ~] = fileparts(fullPath);
        info = h5info(fullPath); dataPath = findH5DataPath(info);
        data = h5read(fullPath, dataPath)';
        
        % [#3] 마스크 적용 (검출기 선택 시)
        if ~isempty(mask)
            % 크기가 일치할 때만 적용
            if isequal(size(mask), size(data))
                data(mask == 0 | isnan(mask)) = 0;  % mask=0/NaN인 픽셀을 0으로 (NaN은 uint에서 표현 불가)
            else
                warning('Converter:MaskSizeMismatch', ...
                        'Mask size %s does not match data size %s — skipped', ...
                        mat2str(size(mask)), mat2str(size(data)));
            end
        end
        
        % [#5] bit depth 선택 + saturation 사전 감지
        satFlag = false;
        outFile = fullfile(fPath, [fName, '.tif']);
        if useBits == 16
            satCount = nnz(data > 65535);
            if satCount > 0, satFlag = true; end
            imwrite(uint16(data), outFile);
        else
            % uint32 TIFF는 imwrite가 지원하지 않으므로 Tiff 클래스를 직접 사용
            writeUint32Tiff(uint32(data), outFile);
        end
        
        % 메타데이터 추출
        ic = h5read(fullPath, '/entry/instrument/user/params/Counter1');
        sc = h5read(fullPath, '/entry/instrument/user/params/Counter2');
        bc = h5read(fullPath, '/entry/instrument/user/params/Counter3');
        
        if strcmp(mode, 'Static')
            logEntry = {fName, ic, sc, bc};
        else
            ts = h5read(fullPath, '/entry/instrument/user/params/TimeStamp');
            if strcmp(mode, 'Time')
                logEntry = {fName, ts, ic, sc, bc};
            elseif strcmp(mode, 'Temperature')
                t1 = h5read(fullPath, '/entry/instrument/user/params/Temp1');
                t2 = h5read(fullPath, '/entry/instrument/user/params/Temp2');
                logEntry = {fName, ts, ic, sc, bc, t1, t2};
            elseif strcmp(mode, 'LowTemp')
                lt1 = h5read(fullPath, '/entry/instrument/user/params/LowTemp1');
                lt2 = h5read(fullPath, '/entry/instrument/user/params/LowTemp2');
                logEntry = {fName, ts, ic, sc, bc, lt1, lt2};
            end
        end
    end

    function writeIntegratedLog(saveDir, logData, mode, isAll, isSerial)
        if isempty(logData), return; end
        
        % 1. Elapsed Time 계산 (tick → hh:mm:ss 문자열)
        if ~strcmp(mode, 'Static')
            t0 = logData{1, 2};
            tick_to_sec = 7753; % 3C 빔라인 환산율
            
            colIdx = size(logData, 2) + 1;
            for r = 1:size(logData, 1)
                elapsed_sec = (logData{r, 2} - t0) / tick_to_sec;
                hh = floor(elapsed_sec / 3600);
                mm = floor(mod(elapsed_sec, 3600) / 60);
                ss = mod(elapsed_sec, 60);
                logData{r, colIdx} = sprintf('%02d:%02d:%05.2f', hh, mm, ss);
            end
        end
        
        % 2. 파일 이름 설정
        if isAll
            baseName = 'Folder_Summary';
        elseif isSerial 
            baseName = [extractBefore(logData{1,1}, '_0001'), '_Serial_Summary'];
        else 
            baseName = logData{1,1}; 
        end
        
        % 3. CSV 파일 저장 (엑셀용 테이블)
        csvFileName = fullfile(saveDir, [baseName, '.csv']);
        T = cell2table(logData);
        if strcmp(mode, 'Static')
            T.Properties.VariableNames = {'FileName','IC','SC','BC'};
        elseif strcmp(mode, 'Time')
            T.Properties.VariableNames = {'FileName','Timestamp','IC','SC','BC','Elapsed'};
        elseif strcmp(mode, 'Temperature')
            T.Properties.VariableNames = {'FileName','Timestamp','IC','SC','BC','Temp1','Temp2','Elapsed'};
        elseif strcmp(mode, 'LowTemp')
            T.Properties.VariableNames = {'FileName','Timestamp','IC','SC','BC','LowTemp1','LowTemp2','Elapsed'};
        end
        [writeOK, writeReport] = writePGIXSTableFile(T, csvFileName);
        if ~writeOK
            error('Converter:CsvWriteFailed', '%s', writeReport.Message);
        end
        
        % 4. TXT 파일 저장 
        logTextFile = fullfile(saveDir, [baseName, '_Log.txt']);
        [fid, openMessage] = fopen(logTextFile, 'w');
        if fid == -1
            error('Converter:TextLogOpenFailed', '%s', openMessage);
        end
        logCleanup = onCleanup(@() fclose(fid));
        if strcmp(mode, 'Static')
            fprintf(fid, '%-30s %10s %10s %10s\n', 'FileName', 'IC', 'SC', 'BC');
            for r = 1:size(logData,1)
                fprintf(fid, '%-30s %10.0f %10.0f %10.0f\n', logData{r,:});
            end
        elseif strcmp(mode, 'Time')
            fprintf(fid, '%-30s %12s %10s %10s %10s %12s\n', 'FileName', 'Timestamp', 'IC', 'SC', 'BC', 'Elapsed');
            for r = 1:size(logData,1)
                fprintf(fid, '%-30s %12.0f %10.0f %10.0f %10.0f %12s\n', logData{r,:});
            end
        elseif strcmp(mode, 'Temperature')
            fprintf(fid, '%-30s %12s %10s %10s %10s %10s %10s %12s\n', 'FileName', 'Timestamp', 'IC', 'SC', 'BC', 'Temp1', 'Temp2', 'Elapsed');
            for r = 1:size(logData,1)
                fprintf(fid, '%-30s %12.0f %10.0f %10.0f %10.0f %10.1f %10.1f %12s\n', logData{r,:});
            end
        elseif strcmp(mode, 'LowTemp')
            fprintf(fid, '%-30s %12s %10s %10s %10s %10s %10s %12s\n', 'FileName', 'Timestamp', 'IC', 'SC', 'BC', 'LowTemp1', 'LowTemp2', 'Elapsed');
            for r = 1:size(logData,1)
                fprintf(fid, '%-30s %12.0f %10.0f %10.0f %10.0f %10.2f %10.2f %12s\n', logData{r,:});
            end
        end
    end

    function path = findH5DataPath(info)
        % [#9] 모든 2D+ 데이터셋을 수집 후 가장 큰 것 선택
        % 메타데이터(예: 캘리브레이션 행렬)보다 실제 이미지가 훨씬 크다는 점을 활용
        % 'data'라는 이름이 있으면 동률 시 우선
        candidates = collectDatasets(info);
        
        if isempty(candidates)
            path = '';
            return;
        end
        
        % 픽셀 수 기준 정렬 (내림차순)
        sizes = cellfun(@(c) prod(c.dims), candidates);
        [~, idx] = sort(sizes, 'descend');
        candidates = candidates(idx);
        
        % 'data'라는 이름이 가장 큰 것에 가깝게 있다면 우선
        % (가장 큰 것 ±10% 이내에서 'data' 이름 검색)
        topSize = sizes(idx(1));
        for k = 1:length(candidates)
            if candidates{k}.size >= topSize * 0.9 && ...
               (endsWith(candidates{k}.path, '/data') || endsWith(candidates{k}.path, '/Data'))
                path = candidates{k}.path;
                return;
            end
        end
        
        % fallback: 가장 큰 것
        path = candidates{1}.path;
    end

    function out = collectDatasets(info)
        % info를 재귀적으로 탐색하여 모든 2D+ 데이터셋의 경로/크기를 수집
        nMax = countDatasets(info);
        out = cell(1, nMax);
        nFound = 0;
        [out, nFound] = collectDatasetsInto(info, out, nFound);
        out = out(1:nFound);
    end

    function nTotal = countDatasets(info)
        nTotal = 0;
        for i = 1:length(info.Datasets)
            sz = info.Datasets(i).Dataspace.Size;
            if length(sz) >= 2
                nTotal = nTotal + 1;
            end
        end
        for k = 1:length(info.Groups)
            nTotal = nTotal + countDatasets(info.Groups(k));
        end
    end

    function [out, nFound] = collectDatasetsInto(info, out, nFound)
        for i = 1:length(info.Datasets)
            sz = info.Datasets(i).Dataspace.Size;
            if length(sz) >= 2
                fullName = [info.Name '/' info.Datasets(i).Name];
                fullName = strrep(fullName, '//', '/');  % 루트 처리
                nFound = nFound + 1;
                out{nFound} = struct('path', fullName, 'dims', sz, 'size', prod(sz));
            end
        end
        for k = 1:length(info.Groups)
            [out, nFound] = collectDatasetsInto(info.Groups(k), out, nFound);
        end
    end

    function closeWaitbarSafely(h)
        % waitbar를 확실하게 닫는다 (close 대신 delete 사용 + drawnow로 즉시 처리)
        % 어떤 종료 경로에서도 안전하게 작동
        try
            if ishandle(h) && isvalid(h)
                delete(h);     % close()보다 강제적
                drawnow;       % 이벤트 큐를 즉시 처리하여 잔류 방지
            end
        catch
            % 이미 닫혔거나 핸들이 무효인 경우 무시
        end
    end

    function writeUint32Tiff(img, filename)
        % uint32 TIFF 작성 (imwrite 미지원 → Tiff 클래스 사용)
        % img: uint32 2D matrix
        % filename: 출력 파일 경로
        t = Tiff(filename, 'w');
        try
            tagstruct.ImageLength         = size(img, 1);
            tagstruct.ImageWidth          = size(img, 2);
            tagstruct.Photometric         = Tiff.Photometric.MinIsBlack;
            tagstruct.BitsPerSample       = 32;
            tagstruct.SamplesPerPixel     = 1;
            tagstruct.SampleFormat        = Tiff.SampleFormat.UInt;  % unsigned integer
            tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
            tagstruct.Compression         = Tiff.Compression.None;
            tagstruct.Software            = 'Converter_gui v2.2.3';
            t.setTag(tagstruct);
            t.write(img);
            t.close();
        catch err
            t.close();  % 에러 시에도 핸들 닫기
            rethrow(err);
        end
    end

    function mask = loadDetectorMask(detIdx)
        % [#3] 검출기 마스크 로딩 (선택 사항)
        % detIdx 1=None, 2=Eiger4M, 3=MarCCD
        try
            switch detIdx
                case 2  % Eiger4M
                    [mask, ~, maskReport] = loadPGIXSDetectorMask('Eiger4M');
                case 3  % MarCCD
                    [mask, ~, maskReport] = loadPGIXSDetectorMask('MarCCD');
                otherwise
                    maskReport = struct('FallbackUsed', false, 'Message', '');
                    mask = [];
            end
            if maskReport.FallbackUsed && ~isempty(maskReport.Message)
                warning('Converter:MaskFallback', '%s', maskReport.Message);
            end
        catch err
            warning('Converter:MaskLoadFailed', 'Mask loading failed: %s', err.message);
            mask = [];
        end
    end

    function showSummary(N, successList, failList, satCount, wasCancelled, saveDir)
        % [#8] 변환 결과 종합 요약
        nSuccess = length(successList);
        nFail = size(failList, 1);
        
        msgParts = cell(max(nFail, 10) + 12, 1);
        partCount = 1;
        msgParts{partCount} = sprintf('=== Conversion Summary ===\n\n');
        if wasCancelled
            partCount = partCount + 1;
            msgParts{partCount} = sprintf('⚠ Cancelled by user.\n\n');
        end
        partCount = partCount + 1;
        msgParts{partCount} = sprintf('Total selected   : %d\n', N);
        partCount = partCount + 1;
        msgParts{partCount} = sprintf('Successful       : %d\n', nSuccess);
        partCount = partCount + 1;
        msgParts{partCount} = sprintf('Failed           : %d\n', nFail);
        if satCount > 0
            partCount = partCount + 1;
            msgParts{partCount} = sprintf('⚠ Saturation (>65535) detected in %d file(s)\n', satCount);
            partCount = partCount + 1;
            msgParts{partCount} = sprintf('  → Consider re-running with uint32 bit depth.\n');
        end
        
        if nFail > 0
            partCount = partCount + 1;
            msgParts{partCount} = sprintf('\n--- Failed files ---\n');
            for k = 1:min(nFail, 10)  % 최대 10개만 표시
                partCount = partCount + 1;
                msgParts{partCount} = sprintf('  • %s\n     (%s)\n', failList{k,1}, failList{k,2});
            end
            if nFail > 10
                partCount = partCount + 1;
                msgParts{partCount} = sprintf('  ... and %d more (see Command Window)\n', nFail - 10);
            end
        end
        
        % 실패 로그를 파일로도 저장 (실패가 있을 때)
        if nFail > 0
            failFile = fullfile(saveDir, 'Conversion_Failures.log');
            try
                [fid, openMessage] = fopen(failFile, 'w');
                if fid == -1
                    error('Converter:FailureLogOpenFailed', '%s', openMessage);
                end
                failCleanup = onCleanup(@() fclose(fid));
                fprintf(fid, 'Conversion failures from %s\n\n', string(datetime("now")));
                for k = 1:nFail
                    fprintf(fid, '%s\n  Error: %s\n\n', failList{k,1}, failList{k,2});
                end
                partCount = partCount + 1;
                msgParts{partCount} = sprintf('\nFailure log saved: Conversion_Failures.log');
            catch err
                warning('Converter:FailureLogWriteFailed', ...
                    'Failure log writing failed: %s', err.message);
            end
        end
        msg = [msgParts{1:partCount}];
        
        % 결과에 따라 아이콘 다르게
        if nFail == 0 && ~wasCancelled
            msgbox(msg, 'Conversion Complete', 'help');
        elseif nFail > 0
            msgbox(msg, 'Conversion Finished with Errors', 'warn');
        else
            msgbox(msg, 'Conversion Cancelled', 'warn');
        end
    end
end
