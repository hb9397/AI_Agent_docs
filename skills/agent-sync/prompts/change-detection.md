# Agent 문서 변경 감지 규칙 (change-detection)

## 라우팅 표

| 조건 | 읽을 섹션 |
| ---- | --------- |
| git 적용 여부 확인 | [Git 감지] |
| git 있음 | [Git Diff 감지] |
| git 없음 — OS 종류 확인 | [OS 감지] |
| git 없음 — Windows | [Mtime — Windows] |
| git 없음 — Linux / macOS | [Mtime — Unix] |

---

## [Git 감지]

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

- 출력이 `true` → git 적용됨, [Git Diff 감지] 진행
- 명령 실패 또는 출력 없음 → git 미적용, [OS 감지] 진행

---

## [Git Diff 감지]

아래 명령으로 unstaged + staged 변경 파일을 수집하고 유형별로 분류한다.

```bash
# 변경 파일 전체 목록 (unstaged + staged 합산)
git diff --name-only HEAD 2>/dev/null
git diff --name-only --cached 2>/dev/null
```

**Skills 경로 필터 (Task B 입력)**

```bash
git diff --name-only HEAD 2>/dev/null | grep -E "(^skills/|\.agents/skills/|\.claude/skills/)"
git diff --name-only --cached 2>/dev/null | grep -E "(^skills/|\.agents/skills/|\.claude/skills/)"
```

- 결과에서 스킬 디렉토리명(`<skill-name>`)을 추출한다.
- 결과가 비어 있으면: "변경된 Skills가 감지되지 않았습니다."

**Doc 파일 필터 (Task A 입력)**

```bash
git diff --name-only HEAD 2>/dev/null | grep -E "(CLAUDE|AGENTS)\.md$"
git diff --name-only --cached 2>/dev/null | grep -E "(CLAUDE|AGENTS)\.md$"
```

- 결과가 비어 있으면: "변경된 Agent 문서가 감지되지 않았습니다."

---

## [OS 감지]

```bash
uname -s 2>/dev/null || powershell -Command "echo Windows" 2>/dev/null
```

- `Linux` / `Darwin` → [Mtime — Unix] 진행
- `Windows` 또는 `uname` 실패 → [Mtime — Windows] 진행

---

## [Mtime — Windows]

```bash
# 최근 수정된 Skills 파일 목록
powershell -Command "Get-ChildItem -Recurse -Filter 'SKILL.md' -Path 'skills','.agents/skills','.claude/skills' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 10 FullName, LastWriteTime" 2>/dev/null

# 최근 수정된 Doc 파일 목록
powershell -Command "Get-ChildItem -Recurse -Include 'CLAUDE.md','AGENTS.md' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch 'node_modules|venv|__pycache__' } | Sort-Object LastWriteTime -Descending | Select-Object -First 5 FullName, LastWriteTime" 2>/dev/null
```

수정 시각 기준으로 변경이 의심되는 파일 목록을 구성한다.
명확한 기준 시각이 없으면 사용자에게 확인: "어느 파일에 변경이 있었는지 지정해 주세요."

---

## [Mtime — Unix]

```bash
# 최근 수정된 Skills 파일 (mtime 내림차순)
find skills .agents/skills .claude/skills -name "SKILL.md" -type f 2>/dev/null \
  | xargs stat -c "%Y %n" 2>/dev/null | sort -rn | head -10

# 최근 수정된 Doc 파일
find . -maxdepth 4 \( -name "CLAUDE.md" -o -name "AGENTS.md" \) \
  -type f 2>/dev/null \
  | grep -v "node_modules\|venv\|__pycache__" \
  | xargs stat -c "%Y %n" 2>/dev/null | sort -rn | head -5
```

수정 시각 기준으로 변경이 의심되는 파일 목록을 구성한다.
명확한 기준 시각이 없으면 사용자에게 확인: "어느 파일에 변경이 있었는지 지정해 주세요."
