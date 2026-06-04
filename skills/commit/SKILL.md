---
name: commit
description: >
  커밋할 때 반드시 이 스킬을 사용한다.
  '커밋해줘', '커밋 메시지 만들어줘', 'commit', '변경 내용 저장',
  '스테이지 올라간 것 커밋' 요청이 오면 이 스킬로 처리한다.
  변경 내용 분석 후 Conventional Commits 규칙의 커밋 메시지를 생성하고 실행.
allowed-tools: Read, Glob, Grep, Bash
---

# 스마트 커밋

이 스킬이 호출되면 `git diff --staged`와 `git status`로 변경 내용을 분석하고, 아래 규칙에 따라 커밋 메시지를 생성하여 사용자 확인 후 커밋하세요.

## 프로젝트 커밋 규칙

- description은 **한글**로 작성, **50자 이내**
- scope는 변경된 파일의 모듈·디렉토리명 기반으로 `git diff`에서 추론한다
- 프로젝트에 `CLAUDE.md`가 있으면 아키텍처 섹션의 모듈명을 우선 참조한다
- scope 추론이 불명확하면 사용자에게 확인한다
- body는 "무엇을"이 아닌 **"왜"** 중심으로 작성
- 여러 성격의 변경이 섞여 있으면 **분리 커밋 제안**

> 좋은/나쁜 예시: [examples/commit-messages.md](examples/commit-messages.md)
