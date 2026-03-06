---
name: code-comment
description: "한글 주석 자동 작성"
allowed-tools: Read, Glob, Grep, Bash, Write
agent: fork
---

# 한글 주석 자동 작성 (code-comment)

이 스킬이 호출되면 아래 워크플로우를 순서대로 실행한다.
주석 작성 전 반드시 사용자 확인을 거친다. 파일을 무단으로 수정하지 않는다.

---

## 워크플로우

### Step 1 — 대상 파일 확인
스킬 호출 시 파일 또는 경로가 지정되지 않은 경우, 사용자에게 되묻는다.

> "주석을 달 파일 또는 디렉토리 경로를 지정해 주세요."

파일이 지정된 경우 Step 2로 즉시 진행한다.
단, 여러 파일이 지정되거나 디렉토리 내의 다수 파일을 처리해야 하는 경우 다음 실행 방식을 따른다:
- **현재 에이전트가 서브에이전트(subagent) 또는 병렬(parallel) 수행 기능이 가능한 경우**: 각 파일에 대한 주석 적용 작업을 병렬로 수행할 것.
- **병렬 수행이 불가능한 경우**: 파일 하나씩 순차적으로(sequential) 실행할 것.

---

### Step 2 — 언어 및 프레임워크 감지

`prompts/style-guide.md` 의 감지 우선순위 표를 참조한다.

```bash
# 1. 확장자 확인
ls <대상경로> 2>/dev/null

# 2. 확장자가 .ts .js .tsx .jsx 인 경우에만 실행
cat package.json 2>/dev/null | grep -E '"react"|"next"|"vue"|"svelte"|"express"' | head -5

# 3. 확장자가 .py 인 경우에만 실행
cat requirements.txt pyproject.toml 2>/dev/null | grep -iE "fastapi|django|flask" | head -3
```

감지 결과를 확정한 뒤 Step 3으로 진행한다.
해당 언어의 스타일 예시만 `prompts/style-guide.md` 에서 참조한다. (전체 파일 불필요)

---

### Step 3 — 주석 작성

작성 규칙은 `prompts/comment-rules.md` 참조.
스타일 예시는 `prompts/style-guide.md` 의 감지된 언어 섹션만 참조.

---

### Step 4 — 결과 미리보기 및 사용자 확인

주석이 추가된 전체 파일 내용을 대화창에 출력하고 승인을 요청한다.
**만약 git 이력에서 작성자를 찾지 못한 경우, 승인 요청 시 사용자에게 작성자 이름을 한 번 물어보아 입력받는다.**

> "위 내용으로 파일을 덮어쓸까요? (승인 / 수정 요청 / 취소)"

승인 전 파일을 절대 수정하지 않는다.

---

### Step 5 — 파일 반영

승인 시 원본 파일에 주석을 반영한다.
