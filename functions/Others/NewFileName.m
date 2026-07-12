function FN = NewFileName(FileName)
% NewFileName - 저장용 기본 파일명 생성 헬퍼
%
%   FN = NewFileName(FileName)
%
%   여러 GUI(TrXS_gui, TrXS2_gui, GIXS_gui, GIXS2_gui)의 Save 콜백에서
%   공통으로 호출되는 외부 헬퍼. 입력 파일명을 받아 '저장에 안전한
%   기본 이름'을 돌려준다.
%
%   동작:
%     1) 전체 경로/확장자가 들어와도 이름 부분만 추출 (fileparts).
%     2) 파일 시스템에서 허용되지 않는 문자( \ / : * ? " < > | )를 '_'로 치환.
%     3) 앞뒤 공백 제거.
%     4) 결과가 비면 'output'으로 대체.
%
%   주의: 프레임 인덱스(_0001 등) 제거는 load 단계의
%         extractBefore(FileName,'_0001')가 담당하므로 여기서는 하지 않는다.
%
%   이 함수는 어떤 입력에 대해서도 예외를 던지지 않는다(Save 콜백 보호).

    % --- 입력 방어 ---
    if nargin < 1 || isempty(FileName)
        FN = 'output';
        return;
    end

    if isstring(FileName)
        if numel(FileName) ~= 1
            FN = 'output';
            return;
        end
        name = char(FileName);
    elseif ischar(FileName)
        name = FileName;
    else
        % 예상치 못한 타입 -> 안전하게 기본값
        FN = 'output';
        return;
    end

    % --- 경로/확장자 제거 (전체 경로가 들어와도 안전) ---
    [~, base, ~] = fileparts(name);
    if isempty(base)
        base = name;
    end

    % --- 파일 시스템 비허용 문자 치환 ---
    base = regexprep(base, '[\\/:*?"<>|]', '_');
    base = strtrim(base);

    if isempty(base)
        FN = 'output';
    else
        FN = base;
    end
end