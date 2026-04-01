# create-prototype 스킬 개선 작업 — 대화 요약

> 다른 에이전트가 이 작업의 맥락을 파악할 수 있도록 작성된 핸드오프 문서.
> 작성 기준일: 2026-04-01

---

## 1. 작업 배경

사용자가 `create-prototype` 스킬로 HTML 프로토타입을 생성했을 때 두 가지 문제를 겪었다.

1. **화면 렌더링 오류**: 코드는 생성됐지만 JS가 실행되지 않아 화면 요소가 비어 보이거나 의도와 다른 UI가 나타남
2. **Claude Code 사용량 급증**: 프로토타입 1개를 만드는데 사용량이 거의 소진됨

---

## 2. 원인 분석 (수정 전)

### 문제 ① — innerHTML + fragment `<script>` 비실행 [가장 치명적]

스킬은 화면이 4개 이상이거나 700줄 초과이면 **분리 구조**로 전환했다:
- 메인 파일이 `fetch()`로 조각 HTML을 가져와 `innerHTML`로 주입
- 조각 파일 안에 `<script>` 태그 포함

**브라우저는 `innerHTML`로 삽입된 `<script>`를 실행하지 않는다.** 화면별 초기화 JS가 전부 죽는 구조적 버그였다.

### 문제 ② — file:// 환경에서 fetch 차단

스킬 문서 자체가 "파일 직접 열기(file://)에서는 fetch가 차단된다"고 명시하면서도, 분리 구조를 기본으로 사용했다. 에러 처리도 없어 첫 화면부터 빈 화면으로 보였다.

### 문제 ③ — showScreen의 암묵적 전역 event 의존

```js
// 수정 전 (취약한 패턴)
function showScreen(id) {
  // ...
  event.currentTarget.classList.add('active'); // 전역 event에 의존
}
```

`addEventListener`나 프로그래밍 방식 호출 시 깨지는 취약한 패턴.

### 문제 ④ — CSS 변수명 불일치

| 파일 | 변수명 |
|---|---|
| `html-template.md` | `--primary`, `--primary-light`, `--primary-mid`, `--nav-bg` |
| `SFR-018.html` (예제) | `--blue`, `--blue-light`, `--blue-mid` (--primary 없음) |
| `color-system.md` | `--primary`, `--primary-light`, `--primary-mid`, `--nav-bg` |

예제가 템플릿과 변수명이 달라 모델이 혼동 → 산출물마다 변수 체계가 달라짐.

### 문제 ⑤ — Tailwind CDN 불일치

`html-template.md`는 Tailwind CDN을 필수로 요구하지만, 품질 기준 예제인 `SFR-018.html`에는 CDN이 없었다.

### 문제 ⑥ — 검증 단계 없음

생성 후 JS 동작 확인, ID 매칭 체크, 첫 화면 active 상태 확인 같은 self-check 단계가 없었다.

### 문제 ⑦ — 사용량 급증 원인

```
화면 4개 이상 → 분리 구조 강제 전환
→ 병렬 subagent (화면 수 + 1개)
→ 각 subagent에 공통 컨텍스트 반복 전달
→ 참조 파일도 큼 (SFR-018.html 1,698줄/102KB)
→ 입력 + 출력 + subagent 비용 합산 → 사용량 급증
```

---

## 3. 수정 작업 내역

총 4개 파일을 수정했다.

### 3-1. `SKILL.md`

| 변경 항목 | 내용 |
|---|---|
| `allowed-tools`에서 `Task` 제거 | subagent 비활성화 |
| 단일 파일 원칙 선언 추가 | 상단 문서에 명시 |
| 분리 구조 전체 섹션 제거 | fetch+innerHTML+조각 파일 구조 폐기 |
| `showScreen` 방식 업데이트 | `showScreen(id, this)` 형태로 명세 |
| **STEP 5 Self-check 추가** | 생성 직후 7개 항목 체크 의무화 |

**Self-check 7개 항목:**
1. Tailwind CDN이 `<head>`에 있는가
2. `:root`에 4개 변수(`--primary`, `--primary-light`, `--primary-mid`, `--nav-bg`) 모두 있는가
3. `--blue` 같은 색상명 변수가 오염되지 않았는가
4. `onclick="showScreen('id', this)"` 형태로 `this`를 전달하는가
5. 첫 번째 `.screen`과 `.tab-btn`에 `active` 클래스가 있는가
6. showScreen 인수 ID와 `<div id="...">` ID가 정확히 일치하는가
7. nav 배경에 HEX 하드코딩 대신 `var(--nav-bg)` 사용하는가

### 3-2. `references/html-template.md`

```js
// 수정 전
function showScreen(id) {
  // ...
  event.currentTarget.classList.add('active'); // 전역 event 의존
}

// 수정 후
function showScreen(id, btn) {
  // ...
  btn.classList.add('active'); // 명시적 파라미터
}
```

유형 A 예시의 onclick도 `this` 전달 형태로 수정.

### 3-3. `examples/SFR-018.html`

1. **Tailwind CDN 추가**
   ```html
   <script src="https://cdn.tailwindcss.com"></script>
   ```

2. **CSS 변수명 통일** (`:root` 정의 + 모든 참조)
   - `--blue` → `--primary`
   - `--blue-light` → `--primary-light`
   - `--blue-mid` → `--primary-mid`
   - `--nav-bg: #1E3A5F` 신규 추가

3. **하드코딩 색상 2곳 → CSS 변수로 대체**
   - `.page-nav { background: #1E3A5F }` → `var(--nav-bg)`
   - `.screen-label { background: #1E3A5F }` → `var(--nav-bg)`

4. **showScreen 함수 개선**
   ```js
   // 수정 후: tab-btn 여부 자동 감지
   function showScreen(id, btn) {
     document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
     document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
     document.getElementById(id).classList.add('active');
     if (btn && btn.classList.contains('tab-btn')) {
       btn.classList.add('active');
     } else {
       // 목록 아이템 등 비탭 버튼에서 호출 시, 해당 탭 자동 활성화
       const tabBtn = document.querySelector(`.tab-btn[onclick*="${id}"]`);
       if (tabBtn) tabBtn.classList.add('active');
     }
   }
   ```

5. **모든 onclick 호출에 `this` 추가** (5종, 14곳)

---

## 4. 수정 후 구조

```
create-prototype/
├── SKILL.md                  ← 수정됨: 분리구조 제거, Self-check 추가
├── references/
│   ├── html-template.md      ← 수정됨: showScreen(id, btn) 함수
│   └── color-system.md       ← 변경 없음
└── examples/
    └── SFR-018.html          ← 수정됨: CDN, 변수명, showScreen 함수
```

---

## 5. 현재 상태 (수정 완료)

| 문제 | 해결 방법 | 상태 |
|---|---|---|
| innerHTML + script 비실행 | 분리 구조 폐지 → 단일 파일만 | ✅ 완료 |
| file:// fetch 차단 | 분리 구조 폐지 → fetch 자체 없음 | ✅ 완료 |
| 사용량 급증 | Task/subagent 제거 | ✅ 완료 |
| showScreen 암묵적 event | btn 파라미터 + this 전달 | ✅ 완료 |
| CSS 변수 불일치 | 예제를 --primary 계열로 통일 | ✅ 완료 |
| Tailwind CDN 불일치 | 예제에 CDN 추가 | ✅ 완료 |
| 검증 단계 없음 | STEP 5 Self-check 추가 | ✅ 완료 |

---

## 6. 추가 작업 여부

현재 이 세션에서 완료하지 않은 작업:
- **없음.** 식별된 모든 문제에 대한 수정이 완료됐다.

향후 고려할 수 있는 추가 개선:
- SFR-018.html 외의 추가 예제 파일 확보 (현재 예제가 1개뿐)
- Self-check 항목을 자동화하는 검증 스크립트 작성
- `color-system.md`에 없는 색상(핑크, 노랑 등)의 파생값 레퍼런스 보강
