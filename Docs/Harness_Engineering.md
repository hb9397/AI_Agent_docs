# Harness Engineering Guide

> 2026-06-28 기준 현재 저장소의 스킬과 문서를 바탕으로 정리한 AI Agent 하네스 운영 가이드.
> 아래 내용은 `skills/`, `example/`, `README.md`, 각 `SKILL.md`의 현재 내용을 기준으로 작성했다.
> 단일/복수 애플리케이션 프로젝트 모두 지원한다.

---

## 1. 이 문서의 목적

이 저장소의 목적은 "AI가 같은 기준으로 코드를 작성하도록 문서·규칙·작업 흐름을 미리 갖추는 것"이다.

핵심은 세 가지다.

1. **설계 문서가 먼저다.** 바로 구현시키지 않는다.
2. **에이전트가 계속 참조할 고정 컨텍스트를 만든다.**
3. **구현 단위를 작게 쪼개고 중간마다 품질을 확인한다.**

이 문서는 현재 저장소 기준의 흐름과 구성을 정리한다.

---

## 2. 현재 저장소 기준 구성 요약

- `harness-setup`은 이 저장소(원본 하네스 저장소)의 스킬을 대상 프로젝트에 설치·갱신하는 진입점이다. 단일/복수 애플리케이션을 자동 감지한다.
- `design-doc`는 `skills/design-doc/templates/INPUT_V2.md`, `OUTPUT_V2.md` 템플릿을 포함한다.
- `rfp-ingest`는 RFP에서 SFR을 해석하여 대화 컨텍스트로 전달한다 (별도 파일 생성 없음).
- 프로토타입 흐름은 `design-prototype-docs` → `create-prototype`으로 연결된다. 산출물은 `.docs/prototype/{사용자}/{식별자}/`에 저장한다.
- 구현 지침 계열은 `impl-fe-be-doc`/`impl-doc`(계획), `impl-reuse-scan`(시작 전 점검), `impl-verify`(Phase 검증) 4개다. 산출물은 `.docs/impl-doc/{사용자}/{기능명}.md` (단일앱) 또는 `.docs/{앱}/impl-doc/{사용자}/{기능명}.md` (복수앱)에 저장한다.
- 품질·운영 계열에는 `multi-review`, `pre-commit`, `commit`, `code-comment`, `doc-audit`, `agent-sync`, `git-scoped-account`가 있다.
- 산출물 생성 또는 코드·커밋 적용범위를 갖는 스킬은 STEP 0에서 프로젝트 유형(단일/복수)을 감지하고 사용자에게 확인한다. 운영 전용 스킬(`git-scoped-account` 등)과 메타 스킬(`custom-skill-design`)은 해당하지 않는다.

---

## 3. 저장소 구조

```text
AI_Agent_docs/
├── skills/              ← IDE 안의 에이전트가 직접 호출하는 스킬과 템플릿의 원본
├── Docs/                ← 운영·소개·분석 문서
│   ├── Harness_Engineering.md
│   ├── Harness_Engineering_Intro.md
│   └── Agent_Skills_Repo_Structure_Analysis.md
├── improvement_plan/    ← 리팩토링 의사결정·점검 이력
├── example/             ← 산출물 예시
└── README.md
```

### 3-1. Agent Skills — 현재 활성 스킬

#### A. 셋업·분석·설계·컨텍스트 계열

| 호출명 | 디렉토리 | 역할 | 대표 입력 | 대표 산출물 |
|--------|----------|------|-----------|-------------|
| `harness-setup` | `skills/harness-setup` | 원본 하네스 저장소 → 프로젝트 설치·갱신 | 원본 하네스 저장소 경로, 대상 프로젝트 | `.claude/skills/`, `.agents/skills/`, `.docs/`, 루트 컨텍스트 파일 |
| `rfp-ingest` | `skills/rfp-ingest` | RFP에서 지정 SFR 추출·해석·화면 후보 매핑 | `@RFP PDF`, `SFR-019` 등 | 대화 컨텍스트 (파일 생성 없음) |
| `design-doc` | `skills/design-doc` | 인터뷰 기반 설계 문서 도출 | 아이디어, 기존 문서, rfp-ingest 해석 결과 | `.docs/DESIGN.md` (단일앱) / `.docs/{앱}-DESIGN.md` (복수앱) |
| `context-doc` | `skills/context-doc` | 에이전트용 컨텍스트 문서 생성 (주제별 분할) | `design-doc` 결과물 | `CLAUDE.md` + `AGENTS.md` + `.docs/instruction/*-instruction.md` |
| `harness-bootstrap` | `skills/harness-bootstrap` | 기존 코드베이스 → 설계 + 컨텍스트 문서 역추출 | 문서 없는 기존 코드베이스 | `design-doc OUTPUT_V2` + `context-doc` 결과물 일괄 |

#### B. 프로토타입·UI 계열

| 호출명 | 디렉토리 | 역할 | 대표 입력 | 대표 산출물 |
|--------|----------|------|-----------|-------------|
| `design-prototype-docs` | `skills/design-prototype-docs` | 프로토타입 입력용 화면 설계 문서 생성 | 요구사항, RFP, PRD | `.docs/prototype/{사용자}/{식별자}/design-doc.md` |
| `create-prototype` | `skills/create-prototype` | HTML/CSS/JSON 프로토타입 생성 | 목업 디자인 문서, 화면 기능 설명 | `.docs/prototype/{사용자}/{PREFIX}-{번호}/` |
| `frontend-design` | `skills/frontend-design` | 실제 UI 구현 시 디자인 품질 기준 제공 | 화면 구현 요청 | 프로젝트에 맞는 프론트엔드 코드 |

#### C. 구현 지침 계열

| 호출명 | 디렉토리 | 역할 | 중심 축 | 적합한 대상 |
|--------|----------|------|---------|-------------|
| `impl-fe-be-doc` | `skills/impl-fe-be-doc` | FE/BE 페어 다중 기능 또는 다중 화면 작업지침서 | 다중 화면·페어 다중 기능 | 풀스택 다중 기능, RFP/SFR 다중 화면 구현 |
| `impl-doc` | `skills/impl-doc` | 단일·소규모 범용 작업지침서 | 기능/모듈/처리 흐름 | API 1~수개, 단일 도메인 로직, 컴포넌트·훅·화면 1개 |
| `impl-reuse-scan` | `skills/impl-reuse-scan` | 공통 자산 발견·보고(자동 수정 금지) | 코드베이스 스캔 | Phase/태스크 시작 직전 중복 구현 방지 |
| `impl-verify` | `skills/impl-verify` | 검증 리포트 산출(코드/지침서 수정 금지) | 작업지침서 검증 기준 추출 | Phase 종료 시 PASS/FAIL 판정 |

#### D. 품질·운영 계열

| 호출명 | 디렉토리 | 역할 | 핵심 포인트 |
|--------|----------|------|-------------|
| `multi-review` | `skills/multi-review` | 4관점 병렬 코드 리뷰 | Security / Performance / Maintainability / Testing |
| `pre-commit` | `skills/pre-commit` | 커밋 전 규칙 검사 | 에러 처리, 타임아웃, 민감 정보, TODO, 테스트 |
| `commit` | `skills/commit` | Conventional Commits 기반 커밋 | 한글 description, scope 추론, why 중심 body |
| `code-comment` | `skills/code-comment` | 변경 파일 한글 주석 작성·갱신 | 승인 전 파일 미수정 원칙 |
| `doc-audit` | `skills/doc-audit` | 코드와 에이전트 문서 괴리 분석 | 제안만 먼저 출력, 승인 후 반영 |
| `agent-sync` | `skills/agent-sync` | Agent 문서/Skills 양쪽 내용 맞춤 | `.claude/skills` ↔ `.agents/skills` 미러, `CLAUDE.md` ↔ `AGENTS.md` 일치 (원본 하네스 저장소에서 가져오는 일은 harness-setup 전담) |
| `git-scoped-account` | `skills/git-scoped-account` | 디렉토리 스코프 git 계정 일괄 적용·확인 | 전역 `~/.gitconfig` 미변경 + `include.path`로 상위 트리 하위 repo에만 user.name/email 적용 |

#### E. 메타 계열

| 호출명 | 디렉토리 | 역할 | 비고 |
|--------|----------|------|------|
| `custom-skill-design` | `skills/custom-skill-design` | 새 스킬 설계·생성·테스트·트리거 최적화 | |

## 4. 작업 시작 전에 먼저 정해야 할 것

### 4-1. 프로젝트 유형

산출물·적용범위 스킬은 STEP 0에서 아래를 자동 감지하고 사용자에게 확인한다:

| 유형 | 구조 | `.docs/` 경로 예시 |
|------|------|---------------------|
| **단일 앱** | 하나의 git repo = 앱 + 하네스 산출물 | `.docs/DESIGN.md`, `.docs/impl-doc/{사용자}/{기능}.md` |
| **복수 앱** | 프로젝트 상위 폴더 (git init 없음) 아래에 `.docs/`, 각 앱, 원본 하네스 저장소가 독립 git | `.docs/{앱}-DESIGN.md`, `.docs/{앱}/impl-doc/{사용자}/{기능}.md` |

### 4-2. 작업 스케일

| 스케일 | 예시 | 기본 권장 |
|--------|------|-----------|
| 프로젝트 전체 | 신규 서비스, 신규 서브시스템 | `design-doc` → `context-doc` → `impl-*` |
| 화면 단위 | 대시보드, 설정 화면 | 다중 화면 명세는 `design-doc` → `impl-fe-be-doc`, 화면 1개는 `impl-doc`도 가능 |
| 기능 단위 | 로그인, 예약 실행, 분석 실행 | 페어 다중 기능은 `impl-fe-be-doc`, 단일·소규모 기능은 `impl-doc` |
| 컴포넌트/로직 단위 | 훅, 파서, 재시도 로직 | `design-doc`만 쓰거나 `impl-doc` 후 구현 |

### 4-3. 구현 지침의 중심 축

| 질문 | 선택할 스킬 |
|------|-------------|
| FE 화면 여러 개 + BE API 여러 개를 페어로 묶는 풀스택인가? | `impl-fe-be-doc` |
| RFP/SFR/화면정의서 기반 다중 화면 명세인가? | `impl-fe-be-doc` |
| 화면 1개·컴포넌트 단독·훅 단독·API 1~수개인가? | `impl-doc` |

---

## 5. 하네스 기본 작업 흐름

흐름은 **하나**다. 진입 조건에 따라 옵션 분기가 붙는다.

```text
[0단계 — 환경 준비]
/git-scoped-account   (복수 앱 환경에서 앱별 git 계정 분리 시)
        │
        ▼
/harness-setup        (원본 하네스 저장소 → 프로젝트 스킬 설치·갱신)
        │
        ▼
[1단계 — 설계]
        │
        ├─ (옵션) RFP가 있으면 /rfp-ingest → 대화 컨텍스트로 전달
        │
        ├─ 기존 코드베이스면 /harness-bootstrap (역추출)
        │
        ▼
/design-doc
        │
        ├─ (권장) /context-doc
        │
        ├─ (옵션) /design-prototype-docs → /create-prototype
        │          화면 구조가 불확실하거나 제안 단계 목업 필요 시
        │
        ▼
[2단계 — 구현 계획]
impl 스킬 선택
  ├─ /impl-fe-be-doc  (다중 화면·페어 다중 기능)
  └─ /impl-doc        (단일·소규모 범용)
        │
        ▼
/impl-reuse-scan      (구현 시작 전 점검 — 중복 자산 확인)
        │
        ▼
[3단계 — 구현·검증]
실제 구현
  └─ UI 비중이 높으면 /frontend-design 기준 적용
        │
        ▼
/impl-verify          (Phase 종료 검증)
        │
        ▼
[4단계 — 품질·커밋]
/multi-review + /doc-audit
        │
        ▼
/pre-commit
        ├─ (선택) /code-comment
        ▼
/commit
        │
        └─ 스킬/문서 변경이 있었으면 /agent-sync (양쪽 내용 맞춤)
```

### 기본 흐름에서 기억할 점

- **0단계는 프로젝트당 한 번**이다. `harness-setup`은 설치 후 원본이 갱신됐을 때 다시 실행한다.
- **rfp-ingest는 파일을 생성하지 않는다.** 해석 결과는 대화 컨텍스트로 남아 후속 스킬이 참조한다.
- **harness-bootstrap → 이후 정규 루프 합류**: 역추출된 설계문서를 기반으로 `design-doc`/`context-doc` 보강 후 같은 흐름을 따른다.
- 프로젝트 전체 작업이면 `context-doc`를 거의 필수로 본다.
- 컴포넌트/로직 단위처럼 작은 작업은 `design-doc`까지만 하고 바로 구현해도 된다.
- 같은 대화에서 여러 Phase를 한꺼번에 구현시키기보다, **Phase 1개 또는 화면 1개 단위**로 끊는 것이 낫다.
- **`rfp-ingest`는 선택 SFR 분석용**이다. 화면 후보는 확정안이 아니라 후보이며, 확정은 `design-doc`/`design-prototype-docs`에서 한다.
- **복수 앱에서 git으로 관리하지 않는 루트 파일(`CLAUDE.md`/`AGENTS.md`)은 `harness-setup` 전담**이다. `agent-sync`는 양쪽 내용 맞춤만 담당한다.

---

## 7. 구현 지침 4종 선택 기준

| 항목 | `impl-fe-be-doc` | `impl-doc` |
|------|------------------|------------|
| 중심 축 | 다중 화면·페어 다중 기능 | 단일·소규모 기능/모듈 |
| Phase 단위 | FE 화면 여러 개 + BE API 여러 개 또는 RFP/SFR 다중 화면 | API 1~수개, 화면 1개, 컴포넌트/훅/입출력 흐름 |
| 태스크 ID | `INF-XX`, `BE-XX`, `FE-XX` | `INIT`, `CORE`, `IO`, `TEST`, `PKG` |
| 적합 대상 | 풀스택 다중 기능, RFP/SFR/화면정의서 기반 다중 화면 구현 | CLI, 스크립트, 서비스, 라이브러리, BE 단일 기능, FE 단일 기능 |
| 핵심 검증 | FE→API→DB 통합, 화면 렌더링, 상태, API, 인터랙션 | 실행 명령, 입출력, 테스트, 패키징 |

### 빠른 선택 규칙

- "FE 화면 여러 개와 BE API 여러 개를 페어로 묶어야 한다" → `impl-fe-be-doc`
- "RFP/SFR/화면정의서 기반 다중 화면 명세다" → `impl-fe-be-doc`
- "화면 1개·컴포넌트 단독·훅 단독·API 1~수개다" → `impl-doc`

---

## 8. 스킬 간 입출력 약속

현재 저장소의 핵심은 단순한 순서가 아니라 **산출물 연결 방식**이다.
아래 연결 방식이 맞아야 다음 스킬도 안정적으로 동작한다.

### 8-1. 핵심 연결도

```text
원본 하네스 저장소
  └─→ /harness-setup
        └─→ .claude/skills/, .agents/skills/, .docs/, 루트 컨텍스트

@RFP PDF
  └─→ /rfp-ingest
        └─→ 대화 컨텍스트 (파일 없음)
                ├─→ /design-doc
                └─→ /design-prototype-docs

아이디어 / 기존 문서
  └─→ /design-doc
        └─→ .docs/DESIGN.md (단일앱) / .docs/{앱}-DESIGN.md (복수앱)
                ├─→ /context-doc
                ├─→ /impl-fe-be-doc 또는 /impl-doc (계획)
                ├─→ /impl-reuse-scan (구현 직전 시작 전 점검)
                ├─→ /impl-verify (Phase 종료 검증)
                └─→ /design-prototype-docs

기존 코드베이스 (문서 없음)
  └─→ /harness-bootstrap
        ├─→ OUTPUT_V2 설계 문서 (역추출)
        └─→ CLAUDE.md + AGENTS.md + .docs/instruction/*-instruction.md

/design-prototype-docs
  └─→ .docs/prototype/{사용자}/{식별자}/design-doc.md
        └─→ /create-prototype
              └─→ .docs/prototype/{사용자}/{PREFIX}-{번호}/ (HTML/CSS/JS/JSON)

코드 변경
  └─→ /multi-review
  └─→ /doc-audit
  └─→ /pre-commit
  └─→ /commit

.claude/skills ↔ .agents/skills 또는 CLAUDE.md ↔ AGENTS.md 불일치
  └─→ /agent-sync (양쪽 내용 맞춤)
```

### 8-2. `design-doc OUTPUT_V2`가 사실상 중심 문서다

`design-doc`는 현재 설계 체계의 중심이며, `OUTPUT_V2`가 가장 중요한 기준 문서다.

#### `context-doc`로 넘어가는 매핑

`context-doc`는 얇은 `CLAUDE.md`와 동일 내용의 `AGENTS.md`(프로젝트 팩트 + 인덱스) + 주제별 `.docs/instruction/*-instruction.md` 7종으로 분할 생성한다. (복수 앱: `.docs/{앱}/instruction/*-instruction.md`)

| `design-doc OUTPUT_V2` 섹션 | 사용처 |
|-----------------------------|--------|
| 01 개요, 05 데이터 설계, 07 라이브러리 | `CLAUDE.md` / `AGENTS.md` 프로젝트 팩트 |
| 06 파일 구성 | `CLAUDE.md` / `AGENTS.md` 트리 + `architecture-instruction.md` + `file-convention-instruction.md` |
| 02 동작 흐름 | `comm-instruction.md` |
| 03 집중 로직 | `architecture-instruction.md` + `framework-instruction.md` |
| 04 인터페이스 설계 | `api-instruction.md` + `comm-instruction.md` |
| 07 라이브러리 (규칙 측면) | `framework-instruction.md` |
| 10 주의사항 | `code-style-instruction.md` / `agent-instruction.md` / 각 주제 금지 목록 |
| 12 열린 결정 사항 | 해당 주제 파일의 `미정` 섹션 |

> 생성되는 instruction 파일: `architecture` / `code-style` / `framework` / `api` / `comm` / `file-convention` / `agent` 중 설계 문서에 해당 내용이 있는 것만. `agent-instruction.md`는 항상 생성.

#### `impl-fe-be-doc`으로 넘어가는 매핑

다중 화면·페어 다중 기능 작업은 `impl-fe-be-doc`으로 넘긴다. 단일 기능·단일 화면·컴포넌트/훅 단독·API 1~수개 작업은 `impl-doc`으로 넘길 수 있다.

| `design-doc OUTPUT_V2` 섹션 | 사용처 |
|-----------------------------|--------|
| 01 개요, 02 동작 흐름 | Phase 분할 기준 |
| 03 집중 로직 | 핵심 Phase의 상세 태스크 |
| 04 인터페이스 설계 | FE 태스크 지시 힌트 |
| 05 데이터 설계 | BE/DB 태스크 |
| 06 파일 구성 | `[NEW]` / `[MODIFY]` 범위 판단 |
| 10 주의사항, 12 열린 결정 사항 | 전역 주의사항 / 미결 사항 |

#### `impl-doc`으로 넘어가는 매핑

단일·소규모 범용 작업, BE 단일 기능(엔드포인트 1~수개, 단일 도메인 로직), FE 단일 기능(컴포넌트/훅/화면 1개 신규·수정)은 `impl-doc`으로 넘길 수 있다.

> **impl 산출물 저장 규칙**: `impl-fe-be-doc`/`impl-doc` 모두 작업지침서를 아래 경로에 저장한다.
> - **단일앱**: `.docs/impl-doc/{사용자}/{기능명}.md`
> - **복수앱**: `.docs/{앱}/impl-doc/{사용자}/{기능명}.md`
>
> `{사용자}`는 git 계정을 우선 탐색해 정하고, 같은 경로면 갱신한다. 파일명은 스킬별로 구분하지 않으며, 어떤 스킬로 만들었는지는 문서 머리말의 `생성 스킬:` 표기로만 구분한다. `impl-reuse-scan`/`impl-verify`는 이 경로의 지침서를 입력으로 참조한다.

#### `impl-fe-be-doc` 화면 중심 모드로 넘어가는 매핑

- 화면 목록
- 화면 간 이동 흐름
- 화면별 대응 SFR
- 공통 컴포넌트 후보
- 화면별 API, 상태, 인터랙션 시나리오

#### `create-prototype`로 넘어가는 매핑

`design-prototype-docs` 산출물(`.docs/prototype/{사용자}/{식별자}/design-doc.md`)은 아래가 채워져 있어야 바로 연결된다.

- 요구사항 번호 / RFP ID / 기능 이름
- 화면 목록 테이블
- 화면 간 흐름 도식
- 화면별 기능 이유
- 레이아웃 구조
- 더미 데이터 예시
- 메인 색상

---

## 9. 품질 확인과 운영 스킬의 역할

| 스킬 | 실행 시점 | 막아주는 문제 |
|------|-----------|---------------|
| `multi-review` | Phase/화면 구현 직후 | 보안, 성능, 유지보수, 테스트 누락 |
| `pre-commit` | 커밋 직전 | 빈 catch, 타임아웃 누락, 민감 정보, TODO 형식, 테스트 부재 |
| `code-comment` | 가독성 보완이 필요할 때 | 변경 파일 문맥 전달 실패 |
| `doc-audit` | 코드와 문서가 어긋난 느낌이 날 때 | 낡은 `CLAUDE.md` / `AGENTS.md`, 낡은 규칙 문서 |
| `agent-sync` | Agent 문서/스킬 변경 후 | 도구별 문서 불일치 |
| `commit` | 스테이징 후 | 메시지 품질 저하, 변경 이유 미정리 |

### 권장 확인 순서

```text
구현 완료
  → multi-review
  → doc-audit (문서 영향이 있을 때)
  → pre-commit
  → code-comment (선택)
  → commit
```

### `pre-commit`가 실제로 보는 것

- 에러를 잡고 무시하는 패턴
- 외부 호출 타임아웃 누락
- 비밀번호/API 키/토큰 하드코딩
- 형식 없는 TODO/FIXME/HACK
- 비즈니스 로직 변경 대비 테스트 존재 여부

### `commit` 스킬 규칙

- description은 한글
- 50자 이내
- scope는 변경 파일/모듈 기준 추론
- body는 "무엇을"보다 "왜" 중심

---

## 10. 병렬화 전략

현재 저장소에서 병렬화 가치가 큰 스킬은 아래다.

| 스킬 | 병렬 단위 | 비고 |
|------|-----------|------|
| `rfp-ingest` | SFR별 | SFR이 2개 이상일 때 의미가 크다 |
| `create-prototype` | 화면별 | 사용자가 모델/개수 선택 |
| `multi-review` | 리뷰 관점 4개 | 가장 확실한 병렬 이득 |
| `doc-audit` | deps / pattern / rulecheck | 문서 괴리 분석 시간 단축 |
| `agent-sync` | Docs / Skills | 범위가 넓을수록 효과적 |
| `code-comment` | 파일별 | 변경 파일이 여러 개일 때만 |
| `custom-skill-design` | 테스트/비교 루프 | Claude Code 환경일수록 효과적 |

### 병렬화하지 않는 편이 좋은 것

- `design-doc`
- `context-doc`
- `impl-*` 본문 설계

이 셋은 순서와 맥락 일관성이 더 중요하다.

---

## 11. 훅(Hook) 전략

### 권장

| 훅 | 목적 | 이유 |
|----|------|------|
| 커밋 전 검사 훅 | `scan.sh` 또는 `/pre-commit` 리마인드 | 가장 자주 빠뜨리는 게 품질 검사다 |
| 세션 종료 리마인드 | 코드 변경 시 `/doc-audit` 권장 | 문서 괴리 누적 방지 |

### 비권장

| 자동화 | 비권장 이유 |
|--------|-------------|
| `design-doc` 완료 즉시 `context-doc` 자동 실행 | 설계 문서가 아직 바뀔 수 있다 |
| `rfp-ingest` 완료 즉시 `design-doc` 자동 실행 | 프로토타입 옵션 분기를 막는다 |
| 모든 커밋 뒤 강제 리뷰/감사 | 비용 대비 노이즈가 크다 |

핵심 원칙은 단순하다.

- **실수 예방용 자동화는 훅으로**
- **의사결정이 필요한 흐름 전환은 명시적 호출로**

---

## 12. AI 코딩 운영 원칙

### 12-1. 웹 기반 AI와 IDE 에이전트는 역할이 다르다

| 상황 | 웹 기반 AI가 강한 쪽 | IDE 에이전트가 강한 쪽 |
|------|------------------|----------------------|
| 긴 탐색 대화 | ✅ | △ |
| 설계 인터뷰 | ✅ | ✅ |
| 웹 검색이 필요한 기술 탐색 | ✅ | △ |
| 실제 파일 생성/수정 | △ | ✅ |
| 구현 지침 문서화 | △ | ✅ |
| 코드 리뷰, 커밋, 동기화 | △ | ✅ |

### 12-2. 대화 단위를 작게 유지한다

좋은 지시의 형태는 거의 항상 아래와 같다.

```text
[참조 문서]
- 설계문서: ...
- 작업지침서: ...
- CLAUDE.md / AGENTS.md / .docs/instruction/*-instruction.md: ...

[이번 턴 범위]
- Phase 2의 BE-03만 구현
- 수정 파일은 A, B로 제한
- 다른 Phase/파일은 건드리지 말 것

[완료 기준]
- 검증 시나리오 1~3 통과 여부 보고
```

### 12-3. 문서를 한 번 만들고 끝내지 않는다

- 구현 중 설계가 바뀌면 문서도 바뀌어야 한다.
- 코드가 맞고 문서가 낡았으면 `doc-audit`로 괴리를 잡고,
- 승인 후 `agent-sync` 또는 직접 수정으로 문서를 맞춘다.

### 12-4. 컨텍스트가 오염되는 신호

아래가 보이면 새 대화로 갈아타는 편이 낫다.

- 이미 결정된 구조를 다시 묻기 시작한다.
- 금지한 패턴이 반복된다.
- 수정 범위를 자꾸 벗어난다.
- 설계 문서와 다른 계층 구조를 만들기 시작한다.

### 12-5. 반복 작업은 스킬화 후보다

같은 작업 흐름을 세 번 이상 반복하면 `custom-skill-design` 후보로 본다.

- 반복 입력 형식이 고정돼 있고
- 출력 형식이 어느 정도 표준화돼 있고
- 사람의 판단 기준이 비교적 명확하면

스킬로 승격할 가치가 높다.

---

## 13. 자주 쓰는 런타임 치트시트

| 지금 상황 | 먼저 쓸 것 | 다음 선택지 |
|-----------|------------|-------------|
| 문서 없는 기존 코드에 하네스를 처음 도입한다 | `harness-bootstrap` | `design-doc`·`context-doc` 보강 |
| 아이디어를 구조화하고 싶다 | `design-doc` | `context-doc`, `impl-*` |
| RFP의 특정 SFR만 풀고 싶다 | `rfp-ingest` | `design-doc` 또는 `design-prototype-docs` |
| 요구사항을 화면 설계 문서로 만들고 싶다 | `design-prototype-docs` | `create-prototype` |
| 실제 HTML 목업이 필요하다 | `create-prototype` | `frontend-design` 참고 |
| 다중 기능 Phase 순서를 정하고 싶다 | `impl-fe-be-doc` | 실제 구현 |
| 화면별 명세가 필요하다 | `impl-fe-be-doc` 화면 중심 모드 | `frontend-design`, 실제 구현 |
| 도구/스크립트 구현 계획이 필요하다 | `impl-doc` | 실제 구현 |
| 구현 직전 중복 자산을 확인하고 싶다 | `impl-reuse-scan` | 실제 구현 |
| Phase 종료 후 검증을 자동화하고 싶다 | `impl-verify` | 다음 Phase |
| 코드와 문서가 어긋난 것 같다 | `doc-audit` | 승인 후 `agent-sync` |
| 커밋 전 품질 점검이 필요하다 | `pre-commit` | `commit` |
| 코드 리뷰가 필요하다 | `multi-review` | 수정 후 재검토 |
| 반복 작업을 스킬로 만들고 싶다 | `custom-skill-design` | eval 루프 |

---

## 14. 빠른 운영 체크리스트

### 새 프로젝트 시작

- [ ] (복수 앱 환경) `git-scoped-account`로 앱별 git 계정 정리.
- [ ] `harness-setup`으로 원본 하네스 저장소의 스킬을 프로젝트에 설치.
- [ ] 문서 없는 기존 코드베이스라면 먼저 `harness-bootstrap`으로 뼈대 추출.
- [ ] `design-doc`로 설계 문서를 만든다.
- [ ] 프로젝트 단위면 `context-doc`로 `CLAUDE.md`, `AGENTS.md`와 주제별 `.docs/instruction/*-instruction.md`를 만든다.
- [ ] 구현 단위에 맞는 `impl-*` 1종을 고른다.
- [ ] 화면 불확실성이 크면 `design-prototype-docs → create-prototype`을 먼저 돌린다.

### 새 화면/기능 추가

- [ ] 화면/기능/로직 중 스케일을 먼저 정한다.
- [ ] 기존 설계 문서에 붙일지, 새 설계를 만들지 결정한다.
- [ ] 다중 화면·페어 다중 기능이면 `impl-fe-be-doc`, 단일·소규모 범용이면 `impl-doc`.
- [ ] UI 감도가 중요하면 `frontend-design` 기준을 같이 적용한다.

### 구현 완료 직후

- [ ] `multi-review`
- [ ] 필요 시 `doc-audit`
- [ ] `pre-commit`
- [ ] 필요 시 `code-comment`
- [ ] `commit`

### 에이전트가 이상한 방향으로 갈 때

- [ ] 바로 멈춘다.
- [ ] 이번 턴 범위를 다시 좁힌다.
- [ ] 참조 문서와 수정 파일 범위를 다시 명시한다.
- [ ] 문서가 낡았다면 `doc-audit`를 먼저 돌린다.
- [ ] 같은 문제가 반복되면 관련 `.docs/instruction/*-instruction.md`에 금지 패턴을 보강한다.

---

## 15. 한 줄 결론

현재 저장소의 하네스 구조는 아래 한 줄로 요약된다.

> `harness-setup`으로 환경을 갖추고, `design-doc`를 중심 문서로 삼아 상황에 맞는 `impl-*` 하나로 구현 단위를 고른 뒤, `multi-review`·`pre-commit`·`doc-audit`로 품질을 확인하는 **하나의 기본 작업 흐름** 구조다. 단일/복수 애플리케이션 모두 같은 흐름을 따른다.

이 흐름만 지켜도 AI 코딩이 즉흥 작업이 아니라 **문서 중심의 반복 가능한 생산 체계**로 바뀐다.
