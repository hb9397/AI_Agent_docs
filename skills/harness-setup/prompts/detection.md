# prompts/detection.md
# 역할: 실행 컨텍스트·프로젝트 유형·세팅 모드를 감지하는 규칙

---

## [실행 컨텍스트 감지]

현재 스킬이 어디서 실행되고 있는지 판정한다.

### 감지 순서

1. 현재 디렉토리에서 원본 하네스 레포 식별자를 찾는다:

```bash
# 원본 하네스 레포 식별: skills/ 디렉토리 + Harness_Engineering.md 공존 여부
ls skills/harness-setup/SKILL.md 2>/dev/null && (ls Docs/Harness_Engineering.md 2>/dev/null || ls Harness_Engineering.md 2>/dev/null)
```

2. 위 두 파일이 모두 존재하면 → **원본 하네스 레포 내부**. 부모 폴더(`..`)를 프로젝트 루트 후보로 설정.

3. 위 조건 불충족 시, `.claude/skills/` 또는 `.agents/skills/`에 스킬이 존재하는지 확인:

```bash
ls .claude/skills/*/SKILL.md 2>/dev/null || ls .agents/skills/*/SKILL.md 2>/dev/null
```

4. 스킬이 존재하면 → **이미 배포된 프로젝트**. 현재 위치를 프로젝트 루트로 설정.

5. 위 모두 불충족 → 사용자에게 프로젝트 루트 경로를 직접 질문.

### 원본 하네스 레포에서 실행 시 추가 확인

부모 폴더를 프로젝트 루트 후보로 잡은 뒤, 사용자에게 확인:

> "원본 하네스 레포(`{현재 폴더}`) 안에서 실행 중입니다.
> 상위 폴더 `{부모 경로}`를 프로젝트 루트로 사용하겠습니다. 맞습니까?
> 다른 경로라면 알려주세요."

---

## [프로젝트 유형 감지]

프로젝트 루트 확정 후, 단일/복수 애플리케이션 여부를 판정한다.

### 감지 기준

**단일 애플리케이션 시그널** — 프로젝트 루트 자체가 앱 루트:
- 루트에 빌드/의존성 매니페스트가 있음: `package.json`, `pom.xml`, `build.gradle`, `go.mod`, `requirements.txt`, `Cargo.toml`, `*.sln`, `*.csproj`, `Gemfile`, `pyproject.toml`, `composer.json`
- 루트에 소스 디렉토리가 있음: `src/`, `app/`, `lib/`, `cmd/`
- 루트에 엔트리포인트가 있음: `main.*`, `index.*`, `App.*`

**복수 애플리케이션 시그널** — 프로젝트 루트 아래에 여러 앱 루트가 존재:
- 하위 디렉토리 각각이 위 매니페스트를 보유
- 하위 디렉토리 각각이 독립 `.git/`을 보유
- 프로젝트 루트 자체에는 매니페스트가 없음 (또는 하네스 레포/`.docs` 등 인프라만 있음)

### 감지 절차

```bash
# 1. 프로젝트 루트에 매니페스트가 있는지 확인
ls package.json pom.xml build.gradle go.mod requirements.txt Cargo.toml *.sln *.csproj Gemfile pyproject.toml composer.json 2>/dev/null

# 2. 하위 1 depth 폴더에서 매니페스트 보유 디렉토리 탐색
for d in */; do
  [ -d "$d" ] || continue
  case "$d" in
    .docs/|.claude/|.agents/|node_modules/|.git/|*-AI-Harness-docs/) continue ;;
  esac
  manifests=$(ls "${d}package.json" "${d}pom.xml" "${d}build.gradle" "${d}go.mod" "${d}requirements.txt" "${d}Cargo.toml" "${d}Gemfile" "${d}pyproject.toml" "${d}composer.json" 2>/dev/null | head -1)
  gitdir=$(ls -d "${d}.git" 2>/dev/null)
  if [ -n "$manifests" ] || [ -n "$gitdir" ]; then
    echo "APP_CANDIDATE: $d (manifest: $manifests, git: $gitdir)"
  fi
done

# 3. 하네스 레포 디렉토리 탐색 (제외 대상)
ls -d *-AI-Harness-docs/ AI_Agent_docs/ 2>/dev/null
```

### 판정 규칙

| 루트 매니페스트 | 하위 앱 후보 | 판정 |
|----------------|-------------|------|
| 있음 | 0~1개 | **단일 애플리케이션** |
| 없음 | 2개 이상 | **복수 애플리케이션** |
| 있음 | 2개 이상 | 사용자에게 확인 — 모노레포일 수 있음 |
| 없음 | 0~1개 | 사용자에게 직접 질문 |

> 어떤 경우든 **판정 결과를 사용자에게 반드시 보여주고 승인받는다**.

---

## [세팅 모드 판별]

프로젝트 루트(확정)에서 기존 하네스 흔적을 탐색한다.

```bash
# 기존 스킬 존재 여부
ls .claude/skills/*/SKILL.md 2>/dev/null | head -5
ls .agents/skills/*/SKILL.md 2>/dev/null | head -5

# 기존 .docs 구조 존재 여부
ls -d .docs/ 2>/dev/null
ls .docs/*.md .docs/*-context.md .docs/root-context/ 2>/dev/null | head -10
```

| 조건 | 모드 |
|------|------|
| `.claude/skills/` 또는 `.agents/skills/`에 SKILL.md가 1개 이상 존재 | **갱신 모드** |
| 위 조건 불충족 | **초기 세팅 모드** |

> `.docs/`만 있고 스킬이 없는 경우: 다른 경로로 `.docs`가 먼저 만들어졌을 수 있으므로 **초기 세팅**으로 분류하되, `.docs/`는 덮어쓰지 않고 병합한다.
