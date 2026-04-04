# Repository Generalization Review

> 대상 레포: `AI_Agent_docs`
> 기준 문서: `README.md`, `Harness_Engineering_v2.md`, `Harness_Engineering_Intro.md`, `Agent Skills/*/SKILL.md`, 핵심 `prompts/` 및 `templates/`

---

## 1. 한 줄 총평

이 레포는 `아이디어만 있는 경우`, `RFP/SFR가 있는 경우`, `문서 없는 기존 코드베이스`까지 3개 진입점을 갖춘 점에서 설계 방향은 좋다.
특히 `harness-bootstrap` + `context-doc` + `impl-doc` 축은 범용성이 높다.

다만 현재 상태를 "제안요청서 유무와 무관하게, 모든 프레임워크와 아키텍처에 유연하게 대응하는 완전 범용 하네스"라고 보기는 어렵다.
실제 성격은 `웹앱 / 화면 / RFP-SFR / AI Agent 문서화` 쪽으로 강하게 최적화된 범용형에 가깝다.

---

## 2. 기준별 평가

### 2-1. 제안요청서 문서가 있든 없든 잘 적용 가능한가

**판정: 부분 충족**

- `RFP 있음` 경로는 `rfp-ingest -> design-doc -> context-doc / impl-*`로 비교적 명확하다.
- `RFP 없음` 경로는 `design-doc` 단독 진입이 가능하다.
- `문서 없는 기존 코드베이스` 경로는 `harness-bootstrap`으로 별도 진입점을 제공한다.

좋은 점:

- 문서 유무에 따른 진입점이 분리되어 있다.
- `harness-bootstrap`이 기존 코드 스캔 + 최소 인터뷰를 통해 설계 문서와 컨텍스트 문서를 역추출하도록 설계되어 있다.

한계:

- `rfp-ingest`는 현재 회사의 주요 진입점인 `RFP/SFR` 흐름에 잘 맞게 최적화되어 있다.
- 현재 구조는 요구사항을 빠르게 화면 후보와 설계 입력으로 연결하는 데 강점이 있다.
- 향후 적용 범위를 더 넓힐 계획이 있다면 `REQ`, `FR`, `UC`, user story, epic, 표가 아닌 본문형 요구사항까지 수용하는 방향으로 확장 여지는 있다.
- `rfp-ingest`는 기본적으로 요구사항을 `화면 후보`로 매핑하는 사고가 강해 비화면 deliverable에는 덜 맞는다.

---

### 2-2. 두 경우가 잘 가이드 및 연계되는가

**판정: 개념적으로 좋음, 운영 문구는 불일치 존재**

좋은 점:

- `Harness_Engineering_v2.md`는 `design-doc OUTPUT_V2`를 중심 허브로 놓고 `context-doc`, `impl-fe-be-doc`, `impl-screen-doc`, `impl-doc`, `design-prototype-docs`로 이어지는 데이터 계약을 비교적 잘 설명한다.
- 전체 플로우 관점에서는 `아이디어 기반`, `RFP 기반`, `레거시 부트스트랩`이 하나의 하네스로 수렴하도록 설계돼 있다.

문제점:

- `design-doc`의 다운스트림 설명이 현재 구조와 맞지 않는다.
  - `context-doc -> CLAUDE.md + .instruction/basic-instruction.md`라고 적혀 있는데, 실제 현재 구조는 `basic-instruction.md`가 아니라 주제별 `*-instruction.md` 분할 구조다.
  - `impl-doc -> FE/BE 페어 작업지침서`라고 적혀 있는데, FE/BE 페어는 실제로 `impl-fe-be-doc`의 책임이다.
- `impl-fe-be-doc`의 제목 줄도 `# 작업지침서 생성 (impl-doc)`로 잘못 표기되어 있다.
- `Harness_Engineering_Intro.md`, `Harness_Engineering_v2.md`에는 여전히 `basic-instruction.md` 같은 예전 구조 표현이 남아 있다.

즉, 큰 흐름은 좋지만 현재는 문서 간 드리프트가 존재한다.

---

### 2-3. 프레임워크와 무관하게 모두 범용적으로 적용되는가

**판정: 핵심 축은 좋음, 전체로 보면 부분 충족**

좋은 점:

- `harness-bootstrap`의 `stack-detection.md`는 Node.js, Python, JVM, Rust, Go, PHP, Ruby, .NET, Flutter, Deno, Bun까지 탐지 대상을 넓게 잡고 있다.
- `context-doc`는 "프레임워크를 하드코딩하지 않는다"는 원칙을 명시하고, 설계 문서에 등장한 라이브러리와 주제만 반영하도록 설계돼 있다.
- `impl-doc`는 CLI, 스크립트, 라이브러리, 단독 백엔드, ETL, AI Agent 도구, 인프라 자동화까지 수용하도록 설계돼 있다.

한계:

- `design-doc`의 인터뷰와 템플릿은 실제로는 `Frontend / Backend / DB / AI / 배포` 구성을 기본 전제로 한다.
- `OUTPUT_V2`의 `07 라이브러리`는 `백엔드 / 프론트엔드 / 외부 구성` 구조라 웹 중심 분류가 강하다.
- `design-prototype-docs`, `create-prototype`, `frontend-design`은 사실상 웹 UI 전용 스킬이다.
- `impl-screen-doc`도 RFP/SFR 화면 중심 설계에 강하게 최적화돼 있다.

즉, Spring Boot, Next.js, FastAPI, .NET 같은 프레임워크 이름 수준에서는 어느 정도 대응 가능하지만, 레포 전체가 완전한 프레임워크 무차별 범용 구조라고 보기는 어렵다.

---

### 2-4. 일부 아키텍처에 종속적이지 않은가

**판정: 아직 부족**

현재 레포는 `프레임워크 중립` 쪽으로는 노력하고 있지만, `아키텍처 중립`까지는 도달하지 못했다.

주요 이유:

- `design-doc` 인터뷰 축이 `문제/목적/사용자/범위/동작 흐름/기술 스택/핵심 로직` 중심이라,
  - 이벤트 기반 아키텍처
  - 메시지 브로커 중심 시스템
  - 데이터 파이프라인
  - 멀티테넌트 SaaS
  - 규제/감사 추적 시스템
  - 관측성/운영성이 핵심인 플랫폼
  같은 아키텍처를 구조적으로 끌어내는 질문이 약하다.
- 비기능 요구사항이 핵심 인터뷰의 1급 축이 아니라 보조 수준에 머문다.
- 보안, 성능, 운영 제약, 관측성, 롤백, 마이그레이션, 컴플라이언스, 권한 모델, 데이터 보존 정책 같은 항목이 OUTPUT의 독립 축으로 충분히 강조되지 않는다.
- RFP 경로에서도 비기능 요구는 `clarification.md`에서 `P2`에 가깝게 다뤄진다.

결론적으로 현재 구조는 `웹 서비스/업무 시스템` 계열에는 강하지만, 모든 아키텍처에 비종속적이라고 말하기는 어렵다.

---

## 3. 인터뷰 유연성 평가

### 장점

- `design-doc`는 스케일 라우팅을 두고 `프로젝트 전체 / 기능 / 화면 / 컴포넌트`를 나누려는 방향이 있다.
- `harness-bootstrap`은 코드에서 알 수 없는 것만 최소 질문하는 원칙이 명확하다.
- `context-doc`는 질문 예산을 제한해서 불필요한 확인을 줄이려 한다.
- `rfp-ingest`는 불명확 항목을 다음 단계로 넘기지 않고 이 단계에서 해결하려는 점이 좋다.

### 한계

- 가장 큰 문제는 `design-doc`의 실제 시작 분기다.
  - `SKILL.md` Step 1에서는 스케일 질문이 `1) 화면 단위 2) 기능 단위 3) 컴포넌트/로직 단위`만 제시된다.
  - 그러나 `scale-routing.md`와 `INPUT_V2.md`는 `프로젝트 전체`를 명시적으로 지원한다.
  - 즉, 설계 허브가 가장 중요한 분기에서 자기 문서와 충돌한다.
- 인터뷰 질문이 좋은 제품 디스커버리에는 적절하지만, 복잡한 시스템 설계 인터뷰로는 부족하다.
- 특히 아래 항목을 체계적으로 캐는 구간이 약하다.
  - 권한 모델
  - 보안/컴플라이언스
  - 데이터 수명주기
  - 마이그레이션 전략
  - 장애/복구
  - 관측성
  - 성능/용량
  - 멀티 서비스 경계
  - 비동기/이벤트 흐름

즉, "질문을 통해 모든 상황에 유연하게 대처"까지는 아직 아니다.
현재는 "웹앱/기능 설계 중심 인터뷰"로 보는 편이 정확하다.

---

## 4. 핵심 강점

### 4-1. 하네스 사고방식 자체는 좋다

- `설계 문서 -> 컨텍스트 문서 -> 구현 지침 -> 리뷰/검사/커밋`이라는 체인 설계가 명확하다.
- 즉흥 프롬프트보다 구조화된 문서 계약을 우선시하는 철학은 타당하다.

### 4-2. bootstrap 축이 강하다

- `harness-bootstrap`은 이 레포에서 가장 실전적인 자산 중 하나다.
- 문서 없는 기존 코드베이스에 하네스를 이식할 수 있다는 점은 큰 장점이다.

### 4-3. context-doc의 분할 전략이 좋다

- 얇은 `CLAUDE.md` + 주제별 `.instruction/*` 구조는 유지보수성과 토큰 효율 측면에서 합리적이다.
- 설계 문서에 없는 주제를 억지로 만들지 않는 원칙도 좋다.

### 4-4. impl-doc이 범용성을 받쳐준다

- 레포 전체가 웹 편향이 있긴 하지만, `impl-doc`은 그 편향을 완화하는 핵심 스킬이다.

### 4-5. skill-design 지식이 실제 레포에 잘 반영된 부분이 있다

- 질문 예산 제한
- 조건부 로드
- prompts 분리
- 연계 구조 명시
- 템플릿 기반 출력

이런 부분은 스킬 설계 관점에서 좋은 습관이다.

---

## 5. 주요 문제점 상세

### 5-1. design-doc가 실제 허브인데 가장 중요하게 보강돼야 한다

현재 레포의 품질은 거의 전적으로 `design-doc` 품질에 달려 있다.
그런데 지금 `design-doc`는 아래 문제가 있다.

1. 프로젝트 전체 분기 질문 누락
2. 다운스트림 설명 불일치
3. 인터뷰가 웹앱/기능 설계 중심
4. 비기능 설계 축 부족
5. OUTPUT_V2가 아키텍처 다양성을 충분히 수용하지 못함

즉, 허브 스킬이 아직 가장 범용적인 상태는 아니다.

### 5-2. 문서 간 용어 드리프트가 있다

대표 사례:

- `basic-instruction.md` 언급 잔존
- `impl-doc`와 `impl-fe-be-doc` 설명 혼선
- `skill-design` 디렉토리 vs `skill-designer` 이름 이중 구조

이런 드리프트는 사람보다 AI Agent에게 더 치명적이다.
Agent는 최신 구조보다 문서 문구를 그대로 신뢰하는 경향이 있기 때문이다.

### 5-3. 범용이라는 말에 비해 UI 축이 강하다

다음 스킬들은 사실상 웹 UI 전용이다.

- `design-prototype-docs`
- `create-prototype`
- `frontend-design`
- `impl-screen-doc`

이 자체는 문제가 아니다.
문제는 레포 전체 설명에서 이 편향을 명확히 구분하지 않으면 "전체가 범용"처럼 보이기 쉽다는 점이다.

### 5-4. skill-design 원칙과 실제 스킬 구현 사이에 괴리가 있다

`Docs Skills/스킬_도출/skill-design-guide.md`는

- SKILL.md는 흐름만 담고
- How는 prompts에 두고
- 중복을 없애라고 명시한다.

하지만 실제 핵심 스킬들은 SKILL.md 안에 상세 규칙을 많이 중복 서술한다.
이 때문에 시간이 지나면 문서 드리프트가 생기기 쉽다.

---

## 6. 우선순위별 개선 제안

### 1순위 — design-doc 재설계

가장 먼저 고칠 것:

1. 시작 스케일 질문에 `프로젝트 전체` 복원
2. 첫 분기에서 스케일뿐 아니라 `아키텍처 유형`도 받기
   - 웹앱
   - 단독 API/백엔드
   - CLI/자동화
   - 라이브러리/SDK
   - 데이터 파이프라인
   - 이벤트/메시지 기반 시스템
   - 인프라/플랫폼
3. 인터뷰에 비기능 설계 축 추가
   - 보안/권한
   - 성능/용량
   - 장애/복구
   - 관측성
   - 운영 제약
   - 데이터 정책
4. OUTPUT_V2를 `FE/BE` 중심이 아니라 `시스템 유형별 가변 섹션` 구조로 바꾸기

### 2순위 — 문서 드리프트 제거

우선 정리 대상:

- `basic-instruction.md` 언급 제거
- `design-doc` 다운스트림 표 수정
- `impl-fe-be-doc` 제목 오기 수정
- `README.md`, `Harness_Engineering_Intro.md`, `Harness_Engineering_v2.md` 표현 통일

### 3순위 — 스킬 트리거 정리

지금은 아래 트리거가 겹친다.

- `create-prototype`
- `design-prototype-docs`
- `frontend-design`

트리거 충돌을 줄이려면:

- 문서 생성
- 목업 생성
- 실제 프론트 구현

세 단계를 description에서 더 강하게 분리해야 한다.

### 4순위 — 비웹 샘플로 forward-test

진짜 범용성을 확인하려면 아래 같은 샘플로 검증해야 한다.

1. .NET 백엔드 API
2. Spring Boot 이벤트 기반 서비스
3. FastAPI 배치 + 워커
4. CLI 도구
5. ETL 파이프라인
6. Terraform 기반 인프라 자동화

현재는 웹앱 중심 성공 가능성이 높고, 비웹/비화면 계열 검증 흔적은 약하다.

### 선택 과제 — RFP intake 확장

현재 회사의 주 진입점인 `RFP/SFR` 흐름에는 잘 맞는다.
따라서 이것 자체를 약점으로 볼 필요는 없다.

다만 향후 적용 범위를 더 넓힐 계획이 있다면 아래까지 확장하는 선택지는 있다.

- SFR / FR / REQ / UC / Epic / User Story
- 표형 요구사항 문서
- 본문형 요구사항 문서
- 화면 중심 요구사항
- 비화면 중심 요구사항

또한 로컬 경로 가정 같은 환경 종속 문구는 필요 시 제거하는 편이 낫다.

---

## 7. 최종 결론

이 레포는 `범용 하네스`로 가는 방향은 맞다.
특히 하네스 사고방식, bootstrap 전략, context 분할 전략, impl-doc 축은 강점이 분명하다.

하지만 현재 시점에서의 정확한 평가는 아래가 적절하다.

> "웹 서비스/업무 시스템 중심 조직에 바로 도입 가능한 하네스 초안"
> 
> "모든 제안요청서/모든 프레임워크/모든 아키텍처를 인터뷰만으로 유연하게 다루는 완성형 범용 하네스"는 아직 아님

핵심은 `프레임워크 중립`과 `아키텍처 중립`을 구분하는 것이다.
현재 레포는 전자에 꽤 근접했지만, 후자는 아직 보강 여지가 크다.

---

## 8. 참고한 핵심 근거 파일

- `README.md`
- `Harness_Engineering_Intro.md`
- `Harness_Engineering_v2.md`
- `Agent Skills/design-doc/SKILL.md`
- `Agent Skills/design-doc/prompts/interview.md`
- `Agent Skills/design-doc/prompts/scale-routing.md`
- `Agent Skills/design-doc/templates/INPUT_V2.md`
- `Agent Skills/design-doc/templates/OUTPUT_V2.md`
- `Agent Skills/rfp-ingest/SKILL.md`
- `Agent Skills/rfp-ingest/prompts/clarification.md`
- `Agent Skills/context-doc/SKILL.md`
- `Agent Skills/harness-bootstrap/SKILL.md`
- `Agent Skills/harness-bootstrap/prompts/stack-detection.md`
- `Agent Skills/impl-fe-be-doc/SKILL.md`
- `Agent Skills/impl-doc/SKILL.md`
- `Agent Skills/design-prototype-docs/SKILL.md`
- `Agent Skills/create-prototype/SKILL.md`
- `Agent Skills/frontend-design/SKILL.md`
- `Docs Skills/스킬_도출/skill-design-guide.md`
