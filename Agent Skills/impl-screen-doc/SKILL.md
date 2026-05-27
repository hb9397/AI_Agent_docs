---
name: impl-screen-doc
description: >
  설계 문서를 기반으로 RFP SFR 화면 단위 구현 지침서를 생성한다.
  '화면별 구현 지침', '화면 단위 명세', 'SFR 화면 구현',
  '화면별 컴포넌트 설계', '화면 구현 가이드' 요청이 오면 이 스킬을 사용한다.
  impl-fe-be-doc(FE/BE 페어)과 달리 화면을 중심 단위로 컴포넌트·API·상태를 명세한다.
  design-doc 이후 구현 지침 계열 3종(impl-fe-be-doc / impl-screen-doc / impl-doc) 중 하나를 선택하며,
  RFP SFR 기반 화면 구현이 중심인 경우 이 스킬을 선택한다.
allowed-tools: Read, Write, Glob, Grep, Bash
agent: fork
---

# 화면 단위 구현 지침서 (impl-screen-doc)

---

## STEP 0 — 플랫폼 및 실행 방식 확인

`prompts/parallel-setup.md`의 [플랫폼 확인] → [모델 목록 표시] → [실행 방식 선택 — 선호도만 저장] 절차를 따른다.

병렬 선호 시: 화면 목록은 Step 1~2에서 확정된다.
화면 구현 순서 확정 후 Step 3 실행 전에 Task 목록을 제시하고 `prompts/parallel-setup.md`의 [모델 확정] 절차를 실행한다.

순차 선택 시 Step 1로 직접 진행한다.

---

design-doc 스킬의 OUTPUT 또는 설계 문서를 입력받아
**화면 단위**로 컴포넌트 구조·API 연동·상태 관리·검증 기준을 명세하는
구현 지침서를 생성한다.

생성 전 반드시 사용자 확인을 거친다. 파일을 무단으로 생성하지 않는다.

> `impl-fe-be-doc`이 FE/BE 역할 기준으로 Phase를 분할하는 반면,
> 이 스킬은 **화면**을 중심 축으로 삼는다.
> 각 화면이 독립적으로 구현·테스트 가능한 단위가 되며,
> 화면 내에서 필요한 FE 컴포넌트와 BE API를 함께 정의한다.

## 스킬 연계

```
design-doc OUTPUT (설계문서.md)
    ↓
impl-screen-doc  ← 지금 여기
    ↓
impl-screen-{화면명}.md (화면별 구현 지침서)
    ├─→ design-prototype-docs → create-prototype  →  HTML 프로토타입
    ├─→ frontend-design        →  실제 컴포넌트 구현
    └─→ sfr-trace              →  SFR 커버리지 점검
```

### 구현 지침 스킬 선택 기준

| 스킬 | 선택 조건 |
|------|----------|
| `impl-fe-be-doc` | FE/BE 역할이 분리되고 Phase별 페어 작업이 필요한 경우 |
| **`impl-screen-doc`** | **RFP SFR 기반 화면 단위 명세가 중심인 경우** ← 이 스킬 |
| `impl-doc` | FE/BE·화면 구분 없이 범용 단계별 구현이 필요한 경우 |

---

## 워크플로우

### Step 1 — 입력 문서 수집 및 화면 목록 파악

설계 문서가 제공되지 않은 경우 요청한다.

> "구현 지침을 만들 설계 문서를 공유해 주세요.
> design-doc 결과물이나 rfp-design-input-*.md 모두 가능합니다."

문서를 받으면 `prompts/screen-analysis.md` 기준으로 분석한다.

추출 항목:
- 전체 화면 목록 (설계 문서·rfp-design-input에서 식별)
- 화면 간 이동 흐름
- 화면별 대응 SFR 번호
- 공통 컴포넌트 후보 (헤더, 사이드바, 인증 등)

분석 후 불명확한 항목 중 최대 3개만 골라 한 번에 묻는다.
확인 우선순위는 `prompts/screen-analysis.md` 참조.

---

### Step 2 — 구현 순서 결정

화면 간 의존 관계를 분석하여 구현 순서를 결정한다.

```
구현 순서 결정 기준:
1. 공통 레이아웃 / 인증 → 가장 먼저
2. 데이터 입력 화면 → 조회 화면보다 먼저 (데이터가 있어야 조회 가능)
3. 핵심 SFR 화면 → 보조 화면보다 먼저
4. 독립 화면 → 의존 화면보다 먼저
```

구현 순서 초안을 대화창에 출력한다:

> "화면 구현 순서를 아래와 같이 제안합니다:
> Phase 1: {화면명} — {이유}
> Phase 2: {화면명} — {이유}
> ...
> 순서를 조정할 부분이 있으면 말씀해 주세요."

---

### Step 2-B — 병렬 모델 확정 (STEP 0에서 병렬 선호 시에만)

STEP 0에서 병렬을 선택한 경우, Step 2에서 확정된 화면 구현 순서를 Task 목록으로 제시한다.

| # | Task | 담당 화면 |
|---|------|----------|
| 1 | screen-{화면명} | 컴포넌트·API·상태·인터랙션 명세 |
| … | … | … (화면 수만큼 행 추가) |

`prompts/parallel-setup.md`의 [모델 확정] 절차를 실행한 뒤 Step 3으로 진행한다.
STEP 0에서 순차를 선택한 경우 이 Step을 건너뛴다.

---

### Step 3 — 화면별 구현 지침 작성

각 화면에 대해 `prompts/component-design.md`와 `prompts/api-mapping.md` 규칙으로
구현 지침을 작성한다.

화면별 필수 포함 항목 (4가지):

1. **컴포넌트 구조** — `prompts/component-design.md` 참조
2. **API 연동 포인트** — `prompts/api-mapping.md` 참조
3. **상태 관리** — `prompts/component-design.md`의 상태 분류 참조
4. **사용자 인터랙션 시나리오** — Happy Path + 에러 흐름 + 경계 케이스

---

### Step 4 — 화면별 검증 체크리스트

각 화면에 대해 `prompts/verification.md` 규칙으로 검증 항목을 작성한다.

검증 체크리스트는 구현 후 사람이 직접 확인하는 항목이다.
"정상 동작 확인" 같은 모호한 표현 금지.

---

### Step 5 — 함정 체크

`prompts/pitfall-checklist.md`의 체크리스트를 실행하여 누락 항목을 검토한다.

---

### Step 6 — 초안 출력 및 사용자 확인

화면별 구현 지침서 초안을 대화창에 출력하고 승인을 요청한다.

> "위 구현 지침서를 검토해 주세요.
> 화면 구성이나 컴포넌트 설계 중 수정할 부분이 있으면 말씀해 주세요."

수정 요청 시 해당 화면 지침만 재작성한다.

승인 시 화면별로 파일 저장:
```
impl-screen-{화면명}.md
예: impl-screen-점검결과목록.md
예: impl-screen-AI분석상세.md
```

여러 화면을 하나의 파일로 통합 저장할 수도 있다 (사용자 선택).

---

## 산출물과 impl-fe-be-doc 차이

| 관점 | impl-fe-be-doc | impl-screen-doc |
|------|---------------|----------------|
| **중심 축** | FE/BE 역할 | 화면 단위 |
| **Phase 단위** | BE+FE 페어 기능 | 화면 1개 = 1 Phase |
| **태스크 ID** | BE-XX / FE-XX 분리 | SCR-XX (화면 내 통합) |
| **API 명세 위치** | BE 태스크에 포함 | 화면 지침 내 API 섹션 |
| **적합한 경우** | FE/BE 담당자 분리, 페어 작업 | 화면 중심 개발, 1인 풀스택, RFP SFR 기반 |
