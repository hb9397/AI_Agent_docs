# RFP 기반 스킬 커맨드 흐름 정의서

> **최종 갱신**: 2026-03-30
> **갱신 배경**: Codex 리뷰 반영 + 하네스 엔지니어 관점의 추가 스킬 제안 + 전체 흐름 재정리

---

## 0) RFP 입력 규칙 (@ 태그)

- RFP 원본 저장 루트: `D:\Dev_Workspace\pre_working\`
- RFP 파일은 하위 프로젝트 폴더에 위치시킨다.
- 호출 시 파일 경로는 `@` 태그로 명시한다.

예시:

```text
@D:\Dev_Workspace\pre_working\한국전기안전공사_AI_플랫폼\(붙임 2) 제안요청서(전기안전 AI플랫폼 구축)_v2.pdf
```

> **운영 전제**: RFP 전체 기능을 한 번에 구현하지 않는다.
> 그 때 그 때 필요한 SFR을 선택하여 스킬 흐름을 실행한다.

---

## 1) 신규 스킬 정의: `rfp-ingest`

### 스킬 목표

RFP를 읽고 **전체 화면 단위**로 기능 요구사항을 묶어,
시스템에 필요한 화면 후보를 예측하고 요구사항-화면 매핑을 만든다.

### 핵심 입력

- `@{RFP 파일 경로}`
- `/rfp-ingest {기능요구사항 일련번호}` 또는 `/rfp-ingest {SFR-019, SFR-021, ...}`

### 핵심 출력

1. 화면 후보 목록 (예상 화면명, 목적, 주요 액션)
2. 요구사항 ↔ 화면 매핑 표
3. 불명확 항목 확인 질문 (인라인 처리 — 별도 스킬 불필요)
4. `design-doc` 인터뷰 입력용 중간 문서 (`.md`)

---

## 2) 실행 방식 제약

- Hook 기반 자동 트리거를 사용하지 않는다.
- 모든 단계는 **스킬 커맨드 호출 흐름**으로만 실행한다.
- 즉, 사용자가 명시적으로 `/rfp-ingest`, `/design-doc`, `/impl-screen-doc`를 호출한다.

---

## 3) `/rfp-ingest` 동작 상세

명령이 다음 형태로 들어오면:

- `/rfp-ingest SFR-019`
- `/rfp-ingest SFR-019,SFR-021`
- `/rfp-ingest SFR-019 SFR-021`

아래 순서로 수행한다.

1. `@`로 지정된 RFP 파일에서 대상 기능요구사항 일련번호를 추출한다.
2. Agent가 해석한 기능 단위(입력, 처리, 출력, 예외, 연계)를 정리한다.
3. 불명확한 항목은 **이 단계에서 인라인으로** 사용자에게 확인 질문한다.
4. 확인된 내용을 기반으로 `design-doc` 인터뷰에 바로 응답 가능한 중간 문서를 생성한다.

중간 문서 파일명 규칙(권장):

```text
rfp-design-input-{일련번호목록}.md
예: rfp-design-input-SFR-019.md
예: rfp-design-input-SFR-019_SFR-021.md
```

중간 문서 최소 포함 항목:

- 요구사항 원문 요약
- 화면 후보 및 우선순위
- 화면별 핵심 기능/입출력
- 화면 간 이동 흐름
- 미결정/확인 필요 항목

---

## 4) `design-doc` 이후 스킬 네이밍

`screen-spec` 대신 아래 스킬명을 사용한다.

- 신규 스킬명: `impl-screen-doc`

의도:

- `impl-doc`와 계열을 맞추되(구현 지침 계열),
- 화면 기능 단위 산출물이라는 점을 명확히 구분한다.

### `impl-screen-doc` 역할

`design-doc` 결과를 입력으로 받아 화면 단위 구현 지침서를 만든다.

- 화면별 컴포넌트 구조
- 화면별 API 연동 포인트
- 상태/에러 처리 시나리오
- 화면별 검증 체크리스트
- 구현 순서(Phase)

---

## 5) 최종 커맨드 흐름

```text
┌─────────────────────────────────────────────────────────────────┐
│                     RFP 기반 개발 워크플로우                      │
└─────────────────────────────────────────────────────────────────┘

[입력]
  @RFP파일 지정
        │
        ▼
[1단계] /rfp-ingest SFR-019[,SFR-021...]
  ├─ RFP에서 SFR 추출
  ├─ 화면 후보 목록 + 요구사항-화면 매핑
  ├─ 불명확 항목 인라인 확인 질문
  └─ rfp-design-input-*.md 생성
        │
        ├─────────────────────────────────────────────┐
        │ [제안 단계 / 추상 목업]                       │
        │                                             ▼
        │                                  /create-prototype
        │                                    ├─ rfp-design-input-*.md 기반
        │                                    ├─ 화면 흐름 미확정 상태로 제작
        │                                    └─ SFR 번호 기반 HTML 목업
        │                                    (이후 설계 확정 시 재생성 가능)
        │
        ▼ [설계·구현 단계]
[2단계] /design-doc
  ├─ rfp-design-input-*.md를 인터뷰 응답으로 활용
  └─ 설계 문서 생성 (화면 정의, 기술 스택, 데이터 구조 등)
        │
        ▼
[3단계] /impl-doc
  ├─ design-doc 산출물 → FE/BE 페어 Phase별 작업지침서
  ├─ 태스크 의존 관계 및 구현 순서 확정
  └─ Phase별 검증 시나리오 작성
        │
        ├──────────────────────────────┐
        ▼                              ▼
[4단계] /impl-screen-doc         /sfr-trace (선택)
  ├─ 화면별 컴포넌트 구조          ├─ SFR ↔ 화면 ↔ API 매핑 매트릭스
  ├─ API 연동 포인트               └─ 누락/충돌 항목 리포트
  └─ 상태/에러 처리 시나리오
        │
        ├──────────────────────┐
        ▼                      ▼
[5단계] /create-prototype  /frontend-design
  └─ 설계 확정 후 정밀    └─ 실제 컴포넌트 구현
     HTML 프로토타입
        │
        ▼
[6단계] /multi-review
  └─ 보안·성능·유지보수성·테스트 4관점 코드 리뷰
        │
        ├──────────────────────────────┐
        ▼                              ▼
[7단계] /pre-commit             /rfp-compliance-review (선택)
  └─ 코드 규칙 검사              └─ 설계·구현 vs RFP 요구사항 누락 점검
        │
        ▼
[8단계] /commit
  └─ Conventional Commits 메시지 생성 및 커밋
```

> **`/create-prototype` 사용 시점**
> - **제안 단계**: rfp-ingest 직후 → 추상적 화면 목업. 설계 미확정 상태 허용.
> - **구현 단계**: impl-screen-doc 이후 → 설계 확정 기반 정밀 프로토타입.
> - 동일 SFR에 대해 두 번 실행되는 것이 정상이며, 이후 버전이 이전 버전을 덮어쓴다.

---

## 6) 산출물 위치 권장

- RFP 입력 문서: `D:\Dev_Workspace\pre_working\{프로젝트}/`
- 중간 문서 (`rfp-design-input-*.md`): 현재 작업 프로젝트 루트
- 설계 산출물 (`design-doc` 결과): 현재 작업 프로젝트 루트
- 구현 지침 산출물 (`impl-screen-doc` 결과): 현재 작업 프로젝트 루트

---

## 7) 추가 제안 스킬 (하네스 엔지니어링 관점)

> 현재 하네스에 없는 스킬들. 우선순위 순으로 기술.

### P0 — 즉시 구현 필요 (스펙은 있으나 SKILL.md 없음)

#### `rfp-ingest`
| 항목 | 내용 |
|------|------|
| 상태 | 이 문서에 스펙 정의됨. SKILL.md 미생성. |
| 우선순위 이유 | 워크플로우 진입점. 없으면 RFP → design-doc 연결이 수동 |

#### `impl-screen-doc`
| 항목 | 내용 |
|------|------|
| 상태 | 이 문서에 스펙 정의됨. SKILL.md 미생성. |
| 우선순위 이유 | design-doc 이후 화면 단위 구현 지침 자동화. impl-doc 계열 완성 |

---

### P1 — 강하게 권장 (RFP 업무에 반복 발생)

#### `sfr-trace`
- **목적**: SFR ↔ 화면 ↔ API ↔ 테스트 간 추적 매트릭스 생성·검증
- **주요 기능**:
  - 설계 문서/impl-screen-doc 결과를 읽고 SFR별 커버리지 표 생성
  - 매핑 누락 항목 경고 (SFR은 있는데 화면이 없거나, 화면은 있는데 SFR이 없는 경우)
  - `--impact` 옵션: 특정 SFR 변경 시 영향 받는 화면/API/테스트 자동 표시
- **sfr-change-impact 흡수**: 별도 스킬 불필요, `--impact` 옵션으로 처리
- **입력**: 설계 문서, impl-screen-doc 산출물
- **출력**: `sfr-trace-matrix.md`

#### `rfp-compliance-review`
- **목적**: 설계/구현 산출물이 RFP 필수 요구사항을 빠짐없이 반영했는지 점검
- **주요 기능**:
  - RFP의 기능/비기능 요구사항 목록 추출
  - 설계 문서/impl 산출물과 대조하여 누락 항목 식별
  - "미반영 SFR 목록" + "부분 반영(위험)" 구분 리포트
- **트리거 시점**: /commit 또는 납품 전 최종 게이트
- **입력**: `@RFP파일`, 설계/구현 산출물 디렉토리
- **출력**: `rfp-compliance-report.md`

---

### P2 — 운영 고도화 (반복 납품 시 ROI 높음)

#### `acceptance-test-doc`
- **목적**: SFR별 인수 기준(성공/실패/경계값)과 QA 체크리스트 자동 생성
- **입력**: rfp-design-input-*.md 또는 SFR ID 목록
- **출력**: `acceptance-test-{SFR}.md`
- **비고**: 현재 multi-review가 일부 커버하지만 SFR별 정형화는 별도 스킬이 효율적

#### `artifact-pack`
- **목적**: 제안/납품용 산출물 패키지 자동 정리 (문서 세트 표준화)
- **주요 기능**:
  - 설계 문서, 구현 지침, SFR 추적 매트릭스, 준수성 리포트를 지정 폴더로 복사·정리
  - 제출 체크리스트 자동 생성
- **비고**: 반복 납품 프로젝트에서 수작업 패키징 대체

---

## 8) 하네스 엔지니어링 관점 — 통합 아키텍처 메모

### 현재 스킬 계열 구조

```text
[RFP 해석 계열]         [설계 계열]          [구현 계열]           [품질 계열]
rfp-ingest           design-doc          impl-doc             pre-commit
rfp-compliance-      context-doc         impl-screen-doc  ─┐  multi-review
review               sfr-trace                             │  commit
                                                           ▼
                                                     create-prototype
                                                     frontend-design
                                                     code-comment
```

### 스킬 간 데이터 흐름

```text
@RFP
  └─► rfp-ingest ──► rfp-design-input-*.md
                              │
                              ▼
                        design-doc ──► 설계문서.md
                              │              │
                              ▼              └──► sfr-trace ──► sfr-trace-matrix.md
                          impl-doc ──► 작업지침서.md (FE/BE Phase)
                              │
                              ▼
              impl-screen-doc ──► impl-screen-{화면}.md
                    │
                    ▼
             create-prototype ──► SFR-{번호}.html
                    │
                    ▼
              multi-review ──► 리뷰 결과
                    │
                    ▼
              pre-commit ──► 규칙 검사 통과
                    │
                    ▼
               commit ──► git history
```

### 스킬 선택 기준 (런타임)

| 상황 | 실행 스킬 |
|------|-----------|
| 새 SFR 작업 시작 | `rfp-ingest` |
| 제안 단계 추상 목업 | `create-prototype` (rfp-ingest 직후, 설계 미확정 상태) |
| SFR → 화면 설계 | `design-doc` (rfp-design-input-*.md 첨부) |
| 구현 순서·Phase 분할 | `impl-doc` |
| 화면 단위 구현 명세 | `impl-screen-doc` |
| 설계 확정 후 정밀 목업 | `create-prototype` (impl-screen-doc 이후 재실행) |
| SFR 커버리지 점검 | `sfr-trace` |
| 커밋 전 | `pre-commit` → `commit` |
| 납품 전 최종 점검 | `rfp-compliance-review` |

### 설계 원칙 (반영 완료 / 향후 유지)

1. **명시적 트리거**: Hook 자동 실행 없음. 모든 스킬은 사용자가 명시적으로 호출.
2. **SFR 선택 실행**: RFP 전체를 일괄 처리하지 않음. 그 때 그 때 필요한 SFR만.
3. **산출물 연결**: 각 스킬의 출력이 다음 스킬의 입력이 되는 파이프라인 구조.
4. **스킬 경계 명확화**: 유사 기능은 별도 스킬 분리 대신 옵션/플래그로 흡수 (sfr-trace + change-impact 통합 사례).
5. **rfp-clarify 불필요**: rfp-ingest Step 3에서 인라인 확인 질문으로 처리. 별도 스킬 분리 시 컨텍스트 단절 리스크.
