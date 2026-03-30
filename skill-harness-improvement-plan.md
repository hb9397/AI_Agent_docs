# 스킬 하네스 개선 방안 — 실행 가이드

> 스킬 관리 레포지토리에서 직접 실행 가능한 작업 단위로 정리.
> 각 항목은 **문제 → 원인 → 정확한 파일/위치 → 수행할 작업** 순서로 기술.
> 우선순위: 🔴 즉시 / 🟠 권장 / 🟡 개선

---

## 목차

- [전체 파이프라인 공통 문제](#0-전체-파이프라인-공통-문제)
- [design-doc](#1-design-doc)
- [context-doc](#2-context-doc)
- [impl-doc](#3-impl-doc)
- [create-prototype](#4-create-prototype)
- [commit](#5-commit)
- [pre-commit](#6-pre-commit)
- [code-comment](#7-code-comment)
- [multi-review](#8-multi-review)
- [doc-audit / agent-sync](#9-doc-audit--agent-sync)
- [frontend-design](#10-frontend-design)
- [skill-designer (기준 스킬)](#11-skill-designer-기준-스킬)

---

## 0. 전체 파이프라인 공통 문제

### 🔴 P0-1. description undertrigger — 6개 스킬

**문제**: `design-doc`, `context-doc`, `impl-doc`, `multi-review`, `commit`, `pre-commit`의 description이
트리거 상황 없이 기능 요약만 있다. Agent가 언제 이 스킬을 써야 하는지 판단하지 못해 undertrigger 발생.

**원인**: `design-principles.md`의 description 작성 기준 — "트리거 키워드 3개 이상, When+What 모두 포함"
— 을 따르지 않았다.

**수행할 작업**: 아래 6개 스킬의 `SKILL.md` frontmatter description 필드를 교체한다.

```yaml
# design-doc/SKILL.md
description: >
  새 기능·화면·프로젝트를 설계할 때 반드시 이 스킬을 사용한다.
  '설계해줘', '어떻게 만들지 정리해줘', '기획 문서 작성', '요구사항 정리',
  '스펙 작성', 'PRD 만들어줘' 요청이 오면 이 스킬로 처리한다.
  인터뷰 기반으로 구조화된 설계 문서를 자동 도출한다.

# context-doc/SKILL.md
description: >
  설계 문서나 PRD가 완성된 후 AI Agent용 컨텍스트 파일을 만들 때 사용한다.
  'CLAUDE.md 만들어줘', '컨텍스트 문서 생성', 'basic-instruction 작성',
  '에이전트 가이드 만들어줘' 요청이 오면 반드시 이 스킬을 쓴다.
  설계 문서 → CLAUDE.md + basic-instruction.md 2종 자동 생성.

# impl-doc/SKILL.md
description: >
  설계가 끝난 뒤 구현 순서와 작업 단위를 정리할 때 사용한다.
  '작업지침서 만들어줘', '구현 계획 세워줘', 'Phase 나눠줘',
  '태스크 쪼개줘', '어떤 순서로 개발하면 돼?' 요청이 오면 이 스킬을 쓴다.
  설계 문서 → FE/BE 페어 Phase별 작업지침서 자동 생성.

# multi-review/SKILL.md
description: >
  코드 리뷰가 필요할 때 반드시 이 스킬을 사용한다.
  '코드 리뷰해줘', '리뷰', '코드 점검', '보안 체크', '성능 확인',
  '이 코드 괜찮아?', 'PR 리뷰' 요청이 오면 이 스킬로 처리한다.
  보안·성능·유지보수성·테스트 4개 관점을 병렬 실행하는 멀티 페르소나 리뷰.

# commit/SKILL.md
description: >
  커밋할 때 반드시 이 스킬을 사용한다.
  '커밋해줘', '커밋 메시지 만들어줘', 'commit', '변경 내용 저장',
  '스테이지 올라간 것 커밋' 요청이 오면 이 스킬로 처리한다.
  변경 내용 분석 후 Conventional Commits 규칙의 커밋 메시지를 생성하고 실행.

# pre-commit/SKILL.md
description: >
  커밋 전 코드 검사가 필요할 때 이 스킬을 사용한다.
  '커밋 전 검사', '규칙 위반 확인', '코드 점검', 'pre-commit',
  '올려도 되는지 확인해줘' 요청이 오면 이 스킬로 처리한다.
  변경 파일 대상으로 에러 처리·민감 정보·TODO 형식 등 규칙 위반을 자동 검사.
```

---

### 🔴 P0-2. CRLF 줄바꿈 오염 — 2개 스킬

**문제**: `doc-audit/`, `agent-sync/` 디렉토리의 `.md` 파일들이 CRLF(`\r\n`)로 저장되어 있다.
bash 스크립트에서 이 파일들을 읽을 때 줄 끝 `\r`이 변수에 포함되어 grep/비교 오류 발생 가능.

**수행할 작업**:
```bash
# 레포지토리 루트에서 실행
find skills/user/doc-audit skills/user/agent-sync -name "*.md" \
  | xargs sed -i 's/\r//' 2>/dev/null

# .gitattributes에 추가하여 재발 방지
echo "skills/user/**/*.md text eol=lf" >> .gitattributes
```

---

### 🟠 P0-3. 결과 파일이 스킬 디렉토리 안에 있음

**문제**: `doc-audit/audit-report.md`, `agent-sync/doc-sync-result.md`는 파일명이
실행 결과물처럼 보이지만 실제로는 출력 형식 지침 파일이다.
위치가 루트에 있어 `templates/`나 `prompts/`와 역할이 구분되지 않는다.

**수행할 작업**:
```bash
# doc-audit
mv skills/user/doc-audit/audit-report.md \
   skills/user/doc-audit/templates/audit-report.md

# agent-sync
mv skills/user/agent-sync/doc-sync-result.md \
   skills/user/agent-sync/templates/sync-result.md
```

그리고 각 SKILL.md에서 이 파일을 참조하는 위치 업데이트:
- `doc-audit/SKILL.md` → `templates/audit-report.md` 참조로 변경
- `agent-sync/SKILL.md` → `templates/sync-result.md` 참조로 변경

---

### 🟠 P0-4. 스킬 간 언어 불일치

**문제**: `frontend-design`만 영어, 나머지 11개 스킬은 한글.
스킬 관리 레포지토리에서 일관된 유지보수가 어렵다.

**수행할 작업**: `frontend-design/SKILL.md`를 한글로 재작성하거나,
레포지토리 `README.md`에 "frontend-design은 공개 스킬 원본을 유지" 정책을 명시한다.
(재작성을 선택하면 [10. frontend-design] 섹션 참조)

---

## 1. design-doc

### 🔴 D-1. V1/V2 OUTPUT 이중화 → 다운스트림 파이프라인 붕괴

**문제**: `OUTPUT_V1.md`는 섹션 `01~09`, `OUTPUT_V2.md`는 `01~12`로 번호 체계가 다르다.
`context-doc`과 `impl-doc`의 섹션 매핑 표는 V2 번호(`01,02,03,04,05,06,07,10,12`)를 참조하는데
`scale-routing.md`에 "V1 / V2 중 하나를 선택"이라고만 쓰여있어 어느 버전 OUTPUT인지 보장이 없다.

**수행할 작업**:

1. `OUTPUT_V1.md`를 `templates/OUTPUT_V1_deprecated.md`로 이름 변경 후 상단에 주석 추가:
   ```markdown
   <!-- DEPRECATED: OUTPUT_V2.md 사용 권장. 이 파일은 레거시 참조용으로만 유지. -->
   ```

2. `scale-routing.md`의 양식 매핑 표를 수정:
   ```markdown
   # 변경 전
   | 프로젝트 전체 | INPUT_V1 | OUTPUT_V1 | ... |
   | 화면 단위     | INPUT_V2 | OUTPUT_V2 | ... |

   # 변경 후
   | 프로젝트 전체 | INPUT_V2 | OUTPUT_V2 | 권장 |
   | 화면 단위     | INPUT_V2 | OUTPUT_V2 | 권장 |
   | 프로젝트 전체 | INPUT_V1 | OUTPUT_V1 | ⚠️ deprecated — 레거시 호환 시에만 |
   ```

3. `SKILL.md` Step 3에 버전 명시 추가:
   ```markdown
   ### Step 3 — OUTPUT 문서 작성
   `templates/OUTPUT_V2.md` 양식을 사용한다. (V1은 deprecated)
   스케일별 섹션 포함 규칙은 `prompts/scale-routing.md` 참조.
   ```

---

### 🔴 D-2. INPUT 파일이 워크플로우에서 참조되지 않음

**문제**: `templates/INPUT_V1.md`, `INPUT_V2.md`가 있는데 SKILL.md에 이 파일을 읽는 Step이 없다.
`scale-routing.md`에 "INPUT_V1/V2 양식 사용"이라고 적혀있으나 어느 Step에서 읽는지 명시 없음.

**수행할 작업**: `SKILL.md` Step 1 끝에 한 줄 추가:
```markdown
### Step 1 — 스케일 확인 및 기존 설계 문서 수집

...기존 내용 유지...

인터뷰 진행 시 입력 양식이 필요하면 `templates/INPUT_V2.md`를 사용자에게 제공한다.
(사용자가 직접 채워서 제출하는 경우에만 — 일반적으로는 Step 2 인터뷰로 대체)
```

---

### 🟠 D-3. H섹션 (뒤집기 확인) 타이밍 문제

**문제**: 뒤집기 확인이 인터뷰 맨 마지막(I 직전)에 배치되어 있다.
모든 설계 답변이 나온 뒤 뒤집으려면 사용자 부담이 크다. D(범위) 직후에 해야 실효성이 있다.

**수행할 작업**: `prompts/interview.md`에서 H섹션 위치를 D섹션 바로 뒤로 이동:
```markdown
# 변경 전 순서: A → B → C → D → E → F → G → H → I
# 변경 후 순서: A → B → C → D → H(뒤집기) → E → F → G → I
```

`SKILL.md` Step 2 설명에도 반영:
```markdown
- H섹션(뒤집기 확인)은 D섹션 직후에 진행한다. 범위가 확정되기 전에 뒤집는 것이 실효성 있다.
```

---

### 🟡 D-4. INPUT_V1 CRLF

**문제**: `INPUT_V2.md`가 CRLF로 저장되어 있다.
```bash
file templates/INPUT_V2.md  # CRLF 확인
sed -i 's/\r//' templates/INPUT_V2.md
```

---

## 2. context-doc

### 🔴 C-1. 연속 질문 누적 3개 초과 가능성

**문제**: `analysis-claude.md`에서 "최대 2개", `analysis-instruction.md`에서 "최대 1개" 질문 가능.
Step 2-A와 Step 2-B가 순차 실행되면 사용자가 최대 3개 질문을 연속으로 받는다.
`design-principles.md`의 "한 번에 최대 3개 초과 금지"를 실질적으로 위반할 수 있다.

**수행할 작업**: `SKILL.md` Step 2-A/2-B 사이에 합산 제약 명시:

```markdown
### Step 2-A — CLAUDE.md 분석
`prompts/analysis-claude.md` 기준으로 분석한다.
**질문은 최대 1개만** — Step 2-B에서도 질문할 수 있으므로, 전체 합산 2개 이하 유지.

### Step 2-B — basic-instruction.md 분석
`prompts/analysis-instruction.md` 기준으로 분석한다.
**질문은 최대 1개만** — 2-A에서 질문했으면 이 단계에서는 질문 금지.
```

`analysis-claude.md`도 수정:
```markdown
# 변경 전
🔴 필수: 기술 스택 버전 / 환경변수 분리 여부

# 변경 후
🔴 최대 1개만 확인 (Step 2-B에서도 질문 가능하므로 합산 2개 이내로 제한):
기술 스택 버전 / 환경변수 분리 여부 중 더 불명확한 것 하나만
```

---

### 🔴 C-2. bash 코드가 SKILL.md 본문에 직접 서술

**문제**: `SKILL.md` Step 5에 `mkdir -p .instruction` bash 예시가 본문에 직접 있다.
`design-principles.md` — "SKILL.md는 흐름만 담고, 규칙은 prompts에" — 위반.

**수행할 작업**: `SKILL.md` Step 5를 다음으로 교체:
```markdown
### Step 5 — 파일 저장

승인 시 `.instruction/` 디렉토리가 없으면 먼저 생성한 후 두 파일을 저장한다.
저장 완료 후 `CLAUDE.md` 내 `@.instruction/basic-instruction.md` 참조 경로가
실제 파일 위치와 일치하는지 확인한다.
```

bash 예시는 SKILL.md에서 제거 (Agent가 스스로 실행할 수 있는 내용이므로 예시 불필요).

---

### 🟠 C-3. 섹션 매핑 표가 어느 OUTPUT 버전 기준인지 불명확

**문제**: `SKILL.md`의 섹션 매핑 표가 `01, 02, 03, 04, 05, 06, 07, 10, 12` 번호를 쓰는데,
이것이 V2 기준임을 명시하지 않았다. design-doc에서 V1을 썼다면 섹션 번호가 달라 매핑이 깨진다.

**수행할 작업**: 매핑 표 위에 한 줄 추가:
```markdown
> 아래 섹션 번호는 `design-doc`의 **OUTPUT_V2 기준**이다. V1 OUTPUT은 번호 체계가 다르므로 비권장.

| design-doc OUTPUT 섹션 | 생성 대상 |
```

---

## 3. impl-doc

### 🔴 I-1. pitfall-checklist가 특정 프로젝트 기술 스택에 종속

**문제**: `prompts/pitfall-checklist.md`의 "기술적 함정" 항목들이
Playwright / CDP / LLM / noVNC / WebSocket 등 특정 자동화 봇 프로젝트 전용이다.
범용 설계 도구에 이 체크리스트가 내장되면, 관련 없는 프로젝트에서도 이 항목들로 검사하여
혼란을 준다.

**수행할 작업**: `pitfall-checklist.md`의 "기술적 함정" 섹션을 범용 항목으로 교체:

```markdown
## 기술적 함정 (범용)

[ ] 외부 API 호출에 타임아웃·재시도 전략이 명시되어 있는가?
[ ] 비동기 처리(async/await, 큐)가 필요한 곳에 동기 처리가 가정되어 있지 않은가?
[ ] 환경별 설정값(개발/배포)이 하드코딩 없이 환경변수로 분리되는가?
[ ] 인증/인가가 필요한 엔드포인트에 누락이 없는가?
[ ] 대용량 데이터 처리 시 페이징/스트리밍 전략이 있는가?

## 기술적 함정 (프로젝트 커스텀)
<!-- 프로젝트별 특수 기술 스택 체크리스트를 여기에 추가한다 -->
<!-- 예시: Playwright, LangGraph, WebSocket 등 프로젝트 고유 기술은 이 섹션에만 -->
```

"기술적 함정 (프로젝트 커스텀)" 섹션 추가 후, 기존 Playwright/LLM 관련 항목들을
그 섹션 아래 주석(`<!-- -->`) 안에 예시로 보존하여 필요 시 활성화할 수 있게 한다.

---

### 🔴 I-2. Phase 분할 패턴이 풀스택(FE+BE)만 상정

**문제**: `prompts/phase-design.md`의 모든 Phase 예시가 BE+FE 쌍으로만 구성되어 있다.
"BE만 또는 FE만 완성되는 Phase는 금지" 규칙이 BE-only API 서버, FE-only 정적 사이트 등에서는
부적절한 제약이 된다.

**수행할 작업**: `phase-design.md` 상단에 라우팅 표 추가 후, 단일-레이어 패턴 섹션을 추가:

```markdown
## 라우팅 표

| 프로젝트 유형 | 읽을 섹션 |
|-------------|----------|
| FE + BE 풀스택 | [풀스택 Phase 패턴] (기존 내용) |
| BE 전용 (API 서버, 배치 등) | [BE 전용 Phase 패턴] |
| FE 전용 (정적 사이트, UI 라이브러리) | [FE 전용 Phase 패턴] |

---

## [BE 전용 Phase 패턴]

BE 전용 프로젝트에서는 FE 페어 요구를 적용하지 않는다.
Phase 종료 조건: API를 curl 또는 테스트 코드로 직접 검증 가능한 상태.

Phase 1: 가장 단순한 엔드포인트 1개 + DB 연결 검증
Phase N: 핵심 비즈니스 로직 API 구현
마지막: 배포 환경 세팅 (있는 경우)

## [FE 전용 Phase 패턴]

FE 전용 프로젝트에서는 BE 페어 요구를 적용하지 않는다.
Phase 종료 조건: 브라우저에서 화면이 정상 렌더링되는 상태.

Phase 1: 기본 레이아웃 + 라우터 설정
Phase N: 핵심 화면 컴포넌트 구현
마지막: 빌드 및 배포 설정 (있는 경우)
```

---

### 🟠 I-3. 분석 prompts와 SKILL.md 간 Step 매핑 불명확

**문제**: SKILL.md에 5개 prompts 파일(`analysis`, `phase-design`, `pitfall-checklist`, `task-rules`, `verification`)이 있는데,
어느 Step에서 어느 파일을 읽는지 1:1 매핑이 SKILL.md에 명시되어 있지 않다.
`phase-design.md`와 `task-rules.md`를 Step 2에서 같이 읽는 건지 Step 3에서 읽는 건지 불명확.

**수행할 작업**: SKILL.md 각 Step에 참조 파일을 명시:

```markdown
### Step 1 — 입력 문서 수집 및 사전 질문
→ `prompts/analysis.md` 기준으로 분석

### Step 2 — Phase 분할
→ `prompts/phase-design.md`의 분할 기준 참조

### Step 3 — 태스크 작성
→ `prompts/task-rules.md`의 태스크 작성 규칙 참조

### Step 4 — 검증 시나리오 작성
→ `prompts/verification.md` 형식 참조

### Step 5 — 함정 체크
→ `prompts/pitfall-checklist.md` 참조
```

(현재도 이와 유사하게 되어있으나, "참조" 표기가 일부 Step에서 생략되어 있다. 모든 Step에 명시적 참조 추가.)

---

## 4. create-prototype

### 🔴 CP-1. `allowed-tools: Agent` — 유효하지 않은 도구명

**문제**: SKILL.md frontmatter에 `allowed-tools: Read, Write, Glob, Agent`라고 선언되어 있다.
Claude Code에서 sub-agent를 실행하는 실제 도구명은 `Task`이다.
`multi-review`, `doc-audit`, `agent-sync`는 모두 `Task`라고 선언했다. 불일치.

**수행할 작업**: `SKILL.md` frontmatter 수정:
```yaml
# 변경 전
allowed-tools: Read, Write, Glob, Agent

# 변경 후
allowed-tools: Read, Write, Glob, Task
```

SKILL.md 본문에서 "subagent", "Agent 툴"이라고 쓰인 부분은 "Task"로 통일:
```markdown
# 변경 전
Agent 툴이 사용 가능한 환경이면 병렬 subagent로 생성한다.

# 변경 후
Task 툴이 사용 가능한 환경이면 병렬 subagent로 생성한다.
```

---

### 🔴 CP-2. STEP 1~3이 이미 제공된 정보를 무시하고 무조건 질문

**문제**: "이미 제공된 정보는 건너뛰되"라고 SKILL.md에 적혀있지만,
각 STEP의 구현이 무조건 질문하는 형태다. 사용자가 첫 메시지에서 번호, 기능, 색상을 모두 말해줬어도
3번 질문을 받는다.

**수행할 작업**: SKILL.md 워크플로우 앞에 "사전 추출" 단계 추가:

```markdown
## 워크플로우

`/create-prototype` 명령이 들어오면 **먼저 사용자 메시지에서 아래 3가지를 추출**한다:

| 항목 | 추출 기준 |
|------|----------|
| SFR 번호 | `SFR-NNN` 패턴 포함 여부 |
| 기능 설명 | 메시지에 화면 기능 설명이 있는가 |
| 메인 색상 | HEX 코드 또는 색상명 포함 여부 |

추출된 항목은 해당 STEP을 건너뛴다.
모두 추출되면 STEP 4로 바로 진입한다.

### STEP 1 — 성능요구사항 번호 수집
(미제공 시에만 질문)
...
```

---

### 🟠 CP-3. `examples/SFR-018.html` 전체를 매번 읽음 — 토큰 낭비

**문제**: STEP 4에서 "examples/SFR-018.html (1700줄) 코드 스타일 참고"로 읽으라고 한다.
매 실행마다 1700줄 파일 전체를 context에 올리는 것은 토큰 낭비다.

**수행할 작업**: STEP 4 지침에서 범위 제한 추가:

```markdown
3. `examples/SFR-018.html` — 코드 스타일 참고
   **전체 읽기 금지.** 아래 부분만 읽는다:
   - 파일 상단 `<style>` 블록 (CSS 변수 + 컴포넌트 클래스 정의): `head -120`
   - 탭 전환 JS 함수: `grep -n "showScreen\|loadScreen" -A 10`
   - 필요한 컴포넌트 패턴이 있으면 해당 섹션만 grep으로 추출
```

---

### 🟠 CP-4. sub-agent fallback 명시가 SKILL.md 중간에 분산

**문제**: "환경별 fallback" 표가 STEP 4 중반부에 있어서 찾기 어렵다.
`multi-review`, `code-comment`처럼 SKILL.md 상단 진입 분기표에 위치해야 한다.

**수행할 작업**: SKILL.md 상단(워크플로우 앞)에 진입 분기표 추가:

```markdown
## 환경별 처리 방식

| 환경 | Task 툴 | 분리 구조 처리 |
|------|---------|--------------|
| Claude Code / Codex | 가능 | 병렬 subagent |
| Claude.ai | 불가 | 메인 파일 → 조각 파일 순차 생성 |

Task 툴 호출 실패 시 자동으로 순차 생성으로 전환한다.
```

---

## 5. commit

### 🔴 CM-1. 특정 프로젝트 scope 하드코딩 — 범용 스킬 오염

**문제**: `SKILL.md` 본문과 `examples/commit-messages.md`에
`api`, `domain`, `infra`, `member`, `auth`, `order`, `payment`라는 scope 목록이 하드코딩되어 있다.
이것은 Java Spring 기반 특정 프로젝트의 도메인 구조다.
다른 프로젝트에서 이 스킬을 쓰면 엉뚱한 scope가 자동 선택된다.

**수행할 작업**:

1. `SKILL.md` scope 규칙을 범용화:
```markdown
# 변경 전
- scope는 모듈명 또는 도메인명 사용 (`api`, `domain`, `infra`, `member`, `auth` 등)

# 변경 후
- scope는 변경된 파일의 모듈·디렉토리명 기반으로 git diff에서 추론한다
- 프로젝트에 CLAUDE.md가 있으면 해당 파일의 아키텍처 섹션에서 모듈명을 참조한다
- scope 추론이 불명확하면 사용자에게 확인한다
```

2. `examples/commit-messages.md`의 "scope 예시" 표를 프로젝트 종속 값에서 범용 패턴으로 교체:
```markdown
## scope 결정 방법

git diff에서 변경된 파일 경로의 최상위 디렉토리 또는 핵심 모듈명을 사용한다.

| 변경 파일 경로 예시 | 적절한 scope |
|-------------------|-------------|
| src/auth/login.ts | auth |
| components/Button.jsx | ui |
| api/users/route.ts | api |
| scripts/deploy.sh | ci |
| package.json, requirements.txt | deps |
| README.md, docs/ | docs |

프로젝트 고유 scope (예: 도메인명)는 CLAUDE.md에서 확인한다.
```

---

### 🟠 CM-2. `disable-model-invocation: true` 선언 이유 불명확

**문제**: `commit` 스킬에 `disable-model-invocation: true`가 선언되어 있다.
이 옵션은 재귀 호출 방지 목적인데, commit 스킬이 왜 재귀 호출 위험이 있는지 불명확하다.
`agent: fork`도 선언되어 있지 않다. 이 옵션이 실제로 필요한지 검토 필요.

**수행할 작업**:
- `commit` 스킬이 다른 스킬을 호출하거나, 모델이 스스로를 재호출할 경로가 없다면 제거:
  ```yaml
  # disable-model-invocation: true  ← 제거 (재귀 경로 없음)
  ```
- 만약 "commit 실행 중 추가 AI 판단 없이 규칙 기계적 적용"이 의도라면,
  `SKILL.md` 상단에 의도를 명시:
  ```markdown
  > 이 스킬은 AI 판단을 최소화하고 규칙을 기계적으로 적용한다.
  > 커밋 메시지 생성은 `git diff` 결과와 아래 규칙만으로 결정한다.
  ```

---

## 6. pre-commit

### 🔴 PC-1. `scan.sh`에서 변경 없을 때 전체 스캔 — 금지된 패턴

**문제**: `scripts/scan.sh`에서 git 변경 파일이 없으면
`echo "(변경 파일 없음 — 전체 스캔)"` 출력 후 프로젝트 전체를 grep한다.
`design-principles.md`는 명시적으로 "변경 없으면 즉시 종료"를 요구한다.
대형 프로젝트에서 이 스킬을 실행하면 수천 개 파일을 불필요하게 스캔한다.

**수행할 작업**: `scripts/scan.sh` 수정:
```bash
# 변경 전 (문제 있는 코드)
if [ -z "$CHANGED" ]; then
  echo "(변경 파일 없음 — 전체 스캔)"
else
  echo "$CHANGED" | sort -u
fi

# 변경 후 (수정된 코드)
if [ -z "$CHANGED" ]; then
  echo "변경된 파일이 없습니다. 검사를 종료합니다."
  exit 0
fi
echo "$CHANGED" | sort -u
```

---

### 🔴 PC-2. `--include=*.java` glob 패턴 — 따옴표 누락

**문제**: `scan.sh`에서 `CODE` 변수가 다음과 같이 정의되어 있다:
```bash
CODE="--include=*.java --include=*.kt ..."
```
쉘이 먼저 `*.java`를 현재 디렉토리의 파일 목록으로 확장하려 시도한다.
파일이 없으면 리터럴로 처리되지만, 있으면 의도치 않은 파일명으로 확장된다.

**수행할 작업**: `scan.sh`의 CODE 변수 정의를 수정:
```bash
# 변경 전
CODE="--include=*.java --include=*.kt --include=*.ts ..."

# 변경 후
# 각 --include 값에 따옴표를 직접 포함하거나, grep 호출 시 배열로 처리
scan_code() {
  grep -rn \
    --include="*.java" --include="*.kt" \
    --include="*.ts" --include="*.tsx" \
    --include="*.js" --include="*.jsx" \
    --include="*.py" --include="*.go" --include="*.rs" \
    "$@"
}
```

그리고 `scan.sh` 전체에서 `grep -rn $CODE ...`를 `scan_code ...`로 교체.

---

### 🟠 PC-3. 검사 항목이 SKILL.md와 scan.sh에 이중 명세

**문제**: 5개 검사 항목(`에러 처리`, `타임아웃`, `민감 정보`, `TODO`, `테스트`)이
SKILL.md 본문과 `scan.sh` 주석 양쪽에 서술되어 있다.
규칙이 바뀌면 두 파일을 동시에 수정해야 한다.

**수행할 작업**: SKILL.md에서 검사 항목 상세 내용 제거, `prompts/` 파일로 분리:

```bash
# 신규 파일 생성
touch skills/user/pre-commit/prompts/check-rules.md
```

`prompts/check-rules.md` 내용:
```markdown
# 검사 항목 정의 (check-rules)

## 1. 에러 처리
- 빈 catch 블록 금지 (에러를 잡고 아무것도 안 하는 경우)
- 에러 무시 패턴 금지 (`// ignore`, 빈 catch)
- catch에서 에러 무시하고 null/undefined 반환 금지

## 2. 외부 호출 타임아웃
...이하 기존 내용 이동
```

`SKILL.md`의 "## 검사 항목" 섹션을 다음으로 교체:
```markdown
## 검사 항목

검사 항목 상세 정의는 `prompts/check-rules.md` 참조.
`scan.sh`은 이 규칙의 자동 탐지 구현이다.
```

---

### 🟠 PC-4. `disable-model-invocation: true`와 `agent: fork` 동시 선언

**문제**: `pre-commit/SKILL.md` frontmatter에 두 옵션이 함께 선언되어 있다.
`disable-model-invocation: true`는 이 스킬이 다른 모델 호출을 막는다는 의미인데,
`agent: fork`와 함께 쓰이면 sub-agent 생성도 막히는지 동작이 불명확하다.

**수행할 작업**: `pre-commit`은 단순 스캔 스킬이므로 sub-agent가 필요없다.
```yaml
# 변경 전
allowed-tools: Read, Glob, Grep, Bash
disable-model-invocation: true
agent: fork

# 변경 후
allowed-tools: Read, Glob, Grep, Bash
disable-model-invocation: true
# agent: fork 제거 (병렬 처리 불필요)
```

---

## 7. code-comment

### 🔴 CC-1. 진입 분기표와 실제 Step 번호 체계 불일치

**문제**: 진입 분기표에 "Step 2A, 2B, 2C, 2D"가 있는데,
실제 워크플로우는 "Step 1, 2, 3, 4, 5, 6" 단층 구조다.
Step 2 본문에서 "진입 분기표에 따라 해당하는 경로를 실행한다"고 쓰여있으나,
2A~2D의 상세 규칙이 `change-detection.md`에 있고 Step 2에서 이 파일로의 참조가 충분하지 않다.

**수행할 작업**: SKILL.md Step 2를 다음과 같이 재작성:

```markdown
## Step 2 — 대상 파일 결정

진입 분기표에 따라 `prompts/change-detection.md`의 해당 섹션을 참조한다:

| 상황 | change-detection.md 참조 섹션 |
|------|------------------------------|
| 특정 파일 지정 + git 있음 | [Git Diff — 특정 파일] |
| 특정 파일 지정 + git 없음 | [Mtime — 특정 파일] |
| 파일 미지정 + git 있음 | [Git Diff — 전체 변경 파일] |
| 파일 미지정 + git 없음 | [사용자 질문] |

> ✋ **확인 게이트** (파일 미지정 + git 미적용인 경우만)
```

Step 1의 "세부 규칙은 `prompts/change-detection.md`의 [Git 감지] 섹션을 참조한다"는 유지.

---

### 🟠 CC-2. 변경 이력 작성 규칙이 SKILL.md와 comment-rules.md에 분산

**문제**: "절대 AI 이름을 임의로 넣지 않는다" 규칙이 `SKILL.md` Step 5와
`prompts/comment-rules.md` Section 5 두 곳에 거의 동일하게 서술되어 있다.

**수행할 작업**: `SKILL.md` Step 5에서 규칙 내용 제거, 참조만 남김:

```markdown
### Step 5 — 결과 미리보기 및 사용자 확인

주석이 추가된 전체 파일 내용을 대화창에 출력하고 승인을 요청한다.
파일 최하단 변경 이력 처리 규칙은 `prompts/comment-rules.md`의 Section 5 참조.

> ✋ **확인 게이트**
> "위 내용으로 파일을 덮어쓸까요? (승인 / 수정 요청 / 취소)"
```

`comment-rules.md`의 Section 5에 규칙이 이미 완전히 서술되어 있으므로 SKILL.md에서 중복 제거.

---

## 8. multi-review

### 🔴 MR-1. 심각도 체계가 prompts 파일마다 달라 통합 리포트 불일치

**문제**:
- `security.md`: 🔴 Critical / 🟠 Major / 🟡 Minor (3단계)
- `performance.md`: 🔴 Critical / 🟠 Major / 🟡 Minor (3단계)
- `maintainability.md`: 🔴 Critical / 🟠 Major / 🟡 Minor (3단계)
- `testing.md`: 🔴 Critical / 🟠 Major / 🟡 Minor (3단계)
- `template.md`: 🔴 Critical / 🟠 Major / 🟡 Minor / 💡 Suggestion (4단계)

4개 sub-agent가 3단계로 결과를 반환하는데 template은 4단계를 표시한다.
Testing 결과의 "테스트 보강 제안"은 Critical/Major/Minor 중 어디에도 맞지 않아
💡 Suggestion이 필요한데 prompts에는 이 단계가 없다.

**수행할 작업**: 4개 prompts 파일의 심각도 기준에 💡 Suggestion 추가:

```markdown
# security.md, performance.md, maintainability.md, testing.md 각각에 추가

## 심각도 판단 기준

- 🔴 Critical: [기존 내용 유지]
- 🟠 Major: [기존 내용 유지]
- 🟡 Minor: [기존 내용 유지]
- 💡 Suggestion: 필수 수정은 아니나 개선하면 코드 품질에 도움이 되는 것
  (리팩토링 아이디어, 테스트 보강, 네이밍 개선 등)
```

---

### 🟠 MR-2. description undertrigger (P0-1에서 처리)

P0-1에서 이미 수행. 추가 작업 없음.

---

## 9. doc-audit / agent-sync

### 🔴 DA-1. CRLF 오염 (P0-2에서 처리)

P0-2에서 이미 수행. 추가 작업 없음.

---

### 🔴 DA-2. 출력 템플릿 파일 위치 오류 (P0-3에서 처리)

P0-3에서 이미 수행. 추가 작업 없음.
파일 이동 후 각 SKILL.md의 참조 경로도 업데이트해야 함:

```markdown
# doc-audit/SKILL.md 최종 처리 섹션
결과 출력 형식은 `templates/audit-report.md` 참조.

# agent-sync/SKILL.md Step 4
결과 출력 형식은 `templates/sync-result.md` 참조.
```

---

### 🟠 DA-3. agent-sync의 Task 참조 불명확

**문제**: `agent-sync/SKILL.md`의 Step 3에서 "Task A / Task B를 병렬 실행"한다고 하는데,
`prompts/docs-sync.md`와 `prompts/skills-sync.md`가 각각 "Task A" / "Task B"에 대응한다는
매핑이 SKILL.md에 명시되어 있지 않다.

**수행할 작업**: Step 3 병렬 구조 표기를 `design-principles.md`의 병렬 처리 표기법 형식으로 통일:

```markdown
### Step 3 — 동기화 실행

sub-agent 지원 환경이면 Task A · B를 병렬 실행한다.
미지원 환경이면 순차로 직접 수행한다.

├── Task A: 문서 동기화 → `prompts/docs-sync.md` 참조
└── Task B: Skills 동기화 → `prompts/skills-sync.md` 참조
```

---

## 10. frontend-design

### 🔴 FD-1. 존재하지 않는 `LICENSE.txt` 참조

**문제**: `SKILL.md` frontmatter에 `license: Complete terms in LICENSE.txt`가 있는데
해당 디렉토리에 `LICENSE.txt` 파일이 없다. Dead reference.

**수행할 작업**:
```yaml
# 변경 전
license: Complete terms in LICENSE.txt

# 변경 후
# license 줄 제거 (파일 없음)
```

---

### 🔴 FD-2. 한글 스킬 하네스에 영어 스킬 단독 존재

**문제**: 12개 스킬 중 이것만 영어. 동일 하네스에서 유지보수 일관성 저하.
이 스킬은 공개 `frontend-design` 스킬과 거의 동일한 내용이며 사용자 버전만의 차별화 포인트가 없다.

**수행할 작업** (두 가지 중 선택):

**옵션 A — 한글 재작성 (권장)**:
공개 스킬의 핵심 원칙은 유지하되, 이 하네스에서 강제할 규칙 추가:
```markdown
---
name: frontend-design
description: >
  프론트엔드 UI를 구현할 때 이 스킬을 사용한다.
  '화면 만들어줘', '컴포넌트 구현', 'UI 개발', '웹 페이지 작성',
  '디자인해줘' 요청이 오면 반드시 이 스킬로 처리한다.
  개성 있고 완성도 높은 프론트엔드 코드를 생성하며, 일반적인 AI 클리셰 디자인을 피한다.
allowed-tools: Read, Write, Glob
---

# 프론트엔드 디자인 (frontend-design)

## 설계 사고

코딩 전에 아래를 먼저 결정한다:
- **목적**: 이 인터페이스가 해결하는 문제, 사용자는 누구인가
- **톤**: 명확한 한 가지 방향 선택 — 극단적 미니멀 / 맥시멀리즘 / 레트로 / 유기적 / 산업적 등
- **제약**: 프레임워크, 성능, 접근성 요구사항
- **차별화**: 이 디자인에서 한 가지 기억에 남을 것은 무엇인가

**원칙**: 방향을 정하고 그것을 끝까지 밀어붙인다. 대담한 맥시멀리즘과 정제된 미니멀리즘 모두 훌륭하다. 중요한 것은 의도성이다.

## 금지 패턴

- Inter, Roboto, Arial, 시스템 폰트 — 개성 없음
- 보라색 그라데이션 배경 — AI 클리셰
- 예측 가능한 레이아웃 패턴 — 같은 디자인 반복 금지

## 구현 기준

- 실제로 동작하는 프로덕션급 코드
- 시각적으로 기억에 남는 디자인
- 일관된 미적 관점
- 모든 세부 요소가 정제된 완성도
```

**옵션 B — 공개 스킬 원본 유지 정책 명시**: 
레포지토리 루트 `SKILLS-README.md`에 다음 추가:
```markdown
## 예외 스킬
- `frontend-design`: 공개 스킬 원본을 그대로 유지. 영어 원문 보존.
```

---

## 11. skill-designer (기준 스킬)

### 🟡 SD-1. 자체 description undertrigger

**문제**: 이 하네스의 설계 기준 스킬이면서 description이 길고 트리거 상황은 잘 명시되어 있다.
다만 "스킬 테스트만 실행", "description 최적화만" 같은 진입 분기가 description에 없어
특수 목적 호출 시 다른 스킬을 쓸 가능성이 있다.

**현재 description** (양호):
```
사용자 인터뷰를 통해 AI Agent Skill을 설계·생성·테스트·고도화한다.
'스킬 만들어줘', '스킬 설계', '스킬 개선', 'SKILL.md 작성', '워크플로우를 스킬로',
'스킬 테스트', '스킬 트리거 최적화' 같은 표현이 나오면 반드시 이 스킬을 사용한다.
```

**개선 불필요** — 현재 description이 기준에 맞게 잘 작성되어 있다. 변경 없음.

---

## 실행 순서 요약

### Phase 1 — 즉시 (파이프라인 안정성)
```
1. P0-2: CRLF 정리 (doc-audit, agent-sync)
2. D-1:  OUTPUT V1 deprecated 처리 + scale-routing.md 수정
3. D-2:  SKILL.md에 INPUT 파일 참조 추가
4. CP-1: create-prototype allowed-tools 수정 (Agent → Task)
5. PC-1: scan.sh 변경 없을 때 즉시 종료 추가
6. PC-2: scan.sh glob 패턴 따옴표 수정
7. CM-1: commit scope 하드코딩 제거
8. MR-1: multi-review 심각도 4단계로 통일
```

### Phase 2 — 권장 (구조 개선)
```
9.  P0-1:  6개 스킬 description 업데이트
10. P0-3:  결과 파일 templates/로 이동
11. C-1:   context-doc 연속 질문 제약 추가
12. C-2:   context-doc bash 코드 SKILL.md에서 제거
13. I-1:   impl-doc pitfall-checklist 범용화
14. I-2:   impl-doc phase-design 단일 레이어 패턴 추가
15. CP-2:  create-prototype 사전 추출 단계 추가
16. CP-3:  SFR-018.html 범위 제한 읽기
17. DA-3:  agent-sync Task 참조 표기 정리
18. FD-1:  frontend-design LICENSE.txt 참조 제거
```

### Phase 3 — 선택 (완성도)
```
19. D-3:   design-doc H섹션 타이밍 변경
20. C-3:   context-doc 매핑 표 버전 명시
21. I-3:   impl-doc Step-prompts 매핑 명시
22. PC-3:  pre-commit 검사 항목 prompts 분리
23. PC-4:  pre-commit agent: fork 제거
24. CM-2:  commit disable-model-invocation 검토
25. CC-1:  code-comment 진입 분기 재작성
26. CC-2:  code-comment 이중 명세 제거
27. FD-2:  frontend-design 한글 재작성 (옵션 A)
```

---

## 체크리스트 (전체 완료 기준)

```
[ ] Phase 1 8개 항목 완료
[ ] Phase 2 10개 항목 완료
[ ] Phase 3 9개 항목 완료 (선택)
[ ] 전체 스킬 CRLF 없음 확인
[ ] design-doc V1/V2 경로 통일 확인
[ ] context-doc → impl-doc 파이프라인 섹션 번호 일치 확인
[ ] scan.sh 변경 없을 때 즉시 종료 동작 확인
[ ] 6개 스킬 description에 트리거 키워드 3개 이상 포함 확인
```
