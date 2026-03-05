# AI Agent Forms & Skills

이 레포지토리는 AI 에이전트 환경(Gemini GEMS, Claude Code Web 등)에서 활용할 수 있는 문서 템플릿 및 자동화 스킬들을 포함하고 있습니다.

## 📂 디렉토리 구조 및 요약

### 1. `Docs Skills/` (문서 도출 템플릿)

프로젝트 설계 및 구현 과정에서 AI 에이전트와 소통하기 위한 문서 양식들이 포함되어 있습니다.

- **`Docs Skills/설계문서_도출/`**: 설계문서 도출을 위한 템플릿. 버전별로 INPUT/OUTPUT 문서 포맷을 정의하여 상세 설계 문서를 도출합니다.
- **`Docs Skills/구현작업_지시서_도출/`**: 도출된 설계 문서를 바탕으로 실제 구현 작업을 지시하는 워크플로우 문서 및 템플릿입니다.

### 2. `Agent Skills/` (AI 에이전트 스킬)

에이전트가 코드를 분석하거나 자동화된 작업을 수행하기 위한 각종 스킬들이 포함되어 있습니다.

- **`Agent Skills/agent-sync/`**: 에이전트의 문서 및 스킬들을 동기화하는 스킬.
- **`Agent Skills/commit/`**: 커밋 메시지를 자동 생성 및 관리하는 스킬.
- **`Agent Skills/doc-audit/`**: 프로젝트 내 문서의 정합성과 요구사항 준수 여부를 감사(Audit)하는 스킬.
- **`Agent Skills/frontend-design/`**: 프론트엔드 디자인 관련 AI 안내 스킬.
- **`Agent Skills/multi-review/`**: 보안, 성능, 테스트, 유지보수성 등을 다각도로 코드 리뷰하는 스킬.
- **`Agent Skills/pre-commit/`**: 커밋 전 코드를 스캔하고 템플릿을 확인하는 스킬.

