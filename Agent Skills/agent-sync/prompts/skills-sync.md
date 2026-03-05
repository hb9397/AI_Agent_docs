# Task B — Skills 동기화 (skills-sync)

**역할**: `.agents/skills`, `.claude/skills` 와 `.gemini/commands` 를 동기화하는 전담 에이전트.

---

## 1. 현재 상태 파악

```bash
# git 기준: 변경된 스킬 파악
git diff --name-only HEAD -- "*/skills/**" 2>/dev/null

# fallback: 파일 시스템 mtime 기준
find . -path "*/skills/*/SKILL.md" ! -path "*/node_modules/*" ! -path "*/venv/*" \
  -printf "%T@ %p\n" 2>/dev/null | sort -rn
```

---

## 2. 동기화 대상 경로

아래 세 경로를 **모두 동기화** 대상으로 처리한다.  
경로가 존재하지 않아도 **자동 생성**한 뒤 동기화를 진행한다.

```
.agents/skills/     ← 주 기준 경로 (be/.agents/skills/ 등)
.claude/skills/     ← 보조 경로 (없으면 mkdir 후 생성)
```

```bash
# 경로 자동 생성 예시
mkdir -p .claude/skills .gemini/commands
```

---

## 3. 스킬 동기화 규칙

| 변경 유형 | 판단 방법 | 처리 |
|-----------|-----------|------|
| 스킬 추가 | 기준 경로에만 있고 나머지에 없음 | 나머지 경로에 **복사** |
| 스킬 삭제 | git diff로 D(deleted) 감지 또는 기준에서 사라짐 | 나머지 경로에서도 **삭제** |
| 스킬 수정 | git diff 또는 mtime 비교로 최신 버전 판별 | 나머지 경로에 **덮어쓰기** |
| 변경 없음 | 내용과 구조 동일 | **스킵** |

스킬 단위는 `skills/<skill-name>/` 디렉토리 전체를 대상으로 한다 (하위 파일 포함).

---

## 4. Gemini CLI Commands 동기화

`.gemini/commands/` 경로가 없으면 자동 생성한다.

```bash
mkdir -p .gemini/commands
```

### 스킬 추가 시

`.gemini/commands/<skill-name>.toml` 파일을 생성한다:

```toml
description = ".agents/skills/<skill-name> 실행"
execute = ".agents/skills/<skill-name>"
prompt = ".agents/skills/<skill-name> 에 정의된 Skills 를 수행해줘"
```

### 스킬 삭제 시

대응하는 `.gemini/commands/<skill-name>.toml` 을 삭제한다.

### 스킬 목록 확인

```bash
# 현재 스킬 목록
ls .agents/skills/

# .gemini/commands 현재 상태
ls .gemini/commands/
```

---

## 5. 결과 반환

동기화한 각 스킬의 이름, 작업 유형(추가/삭제/수정/스킵), 대상 경로 목록과  
`.gemini/commands` 변경 내역을 반환한다.
