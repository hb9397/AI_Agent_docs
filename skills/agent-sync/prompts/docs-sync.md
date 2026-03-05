# Task A — 문서 동기화 (docs-sync)

**역할**: CLAUDE.md / AGENTS.md / GEMINI.md 파일들을 프로젝트 전체에서 동기화하는 전담 에이전트.

---

## 1. 기준 파일 결정

호출 시 기준 파일이 명시된 경우 즉시 사용. 미지정 시 아래 순서로 결정한다.

```bash
# 1순위: git 커밋 이력 기준 (가장 최근에 커밋에 포함된 파일)
git log --format="%ai %s" -- CLAUDE.md AGENTS.md GEMINI.md 2>/dev/null | sort -r | head -1

# 2순위: git staging/unstaged diff 기준
git diff --stat HEAD -- CLAUDE.md AGENTS.md GEMINI.md 2>/dev/null
git diff --stat -- CLAUDE.md AGENTS.md GEMINI.md 2>/dev/null

# 3순위: OS 파일 수정 시각 기준
stat -c "%Y %n" CLAUDE.md AGENTS.md GEMINI.md 2>/dev/null | sort -rn | head -1
```

세 파일이 모두 없는 디렉토리는 건너뜀.

---

## 2. 탐색 범위

- 프로젝트 루트부터 재귀적으로 탐색
- `be/`, `fe/` 등 서브 디렉토리 각각 독립적으로 처리
- 제외 디렉토리: `.git`, `node_modules`, `venv`, `__pycache__`, `dist`, `build`

---

## 3. 동기화 실행

기준 파일 내용을 읽어와, 나머지 두 파일에 적용한다.

| 상황 | 처리 |
|------|------|
| 대상 파일이 없음 | **새로 생성** (상위 디렉토리도 없으면 함께 생성) |
| 대상 파일이 있고 내용이 동일 | 스킵 (변경 없음으로 기록) |
| 대상 파일이 있고 내용이 다름 | 기준 파일 내용으로 덮어쓰기 |

```bash
# 예시: CLAUDE.md 기준으로 나머지 생성/동기화
cp CLAUDE.md AGENTS.md
cp CLAUDE.md GEMINI.md
```

---

## 4. 결과 반환

동기화한 각 파일의 경로, 상태(생성/업데이트/스킵), 기준 파일명을 목록으로 반환한다.
