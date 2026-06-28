<!-- 산출물 예시 메타 -->
> 📂 **산출물 예시 — `context-doc` 스킬 (instruction)**  
> 산출 경로: `.docs/instruction/architecture-instruction.md` (복수 앱은 `.docs/{앱}/instruction/architecture-instruction.md`)  
> context-doc는 설계 문서를 주제별 instruction 파일 7종(`architecture`/`code-style`/`framework`/`api`/`comm`/`file-convention`/`agent`)으로 분할 생성합니다. 이 문서는 그중 아키텍처·코딩 규칙(`architecture-instruction.md`) 예시입니다.

---

# architecture-instruction.md — ACRO Backend 아키텍처·코딩 규칙

> ACRO Backend (Python + FastAPI + SQLAlchemy async + PostgreSQL) 개발 시 반드시 준수해야 할 규칙

---

## 아키텍처 규칙

- **모듈 분리 원칙 엄수** — 하나의 모듈은 하나의 책임만 담당

| 모듈 | 책임 | 금지 |
|---|---|---|
| `onboarding/` | 브라우저 실행, 클릭 캡처, 세션 저장 | 매크로 실행 로직 |
| `crawler/` | HTML 수집, DOM 파싱 | DB 직접 쓰기 |
| `macro/` | Playwright 자동 예약 실행 | AI 직접 호출 |
| `ai/` | LangGraph 에이전트, LangChain 체인 | DB 직접 쓰기 |
| `db/` | SQLAlchemy 모델, 연결 설정 | 비즈니스 로직 |

- **라우터 도메인별 분리 원칙** — API 엔드포인트는 도메인별(예: `sites`, `onboarding`, `macro`)로 개별 파일(예: `routers/site.py` 또는 각 역할 모듈 내 `router.py`)에 분리하고, `main.py`에서는 `app.include_router()`만 호출
- **`main.py`에는 라우터 등록과 WebSocket만** — 비즈니스 로직 직접 작성 금지

위반 시:
1. 위반 내용 명시
2. 올바른 라우터 파일 또는 모듈로 이동시킨 코드 제안

---

## FastAPI 규칙

- **모든 라우터 함수는 `async def`** — sync 함수 사용 금지 (uvicorn ASGI 서버 특성상 블로킹 발생)
- **응답 모델은 Pydantic BaseModel 필수** — `dict` 반환 금지
- **의존성 주입(`Depends`)으로 DB 세션 전달** — 라우터 내에서 직접 DB 연결 생성 금지
- **HTTPException으로 에러 처리** — 일반 `raise Exception` 금지

```python
# ✅ 올바른 패턴
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from db.database import get_db

router = APIRouter()

@router.get("/sites", response_model=list[SiteResponse])
async def get_sites(db: AsyncSession = Depends(get_db)):
    ...

# ❌ 금지
@router.get("/sites")
def get_sites():  # sync 함수 금지
    return {"data": []}  # dict 반환 금지
```

---

## DB 규칙 (SQLAlchemy async + PostgreSQL)

- **모든 DB 쿼리는 `async` / `await` 사용** — sync session 사용 금지
- **`site_name`이 모든 테이블의 파티셔닝 키** — 다른 사이트의 데이터가 섞이지 않도록 쿼리 시 항상 `WHERE site_name = ?` 포함
- **직접 SQL 문자열 작성 금지** — SQLAlchemy ORM 또는 `select()` 빌더 사용
- **트랜잭션은 `async with session.begin()`** 또는 `@router`에서 `Depends`로 관리

```python
# ✅ 올바른 패턴
from sqlalchemy import select
from db.models import Selector

result = await db.execute(
    select(Selector)
    .where(Selector.site_name == site_name)
    .where(Selector.is_active == True)
    .order_by(Selector.element_order)
)
selectors = result.scalars().all()

# ❌ 금지
result = await db.execute(f"SELECT * FROM selectors WHERE site_name='{site_name}'")  # SQL Injection 위험
```

---

## Playwright 규칙

- **`playwright-stealth`는 `goto()` 이전에 반드시 적용**

```python
from playwright_stealth import stealth_async

page = await context.new_page()
await stealth_async(page)        # ← 반드시 goto 전에
await page.goto(url)
```

- **Docker 환경에서 `headless=False` 실행 시 `DISPLAY=:99` 환경변수 필수** — Xvfb 가상 모니터에 렌더링
- **browser / context / page는 `try/finally`로 반드시 닫기** — 리소스 누수 방지
- **`playwright install chromium`은 Docker 이미지 빌드 시 실행** — 런타임 설치 금지

```python
# ✅ 올바른 패턴
async def run_with_browser():
    playwright = await async_playwright().start()
    browser = await playwright.chromium.launch(
        headless=False,
        args=["--no-sandbox"]   # Docker 필수
    )
    try:
        context = await browser.new_context()
        page = await context.new_page()
        await stealth_async(page)
        # ... 작업
    finally:
        await browser.close()
        await playwright.stop()
```

---

## AI (LangGraph / LangChain) 규칙

- **LangGraph 노드는 단일 책임** — 하나의 노드가 "분석 + 판단 + 수정"을 동시에 수행 금지

| 노드 | 담당 |
|---|---|
| `detect_change` | difflib로 HTML 비교만 |
| `analyze_html` | LangChain으로 변경 내용 분석만 |
| `judge_severity` | 단순 변경 vs 구조 변경 판단만 |
| `auto_fix` | DB 자동 수정만 |
| `notify_human` | FE WebSocket 알림만 |

- **Ollama 호스트는 환경변수로** — `os.environ["OLLAMA_HOST"]` 사용, 하드코딩 금지
- **LLM 응답은 반드시 유효성 검증 후 DB 저장** — AI 출력을 그대로 신뢰하지 않음
- **DOM 토큰 제한 및 재시도 한계 준수** — DOM은 통째로 넘기지 않고 일정 길이(3,000자)로 자르거나 주변부만 파싱, 재시도 횟수는 `MAX_RECOVERY_ATTEMPTS` 환경변수(기본값 3)로 제어

---

## 환경변수 규칙

- `.env` 파일은 절대 커밋 금지 (`.gitignore`에 포함)
- 모든 설정값은 `python-dotenv`의 `load_dotenv()`로 로드
- 하드코딩 금지 목록: DB URL, Ollama URL, 포트 번호, 사이트 URL

```python
# ✅ 올바른 패턴
import os
from dotenv import load_dotenv
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
OLLAMA_HOST = os.getenv("OLLAMA_HOST")
MAX_RECOVERY_ATTEMPTS = int(os.getenv("MAX_RECOVERY_ATTEMPTS", "3"))

# ❌ 금지
DATABASE_URL = "postgresql+asyncpg://acro:secret@localhost:5432/acrodb"
```

---

## WebSocket 규칙

- **WebSocket 메시지는 반드시 `type` 필드 포함**

```python
# 메시지 타입 통일
await websocket.send_json({
    "type": "LOG",          # LOG | ELEMENT_CLICKED | SESSION_EXPIRED | MACRO_STATUS
    "level": "INFO",        # INFO | SUCCESS | WARNING | ERROR | AI_FIX
    "message": "매크로 실행 시작",
    "site_name": "korail"
})
```

- **세션 만료 감지 시 즉시 `SESSION_EXPIRED` 전송** — 매크로 중단 + FE 알림 동시 처리

---

## AI Agent 코딩 규칙

- **코드 작성 시 새 주석 추가 금지** — Agent가 코드를 작성하거나 리팩토링/수정할 때는 **기존에 있던 주석은 절대 임의로 삭제하지 말고 그대로 유지**하되, 코드 내부에 **새로운 주석은 절대 추가하지 말고** 사용자에게 보내는 응답 메시지에서만 텍스트로 설명할 것.

---

## 금지 목록 요약

| 금지 | 대신 사용 |
|---|---|
| sync `def` 라우터 | `async def` |
| `dict` 응답 반환 | Pydantic 응답 모델 |
| F-string SQL | SQLAlchemy ORM |
| `stealth_async` 누락 | `goto()` 전에 항상 적용 |
| 하드코딩 URL/비밀번호 | `os.getenv()` |
| `.env` 커밋 | `.gitignore` 처리 |
| 노드 내 복합 책임 | LangGraph 노드 단일 책임 분리 |
| `raise Exception` | `raise HTTPException(status_code=...)` |
