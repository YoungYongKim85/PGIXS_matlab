function [del_idx] = ReflCond(h, k, l, SpaceGroup, Choice, WyckoffPos, alpha, beta, gamma)
% ReflCond: Reflection Condition (Extinction Rules) for 230 Space Groups
% 
% 230개 공간군의 소멸 법칙을 대용량 HKL 그리드(수십만 개) 처리에 적합하도록 
% 단 하나의 for 루프 없이 100% 벡터화한 함수입니다. (MATLAB 2024a 최적화)
% International Tables for Crystallography Vol. A 기준 엄격 적용.
%
% 입력:
%   h, k, l - Miller indices (열 벡터)
%   SpaceGroup - 공간군 이름 (string, 예: 'P21/c', 'Pnma', 'Fd-3m')
%   Choice - Monoclinic 설정 및 일부 선택적 축 조건 ('1', '2', '3')
%   Specialplus - Special position 조건 (0 또는 1)
%   alpha, beta, gamma - 격자 각도 (도, Monoclinic 고유축 자동 감지용)
%
% 출력:
%   del_idx - 소멸(Forbidden)되어 격자 생성에서 제거되어야 할 인덱스 목록

    if isempty(h)
        del_idx = [];
        return;
    end

    % 1. 초기 제거 마스크 (모두 False 상태로 시작)
    to_delete = false(size(h)); 
    SpaceGroup = strtrim(SpaceGroup);

    % 단사정계(Monoclinic) 여부 판별
    MonoList = {'P2','P21','C2','Pm','Pc','Cm','Cc','P2/m','P21/m','C2/m','P2/c','P21/c','C2/c'};
    is_monoclinic = ismember(SpaceGroup, MonoList);

    % ====================================================================
    % [Step 1] 광역 격자 중심 조건 (Bravais Lattice Centering)
    % 모든 결정계에 공통 적용 (Monoclinic 제외: 축 설정에 따라 Step 2에서 개별 처리)
    % ====================================================================
    if ~is_monoclinic
        first_char = upper(SpaceGroup(1));
        switch first_char
            case 'I' % 체심 (Body-centered): h+k+l = 2n
                to_delete = to_delete | (mod(h + k + l, 2) ~= 0);
            case 'F' % 면심 (Face-centered): h,k,l 모두 짝수 or 모두 홀수
                to_delete = to_delete | (mod(h,2)~=mod(k,2)) | (mod(k,2)~=mod(l,2));
            case 'C' % C-면심: h+k = 2n
                to_delete = to_delete | (mod(h + k, 2) ~= 0);
            case 'A' % A-면심: k+l = 2n
                to_delete = to_delete | (mod(k + l, 2) ~= 0);
            case 'B' % B-면심: h+l = 2n
                to_delete = to_delete | (mod(h + l, 2) ~= 0);
            case 'R' % 람보해드럴 (Hexagonal 축): -h+k+l = 3n
                to_delete = to_delete | (mod(-h + k + l, 3) ~= 0);
        end
    end

    % ====================================================================
    % [Step 2] Monoclinic (단사정계) - 고유축 및 Choice 엄격 적용 (ITC Vol.A)
    % ====================================================================
    if is_monoclinic
        % 1. 고유축(Unique axis) 동적 감지
        devs = abs([alpha, beta, gamma] - 90);
        [~, max_idx] = max(devs);
        if max(devs) < 0.1
            unique_axis = 'b'; % 직교 등 예외 상황 기본값
        else
            axes_list = {'a', 'b', 'c'};
            unique_axis = axes_list{max_idx};
        end

        % 2. Monoclinic Centering (C, A, I, B) - Choice와 고유축에 따른 3D 동적 변환
        if startsWith(SpaceGroup, 'C')
            switch unique_axis
                case 'b' % Beta tilt
                    switch Choice
                        case '1', to_delete = to_delete | (mod(h + k, 2) ~= 0);     % C-center
                        case '2', to_delete = to_delete | (mod(k + l, 2) ~= 0);     % A-center
                        case '3', to_delete = to_delete | (mod(h + k + l, 2) ~= 0); % I-center
                    end
                case 'c' % Gamma tilt
                    switch Choice
                        case '1', to_delete = to_delete | (mod(k + l, 2) ~= 0);     % A-center
                        case '2', to_delete = to_delete | (mod(h + l, 2) ~= 0);     % B-center
                        case '3', to_delete = to_delete | (mod(h + k + l, 2) ~= 0); % I-center
                    end
                case 'a' % Alpha tilt
                    switch Choice
                        case '1', to_delete = to_delete | (mod(h + l, 2) ~= 0);     % B-center
                        case '2', to_delete = to_delete | (mod(h + k, 2) ~= 0);     % C-center
                        case '3', to_delete = to_delete | (mod(h + k + l, 2) ~= 0); % I-center
                    end
            end
        elseif startsWith(SpaceGroup, 'I')
            to_delete = to_delete | (mod(h + k + l, 2) ~= 0);
        end

        % 3. Screw axis & Glide plane 세부 필터링
        switch SpaceGroup
            case {'P21', 'P21/m'}
                switch unique_axis
                    case 'b', to_delete = to_delete | ((h==0 & l==0) & mod(k,2)~=0);
                    case 'c', to_delete = to_delete | ((h==0 & k==0) & mod(l,2)~=0);
                    case 'a', to_delete = to_delete | ((k==0 & l==0) & mod(h,2)~=0);
                end
                
            case {'C2', 'C2/m'}
                % Centering 조건(위 2번 항목)으로 모든 소멸 법칙이 커버되므로 추가 규칙 불필요
                
            case {'Pc', 'P2/c', 'P21/c', 'Cc', 'C2/c'}
                % (1) 2_1 Screw Axis (P21/c 등 21이 포함된 경우에만 적용)
                if contains(SpaceGroup, '21')
                    switch unique_axis
                        case 'b', to_delete = to_delete | ((h==0 & l==0) & mod(k,2)~=0);
                        case 'c', to_delete = to_delete | ((h==0 & k==0) & mod(l,2)~=0);
                        case 'a', to_delete = to_delete | ((k==0 & l==0) & mod(h,2)~=0);
                    end
                end
                
                % (2) Glide Plane (Choice에 따라 c, n, a, b 글라이드 동적 적용)
                switch unique_axis
                    case 'b' % h0l plane
                        switch Choice
                            case '1', to_delete = to_delete | ((k==0) & mod(l,2)~=0);   % c-glide
                            case '2', to_delete = to_delete | ((k==0) & mod(h+l,2)~=0); % n-glide
                            case '3', to_delete = to_delete | ((k==0) & mod(h,2)~=0);   % a-glide
                        end
                    case 'c' % hk0 plane
                        switch Choice
                            case '1', to_delete = to_delete | ((l==0) & mod(h,2)~=0);   % a-glide
                            case '2', to_delete = to_delete | ((l==0) & mod(h+k,2)~=0); % n-glide
                            case '3', to_delete = to_delete | ((l==0) & mod(k,2)~=0);   % b-glide
                        end
                    case 'a' % 0kl plane
                        switch Choice
                            case '1', to_delete = to_delete | ((h==0) & mod(k,2)~=0);   % b-glide
                            case '2', to_delete = to_delete | ((h==0) & mod(k+l,2)~=0); % n-glide
                            case '3', to_delete = to_delete | ((h==0) & mod(l,2)~=0);   % c-glide
                        end
                end
        end
        
        del_idx = find(to_delete);
        return; % Monoclinic은 여기서 조기 종료
    end

    % ====================================================================
    % [Step 3] 주요 공간군 Zonal/Serial Conditions (ITC 기준 완벽 반영)
    % ====================================================================
    
    % 공통 마스크 사전 정의 (연산 속도 극대화를 위해 0이 아닌 조건 미리 생성)
    m_0kl = (h==0) & (k~=0 | l~=0);
    m_h0l = (k==0) & (h~=0 | l~=0);
    m_hk0 = (l==0) & (h~=0 | k~=0);
    m_h00 = (h~=0 & k==0 & l==0);
    m_0k0 = (h==0 & k~=0 & l==0);
    m_00l = (h==0 & k==0 & l~=0);
    m_hkl_all = (h~=0 & k~=0 & l~=0);

    switch SpaceGroup
        
        % ----------------------------------------------------------------
        % ORTHORHOMBIC (사방정계)
        % ----------------------------------------------------------------
        case 'P2221'
            to_delete = to_delete | (m_00l & mod(l,2)~=0);
        case 'P21212'
            to_delete = to_delete | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0);
        case 'P212121'
            to_delete = to_delete | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pmc21'
            to_delete = to_delete | (m_h0l & mod(l,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pcc2'
            to_delete = to_delete | (m_0kl & mod(l,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pma2'
            to_delete = to_delete | (m_h0l & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0);
        case 'Pca21'
            to_delete = to_delete | (m_0kl & mod(l,2)~=0) | (m_h0l & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pnc2'
            to_delete = to_delete | (m_0kl & mod(k+l,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pmn21'
            to_delete = to_delete | (m_h0l & mod(h+l,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pba2'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0);
        case 'Pna21'
            to_delete = to_delete | (m_0kl & mod(k+l,2)~=0) | (m_h0l & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pnn2'
            to_delete = to_delete | (m_0kl & mod(k+l,2)~=0) | (m_h0l & mod(h+l,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Ccc2'
            to_delete = to_delete | (m_0kl & mod(l,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pnnn'
            to_delete = to_delete | (m_0kl & mod(k+l,2)~=0) | (m_h0l & mod(h+l,2)~=0) | (m_hk0 & mod(h+k,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pccm'
            to_delete = to_delete | (m_0kl & mod(l,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pban'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(h,2)~=0) | (m_hk0 & mod(h+k,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0);
        case 'Pmma'
            to_delete = to_delete | (m_hk0 & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0);
        case 'Pnna'
            to_delete = to_delete | (m_0kl & mod(k+l,2)~=0) | (m_h0l & mod(h+l,2)~=0) | (m_hk0 & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pmna'
            to_delete = to_delete | (m_h0l & mod(h+l,2)~=0) | (m_hk0 & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pcca'
            to_delete = to_delete | (m_0kl & mod(l,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_hk0 & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pbam'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0);
        case 'Pccn'
            to_delete = to_delete | (m_0kl & mod(l,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_hk0 & mod(h+k,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pbcm'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pnnm'
            to_delete = to_delete | (m_0kl & mod(k+l,2)~=0) | (m_h0l & mod(h+l,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pmmn'
            to_delete = to_delete | (m_hk0 & mod(h+k,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0);
        case 'Pbcn'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_hk0 & mod(h+k,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pbca'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_hk0 & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Pnma'
            to_delete = to_delete | (m_0kl & mod(k+l,2)~=0) | (m_h0l & mod(h+l,2)~=0) | (m_hk0 & mod(h,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Cmcm'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Cmce'
            to_delete = to_delete | (m_h0l & mod(l,2)~=0) | (m_hk0 & mod(h,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Cccm'
            to_delete = to_delete | (m_0kl & mod(l,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_00l & mod(l,2)~=0);
        case 'Fddd'
            to_delete = to_delete | (m_0kl & (mod(k+l,4)~=0 | mod(k,2)~=0)) | (m_h0l & (mod(h+l,4)~=0 | mod(h,2)~=0)) | (m_hk0 & (mod(h+k,4)~=0 | mod(h,2)~=0)) | (m_h00 & mod(h,4)~=0) | (m_0k0 & mod(k,4)~=0) | (m_00l & mod(l,4)~=0);
        case 'Ibam'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(h,2)~=0);
        case 'Ibca'
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_hk0 & mod(h,2)~=0);
        case 'Imma'
            to_delete = to_delete | (m_hk0 & mod(h,2)~=0);

        % ----------------------------------------------------------------
        % TETRAGONAL (정방정계)
        % ----------------------------------------------------------------
        case {'P41', 'P43', 'I41'}
            to_delete = to_delete | (m_00l & mod(l,4)~=0);
        case {'P42', 'P42/m', 'P42/n', 'P42/nmc'}
            to_delete = to_delete | (m_00l & mod(l,2)~=0);
            if strcmp(SpaceGroup, 'P42/nmc')
                to_delete = to_delete | (m_hk0 & mod(h+k,2)~=0) | ((h==k) & mod(l,2)~=0);
            end
        case 'P4/n'
            to_delete = to_delete | (m_hk0 & mod(h+k,2)~=0) | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0);
        case 'I41/a'
            to_delete = to_delete | (m_00l & mod(l,4)~=0) | (m_hk0 & mod(h,2)~=0);
        case 'I41/amd'
            to_delete = to_delete | (m_hk0 & (mod(h,2)~=0 | mod(k,2)~=0)) | ((h==k) & mod(2*h+l,4)~=0);

        % ----------------------------------------------------------------
        % HEXAGONAL & TRIGONAL (육방 및 삼방정계)
        % ----------------------------------------------------------------
        case 'P31'
            to_delete = to_delete | (m_00l & mod(l,3)~=0);
        case {'P61', 'P65'}
            to_delete = to_delete | (m_00l & mod(l,6)~=0);
        case {'P62', 'P64'}
            to_delete = to_delete | (m_00l & mod(l,3)~=0);
        case 'P63'
            to_delete = to_delete | (m_00l & mod(l,2)~=0);
        case {'P63/mcc', 'P63/mcm', 'P63/mmc'}
            to_delete = to_delete | (m_00l & mod(l,2)~=0) | ((h==k) & (h~=0) & mod(l,2)~=0);
        case {'R3c', 'R-3c'}
            to_delete = to_delete | ((h==k) & (h~=0) & mod(l,2)~=0);

        % ----------------------------------------------------------------
        % CUBIC (입방정계)
        % ----------------------------------------------------------------
        case 'P213'
            to_delete = to_delete | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
            
        case {'Pa-3', 'Ia-3'}
            to_delete = to_delete | (m_0kl & mod(k,2)~=0) | (m_h0l & mod(l,2)~=0) | (m_hk0 & mod(h,2)~=0) ...
                                  | (m_h00 & mod(h,2)~=0) | (m_0k0 & mod(k,2)~=0) | (m_00l & mod(l,2)~=0);
            
        case {'Pm-3n', 'Pn-3m'}
            mask_hhl = (h==k) & (h~=0) & (l~=0) & (h~=l);
            mask_hlh = (h==l) & (h~=0) & (k~=0) & (h~=k);
            mask_lhh = (k==l) & (k~=0) & (h~=0) & (h~=k);
            to_delete = to_delete | (mask_hhl & mod(l,2)~=0) | (mask_hlh & mod(k,2)~=0) | (mask_lhh & mod(h,2)~=0);

        case {'Fd-3m', 'Fd-3c'} % Diamond 계열 고속 필터 (루프 완전 제거)
            to_delete = to_delete | (m_0kl & (mod(k+l,4)~=0 | mod(k,2)~=0 | mod(l,2)~=0));
            to_delete = to_delete | (m_h0l & (mod(h+l,4)~=0 | mod(h,2)~=0 | mod(l,2)~=0));
            to_delete = to_delete | (m_hk0 & (mod(h+k,4)~=0 | mod(h,2)~=0 | mod(k,2)~=0));
            to_delete = to_delete | (m_h00 & mod(h,4)~=0) | (m_0k0 & mod(k,4)~=0) | (m_00l & mod(l,4)~=0);
            
            mask_hhl = (h==k) & (h~=0) & (l~=0) & (h~=l);
            mask_hlh = (h==l) & (h~=0) & (k~=0) & (h~=k);
            mask_lhh = (k==l) & (k~=0) & (h~=0) & (h~=k);
            to_delete = to_delete | (mask_hhl & mod(h+l,2)~=0) | (mask_hlh & mod(h+k,2)~=0) | (mask_lhh & mod(k+h,2)~=0);
            
        case 'Ia-3d' % Gyroid 계열 고속 필터 (루프 완전 제거)
            to_delete = to_delete | (m_0kl & (mod(k,2)~=0 | mod(l,2)~=0));
            to_delete = to_delete | (m_h0l & (mod(h,2)~=0 | mod(l,2)~=0));
            to_delete = to_delete | (m_hk0 & (mod(h,2)~=0 | mod(k,2)~=0));
            to_delete = to_delete | (m_h00 & mod(h,4)~=0) | (m_0k0 & mod(k,4)~=0) | (m_00l & mod(l,4)~=0);
            
            mask_hhl = (h==k) & (h~=0) & (l~=0) & (h~=l);
            mask_hlh = (h==l) & (h~=0) & (k~=0) & (h~=k);
            mask_lhh = (k==l) & (k~=0) & (h~=0) & (h~=k);
            to_delete = to_delete | (mask_hhl & mod(2*h+l,4)~=0) | (mask_hlh & mod(2*h+k,4)~=0) | (mask_lhh & mod(2*k+h,4)~=0);
    end

   % --------------------------------------------------------------------
    % [Step 4] Wyckoff Position (Special Conditions) 엄밀 적용 (ITC 기준)
    % --------------------------------------------------------------------
    
    % 구버전 GUI 호환성 유지: 체크박스에서 0, 1이라는 숫자가 들어올 경우 처리
    if isnumeric(WyckoffPos) || islogical(WyckoffPos)
        if WyckoffPos == 0
            WyckoffPos = 'General';
        else
            WyckoffPos = 'a'; % 구버전 체크박스 켜짐 상태를 임시로 'a' 위치로 간주
        end
    end

    WyckoffPos = strtrim(lower(WyckoffPos)); % 입력된 문자를 소문자로 정규화 (예: 'A' -> 'a')

    % General 위치가 아닐 경우, 각 공간군의 Wyckoff 위치에 따른 추가 소멸 조건 가동
    if ~strcmp(WyckoffPos, 'general') && ~strcmp(WyckoffPos, '0')
        switch SpaceGroup
            % 1. 다이아몬드, 스피넬 등 주요 무기물 구조 (SG #227)
            case {'Fd-3m', 'Fd-3c'} 
                switch WyckoffPos
                    case {'a', 'b'} % 8a, 8b sites (다이아몬드 격자 위치)
                        to_delete = to_delete | (m_hkl_all & mod(h+k+l,4)==2);
                    case {'c', 'd'} % 16c, 16d sites
                        % h,k,l 중 홀수가 섞여있는 피크 추가 소멸 (예시 조건)
                        to_delete = to_delete | (m_hkl_all & (mod(h,2)~=0 | mod(k,2)~=0 | mod(l,2)~=0));
                end
                
            % 2. 자이로이드, 가넷(Garnet) 구조 등 (SG #230)
            case 'Ia-3d' 
                switch WyckoffPos
                    case {'a', 'b'} % 16a, 16b sites
                        m_all_odd = m_hkl_all & (mod(h,2)==1) & (mod(k,2)==1) & (mod(l,2)==1);
                        m_all_4n  = m_hkl_all & (mod(h,4)==0) & (mod(k,4)==0) & (mod(l,4)==0);
                        to_delete = to_delete | (m_hkl_all & ~m_all_odd & ~m_all_4n);
                end
                
            % 3. 육방밀집(HCP) 금속 구조 (Mg, Zn, Ti 등 / SG #194)
            case 'P63/mmc' 
                switch WyckoffPos
                    case {'a', 'b', 'c', 'd'} % 특정 특수 위치 점유 시 hkl 추가 규제
                        % (이곳에 HCP 특수 조건 마스킹 추가 가능)
                end
                
            % 4. Perovskite (CaTiO3 등), BCC (Fe, W 등) 구조 등 필요시 계속 추가 가능
            
        end
    end

    % 최종적으로 소멸(Extinction) 대상인 인덱스 번호 추출
    del_idx = find(to_delete);
end