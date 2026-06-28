---
name: harness-setup
description: >
  프로젝트에 AI 하네스를 설치·설정·갱신한다.
  '하네스 설정', '하네스 세팅', '프로젝트 세팅', '스킬 설치',
  '하네스 설치', 'setup', '초기 설정', '프로젝트 초기화',
  '하네스 갱신', '스킬 최신화', '하네스 업데이트',
  'harness setup', 'harness init' 요청이 오면 이 스킬을 사용한다.
  이 저장소(AI_Agent_docs / {프로젝트명}-AI-Harness-docs)를 clone 받은 뒤,
  단일/복수 애플리케이션 프로젝트를 판별하여 스킬·컨텍스트 구조를 자동 세팅한다.
  이미 세팅된 프로젝트에서 재실행하면 스킬·컨텍스트를 최신화한다.
allowed-tools: Read, Write, Glob, Grep, Bash
---

## 스킬 연계

```
{하네스 레포}/skills/*
    ↓
harness-setup  ← 지금 여기
    ↓
프로젝트에 .claude/skills, .agents/skills, .docs/ 구조 세팅
    ↓
design-doc, context-doc 등 후속 스킬 사용 가능
```

---

## harness-setup ↔ agent-sync 책임 경계

이 스킬과 `agent-sync`는 동기화 **방향**이 다르다. 아래 경계를 엄격히 준수한다.

| 영역 | 소유 스킬 | 비고 |
|------|-----------|------|
| 원본 하네스 레포 → 프로젝트 `.claude/skills`·`.agents/skills` **pull** | **harness-setup 전담** | 상류→하류 단방향 |
| 복수앱 **루트 미관리** `CLAUDE.md`/`AGENTS.md` + `.docs/root-context/` 복사본 | **harness-setup 전담** | agent-sync 접근 **금지** |
| git 관리 컨텍스트 횡적 일치(CLAUDE↔AGENTS), 로컬 `.claude/skills↔.agents/skills` 미러 | **agent-sync** | 횡적·변경기반 |

---

## Step 0 — 플랫폼 및 실행 방식 확인

사용자에게 아래를 확인한다:

> 1. 서브에이전트(병렬 처리)를 사용할 수 있는 환경인가요? (Claude Code / Codex / 기타)
> 2. 사용할 경우 병렬 실행을 원하시나요?

서브에이전트 미지원 또는 미사용 선택 시 순차 실행한다.

---

## Step 1 — 실행 컨텍스트 감지

`prompts/detection.md`의 [실행 컨텍스트 감지] 섹션을 참조하여 아래를 판정한다:

| 감지 결과 | 의미 | 다음 동작 |
|-----------|------|-----------|
| 원본 하네스 레포 내부에서 실행 중 | 최초 세팅 또는 외부 프로젝트 대상 | **부모 폴더**를 프로젝트 루트 후보로 설정 → Step 2 |
| 이미 배포된 프로젝트에서 실행 중 | 갱신 모드 | **현재 위치**를 프로젝트 루트로 설정 → Step 2 |
| 판별 불가 | — | 사용자에게 프로젝트 루트 경로를 직접 질문 |

감지 결과를 사용자에게 보여주고 **반드시 확인**받는다:

> "현재 `{감지된 경로}`를 프로젝트 루트로 인식했습니다. 맞습니까?"

---

## Step 2 — 프로젝트 유형 감지 (단일/복수 애플리케이션)

`prompts/detection.md`의 [프로젝트 유형 감지] 섹션을 참조한다.

판정 후 사용자에게 결과를 보여주고 **반드시 확인**한다:

> ✋ **확인 게이트 (C-1)**
>
> 탐색 결과:
> - 프로젝트 유형: **단일 애플리케이션** / **복수 애플리케이션**
> - 프로젝트 루트: `{경로}`
> - (복수인 경우) 감지된 애플리케이션 폴더:
>   - `{앱1 폴더명}` — {근거: package.json / pom.xml / ...}
>   - `{앱2 폴더명}` — {근거}
>   - ...
>
> 맞습니까? **(승인 / 수정 / 취소)**

---

## Step 3 — 초기 세팅 / 갱신 판별

`prompts/detection.md`의 [세팅 모드 판별] 섹션을 참조한다.

| 조건 | 모드 | 다음 |
|------|------|------|
| `.claude/skills/` 또는 `.agents/skills/`에 스킬 파일 없음 | **초기 세팅** | Step 4 |
| `.claude/skills/` 또는 `.agents/skills/`에 스킬 파일 존재 | **갱신** | Step 5 |

판별 결과를 사용자에게 알린다:

> "기존 하네스가 **감지되지 않았습니다** / **감지되었습니다**. 초기 세팅 / 갱신을 진행합니다."

---

## Step 4 — 초기 세팅

Step 2 확인 결과에 따라 분기한다.

### Step 4-A — 단일 애플리케이션 세팅

`prompts/single-app-setup.md` 참조.

핵심 작업:
1. 애플리케이션 루트에 `.claude/skills/`, `.agents/skills/` 생성 (이미 있으면 무시)
2. 원본 하네스 레포의 `skills/` 전체를 위 두 경로에 복사
3. 멀티플랫폼(Claude Code, Codex 등) 고려 이유 안내

### Step 4-B — 복수 애플리케이션 세팅

`prompts/multi-app-setup.md` 참조.

핵심 작업:
1. 프로젝트 최상위 폴더에 구조 생성 (**이 폴더는 `git init` 하지 않는다**)
2. `.claude/skills/`, `.agents/skills/` 생성 + 스킬 복사
3. `.docs/` 디렉토리 생성 (별도 git 레포로 관리 예정)
4. 앱별 빈 컨텍스트 파일 생성: `.docs/{앱}-context.md`
5. 앱별 하위 구조 생성: `.docs/{앱}/instruction/`
6. `.docs/root-context/` 생성 (루트 컨텍스트 파일 복사본 보관용)
7. 루트 `CLAUDE.md`, `AGENTS.md` 생성 (git 미관리, 이 스킬이 단독 관리)
8. `.docs/root-context/CLAUDE.md`, `.docs/root-context/AGENTS.md` 에 동일 복사본 생성

루트 `CLAUDE.md`/`AGENTS.md` 작성 시 `templates/root-context.template` 참조.

### Step 4 완료 보고

생성된 구조를 트리 형태로 사용자에게 보여준다.

> **세팅 완료!**
>
> 생성된 구조:
> ```
> {프로젝트 루트}/
> ├── .claude/skills/...
> ├── .agents/skills/...
> ├── .docs/...
> ├── CLAUDE.md
> └── AGENTS.md
> ```
>
> 📌 멀티플랫폼 안내:
> - `.claude/skills/` → Claude Code 전용 경로
> - `.agents/skills/` → Codex 등 다른 AI 에이전트 플랫폼 경로
> - 두 경로에 동일한 스킬을 배치하여 어떤 플랫폼에서든 동일한 하네스를 사용할 수 있습니다.

→ Step 6으로 이동.

---

## Step 5 — 갱신 모드

`prompts/update-mode.md` 참조.

핵심 작업:
1. 원본 하네스 레포의 `skills/` 현재 버전과 프로젝트에 배포된 스킬을 비교
2. 변경된 스킬만 갱신 (추가/수정/삭제)
3. 복수앱인 경우 추가로:
   - `.docs/root-context/CLAUDE.md`, `.docs/root-context/AGENTS.md` 갱신
   - 루트 `CLAUDE.md`, `AGENTS.md` 를 `.docs/root-context/` 기준으로 갱신
4. 갱신 전 사용자 확인

> ✋ **확인 게이트**
>
> 갱신 대상:
> - 스킬: {추가 N개 / 수정 N개 / 삭제 N개 / 변경 없음}
> - (복수앱) 루트 컨텍스트: {갱신 필요 / 변경 없음}
>
> 진행하시겠습니까? **(승인 / 취소)**

→ Step 6으로 이동.

---

## Step 6 — 최종 결과 보고

세팅 또는 갱신 결과를 요약하여 대화창에 출력한다.
별도 `.md` 파일을 생성하지 않는다.

보고 항목:
1. 프로젝트 유형 (단일/복수)
2. 프로젝트 루트 경로
3. 생성·갱신된 파일 목록
4. (복수앱) 감지된 애플리케이션 폴더 목록
5. 다음 단계 안내

> **다음 단계:**
> - 설계 시작: `/design-doc`
> - 기존 코드 분석: `/harness-bootstrap`
> - 컨텍스트 문서 생성: `/context-doc`
> - 스킬 최신화 재실행: `/harness-setup`
