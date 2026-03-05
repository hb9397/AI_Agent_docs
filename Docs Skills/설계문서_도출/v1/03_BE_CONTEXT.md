# 03_BE_CONTEXT.md
# Backend AI Agent — Context & Instruction

> **이 파일을 읽는 대상:** 백엔드 코드를 작성하는 AI Agent
>
> **읽는 방법:**
> 1. SECTION 0 (역할과 규칙) 를 먼저 읽고 숙지
> 2. SECTION 1~4 를 읽어 전체 맥락 파악
> 3. SECTION 5 (현재 태스크) 를 보고 작업 시작
> 4. 모르거나 결정이 필요하면 SECTION 6 (판단 기준) 를 참고
> 5. 작업 완료 후 SECTION 7 (완료 체크리스트) 확인

---

## SECTION 0 — 역할과 규칙

### 이 Agent의 역할
```
(예시)
- REST API 서버 구현
- DB 스키마 설계 및 마이그레이션
- 자동화 엔진 로직 구현
```

### 절대 하지 말 것
```
- FE 컴포넌트 코드 작성 (FE_CONTEXT 담당)
- API 계약(경로, 요청/응답 형식) 임의 변경
- 02_SPEC.md의 "Won't" 항목 구현
```

### 판단이 필요할 때
```
1. 먼저 02_SPEC.md의 "열린 결정 사항" 확인
2. 거기도 없으면 → 코드에 TODO 주석 남기고 계속 진행
3. 사람에게 물어봐야 할 것은 응답 마지막에 [QUESTION] 으로 모아서 출력
```

---

## SECTION 1 — 프로젝트 맥락 요약

```
(02_SPEC.md 에서 복사)
- 프로젝트명:
- 목적:
- 대상 사용자:
- 실행 환경:
```

---

## SECTION 2 — BE 담당 기능

### 구현할 기능 (02_SPEC.md Must 중 BE 담당)
| # | 기능명 | 설명 | 우선순위 |
|---|--------|------|----------|
| | | | High / Mid / Low |

### 구현하지 않는 기능
```
- (02_SPEC.md Won't 항목 그대로)
```

---

## SECTION 3 — 데이터 모델 (상세)

```
(02_SPEC.md 데이터 모델을 BE 관점에서 확장)

Table: [테이블명]
  - id: UUID, PK
  - created_at: TIMESTAMP
  - (필드 추가)

인덱스:
  - (성능상 필요한 인덱스)

관계:
  - [테이블A] 1 ---- N [테이블B]
```

---

## SECTION 4 — API 명세 (BE 구현 기준)

> 02_SPEC.md의 API 인터페이스를 BE 구현 관점에서 상세화

### [기능명] API

**`POST /api/[경로]`**

Request:
```json
{
  "field": "type — 설명"
}
```

Response (200):
```json
{
  "field": "type — 설명"
}
```

Error:
| 코드 | 상황 |
|------|------|
| 400 | |
| 401 | |
| 500 | |

---

## SECTION 5 — 현재 태스크

> 사람이 작업 시작 전에 이 칸을 채워서 Agent에게 넘김

### 지금 구현할 것
```
(예시)
1. /api/sites POST 엔드포인트 구현
2. Site 테이블 스키마 및 마이그레이션 파일 생성
```

### 참고할 기존 코드
```
(있으면 경로 명시)
- src/models/user.py → 이 패턴으로 작성
```

### 완료 기준
```
- 단위 테스트 통과
- API 응답이 SECTION 4 명세와 일치
```

---

## SECTION 6 — 코딩 규칙

```
- 언어 / 런타임:
- 패키지 매니저:
- 폴더 구조:
  src/
    routes/
    models/
    services/
    tests/
- 에러 핸들링: (예: 모든 에러는 {"error": "message"} 형태로)
- 로깅: (예: structlog 사용, JSON 형태)
- 테스트: (예: pytest, 핵심 로직은 반드시 테스트 작성)
```

---

## SECTION 7 — 완료 체크리스트

작업 완료 후 확인:
- [ ] 구현한 API가 SECTION 4 명세와 일치하는가?
- [ ] 에러 케이스가 처리되어 있는가?
- [ ] TODO 주석이 있으면 SECTION 0의 [QUESTION] 으로 올렸는가?
- [ ] 새로 생긴 결정 사항을 02_SPEC.md "열린 결정 사항"에 추가했는가?
