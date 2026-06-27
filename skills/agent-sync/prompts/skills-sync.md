# Task B — Skills 횡적 동기화 (skills-sync)

**역할**: `.claude/skills` ↔ `.agents/skills` 간 **횡적 미러링**을 담당하는 전담 에이전트.

> **범위 제한**: 정본 레포(`AI_Agent_docs`) → 프로젝트 설치는 `harness-setup`이 담당한다.
> 이 Task는 **이미 설치된** 두 경로 간의 일치만 보장한다.

---

## 1. 대상 스킬 목록 수신

SKILL.md Step 2에서 감지된 변경된 스킬 경로 목록을 입력으로 받는다.

목록이 비어 있는 경우(git diff 결과 없음 등) → **폴백: MD5 비교**로 두 설치 경로 간 불일치 파일을 탐지한다.

```bash
# 폴백: .agents/skills, .claude/skills 직접 비교 (find . 전체 스캔 금지)
find .agents/skills -name "SKILL.md" -type f 2>/dev/null
find .claude/skills -name "SKILL.md" -type f 2>/dev/null

# 스킬별 MD5 비교
md5sum .claude/skills/<skill-name>/SKILL.md 2>/dev/null \
  || md5 -q .claude/skills/<skill-name>/SKILL.md 2>/dev/null
```

> **중요**: `find .` 전체 스캔 금지. 반드시 `.agents/skills`, `.claude/skills` 경로를 명시적으로 지정한다.
> 체크섬 비교가 불가능한 경우 파일을 Read하여 내용을 줄 단위로 비교한다.

---

## 2. 동기화 대상 경로

아래 두 설치 경로 간의 횡적 미러링을 처리한다.
기준 파일은 **더 최근에 수정된 쪽**이다 (git log 또는 mtime 기준).

```
.claude/skills/     ← 설치 경로 A
.agents/skills/     ← 설치 경로 B
```

설치 대상 경로가 존재하지 않아도 **자동 생성**한 뒤 동기화를 진행한다.

```bash
mkdir -p .agents/skills
mkdir -p .claude/skills
```

---

## 3. 스킬 동기화 규칙

| 변경 유형 | 판단 방법 | 처리 |
| --------- | --------- | ---- |
| 스킬 추가 | 한쪽에만 있고 다른 쪽에 없음 | 없는 쪽에 **복사** |
| 스킬 삭제 | 한쪽에서 삭제됨 (git diff D 또는 부재 확인) | 사용자 확인 후 다른 쪽에서도 **삭제** |
| 스킬 수정 | **체크섬(MD5) 불일치** → 더 최근 수정된 쪽을 기준으로 비교 | 기준 쪽 내용으로 **덮어쓰기** |
| 변경 없음 | 체크섬 동일 **AND** 파일 수 동일 | **스킵** |

> **스킵 판단 기준**: 두 조건을 모두 충족해야 스킵한다.
> - 체크섬이 같아도 하위 파일 수가 다르면 전체 재복사한다.
> - 체크섬 명령 실패 시 파일을 Read하여 내용을 직접 비교한다. 비교 불가 시 항상 덮어쓰기한다.

스킬 단위는 `<skill-name>/` 디렉토리 전체를 대상으로 한다 (하위 파일 포함).

---

## 4. 결과 반환

동기화한 각 스킬의 이름, 작업 유형(추가/삭제/수정/스킵), 대상 경로 목록을 반환한다.
