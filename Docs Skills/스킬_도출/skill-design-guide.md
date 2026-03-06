# AI Agent Skill 설계 지침서

> AI Agent용 Skill을 새로 만들거나 기존 Skill을 고도화할 때 반드시 준수해야 할 원칙과 체크리스트.
> 이 문서 자체도 이 원칙에 따라 작성되었다.

---

## 1. 구조 원칙

### 1-1. 디렉토리 구조

```
skill-name/
├── SKILL.md          # 필수 — 워크플로우 오케스트레이터
├── prompts/          # 선택 — 상세 지침 파일들
├── templates/        # 선택 — 출력 양식 파일들
└── [기타 디렉토리]/  # 선택 — scripts/, examples/ 등
```

### 1-2. SKILL.md 역할 경계

SKILL.md는 **흐름(What & When)만** 담는다. 상세 규칙(How)은 prompts 파일에.

```
SKILL.md 에 넣을 것:
  - 스킬 헤더 (name, description, allowed-tools, agent)
  - 워크플로우 Step 목록
  - 각 Step에서 어느 prompts 파일을 참조할지
  - 사용자 확인 게이트 위치

SKILL.md 에 넣지 말 것:
  - prompts 파일 내용의 요약 반복 → 이중 명세 발생
  - 예시 데이터 / 샘플 코드
  - 다른 prompts 파일에 이미 있는 규칙
```

### 1-3. prompts 파일 단일 책임

파일 하나는 역할 하나. 두 가지 이상의 역할이 섞이면 분리한다.

```
❌ analysis.md 에 CLAUDE.md 추출 항목 + basic-instruction.md 추출 항목 혼재
✅ analysis-claude.md / analysis-instruction.md 로 분리
   → Agent가 필요한 파일만 읽을 수 있다
```

---

## 2. 토큰 절감 원칙

### 2-1. 조건부 파일 로드

Agent가 모든 prompts 파일을 항상 읽지 않도록 SKILL.md에서 조건을 명시한다.

```markdown
# 좋은 예 — 조건 명시
Step 2에서 감지된 언어에 해당하는 섹션만 `prompts/style-guide.md`에서 참조한다.

# 나쁜 예 — 무조건 전체 로드
`prompts/style-guide.md`를 참조하여 주석을 작성한다.
```

체크리스트나 분기가 있는 파일은 **파일 상단에 스케일/조건별 실행 섹션 라우팅 표**를 둔다.

```markdown
| 조건 | 읽을 섹션 |
|------|----------|
| 스케일: 프로젝트 전체 | 전체 |
| 스케일: 기능/화면 | ## 기술적 함정 + ## 구조적 함정 |
| 스케일: 컴포넌트 | ## 구조적 함정만 |
```

### 2-2. 템플릿 예시 데이터 금지

템플릿 파일에 실제처럼 보이는 예시 데이터를 넣지 않는다.
Agent가 템플릿 예시와 실제 프로젝트 데이터를 혼동하거나, 예시를 그대로 출력하는 오작동이 생긴다.

```markdown
# 나쁜 예 — 템플릿에 예시 데이터 포함
| 1 | be/CLAUDE.md | Django 3.x → Django 4.2 | requirements.txt 확인 |

# 좋은 예 — 구조만, 예시는 주석으로
| # | 대상 문서 | 현재 내용 | 제안 내용 | 이유 |
|---|-----------|-----------|-----------|------|
<!-- 예시: | 1 | be/CLAUDE.md | Django 3.x | Django 4.2 | requirements.txt 확인 | -->
```

### 2-3. 중복 명세 금지

동일한 내용이 두 곳 이상에 있으면 하나만 남기고 나머지는 참조로 대체한다.

```markdown
# 나쁜 예
SKILL.md Step 3:
  | 위치 | 형식 | 내용 |   ← 이미 comment-rules.md에 있는 내용 반복
  |------|------|------|

# 좋은 예
SKILL.md Step 3:
  작성 규칙은 `prompts/comment-rules.md` 참조.  ← 참조만
```

### 2-4. 사용자 질문 최소화

한 번에 묻는 질문은 최대 3개. 분석 후 **우선순위 높은 것만** 선별해서 묻는다.
질문 우선순위는 prompts 파일에 명시한다 (SKILL.md에 반복 금지).

```markdown
# prompts/analysis.md 에서 정의
🔴 필수 확인 (최대 2개):
  1. 환경 분리 여부 (개발/배포 동작 차이)
  2. 미결 항목 존재 여부

🟡 선택 확인 (필수 확인 후 여유 있을 때):
  3. 기존 코드베이스 여부
```

### 2-5. 결과 파일 생성 금지 원칙

별도 .md 파일 생성은 사용자가 명시적으로 요청할 때만.
기본은 대화창 출력. 파일 생성이 기본이면 불필요한 Write 토큰 소모.

```markdown
# SKILL.md 에 명시
결과는 대화창에 바로 출력한다. (.md 파일 생성 금지 — 사용자 요청 시에만 저장)
```

---

## 3. 응답 속도 원칙

### 3-1. Bash 명령 최소화 & 조건부 실행

감지 먼저, 실행은 조건부로.

```bash
# 나쁜 예 — 언어와 무관하게 전부 실행
cat requirements.txt 2>/dev/null
cat package.json 2>/dev/null
cat pom.xml 2>/dev/null
cat go.mod 2>/dev/null
cat Cargo.toml 2>/dev/null

# 좋은 예 — 존재 파일 먼저 감지, 해당하는 것만 실행
ls requirements.txt package.json pom.xml go.mod Cargo.toml 2>/dev/null
# → 감지된 파일에 해당하는 블록만 실행
```

### 3-2. 대용량 명령 제한

파일 전체를 읽는 명령에는 반드시 범위를 제한한다.

```bash
# 나쁜 예
cat package-lock.json          # 수만 줄
git diff HEAD~5..HEAD          # 무제한
cat settings.py | xargs cat    # 파일 경계 소실

# 좋은 예
cat package.json | grep -E '"dependencies"|"devDependencies"' -A 30
git diff --stat HEAD~5..HEAD   # stat 먼저, 필요한 파일만 선택적으로 diff
find . -name "settings*.py" ! -path "*/node_modules/*" | head -5
# → 파일명 목록만 먼저 확인 후 선택적 Read
```

### 3-3. Fallback 스캔 금지

변경 대상이 없을 때 전체 프로젝트를 스캔하는 fallback을 두지 않는다.

```bash
# 나쁜 예
CHANGED=$(git diff --name-only HEAD 2>/dev/null)
if [ -z "$CHANGED" ]; then
  grep -rn $CODE "..." "$TARGET"  # 전체 스캔 fallback
fi

# 좋은 예
CHANGED=$(git diff --name-only HEAD 2>/dev/null)
if [ -z "$CHANGED" ]; then
  echo "검사할 변경 파일 없음 — 종료"
  exit 0
fi
```

### 3-4. git 명령 최적화

목적에 맞는 최소 명령만 사용한다.

```bash
# 나쁜 예 — 로그 20줄을 스킬 변경 파악에 사용
git log --oneline --diff-filter=ACMRD -- "*/skills/**" | head -20

# 좋은 예 — 변경 파일 목록만
git diff --name-only HEAD -- "*/skills/**"
```

---

## 4. 병렬 처리 원칙

### 4-1. 병렬 처리가 적합한 경우

독립적이고 결과가 서로 영향을 주지 않는 작업에만 적용한다.

```
적합한 경우:
  - 4개 관점(Security, Performance, Maintainability, Testing)의 코드 리뷰
  - FE 문서 동기화 + BE 문서 동기화 (서로 다른 디렉토리)
  - 서로 다른 언어 파일의 독립적 분석

부적합한 경우:
  - 선행 작업 결과가 필요한 작업 (Phase 1 완료 후 Phase 2)
  - 동일 파일을 동시에 수정하는 작업
  - 결과를 즉시 취합해야 하는 단순 작업 (순차가 오히려 빠름)
```

### 4-2. 병렬 Task 수 제한

sub-agent Task는 목적이 명확히 다른 경우에만 분기한다.
관점이 2개 이하면 순차 실행이 낫다. Task 생성 자체에도 토큰이 든다.

```markdown
# 기준
2개 이하 관점 → 순차 실행
3~6개 독립 관점 → 병렬 Task
7개 이상 → 재설계 (관점이 너무 많으면 구조 문제)
```

### 4-3. 병렬 처리 명시 방법

SKILL.md에서 병렬 구조를 명확하게 표현한다.

```markdown
아래 3개 관점을 Task로 병렬 실행한다.
sub-agent를 지원하지 않는 환경이면 순차로 직접 수행한다.

├── Task A: [관점명] → `prompts/a.md` 참조
├── Task B: [관점명] → `prompts/b.md` 참조
└── Task C: [관점명] → `prompts/c.md` 참조
```

---

## 5. 사용자 확인 게이트 원칙

### 5-1. 파일 수정 전 반드시 확인

파일을 생성하거나 수정하는 스킬은 반드시 미리보기 → 승인 → 실행 순서를 따른다.

```markdown
# SKILL.md 에 명시
승인 전 파일을 절대 수정하지 않는다.

Step N — 미리보기 및 사용자 확인
결과를 대화창에 출력하고 승인을 요청한다.
> "위 내용으로 파일을 저장할까요? (승인 / 수정 요청 / 취소)"

Step N+1 — 파일 저장 (승인 후에만 실행)
```

### 5-2. 수정 범위 최소화

수정 요청 시 전체 재작성이 아니라 해당 섹션/태스크만 재작성한다.

---

## 6. 스킬 간 연계 원칙

### 6-1. 연계 구조는 SKILL.md 상단에 명시

다운스트림 또는 업스트림 스킬이 있으면 SKILL.md 상단에 흐름을 표시한다.

```markdown
## 스킬 연계

upstream-skill OUTPUT
    ↓ (이 스킬의 입력)
this-skill
    ↓
downstream-skill 의 입력으로 사용 가능
```

### 6-2. 섹션 매핑 표

연계 스킬의 OUTPUT 섹션이 이 스킬의 어느 부분에 매핑되는지 표로 명시한다.
Agent가 연결 방법을 추론하지 않아도 된다.

```markdown
| 업스트림 OUTPUT 섹션 | 이 스킬에서의 사용 위치 |
|---------------------|------------------------|
| 01 개요             | CLAUDE.md — 프로젝트 맥락 |
| 10 주의사항         | basic-instruction.md — 금지 목록 |
```

---

## 7. 헤더 작성 원칙

모든 SKILL.md는 아래 헤더로 시작한다.

```yaml
---
name: skill-name
description: "한 줄 설명 — 언제 이 스킬을 호출하는지 명확하게"
allowed-tools: Read, Glob, Grep, Bash, Write  # 실제 필요한 것만
agent: fork       # sub-agent 지원 환경용. 단일 실행이면 생략
disable-model-invocation: true  # 재귀 호출 방지가 필요한 경우에만
---
```

`allowed-tools` 는 스킬이 실제로 사용하는 도구만 선언한다.
불필요한 도구를 선언하면 Agent가 과도한 권한으로 동작할 수 있다.

---

## 8. 체크리스트 — 스킬 완성 전 자체 점검

스킬을 완성했다고 판단하기 전에 아래를 점검한다.

### 구조
```
[ ] SKILL.md는 흐름만 담고 있는가? (규칙 요약 표 반복 없음)
[ ] prompts 파일이 단일 책임을 갖는가? (두 역할이 한 파일에 혼재하지 않음)
[ ] 연계 스킬이 있으면 SKILL.md 상단에 명시했는가?
```

### 토큰
```
[ ] 템플릿에 예시 데이터가 없는가?
[ ] SKILL.md와 prompts 파일 사이에 중복 내용이 없는가?
[ ] 조건부 파일 로드가 필요한 곳에 라우팅 표가 있는가?
[ ] 사용자 질문이 한 번에 3개 이하인가?
```

### 속도
```
[ ] Bash 명령이 조건부로 실행되는가? (감지 먼저, 실행은 해당 언어만)
[ ] 대용량 명령에 범위 제한이 있는가? (head -N, grep 필터 등)
[ ] 변경 없을 때 전체 스캔 fallback이 없는가?
[ ] git 명령이 목적에 맞는 최소 명령인가?
```

### 병렬 처리
```
[ ] 병렬 Task가 실제로 독립적인가? (선행 결과 의존 없음)
[ ] Task 수가 6개 이하인가?
[ ] 순차가 더 나은 경우에 병렬을 쓰고 있지 않은가?
[ ] sub-agent 미지원 환경의 순차 fallback이 명시되어 있는가?
```

### 안전성
```
[ ] 파일 수정 전 사용자 확인 게이트가 있는가?
[ ] 기본 동작이 "대화창 출력"이고 파일 저장은 요청 시에만인가?
[ ] disable-model-invocation이 필요한 경우 선언되어 있는가?
```

---

## 9. 안티패턴 요약

자주 발생하는 설계 실수와 해결 방법.

| 안티패턴 | 증상 | 해결 |
|----------|------|------|
| 이중 명세 | SKILL.md와 prompts에 동일 내용 | SKILL.md는 참조만, 내용은 prompts에 |
| 전수 실행 | 언어 무관하게 모든 감지 명령 실행 | 감지 먼저 → 해당 언어 블록만 실행 |
| 예시 데이터 혼입 | 템플릿에 Django, Zustand 등 실제처럼 보이는 값 | 빈 구조 + HTML 주석으로 대체 |
| Fallback 전체 스캔 | 변경 없으면 프로젝트 전체 grep | 변경 없으면 즉시 종료 |
| 과도한 병렬화 | 2개 관점도 Task로 분기 | 3개 미만은 순차 실행 |
| 질문 남발 | 한 번에 5개 이상 질문 | 우선순위 기준으로 최대 3개만 |
| 무조건 파일 생성 | 결과를 항상 .md로 저장 | 기본은 대화창 출력, 저장은 요청 시 |
| 단일 파일 다중 책임 | analysis.md에 두 문서의 추출 항목 혼재 | 목적별로 파일 분리 |
| git log 과다 | 스킬 변경 파악에 log 20줄 사용 | `git diff --name-only`로 대체 |
| lock 파일 파싱 | package-lock.json 전체 읽기 | package.json dependencies만 참조 |
