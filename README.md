# AI Agent Harness — Forms & Skills

AI 에이전트 환경(Claude Code, Gemini CLI, Gemini GEMS 등)에서 팀이 일관된 결과물을 만들 수 있도록 설계된 **문서 템플릿·자동화 스킬 저장소**입니다.

> 왜 이런 스킬셋이 필요한지: [`Harness_Engineering_Intro.md`](./Harness_Engineering_Intro.md)
> 현재 저장소 기준 운영 가이드: [`Harness_Engineering_v2.md`](./Harness_Engineering_v2.md)

---

## 📂 디렉토리 구조

```
AI_Agent_docs/
├── Agent Skills/   ← IDE Agent가 직접 호출하는 스킬
├── Docs Skills/    ← 웹 AI / Gems / Project에 붙여 쓰는 템플릿 문서
└── example/        ← 산출물 예시
```

---

## 🤖 Agent Skills

IDE Agent(Claude Code 등)에서 `/스킬명` 으로 호출하는 자동화 스킬입니다.

### 설계·컨텍스트 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `rfp-ingest` | `RFP 분석해줘`, `SFR-019 추출` | RFP에서 SFR 추출 및 화면 후보 매핑 → `design-doc` 입력용 중간 문서 생성 |
| `design-doc` | `설계해줘`, `PRD 만들어줘` | 인터뷰 기반으로 구조화된 설계 문서 도출 |
| `context-doc` | `CLAUDE.md 만들어줘`, `에이전트 가이드 생성` | 설계 문서 → `CLAUDE.md` + `basic-instruction.md` 자동 생성 |

### 프로토타입·UI 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `design-prototype-docs` | `목업 문서 만들어줘`, `화면 설계 문서` | `create-prototype` 입력용 목업 디자인 `.md` 생성 |
| `create-prototype` | `프로토타입 만들어줘`, `화면 시안` | HTML/CSS 인터랙티브 프로토타입 생성 |
| `frontend-design` | `화면 만들어줘`, `UI 개발` | 클리셰 없는 완성도 높은 프론트엔드 코드 작성 가이드 |

### 구현 지침 계열 (3종)

설계 문서를 받아 AI Agent가 코드를 작성할 수 있는 Phase별 구현 명세서를 생성합니다.
상황에 따라 아래 세 가지 중 하나를 선택합니다.

| 스킬 | 트리거 예시 | 적합한 경우 |
|------|------------|------------|
| `impl-fe-be-doc` | `작업지침서 만들어줘`, `Phase 나눠줘` | 일반 웹앱, FE/BE 역할 분리 병행 개발 |
| `impl-screen-doc` | `화면별 구현 지침`, `SFR 화면 구현` | RFP/SFR 기반, 화면 1개 = 1 Phase |
| `impl-doc` | `구현 계획 세워줘`, `스크립트 구현 가이드` | CLI, 자동화, 라이브러리, 백엔드 단독 |

### 품질·운영 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `multi-review` | `코드 리뷰해줘` | Security / Performance / Maintainability / Testing 4관점 병렬 리뷰 |
| `pre-commit` | (커밋 전 자동 또는 수동 호출) | 에러 처리·민감 정보·타임아웃 등 규칙 준수 여부 스캔 |
| `commit` | `커밋해줘`, `커밋 메시지 만들어줘` | Conventional Commits 규격 커밋 메시지 생성 및 커밋 실행 |
| `code-comment` | `주석 달아줘`, `comment 추가` | 변경된 파일에 한글 주석 자동 작성·갱신 |
| `doc-audit` | `문서 괴리 분석`, `agent 문서 점검` | 코드와 Agent 문서 간 불일치 탐지 및 업데이트 제안 |
| `agent-sync` | `동기화해줘`, `sync` | CLAUDE.md / Skills 등 Agent 관련 문서 동기화 |

### 메타 계열

| 스킬 | 트리거 예시 | 역할 |
|------|------------|------|
| `skill-designer` | `스킬 만들어줘`, `스킬 설계` | 새 스킬 설계·생성·테스트·트리거 최적화 |

---

## 📄 Docs Skills

웹 AI(ChatGPT, Gemini, Claude.ai 등) 또는 Gems/Project 시스템 프롬프트에 붙여 쓰는 **템플릿 문서**입니다.

| 경로 | 용도 |
|------|------|
| `Docs Skills/설계문서_도출/v4/` | 설계 문서 INPUT/OUTPUT 현행 권장 양식 |
| `Docs Skills/설계문서_도출/v1~v3/` | 레거시·참고용 |
| `Docs Skills/구현작업_지시서_도출/` | 웹 AI에서 구현 지침서를 수동 도출할 때 사용 |
| `Docs Skills/스킬_도출/` | 스킬 설계 원칙 및 체크리스트 |

> **분업 권장**: 웹 AI는 설계 탐색, IDE Agent는 구현 지침·코드 작업

---

## 📚 Harness Engineering 문서

### [`Harness_Engineering_Intro.md`](./Harness_Engineering_Intro.md)

팀에서 AI를 쓰면 왜 결과물이 흔들리는지, 그 문제를 해결하기 위해 왜 공통 하네스가 필요한지를 설명하는 **도입 배경 문서**입니다.

### [`Harness_Engineering_v2.md`](./Harness_Engineering_v2.md)

현재 저장소 기준 스킬 목록, Flow A(일반 바이브코딩) / Flow B(RFP 기반) 워크플로우, 스킬 간 데이터 계약을 정리한 **운영 가이드**입니다.
