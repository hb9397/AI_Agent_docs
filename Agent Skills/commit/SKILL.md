---
name: commit
description: "변경 분석 후 Conventional Commits 커밋"
allowed-tools: Read, Glob, Grep, Bash
disable-model-invocation: true
---

# 스마트 커밋

이 스킬이 호출되면 `git diff --staged`와 `git status`로 변경 내용을 분석하고, 아래 규칙에 따라 커밋 메시지를 생성하여 사용자 확인 후 커밋하세요.

## 프로젝트 커밋 규칙

- description은 **한글**로 작성, **50자 이내**
- scope는 모듈명 또는 도메인명 사용 (`api`, `domain`, `infra`, `member`, `auth` 등)
- body는 "무엇을"이 아닌 **"왜"** 중심으로 작성
- 여러 성격의 변경이 섞여 있으면 **분리 커밋 제안**

> 좋은/나쁜 예시: [examples/commit-messages.md](examples/commit-messages.md)
