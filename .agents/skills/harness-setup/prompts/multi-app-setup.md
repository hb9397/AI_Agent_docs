# prompts/multi-app-setup.md
# 역할: 복수 애플리케이션 프로젝트의 초기 세팅 절차

---

## 전제

- SKILL.md Step 2에서 **복수 애플리케이션** 확정, Step 3에서 **초기 세팅** 판정.
- 프로젝트 최상위 폴더는 사용자가 직접 만든 컨테이너이며 **`git init` 조차 하지 않는다.**
- 그 하위의 `.docs`(별도 git 레포), 각 애플리케이션(별도 git 레포), `{프로젝트명}-AI-Harness-docs`(별도 git 레포)만 각각 독립 git으로 관리된다.
- 프로젝트 최상위에 생성되는 `CLAUDE.md`/`AGENTS.md`/`.claude/*`/`.agents/*`는 **어떤 git에도 속하지 않으며** `harness-setup`이 단독 관리한다.

---

## 1. 하네스 정본 레포 위치 확인

```bash
# 프로젝트 루트 내부 또는 동일 레벨에서 하네스 정본 레포 탐색
ls ./AI_Agent_docs/skills/harness-setup/SKILL.md 2>/dev/null \
  || ls ./*-AI-Harness-docs/skills/harness-setup/SKILL.md 2>/dev/null
```

정본 레포를 찾지 못한 경우 사용자에게 경로를 질문한다.

정본 레포 경로를 `$HARNESS_SRC`로 둔다.

---

## 2. 프로젝트 최상위에 스킬 디렉토리 생성

```bash
mkdir -p .claude/skills
mkdir -p .agents/skills
```

> **주의**: 이 폴더들은 프로젝트 최상위에 생성되며, 어떤 git 레포에도 속하지 않는다.
> `git init`은 절대 수행하지 않는다.

---

## 3. 스킬 복사

단일 앱 세팅과 동일한 방식으로 정본 레포의 `skills/` 전체를 복사한다.

```bash
for skill_dir in "$HARNESS_SRC"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  cp -r "$skill_dir" ".claude/skills/$skill_name"
  cp -r "$skill_dir" ".agents/skills/$skill_name"
done
```

### 복사 제외

- `evals/` 디렉토리
- 정본 레포 자체 설정 파일

---

## 4. `.docs/` 구조 생성

`.docs/`는 **별도 git 레포로 형상관리**되는 프로젝트 전체 AI 문서 저장소다.

### 4-1. 기본 구조

```bash
mkdir -p .docs/root-context
```

### 4-2. 애플리케이션별 하위 구조

Step 2에서 확인된 각 앱 폴더에 대해:

```bash
# {앱} = Step 2에서 확인된 앱 디렉토리명 (예: fe-keai-portal, be-keai-portal)
for app in {앱1} {앱2} {앱3}; do
  # 앱별 컨텍스트 파일 (비어 있는 상태로 생성)
  touch ".docs/${app}-context.md"

  # 앱별 instruction 디렉토리
  mkdir -p ".docs/${app}/instruction"

  # 앱별 impl-doc 디렉토리
  mkdir -p ".docs/${app}/impl-doc"
done
```

### 4-3. prototype 디렉토리

```bash
mkdir -p .docs/prototype
```

### 4-4. `.docs/` git 초기화 안내

`.docs/`를 별도 git 레포로 관리하는 것은 **사용자의 선택**이다.
생성 후 아래를 안내한다:

> `.docs/` 디렉토리가 생성되었습니다.
> 이 폴더를 별도 git 레포로 관리하시려면:
> ```bash
> cd .docs && git init && git add -A && git commit -m "init: 프로젝트 AI 문서 저장소"
> ```
> GitHub/GitLab/Gitea에 push하면 팀 전체가 공유할 수 있습니다.

---

## 5. 루트 `CLAUDE.md`/`AGENTS.md` 생성

프로젝트 최상위에 **통합 인덱스 역할**의 컨텍스트 파일을 생성한다.
이 파일들은 **어떤 git에도 속하지 않으며**, `harness-setup`이 단독 관리한다.

`templates/root-context.template`을 참조하여 생성한다.

### 생성 시 변수 치환

| 변수 | 값 |
|------|-----|
| `{{PROJECT_NAME}}` | 프로젝트 최상위 폴더명 |
| `{{APP_LIST}}` | Step 2에서 확인된 앱 폴더 목록 |
| `{{APP_CONTEXT_ENTRIES}}` | 앱별 `.docs/{앱}-context.md` 참조 목록 |
| `{{APP_INSTRUCTION_ENTRIES}}` | 앱별 `.docs/{앱}/instruction/` 참조 목록 |

### `.docs/root-context/`에 복사본 보관

```bash
cp CLAUDE.md .docs/root-context/CLAUDE.md
cp AGENTS.md .docs/root-context/AGENTS.md
```

> **원칙**: 다른 스킬(context-doc 등)이 `.docs/` 내부의 앱별 컨텍스트를 변경해도,
> 프로젝트 최상위 `CLAUDE.md`/`AGENTS.md`는 **이 스킬(harness-setup) 재실행**으로만 갱신한다.
> `.docs/root-context/`의 복사본이 갱신 시 원본 역할을 한다.

---

## 6. 결과 정리

생성된 구조를 출력용으로 정리한다:

```
{프로젝트 최상위 폴더}/          ← git 관리 안 함 (사용자 직접 생성 컨테이너)
├── CLAUDE.md                    ← harness-setup 단독 관리 (git 미소속)
├── AGENTS.md                    ← harness-setup 단독 관리 (git 미소속)
├── .claude/skills/...           ← git 미소속
├── .agents/skills/...           ← git 미소속
├── .docs/                       ← 별도 git 레포 (팀 공유용)
│   ├── root-context/
│   │   ├── CLAUDE.md            ← 루트 컨텍스트 복사본 (원본 역할)
│   │   └── AGENTS.md
│   ├── {앱1}-context.md
│   ├── {앱1}/
│   │   ├── instruction/
│   │   └── impl-doc/
│   ├── {앱2}-context.md
│   ├── {앱2}/
│   │   ├── instruction/
│   │   └── impl-doc/
│   └── prototype/
├── {앱1 폴더}/                  ← 별도 git 레포
├── {앱2 폴더}/                  ← 별도 git 레포
└── {프로젝트명}-AI-Harness-docs/ ← 별도 git 레포 (하네스 정본)
```

> 📌 복수 애플리케이션 프로젝트에서는:
> - 프로젝트 최상위 폴더에는 `git init`을 하지 않는다.
> - `.docs`, 각 애플리케이션, 하네스 레포가 **각각 독립 git 레포**로 관리된다.
> - 루트 `CLAUDE.md`/`AGENTS.md`는 어떤 git에도 속하지 않으며 harness-setup이 단독 관리한다.
> - `.docs/root-context/`에 복사본을 두어 갱신 시 원본으로 활용한다.
> - `.claude/skills/`와 `.agents/skills/`를 통해 어떤 AI 플랫폼에서든 동일 하네스를 사용할 수 있다.
