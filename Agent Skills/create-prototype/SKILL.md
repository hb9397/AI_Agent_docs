---
name: create-prototype
description: >
  HTML UI 프로토타입 생성 스킬. `/create-prototype` 명령어로 트리거되며,
  요구사항 번호(SFR, REQ, UC 등 프로젝트별 prefix) 기반 화면 프로토타입을 HTML 파일로 생성한다.
  Tailwind CSS CDN + Noto Sans KR 기반이며, 실제 서비스 수준의 인터랙티브 프로토타입을 만든다.
  "프로토타입 만들어줘", "화면 설계", "UI 프로토타입", "HTML 화면", "화면 구현",
  "SFR 화면", "REQ 화면", "목업", "화면 시안" 등의 요청에도 반드시 이 스킬을 사용한다.
  화면이나 프로토타입이라는 단어가 포함된 요청이면 거의 항상 이 스킬을 쓴다.
allowed-tools: Read, Write, Glob, Task
---

# Create Prototype — HTML UI 프로토타입 생성기

요구사항 번호(기본 PREFIX: `SFR`, 커스텀 PREFIX 허용)를 기반으로 인터랙티브 UI 프로토타입을 생성하는 스킬이다.
Tailwind CSS CDN과 Noto Sans KR 폰트를 사용하며, VS Code Live Server로 확인하는 것을 권장한다.

> **파일 구조 원칙**: 화면 1개 = 단일 HTML + 데이터 JSON. 다중 화면은 화면별 파일을 생성하고 `<a href>` 링크로 이동한다.

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

그 외에는 아래 단계를 순서대로 진행한다.

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

### STEP 4 — 병렬 생성 옵션 (다중 화면일 때만)

화면이 **2개 이상**인 경우, 서브에이전트를 활용한 병렬 생성 옵션을 사용자에게 제안한다.

사용자에게 이렇게 물어본다:
> "화면이 {N}개입니다. 서브에이전트를 사용해서 화면을 병렬로 동시에 생성할 수 있습니다.
>
> **병렬 생성 옵션:**
> | 옵션 | 설명 |
> |---|---|
> | 서브에이전트 수 | 최대 {N}개 (화면 수만큼). 줄이면 순차 처리와 혼합됩니다 |
> | 모델 선택 | 아래에서 선택해주세요 |
>
> **사용 가능한 모델:**
> | 모델 | 특징 |
> |---|---|
> | `opus` | 최고 품질, 복잡한 화면에 적합. 비용 높음 |
> | `sonnet` | 균형 잡힌 품질/속도. 대부분의 화면에 권장 |
> | `haiku` | 가장 빠르고 저렴. 단순한 화면에 적합 |
>
> 병렬 생성을 사용하시겠습니까? 사용한다면 모델을 선택해주세요.
> (예: 'sonnet으로 병렬', 'opus 3개', '순차로 진행' 등)"

사용자가 **병렬을 선택하지 않거나 화면이 1개**이면 메인 에이전트가 순차 생성한다.

### STEP 5 — HTML 프로토타입 생성

수집한 정보(번호, 기능, 색상, 병렬 옵션)를 종합하여 HTML 파일을 생성한다.

**생성 전 반드시 아래 파일들을 읽는다:**
1. `references/html-template.md` — HTML 기본 골격과 CSS 체계
2. `references/color-system.md` — 메인 색상에서 전체 팔레트 파생 규칙
3. `examples/SFR-018.html` — **화면 구성·디자인·색상 참고** (전체 읽기 금지)
   - 파일 상단의 **섹션 인덱스 주석**을 먼저 읽고, 필요한 줄 범위만 선택적으로 읽기
   - 기본: 상위 ~35줄 (:root 색상 변수) + 필요한 화면 영역만 선택 읽기
   - 참고 대상: 화면 레이아웃 구성, 컴포넌트 배치, 디자인 톤, 색상 활용 방식
   - 참고 대상이 아닌 것: 코드 구조 (이 예제는 구 방식의 단일 파일이므로 코드 패턴은 `html-template.md`를 따른다)

#### 파일 구조

##### 단일 화면

```text
{PREFIX}-001/
├── {PREFIX}-001.html              ← HTML (JS 인라인)
├── {PREFIX}-001.css               ← 공통 CSS (1개)
└── {PREFIX}-001-data.json         ← 더미 데이터
```

##### 다중 화면 (2개 이상)

화면별 독립 HTML 파일을 생성하고, `<a href>` **상대경로 링크**로 화면 간 이동한다.
**CSS는 1개 파일**로 통합하여 모든 HTML에서 `<link rel="stylesheet">`로 참조한다.

```text
{PREFIX}-001/
├── {PREFIX}-001.css               ← 공통 CSS (1개 — 모든 HTML이 참조)
├── {PREFIX}-001-entry.html        ← 진입화면
├── {PREFIX}-001-entry-data.json   ← 진입화면 데이터
├── {PREFIX}-001-list.html         ← 목록화면
├── {PREFIX}-001-list-data.json    ← 목록 데이터
├── {PREFIX}-001-detail.html       ← 상세화면
├── {PREFIX}-001-detail-data.json  ← 상세 데이터
└── ...
```

> **CSS 단일 파일 원칙**: `:root` 변수, `.page-nav`, `.btn`, `.card` 등 모든 공통 스타일은 `{PREFIX}-001.css`에 정의한다. 각 HTML의 `<head>`에는 `<link rel="stylesheet" href="{PREFIX}-001.css">`만 넣고, `<style>` 블록에는 해당 화면 전용 CSS만 작성한다.

파일 저장: 사용자가 지정한 경로에 `{PREFIX}-{번호}/` 디렉토리를 만들어 저장. 경로가 지정되지 않으면 현재 작업 디렉토리를 확인하고, 프로젝트 루트가 아닌 것 같으면 사용자에게 저장 경로를 확인한다.

> **Live Server 권장**: JSON 데이터 파일은 `fetch()`로 로드하므로 VS Code Live Server에서 확인하는 것을 권장한다. `file://` 직접 열기에서는 데이터가 로드되지 않을 수 있다.

#### 다중 화면 — 네비게이션 구조

화면 간 이동은 `<a href>` 상대경로 링크를 사용한다. **같은 폴더 내 파일이므로 파일명만 쓰면 된다.**

```html
<nav class="page-nav">
  <div class="logo">{프로젝트명} <span>DEMO</span></div>
  <a class="tab-btn active" href="{PREFIX}-001-entry.html">진입화면</a>
  <a class="tab-btn" href="{PREFIX}-001-list.html">목록</a>
  <a class="tab-btn" href="{PREFIX}-001-detail.html">상세</a>
</nav>
```

- 현재 페이지에 해당하는 `<a>` 태그에 `active` 클래스 부여
- `showScreen()` 함수 불필요 — 브라우저 네이티브 링크 이동
- Live Server, file:// 양쪽에서 동작

#### 데이터 분리 — JSON 파일

각 화면의 더미 데이터(테이블 행, 카드 목록, 사이드바 항목 등)는 별도 JSON 파일로 분리한다.

**JSON 파일 형식** (`{PREFIX}-001-entry-data.json`):
```json
{
  "cards": [
    { "icon": "📩", "title": "전자민원 접수·응대", "desc": "AI가 민원을 분석하고 답변 초안을 생성합니다", "count": 24, "badge": "신규 5건" },
    { "icon": "📝", "title": "서면민원 답변 생성", "desc": "서면 민원에 대한 공식 답변서를 자동 작성합니다", "count": 12, "badge": "" }
  ]
}
```

**HTML에서 로드하는 패턴**:
```html
<script>
document.addEventListener('DOMContentLoaded', async () => {
  try {
    const res = await fetch('{PREFIX}-001-entry-data.json');
    const data = await res.json();
    renderData(data);
  } catch (e) {
    console.warn('데이터 파일 로드 실패 (Live Server에서 실행해주세요):', e);
  }
});

function renderData(data) {
  // data 객체를 사용하여 DOM에 렌더링
  const container = document.getElementById('card-container');
  container.innerHTML = data.cards.map(card => `
    <div class="list-card" onclick="...">
      <div style="font-size:28px;">${card.icon}</div>
      <h3>${card.title}</h3>
      <p>${card.desc}</p>
    </div>
  `).join('');
}
</script>
```

> **renderData 함수**: 화면마다 데이터 구조가 다르므로, 각 HTML 파일 안에 해당 화면에 맞는 `renderData()` 함수를 작성한다. JSON의 키 구조는 화면의 UI 컴포넌트에 맞게 자유롭게 설계한다.

#### 병렬 생성 (서브에이전트 사용 시)

사용자가 STEP 4에서 병렬 생성을 선택한 경우:

1. **공통 컨텍스트를 먼저 준비**: CSS 변수, 색상 팔레트, nav 구조(파일명 목록), 프로젝트명
2. **각 서브에이전트에 전달하는 정보**:
   - 담당 화면의 기능 설명
   - 해당 화면의 HTML 파일명 + JSON 파일명
   - 공통 컨텍스트 (CSS 변수, nav HTML, 파일명 목록)
   - `references/html-template.md`와 `references/color-system.md`의 경로
   - 생성 규칙 (이 문서의 "HTML 생성 핵심 규칙" 섹션 요약)
3. **서브에이전트는 화면 하나 + JSON 하나만 생성**한다
4. 모든 서브에이전트 완료 후, 메인 에이전트가 **STEP 6 Self-check**를 수행

> **서브에이전트에 전달하지 않는 것**: `examples/SFR-018.html` 전체 (토큰 낭비). 필요하면 해당 줄 범위의 내용만 발췌하여 전달한다.

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

### 인터랙션

- 화면 이동: `<a href="파일명.html">` 상대경로 링크 (다중 화면)
- 화면 내 탭: `showScreen(id, btn)` 함수 (단일 파일 내 서브탭이 필요한 경우에만)
- 모달: `.modal-overlay` + `.modal-box`
- 사이드 패널: `.slide-panel` 또는 `togglePanel()` 함수
- 호버 효과: `transition: all .2s`
- 더미 데이터: JSON 파일에서 로드, 한국어, 실무 맥락에 맞게 사실적으로
- 미구현 기능: `alert('XX 기능은 준비중입니다.')`

---

## 참조 파일

| 파일 | 내용 | 언제 읽는가 |
|---|---|---|
| `references/html-template.md` | HTML 골격, CSS 기본 클래스 정의, JS 함수 템플릿, 코드 패턴 | STEP 5 시작 시 반드시 |
| `references/color-system.md` | 메인 색상 → 전체 팔레트 파생 규칙 | STEP 3에서 색상 확정 후 |
| `examples/SFR-018.html` | 디자인 품질 기준 (화면 구성, 레이아웃, 색상 활용, 더미 데이터) | STEP 5에서 디자인 참고 |

`examples/SFR-018.html`은 이 스킬이 목표로 하는 **디자인 품질 기준**이다.
화면 레이아웃 구성, 컴포넌트 배치 감각, 디자인 톤, 색상 활용 방식, 더미 데이터 스타일을 이 파일에서 참고한다.
코드 구조와 파일 패턴은 이 예제가 아니라 `html-template.md`와 이 SKILL.md의 규칙을 따른다.

> **CSS 변수 주의**: 예제 파일(SFR-018.html)은 `--primary` 계열 변수를 사용한다. 생성 시 항상 `--primary`, `--primary-light`, `--primary-mid`, `--nav-bg` 변수명을 사용해야 한다.

---

## STEP 6 — Self-check (생성 직후 필수)

HTML 파일 생성 후 **모든 파일**에 대해 아래 항목을 순서대로 확인하고, 문제가 있으면 즉시 수정한다.

| 확인 항목 | 기준 |
|---|---|
| Tailwind CDN | 모든 HTML에 `<script src="https://cdn.tailwindcss.com">` 가 `<head>` 안에 있는가 |
| CSS 변수 완비 | 모든 HTML의 `:root`에 `--primary`, `--primary-light`, `--primary-mid`, `--nav-bg` 4개가 모두 정의돼 있는가 |
| 변수 이름 오염 | `--blue`, `--blue-light` 같은 색상명 변수가 없는가 |
| 네비게이션 링크 | 다중 화면: 모든 `<a class="tab-btn" href="...">` 의 href가 실제 존재하는 파일명과 일치하는가 |
| 현재 페이지 표시 | 각 HTML에서 자기 자신에 해당하는 탭에 `active` 클래스가 있는가 |
| 하드코딩 색상 | nav/label 배경에 HEX 직접 입력 대신 `var(--nav-bg)` 사용하는가. hover에도 HEX 대신 `filter: brightness(0.9)` 사용하는가 |
| JSON 데이터 | 각 HTML에 대응하는 `-data.json` 파일이 존재하는가. fetch 경로가 파일명과 일치하는가 |
| 모달 (해당 시) | 모달 `z-index`가 nav(100)보다 높은가. 닫기 버튼/오버레이 클릭에 닫기 함수가 연결돼 있는가 |
| CSS 파일 참조 | 모든 HTML의 `<head>`에 `<link rel="stylesheet" href="{PREFIX}-001.css">`가 있는가. 공통 CSS가 `<style>`에 중복 정의되지 않았는가 |

---

## 품질 기준

1. **실제 서비스처럼 보인다** — 프로토타입이지만 완성도 높은 UI, SFR-018.html 수준
2. **더미 데이터가 사실적이다** — 한국어, 실제 업무 맥락에 맞는 이름/날짜/내용. JSON에서 로드
3. **데스크탑에서 깨지지 않는다** — 최소 1280px 이상에서 정상 표시
4. **코드가 정리되어 있다** — `/* ── 섹션명 ── */` 주석으로 영역 구분, CSS 변수 일관성
5. **인터랙티브하다** — 화면 이동, 모달, 호버, 패널 토글 등 동작하는 프로토타입
6. **Live Server에서 완벽 동작** — 링크 이동, JSON 로드, 모든 JS가 정상 실행
