---
name: doc-audit
description: "프로젝트 코드와 AI Agent 문서 간의 괴리 분석 및 업데이트 제안"
allowed-tools: Read, Glob, Grep, Bash, Task
agent: fork
---

# 문서 감사 (doc-audit)

이 스킬이 호출되면 **현재 프로젝트**의 실제 코드와 AI Agent 문서 간의 괴리를 분석한다.

---

## STEP 0 — 플랫폼 및 실행 방식 확인

`prompts/parallel-setup.md`의 [플랫폼 확인] → [모델 목록 표시] → [실행 방식 선택] 절차를 따른다.

병렬 선택 시 아래 Task 목록을 제시한 뒤 `prompts/parallel-setup.md`의 [모델 확정] 절차를 따른다.

| # | Task | 분석 내용 |
|---|------|----------|
| A | deps-audit | 라이브러리·의존성 괴리 분석 |
| B | pattern-audit | 코드 패턴·아키텍처 괴리 분석 |
| C | rulecheck-audit | 문서 규칙 위반 사례 분석 |

순차 선택 시 Task A → B → C 순서로 직접 수행한다.

---

분석 결과를 문서에 **즉시 반영하지 않는다.**
반드시 변경 제안서를 대화창에 바로 출력하고 **사용자 확인을 받은 후** 진행한다. (별도의 .md 파일 생성 금지)

---

## 분석 대상 문서

현재 프로젝트 루트에서 아래 문서들을 읽어 현재 지침/맥락을 파악한다.

| 문서 | 설명 |
|------|------|
| `README.md` | 프로젝트 개요 및 전체 구조 (핵심) |
| `CLAUDE.md` | Claude AI 전용 지침 |
| `AGENTS.md` | 범용 Agent 지침 (있는 경우) |
| `GEMINI.md` | Gemini AI 전용 지침 (있는 경우) |
| `.instruction/**/*.md` | 세부 코딩 규칙, 아키텍처 가이드 등 (있는 경우) |

---

## 병렬 실행 구조

```
doc-audit (orchestrator)
├── Task A: deps-audit      → 라이브러리/의존성 괴리 분석
├── Task B: pattern-audit   → 코드 패턴·아키텍처 괴리 분석
└── Task C: rulecheck-audit → 문서 규칙 위반 사례 분석
```

각 Task의 상세 지침은 `prompts/` 참조.

---

## Task A — 의존성 분석 (prompts/deps-audit.md)

- 실제 의존성 파일(`requirements.txt`, `package.json`, `pyproject.toml` 등) 수집
- 문서에 언급된 라이브러리와 실제 사용 라이브러리 비교
- 추가됐지만 문서에 없는 항목 → **추가 제안**
- 문서에는 있지만 실제로 제거된 항목 → **삭제 제안**

## Task B — 패턴·아키텍처 분석 (prompts/pattern-audit.md)

- `git log --oneline -30`, `git diff HEAD~5..HEAD` 로 최근 변경 파악
- 소스코드 내 반복 패턴, 예외처리, 새 미들웨어/훅/설정 분석
- 문서에 기술되지 않은 새 패턴 → **추가 제안**
- 버전 정보(프레임워크, 런타임 등) 불일치 → **수정 제안**

## Task C — 규칙 준수 분석 (prompts/rulecheck-audit.md)

- 문서에 명시된 금지 목록, 필수 패턴을 코드에서 위반하는 사례 탐지
- 위반 사례가 잦으면 규칙 자체의 완화 또는 보완 필요 여부 판단
- 규칙 강화 또는 예외 케이스 문서화 → **수정 제안**

---

## 최종 처리

1. Task A, B, C 결과 취합 + 중복 제거
2. 중요도 분류: Critical / Major / Minor
3. 결과 출력 형식은 `templates/audit-report.md` 참조
4. 대화창에 변경 제안서 내용 바로 출력 (.md 파일 생성 금지)
5. **사용자에게 확인 요청** — 승인 전 문서 파일 절대 수정 금지

> ⚠️ 승인 후 반영은 `agent-sync` 스킬 또는 직접 수정으로 진행한다.
