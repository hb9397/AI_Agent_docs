# prompts/single-app-setup.md
# 역할: 단일 애플리케이션 프로젝트의 초기 세팅 절차

---

## 전제

- SKILL.md Step 2에서 **단일 애플리케이션** 확정, Step 3에서 **초기 세팅** 판정.
- 프로젝트 루트 = 애플리케이션 루트 (같은 폴더).
- 이 프로젝트는 단일 git 레포로 관리되며, 스킬·컨텍스트·산출물이 모두 이 레포 안에서 형상관리된다.

---

## 1. 원본 하네스 레포 위치 확인

```bash
# 동일 상위 폴더 또는 하위 폴더에서 원본 하네스 레포 탐색
ls ../ai-agent-harness-docs/skills/harness-setup/SKILL.md 2>/dev/null \
  || ls ../*-ai-harness-docs/skills/harness-setup/SKILL.md 2>/dev/null \
  || ls ./ai-agent-harness-docs/skills/harness-setup/SKILL.md 2>/dev/null \
  || ls ./*-ai-harness-docs/skills/harness-setup/SKILL.md 2>/dev/null
```

원본 하네스 레포를 찾지 못한 경우 사용자에게 경로를 질문한다.

원본 하네스 레포 경로를 `$HARNESS_SRC`로 둔다.

---

## 2. 스킬 디렉토리 생성

```bash
mkdir -p .claude/skills
mkdir -p .agents/skills
```

> 이미 존재하면 아무 작업도 하지 않는다.

---

## 3. 스킬 복사

원본 하네스 레포의 `skills/` 하위 전체를 `.claude/skills/`와 `.agents/skills/`에 복사한다.

```bash
# 원본 하네스 레포의 모든 스킬 디렉토리를 순회
for skill_dir in "$HARNESS_SRC"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  # .claude/skills/ 에 복사
  cp -r "$skill_dir" ".claude/skills/$skill_name"
  # .agents/skills/ 에 복사
  cp -r "$skill_dir" ".agents/skills/$skill_name"
done
```

### 복사 대상에서 제외할 항목

- `evals/` 디렉토리 (테스트 전용, 배포 불필요)
- 원본 하네스 레포 자체 설정 파일 (`.git/`, `README.md`, `Harness_Engineering*.md` 등)

### 스킬별 하위 구조 유지

각 스킬의 `SKILL.md`, `prompts/`, `templates/` 구조를 그대로 복사한다.

---

## 4. 산출물 디렉토리 확인

`.docs/` 디렉토리가 없으면 생성한다:

```bash
mkdir -p .docs
```

> 단일 앱에서의 `.docs/` 산출물 경로 표준:
>
> | 스킬 | 경로 |
> |------|------|
> | design-doc | `.docs/context-base/DESIGN.md` |
> | context-doc | `.docs/instruction/*-instruction.md` |
> | impl-doc / impl-fe-be-doc | `.docs/impl-doc/{사용자}/{기능}.md` |
> | design-prototype-docs / create-prototype | `.docs/prototype/{사용자}/{id}/` |

---

## 4-1. `.docs/` 안내·정책 파일 생성

`.docs/`를 처음 만들 때 아래 3종을 함께 생성한다. 이미 있으면 README/.gitignore는 최신 템플릿으로 덮어쓰고, `_inbox/` 내용은 보존한다.

| 파일 | 원본 템플릿 | 역할 |
|------|------------|------|
| `.docs/README.md` | `templates/docs-readme-single.template` | `.docs/` 구조·산출물 종류·스킬별 산출 위치 안내 |
| `.docs/.gitignore` | `templates/docs-gitignore.template` | 로컬 전용(미추적) 영역 지정 |
| `.docs/_inbox/README.md` | `templates/inbox-readme.template` | `_inbox/` 용도 설명 |

```bash
# 안내 README (구조·산출물·스킬 매핑)
cp "$HARNESS_SRC/skills/harness-setup/templates/docs-readme-single.template" .docs/README.md

# 로컬 전용 영역 지정 .gitignore
cp "$HARNESS_SRC/skills/harness-setup/templates/docs-gitignore.template" .docs/.gitignore

# 에이전트 임시 입력 공간 _inbox (대표적 로컬 전용 영역)
mkdir -p .docs/_inbox
: > .docs/_inbox/.gitkeep
cp "$HARNESS_SRC/skills/harness-setup/templates/inbox-readme.template" .docs/_inbox/README.md
```

> **`_inbox/`의 의미**: 에이전트에게 읽힐 파일(스크린샷·로그·표 등)을 잠시 올려두는 공간이다.
> `.docs/.gitignore`가 `/_inbox/*`를 무시하므로 그 안의 파일은 git에 올라가지 않고, `.gitkeep`·`README.md`만 추적되어 폴더 구조만 공유된다.
> 단일 앱에서는 `.docs/`가 소스 레포에 포함되므로, 이 `.gitignore`가 해당 레포의 중첩 `.gitignore`로 동작한다.

---

## 5. 결과 정리

생성된 구조를 출력용으로 정리한다:

```
{애플리케이션 루트}/
├── .claude/
│   └── skills/
│       ├── harness-setup/
│       ├── design-doc/
│       ├── context-doc/
│       ├── ...
│       └── custom-skill-design/
├── .agents/
│   └── skills/
│       └── (동일 구조)
├── .docs/                  ← 산출물 저장소
│   ├── README.md           ← harness-setup 생성 (구조·산출물 안내)
│   ├── .gitignore          ← harness-setup 생성 (로컬 전용 영역 지정)
│   └── _inbox/             ← 에이전트 임시 입력 공간 (내용 git 미추적)
├── CLAUDE.md               ← context-doc이 생성/관리
├── AGENTS.md               ← context-doc이 생성/관리
└── (기존 소스코드)
```

> 📌 단일 애플리케이션에서는:
> - `CLAUDE.md`, `AGENTS.md`는 `context-doc` 스킬이 생성·관리한다 (이 스킬은 생성하지 않음).
> - `.docs/` 이하 산출물은 소스코드와 함께 동일 git 레포에서 형상관리한다.
> - `.claude/skills/`와 `.agents/skills/`에 동일 스킬을 배치하여 Claude Code, Codex 등 어떤 플랫폼에서든 사용 가능하다.
