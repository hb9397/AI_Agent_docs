---
name: agent-sync
description: "Agent 문서(CLAUDE.md/AGENTS.md) 또는 Skills를 횡적 동기화할 때, 변경된 Agent 관련 파일을 다른 에이전트 경로에도 반영할 때, sync·동기화를 요청할 때 호출한다."
allowed-tools: Read, Write, Glob, Grep, Bash, Task
---

# AI Agent 동기화 (agent-sync)

변경된 Agent 문서 또는 Skills를 감지하여 **횡적(lateral)** 범위에서 다른 에이전트 경로에도 반영한다.
파일 반영 전 반드시 사용자 확인을 거친다.

---

## harness-setup ↔ agent-sync 책임 경계

| 대상 | 담당 | 비고 |
|------|------|------|
| 원본 하네스 레포(`AI_Agent_docs`) → 프로젝트 `skills/` 풀(pull) | **harness-setup** | 상류(upstream) 방향 |
| 복수앱 루트 미관리 `CLAUDE.md`/`AGENTS.md` + `.docs/root-context/` 복사본 | **harness-setup 전담** | agent-sync 접근 **금지** |
| `.claude/skills` ↔ `.agents/skills` 횡적 미러 | **agent-sync** | 횡적·변경 기반 |
| 단일앱 루트 `CLAUDE.md` ↔ `AGENTS.md` 일치 | **agent-sync** | 횡적·변경 기반 |
| 복수앱 앱별 컨텍스트(`.docs/{앱}-context.md` 등) 변경 미러 | **agent-sync** | 횡적·변경 기반 |

> **원칙**: 원본 하네스 레포 pull과 복수앱 루트 미관리 파일은 harness-setup 전담이다.
> agent-sync는 **횡적 일치**만 담당한다.

---

## STEP 0 — 플랫폼·실행 방식 확인 + 프로젝트 유형 확인

#### STEP 0-A — 플랫폼·실행 방식 확인

`prompts/parallel-setup.md`의 [플랫폼 확인] → [모델 목록 표시] → [실행 방식 선택] 절차를 따른다.

병렬 선택 시 아래 Task 목록을 제시한 뒤 `prompts/parallel-setup.md`의 [모델 확정] 절차를 따른다.

| # | Task | 내용 |
|---|------|------|
| A | docs-sync | CLAUDE.md / AGENTS.md 등 Agent 문서 횡적 동기화 |
| B | skills-sync | `.claude/skills` ↔ `.agents/skills` 횡적 동기화 |

> 진입 분기에서 단일 Task만 실행하는 경우(Docs만 / Skills만)에는 해당 Task만 제시한다.
> 순차 선택 시 아래 진입 분기로 직접 진행한다.

#### STEP 0-B — 프로젝트 유형 확인 (C-1 확인 단계)

동기화 범위를 확정하기 위해 **반드시** 아래를 수행한다.

1. 현재 수행 위치에서 프로젝트 구조를 탐색한다 (git repo 경계, 하위 앱 폴더 후보 스캔).
2. **단일 애플리케이션 프로젝트**인지 **복수 애플리케이션 프로젝트**인지 판정한다.
3. 판정 결과 + 동기화 대상을 사용자에게 **반드시 재확인**한다.
4. **복수 앱인 경우**: 루트 미관리 `CLAUDE.md`/`AGENTS.md`와 `.docs/root-context/`는 **이 스킬의 범위 밖**임을 인지한다 (harness-setup 전담).

---

## 진입 분기

| 상황 | 실행할 Task |
| ---- | ----------- |
| "Skills만" / "스킬만" 지정 | Step 1 → 2 → **Task B만** |
| "Docs만" / "문서만" / "CLAUDE.md만" 등 문서 지정 | Step 1 → 2 → **Task A만** |
| 특정 파일 또는 경로 지정 | Step 1 → 2 → 파일 유형에 따라 A 또는 B |
| 미지정 (전체) | Step 1 → 2 → **Task A + B 병렬 실행** |

---

## Step 1 — Git 적용 여부 감지

세부 규칙은 `prompts/change-detection.md`의 [Git 감지] 섹션을 참조한다.

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

git 미적용 시 `prompts/change-detection.md`의 [OS 감지] 섹션으로 이동한다.

---

## Step 2 — 변경된 Agent 문서 감지

진입 분기에서 **특정 파일이 지정된 경우** → 감지 없이 해당 파일을 대상 목록으로 직접 사용하고 Step 3으로 진행한다.

특정 파일이 지정되지 않은 경우 → `prompts/change-detection.md`의 [변경 파일 감지] 섹션을 참조하여 아래 두 목록을 수집한다.

- **변경된 Doc 파일 목록** → Task A 입력
- **변경된 Skills 경로 목록** → Task B 입력

변경이 전혀 감지되지 않으면 사용자에게 알리고 종료한다.

감지 결과를 대화창에 출력한 후 확인 게이트를 거친다:

> ✋ **확인 게이트**
> 위 변경 내역을 동기화하겠습니까? **(승인 / 범위 수정 / 취소)**
> **승인 전 파일을 절대 수정하지 않는다.**

---

## Step 3 — 동기화 실행

진입 분기와 Step 2 감지 결과에 따라 Task를 실행한다.

sub-agent 지원 환경이면 Task A · B를 병렬 실행한다.
미지원 환경이면 순차로 직접 수행한다.

├── Task A: 문서 동기화 → `prompts/docs-sync.md` 참조
└── Task B: Skills 동기화 → `prompts/skills-sync.md` 참조

---

## Step 4 — 결과 보고

두 Task 완료 후 결과를 취합하여 대화창에 종합 리포트를 바로 출력한다. (별도의 .md 파일 생성 금지)
결과 출력 형식은 `templates/sync-result.md` 참조.
