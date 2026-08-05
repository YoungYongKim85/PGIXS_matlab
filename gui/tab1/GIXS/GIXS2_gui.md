# GIXS2_gui — Grazing-Incidence SAXS 스택 분석 GUI

PAL(포항가속기연구소) 3C 빔라인의 **스침각 입사(Grazing-Incidence) SAXS** 측정에서, 시계열/스택 2D 패턴을 GI 기하로 보정하고 1D 곡선으로 환원하는 MATLAB App GUI. TrXS2_gui의 GI 버전에 해당한다.

---

## 1. 개요

- 다중 프레임(시계열, in-situ) GI 2D 이미지를 스택으로 불러와 관리한다.
- 입사각(αᵢ) 기반 GI 기하를 적용하여 Q-map과 검출기 보정을 수행하고, 프레임별 1D 환원(케이크 컷 / 라인 컷 / 픽셀 누적 / 방위각 / ROI 적분)을 수행한다.
- 실시간 측정용 **Auto-refresh(스트리밍)** 모드를 지원한다.
- 핵심 설계 원칙은 TrXS2와 동일하게 **"갭/불량 픽셀은 NaN으로 두고 평균에서 제외, 인위적 보간·평활 없음"** 이다(4절).

## 2. 요구 환경

- **MATLAB R2024a** (App/uifigure 기반).
- **Parallel Computing Toolbox** — `parfor`/`parallel.pool.DataQueue` 사용. *선택 사항이며 미설치 시 serial로 자동 동작.*
- HDF5 입력은 내장 `h5read` 사용.

## 3. 의존 파일 (MATLAB 경로에 함께 있어야 함)

GI 1D 환원의 실제 계산은 아래 외부 함수들에 위임된다.

| 함수 | 역할 |
|---|---|
| `CakeCut_gi` | 섹터(케이크) 컷 — q-bin Huber 평균 |
| `CakeCut_gi_fast`, `CakeCut_gi_prep` | 케이크 컷 가속(사전계산 + 빠른 실행) |
| `CakeCut_gi_buildmaps` | Q-map/각도-map 생성(케이크 컷 내부 사용) |
| `Anglecut1d_gi` | GI 라인 컷(보간 기반, NaN 드롭) |
| `Accumpix_gi` | 픽셀 누적 라인 컷(`omitnan` 평균) |
| `SolidAngle`, `Polarization` | 입체각·편광 보정맵 |
| `Eff_correc`, `Eff_correc2` | 검출기 효율 보정(Kapton/Si 감쇠) |
| `getFiles` | 파일명 패턴으로 프레임 목록 검색 |
| `NewFileName` | 저장용 파일명 정리(없으면 Save 시 오류 — 7절) |
| `HeatmapQ_gui` | Q-heatmap 보조 창 |
| `KaptonAttLength8-30.mat`, `SiAttLength8-30.mat` | 효율 보정용 감쇠 길이 데이터 |

> 로딩/q-Cal/라인컷의 진행률 헬퍼(`progressUpdate`, `qcProgressUpdate`, `lcProgressUpdate`, `loadingProgressMsg`)는 본 파일 안의 **로컬 함수**다. 반면 **평균/컷의 NaN 처리 정책 토글은 외부 `CakeCut_gi.m` / `CakeCut_gi_fast.m` 안에** 있다(4절).

## 4. 데이터 처리 정책 (핵심)

TrXS2와 동일한 원칙을 따른다.

- **갭/불량 픽셀 = NaN.** 마스크를 로드 시 적용(`Mask==0 → NaN`)하여 갭·hot pixel을 NaN으로 만든다. 포화 픽셀은 `D>1e9 → NaN`.
- **NaN은 평균에서 제외**되며 보간으로 메우지 않는다.
- **갭을 넘는 평활 금지**(갭 경계 오염 제거).
- **측정된 0·음수 강도 보존**(`I<=0`을 갭으로 간주하지 않음 → 고각 편향 방지).
- 케이크 컷은 q-bin별 **Huber 로버스트 평균**을 사용한다.

### 동작 토글 (외부 cut 함수 내부, 기본값 보수적)

| 토글 | 위치 | 기본 | 의미 |
|---|---|---|---|
| `DO_SPIKE_REJECT` | `CakeCut_gi(_fast)`의 `qbin_huber` | `false` | 스파이크만 NaN(보간 없음) |
| `DO_SMOOTH` | 동상 | `false` | 켜도 NaN 경계 분할 구간 내부에서만 SG 평활 |
| `EXCLUDE_NONPOSITIVE` | 동상 | `false` | `true`면 0·음수도 제외(예전 동작) |

> GIXS2 본체의 방위각(`Azilinecut2`)·ROI 적분은 serial 루프 + `omitnan`이라 갭을 자연히 제외하며, 별도 보간/스파이크 제거가 없다.

## 5. 표준 워크플로우

1. **경로/파일명 지정** 후 스택 로드 (`Openimage2`). 로드 시 마스크(NaN)·포화 제거 적용.
2. **입사각 보정** (`CalIncidence2` / `CalIncidencePixel2`) — GI 기하의 αᵢ 결정.
3. **q-Cal & 보정** (`Qcalc`): GI Q-map + 입체각·편광·효율 보정. (보정 단계는 `DataQueue` 진행률 표시.)
4. **매핑 선택**: `Pixel` / `Alpha` / `Qxy/Qz` / `Qy/Qz`.
5. **1D 환원**: 케이크 컷·라인 컷·픽셀 누적(`Linecut2` → `CakeCut_gi`/`Anglecut1d_gi`/`Accumpix_gi`), 방위각(`Azilinecut2`), ROI 적분(`ROIdef2`/`PlotROI`).
6. **정규화/배경·저장** (`NormalFactor*`, `Saveget*`, `SaveStack`).

In-situ 측정 시 **Auto-refresh**(`Autoplot`)가 새 프레임을 받아 자동 반복한다(`autoUpdateLineCut`/`autoUpdateAziCut`/`autoUpdateROI`).

## 6. 주요 기능 / 콜백

- **로드/표시**: `Openimage2`, `updateImage2`, `Imageplay2`, `GridRemove2`.
- **GI 기하**: `CalIncidence2`, `CalIncidencePixel2`, `CalcPos`, `CalcQpos`, `Position2D`, `aiZplot`.
- **q-Cal/보정**: `Qcalc`(진행률 포함), `PointFind2`, `Openinfo2`.
- **1D 환원**: `Linecut2`(→ 외부 cut 함수), `executeSingleCut`, `Azilinecut2`(방위각), `ROIdef2`/`CalculateROI`(ROI), `Drawline2`/`draw_ray_adaptive`.
- **시계열 플롯**: `Plot1dseries2`, `PlotAziseries2`, `PlotROI`, Q/Azi heatmap, `ReplotInt`.
- **정규화/배경**: `NormalFactor`, `NormalFactorAzi`, `NormalROII`.
- **저장**: `Saveget2/3/4`, `SavegetX`, `SaveStack`, `saveSingleFrame`, `savePanelSnapshot`.
- **자동화**: `Autoplot`, `InsituModeChanged`, `TimeUnit`.

## 7. 병렬 처리 & 진행률

- 로딩·q-Cal·라인 컷은 `parfor` + `parallel.pool.DataQueue`로 진행률을 표시한다(`n / N`, 남은 시간 포함).
- 진행률 갱신은 **정수 % 단위 throttle**(최대 ~100회) + `try/catch` 보호로, 빠른 처리에서 다이얼로그 갱신 폭주로 인한 창 닫힘을 방지한다.
- 방위각·ROI는 serial 루프이며 `mod(...)`로 이미 갱신을 제한한다.

## 8. 문제 해결

- **Save 시 `Unrecognized function 'NewFileName'`**: `NewFileName.m`을 경로에 추가(TrXS/GIXS 공통 의존).
- **처리 중 GUI 창이 닫힘**: 처리 콜백은 `try/catch` 보호되어 오류 시 에러 팝업을 띄운다. 메시지로 원인 파악 가능.
- **MATLAB 전체 종료**: 대개 OOM. 워커 수 축소(`parpool(2)`)나 프레임 분할 처리.
- **케이크/라인 컷 결과가 이상**: 경로에 **수정본** `CakeCut_gi.m`/`CakeCut_gi_fast.m`/`Anglecut1d_gi.m`/`Accumpix_gi.m`가 올라가 있는지 확인(구버전이 우선되면 예전 왜곡 로직이 적용됨).

## 9. 최근 개선 이력

- 케이크 컷(`CakeCut_gi`/`_fast`)의 `fillmissing`+SG 평활·`bad_edges` 침식 제거 → NaN 보존 정책.
- 방위각의 40% edge 컷·스파이크 제거 옵션화(기본 off).
- `I<=0` 강도 제외 제거, finite 기준 통일(`EXCLUDE_NONPOSITIVE`로 복원).
- Line Cut `parfor` 진행률 표시 추가 + throttle/`try/catch` 방어(로딩·q-Cal과 동일 패턴).