# Gemini CLI Command 템플릿

이 디렉토리의 `.toml` 파일들은 gemini-cli 에서 Skills 를 커맨드로 호출하기 위한 설정 파일입니다.

## 파일 형식

```toml
description = ".agents/skills/<skill-name> 실행"
execute = ".agents/skills/<skill-name>"
prompt = ".agents/skills/<skill-name> 에 정의된 Skills 를 수행해줘"
```

## 파일명 규칙

- 파일명: `<skill-name>.toml`
- 위치: `.gemini/commands/<skill-name>.toml`

> agent-sync 스킬 실행 시 자동으로 이 디렉토리의 파일들이 갱신됩니다.
