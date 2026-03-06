# templates/SKILL-template.md
# 역할: 생성할 스킬의 SKILL.md 초안 양식
# 사용법: 이 파일을 복사해 내용을 채운다. 주석 줄은 최종본에서 제거한다.

---
name: 
<!-- kebab-case. 예: code-reviewer, doc-syncer -->
description: ""
<!-- 트리거 키워드 3개 이상 포함. "~할 때", "~을 요청할 때" 형식 -->
allowed-tools: Read
<!-- 실제 사용 도구만: Read, Write, Glob, Grep, Bash, WebSearch -->
<!-- agent: fork        ← sub-agent 필요 시에만 주석 해제 -->
<!-- disable-model-invocation: true  ← 재귀 호출 방지 필요 시에만 -->
---

<!-- 연계 스킬이 있을 때만 아래 블록 포함 -->
<!--
## 스킬 연계

upstream-skill
    ↓
{skill-name}
    ↓
downstream-skill

| 업스트림 OUTPUT 섹션 | 이 스킬에서의 사용 위치 |
|---------------------|------------------------|
|                     |                         |
-->

# {Skill Title}

{한 줄 소개 — 이 스킬이 무엇을 하는가}

---

<!-- 진입 분기가 2개 이상일 때만 포함 -->
<!--
## 진입 분기

| 상황 | 이동할 Step |
|------|------------|
| [상황 A] | Step 1 → 2 → 3 |
| [상황 B] | Step 2 → 3 |
-->

---

## Step 1 — {단계명}

{이 Step에서 무엇을 하는지 한 줄}
세부 규칙은 `prompts/{파일명}.md`의 [{섹션명}] 섹션을 참조한다.

<!-- Bash가 필요한 경우 -->
<!--
```bash
ls {target-files} 2>/dev/null
```
-->

---

## Step 2 — {단계명}

{이 Step에서 무엇을 하는지 한 줄}
세부 규칙은 `prompts/{파일명}.md`의 [{섹션명}] 섹션을 참조한다.

<!-- 사용자 확인 게이트 -->
> ✋ **확인 게이트**
> "{확인 메시지} (승인 / 수정 / 취소)"
> **승인 전 파일을 절대 수정하지 않는다.**

---

## Step 3 — {단계명} (승인 후에만 실행)

{파일 생성·수정 단계}
세부 규칙은 `prompts/{파일명}.md`의 [{섹션명}] 섹션을 참조한다.

결과는 대화창에 바로 출력한다. (.md 파일 생성 금지 — 사용자 요청 시에만 저장)
