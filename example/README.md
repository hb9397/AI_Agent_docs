# example — 스킬 산출물 예시 모음

각 스킬을 실행했을 때 생성되는 산출물의 형식을 보여주는 예시 문서다. 소재는 **ACRO(범용 예약 매크로)** 프로젝트로 통일했다. 파일명은 `{스킬명}--{주제}.md` 규칙을 따르며, 각 파일 상단에 생성 스킬과 산출 경로를 주석으로 명시한다.

| 파일 | 생성 스킬 | 대표 산출 경로 |
|------|-----------|----------------|
| [design-doc--ACRO.md](./design-doc--ACRO.md) | `design-doc` | `.docs/DESIGN.md` (단일 앱 전체 설계) |
| [design-doc--ACRO-BE.md](./design-doc--ACRO-BE.md) | `design-doc` | `.docs/acro-be-DESIGN.md` (복수 앱 BE) |
| [design-doc--ACRO-FE.md](./design-doc--ACRO-FE.md) | `design-doc` | `.docs/acro-fe-DESIGN.md` (복수 앱 FE) |
| [context-doc--CLAUDE.md](./context-doc--CLAUDE.md) | `context-doc` | 루트 `CLAUDE.md` |
| [context-doc--AGENTS.md](./context-doc--AGENTS.md) | `context-doc` | 루트 `AGENTS.md` (CLAUDE.md와 동일 내용) |
| [context-doc--architecture-instruction.md](./context-doc--architecture-instruction.md) | `context-doc` | `.docs/instruction/architecture-instruction.md` (7종 중 하나) |
| [impl-fe-be-doc--ACRO.md](./impl-fe-be-doc--ACRO.md) | `impl-fe-be-doc` | `.docs/impl-doc/{사용자}/acro.md` (FE/BE 페어 다중 기능) |
| [impl-doc--selector-recovery.md](./impl-doc--selector-recovery.md) | `impl-doc` | `.docs/impl-doc/{사용자}/selector-recovery.md` (단일 기능) |
| [design-prototype-docs--onboarding.md](./design-prototype-docs--onboarding.md) | `design-prototype-docs` | `.docs/prototype/{사용자}/onboarding/design-doc.md` |

> **파일을 만들지 않는 스킬**(`rfp-ingest`는 대화 컨텍스트 전달), **리포트형 스킬**(`impl-verify`·`multi-review`·`pre-commit`·`doc-audit`), **코드/커밋 적용 스킬**(`frontend-design`·`code-comment`·`commit`·`create-prototype`·`agent-sync`·`git-scoped-account`)은 문서 산출물이 아니므로 예시에서 제외했다. 전체 스킬 흐름은 [`Docs/Harness_Engineering.md`](../Docs/Harness_Engineering.md)를 참고.
