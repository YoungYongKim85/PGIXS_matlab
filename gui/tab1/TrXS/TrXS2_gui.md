% TrXS2_gui.md
# TrXS2_gui — Transmission SAXS 스택 분석 GUI

PAL(포항가속기연구소) 3C 빔라인의 **투과(Transmission) SAXS** 측정에서, 시계열/스택 형태로 수집한 2D 패턴을 보정하고 1D 곡선으로 환원하는 MATLAB App GUI.

---

## 1. 개요

- 다중 프레임(시계열, in-situ) 2D 검출기 이미지를 한 번에 불러와 스택으로 관리한다.
- Q-map과 검출기 보정(입체각·편광·효율)을 적용하고, 프레임별 1D 환원(원형 평균 / 라인 컷 / 방위각 컷)을 수행한다.
- 실시간 측정 중 새 파일을 자동으로 받아 갱신하는 **Auto-refresh(스트리밍)** 모드를 지원한다.
- 핵심 설계 원칙은 **"검출기 갭/불량 픽셀은 NaN으로 두고 평균에서 단순 제외, 인위적 보간·평활 없음"** 이다(아래 4절).

## 2. 요구 환경

- **MATLAB R2024a** (App/uifigure 기반).
- **Parallel Computing Toolbox** — 병렬 처리(`parfor`, `parallel.pool.DataQueue`)에 필요. *선택 사항이며, 미설치/풀 미생성 시 자동으로 serial로 동작한다.*
- HDF5 입력은 내장 `h5read` 사용(추가 설치 불필요).

## 3. 의존 파일 (MATLAB 경로에 함께 있어야 함)

GUI 본체 외에 아래 외부 `.m` 함수들이 경로에 있어야 정상 동작한다.

| 함수 | 역할 |
|---|---|
| `Anglecut1d` | 임의 각도 라인/원형 컷(보간 기반, NaN 드롭) |
| `FastRAvg2DQ` | 빠른 방사 평균(Q-map 동반) |
| `SolidAngle`, `Polarization` | 입체각·편광 보정맵 |
| `Eff_correc`, `Eff_correc2` | 검출기 효율 보정(Kapton/Si 감쇠) |
| `Qmaping_tr` | 투과 기하 Q-map 생성 |
| `get_modern_mask` | ROI/마스크 영역 지정 UI |
| `getFiles` | 파일명 패턴으로 프레임 목록 검색 |
| `NewFileName` | 저장용 파일명 정리(없으면 Save 시 오류 — 7절 참고) |
| `HeatmapQ_gui` | Q-heatmap 보조 창 |
| `KaptonAttLength8-30.mat`, `SiAttLength8-30.mat` | 효율 보정용 감쇠 길이 데이터 |

> 1D 환원 코어(`process1dSlice_qbin`, `bin_median_fast`), 방위각 후처리(`azi_postprocess`), 갭 경계 보존 평활(`smooth_segments_respect_nan`), 진행률 헬퍼(`makeParProgress`)는 본 파일 안에 **로컬 함수**로 포함되어 있다.

## 4. 데이터 처리 정책 (핵심)

이 프로그램의 평균/컷은 다음 원칙을 따른다.

- **갭/불량 픽셀 = NaN.** 사전에 만든 마스크(갭·hot pixel)를 로드 시 적용하여 해당 픽셀을 NaN으로 만든다.
- **NaN은 평균에서 단순 제외**(`omitnan` / 유효 픽셀만 누적)되며, `fillmissing`이나 보간으로 메우지 않는다.
- **갭을 넘는 평활 금지.** Savitzky–Golay 등 평활이 갭 너머 값을 인접 bin에 섞지 않는다(갭 경계 오염 = 왜곡 제거).
- **측정된 0·음수 강도는 보존**한다. 갭은 이미 NaN으로 처리되므로, `I<=0`을 갭으로 간주해 버리지 않는다(고각 강도가 위로 편향되는 것을 방지).
- 원형 평균은 q-bin별 **Huber 로버스트 평균**으로 이상치 영향을 줄인다.

### 동작 토글 (기본값 보수적)

| 토글 | 위치 | 기본 | 의미 |
|---|---|---|---|
| `DO_SPIKE_REJECT` | `process1dSlice_qbin` | `false` | hot pixel/스파이크만 NaN 처리(보간 없음). Bragg/형상 피크 보존 위해 기본 off |
| `DO_SMOOTH` | `process1dSlice_qbin` | `false` | 켜도 NaN 경계로 분할한 구간 내부에서만 SG 평활 |
| `MIN_VALID_FRAC` | `azi_postprocess` | `0.0` | 방위각: 최대 대비 이 비율 미만 방향 제거(예전 40% 컷 원하면 `0.4`) |
| `EXCLUDE_NONPOSITIVE` | 각 평균/컷 함수 | `false` | `true`면 0·음수도 갭으로 제외(예전 동작 복원) |

## 5. 표준 워크플로우

1. **경로/파일명 지정** 후 스택 로드 (`Openimage2`). 로드 시 마스크(NaN) 적용·포화 제거(`D>1e9 → NaN`).
2. **마스크/ROI 지정** (필요 시, `get_modern_mask`).
3. **q-Cal & 보정** (`Qcalc`): Q-map 생성 + 입체각·편광·효율 보정. 보정인자는 **1회 계산 후 `param.InvFactor`에 캐시**되어 모든 프레임/새 파일에 재사용된다(매 새로고침마다 재계산하지 않음).
4. **1D 환원**: 원형 평균(`CircularAve2`) / 라인 컷(`Linecut2`) / 방위각 컷(`Azilinecut2`).
5. **배경 보정·정규화** (`Bkgload2`, `NormalFactor`, `NormalROII`).
6. **저장** (`Saveget2/3/4`, `SaveStack`) — 1D 스택, 방위각, ROI 적분 등.

In-situ 측정 시에는 **Auto-refresh**(`Autoplot`)가 새 프레임을 받아 위 단계를 자동 반복한다.

## 6. 주요 기능 / 콜백

- **로드/표시**: `Openimage2`, `Updateimage2`, `Imageplay2`, `GridRemove2`(격자 제거).
- **기하/보정**: `Qcalc`(q-Cal+보정), `PointFind2`(빔센터), `Openinfo2`(메타데이터).
- **1D 환원**: `CircularAve2`(q-binning 원형 평균), `Linecut2`(라인 컷), `Azilinecut2`(방위각 컷), `Drawline2`(컷 선 지정).
- **시계열 플롯**: `Plot1dseries`, `PlotAziseries2`, `PlotROI`, `update*plot`, Q/Azi heatmap.
- **정규화/배경**: `NormalFactor`, `NormalFactorAzi`, `NormalROII`, `Bkgload2`.
- **저장**: `Saveget2/3/4`, `SavegetX`, `SaveStack`.
- **자동화**: `Autoplot`(스트리밍), `TimeUpdate`, `RefreshAllPlots`.

## 7. 병렬 처리 & 진행률

- 1D 환원(`CircularAve2`/`Linecut2`/`Azilinecut2`)은 Parallel 체크 시 `parfor`로 프레임을 분산 처리한다.
- 진행률은 로딩과 동일한 `parallel.pool.DataQueue` + `afterEach` 패턴(`makeParProgress`)으로 `n / N (남은 시간: …s)` 형태로 표시된다.
- 진행률 갱신은 **정수 % 단위로 throttle**(최대 ~100회)하고 `try/catch`로 보호하여, 빠른 cut에서 다이얼로그 갱신이 폭주해 창이 닫히는 문제를 방지한다.

## 8. 문제 해결

- **Save 시 `Unrecognized function 'NewFileName'`**: `NewFileName.m`이 경로에 없음 → 동봉된 `NewFileName.m`을 경로에 두면 해결(TrXS/GIXS 계열 공통 의존).
- **처리 중 GUI 창이 닫힘**: 처리 콜백은 `try/catch`로 감싸 오류 시 창을 닫는 대신 에러 팝업을 띄운다. 팝업 메시지가 실제 원인(줄/함수)을 알려준다.
- **MATLAB 전체가 종료**: 보통 메모리 부족(OOM). 대용량 스택은 Parallel 워커 수를 줄이거나(`parpool(2)`) 프레임 수를 나누어 처리.
- **고각이 이상하게 높음**: 예전 `I<=0` 제외 동작이 남아 있을 때. 현재 정책은 측정 0·음수를 보존하므로 정상.

## 9. 최근 개선 이력

- 원형/방위각 평균의 `fillmissing`+SG 평활(갭 경계 오염) 제거 → NaN 보존 정책으로 통일.
- 방위각의 40% edge 컷·강제 스파이크 제거를 옵션화(기본 off).
- `I<=0` 강도 부호 제외를 제거하고 finite 기준으로 통일(`EXCLUDE_NONPOSITIVE`로 복원 가능).
- 보정인자 1회 계산·캐시(`param.InvFactor`)로 Auto-refresh 재계산 제거.
- 1D 환원 `parfor` 진행률 표시 추가 + throttle/`try/catch` 방어.