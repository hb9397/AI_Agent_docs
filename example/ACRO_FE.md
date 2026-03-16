# ACRO Frontend — 설계 문서
> Adaptive Crawler RObot | `acro/fe/`  
> Agent 참조용 · React + Vite + Tailwind CSS 기반

---

## 프로젝트 개요

ACRO 프론트엔드는 사용자가 매크로를 설정하고 실행 상태를 모니터링하는 Web UI다.  
백엔드(FastAPI)와 REST API + WebSocket으로 통신한다.  
핵심 기능은 사이트 온보딩(최초 등록), 매크로 관리, 실시간 로그 확인이다.

---

## 디렉토리 구조

```
acro/
└── fe/
    ├── index.html
    ├── package.json
    ├── vite.config.js
    ├── tailwind.config.js
    ├── Dockerfile
    ├── .env.development
    ├── .env.production
    └── src/
        ├── main.jsx
        ├── App.jsx               # 라우터 설정
        ├── api/
        │   ├── client.js         # axios 인스턴스 (모든 API 모듈 공유)
        │   ├── sites.js          # /sites API 함수
        │   ├── onboarding.js     # /onboarding API 함수
        │   └── macro.js          # /macro API 함수 + React Query 훅
        ├── hooks/
        │   └── useWebSocket.js   # WebSocket 실시간 연결 훅
        ├── pages/
        │   ├── Dashboard.jsx     # 메인 대시보드 + 실시간 로그
        │   ├── Onboarding.jsx    # 사이트 등록 온보딩 (핵심)
        │   ├── Reservation.jsx   # 매크로 관리
        │   ├── Sites.jsx         # 등록된 사이트 목록 관리
        │   └── SelectorDetails.jsx # 온보딩 완료 사이트의 셀렉터 조회/수정
        └── components/
            ├── SelectorConfirm.jsx  # AI 추론 결과 확인/수정 컴포넌트
            ├── AiChatPanel.jsx      # AI 추론 과정 실시간 챗 패널
            ├── DisclaimerModal.jsx  # 법적 고지 모달 (최초 접속 시)
            ├── StatusBadge.jsx      # 매크로 상태 배지
            ├── LogViewer.jsx        # 실시간 로그 뷰어
            └── Navbar.jsx           # 상단 네비게이션
```

---

## 페이지별 역할

### Dashboard.jsx — 메인 대시보드
- 등록된 사이트별 매크로 현재 상태 표시 (실행중 / 대기 / 오류)
- 실시간 로그 스트림 (WebSocket 연결)
- 매크로 실행 / 중지 버튼
- 세션 만료 알림 배너
- AI 자동 수정 내역 표시
- **최초 접속 시 DisclaimerModal 표시** (localStorage 24시간 숨김)

```
표시 정보:
- 사이트 이름 + 상태 배지
- 마지막 예약 시도 시각
- 변경 감지 여부
- AI 수정 내역 (있을 경우)
- 실시간 로그 (WebSocket)
```

### Onboarding.jsx — 사이트 최초 등록 (핵심 페이지)
사이트를 처음 등록할 때 사용하는 페이지. 6단계 흐름으로 구성된다.

```
Step 1: 사이트 이름 + URL 입력
        → POST /sites
        → POST /onboarding/start (브라우저 실행)

Step 2: 안내 메시지 표시 / noVNC 조건부 렌더링
        - 배포 환경 (`VITE_NOVNC_URL` 존재): FE 화면 안에 iframe으로 noVNC 직접 임베드
          → 사용자가 별도 탭 없이 FE 안에서 바로 Playwright 브라우저 조작 가능
        - 개발 환경 (`VITE_NOVNC_URL` 없음): 안내 텍스트만 표시
          "로컬 PC에 브라우저 창이 직접 열렸습니다. 로그인 후 예약 화면까지 이동해주세요."

        ```jsx
        {import.meta.env.VITE_NOVNC_URL ? (
          <iframe
            src={import.meta.env.VITE_NOVNC_URL}
            width="100%"
            height="600px"
          />
        ) : (
          <p>로컬 PC에 브라우저 창이 직접 열렸습니다. 로그인 후 예약 화면까지 이동해주세요.</p>
        )}
        ```
        → 사용자가 완료하면 "셀렉터 등록 시작" 버튼 활성화

Step 3: 셀렉터 캡처 시작
        → POST /onboarding/capture/start
        "브라우저에서 예약에 필요한 요소들을 클릭하세요."
        "완료하면 아래 버튼을 눌러주세요."

Step 4: 클릭 진행 상태 실시간 표시
        WebSocket으로 클릭된 요소 목록 스트리밍
        → 클릭할 때마다 목록에 추가됨
        + AiChatPanel: AI 추론 과정 화면 우측에 챗버블로 실시간 시각화

Step 5: AI 추론 결과 확인 (SelectorConfirm.jsx)
        각 요소에 대해 AI가 추론한 이름 표시
        사용자가 확인(✅) or 수정(✏️)
        → POST /onboarding/capture/confirm

Step 6: 완료
        "온보딩이 완료되었습니다." 표시
        → Dashboard로 이동
```

### Reservation.jsx — 매크로 관리
- 사이트 선택 드롭다운
- 사이트별 매크로 목록 표시 (매크로명, 셀렉터 수, 예약 상태)
- [+ 새 매크로 등록] → `/onboarding?site=xxx&mode=add_macro` 이동
- 매크로 행 클릭 → `/selectors?site=xxx&macro=yyy` 이동 (상세보기)

### Sites.jsx — 사이트 관리
- 등록된 사이트 목록
- 온보딩 완료 여부 표시
- **[상세보기] 버튼** (완료 시) → `/selectors?site=xxx` 이동 (SelectorDetails.jsx)
- **[초기화] 버튼** (완료 시) → `POST /onboarding/reset` 호출 훈 상태 갱신
- 재온보딩 버튼 (사이트 구조 변경 시)
- 사이트 삭제

### SelectorDetails.jsx — 셀렉터 상세
- `Sites.jsx`의 [상세보기]에서 `/selectors?site=xxx`로 진입
- 온보딩 완료 사이트의 저장된 셀렉터 목록 조회
- element_name, selector, element_type, element_order 표시
- 사용자가 선택적으로 수정 가능

---

## 핵심 컴포넌트

### SelectorConfirm.jsx — AI 추론 결과 확인/수정
온보딩 Step 5에서 사용. AI가 추론한 요소 이름을 사용자가 확인하거나 수정한다. **행별 개별 삭제(🗑️) 및 전체 초기화 기능 포함**.

```
UI 구성:
┌──────────────────────────────────────────────────┐
│ #  │ AI 추론 이름    │ 셀렉터          │ 상태     │
├──────────────────────────────────────────────────┤
│ 1  │ 출발역 입력칸   │ #dpt_stn_nm     │ ✅ 확인  │
│ 2  │ 도착역 입력칸   │ #arv_stn_nm     │ ✅ 확인  │
│ 3  │ 여행 날짜       │ .date-picker    │ ✏️ 수정중│
│ 4  │ 조회 버튼       │ #search_btn     │ ✅ 확인  │
└──────────────────────────────────────────────────┘
         [ 전체 확인 완료 → DB 저장 ]

Props:
- items: [{ order, ai_name, selector, element_type }]
- onConfirm: (confirmedItems) => void
```

### AiChatPanel.jsx — AI 추론 과정 시각화
온보딩 Step 3 화면 우측에 Ollama AI 추론 과정을 실시간 디스플레이.

```
버블 타입:
- thinking  → "AI가 생각하는 중..." (로딩 애니메이션)
- result    → AI가 추론한 요소 명칭
- error     → 추론 실패 메세지
```

### DisclaimerModal.jsx — 법적 고지 모달
대시보드 최초 접속 시 화면 전체를 덮는 모달. "오늘 하루 보지 않기" 체크 훈 localStorage에 24시간 동안 숨김.

### LogViewer.jsx — 실시간 로그
WebSocket으로 수신한 로그를 실시간으로 표시한다.

```
로그 타입별 색상:
- INFO    → 흰색
- SUCCESS → 초록색
- WARNING → 노란색
- ERROR   → 빨간색
- AI_FIX  → 보라색 (AI 자동 수정)
```

### useWebSocket.js — WebSocket 훅
```javascript
// 매크로 상태 추적용 (대시보드)
const { logs, status, isConnected } = useWebSocket('ws://localhost:8000/ws')

// 온보딩 역할 추론 실시간 스트리밍용 (Onboarding)
const { items, isConnected: isOnboardingConnected } = useWebSocket(`ws://localhost:8000/ws/onboarding/${siteName}`)
```

---

## API 통신 (api/ 도메인 분리 구조)

백엔드와의 통신은 도메인별 파일을 통해 한다.

```javascript
// api/sites.js
getSites(isOnboarded)              // GET    /sites (?is_onboarded 필터 선택)
createSite(name, url)              // POST   /sites
deleteSite(siteName)               // DELETE /sites/{site_name}

// api/onboarding.js
startOnboarding(siteName, url)     // POST /onboarding/start
startCapture(siteName)             // POST /onboarding/capture/start
confirmSelectors(siteName, items)  // POST /onboarding/capture/confirm
resetOnboarding(siteName)          // POST /onboarding/reset
getSelectors(siteName)             // GET  /selectors/{site_name}

// api/macro.js (단순 함수 + React Query 훅)
fetchMacroStatus(siteName)         // GET  /macro/status
postRunMacro(siteName)             // POST /macro/run
postStopMacro(siteName)            // POST /macro/stop
useMacroStatusQuery(siteName)      // React Query 훅: 5초 폴링
useRunMacroMutation()              // React Query Mutation 훅
useStopMacroMutation()             // React Query Mutation 훅
```

---

## 라이브러리 목록

```json
{
  "dependencies": {
    "react": "^19",
    "react-dom": "^19",
    "react-router-dom": "^7",
    "@tanstack/react-query": "^5",
    "axios": "^1"
  },
  "devDependencies": {
    "vite": "^5",
    "@vitejs/plugin-react": "^4",
    "tailwindcss": "^3",
    "postcss": "^8",
    "autoprefixer": "^10"
  }
}
```

---

## Dockerfile

배포 테스트 단계이므로 nginx 없이 Vite dev 서버로 5173 포트를 직접 노출한다.
`--host` 옵션이 없으면 컨테이너 외부에서 접근이 불가능하므로 반드시 포함해야 한다.

```dockerfile
FROM node:20-alpine
WORKDIR /app

# corepack으로 pnpm 활성화
RUN corepack enable && corepack prepare pnpm@latest --activate

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .

EXPOSE 5173
CMD ["pnpm", "dev", "--host"]
```

> 💡 운영 배포 시에는 `pnpm build`로 정적 파일을 빌드한 뒤 nginx로 서빙하는 방식으로 전환하고 포트를 `80:80`으로 교체한다.

> **📌 Podman 실행 방법 (로컬 검증용)**
> ```bash
> podman build -t acro-frontend ./fe
> podman run -d --name acro-fe -p 5173:5173 acro-frontend
> ```

---

## 설치 및 실행

### Podman Compose (배포 테스트)

```bash
# 전체 환경 한 번에 기동
podman compose up -d

# Web UI: http://localhost:5173
# noVNC : http://localhost:6080 ← 온보딩용 (배포 환경에서만 사용)
```

### 로컬 직접 실행 (개발 환경 권장)

```bash
cd acro/fe

# 패키지 설치
pnpm install

# Tailwind 초기화 (최초 1회)
npx tailwindcss init -p

# 개발 서버 실행
pnpm dev
# → http://localhost:5173

# 빌드 (배포 이미지 생성 시)
pnpm build
```

---

## 환경 변수

환경변수는 개발/배포 환경을 분리하여 2개의 프로필로 관리한다.

### `.env.development` — 개발 환경 (로컬 VSCode 실행 시)

```bash
# ── API ──────────────────────────────────────────────
# 개발 시 BE를 로컬에서 직접 실행하므로 localhost 사용
VITE_API_BASE_URL=http://localhost:8000

# ── WebSocket ────────────────────────────────────────
VITE_WS_URL=ws://localhost:8000/ws
VITE_WS_ONBOARDING_URL=ws://localhost:8000/ws/onboarding

# ── noVNC ────────────────────────────────────────────
# 개발 환경에서는 로컬 PC에 브라우저 창이 직접 뜨므로 noVNC 불필요
# 이 값이 없으면 Onboarding.jsx Step 2에서 noVNC iframe을 렌더링하지 않음
# VITE_NOVNC_URL=http://localhost:6080

# ── MOCK-TRAIN 연동 (대안 2 — 모의 사이트 테스트용) ──
# Onboarding.jsx에서 사이트 URL 기본값으로 표시 (수동 입력 대체)
# 실제 코레일 대신 로컬 모의 사이트로 ACRO 기능 검증
# VITE_MOCK_SITE_URL=http://localhost:5174

# ── 환경 식별 ─────────────────────────────────────────
VITE_ENV=development
```

### `.env.production` — 배포 환경 (Podman 컨테이너)

```bash
# ── API ──────────────────────────────────────────────
# 배포 환경 — acro-backend 서비스가 8000 포트로 노출됨
VITE_API_BASE_URL=http://localhost:8000

# ── WebSocket ────────────────────────────────────────
VITE_WS_URL=ws://localhost:8000/ws
VITE_WS_ONBOARDING_URL=ws://localhost:8000/ws/onboarding

# ── noVNC ────────────────────────────────────────────
# 배포 환경 — BE 컨테이너 안 Xvfb 화면을 noVNC로 스트리밍
# Onboarding.jsx Step 2에서 이 주소를 iframe으로 FE 화면 안에 직접 임베드
VITE_NOVNC_URL=http://localhost:6080

# ── 환경 식별 ─────────────────────────────────────────
VITE_ENV=production
```

---

## 라우터 구조 (App.jsx)

```
/                  → Dashboard.jsx       (메인)
/onboarding        → Onboarding.jsx      (사이트 등록)
/macro             → Reservation.jsx     (매크로 관리)
/sites             → Sites.jsx           (사이트 관리)
/selectors?site=   → SelectorDetails.jsx (셀렉터 상세 조회/수정)
```

---

## BE와의 통신 흐름 요약

```
[온보딩]
FE → POST /sites               → BE: sites 테이블 생성
FE → POST /onboarding/start    → BE: patchright 브라우저 실행
FE → POST /onboarding/capture/start → BE: 클릭 캡처 시작
BE → WS  /ws/onboarding/{site_name} → FE: AI_THINKING, ELEMENT_CAPTURED 실시간 스트리밍
FE → POST /onboarding/capture/confirm → BE: 확정 셀렉터 DB 저장

[매크로 실행]
FE → POST /macro/run           → BE: 크롤링 → 비교 → 매크로 실행
BE → WS  /ws                   → FE: LOG, MACRO_STATUS, RECOVERY_COMPLETE 실시간 스트리밍

[세션 만료]
BE → WS  /ws (type: SESSION_EXPIRED) → FE: 알림 배너 표시

[사이트 구조 변경]
BE → WS  /ws (type: REONBOARDING_REQUIRED) → FE: 재온보딩 요청 표시
```

---

## VSCode 익스텐션 (FE 개발용)

| 익스텐션 | 용도 |
|----------|------|
| ES7+ React Snippets | rafce 등 React 단축 코드 |
| Tailwind CSS IntelliSense | 클래스 자동완성 |
| Prettier | JS/JSX 코드 자동 정렬 |
| GitLens | Git 히스토리 추적 |
