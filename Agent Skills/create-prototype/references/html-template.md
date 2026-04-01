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
<style>
  /* CSS 변수와 커스텀 클래스 이 안에 정의 */
</style>
</head>
```

---

## 필수 CSS 클래스 정의

아래는 `<style>` 블록 안에 **항상** 포함해야 할 기본 CSS이다.
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
}
.tab-btn:hover { background: rgba(255,255,255,.1); color: #fff; }
.tab-btn.active { background: var(--primary); color: #fff; }

/* ── 화면 전환 ── */
.screen { display: none; }
.screen.active {
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

## 필수 JavaScript 함수

```javascript
// 화면 전환 (다중 화면일 때) — onclick="showScreen('id', this)" 형태로 호출
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

// 패널 토글 (우측 사이드 패널 등)
function togglePanel(panelName) {
  const activeScreen = document.querySelector('.screen.active');
  if (!activeScreen) return;
  // panelName에 해당하는 패널 찾아서 .active 토글
  const panel = activeScreen.querySelector('[data-panel="' + panelName + '"]');
  if (panel) panel.classList.toggle('active');
}
```

---

## 화면 유형별 body 구조

### 유형 A: 다중 화면 (탭 전환)
```html
<body>
  <nav class="page-nav">
    <div class="logo">{프로젝트명} <span>DEMO</span></div>
    <button class="tab-btn active" onclick="showScreen('s001-main', this)">메인</button>
    <button class="tab-btn" onclick="showScreen('s001-list', this)">목록</button>
  </nav>
  <div id="s001-main" class="screen active">...</div>
  <div id="s001-list" class="screen">...</div>
  <script>/* showScreen(id, btn) 함수 */</script>
</body>
```

### 유형 B: 단일 화면 (앱 셸)
```html
<body>
  <div class="screen active" style="height:100vh;">
    <div class="screen-label">
      <span class="badge">SFR-001</span> {화면 설명}
    </div>
    <div class="app-shell">
      <aside class="sidebar">...</aside>
      <main class="main">...</main>
    </div>
  </div>
</body>
```

### 유형 C: 단일 화면 (목록/대시보드)
```html
<body style="background: var(--bg);">
  <div style="padding: 30px 40px; max-width: 1200px; margin: 0 auto;">
    <h1>...</h1>
    <!-- 콘텐츠 -->
  </div>
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
