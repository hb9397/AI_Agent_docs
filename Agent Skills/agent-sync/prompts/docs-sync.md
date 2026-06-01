# Task A — 문서 동기화 (docs-sync)

**역할**: CLAUDE.md / AGENTS.md 파일들을 프로젝트 전체에서 동기화하는 전담 에이전트.

---

## 1. 기준 파일 결정

호출 시 기준 파일이 명시된 경우 즉시 사용. 미지정 시 아래 순서로 결정한다.

```bash
# 1순위: 파일 내용 체크섬 + 바이트 크기 비교 (가장 큰 파일 = 가장 많은 정보 보유)
wc -c CLAUDE.md AGENTS.md 2>/dev/null | sort -rn | head -2

# 2순위: git 커밋 이력 기준 (가장 최근 커밋에 포함된 파일)
git log --format="%ai %H" -- CLAUDE.md AGENTS.md 2>/dev/null | sort -r | head -3

# 3순위: OS 파일 수정 시각 기준
stat -c "%Y %n" CLAUDE.md AGENTS.md 2>/dev/null | sort -rn | head -1
```

> **판단 원칙**: git 결과만으로 기준 파일을 정하지 않는다.
> git diff가 비어 있어도 파일 크기나 내용이 다르면 큰 파일(또는 최근 mtime)을 기준으로 한다.

두 파일이 모두 없는 디렉토리는 건너뜀.

---

## 2. 탐색 범위

- 프로젝트 루트부터 재귀적으로 탐색
- `be/`, `fe/` 등 서브 디렉토리 각각 독립적으로 처리
- 제외 디렉토리: `.git`, `node_modules`, `venv`, `__pycache__`, `dist`, `build`

---

## 3. 동기화 실행

기준 파일 내용을 읽어와, 나머지 파일에 적용한다.

| 상황 | 처리 |
|------|------|
| 대상 파일이 없음 | **새로 생성** (상위 디렉토리도 없으면 함께 생성) |
| 대상 파일이 있고 내용이 동일 | 체크섬 **AND** 바이트 크기 모두 같을 때만 스킵 |
| 대상 파일이 있고 내용이 다름 | 기준 파일 내용으로 덮어쓰기 |

```bash
# 체크섬 비교 후 다를 때만 덮어쓰기
src_md5=$(md5sum CLAUDE.md 2>/dev/null | awk '{print $1}' || md5 -q CLAUDE.md 2>/dev/null)
dst_md5=$(md5sum AGENTS.md  2>/dev/null | awk '{print $1}' || md5 -q AGENTS.md  2>/dev/null)
[ "$src_md5" != "$dst_md5" ] && cp CLAUDE.md AGENTS.md
```

> 체크섬 명령이 모두 실패하는 환경(Gemini CLI 등)에서는 파일을 Read하여 내용을 직접 비교한다.
> 비교 불가 시 항상 덮어쓰기한다 (false-negative 방지).

---

## 4. 결과 반환

동기화한 각 파일의 경로, 상태(생성/업데이트/스킵), 기준 파일명을 목록으로 반환한다.
