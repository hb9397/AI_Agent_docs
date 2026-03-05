---
name: pre-commit
description: "커밋 전 규칙 위반 검사"
allowed-tools: Read, Glob, Grep, Bash
disable-model-invocation: true
agent: fork
---

# 프로젝트 룰 검사

이 스킬이 호출되면 변경된 파일을 대상으로 아래 검사를 즉시 실행하고, [template.md](template.md) 형식으로 결과를 보고하세요.

## 실행 방법

1. `git diff --name-only`로 변경된 파일 목록 수집 (staged + unstaged)
2. `bash scripts/scan.sh`로 패턴 일괄 검색
3. 스캔 결과 + 수동 분석으로 위반 사항 판정
4. template.md 형식으로 결과 보고

## 검사 항목

### 1. 에러 처리

- 빈 catch 블록 금지 (에러를 잡고 아무것도 안 하는 경우)
- 에러를 로깅 없이 무시하는 패턴 금지 (`// ignore`, 빈 catch)
- catch에서 에러 무시하고 `null`/`undefined`/빈 값 반환 금지

### 2. 외부 호출 타임아웃

- 외부 API/서비스 호출에 타임아웃 설정 필수
- 하드코딩된 타임아웃 값은 상수로 추출

### 3. 민감 정보

- 소스 코드에 하드코딩된 비밀번호, API 키, 토큰, 시크릿 금지
- `.env`, 설정 파일의 민감 값이 커밋에 포함되지 않는지 확인

### 4. TODO 주석

- 기한/담당 없는 TODO 금지
- 허용 형식: `// TODO(@담당, 날짜): 내용 - #이슈`
- 기한 없는 TODO는 처리하거나 이슈로 전환

### 5. 테스트 존재

- 비즈니스 로직 변경 시 대응 테스트 존재 여부 확인
- 새 public 함수/메서드 추가 시 테스트 필수
