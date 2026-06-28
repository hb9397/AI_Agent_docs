<!-- 산출물 예시 메타 -->
> 📂 **산출물 예시 — `design-doc` 스킬 (복수 앱)**  
> 산출 경로: `.docs/acro-be/context-base/DESIGN.md`  
> 복수 애플리케이션 프로젝트에서 BE 앱 단위로 분리 생성한 design-doc OUTPUT 예시입니다. (FE 짝: `design-doc--ACRO-FE.md`)

---

# ACRO Backend — 설계 문서
> Adaptive Crawler RObot | `acro/be/`  
> Agent 참조용 · Python + FastAPI 기반

---

## 프로젝트 개요

ACRO는 열차 예약 사이트를 자동으로 예약하는 매크로 시스템이다.  
백엔드는 FastAPI 서버이며, 크롤링 / 온보딩 / 매크로 / AI 모듈을 포함한다.  
사용자가 직접 브라우저에서 로그인 후 예약 화면에서 요소를 클릭하면, AI가 요소 이름을 추론하고 셀렉터를 DB에 저장한다.  
이후 매크로가 저장된 세션과 셀렉터로 자동 예약을 수행한다.  
사이트 구조가 변경되면 크롤러가 감지하고 LangGraph 에이전트가 셀렉터를 자동 수정한다.

---

## 디렉토리 구조

```
acro/
└── be/
    ├── main.py                  # FastAPI 진입점, 라우터 등록, WebSocket
    ├── .env.development         # 개발 환경변수 (노출 금지)
    ├── .env.production          # 배포 환경변수 (노출 금지)
    ├── requirements.txt
    ├── Dockerfile
    ├── start.sh                 # Xvfb → x11vnc → noVNC → uvicorn 기동 스크립트
    │
    ├── routers/                 # 도메인별 API 라우터 분리
    │   ├── __init__.py
    │   ├── site.py              # /sites 엔드포인트
    │   ├── onboarding.py        # /onboarding, /selectors 엔드포인트
    │   ├── reservation.py       # /reservations 매크로 예약 CRUD
    │   └── settings.py          # /settings/human-mode 런타임 토글
    │
    ├── onboarding/              # 온보딩 모듈 — 사이트 최초 등록
    │   ├── browser.py           # patchright headless=False + Xvfb(:99) 실행 (CDP 탐지 우회)
    │   ├── capture.py           # 클릭 요소 HTML 정보 수집 + 셀렉터 추출
    │   └── session.py           # 세션(쿠키) 저장 / 로드
    │
    ├── crawler/                 # 크롤링 모듈 — 변경 감지용
    │   ├── crawler.py           # requests로 HTML 수집
    │   └── parser.py            # BeautifulSoup 셀렉터 파싱
    │
    ├── macro/                   # 매크로 엔진
    │   ├── engine.py            # patchright 자동 예약 실행
    │   ├── selector.py          # DB에서 셀렉터 로드 / 저장
    │   └── human_behavior.py    # 인간형 행동 모듈 (랜덤딜레이·타이핑·새로고침·스크롤)
    │
    ├── ai/                      # AI 모듈
    │   ├── agent.py             # LangGraph 에이전트 (핵심)
    │   ├── detector.py          # difflib DOM 변경 비교
    │   └── chain.py             # LangChain + Ollama 체인
    │
    └── db/
        ├── database.py          # SQLAlchemy + asyncpg 비동기 연결 설정
        └── models.py            # 테이블 모델 정의
```

---

## 메인 로직 흐름

```
[STEP 1] 온보딩 (최초 1회)
  사용자가 직접 브라우저에서 로그인 + 예약 화면 이동
  → 세션(쿠키) 자동 저장
  → 사용자가 요소들을 클릭
  → AI(LangChain)가 각 요소 이름 추론
  → 사용자가 확인 or 수정
  → DB에 셀렉터 + 이름 저장

[STEP 2] 크롤링
  매크로 실행 전 예약 페이지 HTML 수집
  → dom_snapshots 테이블과 비교

[STEP 3] DB 비교
  변경 없음 → STEP 4로 이동
  변경 감지 → AI 에이전트 호출

[STEP 4] 매크로 실행
  저장된 세션으로 예약 화면 진입
  → DB 셀렉터로 자동 예약 수행
  → 세션 만료 시 FE에 재로그인 알림 전송

[STEP 5] 결과 전달
  FastAPI WebSocket으로 FE에 실시간 상태 전달
```

---

## 온보딩 상세 흐름

온보딩은 새 사이트를 최초 등록할 때 1회만 수행한다.  
로그인은 사용자가 직접 하므로 로그인 관련 셀렉터 등록은 불필요하다.

```
1. FE에서 사이트 이름 + URL 입력 → POST /onboarding/start
2. browser.py : patchright headless=False로 Xvfb 가상 화면에 브라우저 실행 (patchright = Chromium 바이너리 패치로 CDP 탐지 우회)
   → 백엔드 컨테이너 내 Xvfb(:99) 가상 모니터에 브라우저가 뜸
   → 사용자는 http://localhost:6080 (noVNC)으로 접속하여 화면 조작
3. 사용자가 직접 로그인 + 예약 화면까지 이동
4. session.py : 세션(쿠키) 저장 → {site_name}_session.json
5. FE에서 "셀렉터 등록 시작" 클릭 → POST /onboarding/capture/start
6. capture.py : 사용자가 클릭하는 요소마다 HTML 정보 수집
   수집 항목: tag, id, class, placeholder, name, nearby_text, selector
7. chain.py : LangChain + Ollama로 요소 이름 추론
   프롬프트 예시: "이 HTML 요소의 역할을 한국어로 한 줄로 답하세요"
   응답 예시: "출발역 입력칸"
8. FE에 추론 결과 전송 → 사용자 확인 or 수정
9. 확정된 이름 + 셀렉터 → selectors 테이블에 저장
10. sites 테이블 is_onboarded = True 업데이트
```

> 💡 **Docker 환경에서의 온보딩**: `headless=False` 브라우저는 Xvfb 가상 모니터(:99)에 실행되며, 사용자는 웹 브라우저에서 `http://localhost:6080` (noVNC)으로 접속해 실시간으로 화면을 보고 클릭합니다.

**`be/Dockerfile` 핵심 패키지**
```dockerfile
FROM mcr.microsoft.com/playwright/python:v1.44.0-jammy

RUN apt-get update && apt-get install -y \
    xvfb x11vnc websockify git \
    && rm -rf /var/lib/apt/lists/*

# noVNC는 pip 대신 git clone 방식이 안정적
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc

# start.sh를 컨테이너 안으로 복사하고 실행 권한 부여
# CMD에서 이 스크립트가 Xvfb → x11vnc → noVNC → uvicorn 순서로 기동함
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

> ⚠️ **Xvfb · x11vnc · websockify · noVNC는 BE 컨테이너에만 설치한다.** Playwright가 BE(`browser.py`)에서 실행되기 때문이며, DB · Ollama · FE 컨테이너에는 불필요하다.

> 💡 **start.sh는 배포 전용이다.** 개발 환경(로컬 VSCode)에서는 `start.sh`를 사용하지 않고 `uvicorn main:app --reload --port 8000`만 실행한다. 로컬 PC에는 실제 모니터가 있으므로 Xvfb · noVNC가 필요 없다.

**`be/start.sh`**
```bash
#!/bin/bash
Xvfb :99 -screen 0 1280x900x24 &
sleep 1   # Xvfb 완전히 뜰 때까지 대기

x11vnc -display :99 -nopw -listen 0.0.0.0 -xkb &
sleep 1   # x11vnc 완전히 뜰 때까지 대기 (websockify 연결 실패 방지)

websockify --web=/opt/novnc/ 6080 localhost:5900 &

uvicorn main:app --host 0.0.0.0 --port 8000
```

---

## AI 에이전트 역할 (LangGraph)

AI는 이 프로젝트에서 두 가지 역할을 한다.

### 역할 1 — 온보딩: 요소 이름 추론
- 담당 파일: `ai/chain.py`
- 입력: 클릭한 요소의 HTML 정보 (tag, id, class, placeholder, nearby_text 등)
- 출력: 요소 역할 이름 (한국어, 한 줄)
- 모델: Ollama (llama3.2, 로컬 실행)

> 💡 **browser.py — HEADLESS 환경변수로 분기**: `headless` 값을 코드에 하드코딩하지 않고 환경변수 `HEADLESS`로 읽어 처리한다. 개발 환경(`HEADLESS=false`)에서는 로컬 PC 모니터에 창이 직접 열리고, 배포 환경(`HEADLESS=false` + Xvfb)에서는 가상 모니터에 창이 열린다.
>
> **중요**: `playwright.async_api` 대신 `patchright.async_api`를 import해야 한다. patchright는 Playwright와 API가 동일하지만 Chromium 바이너리를 패치해 CDP 탐지를 차단한다. `playwright-stealth`의 `Stealth` 클래스(2.x API)를 `goto()` 이전에 함께 적용한다.
> ```python
> # onboarding/browser.py
> import os
> from patchright.async_api import async_playwright  # playwright → patchright
> from playwright_stealth import Stealth             # 2.x API
>
> headless = os.getenv("HEADLESS", "false").lower() == "true"
> browser = await playwright.chromium.launch(headless=headless)
> # ...
> await Stealth().apply_stealth_async(page)  # goto() 이전에 반드시 적용
> await page.goto(url)
> ```

```python
# chain.py 핵심 로직 개념
prompt = f"""
아래는 사용자가 클릭한 HTML 요소 정보입니다.
{element_info}

이 요소의 역할을 한국어로 간단하게 추론해주세요.
예시: 출발역 입력칸, 날짜 선택, 조회 버튼, 예약 버튼
한 줄로만 답하세요.
"""
```

### 역할 2 — 운영 중: 셀렉터 자동 수정
- 담당 파일: `ai/agent.py` (LangGraph), `ai/detector.py`, `ai/chain.py`
- 흐름: 변경 감지 → HTML 분석 → 심각도 판단 → 분기

```
셀렉터 값만 변경  →  자동 수정 후 DB 업데이트 → 매크로 재시도
플로우/구조 변경  →  FE에 알림 → 사용자 재온보딩 요청
```

- LangGraph 노드 구성:
  - `detect_change` : difflib로 HTML 비교
  - `analyze_html`  : LangChain으로 변경 내용 분석
  - `judge_severity`: 단순 셀렉터 변경 vs 구조 변경 판단
  - `auto_fix`      : 자동 수정 가능 시 DB 업데이트
  - `notify_human`  : 구조 변경 시 FE에 알림 (Human-in-the-loop)

> ⚠️ **토큰 한도 주의**: LangGraph 릴레이 시 DOM 전체를 LLM에 넘기면 토큰을 초과하므로, 3,000자 이내로 컷팅하거나 `missing_selectors` 주변부 영역만 추출하는 전처리 레이어가 필수입니다.
> 🔄 **복구 시도 제한**: `MAX_RECOVERY_ATTEMPTS` 환경변수(기본값 3)를 통해 무한 루프를 방지하고 초과 시 재온보딩 경로로 폴백합니다.

---

## DB 테이블 설계

### selectors — 셀렉터 저장
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | SERIAL PK | |
| site_name | VARCHAR | FK (ON DELETE CASCADE) |
| element_name | VARCHAR | AI가 추론한 이름 (예: 출발역 입력칸) |
| selector | VARCHAR | CSS 셀렉터 (#id, .class) |
| element_order | INTEGER | 매크로 실행 순서 (site_name과 복합 UNIQUE) |
| element_type | VARCHAR | `action` / `available_indicator` / `success_indicator` / `input` / `button` / `select` |
| last_verified | TIMESTAMPTZ | 마지막 유효 확인 시각 |
| is_active | BOOLEAN | 활성 여부 (기본값 TRUE) |

> **element_type 값 설명**:
> - `action` — 매크로가 실제로 값을 입력하거나 클릭하는 요소
> - `available_indicator` — 빈자리가 생겼음을 나타내는 요소 (매진 감지 루프 탈출 트리거)
> - `success_indicator` — 예약 완료 화면에 나타나는 요소 (성공 판정 ① 기준)
>
> **인덱스**: `idx_selectors_site_active` `(site_name) WHERE is_active = TRUE`

### sessions — 세션 저장
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | SERIAL PK | |
| site_name | VARCHAR | FK (ON DELETE CASCADE) |
| session_path | VARCHAR | 쿠키 파일 경로 |
| expires_at | TIMESTAMPTZ | 세션 만료 시각 |
| is_valid | BOOLEAN | 유효 여부 (기본값 TRUE) |
| created_at | TIMESTAMPTZ | 기본값 CURRENT_TIMESTAMP |

### dom_snapshots — 변경 감지
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | SERIAL PK | |
| site_name | VARCHAR | FK (ON DELETE CASCADE) |
| page_hash | VARCHAR | MD5 (32 bytes) 해시 |
| snapshot_html | TEXT | 전체 HTML |
| created_at | TIMESTAMPTZ | 기본값 CURRENT_TIMESTAMP |

> **인덱스**: `idx_dom_snapshots_latest` `(site_name, created_at DESC)`

### reservations — 매크로 예약 (BE-M1 범용 구조)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | SERIAL PK | |
| site_name | VARCHAR | FK (ON DELETE CASCADE) |
| target_inputs | JSONB | 온보딩 요소명-값 쌍 `{"출발역 입력칸": "서울", ...}` |
| priority | INTEGER | 실행 우선순위 (낮을수록 우선, 기본값 1) |
| is_active | BOOLEAN | 실행 여부 (기본값 TRUE) |
| is_done | BOOLEAN | 예약 성공 완료 여부 (기본값 FALSE) |
| success_url_pattern | VARCHAR | 성공 판정용 URL 패턴 (선택사항) |
| created_at | TIMESTAMPTZ | 기본값 CURRENT_TIMESTAMP |

> **인덱스**: `idx_reservations_active_running` `(site_name, priority) WHERE is_active = TRUE AND is_done = FALSE`

### sites — 등록 사이트 관리
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | SERIAL PK | |
| site_name | VARCHAR UNIQUE | korail / srt |
| site_url | VARCHAR | |
| is_onboarded | BOOLEAN | 온보딩 완료 여부 (기본값 FALSE) |
| last_crawled | TIMESTAMPTZ | 마지막 크롤링 시각 |
| created_at | TIMESTAMPTZ | 기본값 CURRENT_TIMESTAMP |

---

## API 엔드포인트 목록

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/sites` | 새 사이트 등록 |
| GET | `/sites` | 등록된 사이트 목록 |
| DELETE | `/sites/{site_name}` | 사이트 삭제 (CASCADE) |
| POST | `/onboarding/start` | 온보딩 브라우저 실행 |
| POST | `/onboarding/reset` | 온보딩 초기화 (셀렉터/세션 전체 삭제) |
| POST | `/onboarding/capture/start` | 셀렉터 캡처 시작 |
| POST | `/onboarding/capture/confirm` | AI 추론 결과 확인/수정 저장 |
| POST | `/reservations` | 매크로 예약 등록 (macro_name + priority) |
| GET | `/reservations` | 매크로 예약 목록 (`?site_name=korail`) |
| DELETE | `/reservations/{id}` | 매크로 예약 삭제 |
| PATCH | `/reservations/{id}/done` | 매크로 예약 성공 완료 처리 |
| GET | `/settings/human-mode` | 인간형 행동 모드 상태 조회 |
| POST | `/settings/human-mode` | 인간형 행동 모드 런타임 변경 |
| POST | `/macro/run` | 매크로 실행 |
| POST | `/macro/stop` | 매크로 중지 |
| GET | `/macro/status` | 매크로 현재 상태 |
| GET | `/selectors/{site_name}` | 특정 사이트 셀렉터 목록 |
| WS | `/ws/onboarding/{site_name}` | 온보딩 요소 실시간 스트리밍 |
| WS | `/ws` | 매크로 실시간 상태 추적 및 로그 스트림 |

---

## 라이브러리 목록 (requirements.txt)

```
# 웹 프레임워크
fastapi
uvicorn
websockets

# 매크로 + 온보딩
playwright
playwright-stealth          # 봇 감지 우회 (JS 레벨 패치)
patchright                  # CDP 탐지 우회 — Chromium 바이너리 패치 (코레일 필수)

# 크롤링
requests
beautifulsoup4
lxml
# difflib은 Python 내장

# AI
langchain
langgraph
langchain-ollama
ollama

# DB (PostgreSQL)
sqlalchemy
asyncpg                     # 비동기 드라이버 (FastAPI용)
psycopg2-binary             # 동기 드라이버 (Alembic 마이그레이션용)

# 유틸
pydantic
python-dotenv               # 환경변수 로딩 (main.py 최상단에서 로드 필수)
```

---

## 환경변수

환경변수는 개발/배포 환경을 분리하여 2개의 프로필로 관리한다.

### `.env.development` — 개발 환경 (로컬 VSCode 실행 시)

```bash
# ── DB ──────────────────────────────────────────────
DATABASE_URL=postgresql+asyncpg://acro:acro@localhost:55432/acro_db

# ── AI ──────────────────────────────────────────────
OLLAMA_HOST=http://localhost:11434

# ── Playwright ──────────────────────────────────────
# 개발 환경은 로컬 PC 모니터에 직접 창이 뜨므로 DISPLAY 불필요
# DISPLAY=:99                  # Xvfb 가상 디스플레이 번호 — 배포 전용

# headless=False 로 내 PC에 직접 브라우저 창을 띄움
HEADLESS=false

# ── 세션 ─────────────────────────────────────────────
# 쿠키 파일 저장 경로
SESSION_DIR=./sessions

# ── AI 에이전트 ──────────────────────────────────────
# LangGraph 복구 에이전트 최대 시도 횟수
MAX_RECOVERY_ATTEMPTS=3

# ── 서버 ─────────────────────────────────────────────────
LOG_LEVEL=debug
# 인간형 행동 모듈 on/off 토글 (개발 시 속도 우선)
HUMAN_MODE=false
# CORS 허용 출습 (콤마 구분, *=전체 허용)
CORS_ORIGINS=http://localhost:5173
```

### `.env.production` — 배포 환경 (Podman 컨테이너)

```bash
# ── DB ──────────────────────────────────────────────
# 호스트 PC의 포트 포워딩된 주소로 우회 접근
DATABASE_URL=postgresql+asyncpg://acro:acro@host.containers.internal:55432/acro_db

# ── AI ──────────────────────────────────────────────
# 호스트 PC의 포트 포워딩된 주소로 우회 접근
OLLAMA_HOST=http://host.containers.internal:11434

# ── Playwright ──────────────────────────────────────
# 컨테이너 안에는 모니터가 없으므로 Xvfb 가상 디스플레이 필수
DISPLAY=:99

# start.sh가 Xvfb를 먼저 띄운 뒤 uvicorn을 실행하므로 headless=False 유지
# Xvfb가 가상 모니터 역할을 대신함
HEADLESS=false

# ── 세션 ─────────────────────────────────────────────
SESSION_DIR=./sessions

# ── AI 에이전트 ──────────────────────────────────────
MAX_RECOVERY_ATTEMPTS=3

# ── 서버 ─────────────────────────────────────────────────
LOG_LEVEL=warning
# 인간형 행동 모듈 on/off 토글 (배포 시 활성화)
HUMAN_MODE=true
# CORS 허용 출습 (콤마 구분, *=전체 허용)
CORS_ORIGINS=http://localhost:5173
```

> **📌 dotenv 로딩 주의사항**: Podman 환경변수 오버라이딩을 정상적으로 적용하기 위해, `be/main.py`의 **최상단(프레임워크 및 라우터 import 전)**에서 `load_dotenv()`가 필수적으로 실행되어야 한다. `be/db/database.py`의 경우 특정 파일(`.env.development`)을 하드코딩하지 않고 환경별 기본 우선순위를 따르도록 `load_dotenv()` 기본 동작에 의존한다.

---

## 설치 및 실행

### 방법 A — Podman Compose (배포 테스트)

```bash
# 전체 환경 한 번에 기동
podman compose up -d

# 접속 주소
# Web UI  : http://localhost:5173
# FastAPI  : http://localhost:8000
# noVNC    : http://localhost:6080  ← 온보딩 브라우저 화면
```

### 방법 B — 로컬 직접 실행 (개발 환경 권장)

> 💡 개발 환경에서는 `start.sh`를 사용하지 않는다. Xvfb · noVNC 없이 `uvicorn`만 실행하며, Playwright는 로컬 PC 모니터에 직접 브라우저 창을 띄운다. DB · Ollama는 Podman 컨테이너로 별도 실행한다.

#### 1. 로컬 인프라 세팅 (Podman: DB & AI)

데이터베이스와 AI 모델은 로컬 개발 시 데이터가 날아가지 않도록 반드시 **볼륨(`Volume`)을 마운트**하여 실행한다.

```bash
# 1. PostgreSQL + PostGIS 실행
podman volume create acro-db-data
podman run -d --name acro-db -p 55432:5432 -e POSTGRES_USER=acro -e POSTGRES_PASSWORD=acro -e POSTGRES_DB=acro_db -v acro-db-data:/var/lib/postgresql/data postgis/postgis:15-3.3

# 2. Ollama 실행 및 Llama3.2 모델 다운로드
podman volume create acro-ai-data
podman run -d --name acro-ai -p 11434:11434 -v acro-ai-data:/root/.ollama ollama/ollama:latest
podman exec -it acro-ai ollama pull llama3.2
```

#### 2. 백엔드 가상환경 및 패키지 설치

```bash
# 1. 가상환경 생성 및 활성화
python -m venv venv
venv\Scripts\activate         # Windows
source venv/bin/activate      # Mac/Linux

# 2. 라이브러리 설치
pip install -r requirements.txt

# 3. 브라우저 설치 (patchright — CDP 탐지 우회 패치 적용된 Chromium)
patchright install chromium

# 4. .env.development 파일 기준으로 서버 실행
uvicorn main:app --reload --port 8000
```

---

## 인간형 행동 모듈 (`macro/human_behavior.py`)

봇 탐지 회피를 위해 매크로를 사람처럼 동작시키는 유틸리티 모음.
`macro/engine.py`에서 import하여 각 액션 전후에 호출한다.

> ⚠️ **적용 범위 제한**: 랜덤 딜레이·새로고침·타이핑·스크롤만 적용.
> IP 우회(프록시/VPN/레지덴셜 IP 위장)는 정보통신망법 위반 가능성이 있어 사용하지 않는다.

```python
# macro/human_behavior.py
import asyncio
import random

async def random_delay(min_sec: float = 1.0, max_sec: float = 5.0):
    """
    행동 간 랜덤 대기.
    일정한 요청 간격으로 인한 봇 패턴 탐지를 방지한다.
    """
    await asyncio.sleep(random.uniform(min_sec, max_sec))


async def random_refresh(page, min_times: int = 1, max_times: int = 3):
    """
    예약 시도 전 1~3회 랜덤 새로고침.
    연속 접속 패턴을 자연스럽게 분산시킨다.
    engine.py에서 페이지 최초 진입 후 조회 버튼 클릭 전에 호출.
    """
    count = random.randint(min_times, max_times)
    for _ in range(count):
        await random_delay(2.0, 6.0)
        await page.reload()
        await random_delay(1.5, 4.0)


async def human_type(page, selector: str, text: str):
    """
    문자 단위 타이핑 — 사람 타이핑 속도를 시뮬레이션한다.
    page.fill() 대신 이 함수를 사용해야 즉각적 form fill 탐지를 피할 수 있다.
    engine.py에서 element_type='input' 처리 시 page.fill() 대신 호출.
    """
    await page.click(selector)
    for char in text:
        await page.type(selector, char)
        await asyncio.sleep(random.uniform(0.05, 0.25))


async def random_scroll(page):
    """
    클릭 전 소량 스크롤 후 복귀.
    화면을 보지 않고 즉시 클릭하는 봇 패턴을 방지한다.
    engine.py에서 element_type='button' 처리 직전에 호출.
    """
    scroll_y = random.randint(80, 300)
    await page.evaluate(f"window.scrollBy(0, {scroll_y})")
    await random_delay(0.3, 1.0)
    await page.evaluate(f"window.scrollBy(0, -{scroll_y})")
```

### engine.py 연동 포인트

```python
# macro/engine.py 내 human_behavior 모듈 적용 위치 (개념)
from macro.human_behavior import random_delay, random_refresh, human_type, random_scroll

# 페이지 진입 직후
await random_refresh(page, min_times=1, max_times=3)

# 각 셀렉터 처리 루프
for selector in selectors:
    await random_delay(1.0, 4.0)          # 액션 전 대기
    if selector.element_type == 'input':
        await human_type(page, selector.selector, value)   # 인간형 타이핑
    elif selector.element_type == 'button':
        await random_scroll(page)          # 클릭 전 스크롤
        await page.click(selector.selector)
    elif selector.element_type == 'select':
        await page.select_option(selector.selector, value)
    await random_delay(0.5, 2.0)          # 액션 후 대기
```

---

## 주의사항

- 코레일은 Chrome DevTools Protocol(CDP) 연결 자체를 탐지한다. `patchright`(Chromium 바이너리 패치)와 `playwright-stealth`(JS 레벨 패치)를 함께 사용해야 탐지를 우회할 수 있다.
- `browser.py`는 `patchright.async_api`에서 import한다. `playwright.async_api`로 교체하면 코레일에서 차단된다.
- 세션 만료 시 FE에 WebSocket으로 알림을 전송해야 한다.
- 개인 학습 목적, 본인 계정에서만 사용할 것. 상업적 이용 금지.
- `.env.development` · `.env.production` 파일은 절대 커밋하지 않는다.

---

### 💡 참고: Playwright와 Patchright의 사용 및 관계

**📢 브라우저 자동화 및 봇 탐지(Anti-Bot) 우회 흐름**

> **사용자 스크립트 (Python 등)** 👉 [브라우저 제어 명령] 
👉 **`Playwright` API 구조** 👉 [지문 변조 및 흔적 제거] 
👉 **`Patchright`** (탐지 회피 브라우저) 👉 [DOM 렌더링 / 클릭 동작] 👉 **타겟 웹사이트 (코레일/SRT)**

**1. Playwright**
마이크로소프트(Microsoft)에서 개발한 강력한 오픈소스 브라우저 자동화 프레임워크입니다. 사람이 마우스와 키보드로 수행하는 모든 브라우저 동작을 자동으로 실행하게 해주는 핵심 구동기 역할을 합니다.

**2. Patchright**
기본 Playwright가 남기는 '자동화 봇 고유의 흔적(브라우저 지문)'을 제거하기 위해 프레임워크의 소스 코드를 변조하여 만든 특수 패치 버전입니다. 대상 사이트에 적용된 봇 탐지 솔루션이 스크립트의 접근을 차단하는 것을 막아줍니다.

정확히 말하자면 **"Playwright가 Patchright를 불러서 사용하는 형태"**라기보다는, **"Patchright가 Playwright를 통째로 덮어쓰거나 대체(Drop-in Replacement)해서 사용하는 형태"**로 이해하시는 것이 좀 더 정확합니다.

**덧붙이는 모듈이 아닌 '개조된 복제본'**
Patchright는 Playwright와 별개의 부품으로 작동하여 서로 통신하는 것이 아닙니다. Patchright의 개발자들은 프레임워크인 Playwright의 원본 소스 코드를 통째로 가져온 뒤, 봇 탐지에 걸리는 취약한 부분들만 교묘하게 수정(Patch)하여 아예 새로운 통짜 라이브러리를 만들어 냈습니다.
즉, Playwright의 모든 스티어링 휠(API)과 엔진 기능을 100% 동일하게 가지고 있으면서, 겉모습만 봇이 아닌 일반 사용자처럼 위장한 형태입니다.

**실제 코드 적용에서의 차이**
따라서 개발을 할 때는 Playwright를 실행하고 그 위에 Patchright 플러그인을 얹는 것이 아니라, 처음부터 Playwright 대신 Patchright 라이브러리를 임포트(Import)하여 사용하게 됩니다. 동작하는 함수나 문법은 Playwright와 완벽하게 똑같습니다.
