<!-- 산출물 예시 메타 -->
> 📂 **산출물 예시 — `impl-fe-be-doc` 스킬**  
> 산출 경로: `.docs/impl-doc/{사용자}/acro.md` (단일 앱) · 복수 앱이면 `.docs/{앱}/impl-doc/{사용자}/acro.md`  
> 설계 문서를 입력받아 FE/BE 페어를 Phase 단위로 묶은 작업지침서 예시입니다. 각 Phase 끝에 통합 검증이 붙습니다.

---

# 🚄 ACRO — FE/BE 페어 기능 단위 구현 명세서

> **AI Agent 및 개발자 참조용** · 기능이 온전히 동작하는 단위로 BE+FE를 페어로 묶어 구현 후 즉시 통합 검증
> `FastAPI · Playwright · LangChain · LangGraph · Ollama · React · Vite · PostgreSQL · Podman`

---

## 읽는 법

- **태스크 ID** : `BE-XX` / `FE-XX` / `INF-XX` 형식
- **의존** : 시작 전 반드시 완료되어야 하는 태스크
- **Agent 지시** : AI Agent가 구현 시 따라야 할 구체적 코드/구조 지침
- **✅ 통합 검증** : Phase 내 BE+FE 페어 작업이 모두 끝난 뒤 수행하는 통합 테스트. **이 조건을 통과해야 다음 Phase로 이동.**

---

## Phase 0 — 인프라 & 개발 환경 세팅

> 모든 Phase의 전제 조건. 여기서 문제가 생기면 이후 모든 작업이 막힌다.

---

### INF-01 · 프로젝트 디렉토리 구조 생성

**의존** : 없음

```
acro/
├── be/
│   ├── routers/            # 도메인별 API 라우터 분리
│   │   ├── __init__.py
│   │   ├── site.py         # /sites 엔드포인트
│   │   └── onboarding.py   # /onboarding, /selectors 엔드포인트
│   ├── onboarding/         # __init__.py 포함
│   ├── crawler/            # __init__.py 포함
│   ├── macro/              # __init__.py 포함
│   ├── ai/                 # __init__.py 포함
│   └── db/                 # __init__.py 포함
├── fe/
│   └── src/
│       ├── api/
│       ├── hooks/
│       ├── pages/
│       └── components/
└── compose.yaml
```

**.gitignore 필수 항목** (생성 시 즉시 추가):

```
# 환경변수 — 절대 커밋 금지
be/.env.development
be/.env.production
fe/.env.development
fe/.env.production

# 세션 쿠키 — 유출 시 계정 탈취 가능
be/sessions/

# Python
be/venv/
be/__pycache__/
be/**/__pycache__/

# Node
fe/node_modules/
```

**검증 기준** : 디렉토리 트리 존재, `.gitignore` 생성 확인

---

### INF-02 · DB + Ollama 컨테이너 단독 실행 (개발 환경)

**의존** : INF-01

```bash
# acro-db 볼륨 생성
podman volume create acro-db-data

# acro-db 단독 실행
podman run -d --name acro-db -p 55432:5432 -e POSTGRES_USER=acro -e POSTGRES_PASSWORD=acro -e POSTGRES_DB=acro_db -v acro-db-data:/var/lib/postgresql/data postgis/postgis:15-3.3


# acro-ai 볼륨 생성
podman volume create acro-ai-data

# acro-ai 단독 실행
podman run -d --name acro-ai -p 11434:11434 -v acro-ai-data:/root/.ollama ollama/ollama:latest

# llama3.2 모델 다운로드 (최초 1회, 약 2GB)
podman exec acro-ai ollama pull llama3.2


# Open WebUI 볼륨 생성 (선택 사항 - Ollama 챗봇 UI)
podman volume create open-webui-data

# Open WebUI 단독 실행
podman run -d -p 8888:8080 --name ollama-webui \
  --add-host=host.containers.internal:host-gateway \
  -e OLLAMA_BASE_URL=http://host.containers.internal:11434 \
  -v open-webui-data:/app/backend/data \
  ghcr.io/open-webui/open-webui:main
```

**검증 기준** :

- `psql -h localhost -U acro_user -d acro_db` 접속 성공
- `curl http://localhost:11434/api/tags` 응답에 `llama3.2` 포함
- `http://localhost:8888` Open WebUI 접속 성공

---

### INF-03 · BE 개발 환경 세팅

**의존** : INF-02

```bash
cd acro/be
python -m venv venv
source venv/bin/activate      # Windows: venv\Scripts\activate
pip install -r requirements.txt
patchright install chromium  # CDP 탐지 우회 패치 적용된 Chromium 설치 (playwright install chromium 대신 사용)
```

`be/.env.development` 생성:

```bash
DATABASE_URL=postgresql+asyncpg://acro_user:acro_password@localhost:5432/acro_db
OLLAMA_HOST=http://localhost:11434
# 개발 환경: 로컬 PC 모니터에 브라우저 창이 직접 열림. DISPLAY 불필요.
HEADLESS=false
SESSION_DIR=./sessions
MAX_RECOVERY_ATTEMPTS=3
LOG_LEVEL=debug
# 인간형 행동 모듈 on/off 토글 (true=활성화, false=비활성화 → 속도 우선)
HUMAN_MODE=false
# CORS 허용 출처 (쉼표 구분, *=전체 허용)
CORS_ORIGINS=http://localhost:5173
```

**검증 기준** : `uvicorn main:app --reload --port 8000` 실행 후 `http://localhost:8000/docs` 접속 성공 (main.py는 빈 파일도 무방)

---

### INF-04 · FE 개발 환경 세팅

**의존** : INF-01

```bash
cd acro/fe
pnpm install
npx tailwindcss init -p
```

`fe/.env.development` 생성:

```bash
VITE_API_BASE_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000/ws
VITE_WS_ONBOARDING_URL=ws://localhost:8000/ws/onboarding
# VITE_NOVNC_URL 의도적 미설정
# → Onboarding.jsx Step 2에서 "가상 브라우저 열기" 버튼 비렌더링 (로컬 텍스트 안내로 대체)
VITE_ENV=development
```

**검증 기준** : `pnpm dev` 실행 후 `http://localhost:5173` 정상 출력 (빈 화면도 무방)

---

## Phase 1 — 사이트 관리 기반 (Foundation)

> 가장 단순한 CRUD로 BE-FE 통신 파이프라인 전체를 검증하는 단계. DB → API → UI 순으로 연결.

---

### BE-01 · DB 연결 설정 (`db/database.py`)

**의존** : INF-03

- SQLAlchemy `create_async_engine` + asyncpg 비동기 연결
- `AsyncSession` 팩토리 및 `get_db()` 의존성 주입 함수
- `python-dotenv`로 `DATABASE_URL` 환경변수 로드

**Agent 지시**:

```python
# db/database.py
import os
from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base

# .env 파일을 기본적으로 로드 (호출하는 main.py 등에서 결정한 환경변수 우선)
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL 환경변수가 설정되지 않았습니다.")

engine = create_async_engine(DATABASE_URL, echo=False)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
Base = declarative_base()

async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
```

**검증 기준** : `from db.database import get_db` import 성공, DB 연결 오류 없음

---

### BE-02 · DB 모델 전체 정의 (`db/models.py`)

**의존** : BE-01

5개 테이블을 한 번에 정의. Phase 1에서 `sites`만 사용하더라도 **나머지 4개도 이 시점에 함께 정의**해 Alembic 마이그레이션을 1회로 처리한다.

| 모델          | 핵심 컬럼                                                                                    | 사용 Phase |
| ------------- | -------------------------------------------------------------------------------------------- | ---------- |
| `Site`        | site_name (UNIQUE), site_url, is_onboarded, last_crawled                                     | Phase 1~   |
| `Selector`    | site_name(FK), **macro_name**, element_name, selector, element_order, element_type, last_verified, is_active | Phase 3~   |
| `Session`     | site_name(FK), session_path, expires_at, is_valid                                                            | Phase 4~   |
| `DomSnapshot` | site_name(FK), page_hash(MD5), snapshot_html(TEXT)                                                           | Phase 5~   |
| `Reservation` | site_name(FK), **macro_name**, priority, is_active, is_done, success_url_pattern, created_at                 | Phase M~   |

**검증 기준** : `from db.models import Site, Selector, Session, DomSnapshot, Reservation` import 성공

---

### BE-03 · Alembic 마이그레이션

**의존** : BE-02

```bash
cd acro/be
pip install alembic
alembic init alembic
```

`alembic.ini` 수정 — `sqlalchemy.url`을 **동기 드라이버(psycopg2)** URL로 교체:

```ini
sqlalchemy.url = postgresql+psycopg2://acro:acro@localhost:55432/acro_db
```

> ⚠️ `asyncpg`는 Alembic 마이그레이션에서 사용 불가. `alembic.ini`의 URL은 반드시 `psycopg2` 동기 드라이버를 사용해야 한다. `be/.env.development`의 `DATABASE_URL`(asyncpg://)과는 별도로 관리.

`alembic/env.py` 수정:

```python
from db.database import Base
from db import models  # 모든 모델 import하여 autogenerate가 인식하게
target_metadata = Base.metadata
```

```bash
alembic revision --autogenerate -m "init all tables"
alembic upgrade head
```

**검증 기준** : psql `\dt` 명령으로 5개 테이블(`sites`, `selectors`, `sessions`, `dom_snapshots`, `reservations`) 모두 확인

---

### BE-04 · 사이트 관리 API (`main.py` 초기 구성)

**의존** : BE-03

구현할 엔드포인트:

- `POST /sites` — Site 생성
- `GET /sites` — Site 목록 조회 (쿼리 파라미터 `?is_onboarded=true` 지원)
- `DELETE /sites/{site_name}` — Site 삭제 (연관 selectors/sessions 등 CASCADE)
- `POST /onboarding/reset` — 특정 사이트의 온보딩 정보 초기화 (is_onboarded=False 전환, 셀렉터 및 세션 삭제)

**Agent 지시**:

```python
# main.py — 라우터 등록 및 기본 구조 유지
import os
from dotenv import load_dotenv

# 애플리케이션 시작 시점에 .env 값을 최우선으로 로드해 이후 모든 모듈에서 참조가 가능하도록 한다.
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import site, onboarding  # 도메인 라우터 임포트 (routers/ 디렉토리)

app = FastAPI()

# CORS 허용 출처 — 환경변수 CORS_ORIGINS로 동적 설정 (쉼표 구분, *=전체 허용)
_cors_env = os.getenv("CORS_ORIGINS", "http://localhost:5173")
cors_origins = ["*"] if _cors_env.strip() == "*" else [o.strip() for o in _cors_env.split(",")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(site.router)
app.include_router(onboarding.router)
app.include_router(onboarding.selector_router)  # GET /selectors/{site_name} 별도 등록
```

```python
# routers/site.py (API 도메인별 파일 분리)
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel
from db.database import get_db

router = APIRouter(prefix="/sites", tags=["Sites"])

class SiteCreate(BaseModel):
    site_name: str
    site_url: str

@router.post("")
async def create_site(info: SiteCreate, db: AsyncSession = Depends(get_db)): ...

@router.get("")
async def get_sites(
    is_onboarded: bool | None = Query(default=None),
    db: AsyncSession = Depends(get_db)
):
    # is_onboarded 파라미터가 있으면 해당 값으로 필터링, 없으면 전체 반환
    ...

@router.delete("/{site_name}")
async def delete_site(site_name: str, db: AsyncSession = Depends(get_db)):
    # Site 삭제 — DB 모델의 CASCADE로 연관 테이블(selectors, sessions 등) 자동 삭제
    ...
```

**검증 기준** : `http://localhost:8000/docs`에서 `/sites` 엔드포인트 3개 확인, Swagger UI에서 POST·GET(`?is_onboarded=true`)·DELETE 테스트 성공

---

### FE-01 · 라우터 & 레이아웃 기반 (`App.jsx`, `Navbar.jsx`)

**의존** : INF-04

- `react-router-dom` 기반 라우팅 구조 세팅
- `Navbar.jsx`: Dashboard / 사이트 등록 / 매크로 / 사이트 관리 링크

라우터 구성:

```jsx
/ → Dashboard.jsx (빈 페이지로 먼저 생성)
/onboarding → Onboarding.jsx (빈 페이지)
/reservation → Reservation.jsx (빈 페이지)
/sites → Sites.jsx (Phase 1에서 구현)
```

**검증 기준** : `/sites` 경로 접속 시 빈 Sites 페이지 렌더링, Navbar 링크 동작 확인

---

### FE-02 · API 클라이언트 (`api/client.js`)

**의존** : FE-01

- `axios.create()`로 `VITE_API_BASE_URL` 기반 전역 인스턴스 생성 (`client.js`)
- 도메인별 API 함수는 별도 파일로 분리 (`sites.js`, `onboarding.js` 등)

```javascript
// api/client.js
import axios from "axios";

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
});
```

```javascript
// api/sites.js
import { apiClient } from "./client";

export const getSites = (isOnboarded = null) =>
  apiClient.get("/sites", {
    params: isOnboarded !== null ? { is_onboarded: isOnboarded } : {},
  });
export const createSite = (name, url) =>
  apiClient.post("/sites", { site_name: name, site_url: url });
export const deleteSite = (siteName) => apiClient.delete(`/sites/${siteName}`);
```

```javascript
// api/onboarding.js (Phase 2 이후 추가 예시)
// import { apiClient } from './client'
// export const startOnboarding = ...
// export const startCapture = ...
```

**검증 기준** : `createSite("test", "https://test.com")` 호출 시 콘솔에서 201 응답 확인

---

### FE-03 · `Sites.jsx` — 사이트 목록 및 추가

**의존** : FE-02

- 사이트 이름 + URL 입력 폼
- [추가] 버튼 → `POST /sites`
- 목록 렌더링 → `GET /sites`
- 온보딩 완료 여부 배지 (`is_onboarded`)
- **[온보딩 시작] 버튼 (미완료 시)** → `/onboarding?site=xxx` 이동 (첫 번째 매크로 등록)
- **[초기화] 버튼 (완료 시)** → `POST /onboarding/reset` 호출 후 상태 갱신
- 사이트 삭제 버튼 (CASCADE 삭제)
- **온보딩 완료 시 매크로 목록 인라인 표시** → `GET /macros?site_name=xxx` 로 로드

  ```
  ┌─ korail ─────────────────────────────────────────────┐
  │  is_onboarded ✅          [초기화]  [삭제]           │
  │  매크로 목록                                         │
  │  ┌──────────────────────────────────┬──────────────┐ │
  │  │ 매크로 이름                      │ 셀렉터 수    │ │
  │  ├──────────────────────────────────┼──────────────┤ │
  │  │ 🔗 KTX 서울→부산 예약            │ 6개          │ │
  │  │ 🔗 무궁화 출발역 검색            │ 4개          │ │
  │  └──────────────────────────────────┴──────────────┘ │
  └──────────────────────────────────────────────────────┘
  ```
  - 매크로 행 클릭 → `/selectors?site=xxx&macro=yyy` 이동 (매크로 셀렉터 상세보기·수정)

**검증 기준** : 폼 제출 후 목록 반영, 온보딩 상태에 따른 버튼 분기 처리, 온보딩 완료 사이트의 매크로 목록 표시 및 클릭 시 상세보기 이동 확인

---

### ✅ Phase 1 통합 검증

**시나리오**: FE 브라우저에서 사이트 추가 → DB 확인

1. `http://localhost:5173/sites` 접속
2. 사이트 이름: `korail`, URL: `https://www.korail.com` 입력 후 [추가] 클릭
3. 목록에 "korail"이 즉시 나타나는지 확인
4. DB에서 `SELECT * FROM sites;` 실행 — 레코드 존재 확인

**합격 조건** : FE 목록 반영 ✅ / DB 레코드 적재 ✅ / CORS 오류 없음 ✅

---

## Phase 2 — 가상 브라우저 & noVNC 연동

> 온보딩의 전제 조건인 "FE 화면 안에 실제 브라우저를 띄우는" 기능을 구현한다.
> **개발 환경(로컬)과 배포 환경(Podman)의 동작 차이를 반드시 이해하고 진행.**

> 💡 **환경별 동작 차이**
> | 환경 | 브라우저 위치 | FE 표시 방식 |
> |------|-------------|-------------|
> | 개발 (로컬) | 로컬 PC 모니터에 직접 창 오픈 | 텍스트 안내 표시 |
> | 배포 (Podman) | BE 컨테이너 내 Xvfb 가상 화면 | noVNC 새 창 열기 버튼 렌더링 |
>
> 이 Phase는 배포 환경 기준으로 구현하되, 개발 환경에서의 fallback 분기를 함께 처리한다.

---

### INF-05 · BE Dockerfile + `start.sh` 작성

**의존** : INF-03

> ⚠️ `start.sh`는 **배포 컨테이너 전용**이다. 개발 환경(로컬 VSCode)에서는 절대 실행하지 않는다.
> Xvfb · x11vnc · noVNC는 BE 컨테이너에만 설치한다. DB · AI · FE 컨테이너에는 불필요.

`be/Dockerfile`:

```dockerfile
FROM mcr.microsoft.com/playwright/python:v1.44.0-jammy

RUN apt-get update && apt-get install -y \
    xvfb x11vnc websockify git \
    && rm -rf /var/lib/apt/lists/*

# noVNC는 pip 대신 git clone 방식이 안정적
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc

WORKDIR /app

# 애플리케이션 코드 복사
COPY . /app

# Windows 환경에서 빌드 시 발생하는 start.sh의 CRLF(캐리지 리턴)를 LF로 일괄 변환
# (오류: exec container process `/app/start.sh`: No such file or directory 방지)
RUN sed -i 's/\r$//' /app/start.sh && \
    chmod +x /app/start.sh

RUN pip install -r requirements.txt
RUN patchright install chromium  # CDP 탐지 우회 패치된 Chromium 바이너리 설치

CMD ["/app/start.sh"]
```

`be/start.sh`:

```bash
#!/bin/bash
Xvfb :99 -screen 0 1280x900x24 &
sleep 1   # Xvfb 완전히 뜰 때까지 대기

x11vnc -display :99 -nopw -listen 0.0.0.0 -xkb -forever &
sleep 1   # websockify 연결 실패 방지

websockify --web=/opt/novnc/ 6080 localhost:5900 &

uvicorn main:app --host 0.0.0.0 --port 8000
```

`be/.env.production` 생성:

```bash
DATABASE_URL=postgresql+asyncpg://acro_user:acro_password@host.containers.internal:55432/acro_db
OLLAMA_HOST=http://host.containers.internal:11434
DISPLAY=:99        # Xvfb 가상 디스플레이 번호 — 없으면 patchright 실행 불가
HEADLESS=false     # Xvfb가 가상 모니터 역할. 배포 시에도 false 유지.
SESSION_DIR=./sessions
MAX_RECOVERY_ATTEMPTS=3
LOG_LEVEL=warning
# 인간형 행동 모듈 on/off 토글 (true=활성화, false=비활성화 → 속도 우선)
HUMAN_MODE=true
# CORS 허용 출처 (배포 환경에서 FE 컨테이너 주소 지정, 또는 *=전체 허용)
CORS_ORIGINS=http://localhost:5173
```

**검증 기준** : `podman build -t acro-backend ./be` 빌드 성공

---

### BE-05 · 온보딩 브라우저 실행 (`onboarding/browser.py`)

**의존** : INF-03

> ⚠️ **중요 주의사항**
>
> - **Windows 환경 호환성**: Windows에서 Playwright 하위 프로세스를 실행하려면 `main.py` 최상단에서 `WindowsProactorEventLoopPolicy`를 반드시 설정해야 한다.
> - **봇 탐지 회피**: 코레일은 Chrome DevTools Protocol(CDP) 연결 자체를 탐지한다. `playwright` 대신 `patchright`(Chromium 바이너리 패치)를 import하고, `playwright-stealth` 2.x의 `Stealth().apply_stealth_async(page)`를 `goto()` 이전에 적용해야 한다. `--disable-blink-features=AutomationControlled` 인자도 필수.
> - **싱글턴 유지**: 온보딩 세션 동안 브라우저 인스턴스를 유지하기 위해 전역 변수로 관리한다.

**Agent 지시 (browser.py)**:

```python
# onboarding/browser.py
import os
from patchright.async_api import async_playwright  # playwright 대신 patchright — CDP 탐지 우회

_playwright = _browser = _context = _page = None

async def launch_browser(url: str):
    global _playwright, _browser, _context, _page
    # 1. 기존 페이지가 있으면 해당 페이지로 이동 후 반환
    if _page: return await _page.goto(url)

    # 2. 브라우저 기동 (탐지 회피 인자 포함, channel="chrome" 사용 금지)
    _playwright = await async_playwright().start()
    _browser = await _playwright.chromium.launch(
        headless=os.getenv("HEADLESS", "false").lower() == "true",
        args=[
            "--no-sandbox",
            "--disable-blink-features=AutomationControlled",
            "--disable-features=IsolateOrigins,site-per-process",
            "--exclude-switches=enable-automation,enable-logging",
        ],
        ignore_default_args=["--enable-automation", "--enable-logging"]
    )
    _context = await _browser.new_context(user_agent="...")
    _page = await _context.new_page()

    # 3. playwright-stealth 2.x Stealth 클래스 적용 (goto() 이전 필수)
    from playwright_stealth import Stealth
    await Stealth().apply_stealth_async(_page)
    await _page.goto(url)
    return _page
```

**API 추가 (routers/onboarding.py)**:

```python
# routers/onboarding.py
router = APIRouter(prefix="/onboarding", tags=["Onboarding"])

@router.post("/start")
async def start_onboarding(req: OnboardingStartRequest, db: AsyncSession = Depends(get_db)):
    # DB에서 사이트 URL 조회 후 browser.launch_browser(url) 호출
    ...
```

**이벤트 루프 설정 (main.py)**:

```python
# main.py 최상단
if sys.platform == 'win32':
    asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())
```

**검증 기준** : `POST /onboarding/start` 호출 시 지정 URL로 브라우저 창이 열릴 것 (개발 환경: 탐지 회피가 적용된 상태로 로컬 모니터에 오픈)

---

### FE-04 · `Onboarding.jsx` Step 1~2 구현

**의존** : FE-02

Step 1 — 사이트 입력 & 브라우저 실행:

- 사이트 이름 + URL 입력 폼
- **매크로 이름 입력 폼** (필수) — 이번 온보딩으로 등록할 매크로의 이름 (예: "KTX 서울→부산 예약")
  - `/onboarding?site=korail&mode=add_macro` 쿼리파라미터로 진입 시: 사이트 이름/URL 폼 숨기고 매크로 이름만 입력받음 (사이트는 이미 선택됨)
  - 최초 온보딩(`/onboarding?site=xxx` 또는 직접 접근) 시: 사이트 이름 + URL + 매크로 이름 모두 입력
- [온보딩 시작] 버튼 → `POST /sites` (최초 시에만) 후 `POST /onboarding/start` 호출

Step 2 — 환경별 조건부 렌더링:

```jsx
// VITE_NOVNC_URL 유무로 개발/배포 환경 자동 분기
{
  import.meta.env.VITE_NOVNC_URL ? (
    // 배포 환경: 새 창으로 가상 브라우저 여는 버튼 제공
    <div className="p-4 bg-blue-500/10 border border-blue-500/20 rounded-lg">
      <p className="text-blue-300 font-medium mb-3">
        배포 환경(가상 브라우저)에서 온보딩을 진행합니다.
      </p>
      <button
        onClick={() =>
          window.open(
            import.meta.env.VITE_NOVNC_URL,
            "_blank",
            "width=1280,height=900",
          )
        }
      >
        새 창으로 가상 브라우저 열기 ↗
      </button>
      <p className="mt-2 text-sm text-gray-400">
        ※ 새 창에서 로그인 및 예약 화면 이동 후, 이 탭으로 돌아와 진행해주세요.
      </p>
    </div>
  ) : (
    // 개발 환경: 로컬 PC에 창이 떴음을 안내
    <div className="p-4 bg-blue-50 rounded">
      <p>로컬 PC에 브라우저 창이 직접 열렸습니다.</p>
      <p>로그인 후 예약 화면까지 이동해주세요.</p>
    </div>
  );
}
<button onClick={() => setStep(3)}>셀렉터 등록 시작 →</button>;
```

**api/onboarding.js에 추가**:

```javascript
import { apiClient } from "./client";

export const startOnboarding = (siteName, siteUrl) =>
  apiClient.post("/onboarding/start", {
    site_name: siteName,
    site_url: siteUrl,
  });
```

**검증 기준** :

- 개발 환경: [온보딩 시작] 클릭 시 로컬 PC에 브라우저 창 오픈 + FE에 텍스트 안내 표시
- 배포 환경(`VITE_NOVNC_URL` 설정 시): 가상 브라우저 "새 창 열기" 버튼 렌더링

---

### ✅ Phase 2 통합 검증

**시나리오 1**: 로컬 개발 환경 브라우저 연동 확인

1. `http://localhost:5173/onboarding` 접속
2. 사이트 이름: `korail`, URL 입력 후 [온보딩 시작] 클릭
3. **개발 환경**: 로컬 PC에 코레일 웹사이트가 열린 브라우저 창 확인 / FE에 텍스트 안내 표시 확인
4. 수동으로 브라우저에서 로그인 후 예약 화면까지 이동
5. [셀렉터 등록 시작 →] 버튼 활성화 확인

**합격 조건** : 브라우저 창 오픈 ✅ / 환경별 FE 렌더링 분기 정상 ✅ / `POST /onboarding/start` 200 응답 ✅

---

**시나리오 2**: Podman 배포 환경 (컨테이너 연동 통합 검증)

Podman 빌드 후 컨테이너 간 연동 단계를 검사하는 단축 검증 루틴이다.

```bash
# 1. Frontend 빌드 및 실행
podman build -t acro-frontend ./fe
podman run -d --name acro-fe -p 5173:80 acro-frontend
# → localhost:5173 접속 가능 여부 점검

# 2. Database + AI 실행 (Phase 0에서 이미 수행되어 있어야 함)
# 필수: acro-db(5432), acro-ai(11434) 가 실행 중이어야 함

# 3. Backend 빌드 및 실행
podman build -t acro-backend ./be
# sessions 폴더 마운트를 위한 디렉토리 사전 생성 (Windows 환경 오류 방지)
mkdir -p ./be/sessions
podman run -d --name acro-be -p 8000:8000 -p 6080:6080 \
  -v ./be/.env.production:/app/.env \
  -v ./be/sessions:/app/sessions \
  acro-backend

# => 서버 시작 후 `podman logs acro-be`를 확인하여
# "Uvicorn running on http://0.0.0.0:8000" 이 뜨고, DB 연결 오류가 없는지 확인 (ConnectionRefusedError 점검)
```

**합격 조건** :

- `podman ps` 실행 시 `acro-fe`, `acro-be`, `acro-db`, `acro-ai` 4개 컨테이너 모두 `Up` 상태
- 브라우저로 `http://localhost:5173/onboarding` 접속
- [온보딩 시작] 클릭 후 나타나는 "가상 브라우저 열기" 버튼을 누르면 새 창이 팝업되고, 그 안에 "코레일" 화면이 정상 렌더링됨
- 브라우저를 직접 띄우는 것이 아닌 Xvfb 속 화면이 noVNC로 중계됨 ✅

---

## Phase 3 — 실시간 클릭 캡처 & AI 역할 추론 (Onboarding Core)

> 이 Phase가 온보딩의 핵심. 사용자 클릭 → HTML 수집 → AI 추론 → WebSocket 실시간 전달 → 사용자 확인 → DB 저장 루프 전체를 완성한다.

---

### BE-06 · AI 체인 구현 (`ai/chain.py`)

**의존** : INF-03 (Ollama 컨테이너)

> ⚠️ `OllamaLLM`을 직접 호출하지 않는다. `get_llm()` 팩토리를 통해 추상화한다.
> Ollama → 클라우드 LLM 전환 시 이 파일만 수정하면 된다.

```python
# ai/chain.py
import os
from langchain_ollama import OllamaLLM

def get_llm():
    return OllamaLLM(
        model="llama3.2",
        base_url=os.getenv("OLLAMA_HOST", "http://localhost:11434")
    )

async def infer_element_name(element_info: dict) -> str:
    """HTML 요소 정보를 받아 한국어 역할명을 추론"""
    llm = get_llm()
    prompt = f"""아래는 사용자가 클릭한 HTML 요소 정보입니다.
{element_info}

이 요소의 역할을 한국어로 간단하게 추론해주세요.
요소 정보에 특정 텍스트(역 이름, 날짜, 시간 등)가 있다면 반드시 괄호에 넣어 표시하세요.
예시: 출발역 선택(용산역), 날짜 선택(21일), 출발시간대 선택(9시), 조회 버튼
한 줄로만 답하세요. 확실하지 않으면 "확인 필요"라고만 답하세요."""
    result = await llm.ainvoke(prompt)
    return result.strip() if result.strip() else "확인 필요"
```

**검증 기준** : `await infer_element_name({"tag": "input", "placeholder": "출발지"})` → 한국어 역할명 반환 (빈값 없음)

---

### BE-07 · 클릭 캡처 (`onboarding/capture.py`)

**의존** : BE-05, BE-06

> ⚠️ Python Playwright의 `page.on("click")`은 브라우저 DOM 이벤트를 감지할 수 없으므로, JS 클릭 리스너를 직접 주입하는 브릿지 방식을 사용한다. `ctx.expose_function()`으로 Python 수신부를 등록하고, **`page.add_init_script()`**로 동일 페이지 네비게이션(로그인 후 리다이렉트 등)마다 자동 재주입한다. `ctx.add_init_script()`는 신규 페이지 생성 시에만 동작하므로, 로그인 리다이렉트처럼 같은 page 객체 내 URL이 변경되는 경우에는 동작하지 않는다. `page.on("load")` fallback과 `ctx.on("page")` 새 탭 대응을 함께 등록하여 모든 네비게이션 케이스를 커버한다.

```python
# onboarding/capture.py
import asyncio

_capture_queue: asyncio.Queue = asyncio.Queue()
_capturing = False

async def start_capture(page):
    global _capturing
    _capturing = True

    async def handle_click(info):
        if not _capturing:
            return
        await _capture_queue.put(info)

    ctx = page.context

    try:
        await ctx.expose_function("acro_capture_click", handle_click)
    except Exception:
        pass  # 이미 바인딩된 경우 무시

    capture_js = """(() => {
        if (window.__acro_capture_setup) return;
        window.__acro_capture_setup = true;

        // 셀렉터 최적화: 난수성 클래스(숫자 4개 이상/30자 이상) 및 상태성 클래스 제거, 최대 3개 결합
        const getEnhancedSelector = (el) => {
            try {
                if (!el || el === document.body || el === document.documentElement) return '';
                let textSelector = '';
                const text = el.innerText?.trim();
                if (text && text.length > 0 && text.length <= 20 && !text.includes('\\n')) {
                    const safeText = text.replace(/'/g, "\\\\'");
                    textSelector = `:has-text('${safeText}')`;
                }
                if (el.id && !/\\d{5,}/.test(el.id) && el.id.length < 40)
                    return '#' + CSS.escape(el.id) + textSelector;
                if (el.className && typeof el.className === 'string') {
                    const classes = el.className.trim().split(/\\s+/)
                        .filter(c => c.length > 0 && c.length < 30 && !/\\d{4,}/.test(c)
                            && !['active','hover','selected','on','focus'].includes(c));
                    if (classes.length > 0)
                        return '.' + classes.slice(0, 3).map(c => CSS.escape(c)).join('.') + textSelector;
                }
                return el.tagName.toLowerCase() + textSelector;
            } catch (e) { return el.tagName ? el.tagName.toLowerCase() : ''; }
        };

        document.addEventListener('click', async (e) => {
            try {
                const target = e.composedPath()[0] || e.target;
                const el = target.closest('a, button, [role="button"], label, input, select') || target;
                if (!el || el === document.body || el === document.documentElement) return;
                const info = {
                    tag: el.tagName.toLowerCase(),
                    id: el.id || '',
                    class: (typeof el.className === 'string' ? el.className : ''),
                    placeholder: el.placeholder || '',
                    name: el.name || '',
                    nearby_text: el.closest('label')?.innerText
                              || el.closest('div')?.querySelector('label')?.innerText
                              || el.innerText?.substring(0, 30)?.trim() || '',
                    selector: getEnhancedSelector(el),
                    element_type: ['input', 'button', 'select'].includes(el.tagName.toLowerCase())
                                ? el.tagName.toLowerCase() : 'button'
                };
                if (window.acro_capture_click && info.selector)
                    await window.acro_capture_click(info);
            } catch (err) { console.error("Capture Error:", err); }
        }, { capture: true });
    })();"""

    # page 레벨 init_script 등록 → 동일 page 객체의 모든 네비게이션(로그인 리다이렉트 등)에 재주입
    # ⚠️ ctx.add_init_script는 신규 page 생성 시에만 동작 — 같은 page의 URL 변경에는 동작하지 않음
    await page.add_init_script(capture_js)

    # page.on("load") fallback → 전체 페이지 로드 이후 누락 방지
    async def on_load():
        for frame in page.frames:
            try:
                await frame.evaluate(capture_js)
            except Exception:
                pass

    page.on("load", on_load)

    # 새 탭/팝업 대응 → init_script + load 이벤트 + 즉시 evaluate 3중 보장
    async def handle_new_page(new_page):
        try:
            await new_page.add_init_script(capture_js)
        except Exception:
            pass
        async def on_new_page_load():
            for frame in new_page.frames:
                try:
                    await frame.evaluate(capture_js)
                except Exception:
                    pass
        new_page.on("load", on_new_page_load)
        try:
            await new_page.wait_for_load_state("domcontentloaded")
            for frame in new_page.frames:
                try:
                    await frame.evaluate(capture_js)
                except Exception:
                    pass
        except Exception:
            pass

    ctx.on("page", handle_new_page)

    # 현재 열린 프레임에도 즉시 주입
    for frame in page.frames:
        try:
            await frame.evaluate(capture_js)
        except Exception:
            continue

async def stop_capture():
    global _capturing
    _capturing = False

async def get_next_click():
    return await _capture_queue.get()
```

**API 추가** (`routers/onboarding.py`):

```python
# POST /onboarding/capture/start
# → browser._page (전역 싱글턴)로 현재 열린 페이지를 가져와 capture.start_capture(page) 호출
# → 동시에 session.save_session(context, site_name) 호출로 로그인 세션 쿠키 저장
#
# 구현 예시:
# from onboarding import browser, capture, session
#
# class CaptureStartBody(BaseModel):
#     site_name: str
#
# @router.post("/capture/start")
# async def capture_start(body: CaptureStartBody, db: AsyncSession = Depends(get_db)):
#     page = browser._page        # browser.py 전역 싱글턴
#     ctx  = browser._context
#     await session.save_session(ctx, body.site_name)  # 세션 쿠키 저장 (BE-09)
#     await capture.start_capture(page)                # 캡처 리스너 등록
#     return {"status": "capture_started"}
```

> ⚠️ `browser._page` 전역 싱글턴을 사용하므로 동시에 두 사이트를 온보딩할 수 없다. 온보딩은 단일 세션으로만 진행한다.

**검증 기준** : 캡처 시작 후 브라우저에서 input 클릭 시 tag/id/class/placeholder/nearby_text/selector/element_type 7개 필드 채워진 dict 큐에 적재

---

### BE-08 · WebSocket 온보딩 스트리밍 (`main.py` WS 엔드포인트)

**의존** : BE-07

**WebSocket 메시지 타입 정의** (FE와 약속):

```python
# /ws/onboarding/{site_name} — 서버 → 클라이언트
{
  "type": "ELEMENT_CAPTURED",
  "element": { "tag": "...", "selector": "...", ... },
  "suggested_name": "출발역 입력칸",  # AI 추론 결과
  "status": "confirmed",             # "confirmed" | "needs_review"
  "site_name": "korail"              # 온보딩 대상 사이트 식별자
}

# /ws — 서버 → 클라이언트 (매크로 실행용, Phase 5에서 완성)
{ "type": "LOG", "level": "INFO|SUCCESS|WARNING|ERROR|AI_FIX", "message": "..." }
{ "type": "MACRO_STATUS", "status": "running|idle|error" }
{ "type": "SESSION_EXPIRED", "site_name": "..." }
{ "type": "RECOVERY_COMPLETE", "changed_selectors": [...] }
{ "type": "REONBOARDING_REQUIRED", "site_name": "..." }
```

```python
# main.py
@app.websocket("/ws/onboarding/{site_name}")
async def onboarding_ws(websocket: WebSocket, site_name: str):
    await websocket.accept()
    while True:
        click_data = await capture.get_next_click()
        suggested_name = await chain.infer_element_name(click_data)
        await websocket.send_json({
            "type": "ELEMENT_CAPTURED",
            "element": click_data,
            "suggested_name": suggested_name,
            "status": "confirmed" if suggested_name != "확인 필요" else "needs_review",
            "site_name": site_name,
        })

# 매크로 실행 상태 + 로그 스트리밍용 범용 WebSocket
# FE Dashboard.jsx의 useWebSocket(VITE_WS_URL)이 이 엔드포인트에 연결
_macro_ws_clients: list[WebSocket] = []

@app.websocket("/ws")
async def macro_ws(websocket: WebSocket):
    await websocket.accept()
    _macro_ws_clients.append(websocket)
    try:
        while True:
            await websocket.receive_text()  # 연결 유지 (클라이언트 → 서버 메시지 무시)
    except Exception:
        _macro_ws_clients.remove(websocket)

# 매크로 엔진(engine.py)에서 로그·상태 이벤트 전송 시 사용
async def broadcast_macro_event(event: dict):
    for ws in list(_macro_ws_clients):
        try:
            await ws.send_json(event)
        except Exception:
            _macro_ws_clients.remove(ws)
```

**API 추가** (`routers/onboarding.py`):

```python
# POST /onboarding/capture/confirm
# body: { "site_name": "...", "macro_name": "...", "items": [{element_name, selector, element_order, element_type}] }
# → selectors 테이블 저장 (각 row에 macro_name 포함) + sites.is_onboarded = True
# → 동일 (site_name, macro_name) 조합이 이미 존재하면 해당 매크로 셀렉터 전체 교체(upsert)

# GET /selectors
# query: site_name (필수), macro_name (필수)
# → 해당 (site_name, macro_name)의 is_active=True 셀렉터 목록 반환 (element_order 오름차순)
# → FE SelectorDetails 상세보기 및 매크로 엔진 셀렉터 로드에 사용

# GET /macros
# query: site_name (필수)
# → 해당 사이트의 고유 macro_name 목록 반환 (각 매크로별 셀렉터 수 포함)
# → FE Sites.jsx / Reservation.jsx 매크로 목록 표시에 사용
# 응답 예시: [{ "macro_name": "KTX 서울→부산", "selector_count": 6 }, ...]
```

**검증 기준** : WS 연결 후 브라우저 클릭 시 3~5초 이내 `ELEMENT_CAPTURED` 메시지 수신, `suggested_name` 비어있지 않음 / `/ws` 연결 후 `broadcast_macro_event()` 호출 시 클라이언트에 메시지 수신 확인

---

### BE-09 · 세션 저장/로드 (`onboarding/session.py`)

**의존** : BE-05

```python
# onboarding/session.py
import os

SESSION_DIR = os.getenv("SESSION_DIR", "./sessions")

async def save_session(context, site_name: str) -> str:
    os.makedirs(SESSION_DIR, exist_ok=True)
    path = f"{SESSION_DIR}/{site_name}_session.json"
    await context.storage_state(path=path)
    return path

async def load_session(site_name: str) -> str | None:
    path = f"{SESSION_DIR}/{site_name}_session.json"
    return path if os.path.exists(path) else None
```

**트리거 시점** : `POST /onboarding/capture/start` 호출 시 캡처 시작 직전에 `save_session()`을 함께 호출한다 (BE-07 `routers/onboarding.py` 구현 예시 참조). 사용자가 예약 화면까지 이동한 뒤 버튼을 누르는 시점이므로, 로그인 쿠키가 온전히 포함된 상태에서 세션이 저장된다.

**검증 기준** : `POST /onboarding/capture/start` 호출 후 `{SESSION_DIR}/{site_name}_session.json` 파일 생성 확인

---

### FE-05 · WebSocket 훅 (`hooks/useWebSocket.js`)

**의존** : FE-01

```javascript
// hooks/useWebSocket.js
import { useState, useEffect, useRef } from "react";

export function useWebSocket(url) {
  const [isConnected, setIsConnected] = useState(false);
  const [lastMessage, setLastMessage] = useState(null);
  const wsRef = useRef(null);

  useEffect(() => {
    if (!url) return;
    wsRef.current = new WebSocket(url);
    wsRef.current.onopen = () => setIsConnected(true);
    wsRef.current.onmessage = (e) => setLastMessage(JSON.parse(e.data));
    wsRef.current.onclose = () => setIsConnected(false);
    return () => wsRef.current?.close();
  }, [url]);

  return { isConnected, lastMessage };
}
```

**검증 기준** : URL 전달 시 WS 연결, BE 메시지 전송 시 `lastMessage` 업데이트 확인

---

### FE-06 · `SelectorConfirm.jsx` — AI 추론 확인/수정

**의존** : FE-05

온보딩 Step 4~5에서 사용. WS로 수신된 요소가 실시간으로 목록에 추가되며, AI 추론 이름을 확인하거나 수정할 수 있다.

**Props**:

```javascript
items: [{
  order: number,
  ai_name: string,      // AI 추론 결과
  selector: string,
  element_type: string,
  status: "confirmed" | "needs_review"
}]
onConfirm: (confirmedItems) => void
```

**UI 구성**:

```
┌────┬────────────────────┬─────────────────┬──────────┐
│ #  │ AI 추론 이름       │ 셀렉터          │ 상태     │
├────┼────────────────────┼─────────────────┼──────────┤
│ 1  │ 출발역 입력칸      │ #dpt_stn_nm     │ ✅ 확인  │
│ 2  │ 도착역 입력칸      │ #arv_stn_nm     │ ✅ 확인  │
│ 3  │ [________입력_____]│ .date-picker    │ ⚠️ 수정  │  ← needs_review
│ 4  │ 조회 버튼          │ #search_btn     │ ✅ 확인  │
└────┴────────────────────┴─────────────────┴──────────┘
               [ 전체 초기화 ] [ 전체 확인 완료 → DB 저장 ]  ← 모든 행 confirmed일 때만 활성
```

- **추가 구현**: 오클릭한 요소를 제외하기 위한 행별 개별 삭제 버튼(🗑️) 및 `전체 초기화` 버튼 제공.

**검증 기준** : items 배열 전달 시 테이블 렌더링, 개별/전체 삭제 기능 동작, 수정 후 onConfirm 호출 시 최종 확정 데이터 반환

---

### FE-07 · `Onboarding.jsx` Step 3~6 완성

**의존** : FE-04, FE-06

Step 3~6 구현:

```
Step 3: [셀렉터 등록 시작] 클릭 → POST /onboarding/capture/start
        "브라우저에서 예약에 필요한 요소들을 클릭하세요."

Step 4: WS /ws/onboarding/{site_name} 연결
        클릭마다 SelectorConfirm 목록에 실시간 추가
        (useWebSocket lastMessage 감지 → items 배열에 append)

Step 5: SelectorConfirm.jsx 렌더링
        사용자가 AI 추론 이름 확인/수정

Step 6: [전체 확인 완료 → DB 저장] 클릭
        → POST /onboarding/capture/confirm  (body에 macro_name 포함)
        → "온보딩 완료! 매크로 [xxx] 등록됨" 표시
        → 최초 온보딩 / add_macro 모드 모두: /reservation?site=xxx 로 이동 (매크로 목록으로 복귀)

---

### FE-07.5 · `SelectorDetails.jsx` — 매크로 셀렉터 상세보기 & 관리

**의존** : FE-07

- URL: `/selectors?site=xxx&macro=yyy`
  - `site` 쿼리파라미터 → 사이트 이름
  - `macro` 쿼리파라미터 → 매크로 이름 (없으면 해당 사이트의 첫 번째 매크로로 폴백)
- **기능**:
  - `GET /selectors?site_name=xxx&macro_name=yyy` 호출로 해당 매크로 셀렉터 로드
  - 페이지 상단에 매크로 이름 표시 (예: "KTX 서울→부산 예약")
  - `SelectorConfirm` 컴포넌트 재사용으로 UI 일관성 유지
  - 개별 셀렉터 이름/값 수정 및 삭제 지원
  - [변경사항 저장] 클릭 시 `POST /onboarding/capture/confirm` (macro_name 포함) 재호출하여 DB 업데이트

**검증 기준** : Sites.jsx 또는 Reservation.jsx 매크로 행 클릭 시 올바른 `?site=xxx&macro=yyy` URL로 이동, 해당 매크로 셀렉터만 로드, 수정 후 저장 시 DB 반영 확인
```

**api/onboarding.js에 추가**:

```javascript
import { apiClient } from "./client";

export const startCapture = (siteName) =>
  apiClient.post("/onboarding/capture/start", { site_name: siteName });
export const confirmSelectors = (siteName, macroName, items) =>
  apiClient.post("/onboarding/capture/confirm", {
    site_name: siteName,
    macro_name: macroName,  // 셀렉터를 묶을 매크로 이름
    items,
  });
export const getMacros = (siteName) =>
  apiClient.get("/macros", { params: { site_name: siteName } });
```

**검증 기준** : 6단계 전체 플로우 완료 시 `sites.is_onboarded = true`, `selectors` 테이블에 클릭한 수만큼 row 존재 (모두 동일 `macro_name`), add_macro 모드 시 기존 매크로와 다른 `macro_name`으로 별도 row 저장 확인

---

### ✅ Phase 3 통합 검증

**시나리오**: 클릭 캡처 → AI 추론 → DB 저장 E2E

1. `http://localhost:5173/onboarding` 에서 온보딩 시작 (Phase 2 검증 선행)
2. 브라우저에서 로그인 후 예약 화면 이동
3. [셀렉터 등록 시작] 클릭
4. 예약 화면에서 "출발역 입력칸" 클릭
5. **3~5초 후** FE 우측 패널에 새 항목 추가, AI 추론 이름 표시 확인
6. `status: "needs_review"` 항목은 직접 이름 수정
7. [전체 확인 완료 → DB 저장] 클릭
8. DB 확인: `SELECT * FROM selectors WHERE site_name='korail';`

**합격 조건** : WS 실시간 수신 ✅ / AI 추론 이름 표시 ✅ / DB selectors 저장 ✅ / `sites.is_onboarded = true` ✅

---

### FE-07.6 · `AiChatPanel.jsx` — AI 추론 과정 실시간 대화창 패널

**의존** : FE-07

온보딩 Step 3 화면 우측에 Ollama AI 추론 과정을 **챗 버블 형식**으로 실시간 시각화하는 사이드 패널.

#### BE 변경 (`main.py`)

`onboarding_ws` WebSocket 핸들러에서 AI 추론 **시작 전** `AI_THINKING` 선행 이벤트를 전송:

```python
# AI 추론 시작 전 FE 대화창에 "생각 중" 버블 표시용 이벤트
await websocket.send_json({
    "type": "AI_THINKING",
    "element": click_data,
    "site_name": site_name,
})
# 이후 기존 ELEMENT_CAPTURED 이벤트 전송 (변경 없음)
```

**신규 WebSocket 이벤트 타입**:

| type | 방향 | 설명 |
|---|---|---|
| `AI_THINKING` | 서버→클라이언트 | 추론 시작. FE에서 "생각 중" 버블 표시 트리거 |

#### FE 변경

**`fe/src/components/AiChatPanel.jsx` [NEW]**:

- `chatLogs` 배열을 props로 받아 챗 버블 목록 렌더
- 버블 타입: `thinking` (Spinner 점 애니메이션) / `result` (추론 결과) / `error`
- 각 항목은 클릭 요소 정보(우측 USER 버블) + AI 응답(좌측 ASSISTANT 버블) 쌍으로 구성
- 새 버블 추가 시 자동 스크롤 (최신 항목이 항상 뷰포트에 노출)
- 패널 외부 컨테이너에 `h-full` 적용 → 좌측 셀렉터 섹션과 높이를 맞춤 (부모의 `items-stretch` 활용)
- 버블 스크롤 영역에서 `min-h-[400px]` / `max-h-[600px]` 고정 높이 제거 → `flex-1`로 남은 공간을 유동적으로 채움

```
┌─────────────────────────────────┐
│ ◉  AI 추론 과정   Ollama·llama  │  ← 패널 헤더
├─────────────────────────────────┤
│                  📥 클릭 요소   │  ← USER 버블 (tag/placeholder 요약)
│  🤖 ·  ·  · 생각 중            │  ← AI 버블 (thinking 상태)
├─────────────────────────────────┤
│                  📥 클릭 요소   │  ← USER 버블
│  🤖 ✅ 추론 완료               │  ← AI 버블 (result 상태)
│      출발역 입력칸              │
└─────────────────────────────────┘
```

**`Onboarding.jsx` Step 3 레이아웃**:

```jsx
// AS-IS: 단일 컬럼, 고정 너비
<div className="max-w-4xl mx-auto pb-20">
  <SelectorConfirm .../>
</div>

// TO-BE: 뷰포트 기반 2-column flex (화면을 꽉 채우는 레이아웃)
<div className="h-[calc(100vh-10rem)] flex flex-col overflow-hidden">
  <h1 ... className="... shrink-0">사이트 온보딩</h1>
  <div className="flex gap-6 items-stretch flex-1 min-h-0">  {/* 남은 공간 전부 활용 */}
    <section className="flex-1 ... flex flex-col h-full">  {/* 좌측: 셀렉터 테이블 */}
      <SelectorConfirm .../>
    </section>
    <AiChatPanel chatLogs={chatLogs} />  {/* 우측: AI 대화창 — h-full로 좌측과 높이 동기화 */}
  </div>
</div>
```

> 💡 `items-stretch` + `h-full` 조합으로 좌우 패널이 항상 동일한 높이를 유지한다. `min-h-0`은 flex 자식의 기본 최소 높이(auto) 제약을 해제하여 overflow-y-auto 스크롤이 정상 동작하게 한다.

**`Onboarding.jsx` `handleOnMessage` 처리 추가**:

```javascript
if (msg.type === "AI_THINKING") {
  // 대화창에 "생각 중" 버블 추가
  setChatLogs(prev => [...prev, { id: Date.now(), type: "thinking", element: msg.element }]);
}
if (msg.type === "ELEMENT_CAPTURED") {
  // 마지막 thinking 버블 → result 버블로 교체
  setChatLogs(prev => { /* reverse 탐색으로 마지막 thinking 인덱스를 result로 전환 */ });
  setItems(prev => [...prev, { /* 기존 셀렉터 목록 항목 추가 */ }]);
}
```

> 💡 `전체 초기화` 버튼 클릭 시 `setItems([])` + `setChatLogs([])` 함께 초기화.

**검증 기준** : Step 3 진입 후 브라우저 요소 클릭 시 → 우측 패널에 "생각 중" 버블 즉시 표시 → 3~5초 후 결과 텍스트로 전환 ✅ / 좌측 셀렉터 테이블에도 동일 항목 동시 추가 ✅

---

## Phase M — DB 범용화 & 성공 기준 정의

> Phase 3까지 완료된 온보딩 코어 위에, 매크로 실행(Phase 4) 착수 전에 먼저 DB 스키마와 성공 판정 구조를 범용적으로 확립한다.
> **이 Phase를 완료해야 Phase 4 이후의 모든 구현이 범용 구조 위에 올라갈 수 있다.**

---

### BE-M1 · `reservations` 테이블 범용화 + 매크로 참조 기반 재설계

**의존** : BE-03 (Alembic 마이그레이션)

**설계 배경**:

> 기존에는 각 예약 조건이 브라우저 시연으로 캡처한 **액션 시퀀스(target_actions JSONB)**를 직접 포함했다.
> 그러나 하나의 사이트가 **여러 매크로**를 가질 수 있으며, 매크로의 실행 레시피(셀렉터 목록)는
> `selectors` 테이블에 `macro_name`으로 이미 그룹핑되어 저장된다.
>
> 따라서 `reservations`는 "어떤 매크로를 어떤 우선순위로 실행할지"만 정의하고,
> 실제 실행 절차(셀렉터)는 `selectors` 테이블에서 `macro_name`으로 조회한다.
> `fill` 타입 요소의 런타임 입력값만 `fill_overrides JSONB`로 별도 보관한다.

**변경 내용**:

```sql
-- AS-IS (기차 예약 특화, 단일 조건)
reservations (
  departure    VARCHAR,
  destination  VARCHAR,
  travel_date  VARCHAR,
  seat_type    VARCHAR,
  is_active    BOOLEAN
)

-- TO-BE (범용 + 매크로 참조 기반)
reservations (
  id                   SERIAL PK,
  site_name            VARCHAR      NOT NULL,  -- FK → sites
  macro_name           VARCHAR      NOT NULL,  -- selectors 테이블의 macro_name과 일치
  fill_overrides       JSONB,                  -- fill 타입 셀렉터의 런타임 값 지정 (선택사항)
  priority             INTEGER      NOT NULL DEFAULT 1,  -- 낮을수록 먼저 시도
  is_active            BOOLEAN      NOT NULL DEFAULT TRUE,
  is_done              BOOLEAN      NOT NULL DEFAULT FALSE,  -- 예약 성공 후 완료 처리
  success_url_pattern  VARCHAR,                -- 성공 판정 URL 패턴 (선택사항, 예: "/confirm")
  created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
)
```

**`fill_overrides` JSONB 형식**:

```json
{
  "#dpt_stn_nm": "서울",
  "#arv_stn_nm": "부산"
}
```

> 키: 셀렉터 문자열, 값: 해당 fill 요소에 입력할 텍스트
> fill_overrides가 없으면 selectors 테이블에 저장된 기본값(있을 경우)을 사용

**매크로-예약 관계 예시**:

| macro_name | priority | fill_overrides | 설명 |
|---|---|---|---|
| KTX 서울→부산 9시 | 1 | `{"#dpt": "서울", "#arv": "부산"}` | 온보딩으로 날짜·시간 버튼 캡처됨 |
| 무궁화 서울→대전 | 2 | `{"#dpt": "서울", "#arv": "대전"}` | 별도 온보딩으로 등록된 다른 매크로 |

> 💡 **핵심**: 같은 매크로를 다른 fill 값으로 여러 예약에 등록할 수 있다.
> (예: "KTX 매크로"를 서울→부산 priority 1, 서울→대전 priority 2로 각각 등록)

**Agent 지시**:

- 기존 `departure`, `destination`, `travel_date`, `seat_type`, `target_actions` 컬럼 제거
- `macro_name VARCHAR NOT NULL` 추가
- `fill_overrides JSONB` 추가 (NULL 허용)
- `priority INTEGER NOT NULL DEFAULT 1` 추가
- `is_done BOOLEAN NOT NULL DEFAULT FALSE` 추가
- `success_url_pattern VARCHAR` 추가 (NULL 허용)

**검증 기준** : Alembic 마이그레이션 성공 후 `macro_name` 기반 INSERT/SELECT 정상 동작, `fill_overrides` JSONB NULL 및 값 저장 모두 확인

---

### BE-M2 · `selectors.element_type` 확장

**의존** : BE-M1

#### element_type 값 확장

현재 `element_type`은 `input / button / select` 3가지만 구분한다. 아래 1개 값을 추가한다.

| element_type | 역할 | 등록 방법 |
|---|---|---|
| `action` | 입력/클릭 실행 요소 | 클릭 → 자동 캡처 (기존) |
| `input` / `button` / `select` | 세부 태그 구분 | 클릭 → 자동 캡처 (기존) |
| `success_indicator` | 예약 완료 화면에 나타나는 요소 (성공 판정 ① 기준) | 완료 화면 클릭 → 캡처 (기존) |

> 💡 **설계 원칙**: 매크로는 "언제 시도할지 판단"하지 않는다. `새로고침 → actions 실행 → success_indicator 확인 → 실패 시 재시도` 루프로 동작한다.
> 매진/disabled 상태의 버튼도 DOM에 존재하므로 온보딩 시 클릭 캡처가 가능하다.

**Agent 지시**:

- `db/models.py`의 `Selector` 모델 `element_type` 컬럼 주석 업데이트
- `ACRO_DDL.sql` `selectors` 테이블 COMMENT 수정 — `success_indicator` 추가
- DB 컬럼 타입(VARCHAR) 변경 불필요, 단순 값 확장

**검증 기준**:

- `element_type = 'success_indicator'` INSERT 성공

---

### BE-M3 · Alembic 마이그레이션 실행

**의존** : BE-M1, BE-M2

```bash
cd acro/be
alembic revision --autogenerate -m "phase_m_generic_reservations"
alembic upgrade head
```

> ⚠️ 기존 `reservations` 테이블 데이터가 있다면 마이그레이션 전 백업 또는 삭제 필요.
> `departure` 등 기존 컬럼 및 `target_actions` JSONB 컬럼은 DROP.
> `selectors` 테이블에 `macro_name VARCHAR` 컬럼 추가 (NOT NULL → 기존 row가 있다면 먼저 값을 채운 후 NOT NULL 제약 추가).

**검증 기준** : `psql`에서 `\d reservations` 실행 시 `macro_name varchar`, `fill_overrides jsonb`, `priority integer`, `is_done boolean`, `success_url_pattern varchar` 컬럼 확인 / `\d selectors` 에서 `macro_name varchar` 컬럼 확인

---

### BE-M4 · 매크로 예약 CRUD API (`routers/reservation.py`)

**의존** : BE-M3

구현할 엔드포인트:

```python
# routers/reservation.py
router = APIRouter(prefix="/reservations", tags=["Reservations"])

# POST /reservations          — 예약 등록 (매크로 참조 + fill_overrides + priority)
# GET  /reservations?site_name=korail — 해당 사이트 is_active 예약 priority 오름차순 반환
# DELETE /reservations/{id}   — 예약 삭제
# PATCH  /reservations/{id}/done — is_done=TRUE 처리 (매크로 성공 후 호출)
```

**Agent 지시**:

```python
class ReservationCreate(BaseModel):
    site_name: str
    macro_name: str                        # selectors 테이블의 macro_name 참조
    fill_overrides: dict[str, str] | None = None  # {selector: value} fill 런타임 값
    priority: int = 1
    success_url_pattern: str | None = None

class ReservationResponse(BaseModel):
    id: int
    site_name: str
    macro_name: str
    fill_overrides: dict | None
    priority: int
    is_active: bool
    is_done: bool
    success_url_pattern: str | None
    created_at: datetime
```

> `main.py`에 `app.include_router(reservation.router)` 등록 필수.

**검증 기준** :

- `POST /reservations` → `macro_name`, `fill_overrides` JSONB DB 저장
- `GET /reservations?site_name=korail` → `priority` 오름차순 목록 반환, 각 항목 `macro_name` 포함
- `PATCH /reservations/{id}/done` → `is_done=TRUE` 업데이트 확인

---

### FE-M1 · `Reservation.jsx` — 매크로 목록 관리 & 새 매크로 온보딩 연동

**의존** : BE-M4, FE-03 (`Sites.jsx`), FE-07 (`Onboarding.jsx`)

**핵심 변경**: 미니 온보딩 캡처 패널 방식 → **사이트별 매크로 목록 표시 + 새 매크로는 전체 온보딩으로 등록**

**설계 원칙**:

> 하나의 사이트는 여러 매크로를 가질 수 있다.
> 각 매크로는 독립적인 온보딩 세션으로 캡처한 셀렉터 집합이다.
> Reservation 페이지는 매크로 목록 관리 + 예약 우선순위 설정 화면이 된다.
> 새 매크로 추가는 기존 온보딩 플로우(`/onboarding?site=xxx&mode=add_macro`)를 그대로 사용한다.

**UI 흐름**:

```
┌─────────────────────────────────────────────────────────────┐
│  사이트 선택: [ korail ▼ ]                                   │
├─────────────────────────────────────────────────────────────┤
│  등록된 매크로 목록                                          │
│  ┌──────────────────────────┬────────┬──────┬──────┬──────┐ │
│  │ 매크로 이름              │ 셀렉터 │ 순위 │ 상태 │      │ │
│  ├──────────────────────────┼────────┼──────┼──────┼──────┤ │
│  │ 🔗 KTX 서울→부산 9시    │  6개   │  1   │ 대기 │  🗑  │ │
│  │ 🔗 무궁화 서울→대전     │  4개   │  2   │ 대기 │  🗑  │ │
│  │ 🔗 KTX 서울→부산 15시 ✅│  6개   │  3   │ 완료 │      │ │
│  └──────────────────────────┴────────┴──────┴──────┴──────┘ │
│                              [ + 새 매크로 등록 시작 ]       │
└─────────────────────────────────────────────────────────────┘
```

- **매크로 행 클릭** → `/selectors?site=korail&macro=KTX+서울→부산+9시` (상세보기·수정)
- **[+ 새 매크로 등록 시작]** → `/onboarding?site=korail&mode=add_macro` 이동 (새 온보딩 세션 시작)
- **🗑 삭제** → `DELETE /reservations/{id}` 호출 후 목록 갱신

**구현 핵심**:

```javascript
// Reservation.jsx
import { useNavigate, useSearchParams } from "react-router-dom";
import { getMacros } from "../api/onboarding";
import { getReservations, deleteReservation } from "../api/reservation";

// ① 사이트 선택 시 매크로 목록 + 예약 목록 병렬 로드
const { data: macros } = useQuery({
  queryKey: ["macros", selectedSite],
  queryFn: () => getMacros(selectedSite),    // GET /macros?site_name=xxx
  enabled: !!selectedSite,
});

const { data: reservations, refetch } = useQuery({
  queryKey: ["reservations", selectedSite],
  queryFn: () => getReservations(selectedSite),  // GET /reservations?site_name=xxx
  enabled: !!selectedSite,
});

// ② 매크로 + 예약 정보 병합 (매크로 이름 기준으로 join)
const macroRows = (macros ?? []).map(macro => {
  const reservation = (reservations ?? []).find(r => r.macro_name === macro.macro_name);
  return {
    macro_name:     macro.macro_name,
    selector_count: macro.selector_count,
    reservation_id: reservation?.id ?? null,
    priority:       reservation?.priority ?? "-",
    is_done:        reservation?.is_done ?? false,
    is_active:      reservation?.is_active ?? false,
  };
});

// ③ 새 매크로 등록: 온보딩 페이지로 이동 (add_macro 모드)
const navigate = useNavigate();
const handleAddMacro = () => {
  navigate(`/onboarding?site=${selectedSite}&mode=add_macro`);
};

// ④ 매크로 클릭 → 상세보기
const handleMacroClick = (macroName) => {
  navigate(`/selectors?site=${selectedSite}&macro=${encodeURIComponent(macroName)}`);
};

// ⑤ 예약 삭제
const handleDelete = async (reservationId) => {
  await deleteReservation(reservationId);
  refetch();
};
```

**api/reservation.js 신규 파일**:

```javascript
import { apiClient } from "./client";

export const getReservations = (siteName) =>
  apiClient.get("/reservations", { params: { site_name: siteName } });

export const createReservation = (data) =>
  // data: { site_name, macro_name, fill_overrides?, priority, success_url_pattern? }
  apiClient.post("/reservations", data);

export const deleteReservation = (id) =>
  apiClient.delete(`/reservations/${id}`);
```

> 💡 **핵심 플로우 요약**:
> 1. 사이트 관리(`/sites`) → [온보딩 시작] → 매크로 이름 입력 → 온보딩 완료 → 첫 번째 매크로 등록
> 2. 매크로 관리(`/macro`) → 사이트 선택 → [+ 새 매크로 등록 시작] → 온보딩(`add_macro` 모드) → 두 번째 매크로 등록
> 3. 매크로 행 클릭 → `/selectors?site=xxx&macro=yyy` → 셀렉터 상세보기·수정

**검증 기준** :

- 사이트 선택 → `GET /macros?site_name=xxx` + `GET /reservations?site_name=xxx` 병렬 호출
- 매크로 목록에 등록된 온보딩 결과 표시 (매크로 이름, 셀렉터 수)
- 매크로 행 클릭 → `/selectors?site=xxx&macro=yyy` 이동 확인
- [+ 새 매크로 등록 시작] → `/onboarding?site=xxx&mode=add_macro` 이동 확인
- 온보딩 완료(add_macro 모드) 후 Reservation 페이지로 복귀 시 새 매크로 목록 반영 확인

---

### FE-M2 · `SelectorConfirm.jsx` — `element_type` 드롭다운 추가

**의존** : FE-06 (기존 `SelectorConfirm.jsx`)

온보딩 완료 후 사용자가 각 셀렉터의 `element_type`을 직접 지정할 수 있도록 드롭다운을 추가한다.

**변경 내용**:

```jsx
// 기존 테이블에 element_type 열 추가
const ELEMENT_TYPES = [
  { value: "action",            label: "⚙️ 액션 (입력/클릭)" },
  { value: "success_indicator", label: "✅ 예약 완료 확인 요소" },
  { value: "input",             label: "📝 입력 필드" },
  { value: "button",            label: "🖱️ 버튼" },
  { value: "select",            label: "📋 선택 드롭다운" },
  { value: "radio",             label: "🔘 라디오 버튼" },
  { value: "checkbox",          label: "☑️ 체크박스" },
];

// 테이블 컬럼 추가
<td>
  <select value={item.element_type} onChange={...}>
    {ELEMENT_TYPES.map(t => <option value={t.value}>{t.label}</option>)}
  </select>
</td>
```

> 💡 AI 추론이 `element_type`을 자동 결정하지 않으므로, 사용자가 `success_indicator`를 수동으로 지정한다.
> 기본값은 태그 기반 추론(`input` → `action`, `button` → `action`)을 유지하되 변경 가능.

**검증 기준** : 드롭다운에서 `success_indicator` 선택 후 저장 시 DB `element_type` 컬럼에 정상 반영

---

### ✅ Phase M 통합 검증

**시나리오 A**: 최초 온보딩 → 첫 번째 매크로 등록

1. `/sites` 에서 코레일 사이트 추가 → [온보딩 시작] 클릭
2. Onboarding Step 1: 사이트 이름, URL, **매크로 이름("KTX 서울→부산 9시")** 입력
3. 온보딩 완료 → DB 확인: `SELECT macro_name FROM selectors WHERE site_name='korail';` → 'KTX 서울→부산 9시' 존재
4. `/sites` 에서 코레일 카드에 매크로 목록 표시 확인

**시나리오 B**: 매크로 관리에서 두 번째 매크로 추가

1. `/macro` 접속 → 코레일 선택 → 매크로 목록 1개 확인
2. [+ 새 매크로 등록 시작] → `/onboarding?site=korail&mode=add_macro` 이동 확인
3. 매크로 이름("무궁화 서울→대전") 입력 → 온보딩 완료 → `/reservation?site=korail` 복귀
4. 매크로 목록 2개 표시 확인

**시나리오 C**: 매크로 상세보기 + element_type 지정

1. `/reservation` 에서 매크로 행 클릭 → `/selectors?site=korail&macro=KTX+서울→부산+9시` 이동
2. `SelectorDetails.jsx` 에서 "예약 완료" 배너 요소 → `success_indicator`로 타입 변경 후 저장
3. DB 확인: `SELECT element_type FROM selectors WHERE site_name='korail' AND macro_name='KTX 서울→부산 9시';` → `success_indicator` 행 존재

**합격 조건** :

- `selectors.macro_name` 정상 저장 ✅
- `GET /macros?site_name=korail` 매크로 목록 반환 ✅
- Reservation.jsx 매크로 목록 표시 및 상세보기 이동 ✅
- add_macro 모드 온보딩 완료 후 복귀 ✅
- `element_type` 드롭다운 + `success_indicator` DB 반영 ✅

---

## Phase 4 — 자동 예약 매크로 실행


> 온보딩에서 저장한 셀렉터와 세션으로 실제 자동 조작을 수행한다.
> **로그인은 사용자가 직접 수행한 세션 쿠키를 사용한다. 매크로가 로그인을 대신하지 않는다.**

---

### BE-10 · 크롤러 구현 (`crawler/crawler.py`, `crawler/parser.py`)

**의존** : BE-03 (DomSnapshot 테이블)

```python
# crawler/crawler.py
import requests, hashlib

def fetch_page(url: str, session_cookies: dict) -> tuple[str, str]:
    response = requests.get(url, cookies=session_cookies)
    html = response.text
    page_hash = hashlib.md5(html.encode()).hexdigest()
    return html, page_hash
```

크롤링 결과를 `dom_snapshots` 테이블에 저장하고 이전 `page_hash`와 비교. 해시 일치 시 매크로 즉시 실행, 불일치 시 `difflib`로 상세 비교 후 `missing_selectors` 추출.

**검증 기준** : 같은 페이지 2회 크롤링 시 해시 일치, `dom_snapshots` 테이블에 레코드 적재

---

### BE-HB · 인간형 행동 모듈 (`macro/human_behavior.py`)

**의존**: INF-03

> ⚠️ **적용 범위**: 랜덤 딜레이·조건부 새로고침·타이핑 시뮬레이션만 구현.
> IP 우회(프록시/VPN)는 법적 리스크로 인해 포함하지 않는다.

> 🔧 **HUMAN_MODE 토글**: 서버 기동 시 `.env`의 `HUMAN_MODE` 값으로 초기화. **FE 대시보드 토글 버튼**으로 서버 재시작 없이 런타임에서 즉시 on/off 전환 가능. FE 토글 값이 환경변수보다 우선 적용되며, 서버 재시작 시 `.env` 값으로 리셋.

```python
# macro/human_behavior.py
import asyncio
import random
import os

# ---------------------------------------------------------------
# 사람 모드 런타임 토글
# 서버 기동 시 .env 값으로 초기화, GET/POST /settings/human-mode API로 런타임 변경 가능
# ---------------------------------------------------------------
_human_mode: bool = os.getenv("HUMAN_MODE", "true").lower() == "true"

def get_human_mode() -> bool:
    return _human_mode

def set_human_mode(enabled: bool):
    global _human_mode
    _human_mode = enabled


async def random_delay(min_sec: float = 1.0, max_sec: float = 5.0):
    """
    행동 간 랜덤 대기 — 일정 패턴 탐지 방지.
    사람 모드 비활성 시 즉시 반환(대기 없이 다음 단계 진행).
    """
    if not get_human_mode():
        return
    await asyncio.sleep(random.uniform(min_sec, max_sec))


async def conditional_refresh(page, check_available_fn, max_retries: int = 10):
    """
    잔여 좌석이 없으면 새로고침 반복.
    사람이 빈자리 생길 때까지 기다리며 새로고침하는 행동을 시뮬레이션.
    사람 모드 비활성 시 즉시 True 반환(새로고침 없이 진행).

    Args:
        page              : Playwright 페이지 객체
        check_available_fn: page를 받아 bool을 반환하는 async 함수
                            True  = 좌석 있음 (진행 가능)
                            False = 좌석 없음 (새로고침 필요)
        max_retries       : 최대 새로고침 횟수 (기본 10회, 초과 시 포기)

    Returns:
        True  — 좌석 발견 → 매크로 계속 진행
        False — max_retries 초과 (좌석 미발견) → 매크로 중단

    engine.py 사용 예:
        async def check_seat_available(page) -> bool:
            # "잔여석 없음" 메시지가 없으면 좌석 있는 것으로 판단
            return await page.locator(".no-seats-message").count() == 0

        found = await conditional_refresh(page, check_seat_available)
        if not found:
            await broadcast_macro_event({"status": "NO_SEATS", "message": "좌석 없음 — 최대 재시도 초과"})
            return
    """
    if not get_human_mode():
        return True

    for attempt in range(max_retries):
        if await check_available_fn(page):
            return True          # 좌석 발견 → 즉시 진행
        # 좌석 없음 → 사람처럼 잠시 기다린 후 새로고침
        await random_delay(2.0, 6.0)
        await page.reload()
        await random_delay(1.5, 3.0)

    return False                 # 최대 횟수 초과 → 포기


async def human_type(page, selector: str, text: str):
    """
    문자 단위 타이핑 — page.fill() 대신 사용.
    각 문자 입력 사이 0.05~0.25초 랜덤 딜레이로 즉각적 fill 탐지 회피.
    사람 모드 비활성 시 page.fill()로 즉시 입력.
    """
    if not get_human_mode():
        await page.fill(selector, text)
        return
    await page.click(selector)
    for char in text:
        await page.type(selector, char)
        await asyncio.sleep(random.uniform(0.05, 0.25))


async def random_scroll(page):
    """
    클릭 전 소량 스크롤 후 복귀.
    화면 탐색 없이 즉시 클릭하는 봇 패턴 방지.
    사람 모드 비활성 시 즉시 반환(스크롤 없이 진행).
    """
    if not get_human_mode():
        return
    scroll_y = random.randint(80, 300)
    await page.evaluate(f"window.scrollBy(0, {scroll_y})")
    await random_delay(0.3, 1.0)
    await page.evaluate(f"window.scrollBy(0, -{scroll_y})")
```

**API 추가** (`routers/settings.py`):

```python
# routers/settings.py
from fastapi import APIRouter
from pydantic import BaseModel
from macro import human_behavior

router = APIRouter(prefix="/settings", tags=["Settings"])

class HumanModeBody(BaseModel):
    enabled: bool

@router.get("/human-mode")
async def get_human_mode():
    """현재 사람 모드 상태 조회 — FE 대시보드 토글 초기값 로드 시 사용"""
    return {"enabled": human_behavior.get_human_mode()}

@router.post("/human-mode")
async def set_human_mode(body: HumanModeBody):
    """사람 모드 런타임 변경 — FE 대시보드 토글 버튼이 호출"""
    human_behavior.set_human_mode(body.enabled)
    return {"enabled": body.enabled}
```

> ⚠️ `main.py`에 `app.include_router(settings.router)` 등록 필수.

**검증 기준**:

- `GET /settings/human-mode` → `{ "enabled": true }` 응답 (기본값)
- `POST /settings/human-mode` `{ "enabled": false }` 호출 후 `random_delay()` 즉시 반환 확인 (서버 재시작 없이)
- FE 토글 후 매크로 실행 시 `HUMAN_MODE=true` 시 대기 동작 / `HUMAN_MODE=false` 시 즉시 진행 확인

---

### BE-11 · 매크로 엔진 (`macro/engine.py`, `macro/selector.py`)

**의존** : BE-09, BE-10

- **셀렉터 로드**: `GET /reservations?site_name=xxx` → `priority` 오름차순으로 각 예약의 `macro_name` 확인 → `GET /selectors?site_name=xxx&macro_name=yyy` 로 해당 매크로 셀렉터 로드
- `selectors.element_order` 오름차순으로 요소 순회
- `element_type`별 분기 (**인간형 행동 모듈 통합**):
  - `input` → `human_type(page, selector, value)` — `value`는 `reservation.fill_overrides[selector]` 우선, 없으면 selector의 기본값 (**`page.fill()` 대신 사용**)
  - `button` → `random_scroll(page)` 후 `page.click(selector)`
  - `select` → `page.select_option(selector, value)`
  - `success_indicator` → 액션 실행 후 해당 요소 존재 여부로 성공 판정
- 결과 페이지 진입 후: `await conditional_refresh(page, check_available_fn)` 호출 — 잔여 좌석 없으면 새로고침 반복 (최대 10회). `check_available_fn`은 `success_indicator` 셀렉터 존재 여부로 판정.
- 각 셀렉터 처리 전: `await random_delay(1.0, 4.0)` 호출
- `patchright` + `playwright-stealth` 2.x(`Stealth` 클래스) 적용 필수 (코레일/SRT 봇 감지 우회)
- 세션 로드: `context = await browser.new_context(storage_state=session_path)` 로 쿠키 복원
- 세션 만료 감지: `page.url`이 로그인 페이지로 redirect되면 WS로 `SESSION_EXPIRED` 이벤트 전송

**API 추가** (`routers/macro.py`):

```python
# POST /macro/run  → body: { "site_name": "..." }
# POST /macro/stop → body: { "site_name": "..." }
# GET  /macro/status?site_name=korail
```

매크로 각 단계 로그는 `main.py`의 `broadcast_macro_event()`를 통해 `/ws` 클라이언트에 전송한다:

```python
# engine.py 내 로그 전송 예시
from main import broadcast_macro_event
await broadcast_macro_event({"type": "LOG", "level": "SUCCESS", "message": "출발역 입력 완료"})
await broadcast_macro_event({"type": "MACRO_STATUS", "status": "running"})
```

**검증 기준** : 저장된 세션과 셀렉터로 예약 페이지 요소를 `element_order` 순서대로 조작. `fill_overrides` 값이 셀렉터 기본값 대신 적용되는지 확인. 각 단계 `/ws` 클라이언트에 `LOG` 메시지 수신 확인.

---

### FE-08 · 공통 컴포넌트 (`StatusBadge.jsx`, `LogViewer.jsx`, `DisclaimerModal.jsx`)

**의존** : INF-04

**StatusBadge.jsx**:

```javascript
// props: status ("running" | "idle" | "error" | "onboarding_required" | "self_healing")
const colors = {
  running: "bg-green-500",
  idle: "bg-gray-400",
  error: "bg-red-500",
  onboarding_required: "bg-yellow-500",
  self_healing: "bg-purple-500", // AI 복구 중
};
```

**LogViewer.jsx**:

```javascript
// props: logs [{level, message, timestamp}]
// 로그 타입별 색상
const levelColors = {
  INFO: "text-white",
  SUCCESS: "text-green-400",
  WARNING: "text-yellow-400",
  ERROR: "text-red-400",
  AI_FIX: "text-purple-400", // AI 자동 수정
};
// 자동 스크롤: useEffect로 최신 로그가 항상 하단에 보이도록
```

**DisclaimerModal.jsx** [NEW]:

```javascript
// props: show (bool), onClose (isChecked: bool) => void
// 대시보드 최초 접속 시 화면 전체를 덮는 법적 고지 모달
// - 학습 목적 명시 및 사용자 책임 고지 내용 표시
// - "오늘 하루 보지 않기" 체크박스 → localStorage 기반 24시간 숨김 처리
// - Dashboard.jsx 마운트 시 localStorage 조회하여 show/hide 결정
```

**검증 기준** : 각 컴포넌트 단독 렌더링 시 props별 스타일 올바르게 적용 / DisclaimerModal: 최초 접속 시 모달 표시, "오늘 하루 보지 않기" 체크 후 재접속 시 미표시 확인

---

### FE-09 · `Reservation.jsx` — 매크로 관리 (구 예약 조건 설정)

**의존** : FE-02

- 사이트 선택 드롭다운 (`GET /sites`, `is_onboarded = true` 사이트만)
- 출발지 / 도착지 입력
- 날짜 선택
- 좌석 종류 선택
- [저장] 버튼 → `POST /reservations`
- [매크로 실행] 버튼 → `POST /macro/run`

**`api/macro.js` 생성** (FE-02 도메인 분리 원칙 준수 — `api/client.js`에 추가하지 않는다):

```javascript
// api/macro.js
import { apiClient } from "./client";

export const runMacro = (siteName) =>
  apiClient.post("/macro/run", { site_name: siteName });
export const stopMacro = (siteName) =>
  apiClient.post("/macro/stop", { site_name: siteName });
export const getMacroStatus = (siteName) =>
  apiClient.get(`/macro/status?site_name=${siteName}`);
```

**`api/reservation.js` 생성**:

```javascript
// api/reservation.js
import { apiClient } from "./client";

export const createReservation = (data) =>
  apiClient.post("/reservations", data);
export const getReservations = (siteName) =>
  apiClient.get("/reservations", { params: { site_name: siteName } });
```

`Reservation.jsx`에서 `getSites(true)`(is_onboarded=true 필터)로 온보딩 완료 사이트만 드롭다운에 표시한다 (`api/sites.js`의 `getSites` 참조).

**검증 기준** : 사이트 선택 후 [저장] 클릭 시 `POST /reservations` 200 응답, DB 저장 확인 / [매크로 실행] 클릭 시 `POST /macro/run` 200 응답

---

### FE-10 · `Dashboard.jsx` — 메인 대시보드 기본 구현

**의존** : FE-08, FE-05

- 사이트별 매크로 상태 카드 (`StatusBadge` 포함)
- `useWebSocket(VITE_WS_URL)` 연결
- `LogViewer` 통합 (WS 메시지 → logs 배열 append)
- 매크로 실행/중지 버튼
- 세션 만료 알림 배너: WS `SESSION_EXPIRED` 수신 시 표시
- **사람 모드 토글 버튼**: 대시보드 상단 제어 영역에 배치. 마운트 시 `GET /settings/human-mode`로 현재 상태 조회 후 토글 상태 초기화. 버튼 클릭 시 `POST /settings/human-mode`로 즉시 반영.

**`api/settings.js` 생성** (FE-02 도메인 분리 원칙 준수):

```javascript
// api/settings.js
import { apiClient } from "./client";

export const getHumanMode = () => apiClient.get("/settings/human-mode");

export const setHumanMode = (enabled) =>
  apiClient.post("/settings/human-mode", { enabled });
```

**사람 모드 토글 UI**:

```jsx
// Dashboard.jsx — 상단 제어 영역
const [humanMode, setHumanModeState] = useState(true);

useEffect(() => {
  getHumanMode().then((res) => setHumanModeState(res.data.enabled));
}, []);

const toggleHumanMode = async () => {
  const next = !humanMode;
  await setHumanMode(next);
  setHumanModeState(next);
};

// 렌더링
<button
  onClick={toggleHumanMode}
  className={humanMode ? "bg-green-500 text-white" : "bg-gray-400 text-white"}
>
  사람 모드: {humanMode ? "ON" : "OFF"}
</button>;
```

> 💡 토글 상태는 서버 상태를 직접 반영. FE 로컬 상태(`humanMode`)는 서버 응답 기준으로만 갱신하며 낙관적 업데이트는 사용하지 않는다.

**검증 기준** : 매크로 실행 후 LogViewer에 `INFO`/`SUCCESS` 타입 로그 실시간 표시 / 토글 OFF 후 매크로 실행 시 랜덤 딜레이 없이 즉시 진행 확인 / 페이지 새로고침 후 토글 상태 서버 값과 일치 확인

---

### ✅ Phase 4 통합 검증

**시나리오**: 매크로 예약 설정 → 매크로 자동 실행

1. `http://localhost:5173/macro` 에서 조건 입력 후 [저장]
2. `http://localhost:5173` 대시보드로 이동, [매크로 실행] 클릭
3. **가상 브라우저(개발 환경: 로컬 창)에서** 저장된 세션으로 예약 화면 진입 확인
4. `element_order` 순서대로 출발역 → 도착역 → 날짜 → [조회] 자동 조작 확인
5. 각 단계마다 대시보드 LogViewer에 `SUCCESS` 로그 실시간 표시 확인

**합격 조건** : 매크로 순서대로 동작 ✅ / 대시보드 로그 실시간 표시 ✅ / patchright + playwright-stealth 적용 (봇 차단 없음) ✅ / `HUMAN_MODE=true` 시 human_behavior 모듈 정상 동작 (랜덤 딜레이·conditional_refresh·문자 단위 타이핑 확인) ✅ / `HUMAN_MODE=false` 시 대기 없이 즉시 진행 확인 ✅

> 💡 **MOCK-TRAIN 연동 테스트**: Phase 4 검증 시 실제 코레일 대신 `http://localhost:5174` (MOCK-TRAIN 모의 사이트)를 타겟으로 사용하는 것을 권장. 법적 리스크 없이 매크로 동작과 봇 탐지 우회를 동시에 검증 가능.

---

## Phase 5 — AI 자가 복구 & 모니터링 (Self-Healing)

> DOM이 변경되어 매크로가 실패했을 때 AI가 자동으로 새 셀렉터를 찾아 복구한다.

---

### BE-12 · AI 변경 감지 (`ai/detector.py`)

**의존** : BE-10

```python
# ai/detector.py
import difflib

def detect_changes(old_html: str, new_html: str, stored_selectors: list[str]) -> dict:
    diff = list(difflib.unified_diff(
        old_html.splitlines(), new_html.splitlines(), lineterm=""
    ))
    missing = [sel for sel in stored_selectors if sel not in new_html]
    return {
        "has_change": bool(diff),
        "missing_selectors": missing,
        # 1차 판단 — LangGraph에서 LLM으로 재판단
        "severity": "minor" if missing else "major"
    }
```

**검증 기준** : 셀렉터가 제거된 HTML 입력 시 `missing_selectors`에 해당 셀렉터 포함

---

### BE-13 · LangGraph 복구 에이전트 (`ai/agent.py`)

**의존** : BE-12, BE-06

> ⚠️ DOM 전체를 LLM에 넘기면 토큰 초과. `missing_selectors` 주변 영역만 추출하거나 **3,000자 이내**로 잘라서 전달.
> `MAX_RECOVERY_ATTEMPTS` 환경변수로 무한 루프 방지.

5개 노드 `StateGraph` 구성:

| 노드       | 역할                                                           |
| ---------- | -------------------------------------------------------------- |
| `judge`    | LLM으로 severity 재판단 (minor/major) — DOM 3,000자 이내       |
| `find`     | LLM으로 새 DOM에서 기존 역할에 맞는 셀렉터 후보 추론           |
| `verify`   | Playwright로 후보 셀렉터 실존 여부 검증                        |
| `save`     | 복구 셀렉터 DB 업데이트 + WS `RECOVERY_COMPLETE` 전송          |
| `escalate` | `sites.is_onboarded = false` + WS `REONBOARDING_REQUIRED` 전송 |

분기 규칙 (`route_after_verify`):

```python
def route_after_verify(state):
    if state["severity"] == "major":         return "escalate"
    if not state["failed"]:                  return "save"
    if state["attempt_count"] >= int(os.getenv("MAX_RECOVERY_ATTEMPTS", 3)):
                                             return "escalate"
    return "find"  # 재시도
```

**검증 기준** : `missing_selectors`가 있는 state 입력 시 `save` 또는 `escalate` 중 하나로 종료, 무한 루프 없음

---

### FE-11 · `Dashboard.jsx` — 자가 복구 알림 추가

**의존** : FE-10

`lastMessage` 타입별 처리 추가:

```javascript
useEffect(() => {
  if (!lastMessage) return;
  switch (lastMessage.type) {
    case "LOG":
      setLogs((prev) => [...prev, lastMessage]);
      break;
    case "MACRO_STATUS":
      setStatus(lastMessage.status);
      break;
    case "SESSION_EXPIRED":
      setSessionExpiredSite(lastMessage.site_name); // 배너 표시
      break;
    case "RECOVERY_COMPLETE":
      setRecoveryInfo(lastMessage.changed_selectors); // 변경 내역 표시
      break;
    case "REONBOARDING_REQUIRED":
      setReonboardingSite(lastMessage.site_name); // 재온보딩 버튼 표시
      break;
  }
}, [lastMessage]);
```

- `SESSION_EXPIRED` → 상단 배너 "세션이 만료되었습니다. 재로그인 후 온보딩을 다시 진행해주세요."
- `RECOVERY_COMPLETE` → 알림 카드 "AI가 셀렉터를 자동 수정했습니다. 변경 내역 보기"
- `REONBOARDING_REQUIRED` → 경고 카드 "사이트 구조가 변경되었습니다. 재온보딩이 필요합니다." + [재온보딩 시작] 버튼

**검증 기준** : 각 WS 이벤트 수신 시 대응하는 UI 요소 렌더링 확인

---

### ✅ Phase 5 통합 검증

**시나리오**: 셀렉터 의도적 파손 → AI 복구 → 매크로 재시도

1. DB에서 `selectors.selector` 하나를 존재하지 않는 값(예: `#invalid_selector`)으로 수동 변경
2. 대시보드에서 [매크로 실행] 클릭
3. 매크로 실행 중 요소 찾기 실패 발생
4. 대시보드 LogViewer에 `"DOM 변경 감지. 복구 프로세스 시작"` `WARNING` 로그 표시 확인
5. StatusBadge가 `self_healing` (보라색)으로 변경 확인
6. LangGraph 에이전트가 새 셀렉터를 찾아내어 DB 업데이트
7. 대시보드에 `AI_FIX` 로그 + `RECOVERY_COMPLETE` 알림 표시 확인
8. 매크로 자동 재시도 → 성공

**합격 조건** : 복구 감지 로그 ✅ / self_healing 상태 배지 ✅ / DB `selectors.last_verified` 갱신 ✅ / 매크로 재시도 성공 ✅

---

## Phase 6 — 배포 환경 검증 (Podman Compose)

> 개발 환경에서 동작한 전체 시스템을 컨테이너 환경으로 올려 검증한다.

---

### INF-06 · `compose.yaml` 작성

**의존** : Phase 5 통합 검증 통과

```yaml
version: "3.8"
services:
  acro-db:
    image: postgres:16
    container_name: acro-db
    environment:
      POSTGRES_USER: acro_user
      POSTGRES_PASSWORD: acro_password
      POSTGRES_DB: acro_db
    ports: ["5432:5432"]
    volumes: [final_pgdata:/var/lib/postgresql/data]

  acro-ai:
    image: ollama/ollama
    container_name: acro-ai
    ports: ["11434:11434"]

  acro-backend:
    build: { context: ./be, dockerfile: Dockerfile }
    container_name: acro-backend
    ports: ["8000:8000", "6080:6080"]
    environment:
      - DISPLAY=:99 # ← 필수. 없으면 Playwright 브라우저 실행 불가
      - DATABASE_URL=postgresql+asyncpg://acro_user:acro_password@acro-db:5432/acro_db
      - OLLAMA_HOST=http://acro-ai:11434
      - MAX_RECOVERY_ATTEMPTS=3
      - HEADLESS=false
      - SESSION_DIR=./sessions
      - LOG_LEVEL=warning
      - HUMAN_MODE=true # 인간형 행동 모듈 on/off 토글
    depends_on: [acro-db, acro-ai]

  acro-frontend:
    build: { context: ./fe, dockerfile: Dockerfile }
    container_name: acro-frontend
    ports: ["5173:5173"]
    depends_on: [acro-backend]

volumes:
  final_pgdata:
```

`fe/.env.production`:

```bash
VITE_API_BASE_URL=http://localhost:8000
VITE_WS_URL=ws://localhost:8000/ws
VITE_WS_ONBOARDING_URL=ws://localhost:8000/ws/onboarding
VITE_NOVNC_URL=http://localhost:6080/vnc.html?autoconnect=true&resize=remote   # ← 배포 환경: 가상 브라우저 열기 버튼 활성화
VITE_ENV=production
```

**검증 기준** : `podman compose up -d` 후 4개 컨테이너 모두 `Up` 상태

---

### INF-07 · FE Dockerfile 작성

**의존** : INF-06

```dockerfile
FROM node:20-alpine
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
EXPOSE 5173
CMD ["pnpm", "dev", "--host"]
# --host 없으면 컨테이너 외부에서 접근 불가 (필수)
```

**검증 기준** : `http://localhost:5173` 정상 접속

---

### ✅ Phase 6 통합 검증

**시나리오**: 배포 환경에서 전체 플로우 검증

```bash
podman compose up -d
curl http://localhost:5173       # FE
curl http://localhost:8000/docs  # BE API 문서
curl http://localhost:6080       # noVNC
curl http://localhost:11434/api/tags  # Ollama + llama3.2 확인
```

1. `http://localhost:5173/onboarding` 에서 온보딩 시작
2. **FE 화면에 "가상 브라우저 열기" 버튼 렌더링 확인** 및 새 창 팝업에 실제 브라우저 화면 표시 확인
3. 온보딩 → 매크로 실행 → AI 복구 전체 플로우 재검증

**합격 조건** : 가상 브라우저 버튼 및 새 창 렌더링 정상 ✅ / 4개 컨테이너 연동 ✅ / 전체 플로우 동작 ✅

---

## 전체 Phase 의존 흐름

```
Phase 0 (인프라)
  INF-01 → INF-02 → INF-03
         → INF-04

Phase 1 (사이트 관리)              ← ✅ 검증: FE 사이트 추가/삭제 → DB 확인
  INF-03 → BE-01 → BE-02 → BE-03 → BE-04 (POST·GET·DELETE /sites)
  INF-04 → FE-01 → FE-02 (api/sites.js: getSites·createSite·deleteSite) → FE-03

Phase 2 (가상 브라우저)            ← ✅ 검증: 브라우저 창 오픈 + 환경별 분기
  BE-04  → INF-05 → BE-05
  FE-02  → FE-04

Phase 3 (캡처 & AI 추론)          ← ✅ 검증: 클릭 → AI → WS → DB 저장
  BE-05  → BE-06 → BE-07 (element_type 포함, capture/start에서 세션 저장)
        → BE-08 (/ws/onboarding + /ws 범용 WebSocket + GET /selectors)
        → BE-09 (save_session — capture/start에서 트리거)
  FE-04  → FE-05 → FE-06 → FE-07

Phase 4 (매크로 실행)              ← ✅ 검증: 자동 예약 조작 + 로그
  BE-09  → BE-10 → BE-HB (human_behavior.py) → BE-11 (POST·GET /reservations + macro API + broadcast_macro_event)
  FE-07  → FE-08 → FE-09 (api/macro.js + api/reservation.js) → FE-10

Phase 5 (AI 자가 복구)             ← ✅ 검증: 파손 → 복구 → 재시도
  BE-11  → BE-12 → BE-13
  FE-10  → FE-11

Phase 6 (배포)                     ← ✅ 검증: 컨테이너 전체 플로우
  INF-05 → INF-06 → INF-07
```

---

## Agent 필독 — 전역 주의사항

> 🛡️ `.env.development` / `.env.production` / `sessions/` 는 절대 커밋하지 않는다. INF-01에서 `.gitignore`에 즉시 추가.

> ⚠️ `browser.py`의 `headless` 값은 반드시 `HEADLESS` 환경변수로 결정. 코드 하드코딩 금지.

> ⚠️ `start.sh`(Xvfb + noVNC 기동 스크립트)는 **배포 컨테이너 전용**. 개발 환경에서는 `uvicorn main:app --reload --port 8000`만 실행.

> ⚠️ `capture.py`는 **`ctx.expose_function()` + `page.add_init_script()` + `page.on("load")` + `ctx.on("page", ...)`** 조합으로 JS 클릭 이벤트를 주입해 수집한다. `ctx.add_init_script()`는 신규 page 생성 시에만 동작하므로, 로그인 후 같은 page에서 URL이 변경되는 리다이렉트 케이스는 `page.add_init_script()`와 `page.on("load")` fallback이 처리한다. 새 탭/팝업은 `ctx.on("page")` + `new_page.add_init_script()` + `wait_for_load_state` 3중 보장으로 대응한다. Playwright의 `page.on("click")` 은 DOM 이벤트를 감지할 수 없어 사용하지 않는다. (BE-07 구현 코드 참조)

> ⚠️ 매크로는 저장된 세션 쿠키로 예약 화면에 진입한다. 로그인 자동화가 아님. **"봇이 스스로 로그인"하지 않는다.**

> ⚠️ LLM에 넘기는 DOM은 반드시 **3,000자 이하**로 제한. 토큰 초과 방지.

> ⚠️ 코레일/SRT 봇 감지 우회는 `patchright`(import 교체)와 `playwright-stealth` 2.x(`Stealth().apply_stealth_async(page)`)를 **함께** 적용해야 한다. 매크로 엔진(`engine.py`)에서도 동일하게 적용하며, `playwright.async_api` import는 금지.

> ⚠️ `chain.py`에서 LLM 클라이언트는 `get_llm()` 팩토리를 통해서만 호출. `OllamaLLM` 직접 호출 금지. Ollama → 클라우드 전환 시 `chain.py`만 수정.

> 💡 개발/배포 환경 핵심 차이: `VITE_NOVNC_URL` 유무(FE "가상 브라우저 열기" 버튼 렌더링 여부) / `start.sh` 사용 유무 / `DISPLAY=:99` 환경변수 유무. 환경변수로만 분기하며 코드 분기는 최소화.

---

## 미결 사항 (구현 전 결정 필요)

| 항목                    | 옵션                                                        | 결정 시점             |
| ----------------------- | ----------------------------------------------------------- | --------------------- |
| 운영자 알림 방식        | 앱 내 배너(WS, 현재 구현 기준) / 이메일 / Slack             | 🔴 Phase 5 전         |
| 매크로 실행 트리거      | 수동 실행 버튼(현재) / cron 스케줄 자동 실행                | 🔴 BE-11 구현 전      |
| AI 추론 실패 fallback   | 빈칸 vs "확인 필요" 표시 (후자 권장)                        | 🟡 BE-06 구현 시 선택 |
| DOM 전처리 전략         | 3,000자 cut(단순) vs missing_selectors 주변 영역 추출(정확) | 🔴 BE-13 구현 전      |
| dom_snapshots 보존 정책 | 최신 N개만 유지 vs 전체 보존                                | 🟡 나중에             |
