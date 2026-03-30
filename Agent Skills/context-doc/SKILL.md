---
name: context-doc
description: >
  설계 문서나 PRD가 완성된 후 AI Agent용 컨텍스트 파일을 만들 때 사용한다.
  'CLAUDE.md 만들어줘', '컨텍스트 문서 생성', 'basic-instruction 작성',
  '에이전트 가이드 만들어줘' 요청이 오면 반드시 이 스킬을 쓴다.
  설계 문서 → CLAUDE.md + basic-instruction.md 2종 자동 생성.
allowed-tools: Read, Glob, Grep, Bash, Write
agent: fork
---

# Context 문서 생성 (context-doc)

design-doc 스킬의 OUTPUT 또는 별도 설계 문서를 입력받아
AI Agent가 개발에 활용할 수 있는 Context 문서 2종을 생성한다.

- `CLAUDE.md` — 프로젝트 루트에 위치하는 AI Agent 전용 프로젝트 맥락 문서
- `.instruction/basic-instruction.md` — 코딩 규칙 및 아키텍처 제약 지침

생성 전 반드시 사용자 확인을 거친다. 파일을 무단으로 수정하지 않는다.

> 이 문서들은 AI Agent가 코드를 작성할 때 매 요청마다 참조하는 핵심 컨텍스트다.
> 모호한 서술, 중복, 미결 항목 방치는 Agent의 잘못된 코드 생성으로 직결된다.
> 정밀하고 오해 없는 표현을 최우선으로 한다.

## 스킬 연계

이 스킬은 단독으로도 사용할 수 있지만, 아래 순서로 연계했을 때 가장 효과적이다.

```
design-doc (설계 인터뷰 → OUTPUT 문서)
    ↓ OUTPUT 문서를 그대로 이 스킬에 입력
context-doc → CLAUDE.md + basic-instruction.md
```

> 아래 섹션 번호는 `design-doc`의 **OUTPUT_V2 기준**이다. V1 OUTPUT은 번호 체계가 다르므로 비권장.

design-doc OUTPUT의 각 섹션은 아래와 같이 매핑된다.

| design-doc OUTPUT 섹션 | 생성 대상 |
|------------------------|----------|
| 01 개요, 05 데이터, 06 파일 구성 | CLAUDE.md — 프로젝트 맥락·아키텍처 |
| 02 동작 흐름, 07 라이브러리 | CLAUDE.md — 통신 규칙·기술 스택 |
| 03 집중 로직, 04 인터페이스 | basic-instruction.md — 아키텍처 제약 |
| 10 주의사항, 12 열린 결정 | basic-instruction.md — 금지 목록·미결 항목 |

---

## 워크플로우

### Step 1 — 입력 문서 수집

설계 문서가 제공되지 않은 경우 요청한다.

> "CLAUDE.md와 basic-instruction.md를 생성할 설계 문서를 공유해 주세요.
> design-doc 스킬의 결과물이나 기존 PRD/설계서 모두 가능합니다."

---

### Step 2-A — CLAUDE.md 분석

`prompts/analysis-claude.md` 기준으로 설계 문서를 분석한다.
**질문은 최대 1개만** 한다. (Step 2-B와 합산 2개 이하)
누락 항목은 `미정 — [이유]` 로 표시한다.

---

### Step 2-B — basic-instruction.md 분석

`prompts/analysis-instruction.md` 기준으로 설계 문서를 분석한다.
특히 금지 목록은 **금지 패턴 + 이유 + 대안** 삼위일체가 모두 갖춰졌는지 확인한다.
**질문은 최대 1개만** 한다. (Step 2-A에서 질문했다면 이 단계에서는 질문 금지)
누락 항목은 `미정 — [이유]` 로 표시한다.

---

### Step 3 — 문서 초안 생성

`templates/CLAUDE.md.template` 와 `templates/basic-instruction.md.template` 를 참조하여
Step 2-A / 2-B 분석 결과를 각각 채워 초안을 작성한다.

작성 원칙:
- 확실하지 않은 항목은 `미정 — [이유]` 로 표시하고 생략하지 않는다.
- 설계 문서의 "열린 결정 사항"은 그대로 전달한다.
- 코드 예시는 핵심 패턴만, 완성 코드는 포함하지 않는다.
- 두 문서 사이에 동일 내용이 중복되면 CLAUDE.md에만 두고 basic-instruction.md에서 참조 처리한다.

---

### Step 4 — 미리보기 및 사용자 확인

두 문서 초안을 대화창에 순서대로 출력하고 승인을 요청한다.

> "위 두 문서를 검토해 주세요.
> 수정할 부분이 있으면 말씀해 주시고, 이상 없으면 저장 경로를 확인해 드릴게요."

저장 경로 안내:
- `CLAUDE.md` → 프로젝트 루트
- `.instruction/basic-instruction.md` → 프로젝트 루트 하위 `.instruction/` 폴더

---

### Step 5 — 파일 저장

승인 시 `.instruction/` 디렉토리가 없으면 먼저 생성한 후 두 파일을 저장한다.
저장 경로는 아래를 따른다.
- `CLAUDE.md` → 프로젝트 루트
- `.instruction/basic-instruction.md` → `.instruction/` 하위

저장 완료 후 `CLAUDE.md` 내 `@.instruction/basic-instruction.md` 참조 경로가
실제 파일 위치와 일치하는지 확인한다.
