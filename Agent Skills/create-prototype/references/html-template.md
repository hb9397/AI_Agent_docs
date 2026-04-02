# HTML Template — 프로토타입 기본 골격

이 파일은 프로토타입 HTML의 기본 구조를 정의한다.
모든 프로토타입은 이 골격을 기반으로 확장한다.

---

## 기본 `<head>` 구조

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{SFR번호} — {프로젝트명} 화면 예시</title>
<!-- 폰트 -->
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<!-- Tailwind CSS CDN -->
<script src="https://cdn.tailwindcss.com"></script>
<!-- 공통 CSS (1개 파일로 통합) -->
<link rel="stylesheet" href="{PREFIX}-001.css">
<style>
  /* 이 화면 전용 CSS만 여기에 작성 */
</style>
</head>
```

---

## 필수 CSS 클래스 정의 — `{PREFIX}-001.css`

아래는 **공통 CSS 파일** (`{PREFIX}-001.css`)에 작성하는 내용이다.
모든 HTML이 이 파일 하나를 `<link rel="stylesheet">`로 참조한다.
색상 변수 부분은 `color-system.md`를 참고하여 메인색상에 맞게 채운다.

```css
/* ── CSS 변수 (color-system.md 참조) ── */
:root {
  --bg: #F4F6F9;
  --surface: #FFFFFF;
  --surface2: #EEF1F6;
  --border: #D8DDE8;
  --primary: {메인색상};
  --primary-light: {파생};
  --primary-mid: {파생};
  --nav-bg: {파생};
  --sky: #0EA5E9;
  --sky-light: #E0F2FE;
  --green: #16A34A;
  --green-light: #DCFCE7;
  --orange: #EA580C;
  --orange-light: #FFF7ED;
  --purple: #7C3AED;
  --purple-light: #F3E8FF;
  --red: #EF4444;
  --red-light: #FEE2E2;
  --amber: #F59E0B;
  --text-primary: #111827;
  --text-secondary: #4B5563;
  --text-muted: #9CA3AF;
  --sidebar-w: 260px;
  --header-h: 52px;
}

/* ── 리셋 ── */
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Noto Sans KR', sans-serif;
  background: var(--bg);
  color: var(--text-primary);
  font-size: 13px;
  line-height: 1.5;
}

/* ── 상단 내비게이션 탭 (다중 화면용) ── */
.page-nav {
  position: sticky; top: 0; z-index: 100;
  background: var(--nav-bg);
  display: flex; align-items: center; gap: 4px;
  padding: 0 20px; height: 36px;
  box-shadow: 0 2px 8px rgba(0,0,0,.18);
}
.page-nav .logo {
  font-size: 13px; font-weight: 700; color: #fff;
  margin-right: 24px; white-space: nowrap;
  display: flex; align-items: center; gap: 8px;
}
.page-nav .logo span {
  background: var(--sky); color: #fff;
  border-radius: 4px; padding: 2px 7px; font-size: 11px;
}
.tab-btn {
  border: none; background: transparent; cursor: pointer;
  color: rgba(255,255,255,.6); font-family: inherit;
  font-size: 12.5px; font-weight: 500;
  padding: 6px 14px; border-radius: 6px;
  transition: all .2s;
  text-decoration: none; /* <a> 태그용 */
}
.tab-btn:hover { background: rgba(255,255,255,.1); color: #fff; }
.tab-btn.active { background: var(--primary); color: #fff; }

/* ── 화면 ── */
.screen {
  display: flex; flex-direction: column;
  height: calc(100vh - 36px); overflow: hidden;
}

/* ── 화면 라벨 바 ── */
.screen-label {
  background: var(--nav-bg); color: #fff;
  padding: 4px 24px;
  font-size: 11px; font-weight: 600;
  display: flex; align-items: center; gap: 12px;
  flex-shrink: 0;
}
.screen-label .badge {
  background: var(--sky); color: #fff;
  border-radius: 4px; padding: 2px 8px; font-size: 10.5px;
}
.screen-label .sub { color: rgba(255,255,255,.6); font-weight: 400; }

/* ── 앱 셸 ── */
.app-shell { display: flex; flex: 1; overflow: hidden; }

/* ── 사이드바 ── */
.sidebar {
  width: var(--sidebar-w); min-width: var(--sidebar-w);
  background: var(--surface);
  border-right: 1px solid var(--border);
  display: flex; flex-direction: column;
  overflow-y: auto;
}
.sidebar-section {
  padding: 8px 0;
  border-bottom: 1px solid var(--border);
}
.sidebar-section:last-child { border-bottom: none; flex: 1; }
.sidebar-heading {
  font-size: 10.5px; font-weight: 700; letter-spacing: .05em;
  color: var(--text-muted); text-transform: uppercase;
  padding: 6px 14px 4px;
}
.sidebar-item {
  display: flex; align-items: center; gap: 8px;
  padding: 6px 14px;
  font-size: 12px; color: var(--text-secondary);
  cursor: pointer; transition: background .15s;
}
.sidebar-item:hover { background: var(--primary-light); color: var(--primary); }
.sidebar-item.active { background: var(--primary-light); color: var(--primary); font-weight: 600; }

/* ── 메인 콘텐츠 ── */
.main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

/* ── 상단 바 ── */
.topbar {
  height: 32px; min-height: 32px;
  background: var(--surface); border-bottom: 1px solid var(--border);
  display: flex; align-items: center; padding: 0 16px; gap: 12px;
  font-size: 11.5px;
}
.topbar .meta-badge {
  background: var(--primary-light); color: var(--primary);
  border-radius: 5px; padding: 3px 8px; font-weight: 600; font-size: 11.5px;
}

/* ── 버튼 ── */
.btn {
  border: none; border-radius: 7px; cursor: pointer;
  font-family: inherit; font-size: 12px; font-weight: 600;
  padding: 7px 14px; transition: all .15s;
  display: inline-flex; align-items: center; justify-content: center; gap: 6px;
}
.btn-primary { background: var(--primary); color: #fff; }
.btn-primary:hover { filter: brightness(0.9); }
.btn-secondary { background: var(--surface2); color: var(--text-secondary); }
.btn-secondary:hover { background: var(--border); }
.btn-green { background: var(--green); color: #fff; }
.btn-green:hover { filter: brightness(0.9); }
.btn-icon { background: var(--surface2); color: var(--text-secondary); padding: 7px 10px; }

/* ── 입력 필드 ── */
.input-field {
  width: 100%; padding: 8px 12px;
  border: 1px solid var(--border); border-radius: 6px;
  font-family: inherit; font-size: 13px;
  background: var(--surface); outline: none;
  transition: border-color .2s;
}
.input-field:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 3px var(--primary-light);
}

/* ── 카드 ── */
.card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 10px; padding: 16px;
  box-shadow: 0 2px 6px rgba(0,0,0,.02);
}

/* ── 태그/뱃지 ── */
.tag {
  display: inline-flex; align-items: center;
  padding: 2px 8px; border-radius: 4px;
  font-size: 11px; font-weight: 600;
}
.chip {
  font-size: 10px; font-weight: 600; padding: 1px 6px;
  border-radius: 10px;
}

/* ── 데이터 테이블 ── */
.data-table { width: 100%; border-collapse: collapse; }
.data-table th {
  text-align: left; padding: 8px 12px;
  font-size: 11px; font-weight: 600;
  color: var(--text-muted);
  border-bottom: 2px solid var(--border);
  background: var(--surface2);
}
.data-table td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--border);
  font-size: 13px;
}
.data-table tr:hover { background: var(--primary-light); }

/* ── 검색 바 (목록 화면용) ── */
.search-bar {
  width: 100%; padding: 14px 20px; font-size: 15px;
  border: 1px solid var(--border); border-radius: 8px;
  font-family: inherit; margin-bottom: 20px;
  background: var(--surface); outline: none;
  padding-left: 48px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.02);
  transition: border-color 0.2s;
}
.search-bar:focus { border-color: var(--primary); }

/* ── 목록 카드 (그리드 배치) ── */
.grid-container {
  display: grid; grid-template-columns: 1fr 1fr; gap: 20px;
}
.list-card {
  background: var(--surface); border: 1px solid var(--border);
  border-radius: 12px; padding: 24px;
  display: flex; flex-direction: column; cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  box-shadow: 0 4px 12px rgba(0,0,0,0.02);
}
.list-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.06);
  border-color: var(--primary-mid);
}

/* ── 스크롤바 ── */
::-webkit-scrollbar { width: 5px; height: 5px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }

/* ── 애니메이션 ── */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(6px); }
  to { opacity: 1; transform: translateY(0); }
}

/* ── 반응형 (최소한) ── */
@media (max-width: 900px) {
  .sidebar { width: 160px; min-width: 160px; }
}
```

---

## 필수 JavaScript

### 데이터 로드 (모든 화면 공통)

```javascript
// JSON 데이터 로드 — 각 HTML 파일에 포함
document.addEventListener('DOMContentLoaded', async () => {
  try {
    const res = await fetch('{PREFIX}-001-entry-data.json');
    const data = await res.json();
    renderData(data);
  } catch (e) {
    console.warn('데이터 파일 로드 실패 (Live Server에서 실행해주세요):', e);
  }
});

// renderData는 화면마다 다르게 구현
function renderData(data) {
  // 예: 카드 목록 렌더링
  const container = document.getElementById('card-container');
  container.innerHTML = data.cards.map(card => `
    <div class="list-card">
      <div style="font-size:28px;">${card.icon}</div>
      <h3>${card.title}</h3>
      <p>${card.desc}</p>
    </div>
  `).join('');
}
```

### 패널 토글 (필요 시)

```javascript
function togglePanel(panelName) {
  const panel = document.querySelector('[data-panel="' + panelName + '"]');
  if (panel) panel.classList.toggle('active');
}
```

### 화면 내 서브탭 전환 (필요 시)

단일 파일 내에서 서브탭이 필요한 경우에만 사용한다. 화면 간 이동은 `<a href>` 링크를 쓴다.

```javascript
function showScreen(id, btn) {
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById(id).classList.add('active');
  if (btn && btn.classList.contains('tab-btn')) {
    btn.classList.add('active');
  } else {
    const tabBtn = document.querySelector(`.tab-btn[onclick*="${id}"]`);
    if (tabBtn) tabBtn.classList.add('active');
  }
}
```

---

## 화면 유형별 body 구조

### 유형 A: 다중 화면 (링크 이동 — 각 파일)

각 HTML 파일이 독립 완성 파일이며, `<a href>` 상대경로로 이동한다.

```html
<!-- SFR-001-entry.html -->
<body>
  <nav class="page-nav">
    <div class="logo">{프로젝트명} <span>DEMO</span></div>
    <a class="tab-btn active" href="SFR-001-entry.html">진입화면</a>
    <a class="tab-btn" href="SFR-001-list.html">목록</a>
    <a class="tab-btn" href="SFR-001-detail.html">상세</a>
  </nav>
  <div class="screen active" style="height:calc(100vh - 36px); overflow:auto;">
    <div id="card-container"><!-- JSON 데이터로 렌더링 --></div>
  </div>
  <script>/* fetch + renderData */</script>
</body>
```

> `active` 클래스는 현재 페이지에 해당하는 `<a>` 태그에만 부여. `showScreen()` 불필요.

### 유형 B: 단일 화면 (앱 셸)
```html
<body>
  <div class="screen active" style="height:100vh;">
    <div class="screen-label">
      <span class="badge">SFR-001</span> {화면 설명}
    </div>
    <div class="app-shell">
      <aside class="sidebar">...</aside>
      <main class="main">
        <div id="data-container"><!-- JSON 데이터로 렌더링 --></div>
      </main>
    </div>
  </div>
  <script>/* fetch + renderData */</script>
</body>
```

### 유형 C: 단일 화면 (목록/대시보드)
```html
<body style="background: var(--bg);">
  <div style="padding: 30px 40px; max-width: 1200px; margin: 0 auto;">
    <h1>...</h1>
    <div id="data-container"><!-- JSON 데이터로 렌더링 --></div>
  </div>
  <script>/* fetch + renderData */</script>
</body>
```

---

## 모달 패턴

모달이 필요한 화면에서 사용하는 기본 구조. `z-index`는 nav(100)보다 높게 설정한다.

```css
/* ── 모달 ── */
.modal-overlay {
  display: none; position: fixed; top: 0; left: 0;
  width: 100%; height: 100%;
  background: rgba(0,0,0,0.5); z-index: 1000;
  align-items: center; justify-content: center;
}
.modal-overlay.active { display: flex; }
.modal-box {
  background: var(--surface); width: 600px; max-width: 90%;
  border-radius: 12px; overflow: hidden;
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}
.modal-header {
  padding: 16px 20px; border-bottom: 1px solid var(--border);
  display: flex; justify-content: space-between; align-items: center;
  background: var(--bg);
}
.modal-body { padding: 24px 20px; overflow-y: auto; }
.modal-footer {
  padding: 16px 20px; border-top: 1px solid var(--border);
  display: flex; justify-content: flex-end; background: var(--bg);
}
```

```html
<div id="myModal" class="modal-overlay" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <div class="modal-header">
      <h3 style="font-size:16px; font-weight:700;">제목</h3>
      <button onclick="closeModal()" style="background:transparent; border:none; font-size:20px; cursor:pointer; color:var(--text-muted);">&times;</button>
    </div>
    <div class="modal-body">내용</div>
    <div class="modal-footer">
      <button class="btn btn-primary" onclick="closeModal()">확인</button>
    </div>
  </div>
</div>
```

```javascript
function openModal(id) { document.getElementById(id).classList.add('active'); }
function closeModal(id) {
  // id가 있으면 해당 모달, 없으면 모든 모달 닫기
  if (id) { document.getElementById(id).classList.remove('active'); }
  else { document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('active')); }
}
```

---

## 슬라이드 패널 패턴

우측에서 슬라이드로 열리는 상세 패널.

```css
/* ── 슬라이드 패널 ── */
.slide-panel {
  width: 320px; min-width: 320px; background: var(--surface);
  border-left: 1px solid var(--border);
  display: none; flex-direction: column; overflow-y: auto;
}
.slide-panel.active { display: flex; }
```

---

## 주석 컨벤션

코드 가독성을 위해 아래 형식의 주석을 사용한다:

```css
/* ── 섹션명 ─────────────────────────────── */
```

```html
<!-- ═══════ 화면 이름 ═══════ -->
```

각 `.screen`, 주요 영역(사이드바, 메인, 패널), 모달 등에 주석을 붙인다.
