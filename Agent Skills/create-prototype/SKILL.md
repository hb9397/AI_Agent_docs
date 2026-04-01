---
name: create-prototype
description: >
  HTML UI 프로토타입 생성 스킬. `/create-prototype` 명령어로 트리거되며,
  요구사항 번호(SFR, REQ, UC 등 프로젝트별 prefix) 기반 화면 프로토타입을 HTML 파일로 생성한다.
  Tailwind CSS CDN + Noto Sans KR 기반이며, 실제 서비스 수준의 인터랙티브 프로토타입을 만든다.
  "프로토타입 만들어줘", "화면 설계", "UI 프로토타입", "HTML 화면", "화면 구현",
  "SFR 화면", "REQ 화면", "목업", "화면 시안" 등의 요청에도 반드시 이 스킬을 사용한다.
  화면이나 프로토타입이라는 단어가 포함된 요청이면 거의 항상 이 스킬을 쓴다.
allowed-tools: Read, Write, Glob
---

# Create Prototype — HTML UI 프로토타입 생성기

요구사항 번호(기본 PREFIX: `SFR`, 커스텀 PREFIX 허용)를 기반으로 인터랙티브 UI 프로토타입을 생성하는 스킬이다.
Tailwind CSS CDN과 Noto Sans KR 폰트를 사용하며, VS Code Go Live 서버 또는 파일 직접 열기로 바로 확인할 수 있다.

> **단일 파일 원칙**: 모든 산출물은 CSS·JS 인라인의 단일 HTML 파일로 생성한다. 분리 구조(fetch + 조각 파일)는 사용하지 않는다.

## 워크플로우

`/create-prototype` 명령이 들어오면 먼저 사용자 메시지에서 아래 4가지를 사전 추출한다.

| 항목 | 추출 기준 |
|---|---|
| PREFIX | `[A-Z]+-NNN` 패턴 포함 여부 (예: `SFR-018`, `REQ-005`, `UC-012`) — 없으면 기본값 `SFR` |
| 번호 | PREFIX와 결합된 숫자 부분 |
| 기능 설명 | 메시지에 화면 기능 설명이 있는가 |
| 메인 색상 | HEX 코드 또는 색상명 포함 여부 |

추출된 항목은 해당 STEP을 건너뛴다.
4개가 모두 추출되면 STEP 4로 바로 진입한다.

> PREFIX는 사용자가 명시한 값을 그대로 사용한다. 이후 모든 파일명, 디렉토리명, HTML title에 `{PREFIX}-{번호}` 형태로 반영한다.

그 외에는 아래 4단계를 순서대로 진행한다.

### STEP 1 — 요구사항 번호 수집 (미제공 시에만 질문)

사용자에게 해당 화면의 **요구사항 번호**를 물어본다.

- 기본 PREFIX: `SFR` — 사용자가 다른 prefix를 사용하면 그것을 그대로 따른다
- 형식 규칙: `{PREFIX}-001` (영어 대문자 + 하이픈 + 숫자, 자릿수는 프로젝트 관례 따름)
- 복수 화면: `{PREFIX}-001&002` 형태로 `&`로 결합
- HTML `<title>`에도 반영: `{PREFIX}-001 — {프로젝트명} 화면 예시`

사용자에게 이렇게 물어본다:
> "이 화면의 요구사항 번호를 알려주세요. (예: SFR-001, REQ-005, UC-012 등 프로젝트에서 쓰는 번호로 알려주세요. 복수이면 & 로 결합: SFR-001&002)"

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
   - 파일 상단의 **섹션 인덱스 주석**을 먼저 읽고, 필요한 줄 범위만 선택적으로 읽기
   - 기본: 상위 ~130줄 (:root + 공통 CSS) + showScreen 함수 주변 (~1583줄)
   - 모달/패널 등 특정 컴포넌트가 필요하면 인덱스에서 해당 줄 범위를 찾아 추출

#### 파일 구조 — 항상 단일 파일

화면 수·줄 수에 관계없이 **항상 단일 HTML 파일**로 생성한다.

```text
{PREFIX}-001.html    ← 단독 파일, CSS·JS 전부 인라인
```

파일 저장: 사용자가 지정한 경로에 `{PREFIX}-{번호}.html`로 저장. 경로가 지정되지 않으면 현재 작업 디렉토리를 확인하고, 프로젝트 루트가 아닌 것 같으면 사용자에게 저장 경로를 확인한다.

> 단일 파일은 file:// 직접 열기와 Go Live 서버 양쪽에서 모두 동작하며, 화면별 JS가 항상 정상 실행된다.

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

- 탭 전환: `showScreen(id, btn)` 함수 — **반드시 `this`를 두 번째 인수로 전달**
- 모달: `.modal-overlay` + `.modal-box`
- 사이드 패널: `.slide-panel` 또는 `togglePanel()` 함수
- 호버 효과: `transition: all .2s`
- 더미 데이터: 한국어, 실무 맥락에 맞게 사실적으로
- 미구현 기능: `alert('XX 기능은 준비중입니다.')`

### 다중 화면 처리

화면이 여러 개인 경우 단일 파일 내에서 탭으로 처리한다. onclick에 반드시 `this`를 전달한다:

```html
<nav class="page-nav">
  <div class="logo">{프로젝트명} <span>DEMO</span></div>
  <button class="tab-btn active" onclick="showScreen('s001-entry', this)">진입화면</button>
  <button class="tab-btn" onclick="showScreen('s001-list', this)">목록</button>
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
| `examples/SFR-018.html` | 완성 예제 (1700줄, 5개 화면, PREFIX=SFR) | STEP 4에서 코드 스타일 참고 |

`examples/SFR-018.html`은 이 스킬이 목표로 하는 **품질 기준**이다. PREFIX가 달라도 동일한 파일 구조와 코드 패턴을 따른다.
구조, 네이밍, 인터랙션 패턴, CSS 클래스명, 더미 데이터 스타일 등을 이 파일에서 참고한다.

> **CSS 변수 주의**: 예제 파일(SFR-018.html)은 `--primary` 계열 변수를 사용한다. 생성 시 항상 `--primary`, `--primary-light`, `--primary-mid`, `--nav-bg` 변수명을 사용해야 한다.

---

## STEP 5 — Self-check (생성 직후 필수)

HTML 파일 생성 후 아래 항목을 순서대로 확인하고, 문제가 있으면 즉시 수정한다.

| 확인 항목 | 기준 |
|---|---|
| Tailwind CDN | `<script src="https://cdn.tailwindcss.com">` 가 `<head>` 안에 있는가 |
| CSS 변수 완비 | `:root`에 `--primary`, `--primary-light`, `--primary-mid`, `--nav-bg` 4개가 모두 정의돼 있는가 |
| 변수 이름 오염 | `--blue`, `--blue-light` 같은 색상명 변수가 없는가 |
| showScreen 인수 | `onclick="showScreen('id', this)"` 형태로 `this`를 전달하는가 |
| 첫 화면 표시 | 첫 번째 `.screen`에 `active` 클래스가 있고, 첫 번째 `.tab-btn`에도 `active`가 있는가 |
| ID 일치 | `showScreen('id', this)` 인수와 `<div id="id">`가 정확히 일치하는가 |
| 하드코딩 색상 | nav/label 배경에 HEX 직접 입력 대신 `var(--nav-bg)` 사용하는가. hover에도 HEX 대신 `filter: brightness(0.9)` 사용하는가 |
| 모달 (해당 시) | 모달 `z-index`가 nav(100)보다 높은가. 닫기 버튼/오버레이 클릭에 닫기 함수가 연결돼 있는가 |

---

## 품질 기준

1. **실제 서비스처럼 보인다** — 프로토타입이지만 완성도 높은 UI, SFR-018.html 수준
2. **더미 데이터가 사실적이다** — 한국어, 실제 업무 맥락에 맞는 이름/날짜/내용
3. **데스크탑에서 깨지지 않는다** — 최소 1280px 이상에서 정상 표시
4. **코드가 정리되어 있다** — `/* ── 섹션명 ── */` 주석으로 영역 구분, CSS 변수 일관성
5. **인터랙티브하다** — 탭 전환, 모달, 호버, 패널 토글 등 동작하는 프로토타입
6. **어디서나 열린다** — 단일 파일이므로 file:// 직접 열기와 Go Live 서버 양쪽에서 정상 동작
