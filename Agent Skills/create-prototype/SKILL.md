---
name: create-prototype
description: >
  HTML UI 프로토타입 생성 스킬. `/create-prototype` 명령어로 트리거되며,
  성능요구사항(SFR) 번호 기반 화면 프로토타입을 HTML 파일로 생성한다.
  Tailwind CSS CDN + Noto Sans KR 기반이며, 실제 서비스 수준의 인터랙티브 프로토타입을 만든다.
  "프로토타입 만들어줘", "화면 설계", "UI 프로토타입", "HTML 화면", "화면 구현",
  "SFR 화면", "목업", "화면 시안" 등의 요청에도 반드시 이 스킬을 사용한다.
  화면이나 프로토타입이라는 단어가 포함된 요청이면 거의 항상 이 스킬을 쓴다.
allowed-tools: Read, Write, Glob, Task
---

# Create Prototype — HTML UI 프로토타입 생성기

성능요구사항(SFR) 번호를 기반으로 인터랙티브 UI 프로토타입을 생성하는 스킬이다.
Tailwind CSS CDN과 Noto Sans KR 폰트를 사용하며, VS Code Go Live 서버로 바로 확인할 수 있다.

---

## 환경별 처리 방식

| 환경 | Task 툴 | 분리 구조 처리 |
|---|---|---|
| Claude Code / Codex | 가능 | 병렬 subagent |
| Claude.ai | 불가 | 메인 파일 → 조각 파일 순차 생성 |

Task 툴 호출 실패 시 자동으로 순차 생성으로 전환한다.

## 워크플로우

`/create-prototype` 명령이 들어오면 먼저 사용자 메시지에서 아래 3가지를 사전 추출한다.

| 항목 | 추출 기준 |
|---|---|
| SFR 번호 | `SFR-NNN` 패턴 포함 여부 |
| 기능 설명 | 메시지에 화면 기능 설명이 있는가 |
| 메인 색상 | HEX 코드 또는 색상명 포함 여부 |

추출된 항목은 해당 STEP을 건너뛴다.
3개가 모두 추출되면 STEP 4로 바로 진입한다.

그 외에는 아래 4단계를 순서대로 진행한다.

### STEP 1 — 성능요구사항 번호 수집 (미제공 시에만 질문)

사용자에게 해당 화면의 **성능요구사항 번호**를 물어본다.

- 형식 규칙: `SFR-001` (세 자리, 영어 대문자 + 하이픈 + 숫자 세 자리)
- 복수 화면: `SFR-001&002` 형태로 `&`로 결합
- HTML `<title>`에도 반영: `SFR-001 — {프로젝트명} 화면 예시`

사용자에게 이렇게 물어본다:
> "이 화면의 성능요구사항 번호를 알려주세요. (예: SFR-001, 복수이면 SFR-001&002)"

### STEP 2 — 화면 기능구성 + 와이어프레임 수집 (미제공 시에만 질문)

사용자에게 **두 가지**를 요청한다:

1. **화면의 기능구성** — 텍스트로 설명 (어떤 기능이 있는지, 주요 영역이 뭔지)
2. **와이어프레임 또는 화면 영역 구분** — PPT, 이미지, 손그림 사진 등 무엇이든 OK

이미지가 첨부되면 이를 분석하여 레이아웃 구조(사이드바, 메인, 패널 등), 영역 배치, 주요 컴포넌트를 파악한다. 텍스트만 있어도 진행 가능.

사용자에게 이렇게 물어본다:
> "화면의 기능구성을 설명해주세요. 그리고 대략적인 와이어프레임이나 화면 영역 구분 이미지(PPT, 스크린샷, 손그림 등)가 있으면 함께 첨부해주세요."

### STEP 3 — 메인 색상 수집 (미제공 시에만 질문)

사용자에게 **메인 색상 하나**만 물어본다.

- HEX 코드(`#2563EB`) 또는 색상명("네이비", "초록") 모두 OK
- 나머지 팔레트는 `references/color-system.md`를 읽고 자동 생성

사용자에게 이렇게 물어본다:
> "디자인의 메인 색상을 알려주세요. (예: #2563EB, 또는 '네이비', '초록' 등)"

### STEP 4 — HTML 프로토타입 생성

수집한 정보(번호, 기능, 색상)를 종합하여 HTML 파일을 생성한다.

**생성 전 반드시 아래 파일들을 읽는다:**
1. `references/html-template.md` — HTML 기본 골격과 CSS 체계
2. `references/color-system.md` — 메인 색상에서 전체 팔레트 파생 규칙
3. `examples/SFR-018.html` — 코드 스타일 참고 (전체 읽기 금지)
   - `<style>` 블록 중심 상단 범위만 읽기 (`head -120` 수준)
   - 탭 전환 JS 함수 주변만 추출 (`showScreen`, `loadScreen`)
   - 필요한 컴포넌트 패턴이 있는 섹션만 추가 추출

#### 파일 구조 결정 (단일 파일 vs 분리 구조)

생성 전에 아래 기준으로 구조를 먼저 결정한다:

| 조건 | 구조 |
|---|---|
| 화면 수 3개 이하 **AND** 예상 700줄 이하 | **단일 파일**: `SFR-{번호}.html` |
| 화면 수 4개 이상 **OR** 예상 700줄 초과 | **분리 구조**: `SFR-{번호}/` 디렉토리 |

#### 단일 파일 구조

```text
SFR-001.html    ← 단독 파일, CSS·JS 전부 인라인
```

파일 저장: 사용자가 지정한 경로 또는 현재 작업 디렉토리에 `SFR-{번호}.html`로 저장.

#### 분리 구조 (Go Live 서버 완전 호환)

화면이 많거나 길어질 경우 디렉토리를 생성하고 화면별로 분리한다:

```text
SFR-001/
├── SFR-001.html        ← 메인: 공통 CSS, nav, JS 로더
├── SFR-001-1.html      ← 화면 1 HTML 조각 (div 내용만)
├── SFR-001-2.html      ← 화면 2 HTML 조각
└── SFR-001-3.html      ← 화면 3 HTML 조각 (필요 시)
```

**SFR-{번호}.html (메인 파일) 구조:**
```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <!-- 공통 스타일: :root CSS 변수, 기본 컴포넌트 전부 여기에 -->
</head>
<body>
  <nav class="page-nav">
    <div class="logo">{프로젝트명} <span>DEMO</span></div>
    <button class="tab-btn active" onclick="loadScreen(1, this)">화면명1</button>
    <button class="tab-btn" onclick="loadScreen(2, this)">화면명2</button>
  </nav>

  <div id="screen-container"><!-- fetch로 로드된 화면이 여기에 주입됨 --></div>

  <script>
    async function loadScreen(n, btn) {
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const res = await fetch(`./SFR-001-${n}.html`);
      document.getElementById('screen-container').innerHTML = await res.text();
    }
    loadScreen(1, document.querySelector('.tab-btn.active'));
  </script>
</body>
</html>
```

**SFR-{번호}-N.html (화면 조각 파일) 구조:**
```html
<!-- 화면 1: 진입화면 — <!DOCTYPE>, <html>, <head> 없음. div 조각만 작성 -->
<div class="screen-wrap">
  <!-- 해당 화면 전체 내용 -->
</div>
<script>
  /* 이 화면 전용 JS만 작성 */
</script>
```

> **Go Live 호환 이유**: Go Live는 HTTP 서버이므로 `fetch('./SFR-001-1.html')`이 CORS 없이 완벽히 동작한다. 파일 이중 클릭(file:// 프로토콜)으로는 fetch가 차단되지만, Go Live 사용 시 항상 정상 작동한다.

#### 분리 구조 생성 — 병렬 subagent (Claude Code / Codex)

분리 구조로 결정됐을 때 **Task 툴이 사용 가능한 환경이면 병렬 subagent로 생성**한다.
각 화면 조각 파일은 서로 독립적이므로 동시에 생성할 수 있다.

**병렬 처리 순서:**

1. 먼저 공통 컨텍스트를 확정한다 (CSS 변수 팔레트, nav 탭 목록, 화면별 기능 명세)
2. **메인 파일 + 각 화면 조각 파일을 한 번에 병렬 subagent로 실행**

```text
병렬 실행 (동시):
  subagent-0: SFR-001.html     ← 공통 CSS, nav, fetch 로더 생성
  subagent-1: SFR-001-1.html   ← 화면 1 조각 생성
  subagent-2: SFR-001-2.html   ← 화면 2 조각 생성
  subagent-3: SFR-001-3.html   ← 화면 3 조각 생성 (있을 경우)
```

각 subagent에게 전달할 공통 컨텍스트:

- CSS 변수 팔레트 (`--primary`, `--bg`, `--surface` 등 전체 목록)
- 프로젝트명, SFR 번호
- 해당 화면의 기능 명세 (해당 조각만)
- 화면 조각 파일 작성 규칙 (`<!DOCTYPE>` 없이 `<div class="screen-wrap">` 조각만)

**환경별 fallback:**

| 환경 | 처리 방식 |
|---|---|
| Claude Code, Codex (Task 툴 가능) | 병렬 subagent로 동시 생성 |
| Claude.ai, 기타 (Task 툴 없음) | 메인 파일 → 조각 파일 순서대로 순차 생성 |

Task 툴 호출이 실패하거나 미지원 환경이면 **순차 생성으로 자동 전환**한다.

---

## HTML 생성 핵심 규칙

### 파일 기본 설정

- `lang="ko"`, 한글 UI
- Google Fonts: `Noto Sans KR` (본문) + `JetBrains Mono` (코드/숫자)
- **Tailwind CSS CDN**: `<script src="https://cdn.tailwindcss.com"></script>`을 head에 포함
- CSS 변수(`:root`)로 색상 체계 관리 — Tailwind 유틸리티는 **보조**로만 사용

### Tailwind 사용 원칙

- 레이아웃 보조: `flex`, `gap-*`, `p-*`, `mt-*`, `grid`, `w-full` 등
- 텍스트 보조: `text-sm`, `font-bold`, `truncate` 등
- **색상은 항상 CSS 변수 사용** — `style="color: var(--primary)"` 형태
- Tailwind의 색상 유틸리티(text-blue-500 등)는 사용하지 않는다
- 핵심 컴포넌트(.btn, .card, .sidebar 등)는 `<style>` 블록에 커스텀 CSS로 정의

### 디자인 시스템

- CSS 변수(`:root`)로 전체 색상 관리 (color-system.md 참조)
- 13px 기본 폰트, `line-height: 1.5`
- 카드/패널: `border-radius: 8~12px`, 미세한 `box-shadow`
- 버튼 클래스: `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-green`
- 스크롤바 커스텀, fadeIn 애니메이션, hover 트랜지션

### 레이아웃 패턴
상황에 맞는 패턴을 선택하거나 조합한다:

| 패턴 | 용도 | 구조 |
|---|---|---|
| 앱 셸 | 업무 화면 | 사이드바 + 메인 + 우측패널 |
| 목록 화면 | 데이터 조회 | 검색바 + 그리드/테이블 |
| 대시보드 | 현황 요약 | 상단 카드 + 하단 차트/테이블 |
| 진입 화면 | 메뉴 선택 | 중앙 정렬 카드 버튼 |
| 폼 화면 | 데이터 입력 | 라벨 + 입력필드 + 제출 |
| 탭 다중화면 | 관련 화면 묶음 | 상단 탭(.page-nav) + .screen 전환 |

### 인터랙션

- 탭 전환: `showScreen(id)` 함수 (단일 파일) / `loadScreen(n, btn)` 함수 (분리 구조)
- 모달: `.modal-overlay` + `.modal-box`
- 사이드 패널: `.slide-panel` 또는 `togglePanel()` 함수
- 호버 효과: `transition: all .2s`
- 더미 데이터: 한국어, 실무 맥락에 맞게 사실적으로
- 미구현 기능: `alert('XX 기능은 준비중입니다.')`

### 단일 파일 다중 화면 처리

화면 수 3개 이하인 경우 단일 파일 내에서 탭으로 처리:

```html
<nav class="page-nav">
  <div class="logo">{프로젝트명} <span>DEMO</span></div>
  <button class="tab-btn active" onclick="showScreen('s001-entry')">진입화면</button>
  <button class="tab-btn" onclick="showScreen('s001-list')">목록</button>
</nav>

<div id="s001-entry" class="screen active">...</div>
<div id="s001-list" class="screen">...</div>
```

---

## 참조 파일

| 파일 | 내용 | 언제 읽는가 |
|---|---|---|
| `references/html-template.md` | HTML 골격, CSS 기본 클래스 정의, JS 함수 템플릿 | STEP 4 시작 시 반드시 |
| `references/color-system.md` | 메인 색상 → 전체 팔레트 파생 규칙 | STEP 3에서 색상 확정 후 |
| `examples/SFR-018.html` | 완성 예제 (1700줄, 5개 화면) | STEP 4에서 코드 스타일 참고 |

`examples/SFR-018.html`은 이 스킬이 목표로 하는 **품질 기준**이다.
구조, 네이밍, 인터랙션 패턴, CSS 클래스명, 더미 데이터 스타일 등을 이 파일에서 참고한다.

---

## 품질 기준

1. **실제 서비스처럼 보인다** — 프로토타입이지만 완성도 높은 UI, SFR-018.html 수준
2. **더미 데이터가 사실적이다** — 한국어, 실제 업무 맥락에 맞는 이름/날짜/내용
3. **데스크탑에서 깨지지 않는다** — 최소 1280px 이상에서 정상 표시
4. **코드가 정리되어 있다** — `/* ── 섹션명 ── */` 주석으로 영역 구분, CSS 변수 일관성
5. **인터랙티브하다** — 탭 전환, 모달, 호버, 패널 토글 등 동작하는 프로토타입
6. **Go Live로 바로 확인 가능하다** — 단일 파일이든 분리 구조든 VS Code Go Live에서 정상 동작
