# Harness Engineering Guide v1

> AI Agent 하네스 엔지니어링 관점에서 정리한 전체 워크플로우.
> RFP 기반 흐름과 일반 아이디어 기반 흐름으로 분기하며,
> create-prototype 는 제안 단계와 구현 단계 두 곳에서 사용 가능하다.

---

## 1. 전체 스킬 맵

```
[RFP 해석 계열]          [설계 계열]           [구현 지침 계열]       [목업·구현 계열]
rfp-ingest ✗            design-doc ✓          impl-doc ✓            create-prototype ✓
rfp-compliance-         context-doc ✓         impl-screen-doc ✗     frontend-design ✓
review ✗                sfr-trace ✗                                 code-comment ✓

[품질 게이트 계열]        [메타·하네스 계열]
multi-review ✓          skill-designer ✓
pre-commit ✓            doc-audit ✓
commit ✓                agent-sync ✓
                        pdf ✓ / pptx ✓ / xlsx ✓ / docx ✓
```

> ✓ = 구현 완료  ✗ = 스펙 정의만 있거나 미존재 (구현 필요)

---

## 2. 어느 흐름으로 시작할 것인가

```
작업 시작
    │
    ├── RFP(제안요청서)가 있는가?
    │         │
    │       YES ──► Flow B: RFP 기반 흐름  (§4)
    │         │
    │        NO
    │         │
    └── 아이디어 / 내부 기획만 있는가?
              │
            YES ──► Flow A: 일반 흐름      (§3)
```

| 구분 | 진입점 | 특징 |
|------|--------|------|
| **Flow A** | 아이디어 · 내부 기획 | 자유도 높음. 설계부터 직접 시작 |
| **Flow B** | RFP 파일 (`@pdf`) | SFR 번호 기반. 요구사항 추적 필수 |

---

## 3. Flow A — 일반 흐름 (RFP 없음)

```
┌──────────────────────────────────────────────────────────────────────┐
│                      Flow A: 일반 아이디어 기반                        │
└──────────────────────────────────────────────────────────────────────┘

아이디어 / 내부 기획
        │
        ▼
[Step 1] /design-doc
  ├─ 스케일 확인 (프로젝트 / 화면 / 기능 / 세부 로직)
  ├─ 인터뷰 기반 구조화
  └─ 설계문서.md 생성
  │
  ├──────────────────────────────────────────────┐
  ▼                                              ▼
[Step 2-A] /context-doc                   [Step 2-B] create-prototype (선택)
  ├─ CLAUDE.md 생성                          └─ 초기 UI 개념 목업
  └─ basic-instruction.md 생성                  (화면 아이디어 확인용)
  │
  ▼
[Step 3] /impl-doc
  ├─ FE/BE 페어 Phase별 작업지침서
  ├─ 태스크 의존 관계 확정
  └─ Phase별 검증 시나리오
  │
  ▼
[Step 4] /impl-screen-doc  (화면 단위 작업 시)
  ├─ 화면별 컴포넌트 구조
  ├─ API 연동 포인트
  └─ 상태·에러 처리 시나리오
  │
  ├──────────────────────────┐
  ▼                          ▼
[Step 5-A]                [Step 5-B]
/create-prototype         /frontend-design
  └─ 설계 확정 후 정밀      └─ 실제 컴포넌트 구현
     HTML 프로토타입
  │
  ▼  (Phase 1개 완료마다 반복)
/doc-audit  ──  /multi-review
  └─ 문서 괴리 점검   └─ 코드 리뷰 4관점
  │
  ▼
/pre-commit
  │
  ▼
/commit
```

### Flow A 스케일별 단축 경로

| 스케일 | 생략 가능한 단계 |
|--------|----------------|
| 프로젝트 | 전 단계 필수 |
| 화면 단위 | impl-doc 선택 (단순 화면이면 impl-screen-doc 바로) |
| 기능 단위 | context-doc 선택, impl-doc 선택 |
| 세부 로직 | design-doc만 하고 바로 구현 가능 |

---

## 4. Flow B — RFP 기반 흐름

```
┌──────────────────────────────────────────────────────────────────────┐
│                      Flow B: RFP 기반                                 │
└──────────────────────────────────────────────────────────────────────┘

@RFP 파일 지정
  예) @D:\Dev_Workspace\pre_working\프로젝트명\제안요청서_v2.pdf
        │
        ▼
[Step 1] /rfp-ingest SFR-019[,SFR-021,...]
  ├─ RFP에서 SFR 추출 (병렬 서브에이전트)
  ├─ 화면 후보 목록 + 요구사항-화면 매핑
  ├─ 불명확 항목 인라인 확인 질문
  └─ rfp-design-input-{SFR}.md 생성
        │
        │  ◀──────────────────────────────────────────────────┐
        │  [제안 단계 분기]                                     │
        │  설계 확정 전 추상 목업이 필요한 경우                    │
        ├──────────────────────────────────────────────────►  │
        │                                         /create-prototype
        │                                           ├─ rfp-design-input-*.md 기반
        │                                           ├─ 화면 흐름 미확정 상태 허용
        │                                           └─ SFR 번호 기반 HTML 목업
        │                                              (설계 확정 시 재생성)
        │
        ▼  [설계·구현 단계]
[Step 2] /design-doc
  ├─ rfp-design-input-*.md를 인터뷰 응답으로 활용
  └─ 설계문서.md 생성
        │
        ├──────────────────────────────────┐
        ▼                                  ▼
[Step 3-A] /context-doc            [Step 3-B] /sfr-trace (선택)
  ├─ CLAUDE.md                       ├─ SFR ↔ 화면 ↔ API 매핑 매트릭스
  └─ basic-instruction.md            └─ 누락·충돌 항목 리포트
        │
        ▼
[Step 4] /impl-doc
  ├─ FE/BE 페어 Phase별 작업지침서
  └─ Phase별 검증 시나리오
        │
        ▼
[Step 5] /impl-screen-doc
  ├─ 화면별 컴포넌트 구조
  ├─ API 연동 포인트
  └─ 상태·에러 처리 시나리오
        │
        ├──────────────────────────┐
        ▼                          ▼
[Step 6-A]                    [Step 6-B]
/create-prototype             /frontend-design
  └─ 설계 확정 후 정밀            └─ 실제 컴포넌트 구현
     HTML 프로토타입
        │
        ▼  (Phase 1개 완료마다 반복)
/doc-audit  ──  /multi-review
  │
  ▼
/pre-commit
  │
  ├──────────────────────────────────┐
  ▼                                  ▼
/commit                    /rfp-compliance-review (납품 전)
                             ├─ RFP 필수 요구사항 커버리지 점검
                             └─ 미반영 SFR · 부분 반영(위험) 리포트
```

### Flow B create-prototype 두 가지 시점

| 시점 | 단계 | 상태 | 목적 |
|------|------|------|------|
| **제안 단계** | rfp-ingest 직후 | 설계 미확정 허용 | 발주처 설득용 추상 목업 |
| **구현 단계** | impl-screen-doc 이후 | 설계 확정 기반 | 정밀 프로토타입, 개발 기준 |

> 같은 SFR에 대해 두 번 실행이 정상. 구현 단계 버전이 제안 단계 버전을 덮어씀.

---

## 5. 스킬 간 데이터 흐름

```
@RFP ──► rfp-ingest ──► rfp-design-input-*.md
                                │
                                ▼
아이디어 ────────────► design-doc ──► 설계문서.md
                            │               │
                    ┌───────┘               └──► sfr-trace ──► sfr-trace-matrix.md
                    │
                    ├──► context-doc ──► CLAUDE.md
                    │                   basic-instruction.md
                    │
                    └──► impl-doc ──► 작업지침서.md
                              │
                              ▼
                      impl-screen-doc ──► impl-screen-{화면}.md
                              │
                      create-prototype ──► SFR-{번호}.html
                              │
                      frontend-design ──► 컴포넌트 코드
                              │
                     doc-audit + multi-review
                              │
                          pre-commit
                              │
                           commit ──► git history
                              │
                    rfp-compliance-review ──► rfp-compliance-report.md
```

---

## 6. 서브에이전트 전략

### 현재 병렬 서브에이전트를 사용하는 스킬

| 스킬 | 병렬화 대상 | 효과 |
|------|------------|------|
| `multi-review` | 보안·성능·유지보수·테스트 4 페르소나 | 리뷰 시간 1/4 |
| `create-prototype` | 화면 조각 파일 (SFR-001-1.html 등) | 화면 수만큼 병렬 |
| `doc-audit` | 분석 관점별 (의존성·패턴·규칙 위반) | 분석 시간 단축 |
| `impl-doc` | fork 모드 실행 | 컨텍스트 격리 |

### 신규 스킬에 적용할 서브에이전트 토폴로지

**`rfp-ingest` — SFR 병렬 분석**

```
/rfp-ingest SFR-019, SFR-021, SFR-023
  │
  ├── subagent-A: SFR-019 분석 (입력/처리/출력/예외)
  ├── subagent-B: SFR-021 분석
  └── subagent-C: SFR-023 분석
        │
        ▼ (오케스트레이터 병합)
  rfp-design-input-SFR-019_021_023.md
```

**`sfr-trace` — 문서별 병렬 검증**

```
  ├── subagent-A: 설계문서.md × SFR 목록 대조
  ├── subagent-B: impl-screen-*.md × SFR 목록 대조
  └── subagent-C: 테스트 문서 × SFR 목록 대조
        │
        ▼
  sfr-trace-matrix.md
```

**`rfp-compliance-review` — 요구사항 카테고리별 병렬**

```
  ├── subagent-A: 기능요구사항 커버리지
  ├── subagent-B: 비기능요구사항 (성능·보안·가용성)
  └── subagent-C: 납품 산출물 체크리스트
```

---

## 7. 훅(Hook) 전략

### 판단 기준

> **써야 하는 훅**: "빠뜨리면 반드시 문제가 생기는 것"
> **쓰지 말아야 하는 훅**: "하면 좋은 것" — 수동으로 유지

### 권장 훅

| 훅 타입 | 시점 | 실행 내용 | 이유 |
|---------|------|-----------|------|
| `PreToolUse` (Bash) | git commit 명령 전 | scan.sh 자동 실행 | /pre-commit 잊는 경우 방지 |
| `Stop` | 세션 종료 시 | 코드 변경 감지 → doc-audit 알림 출력 | CLAUDE.md 괴리 축적 방지 |

**Stop 훅 예시:**

```json
"Stop": [{
  "hooks": [{
    "type": "command",
    "command": "git diff --name-only HEAD 2>/dev/null | grep -qE '\\.(ts|tsx|js|java|py)' && echo '⚠ 코드 변경 감지 — /doc-audit 실행 권장'"
  }]
}]
```

### 쓰지 말아야 하는 훅

| 훅 | 이유 |
|----|------|
| design-doc 완료 → context-doc 자동 실행 | 설계 문서 추가 수정 가능. 중간 자동 실행은 노이즈 |
| rfp-ingest 완료 → design-doc 자동 실행 | 제안 단계에서 바로 create-prototype으로 가는 분기가 막힘 |
| commit 완료 → rfp-compliance-review 자동 실행 | 매 커밋마다 RFP 전체를 읽는 건 비용 낭비 |

---

## 8. 스킬 선택 기준 — 런타임 치트시트

| 지금 이 상황 | 실행 스킬 |
|------------|-----------|
| 새 SFR 작업 시작 | `/rfp-ingest SFR-xxx` |
| 제안 단계 추상 목업 필요 | `/create-prototype` (rfp-ingest 직후) |
| 아이디어 → 설계 문서 | `/design-doc` |
| 설계 완료 → AI 컨텍스트 파일 | `/context-doc` |
| 구현 순서·Phase 분할 | `/impl-doc` |
| 화면 단위 구현 명세 | `/impl-screen-doc` |
| 설계 확정 후 정밀 목업 | `/create-prototype` |
| 실제 UI 컴포넌트 구현 | `/frontend-design` |
| SFR 커버리지 점검 | `/sfr-trace` |
| Phase 완료 후 코드 리뷰 | `/multi-review` |
| 코드와 CLAUDE.md 괴리 점검 | `/doc-audit` |
| 커밋 전 규칙 검사 | `/pre-commit` |
| 커밋 | `/commit` |
| 납품 전 최종 요구사항 점검 | `/rfp-compliance-review` |
| 반복 워크플로우 → 스킬화 | `/skill-designer` |

---

## 9. 구현 필요한 스킬 (미존재 · 우선순위 순)

| 스킬 | 우선순위 | 이유 |
|------|---------|------|
| `rfp-ingest` | **P0** | Flow B 진입점. 없으면 RFP → design-doc 연결이 수동 |
| `impl-screen-doc` | **P0** | HTML 목업 → 실제 구현 브릿지. 없으면 create-prototype이 참고용으로만 끝남 |
| `sfr-trace` | **P1** | 납품 프로젝트에서 SFR 누락은 계약 리스크 |
| `rfp-compliance-review` | **P1** | sfr-trace는 매핑, compliance-review는 요구사항 준수 — 역할 다름 |
| `acceptance-test-doc` | **P2** | 반복 납품 시 SFR별 인수 기준 자동화 |
| `artifact-pack` | **P2** | 납품 산출물 패키지 자동 정리 |

---

## 10. 하네스 설계 원칙

1. **명시적 트리거**: Hook 자동 실행 없음. 모든 스킬은 사용자가 명시적으로 호출.
2. **SFR 선택 실행**: RFP 전체를 일괄 처리하지 않음. 그때그때 필요한 SFR만.
3. **산출물 연결**: 각 스킬의 출력이 다음 스킬의 입력이 되는 파이프라인 구조.
4. **스킬 통합 원칙**: 유사 기능은 별도 스킬 분리 대신 옵션/플래그로 흡수.
   - `sfr-change-impact` → `sfr-trace --impact`
   - `rfp-clarify` → `rfp-ingest` Step 3 인라인 처리
5. **게이트 포지셔닝**: 게이트는 언제, 무엇을 막는지로 구분.
   - `pre-commit`: 코드 규칙 게이트 (커밋 전)
   - `rfp-compliance-review`: 요구사항 게이트 (납품 전)
6. **프로토타입 이중 사용**: `create-prototype`은 제안 단계(추상)와 구현 단계(정밀) 모두에서 실행. 나중 버전이 덮어씀.

---

## 11. 바이브코딩 운영 노하우

### 컨텍스트 창 낭비하지 않는 대화 설계

- 긴 탐색 대화(설계·우려 사항)는 웹 AI에서, 실제 구현 지시는 Agent에서
- Agent에게는 `"Phase 2의 BE-05 태스크 구현해줘. 작업지침서 참고해"` 같이 짧고 범위가 한정된 지시가 효과적
- 대화 초반에 CLAUDE.md, 작업지침서를 언급해두면 Agent가 알아서 읽고 컨텍스트를 채움

### Phase 단위 체크포인트

- Phase 하나 완료 → 검증 시나리오 직접 실행 → `/multi-review` → `/pre-commit` → `/commit`
- git 체크포인트를 남겨두면 Agent가 이상한 방향으로 갔을 때 되돌리기 쉬움
- "Phase 1~5 한 번에 다 짜줘"는 거의 항상 중간에 인터페이스가 안 맞는 문제 발생

### 금지 패턴 작성 삼위일체

`basic-instruction.md` 금지 패턴은 반드시 **패턴 + 이유 + 대안** 세트로 작성.

```markdown
### ❌ DOM 전체를 LLM에 직접 전달
- **패턴**: `llm.invoke(full_html_string)`
- **이유**: 토큰 초과로 컨텍스트 창 초과 또는 응답 품질 급락
- **대안**: missing_selectors 주변 영역만 추출하거나 3,000자로 잘라서 전달
```

단순히 "하지 마라"만 쓰면 Agent가 이유를 모르고 같은 실수를 반복함.

### 웹 AI vs Agent(IDE) 역할 분담

| 상황 | 웹 AI | Agent (Claude Code) |
|------|-------|---------------------|
| 초기 아이디어 탐색 | ✅ | — |
| 설계 인터뷰 | ✅ | ✅ `/design-doc` |
| 처음 쓰는 기술 조사 (웹 검색) | ✅ | — |
| 우려 사항 고도화 | ✅ | — |
| Context 문서 생성 | ✅ 템플릿 | ✅ `/context-doc` |
| 작업지침서 도출 | ✅ 템플릿 | ✅ `/impl-doc` |
| 실제 코드 작성 | — | ✅ |
| 코드 리뷰·커밋 | — | ✅ |
| 문서 동기화·괴리 분석 | — | ✅ |
