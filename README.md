# AI Agent Harness — Agent Skills

AI 에이전트 환경(Claude Code, Gemini CLI 등)에서 팀이 일관된 결과물을 만들 수 있도록 정리한 **스킬·운영 문서 저장소**입니다.

이 저장소의 내부 기준 이름은 `ai-agent-harness-docs`이며, 현재 GitHub private 저장소로 관리합니다. 프로젝트나 고객사에 공유할 때는 `{프로젝트명}-ai-harness-docs` 이름으로 GitLab·Gitea 같은 사내 저장소에 옮겨 운영할 수 있습니다.

- 대상 저장소: `ai-agent-harness-docs` (GitHub private)
- 공유 시 저장소명: `{프로젝트명}-ai-harness-docs` (GitLab·Gitea 등 사내 저장소)

> 왜 이런 스킬셋이 필요한지: [`Harness_Engineering_Intro.md`](./Docs/Harness_Engineering_Intro.md)

> 현재 저장소 기준 운영 가이드: [`Harness_Engineering.md`](./Docs/Harness_Engineering.md)

> 타 AI 하네스 비교·분석 (과거 스냅샷): [`Agent_Skills_Repo_Structure_Analysis.md`](./Docs/Agent_Skills_Repo_Structure_Analysis.md)

---

## 기본 원칙

- **단일 애플리케이션 프로젝트**(git repo 1개)와 **복수 애플리케이션 프로젝트**(프로젝트 상위 폴더 아래 `.docs`·각 앱·하네스 저장소가 각각 독립 git)를 모두 지원한다.
- 산출물 생성 또는 코드·커밋 적용범위를 갖는 스킬은 STEP 0에서 **프로젝트 유형 확인 단계**를 거친다. 프로젝트 유형에 따라 산출물 경로가 달라진다.
- `skills/`가 스킬·프롬프트·템플릿의 **원본**이며, 프로젝트에는 `harness-setup`으로 설치한다.

---

## 빠른 시작 — 프로젝트에 하네스 설치

```text
# 1. 프로젝트 상위 폴더에서 이 저장소를 clone
git clone <이 저장소 URL> {프로젝트명}-ai-harness-docs

# 2-A. 프로젝트 상위 폴더에서 하네스 스킬 파일을 직접 지정해 설치 또는 갱신
@{프로젝트명}-ai-harness-docs/.agents/skills/harness-setup/SKILL.md 하네스 설치 또는 갱신해줘

# 2-B. 또는 원본 하네스 저장소로 이동한 뒤 실행
cd {프로젝트명}-ai-harness-docs
@.agents/skills/harness-setup/SKILL.md 하네스 설치 또는 갱신해줘
```

`harness-setup`은 현재 폴더 구조를 살핀 뒤 단일/복수 애플리케이션 프로젝트 여부와 적용 대상을 사용자에게 확인한다. 프로젝트 폴더 안에서 바로 `/harness-setup`을 실행하기 전에, 위 예시처럼 원본 하네스 저장소의 `harness-setup` 스킬 위치를 `@`로 지정하거나 원본 하네스 저장소로 이동한 뒤 스킬 파일을 지정해 실행한다. 승인 후 `.claude/skills`·`.agents/skills`에 스킬을 설치하고, 프로젝트 유형에 맞는 `.docs/` 구조와 `CLAUDE.md`/`AGENTS.md`를 준비한다. 이후 원본 하네스 저장소가 업데이트되면 같은 방식으로 다시 실행해 배포본을 갱신한다.

### 먼저 권장 — 프로젝트 루트에 git 계정 설정

하네스를 설치하기 전, **앞단계로** 프로젝트 최상위 루트에서 [`git-scoped-account`](./skills/git-scoped-account/SKILL.md) 스킬로 GitHub·GitLab·Gitea 등 형상관리에 사용할 git 계정(`user.name`/`user.email`)을 먼저 설정하는 것을 권장한다. 전역 `~/.gitconfig`는 건드리지 않고 지정한 상위 디렉토리 바로 아래 git repo들에만 `include.path` 방식으로 공통 계정을 일괄 적용한다.

```text
# 프로젝트 상위 폴더에서 git 계정을 먼저 설정 (전역 설정은 변경하지 않음)
@{프로젝트명}-ai-harness-docs/.agents/skills/git-scoped-account/SKILL.md 이 폴더 아래 repo들 git 계정 한 번에 설정해줘
```

**왜 앞단계에서 하는가:** `commit` 등 일부 스킬의 산출물(커밋 작성자, 문서 작성자 표기 등)이 git 계정·사용자 이름을 입력값으로 사용하도록 되어 있다. 루트에서 git 계정을 미리 정해 두면, 이후 하네스 산출물이 일관된 작성자 정보로 생성·커밋되어 프로젝트마다 계정이 섞이는 문제를 예방할 수 있다. 특히 한 사용자가 GitHub·GitLab·Gitea 등 저장소별로 다른 계정을 쓰는 환경에서는 이 디렉토리 트리에만 맞는 계정을 먼저 고정해 두는 것이 안전하다.

### 복수 애플리케이션 — 기존 `.docs` 저장소가 있는 경우

복수 애플리케이션 프로젝트에서 `.docs/`는 프로젝트 루트와 별개로 **독립된 git 저장소**로 관리한다. 이미 `.docs`가 원격 git에 올라가 있는 프로젝트(다른 팀원이 먼저 세팅했거나, 새 머신에서 이어받는 경우)라면, **먼저 `.docs` 저장소를 받은 뒤** `harness-setup`으로 문서 내용·위치를 갱신한다.

```text
# 1. 프로젝트 상위 폴더에서 .docs 저장소를 먼저 clone (또는 기존 것을 pull)
git clone <.docs 저장소 URL> .docs

# 2. 원본 하네스 저장소도 받는다 (위 빠른 시작 1번 참고)
git clone <이 저장소 URL> {프로젝트명}-ai-harness-docs

# 3. harness-setup으로 문서 내용·위치 설정 및 갱신
@{프로젝트명}-ai-harness-docs/.agents/skills/harness-setup/SKILL.md 하네스 설치 또는 갱신해줘
```

`harness-setup`은 이미 존재하는 `.docs/`를 인식해 갱신 모드로 동작한다. 받아온 `.docs/root-context/CLAUDE.md`·`.docs/root-context/AGENTS.md`를 원본으로 삼아 git으로 관리하지 않는 루트 `CLAUDE.md`·`AGENTS.md`를 다시 만들거나 갱신하고, 앱별 컨텍스트(`.docs/{앱}-context.md`, `.docs/{앱}/instruction/*`)의 위치와 루트 인덱스의 연결을 정리한다. 즉 `.docs`를 먼저 받아 두면 루트의 미관리 파일들이 받아온 문서 내용 기준으로 일관되게 복원된다.

> 순서가 중요하다: `.docs`를 받기 전에 `harness-setup`을 돌리면 루트 컨텍스트의 원본이 없어 빈 골격만 생성된다. 반드시 `.docs`를 먼저 받은 뒤 실행한다.

### 단일 애플리케이션 프로젝트 예시

단일 앱은 애플리케이션 레포 안에서 소스코드와 하네스 산출물을 함께 관리한다.

```text
acro/
├── acro-portal/                  ← 애플리케이션 레포 (git 관리)
│   ├── .claude/                  ← Claude Code용 스킬 배포본
│   │   └── skills/
│   ├── .agents/                  ← Codex 등 Agent용 스킬 배포본
│   │   └── skills/
│   ├── .docs/                    ← 설계/컨텍스트/구현 지침 산출물
│   ├── CLAUDE.md                 ← Claude용 프로젝트 컨텍스트
│   ├── AGENTS.md                 ← Codex/공용 Agent 컨텍스트
│   └── src/                      ← 소스코드 구조
└── acro-ai-harness-docs/         ← 원본 하네스 저장소 (별도 git 관리)
```

단일 앱에서 git으로 관리되는 대상:

- `acro-portal/`: 소스코드, `.docs/*`, `CLAUDE.md`, `AGENTS.md`, `.claude/skills`, `.agents/skills`
- `acro-ai-harness-docs/`: 원본 `skills/`, 운영 문서, 템플릿

### 복수 애플리케이션 프로젝트 예시

복수 앱은 프로젝트 최상위 폴더 자체를 git으로 관리하지 않는다. 각 애플리케이션과 원본 하네스 저장소, `.docs` 저장소를 각각 독립 저장소로 관리한다.

```text
acro/                             ← 프로젝트 상위 폴더 (git 관리 안 함)
├── acro-fe-portal/               ← 애플리케이션 레포 1 (git 관리)
│   └── src/                      ← 소스코드 구조
├── acro-be-portal/               ← 애플리케이션 레포 2 (git 관리)
│   └── src/                      ← 소스코드 구조
├── acro-be-collector/            ← 애플리케이션 레포 3 (git 관리)
│   └── src/                      ← 소스코드 구조
├── acro-ai-harness-docs/         ← 원본 하네스 저장소 (별도 git 관리)
├── .docs/                        ← 프로젝트 전체 AI 문서 저장소 (별도 git 레포로 관리)
│   ├── root-context/             ← 루트 CLAUDE.md/AGENTS.md의 원본 복사본
│   │   ├── CLAUDE.md             ← 루트 통합 인덱스 원본
│   │   └── AGENTS.md             ← 루트 통합 인덱스 원본
│   ├── acro-fe-portal-context.md
│   ├── acro-fe-portal/
│   ├── acro-be-portal-context.md
│   ├── acro-be-portal/
│   ├── acro-be-collector-context.md
│   └── acro-be-collector/
├── .claude/                      ← 프로젝트 루트 배포본 (git 미관리)
├── .agents/                      ← 프로젝트 루트 배포본 (git 미관리)
├── CLAUDE.md                     ← 루트 통합 인덱스 (git 미관리)
└── AGENTS.md                     ← 루트 통합 인덱스 (git 미관리)
```

복수 앱에서 git으로 관리되는 대상:

- 각 애플리케이션 레포: 각 앱의 소스코드와 앱별 설정
- `acro-ai-harness-docs/`: 원본 `skills/`, 운영 문서, 템플릿
- `.docs/`: 프로젝트 전체 AI 문서와 앱별 컨텍스트 문서 (별도 git 레포로 관리). 초기 개인 실험 단계에서는 remote 연결 전일 수 있음

복수 앱에서 git으로 관리하지 않는 대상:

- 프로젝트 최상위 `acro/`
- 루트 `.claude/*`, `.agents/*`, `CLAUDE.md`, `AGENTS.md`

이 git으로 관리하지 않는 루트 파일들은 `harness-setup`이 원본 하네스 저장소와 `.docs/root-context/`를 기준으로 다시 만들거나 갱신한다.

루트 컨텍스트 파일의 관계:

```text
.docs/root-context/CLAUDE.md   ─┐
                                ├─ /harness-setup 재실행 → acro/CLAUDE.md
.docs/root-context/AGENTS.md   ─┘                         → acro/AGENTS.md
```

- `.docs/root-context/CLAUDE.md`, `.docs/root-context/AGENTS.md`: git으로 관리되는 `.docs` 레포 안의 원본 복사본
- `acro/CLAUDE.md`, `acro/AGENTS.md`: 프로젝트 최상위에 놓이는 실행용 루트 인덱스. git으로 관리하지 않고 `harness-setup`이 갱신
- 앱별 상세 컨텍스트는 `.docs/{앱}-context.md`와 `.docs/{앱}/instruction/*-instruction.md`에 두고, 루트 인덱스는 각 앱 문서의 위치를 안내하는 역할만 한다

### 원본 최신화와 배포 방식

이 저장소는 스킬의 원본이다. 스킬을 고칠 때는 먼저 `{프로젝트명}-ai-harness-docs/skills/{스킬명}/`을 수정하고 커밋한다.

```text
{프로젝트명}-ai-harness-docs/skills/*       ← 원본
        │
        └─ /harness-setup 재실행
              ├─ 단일 앱: 애플리케이션 레포의 .claude/skills, .agents/skills 갱신
              └─ 복수 앱: 프로젝트 루트의 .claude/skills, .agents/skills 갱신
```

`.claude/skills`와 `.agents/skills`는 배포본이다. 두 경로 사이의 내용만 맞출 때는 `agent-sync`를 사용하고, 원본 하네스 저장소의 최신 내용을 프로젝트에 가져올 때는 `harness-setup`을 사용한다.

### 산출물·스킬 형상관리 기준

하네스 관련 파일은 모두 같은 성격이 아니다. 어떤 파일은 원본이고, 어떤 파일은 원본에서 복사된 배포본이며, 어떤 파일은 프로젝트에서 새로 만들어지는 산출물이다.

| 경로 | 성격 | 최신화 방법 | git 관리 기준 |
|------|------|-------------|---------------|
| `{프로젝트명}-ai-harness-docs/skills/*` | 스킬 원본 | 사람이 수정 후 커밋 | 원본 하네스 저장소에서 관리 |
| `{프로젝트명}-ai-harness-docs/Docs/*` | 운영·소개 문서 원본 | 사람이 수정 후 커밋 | 원본 하네스 저장소에서 관리 |
| `.claude/skills/*` | Claude Code용 스킬 배포본 | `harness-setup`으로 원본에서 갱신 | 단일 앱은 앱 레포에서 관리, 복수 앱 루트는 git 미관리 |
| `.agents/skills/*` | Codex 등 Agent용 스킬 배포본 | `harness-setup`으로 원본에서 갱신 | 단일 앱은 앱 레포에서 관리, 복수 앱 루트는 git 미관리 |
| `.docs/*` | 설계·컨텍스트·구현 지침 산출물 | `context-doc`, `impl-*`, `doc-audit` 등으로 생성·수정 | 단일 앱은 앱 레포에서 관리, 복수 앱은 별도 `.docs` 저장소에서 관리 |
| `.docs/root-context/*` | 복수 앱 루트 컨텍스트의 원본 복사본 | `context-doc` 또는 수동 수정 후 커밋 | 복수 앱의 별도 `.docs` 저장소에서 관리 |
| 루트 `CLAUDE.md`, `AGENTS.md` | 에이전트가 읽는 실행용 인덱스 | `harness-setup` 또는 `agent-sync`로 갱신 | 단일 앱은 앱 레포에서 관리, 복수 앱 루트는 git 미관리 |

최신화 흐름은 아래처럼 나눈다.

```text
스킬 최신화
  원본 하네스 저장소 skills/* 수정·커밋
    └─ /harness-setup
        ├─ .claude/skills/* 갱신
        └─ .agents/skills/* 갱신

프로젝트 문서 최신화
  설계/구현/검증 과정에서 .docs/* 생성·수정
    ├─ 단일 앱: 애플리케이션 레포에 커밋
    └─ 복수 앱: 별도 .docs 저장소에 커밋

루트 에이전트 문서 최신화
  단일 앱: CLAUDE.md / AGENTS.md를 앱 레포에서 직접 관리
  복수 앱: .docs/root-context/*를 원본으로 관리
    └─ /harness-setup 재실행
        ├─ 프로젝트 루트 CLAUDE.md 재생성 또는 갱신
        └─ 프로젝트 루트 AGENTS.md 재생성 또는 갱신
```

정리하면, 스킬은 원본 하네스 저장소에서 고치고 `harness-setup`으로 배포한다. 프로젝트별 설계·구현 문서는 `.docs/*`에 쌓고 해당 프로젝트의 git 정책에 맞게 커밋한다. 복수 앱 프로젝트의 루트 `.claude/*`, `.agents/*`, `CLAUDE.md`, `AGENTS.md`는 실행용 파일이므로 프로젝트 최상위에서 직접 형상관리하지 않는다.

---

## 디렉토리 구조

```
ai-agent-harness-docs/                   ← 원본 하네스 저장소
├── skills/                      ← 모든 스킬의 원본 (20종)
│   ├── harness-setup/           ← 프로젝트에 하네스 설치·업데이트
│   ├── custom-skill-design/     ← 새 스킬 설계·생성·검증
│   └── ... (18종 더)
├── Docs/                        ← 운영·소개·분석 문서
│   ├── Harness_Engineering.md   ← 운영 가이드 (스킬 목록·작업 흐름·입출력 약속)
│   ├── Harness_Engineering_Intro.md ← 도입 배경 문서
│   └── Agent_Skills_Repo_Structure_Analysis.md ← 외부 하네스 비교 분석 (과거 스냅샷)
├── improvement_plan/            ← 리팩토링 의사결정·점검 이력
│   └── 20260627/
├── example/                     ← 산출물 예시
├── .claude/skills/              ← 이 레포 자체용 (harness-setup + custom-skill-design)
└── .agents/skills/              ← 이 레포 자체용 (동일)
```

---

## Agent Skills

IDE 에이전트(Claude Code 등)에서 `/스킬명`으로 호출하는 작업 스킬입니다.

### 설계·컨텍스트 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `harness-setup` | `하네스 설치`, `스킬 업데이트` | 원본 하네스 저장소에서 스킬·문서를 프로젝트에 설치·업데이트 + git으로 관리하지 않는 루트 파일 관리 |
| `rfp-ingest` | `RFP 분석해줘`, `SFR-019 추출` | RFP에서 SFR 추출 및 화면 후보 매핑 → 대화 컨텍스트로 전달 (파일 미생성) |
| `design-doc` | `설계해줘`, `PRD 만들어줘` | 인터뷰 기반으로 구조화된 설계 문서 도출 |
| `context-doc` | `CLAUDE.md 만들어줘`, `AGENTS.md 만들어줘`, `instruction 생성` | 설계 문서 → 얇은 `CLAUDE.md`와 동일 내용의 `AGENTS.md`(프로젝트 팩트 + 인덱스) + 주제별 `.docs/instruction/*-instruction.md` 자동 생성 |
| `harness-bootstrap` | `기존 프로젝트 문서화`, `하네스 부팅` | 레거시/기존 코드베이스 분석 → `design-doc` OUTPUT + `context-doc` 결과물 역추출 |

### 프로토타입·UI 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `design-prototype-docs` | `목업 문서 만들어줘`, `화면 설계 문서` | `create-prototype` 입력용 목업 디자인 `.md` 생성 |
| `create-prototype` | `프로토타입 만들어줘`, `화면 시안` | HTML/CSS 인터랙티브 프로토타입 생성 |
| `frontend-design` | `화면 만들어줘`, `UI 개발` | 클리셰 없는 완성도 높은 프론트엔드 코드 작성 가이드 |

### 구현 지침 계열 (4종)

설계 문서를 바탕으로 AI 에이전트가 코드를 작성할 수 있는 단계별 구현 명세서를 생성합니다.
상황에 따라 계획 스킬 2종과 시작 전 점검·검증 스킬 2종을 조합합니다.

| 스킬 | 트리거 예시 | 적합한 경우 |
|------|------------|------------|
| `impl-fe-be-doc` | `작업지침서 만들어줘`, `Phase 나눠줘`, `화면별 구현 지침` | FE/BE 페어 다중 기능, RFP/SFR 기반 다중 화면 구현 |
| `impl-doc` | `구현 계획 세워줘`, `스크립트 구현 가이드` | 단일 기능(BE 1~수개 / FE 컴포넌트·훅·화면 1개), CLI, 자동화, 라이브러리 |
| `impl-reuse-scan` | `공통 자산 스캔`, `중복 구현 방지`, `Phase 시작 전 점검` | 작업지침서가 손댈 영역의 기존 API/DTO/Entity/Component/Hook/Util을 코드베이스에서 발견·보고(자동 반영 금지) |
| `impl-verify` | `구현 검증`, `Phase 검증`, `단계별 검증`, `페이즈 종료 검증` | 작업지침서의 검증 기준·통합 검증 시나리오를 추출해 PASS/FAIL 매트릭스 산출(코드/지침서 수정 금지) |

### 품질·운영 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `multi-review` | `코드 리뷰해줘` | Security / Performance / Maintainability / Testing 4관점 병렬 리뷰 |
| `pre-commit` | (커밋 전 자동 또는 수동 호출) | 에러 처리·민감 정보·타임아웃 등 규칙 준수 여부 스캔 |
| `commit` | `커밋해줘`, `커밋 메시지 만들어줘` | Conventional Commits 규격 커밋 메시지 생성 및 커밋 실행 |
| `code-comment` | `주석 달아줘`, `comment 추가` | 변경된 파일에 한글 주석 자동 작성·갱신 |
| `doc-audit` | `문서 괴리 분석`, `agent 문서 점검` | 코드와 Agent 문서 간 불일치 탐지 및 업데이트 제안 |
| `agent-sync` | `동기화해줘`, `sync` | CLAUDE.md / AGENTS.md / Skills 등 Agent 관련 문서의 양쪽 내용 맞춤 (원본 하네스 저장소에서 가져오는 일은 harness-setup 담당) |
| `git-scoped-account` | `이 폴더 아래 repo들 git 계정 한 번에 바꿔줘`, `전역 설정 안 건드리고 하위 repo 계정 일괄 적용` | 전역 `~/.gitconfig`를 건드리지 않고 지정 상위 디렉토리 하위 git repo들에 공통 계정(user.name/email)을 `include.path` 방식으로 일괄 적용·확인 |

### 메타 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `custom-skill-design` | `스킬 만들어줘`, `스킬 설계` | 새 스킬 설계·생성·테스트·트리거 최적화 |

## Harness Engineering 문서

### [`Harness_Engineering_Intro.md`](./Docs/Harness_Engineering_Intro.md)

팀에서 AI를 쓰면 왜 결과물이 흔들리는지, 그 문제를 해결하기 위해 왜 공통 하네스가 필요한지를 설명하는 **도입 배경 문서**입니다.

### [`Harness_Engineering.md`](./Docs/Harness_Engineering.md)

현재 저장소 기준 스킬 목록, 단일 작업 흐름(RFP·아이디어·레거시 모두 같은 흐름으로 합류), 스킬 간 입출력 약속을 정리한 **운영 가이드**입니다.
