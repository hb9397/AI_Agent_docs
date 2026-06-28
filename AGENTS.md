# AI Agent Harness — Agent 운영 가이드

> AI 에이전트 스킬·운영 문서 정본 레포  
> 단일/복수 애플리케이션 프로젝트를 모두 지원하는 공통 하네스

---

## 프로젝트 개요

이 저장소는 AI 에이전트(Claude Code, Gemini CLI 등)가 팀 공통 품질 기준으로 작업하기 위한 **스킬·프롬프트·템플릿·운영 문서의 단일 원천(source of truth)**이다.

- 총 20종 스킬이 `skills/` 디렉토리에 있다
- 프로젝트에는 `harness-setup` 스킬로 설치·업데이트한다
- 이 레포 자체의 `.claude/skills`와 `.agents/skills`에는 `harness-setup`과 `custom-skill-design`만 배치한다

## 디렉토리 구조

```
AI_Agent_docs/
├── skills/                        ← 모든 스킬의 단일 소스 (20종)
│   ├── harness-setup/             ← 프로젝트에 하네스 설치·갱신
│   ├── custom-skill-design/       ← 새 스킬 설계·생성·검증
│   ├── design-doc/                ← 설계 문서 생성
│   ├── context-doc/               ← 컨텍스트 문서 생성
│   └── ... (16종 더)
├── Docs/                          ← 운영·소개·분석 문서
│   ├── Harness_Engineering.md     ← 운영 가이드 (스킬 맵·흐름·데이터 계약)
│   ├── Harness_Engineering_Intro.md ← 도입 배경 문서
│   └── Agent_Skills_Repo_Structure_Analysis.md ← 외부 하네스 비교 분석
├── improvement_plan/              ← 리팩토링 의사결정·점검 이력
│   └── 20260627/리팩토링 작업 계획서.md
├── example/                       ← 산출물 예시
├── .claude/skills/                ← 이 레포용 시드 (harness-setup + custom-skill-design)
└── .agents/skills/                ← 이 레포용 시드 (동일)
```

## 핵심 규칙

### 스킬 편집 시 준수 사항

1. **`skills/`가 단일 원천** — 스킬 수정은 반드시 `skills/{스킬명}/` 에서만 한다. `.claude/skills`나 `.agents/skills`는 배포 사본이다.
2. **C-1 게이트** — 산출물·적용범위 스킬의 STEP 0에는 프로젝트 유형(단일/복수) 감지 + 사용자 확인이 있어야 한다.
3. **C-2 경로 표준** — `.docs/` 경로는 단일/복수에 따라 분기한다 (상세: `improvement_plan/20260627/리팩토링 작업 계획서.md` §3-2).
4. **C-3 포맷** — SKILL.md frontmatter는 Claude 양식(`name`, `description`, `allowed-tools`)을 유지하되, 본문은 Codex 등 타 플랫폼에서도 해석 가능한 중립 서술이어야 한다.
5. **금지 항목** — `model:` 필드 금지, `agent: fork` 하드코딩 금지 (서브에이전트 사용은 STEP 0 질문 게이트로).
6. **규칙 인라인** — 스킬 간 참조 금지. 규칙은 각 스킬에 인라인 복제한다.

### harness-setup ↔ agent-sync 경계

| 영역 | 담당 |
|------|------|
| 정본 레포 → 프로젝트 pull | harness-setup |
| 복수앱 루트 미관리 파일 | harness-setup 전담 (agent-sync 접근 금지) |
| `.claude/skills` ↔ `.agents/skills` 횡적 미러 | agent-sync |
| 단일앱 `CLAUDE.md` ↔ `AGENTS.md` 횡적 | agent-sync |

### 이 레포에서 작업할 때

- 스킬을 수정한 뒤 `.claude/skills` / `.agents/skills` 시드도 함께 갱신해야 한다 (해당 2종에 한해).
- `Docs/Harness_Engineering.md`와 `Docs/Harness_Engineering_Intro.md`는 스킬 변경 시 함께 업데이트한다.
- 커밋 메시지는 Conventional Commits 규격을 따른다.

## 참조 문서

- [Harness_Engineering.md](./Docs/Harness_Engineering.md) — 스킬 맵, 단일 통합 흐름, 데이터 계약
- [Harness_Engineering_Intro.md](./Docs/Harness_Engineering_Intro.md) — 도입 배경, 철학, 사용 예시
- [리팩토링 작업 계획서.md](./improvement_plan/20260627/리팩토링%20작업%20계획서.md) — D-1~D-7 의사결정, C-1/C-2/C-3 공통 규약
- [Agent_Skills_Repo_Structure_Analysis.md](./Docs/Agent_Skills_Repo_Structure_Analysis.md) — 타 AI 하네스 비교 분석
