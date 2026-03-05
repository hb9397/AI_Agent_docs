---
name: agent-sync
description: "AI Agent 문서 및 Skills 동기화"
allowed-tools: Read, Write, Glob, Grep, Bash, Task
agent: fork
---

# AI Agent 동기화 (agent-sync)

이 스킬이 호출되면 **Task(sub-agent)를 병렬로 실행**하여 아래 두 가지 동기화 작업을 수행하세요.
sub-agent를 지원하지 않는 환경이라면 순차적으로 직접 수행하세요.

---

## 병렬 실행 구조

```
agent-sync (orchestrator)
├── Task A: docs-sync     → CLAUDE.md / AGENTS.md / GEMINI.md 동기화
└── Task B: skills-sync   → Skills 디렉토리 + .gemini/commands 동기화
```

두 Task를 **동시에(병렬로)** 실행하고, 완료 후 결과를 취합하여 대화창(채팅창)에 바로 출력한다. (별도의 .md 파일 생성 금지)

---

## Task A — 문서 동기화

CLAUDE.md / AGENTS.md / GEMINI.md 를 프로젝트 전체에서 동기화한다. → [prompts/docs-sync.md](prompts/docs-sync.md)

## Task B — Skills 동기화

`.agents/skills/`, `.claude/skills/`, `.gemini/commands/` 를 동기화한다. → [prompts/skills-sync.md](prompts/skills-sync.md)

---

## 결과 보고

두 Task 완료 후 결과를 취합하여 대화창에 종합 리포트를 바로 출력한다. (별도의 .md 파일 생성 금지)
