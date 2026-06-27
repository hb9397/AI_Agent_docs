# prompts/update-mode.md
# 역할: 이미 세팅된 프로젝트에서 스킬·컨텍스트를 갱신하는 절차

---

## 전제

- SKILL.md Step 3에서 **갱신 모드**로 판정.
- `.claude/skills/` 또는 `.agents/skills/`에 기존 스킬이 존재.
- 프로젝트 유형(단일/복수)은 Step 2에서 확정.

---

## 1. 하네스 정본 레포 위치 확인

초기 세팅과 동일한 방법으로 정본 레포를 탐색한다.

```bash
# 프로젝트 내부 또는 동일 레벨
ls ./*-AI-Harness-docs/skills/harness-setup/SKILL.md 2>/dev/null \
  || ls ./AI_Agent_docs/skills/harness-setup/SKILL.md 2>/dev/null \
  || ls ../*-AI-Harness-docs/skills/harness-setup/SKILL.md 2>/dev/null \
  || ls ../AI_Agent_docs/skills/harness-setup/SKILL.md 2>/dev/null
```

정본 레포를 찾지 못한 경우 사용자에게 경로를 질문한다.

---

## 2. 스킬 변경 비교

정본 레포의 `skills/`와 배포된 `.claude/skills/`를 비교한다.

### 비교 방법

`.claude/skills/`를 기준으로 비교한다 (`.agents/skills/`는 `.claude/skills/`와 동일하게 갱신).

```bash
# 정본 레포 스킬 목록
ls -d "$HARNESS_SRC"/skills/*/

# 배포된 스킬 목록
ls -d .claude/skills/*/
```

### 변경 유형 분류

| 유형 | 조건 | 처리 |
|------|------|------|
| **추가** | 정본에 있고 배포에 없음 | `.claude/skills/`와 `.agents/skills/`에 복사 |
| **수정** | 양쪽 모두 존재하나 내용 불일치 | 배포 측 덮어쓰기 |
| **삭제** | 정본에서 사라지고 배포에만 있음 | 사용자에게 삭제 여부 확인 후 처리 |
| **변경 없음** | 내용 동일 | 스킵 |

### 내용 비교 방법

```bash
# SKILL.md 파일 내용 비교 (MD5 우선, 불가 시 줄 단위)
md5sum "$HARNESS_SRC/skills/$skill/SKILL.md" 2>/dev/null
md5sum ".claude/skills/$skill/SKILL.md" 2>/dev/null
```

> MD5 명령이 실패하면 Read 도구로 양쪽 파일을 읽어 줄 단위 비교한다.
> SKILL.md 외에 prompts/, templates/ 하위 파일도 모두 비교한다.

---

## 3. 갱신 계획 사용자 확인

비교 결과를 요약하여 사용자에게 확인받는다:

> ✋ **갱신 대상 확인**
>
> | 유형 | 스킬 |
> |------|------|
> | 추가 | `{스킬1}`, `{스킬2}` |
> | 수정 | `{스킬3}`, `{스킬4}` |
> | 삭제 후보 | `{스킬5}` (정본에서 제거됨) |
> | 변경 없음 | N개 스킵 |
>
> 진행하시겠습니까? **(승인 / 수정 / 취소)**

---

## 4. 스킬 갱신 실행

승인 후 실행:

```bash
# 추가·수정: 정본 → 배포 복사
cp -r "$HARNESS_SRC/skills/$skill" ".claude/skills/$skill"
cp -r "$HARNESS_SRC/skills/$skill" ".agents/skills/$skill"

# 삭제 (사용자 승인 시): 배포에서만 제거
rm -rf ".claude/skills/$skill"
rm -rf ".agents/skills/$skill"
```

---

## 5. 복수 애플리케이션 추가 갱신

프로젝트가 **복수 애플리케이션**인 경우에만 수행.

### 5-1. 루트 컨텍스트 갱신

`.docs/root-context/CLAUDE.md`, `.docs/root-context/AGENTS.md`를 다시 읽어와 루트에 반영한다.

```bash
# .docs/root-context/가 원본. 루트 파일을 갱신.
cp .docs/root-context/CLAUDE.md ./CLAUDE.md
cp .docs/root-context/AGENTS.md ./AGENTS.md
```

> 만약 `.docs/root-context/` 파일이 존재하지 않으면 (다른 스킬에 의해 아직 안 만들어졌거나 삭제된 경우),
> 갱신하지 않고 사용자에게 알린다.

### 5-2. 신규 애플리케이션 감지

Step 2 감지 결과에서 `.docs/{앱}-context.md`가 없는 새 앱 폴더가 발견되면:

```bash
touch ".docs/${new_app}-context.md"
mkdir -p ".docs/${new_app}/instruction"
mkdir -p ".docs/${new_app}/impl-doc"
```

사용자에게 신규 앱 추가 사실을 알린다.

---

## 6. 결과 정리

갱신 결과를 요약한다:

```
## 갱신 결과

- 스킬: 추가 N개 / 수정 N개 / 삭제 N개 / 변경 없음 N개
- (복수앱) 루트 컨텍스트: 갱신됨 / 변경 없음
- (복수앱) 신규 앱 감지: {앱명} (구조 추가됨)
```
