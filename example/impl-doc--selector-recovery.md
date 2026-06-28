<!-- 산출물 예시 메타 -->
> 📂 **산출물 예시 — `impl-doc` 스킬**
> 산출 경로: `.docs/impl-doc/{사용자}/selector-recovery.md` (단일 앱) · 복수 앱이면 `.docs/{앱}/impl-doc/{사용자}/selector-recovery.md`
> 단일·소규모 범용 기능(여기서는 BE 단일 도메인 기능)에 대한 작업지침서 예시입니다. FE/BE 페어 다중 기능은 `impl-fe-be-doc--ACRO.md`를 참고하세요. impl-doc은 `INIT/CORE/IO/TEST/PKG` 계열 태스크 ID를 씁니다.

---

# 구현 작업지침서: ACRO 셀렉터 자동 복구 모듈

> 생성 스킬: impl-doc
> 프로젝트 유형: BE 단일 기능 (AI 도메인 모듈)
> 설계 문서: `design-doc--ACRO-BE.md` (§AI 에이전트 역할 / §DB 테이블 설계)
> 작성일: 2026-06-28
> 기술 스택: Python · FastAPI · LangGraph · LangChain · SQLAlchemy(async) · PostgreSQL

이 모듈은 매크로 실행 중 저장된 셀렉터가 더 이상 매칭되지 않을 때, DOM 스냅샷을 비교해 변경을 감지하고 LangGraph 에이전트로 셀렉터를 자동 보정한다. 온보딩/매크로 실행 흐름과 분리된 독립 도메인 기능이므로 단일 작업지침서로 다룬다.

---

## 전역 주의사항

- **LLM 비결정성** — 에이전트가 추론한 셀렉터는 반드시 실제 DOM에서 `query_selector` 매칭으로 검증한 뒤에만 DB에 반영한다. 미검증 셀렉터 저장 금지.
- **외부 호출 타임아웃** — Ollama 추론 호출에는 타임아웃(기본 30s)과 1회 재시도를 둔다. 무한 대기 금지.
- **DB 직접 쓰기 경계** — `ai/` 모듈은 DB에 직접 쓰지 않는다. 보정 결과는 `db/` 리포지토리 함수를 통해서만 반영한다(설계 문서 모듈 책임 규칙 준수).
- **원본 셀렉터 보존** — 보정 시 기존 셀렉터를 덮어쓰지 않고 버전 이력으로 남긴다(롤백 가능).

---

## 미결 사항

| # | 항목 | 영향 범위 | 결정 시한 |
|---|------|----------|----------|
| 1 | 보정 실패 N회 후 정책(매크로 중단 vs 사용자 재온보딩 요청) | IO-01 | Phase 2 시작 전 |
| 2 | 스냅샷 보관 주기(매 실행 vs 변경 시) | CORE-01 | Phase 1 시작 전 |

---

## Phase 1 — 변경 감지 코어

**목표**: 저장된 셀렉터가 깨졌는지 판단하고, 깨졌다면 무엇이 바뀌었는지 진단 데이터를 만든다.

### [CORE-01] · DOM 스냅샷 비교기 (`ai/detector.py`)

**의존** : 없음

이전 실행 시 저장한 HTML 스냅샷과 현재 페이지 HTML을 `difflib`로 비교해 변경 영역을 추출한다. 셀렉터별로 "여전히 매칭됨 / 사라짐 / 후보 이동" 상태를 분류한다.

**Agent 지시** :
- 입력: `site_name`, `current_html`, `stored_selectors: list[SelectorRecord]`
- 출력: `DetectionResult(broken: list[SelectorRecord], diff_summary: str)`
- 순수 함수로 작성(DB·네트워크 접근 금지). 비교는 텍스트·구조 기준 모두 사용.

**검증 기준** : 동일 HTML 입력 시 `broken == []`, 변경된 HTML 입력 시 깨진 셀렉터만 정확히 분류(단위 테스트 3케이스: 무변경/속성변경/노드삭제).

### [CORE-02] · 보정 에이전트 그래프 (`ai/agent.py`)

**의존** : CORE-01

`DetectionResult.broken`을 입력으로 받아, LangGraph 그래프(추론 → 후보 생성 → 검증 → 종료)로 새 셀렉터 후보를 생성한다.

**Agent 지시** :
- 노드: `infer`(요소 의미 추론) → `propose`(셀렉터 후보) → `verify`(현재 DOM에서 매칭 확인) → 매칭 실패 시 `propose`로 1회 루프.
- LLM 호출은 `ai/chain.py`의 추상화를 사용(모델 직접 호출 금지).
- 출력: `RecoveryResult(fixed: dict[old_selector, new_selector], unresolved: list)`

**검증 기준** : 변경된 모의 사이트(MOCK-TRAIN)에서 최소 1개 깨진 셀렉터가 검증 통과한 새 셀렉터로 보정됨.

---

### Phase 1 통합 검증

**시나리오**: 모의 사이트 DOM을 변경한 뒤 감지→보정이 동작하는지 확인한다.

1. MOCK-TRAIN 사이트에서 정상 스냅샷 1회 저장
2. 입력칸 `id`를 변경한 변형 HTML 로드
3. `detector` → `agent` 순차 실행

**합격 조건** : 깨진 셀렉터가 `broken`으로 분류됨 ✅ / 보정된 셀렉터가 현재 DOM에서 매칭됨 ✅ / DB에는 아직 반영되지 않음(다음 Phase) ✅

---

## Phase 2 — 반영·연동

**목표**: 보정 결과를 안전하게 저장하고 매크로 실행 흐름에 연결한다.

### [IO-01] · 셀렉터 버전 리포지토리 (`db/selector_repo.py`)

**의존** : CORE-02

보정된 셀렉터를 새 버전으로 저장하고, 이전 버전은 `is_active=False`로 비활성화한다. 롤백용 조회 함수 포함.

**Agent 지시** :
- `save_recovered(site_name, fixed: dict) -> None` (트랜잭션 처리)
- `rollback(site_name, selector_key) -> SelectorRecord`
- 기존 행 UPDATE 대신 INSERT + 플래그 전환(이력 보존).

**검증 기준** : 보정 저장 후 활성 셀렉터가 새 값, 직전 값은 비활성으로 조회됨. 롤백 시 직전 값이 다시 활성화됨.

### [API-01] · 매크로 실행 훅 연동 (`macro/runner.py` 수정)

**의존** : IO-01

매크로 실행 중 셀렉터 매칭 실패가 감지되면 복구 모듈을 호출하고, 성공 시 보정된 셀렉터로 재시도한다.

**Agent 지시** :
- 매칭 실패 → `detector` → `agent` → `selector_repo.save_recovered` → 1회 재시도.
- 미결 사항 #1 정책에 따라 N회 실패 시 분기. WebSocket으로 진행 상태 전송.

**검증 기준** : 실행 중 셀렉터를 깨뜨린 시나리오에서 매크로가 중단 없이 보정 후 예약 단계를 계속 진행.

---

### Phase 2 통합 검증

**시나리오**: 매크로 실행 도중 DOM 변경 → 자동 복구 → 예약 계속.

1. MOCK-TRAIN에서 매크로 실행 시작
2. 실행 중간에 대상 요소 셀렉터를 변경
3. 복구 동작과 재시도 관찰

**합격 조건** : 매크로가 실패로 종료되지 않음 ✅ / 보정 이력이 DB에 1건 기록됨 ✅ / WebSocket으로 "셀렉터 자동 복구됨" 로그 수신 ✅

---

## Phase 3 — 검증·패키징

### [TEST-01] · 회귀 테스트 (`tests/test_selector_recovery.py`)

**의존** : Phase 2 전체

감지·보정·저장·롤백 4단계 회귀 테스트. LLM 호출은 고정 응답으로 모킹.

**검증 기준** : `pytest tests/test_selector_recovery.py` 전부 통과, 커버리지 80% 이상.

### [PKG-01] · 모듈 공개 인터페이스 정리 (`ai/__init__.py`)

**의존** : TEST-01

외부(매크로 모듈)에서 쓰는 진입 함수만 노출하고 내부 노드 구현은 감춘다.

**검증 기준** : `from ai import recover_selectors` 한 줄로 사용 가능, 내부 심볼 비노출.

---

## 태스크 의존 관계 요약

```text
CORE-01 (감지기)
  └─→ CORE-02 (보정 에이전트)
        └─→ IO-01 (버전 리포지토리)
              └─→ API-01 (매크로 훅 연동)
                    └─→ TEST-01 (회귀 테스트)
                          └─→ PKG-01 (공개 인터페이스)
```
