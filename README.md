# AI Agent Forms & Skills

이 레포지토리는 AI 에이전트 환경(Gemini CLI, Claude Code, Gemini GEMS 등)에서 활용할 수 있는 문서 템플릿 및 자동화 스킬들을 포함하고 있습니다.

## 📂 디렉토리 구조 및 요약

### 1. `Docs Skills/` (문서 도출 템플릿)

프로젝트 설계 및 구현 과정에서 AI 에이전트와 소통하기 위한 문서 양식 및 가이드라인입니다.

- **`Docs Skills/설계문서_도출/`**: 아이디어 구상부터 상세 설계까지, 스케일별(프로젝트/화면/기능) INPUT/OUTPUT 템플릿을 제공합니다.
- **`Docs Skills/구현작업_지시서_도출/`**: 설계 문서를 바탕으로 FE/BE 페어 기능 단위의 상세 작업 지침서를 도출하는 방법론과 템플릿입니다.
- **`Docs Skills/스킬_도출/`**: AI Agent용 Skill을 설계하고 구조화할 때 준수해야 할 원칙과 체크리스트를 포함합니다.

### 2. `Agent Skills/` (AI Agent 전용 스킬)

AI 에이전트가 코드를 분석하거나 자동화된 작업을 수행하기 위한 전문화된 스킬들입니다.

- **`Agent Skills/agent-sync/`**: 프로젝트 내 여러 에이전트 경로(CLAUDE.md, Skills 등)를 감지하고 동기화합니다.
- **`Agent Skills/code-comment/`**: 변경된 코드를 분석하여 스타일 가이드에 맞는 한글 주석을 자동으로 작성하고 갱신합니다.
- **`Agent Skills/commit/`**: 변경 사항을 분석하여 Conventional Commits 규격에 맞는 커밋 메시지를 생성하고 커밋을 수행합니다.
- **`Agent Skills/context-doc/`**: 설계 문서를 분석하여 CLAUDE.md 및 아키텍처 제약 지침(basic-instruction.md)을 자동 생성합니다.
- **`Agent Skills/design-doc/`**: 사용자 인터뷰를 통해 페르소나별 요구사항을 파악하고 정밀한 설계 문서를 도출합니다.
- **`Agent Skills/doc-audit/`**: 실제 코드와 문서 간의 괴리를 분석하여 라이브러리, 패턴, 규칙 불일치를 탐지하고 업데이트를 제안합니다.
- **`Agent Skills/frontend-design/`**: 범용적인 디자인을 탈피하여 독창적이고 완성도 높은 프론트엔드 인터페이스 제작을 가이드합니다.
- **`Agent Skills/impl-doc/`**: 설계 문서를 기반으로 FE/BE 페어 작업 순서와 검증 시나리오를 포함한 구현 명세서를 생성합니다.
- **`Agent Skills/multi-review/`**: 보안, 성능, 유지보수성, 테스트 관점의 멀티 페르소나 전문가 그룹 코드 리뷰를 수행합니다.
- **`Agent Skills/pre-commit/`**: 커밋 전 에러 처리, 민감 정보 노출, 타임아웃 설정 등 프로젝트 핵심 규칙 준수 여부를 스캔합니다.
- **`Agent Skills/skill-design/`**: 새로운 에이전트 스킬을 인터뷰부터 설계, 생성, 테스트 및 최적화까지 통합 관리합니다.
