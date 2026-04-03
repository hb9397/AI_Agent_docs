# Harness Engineering Guide v2

> 2026-04-03 기준 현재 저장소 스킬셋을 기준으로 다시 정리한 AI Agent 하네스 운영 가이드.
> `Harness_Engineering_v1.md`를 현재 상태에 맞게 갱신한 버전이며, 실제로 존재하는 스킬과 문서만 기준으로 작성했다.
> `v1`에서 예정으로 적혀 있던 `rfp-ingest`, `impl-screen-doc`, `impl-doc`은 이제 구현 완료 기준으로 반영했고, 아직 없는 항목은 별도 갭으로 분리했다.

---

## 1. 이 문서의 목적

이 저장소의 본질은 "AI가 코드를 잘 짜게 만드는 문서·규칙·워크플로우를 미리 설계하는 것"이다.

핵심은 세 가지다.

1. **설계 문서가 먼저다.** 바로 구현시키지 않는다.
2. **Agent가 계속 참조할 고정 컨텍스트를 만든다.**
3. **구현 단위를 작게 쪼개고 품질 게이트를 사이사이에 둔다.**

`v2`는 이 흐름을 현재 저장소 기준으로 다시 정리한다.

---

## 2. 이번 버전에서 달라진 점

- `design-doc`는 이제 `INPUT_V2` / `OUTPUT_V2` 중심 체계다.
- `Flow B`의 진입점인 `rfp-ingest`가 실제 구현되어 있다.
- 구현 지침 계열이 이제 실제로 **3종**이다.
  - `impl-fe-be-doc`
  - `impl-screen-doc`
  - `impl-doc`
- 프로토타입 브리지가 명확하다.
  - `design-prototype-docs` → `create-prototype`
- 운영 스킬 축이 선명해졌다.
  - `doc-audit`, `multi-review`, `pre-commit`, `commit`, `agent-sync`, `code-comment`
- 반대로 아래 항목은 아직 저장소에 없다.
  - `sfr-trace`
  - `rfp-compliance-review`
  - `acceptance-test-doc`
  - `artifact-pack`

---

## 3. 저장소 최신 지도

```text
AI_Agent_docs/
├── Agent Skills/   ← IDE 안의 Agent가 직접 호출하는 스킬
├── Docs Skills/    ← 웹 AI/Gems/Project에 넣어 쓰는 템플릿 문서
├── example/        ← 산출물 예시
├── Harness_Engineering_v1.md
└── v2.md
```

### 3-1. Agent Skills — 현재 활성 스킬

#### A. 분석·설계·컨텍스트 계열

| 호출명 | 디렉토리 | 역할 | 대표 입력 | 대표 산출물 |
|--------|----------|------|-----------|-------------|
| `rfp-ingest` | `Agent Skills/rfp-ingest` | RFP에서 지정 SFR 추출·해석·화면 후보 매핑 | `@RFP PDF`, `SFR-019` 등 | `rfp-design-input-{SFR}.md` |
| `design-doc` | `Agent Skills/design-doc` | 인터뷰 기반 설계 문서 도출 | 아이디어, 기존 문서, RFP 중간 문서 | `OUTPUT_V2` 형식 설계 문서 |
| `context-doc` | `Agent Skills/context-doc` | Agent용 컨텍스트 문서 생성 | `design-doc` 결과물 | `CLAUDE.md`, `.instruction/basic-instruction.md` |

#### B. 프로토타입·UI 계열

| 호출명 | 디렉토리 | 역할 | 대표 입력 | 대표 산출물 |
|--------|----------|------|-----------|-------------|
| `design-prototype-docs` | `Agent Skills/design-prototype-docs` | 프로토타입 입력용 화면 설계 문서 생성 | 요구사항, RFP, PRD | `{PREFIX}-{번호}_목업디자인.md` |
| `create-prototype` | `Agent Skills/create-prototype` | HTML/CSS/JSON 프로토타입 생성 | 목업 디자인 문서, 화면 기능 설명 | `{PREFIX}-{번호}/` 프로토타입 폴더 |
| `frontend-design` | `Agent Skills/frontend-design` | 실제 UI 구현 시 디자인 품질 기준 제공 | 화면 구현 요청 | 개성 있는 프론트 코드 |

#### C. 구현 지침 계열

| 호출명 | 디렉토리 | 역할 | 중심 축 | 적합한 대상 |
|--------|----------|------|---------|-------------|
| `impl-fe-be-doc` | `Agent Skills/impl-fe-be-doc` | FE/BE 페어 Phase 작업지침서 | 역할 분리 | 일반 웹앱, FE/BE 병행 개발 |
| `impl-screen-doc` | `Agent Skills/impl-screen-doc` | 화면 단위 구현 지침서 | 화면 1개 = 1 Phase | RFP/SFR 기반, 화면 중심 구현 |
| `impl-doc` | `Agent Skills/impl-doc` | 범용 단계별 구현 지침서 | 기능/모듈/파이프라인 | CLI, 자동화, 라이브러리, 백엔드 단독 |

#### D. 품질·운영 계열

| 호출명 | 디렉토리 | 역할 | 핵심 포인트 |
|--------|----------|------|-------------|
| `multi-review` | `Agent Skills/multi-review` | 4관점 병렬 코드 리뷰 | Security / Performance / Maintainability / Testing |
| `pre-commit` | `Agent Skills/pre-commit` | 커밋 전 규칙 검사 | 에러 처리, 타임아웃, 민감 정보, TODO, 테스트 |
| `commit` | `Agent Skills/commit` | Conventional Commits 기반 커밋 | 한글 description, scope 추론, why 중심 body |
| `code-comment` | `Agent Skills/code-comment` | 변경 파일 한글 주석 작성·갱신 | 승인 전 파일 미수정 원칙 |
| `doc-audit` | `Agent Skills/doc-audit` | 코드와 Agent 문서 괴리 분석 | 제안만 먼저 출력, 승인 후 반영 |
| `agent-sync` | `Agent Skills/agent-sync` | Agent 문서/Skills 동기화 | Docs와 Skills를 분리 또는 병렬 동기화 |

#### E. 메타 계열

| 호출명 | 디렉토리 | 역할 | 비고 |
|--------|----------|------|------|
| `skill-designer` | `Agent Skills/skill-design` | 새 스킬 설계·생성·테스트·트리거 최적화 | 디렉토리명은 `skill-design`, 실제 name은 `skill-designer` |

### 3-2. Docs Skills — 웹 AI용 템플릿

| 경로 | 현재 상태 | 용도 |
|------|-----------|------|
| `Docs Skills/설계문서_도출/v4/INPUT_V2.md` | **현재 권장** | 웹 AI 인터뷰 입력 양식 |
| `Docs Skills/설계문서_도출/v4/OUTPUT_V2.md` | **현재 권장** | 설계 산출물 양식 |
| `Docs Skills/설계문서_도출/v1~v3` | 레거시/참고용 | 과거 버전 호환 또는 예시 참조 |
| `Docs Skills/구현작업_지시서_도출/v1/Impl_workflow_doc.md` | 현재도 존재 | 웹 AI에서 구현 지침서를 수동 도출할 때 사용 |
| `Docs Skills/스킬_도출/skill-design-guide.md` | 현재도 존재 | 스킬 설계 원칙 참고 |

> 현재 저장소를 보면 설계 문서 체계는 `v4`까지 정리돼 있고, 구현 지침 문서 템플릿은 Docs Skills 쪽보다 Agent Skills 쪽이 더 세분화돼 있다.  
> 따라서 **웹 AI는 설계 탐색**, **IDE Agent는 구현 지침·코드 작업**에 쓰는 분업이 가장 자연스럽다.  
> 위 해석은 저장소 구조를 바탕으로 한 운영 권장안이다.

---

## 4. 작업 시작 전에 먼저 정해야 할 3가지

### 4-1. 진입점

| 질문 | 분기 |
|------|------|
| 아이디어/내부 기획만 있는가? | `Flow A` |
| RFP/PDF/SFR 번호가 이미 있는가? | `Flow B` |

### 4-2. 작업 스케일

| 스케일 | 예시 | 기본 권장 |
|--------|------|-----------|
| 프로젝트 전체 | 신규 서비스, 신규 서브시스템 | `design-doc` → `context-doc` → `impl-*` |
| 화면 단위 | 대시보드, 설정 화면 | `design-doc` → `design-prototype-docs` 또는 `impl-screen-doc` |
| 기능 단위 | 로그인, 예약 실행, 분석 실행 | `design-doc` → `impl-fe-be-doc` 또는 `impl-doc` |
| 컴포넌트/로직 단위 | 훅, 파서, 재시도 로직 | `design-doc`만 쓰거나 바로 구현 |

### 4-3. 구현 지침의 중심 축

| 질문 | 선택할 스킬 |
|------|-------------|
| FE/BE를 한 Phase 안에서 같이 끝내야 하는가? | `impl-fe-be-doc` |
| 화면별 컴포넌트/API/상태 명세가 중심인가? | `impl-screen-doc` |
| 웹앱이 아니라 도구/스크립트/라이브러리인가? | `impl-doc` |

---

## 5. Flow A — 일반 바이브코딩 흐름

```text
아이디어 / 내부 기획
        │
        ▼
/design-doc
        │
        ├─ (선택) 기술 불확실성·우려사항 고도화 인터뷰
        │          주로 웹 AI에서 수행
        │
        ├─ (권장) /context-doc
        │
        ├─ (선택) /design-prototype-docs
        │            └─→ /create-prototype
        │
        ▼
구현 지침 3종 중 하나 선택
  ├─ /impl-fe-be-doc
  ├─ /impl-screen-doc
  └─ /impl-doc
        │
        ▼
실제 구현
  └─ UI 비중이 높으면 /frontend-design 기준 적용
        │
        ▼
/multi-review + /doc-audit
        │
        ▼
/pre-commit
        │
        ├─ (선택) /code-comment
        ▼
/commit
        │
        └─ Agent 문서/스킬이 바뀌었으면 /agent-sync
```

### Flow A에서 기억할 점

- 화면 구조가 불명확하면 `impl-*` 전에 `design-prototype-docs → create-prototype`을 먼저 돌리는 편이 좋다.
- 프로젝트 전체 작업이면 `context-doc`를 거의 필수로 본다.
- 컴포넌트/로직 단위처럼 작은 작업은 `design-doc`까지만 하고 바로 구현해도 된다.
- 같은 대화에서 여러 Phase를 한꺼번에 구현시키기보다, **Phase 1개 또는 화면 1개 단위**로 끊는 것이 낫다.

---

## 6. Flow B — RFP 기반 흐름

```text
@RFP PDF + SFR 번호 지정
        │
        ▼
/rfp-ingest
        │
        ▼
rfp-design-input-{SFR}.md
        │
        ├─ 제안 단계 목업이 필요하면
        │    /design-prototype-docs
        │      └─→ /create-prototype
        │
        ▼
/design-doc
        │
        ├─ (권장) /context-doc
        ├─ (선택) /design-prototype-docs → /create-prototype
        ▼
구현 지침 3종 중 하나 선택
  ├─ /impl-screen-doc
  ├─ /impl-fe-be-doc
  └─ /impl-doc
        │
        ▼
실제 구현
        │
        ▼
/multi-review + /doc-audit
        │
        ▼
/pre-commit → /commit
```

### Flow B에서 기억할 점

- `rfp-ingest`는 **RFP 전체 일괄 처리용이 아니라 선택 SFR 분석용**이다.
- `rfp-ingest` 산출물의 화면 후보는 확정안이 아니라 **후보**다. 확정은 `design-doc` 또는 `design-prototype-docs`에서 한다.
- RFP 기반이라고 무조건 `impl-screen-doc`만 쓰는 건 아니다.
  - 화면 중심이면 `impl-screen-doc`
  - FE/BE 페어 Phase가 더 중요하면 `impl-fe-be-doc`
  - 실제 구현 대상이 내부 도구/배치라면 `impl-doc`

---

## 7. 구현 지침 3종 선택 기준

| 항목 | `impl-fe-be-doc` | `impl-screen-doc` | `impl-doc` |
|------|------------------|-------------------|------------|
| 중심 축 | FE/BE 역할 | 화면 | 기능/모듈 |
| Phase 단위 | BE+FE 페어 기능 | 화면 1개 | 입출력 파이프라인/모듈 |
| 태스크 ID | `INF-XX`, `BE-XX`, `FE-XX` | 화면 중심 통합 태스크(`SCR-XX` 개념) | `INIT`, `CORE`, `IO`, `TEST`, `PKG` |
| 적합 대상 | 일반 웹앱, FE/BE 담당 분리 | RFP/SFR 화면 구현, 1인 풀스택 | CLI, 스크립트, 서비스, 라이브러리 |
| 핵심 검증 | FE→API→DB 통합 | 화면 렌더링, 상태, API, 인터랙션 | 실행 명령, 입출력, 테스트, 패키징 |

### 빠른 선택 규칙

- "이 Phase가 끝나면 BE와 FE가 같이 살아 있어야 한다" → `impl-fe-be-doc`
- "이 화면 하나를 완성 단위로 보고 싶다" → `impl-screen-doc`
- "이건 화면이 아니라 도구/백엔드/자동화다" → `impl-doc`

---

## 8. 스킬 간 데이터 계약

현재 저장소의 핵심은 단순한 순서가 아니라 **산출물 연결 방식**이다.
아래 계약이 맞아야 다음 스킬이 흔들리지 않는다.

### 8-1. 핵심 연결도

```text
@RFP PDF
  └─→ /rfp-ingest
        └─→ rfp-design-input-{SFR}.md
                ├─→ /design-doc
                └─→ /design-prototype-docs

아이디어 / 기존 문서
  └─→ /design-doc
        └─→ OUTPUT_V2 설계 문서
                ├─→ /context-doc
                ├─→ /impl-fe-be-doc
                ├─→ /impl-screen-doc
                ├─→ /impl-doc
                └─→ /design-prototype-docs

/design-prototype-docs
  └─→ {PREFIX}-{번호}_목업디자인.md
        └─→ /create-prototype
              └─→ HTML / CSS / JSON 프로토타입

코드 변경
  └─→ /multi-review
  └─→ /doc-audit
  └─→ /pre-commit
  └─→ /commit

Agent 문서 / Skills 변경
  └─→ /agent-sync
```

### 8-2. `design-doc OUTPUT_V2`가 사실상 중심 허브다

`design-doc`는 현재 설계 체계의 중심이며, `OUTPUT_V2`가 가장 중요한 계약 문서다.

#### `context-doc`로 넘어가는 매핑

| `design-doc OUTPUT_V2` 섹션 | 사용처 |
|-----------------------------|--------|
| 01 개요, 05 데이터 설계, 06 파일 구성 | `CLAUDE.md`의 프로젝트 맥락 / 구조 |
| 02 동작 흐름, 07 라이브러리 및 외부 구성 | `CLAUDE.md`의 통신 규칙 / 기술 스택 |
| 03 집중 로직, 04 인터페이스 설계 | `basic-instruction.md`의 아키텍처 제약 |
| 10 주의사항, 12 열린 결정 사항 | `basic-instruction.md`의 금지/주의/미결 |

#### `impl-fe-be-doc`으로 넘어가는 매핑

| `design-doc OUTPUT_V2` 섹션 | 사용처 |
|-----------------------------|--------|
| 01 개요, 02 동작 흐름 | Phase 분할 기준 |
| 03 집중 로직 | 핵심 Phase의 상세 태스크 |
| 04 인터페이스 설계 | FE 태스크 지시 힌트 |
| 05 데이터 설계 | BE/DB 태스크 |
| 06 파일 구성 | `[NEW]` / `[MODIFY]` 범위 판단 |
| 10 주의사항, 12 열린 결정 사항 | 전역 주의사항 / 미결 사항 |

#### `impl-screen-doc`으로 넘어가는 매핑

- 화면 목록
- 화면 간 이동 흐름
- 화면별 대응 SFR
- 공통 컴포넌트 후보
- 화면별 API, 상태, 인터랙션 시나리오

#### `create-prototype`로 넘어가는 매핑

`design-prototype-docs` 산출물은 아래가 채워져 있어야 바로 연결된다.

- 요구사항 번호
- 화면 목록 테이블
- 화면 간 흐름 도식
- 화면별 기능 이유
- 레이아웃 구조
- 더미 데이터 예시
- 메인 색상

---

## 9. 품질 게이트와 운영 스킬의 역할

| 스킬 | 실행 시점 | 막아주는 문제 |
|------|-----------|---------------|
| `multi-review` | Phase/화면 구현 직후 | 보안, 성능, 유지보수, 테스트 누락 |
| `pre-commit` | 커밋 직전 | 빈 catch, 타임아웃 누락, 민감 정보, TODO 형식, 테스트 부재 |
| `code-comment` | 가독성 보완이 필요할 때 | 변경 파일 문맥 전달 실패 |
| `doc-audit` | 코드와 문서가 어긋난 느낌이 날 때 | 낡은 `CLAUDE.md`, 낡은 규칙 문서 |
| `agent-sync` | Agent 문서/스킬 변경 후 | 환경별 문서 불일치 |
| `commit` | 스테이징 후 | 메시지 품질 저하, 변경 이유 미정리 |

### 권장 게이트 순서

```text
구현 완료
  → multi-review
  → doc-audit (문서 영향이 있을 때)
  → pre-commit
  → code-comment (선택)
  → commit
```

### `pre-commit`가 실제로 보는 것

- 에러를 잡고 무시하는 패턴
- 외부 호출 타임아웃 누락
- 비밀번호/API 키/토큰 하드코딩
- 형식 없는 TODO/FIXME/HACK
- 비즈니스 로직 변경 대비 테스트 존재 여부

### `commit` 스킬 규칙

- description은 한글
- 50자 이내
- scope는 변경 파일/모듈 기준 추론
- body는 "무엇을"보다 "왜" 중심

---

## 10. 병렬화 전략

현재 저장소에서 병렬화 가치가 큰 스킬은 아래다.

| 스킬 | 병렬 단위 | 비고 |
|------|-----------|------|
| `rfp-ingest` | SFR별 | SFR이 2개 이상일 때 의미가 크다 |
| `create-prototype` | 화면별 | 사용자가 모델/개수 선택 |
| `multi-review` | 리뷰 관점 4개 | 가장 확실한 병렬 이득 |
| `doc-audit` | deps / pattern / rulecheck | 문서 괴리 분석 시간 단축 |
| `agent-sync` | Docs / Skills | 범위가 넓을수록 효과적 |
| `code-comment` | 파일별 | 변경 파일이 여러 개일 때만 |
| `skill-designer` | 테스트/비교 루프 | Claude Code 환경일수록 효과적 |

### 병렬화하지 않는 편이 좋은 것

- `design-doc`
- `context-doc`
- `impl-*` 본문 설계

이 셋은 순서와 맥락 일관성이 더 중요하다.

---

## 11. 훅(Hook) 전략

### 권장

| 훅 | 목적 | 이유 |
|----|------|------|
| 커밋 전 검사 훅 | `scan.sh` 또는 `/pre-commit` 리마인드 | 가장 자주 빠뜨리는 게 품질 검사다 |
| 세션 종료 리마인드 | 코드 변경 시 `/doc-audit` 권장 | 문서 괴리 누적 방지 |

### 비권장

| 자동화 | 비권장 이유 |
|--------|-------------|
| `design-doc` 완료 즉시 `context-doc` 자동 실행 | 설계 문서가 아직 흔들릴 수 있다 |
| `rfp-ingest` 완료 즉시 `design-doc` 자동 실행 | 제안 단계 목업 분기를 막는다 |
| 모든 커밋 뒤 강제 리뷰/감사 | 비용 대비 노이즈가 크다 |

핵심 원칙은 단순하다.

- **실수 예방용 자동화는 훅으로**
- **의사결정이 필요한 흐름 전환은 명시적 호출로**

---

## 12. 현재 저장소 기준 남아 있는 갭

### 12-1. 아직 없는 스킬

| 항목 | 우선순위 | 필요한 이유 |
|------|---------|-------------|
| `sfr-trace` | P0 | RFP 요구사항과 설계/구현/테스트 간 추적성 확보 |
| `rfp-compliance-review` | P0 | 납품 직전 요구사항 커버리지 점검 |
| `acceptance-test-doc` | P1 | SFR별 인수 기준 표준화 |
| `artifact-pack` | P2 | 납품 산출물 패키징 자동화 |

### 12-2. 문서 체계 갭

- `Docs Skills/설계문서_도출`는 `v4`까지 올라와 있지만,
- `Docs Skills/구현작업_지시서_도출`는 아직 `v1` 단일 구조다.

즉, 웹 AI용 설계 문서 체계는 최신화되어 있지만, 웹 AI용 구현 지침 체계는 Agent Skills의 `impl-* 3종`만큼 세분화되어 있지는 않다.

실무적으로는 아래처럼 운영하는 편이 낫다.

- 설계 인터뷰: 웹 AI 또는 `design-doc`
- 구현 지침: 가능하면 IDE Agent의 `impl-fe-be-doc` / `impl-screen-doc` / `impl-doc`

---

## 13. 바이브코딩 운영 원칙

### 13-1. 웹 AI와 IDE Agent는 역할이 다르다

| 상황 | 웹 AI가 강한 쪽 | IDE Agent가 강한 쪽 |
|------|------------------|----------------------|
| 긴 탐색 대화 | ✅ | △ |
| 설계 인터뷰 | ✅ | ✅ |
| 웹 검색이 필요한 기술 탐색 | ✅ | △ |
| 실제 파일 생성/수정 | △ | ✅ |
| 구현 지침 문서화 | △ | ✅ |
| 코드 리뷰, 커밋, 동기화 | △ | ✅ |

### 13-2. 대화 단위를 작게 유지한다

좋은 지시의 형태는 거의 항상 아래와 같다.

```text
[참조 문서]
- 설계문서: ...
- 작업지침서: ...
- CLAUDE.md / basic-instruction.md: ...

[이번 턴 범위]
- Phase 2의 BE-03만 구현
- 수정 파일은 A, B로 제한
- 다른 Phase/파일은 건드리지 말 것

[완료 기준]
- 검증 시나리오 1~3 통과 여부 보고
```

### 13-3. 문서를 한 번 만들고 끝내지 않는다

- 구현 중 설계가 바뀌면 문서도 바뀌어야 한다.
- 코드가 맞고 문서가 낡았으면 `doc-audit`로 괴리를 잡고,
- 승인 후 `agent-sync` 또는 직접 수정으로 문서를 맞춘다.

### 13-4. 컨텍스트가 오염되는 신호

아래가 보이면 새 대화로 갈아타는 편이 낫다.

- 이미 결정된 구조를 다시 묻기 시작한다.
- 금지한 패턴이 반복된다.
- 수정 범위를 자꾸 벗어난다.
- 설계 문서와 다른 계층 구조를 만들기 시작한다.

### 13-5. 반복 작업은 스킬화 후보다

같은 워크플로우를 세 번 이상 반복하면 `skill-designer` 후보로 본다.

- 반복 입력 형식이 고정돼 있고
- 출력 형식이 어느 정도 표준화돼 있고
- 사람의 판단 기준이 비교적 명확하면

스킬로 승격할 가치가 높다.

---

## 14. 자주 쓰는 런타임 치트시트

| 지금 상황 | 먼저 쓸 것 | 다음 선택지 |
|-----------|------------|-------------|
| 아이디어를 구조화하고 싶다 | `design-doc` | `context-doc`, `impl-*` |
| RFP의 특정 SFR만 풀고 싶다 | `rfp-ingest` | `design-doc` 또는 `design-prototype-docs` |
| 요구사항을 화면 설계 문서로 만들고 싶다 | `design-prototype-docs` | `create-prototype` |
| 실제 HTML 목업이 필요하다 | `create-prototype` | `frontend-design` 참고 |
| FE/BE Phase 순서를 정하고 싶다 | `impl-fe-be-doc` | 실제 구현 |
| 화면별 명세가 필요하다 | `impl-screen-doc` | `frontend-design`, 실제 구현 |
| 도구/스크립트 구현 계획이 필요하다 | `impl-doc` | 실제 구현 |
| 코드와 문서가 어긋난 것 같다 | `doc-audit` | 승인 후 `agent-sync` |
| 커밋 전 품질 점검이 필요하다 | `pre-commit` | `commit` |
| 코드 리뷰가 필요하다 | `multi-review` | 수정 후 재검토 |
| 반복 작업을 스킬로 만들고 싶다 | `skill-designer` | eval 루프 |

---

## 15. 빠른 운영 체크리스트

### 새 프로젝트 시작

- [ ] `design-doc`로 `OUTPUT_V2` 설계 문서를 만든다.
- [ ] 프로젝트 단위면 `context-doc`로 `CLAUDE.md`와 `basic-instruction.md`를 만든다.
- [ ] 구현 단위에 맞는 `impl-*` 1종을 고른다.
- [ ] 화면 불확실성이 크면 `design-prototype-docs → create-prototype`을 먼저 돌린다.

### 새 화면/기능 추가

- [ ] 화면/기능/로직 중 스케일을 먼저 정한다.
- [ ] 기존 설계 문서에 붙일지, 새 설계를 만들지 결정한다.
- [ ] 화면 중심이면 `impl-screen-doc`, FE/BE 페어면 `impl-fe-be-doc`, 범용이면 `impl-doc`.
- [ ] UI 감도가 중요하면 `frontend-design` 기준을 같이 적용한다.

### 구현 완료 직후

- [ ] `multi-review`
- [ ] 필요 시 `doc-audit`
- [ ] `pre-commit`
- [ ] 필요 시 `code-comment`
- [ ] `commit`

### Agent가 이상한 방향으로 갈 때

- [ ] 바로 멈춘다.
- [ ] 이번 턴 범위를 다시 좁힌다.
- [ ] 참조 문서와 수정 파일 범위를 다시 명시한다.
- [ ] 문서가 낡았다면 `doc-audit`를 먼저 돌린다.
- [ ] 같은 문제가 반복되면 `basic-instruction.md`에 금지 패턴을 보강한다.

---

## 16. 한 줄 결론

현재 저장소의 최신 하네스는 아래 한 줄로 요약된다.

> `rfp-ingest` 또는 `design-doc`로 시작해서, `OUTPUT_V2`를 중심 허브로 삼고, 상황에 맞는 `impl-*` 하나로 구현 단위를 고른 뒤, `multi-review`·`pre-commit`·`doc-audit`로 품질을 닫는 구조다.

이 흐름만 지켜도 "바이브코딩"이 즉흥 코딩이 아니라 **문서 중심의 반복 가능한 생산 체계**로 바뀐다.
