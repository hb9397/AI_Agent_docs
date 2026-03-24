---
name: agent-sync
description: "Agent 문서(CLAUDE.md/AGENTS.md/GEMINI.md) 또는 Skills를 동기화할 때, 변경된 Agent 관련 파일을 다른 에이전트에도 반영할 때, 스킬을 동기화·복사할 때, sync·동기화를 요청할 때 호출한다."
allowed-tools: Read, Write, Glob, Grep, Bash, Task
agent: fork
---

# AI Agent 동기화 (agent-sync)

변경된 Agent 문서 또는 Skills를 감지하여 지정된 범위에 따라 다른 에이전트 경로에도 반영한다.
파일 반영 전 반드시 사용자 확인을 거친다.

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

### Task A — 문서 동기화

- 대상: Step 2에서 수집된 변경된 Doc 파일 목록
- 규칙: `prompts/docs-sync.md` 참조

### Task B — Skills 동기화

- 대상: Step 2에서 수집된 변경된 Skills 경로 목록
- 규칙: `prompts/skills-sync.md` 참조

---

## Step 4 — 결과 보고

두 Task 완료 후 결과를 취합하여 대화창에 종합 리포트를 바로 출력한다. (별도의 .md 파일 생성 금지)
