# 변경 이력 / Changelog

버전은 `functions/Others/pgixsVersion.m`에 있고, 콘솔 창 제목과 하단에 표시된다.

---

## v2.5.1 — Smart Auto Run 링 차수 인식 개선 / Smart Auto Run ring orders

- **SDD Calibration의 Smart Auto Run**이 링 차수를 더 정확히 붙입니다.
  - 전에는 링 후보를 순서대로 1, 2, 3차로 붙여서, 빔스톱 가장자리나 검출기 이음매 같은
    엉뚱한 피크가 하나 끼면 그 뒤 링이 모두 한 차수씩 밀려 SDD가 1.5~2.5배 틀렸습니다.
  - 이제 각 차수의 링이 있어야 할 반지름을 예측해 실제로 맞는 후보에만 차수를 붙이고,
    나머지 피크는 계산에서 뺍니다(후보 표에 "Not in the ring series"로 표시).
  - 테스트 데이터 표준시료 40개 중 39개가 저장된 SDD와 1% 이내로 맞습니다(전에는 28개).
    Python 앱(v0.3.12)과 차수가 똑같이 나옵니다.

---

## ⚠️ v2.5.0 — Python 앱과 결과 맞추기 / Results aligned with the Python app

Python 앱과 결과를 하나하나 비교해서, MATLAB 쪽이 틀렸던 곳을 고쳤습니다.

- **Qy/Qz 매핑의 |Q|에 Qx를 포함합니다.** 지금까지 `sqrt(Qy² + Qz²)`로 계산해서
  SDD 250 mm에서 q가 0.2–0.9% 낮게 나왔습니다(검출기 보정, Pixel 모드 컷의 q축,
  azimuthal q 표시에 영향). 긴 SAXS 거리에서는 거의 차이가 없습니다.
- **TrXS 콘솔 Azimuthal**이 Range(−/+) 값 그대로 `pix+minus ~ pix+plus` 반지름을
  씁니다(GIXS와 같음). 전에는 범위를 비대칭으로 주면 다른 q의 링을 계산했습니다.
- **GIXS-series ROI Save Integ.**가 화면처럼 IC/BC로 정규화한 값을 저장합니다.
- **GIXS-series Azimuthal**을 전체 최댓값으로 나누지 않습니다. 화면과 저장 값이
  0–1이 아닌 원래 크기로 나옵니다(Python과 같음).

---

## ⚠️ v2.4.0 — GIXS-series·TrXS-series Auto Refresh 파일 선택 / Auto Refresh file selection

- **Auto Refresh가 엉뚱한 파일을 붙이던 문제를 고쳤습니다.** 새 파일을 "불러온 개수
  다음 순서"로 골라서, Set/Table에서 중간 파일의 체크를 빼고 불러오면 그 다음 파일을
  한 번 더 읽었습니다(0003을 빼면 0005가 두 번). 이후 모든 프레임이 X축과 한 칸씩
  어긋났습니다. 이제 마지막으로 불러온 파일 **다음** 파일만 새 파일로 봅니다
  (`selectPGIXSNewSeriesFiles`).
- **Set/Table 목록만 열어도 시리즈 이름이 바뀌던 문제를 고쳤습니다.** 다른 이름으로
  목록을 열고 닫기만 해도 Auto Refresh가 그 시리즈 파일을 붙이고, Save가 그 이름의
  폴더에 저장했습니다. 이제 시리즈 이름은 Export & Load로 실제로 불러올 때만 바뀝니다.
- **영향 범위:** 중간 파일을 빼고 불러온 시리즈에 Auto Refresh를 썼다면 그 결과를 다시
  확인하는 것을 권합니다.

Auto Refresh now adds only files after the last one loaded, and the series
name changes only on Export & Load (PGIXS_python v0.3.6 has the same fixes).

---

## ⚠️ v2.3.0 — Alpha 매핑 1D 컷 결과가 달라집니다 / Alpha-mapping 1D cuts change

- **Map format이 Alpha일 때 1D 컷(Line, Cakecut, Accumulation, Azimuthal)도 갭 경계
  3픽셀을 재보간 *전에* 뺍니다.** v2.2.0에서 Qxy/Qz·Qy/Qz에 적용한 것과 같은 문제와
  수정입니다. `AlphaMap`도 원본과 크기가 같아서 검출기 픽셀 기준 마스크가 재보간된
  이미지의 엉뚱한 위치에 찍히고 있었습니다. 이제 q-Map Cal.이 `AlphaMapCut`을 따로
  만들고, 화면의 Alpha 이미지는 그대로 둡니다.

---

## ⚠️ v2.2.0 — Q-space 1D 컷 결과가 달라집니다 / Q-space 1D cuts change

- **Map format이 Qxy/Qz·Qy/Qz일 때 1D 컷(Line, Cakecut, Accumulation, Azimuthal)이
  갭 경계 3픽셀을 Q 격자로 재보간하기 *전에* 뺍니다.** 이전에는 검출기 픽셀 기준
  마스크를 재보간된 `Itrans` 위에 그대로 찍었습니다. `Itrans`가 원본과 크기가 같아
  크기 비교로 걸러지지 않았기 때문인데, 그 결과 **엉뚱한 Q 위치의 값이 빠지고** 실제
  갭 옆 픽셀은 보간을 거쳐 커브에 섞였습니다. 이제 q-Map Cal.이 버퍼를 뺀 이미지를
  따로 재보간해 두고(`ItransCut`), 화면의 Qxy/Qz 이미지는 그대로 둡니다. Python
  버전(v0.3.2)과 같은 방식입니다.
- **Pixel 모드의 Accumulation 컷도 갭 경계 3픽셀을 뺍니다.** 다른 1D 컷과 Python
  버전은 이미 빼고 있었고, Accumulation만 빠져 있었습니다.

---

## ⚠️ v2.1.0 — 일부 결과 수치가 달라집니다 / Some numerical results change

이전 배포판으로 처리한 결과와 **직접 비교하기 전에 아래 항목을 확인하세요.** 계산이
바뀐 부분이 있어 **같은 원본 데이터에서 다른 값이 나올 수 있습니다.**

Check the items below before comparing against output from an earlier build:
some calculations changed, so the same raw data can produce different numbers.

### 수치에 영향을 주는 수정 / Fixes that change values

- **TrXS Circular Average의 `Min cov` 임계값이 실제로 동작합니다.**
  이전에는 기하 마스크를 만들 때 `~isfinite(I)`까지 포함해서 coverage가 항상 1이
  되었고, 그래서 **`Min cov` 입력값이 아무 효과도 없었습니다.** 이제 기하와 데이터
  유효성을 분리하므로, 모듈 갭을 많이 지나는 q-bin은 임계값에 걸려 NaN으로 빠집니다.
  좁은 각도 범위에서 커브에 구멍이 늘어난다면 이것이 원인이며, 정상 동작입니다.

- **검출기 갭 경계 3픽셀 버퍼가 데이터 쪽에 적용됩니다.**
  갭에 바로 붙은 픽셀은 전하 수집이 불완전해 값이 치우칠 수 있습니다. 이 픽셀들을
  평균에서 빼되 **기하에는 남겨** coverage를 떨어뜨리도록 바꿨습니다. 그래야 갭을
  많이 지나는 bin이 "적은 픽셀로 만든 평균"이 아니라 "샘플링이 부족한 bin"으로
  드러납니다.

- **SDD Smart Auto Run의 링 차수 판정.**
  링들이 서로 같은 SDD를 주는지(일관성)를 우선하도록 바꿨습니다. SDD가 짧아 1차
  링이 빔스탑에 가려진 패턴에서, 이전에는 보이는 링을 1·2·3차로 읽어 SDD가 크게
  벌어지는 해석을 고를 수 있었습니다. **이전 버전으로 구한 SDD 값을 다시 확인해
  보시길 권합니다.**

- **SDD 캘리브레이션의 `.json` 빔 중심을 1-based로 저장합니다.**
  이전에는 `.json`에만 값에서 1을 빼서 저장했습니다("Python은 0-based"라는 가정
  때문인데, 실제로는 그렇지 않습니다). 그 시절 `.json`을 Python 버전에서 읽으면
  **두 축 모두 한 픽셀 어긋납니다.** 해당 파일은 이 버전에서 다시 저장하거나,
  같은 이름의 `.mat`을 대신 쓰면 됩니다. `.mat`/`.std`는 원래부터 1-based였습니다.

### 동작 수정 / Behavioural fixes

- **GIXS / GIXS-series의 입사각 pixel ↔ degree 변환이 동작합니다.**
  한쪽에 숫자를 넣고 Enter를 눌러도 다른 쪽이 계산되지 않던 문제. 변환이
  `param.pixel`에서 예외를 던지고 있었는데, 이 값은 데이터를 불러와야 생기는
  반면 변환은 보통 **불러오기 전에** 쓰는 기능입니다(입사각을 얼마로 할지 정하려고).
  에러가 커맨드 창으로만 가서 GUI에서는 아무 반응이 없는 것처럼 보였습니다.
  이제 검출기 선택에서 픽셀 크기를 얻으므로 **데이터 로드 전에도 양방향으로
  동작**하고, SDD가 0이거나 없으면 조용히 실패하는 대신 알려줍니다.

### 문서 / Documentation

- **통합 사용자 매뉴얼 추가** — [`docs/manual_ko.md`](docs/manual_ko.md).
  콘솔부터 SDD 캘리브레이션, GIXS·TrXS(단일/시리즈), 투과율·침투깊이 계산기,
  H5→TIFF 변환기, 2D 인덱싱 도구까지 전 도구를 다룹니다. **13장 부록**에는 Python
  버전과 어디까지 일치하고 어디서 갈리는지 실측값과 함께 정리했습니다.
  Word 사본은 `docs/tools`에서 `npm install && npm run manual`.
- README와 MIT 라이선스 추가. 저작권자는 포항가속기연구소.

### 개발 / Development

- `dist/build`가 소스보다 오래되면 테스트가 실패합니다. 이 패키지는 자동으로
  갱신되지 않는데, `addpath(genpath(...))`가 이 폴더를 `functions/`보다 앞에 놓기
  때문에 오래된 사본이 **실제 코드를 가려버립니다.** 실제로 3주간 벌어져 있었고,
  그 사이의 모든 수정이 빠진 채였습니다. 컴파일 전에 재생성하세요:
  `run('dist/build_dist_package.m')`.
- 테스트 러너가 `dist/`를 MATLAB 경로에서 제외합니다. 이전에는 소스가 아니라
  배포용 사본을 테스트하고 있었습니다.
- 검출기 픽셀 크기 조회를 `pgixsDetectorPixelSize`로 분리(마스크 파일을 읽지 않고
  피치만 얻기 위해). `loadPGIXSDetectorMask`가 이 함수를 쓰므로 표는 한 곳에만
  있습니다.

### 버전 표기 / Versioning

- **모든 창이 같은 버전을 표시합니다.** 이전에는 도구마다 `v2.0` / `v2.1` / `v1.0`이
  제각각 하드코딩돼 있어 서로 맞지 않았습니다. 이제 창 제목·하단 라벨 20곳이
  모두 `pgixsVersion()`을 읽습니다. H5→TIFF 변환기가 출력 파일의 Software 태그에
  쓰는 문자열도 포함입니다 — 변환한 TIFF가 어느 버전에서 나왔는지 파일 자체에
  남습니다.

### Python 버전과의 관계 / Relationship to the Python version

두 구현은 **수치적으로 동일하지 않습니다.** 피크 위치는 6e-4 Å⁻¹ 이내로 일치하지만,
q-bin 대표값(산술평균 vs Huber), 라인컷 샘플링(단일 광선 vs 각도 쐐기), Azimuthal
집계 방식이 다릅니다. 자세한 내용과 실측 비교는 매뉴얼 13장에 있고, 같은 데이터로
두 버전을 대조하는 도구는 Python 저장소의 `tools/matlab_crosscheck/`에 있습니다.

---

## v2.0 이전

이 파일이 생기기 전의 이력은 git 로그를 참고하세요. 도구별 매뉴얼(`Manual/`)에도
일부 변경 이력이 남아 있습니다.
