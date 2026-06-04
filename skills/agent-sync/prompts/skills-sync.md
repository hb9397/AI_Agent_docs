# Task B — Skills 동기화 (skills-sync)

**역할**: SKILL.md Step 2에서 전달받은 변경된 Skills 목록을 기준으로 저장소 원본 `skills/`와 설치 대상 `.agents/skills`, `.claude/skills`를 동기화하는 전담 에이전트.

---

## 1. 대상 스킬 목록 수신

SKILL.md Step 2에서 감지된 변경된 스킬 경로 목록을 입력으로 받는다.

목록이 비어 있는 경우(git diff 결과 없음 등) → **폴백: MD5 비교**로 원본 경로와 설치 대상 경로 간 불일치 파일을 탐지한다.

```bash
# 폴백: skills, .agents/skills, .claude/skills 직접 비교 (find . 전체 스캔 금지)
find skills -name "SKILL.md" -type f 2>/dev/null
find .agents/skills -name "SKILL.md" -type f 2>/dev/null
find .claude/skills -name "SKILL.md" -type f 2>/dev/null

# 스킬별 MD5 비교
md5sum skills/<skill-name>/SKILL.md 2>/dev/null \
  || md5 -q skills/<skill-name>/SKILL.md 2>/dev/null
```

> **중요**: `find .` 전체 스캔 금지. 반드시 `skills`, `.agents/skills`, `.claude/skills` 경로를 명시적으로 지정한다.
> 체크섬 비교가 불가능한 경우 파일을 Read하여 내용을 줄 단위로 비교한다.

---

## 2. 동기화 대상 경로

아래 세 경로를 처리한다. `skills/`는 저장소 원본 경로이며, `.agents/skills/`와 `.claude/skills/`는 설치 대상 경로다.
설치 대상 경로가 존재하지 않아도 **자동 생성**한 뒤 동기화를 진행한다.

```
skills/             ← 저장소 원본 경로
.agents/skills/     ← 설치 대상 경로
.claude/skills/     ← 설치 대상 경로 (없으면 mkdir 후 생성)
```

```bash
mkdir -p .agents/skills
mkdir -p .claude/skills
```

---

## 3. 스킬 동기화 규칙

| 변경 유형 | 판단 방법 | 처리 |
| --------- | --------- | ---- |
| 스킬 추가 | 원본 경로에만 있고 설치 대상에 없음 | 설치 대상 경로에 **복사** |
| 스킬 삭제 | git diff D(deleted) 감지 또는 원본에서 사라짐 | 설치 대상 경로에서도 **삭제** |
| 스킬 수정 | **체크섬(MD5) 불일치** → 원본 기준으로 내용 직접 비교 | 설치 대상 경로에 **덮어쓰기** |
| 변경 없음 | 체크섬 동일 **AND** 파일 수 동일 | **스킵** |

> **스킵 판단 기준**: 두 조건을 모두 충족해야 스킵한다.
> - 체크섬이 같아도 하위 파일 수가 다르면 전체 재복사한다.
> - 체크섬 명령 실패 시 파일을 Read하여 내용을 직접 비교한다. 비교 불가 시 항상 덮어쓰기한다.

스킬 단위는 `skills/<skill-name>/` 디렉토리 전체를 대상으로 한다 (하위 파일 포함).

---

## 4. 결과 반환

동기화한 각 스킬의 이름, 작업 유형(추가/삭제/수정/스킵), 대상 경로 목록을 반환한다.
