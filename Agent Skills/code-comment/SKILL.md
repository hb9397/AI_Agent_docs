---
name: code-comment
description: "한글 주석 자동 작성 — 코드에 주석을 달아달라거나, 주석을 추가·갱신할 때, 변경된 파일에 주석을 적용할 때, comment 추가를 요청할 때 호출한다."
allowed-tools: Read, Glob, Grep, Bash, Write
agent: fork
---

# 한글 주석 자동 작성 (code-comment)

변경된 코드를 감지하고, 해당 파일에 한글 주석을 작성·갱신한다.
승인 전 파일을 절대 수정하지 않는다.

---

## 진입 분기

| 상황 | Step 2 진입 경로 |
| ---- | ---------------- |
| 특정 파일 지정 + git 적용됨 | Step 2A — git diff로 해당 파일 변경 확인 |
| 특정 파일 지정 + git 미적용 | Step 2B — mtime으로 해당 파일 변경 확인 |
| 파일 미지정 + git 적용됨 | Step 2C — git diff로 전체 변경 파일 목록 추출 |
| 파일 미지정 + git 미적용 | Step 2D — 사용자에게 파일 질문 후 진행 |

---

## Step 1 — Git 적용 여부 감지

세부 규칙은 `prompts/change-detection.md`의 [Git 감지] 섹션을 참조한다.

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

---

## Step 2 — 대상 파일 결정

진입 분기표에 따라 해당하는 경로를 실행한다.
세부 규칙은 `prompts/change-detection.md`의 [대상 파일 결정] 섹션을 참조한다.

> ✋ **확인 게이트** (Step 2D — 파일 미지정 + git 미적용인 경우만)
> "주석을 적용할 파일 또는 디렉토리 경로를 지정해 주세요."
> **사용자가 경로를 제공한 뒤 Step 3으로 진행한다.**

대상 파일이 여러 개인 경우:

- sub-agent 지원 환경: 각 파일에 대해 Step 3~5를 병렬 처리
- 미지원 환경: 파일 하나씩 순차 처리

---

## Step 3 — 언어 및 프레임워크 감지

`prompts/style-guide.md`의 감지 우선순위 표를 참조한다.

```bash
# 1. 확장자 확인
ls <대상경로> 2>/dev/null

# 2. .ts .js .tsx .jsx 인 경우에만
cat package.json 2>/dev/null | grep -E '"react"|"next"|"vue"|"svelte"|"express"' | head -5

# 3. .py 인 경우에만
cat requirements.txt pyproject.toml 2>/dev/null | grep -iE "fastapi|django|flask" | head -3
```

감지된 언어의 스타일 섹션만 `prompts/style-guide.md`에서 참조한다.

---

## Step 4 — 주석 작성

작성 규칙은 `prompts/comment-rules.md` 참조.
스타일 예시는 `prompts/style-guide.md`의 감지된 언어 섹션만 참조.

---

## Step 5 — 결과 미리보기 및 사용자 확인

주석이 추가된 전체 파일 내용을 대화창에 출력하고 승인을 요청한다.
**git 이력에서 작성자를 찾지 못한 경우, 승인 요청 시 사용자에게 작성자 이름을 한 번 물어본다.**

> ✋ **확인 게이트**
> "위 내용으로 파일을 덮어쓸까요? (승인 / 수정 요청 / 취소)"
> **승인 전 파일을 절대 수정하지 않는다.**

---

## Step 6 — 파일 반영 (승인 후에만 실행)

승인 시 원본 파일에 주석을 반영한다.
