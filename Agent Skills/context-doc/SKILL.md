---
name: context-doc
description: >
  설계 문서나 PRD가 완성된 후 AI Agent용 컨텍스트 파일을 만들 때 사용한다.
  'CLAUDE.md 만들어줘', '컨텍스트 문서 생성', 'instruction 작성',
  '에이전트 가이드 만들어줘' 요청이 오면 반드시 이 스킬을 쓴다.
  설계 문서 → 얇은 CLAUDE.md(프로젝트 팩트 + 인덱스) + 주제별 .instruction/*-instruction.md 자동 생성.
  프레임워크 종속성이 없으며, 설계 문서에 등장한 주제만 분할 파일로 생성한다.
allowed-tools: Read, Glob, Grep, Bash, Write
agent: fork
---

# Context 문서 생성 (context-doc)

design-doc 스킬의 OUTPUT 또는 별도 설계 문서를 입력받아
AI Agent가 개발에 활용할 수 있는 Context 문서 세트를 생성한다.

- `CLAUDE.md` — 프로젝트 루트에 위치하는 **얇은 프로젝트 팩트 + 지침 인덱스**
- `.instruction/*-instruction.md` — 주제별로 분리된 코딩 지침 (설계 문서에 등장한 주제만 생성)

생성 전 반드시 사용자 확인을 거친다. 파일을 무단으로 수정하지 않는다.

> 이 문서들은 AI Agent가 코드를 작성할 때 매 요청마다 참조하는 핵심 컨텍스트다.
> 모호한 서술, 중복, 미결 항목 방치는 Agent의 잘못된 코드 생성으로 직결된다.
> 정밀하고 오해 없는 표현을 최우선으로 한다.

## 설계 원칙

1. **CLAUDE.md는 얇게 유지한다.** 프로젝트 팩트(기술 스택·아키텍처·실행 방법·환경 변수·주의사항)와 인덱스만 둔다.
2. **규칙은 주제별로 분리한다.** Agent가 필요한 주제만 찾아 참조할 수 있게 한다.
3. **프레임워크를 하드코딩하지 않는다.** 설계 문서에 등장한 라이브러리·주제를 그대로 반영한다.
4. **설계 문서에 없는 주제는 파일을 만들지 않는다.** 빈 파일·추측 규칙은 금지.
5. **금지 항목은 삼위일체(패턴·이유·대안)로 작성한다.**

## 스킬 연계

```
design-doc (설계 인터뷰 → OUTPUT 문서)
    ↓ OUTPUT 문서를 그대로 이 스킬에 입력
context-doc → CLAUDE.md + .instruction/*-instruction.md
```

> 아래 섹션 번호는 `design-doc`의 **OUTPUT_V2 기준**이다. V1 OUTPUT은 번호 체계가 다르므로 비권장.

design-doc OUTPUT의 각 섹션은 아래와 같이 매핑된다.

| design-doc OUTPUT 섹션 | 생성 대상 |
|------------------------|----------|
| 01 개요, 05 데이터, 07 라이브러리 | CLAUDE.md — 프로젝트 팩트 |
| 06 파일 구성 | CLAUDE.md(트리) + architecture-instruction.md + file-convention-instruction.md |
| 02 동작 흐름 | comm-instruction.md |
| 03 집중 로직 | architecture-instruction.md + framework-instruction.md |
| 04 인터페이스 | api-instruction.md + comm-instruction.md |
| 07 라이브러리 | framework-instruction.md |
| 10 주의사항 | code-style-instruction.md / agent-instruction.md / 각 주제 금지 목록 |
| 12 열린 결정 | 해당 주제 파일의 `미정` 섹션 |

---

## 분할 파일 카탈로그

설계 문서에서 해당 내용이 발견될 때만 생성한다. 없으면 만들지 않는다.

| 파일 | 생성 조건 |
|------|----------|
| `architecture-instruction.md` | 모듈·레이어 경계, 의존성 방향, 책임 분리 규칙이 있을 때 |
| `code-style-instruction.md` | 네이밍·타입힌트·예외 처리·주석 스타일 규칙이 있을 때 |
| `framework-instruction.md` | 라이브러리별 사용 규칙/금지 패턴이 있을 때 |
| `api-instruction.md` | API 엔드포인트·요청/응답 스키마 규약이 있을 때 |
| `comm-instruction.md` | WebSocket·메시지큐·RPC 등 통신 프로토콜 규약이 있을 때 |
| `file-convention-instruction.md` | 파일 위치·네이밍·디렉토리 추가 기준이 있을 때 |
| `agent-instruction.md` | 항상 생성 (AI가 사람과 다르게 행동해야 할 규칙 집합) |

---

## 워크플로우

### Step 1 — 입력 문서 수집

설계 문서가 제공되지 않은 경우 요청한다.

> "CLAUDE.md와 instruction 문서를 생성할 설계 문서를 공유해 주세요.
> design-doc 스킬의 결과물이나 기존 PRD/설계서 모두 가능합니다."

---

### Step 2 — 구조 판정

설계 문서 `06 파일 구성`의 디렉토리 트리를 읽어 아래를 판정한다.

- **모노레포 여부**: `frontend/`·`backend/`·`fe/`·`be/`·`client/`·`server/` 등 **명시적 분리**가 보이는가
- **분할 대상 파일**: 위 카탈로그에서 어떤 파일을 생성할지 결정

모노레포로 감지되면 사용자에게 1회 확인한다.

> "디렉토리 트리에 FE/BE 분리가 보입니다.
> `.instruction/`을 프로젝트별로 분리할까요, 루트에 통합할까요?"

---

### Step 3-A — CLAUDE.md 분석

`prompts/analysis-claude.md` 기준으로 설계 문서를 분석하여 **프로젝트 팩트**만 추출한다.
**질문은 최대 1개만** 한다. (Step 3-B와 합산 2개 이하)
누락 항목은 `미정 — [이유]` 로 표시한다.

---

### Step 3-B — instruction 분석 및 주제 분류

`prompts/analysis-instruction.md` 기준으로 설계 문서를 분석하여
**주제별로 규칙을 분류**한다. 각 주제마다 다음을 모은다.

- 규칙 본문
- 금지 패턴 + 이유 + 대안 (삼위일체)
- 예시 스니펫 (핵심 패턴만)

**질문은 최대 1개만** 한다. (Step 3-A에서 질문했다면 이 단계에서는 질문 금지)
누락 항목은 `미정 — [이유]` 로 표시한다.

주제별 분류가 끝나면 **어떤 파일을 생성할지 목록을 확정**한다.

---

### Step 4 — 문서 초안 생성

`templates/` 하위 템플릿을 참조하여 각 파일 초안을 작성한다.

- `templates/CLAUDE.md.template`
- `templates/architecture-instruction.md.template`
- `templates/code-style-instruction.md.template`
- `templates/framework-instruction.md.template`
- `templates/api-instruction.md.template`
- `templates/comm-instruction.md.template`
- `templates/file-convention-instruction.md.template`
- `templates/agent-instruction.md.template`

작성 원칙:
- 확실하지 않은 항목은 `미정 — [이유]` 로 표시하고 생략하지 않는다.
- 설계 문서의 "열린 결정 사항"은 그대로 전달한다.
- 코드 예시는 핵심 패턴만, 완성 코드는 포함하지 않는다.
- **CLAUDE.md의 인덱스와 실제 생성 파일 목록이 1:1로 일치**해야 한다.
- 각 instruction 파일은 자신의 주제에만 집중한다. 주제 간 중복 금지.

---

### Step 5 — 미리보기 및 사용자 확인

CLAUDE.md와 각 instruction 파일 초안을 대화창에 순서대로 출력하고 승인을 요청한다.

> "위 문서들을 검토해 주세요.
> 수정할 부분이 있으면 말씀해 주시고, 이상 없으면 저장 경로를 확인해 드릴게요."

저장 경로 안내 (단일 프로젝트 기준):
- `CLAUDE.md` → 프로젝트 루트
- `.instruction/*-instruction.md` → 프로젝트 루트 하위 `.instruction/` 폴더

모노레포 분리 선택 시:
- `{project}/CLAUDE.md` → 각 프로젝트 루트
- `{project}/.instruction/*-instruction.md` → 각 프로젝트 하위

---

### Step 6 — 파일 저장

승인 시 `.instruction/` 디렉토리가 없으면 먼저 생성한 후 모든 파일을 저장한다.

저장 완료 후 검증:
- `CLAUDE.md`의 인덱스에 명시된 각 `@.instruction/*-instruction.md` 참조 경로가
  실제 저장된 파일과 1:1로 일치하는지 확인한다.
- 일치하지 않으면 사용자에게 보고하고 수정한다.
