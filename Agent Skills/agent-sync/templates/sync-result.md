# Agent Sync 결과 보고서

동기화 완료 후 아래 형식으로 결과를 출력하세요.

---

## 📄 1. 문서 동기화 결과 (CLAUDE.md / AGENTS.md)

| 항목 | 값 |
|------|-----|
| 기준 파일 | `CLAUDE.md` (최근 수정: 2026-03-03 16:00:00) |
| 동기화된 파일 수 | N개 |
| 생성됨 | N개 |
| 업데이트됨 | N개 |
| 변경 없음 (스킵) | N개 |

### 상세

| 파일 경로 | 상태 | 비고 |
|-----------|------|------|
| `be/AGENTS.md` | ✅ 생성됨 | 기준: `be/CLAUDE.md` |
| `fe/AGENTS.md` | ⏭️ 스킵 | 내용 동일 |

---

## 🧩 2. Skills 동기화 결과

| 항목 | 값 |
|------|-----|
| 기준 Skills 경로 | `.agents/skills/` |
| 총 스킬 수 | N개 |
| 추가됨 | N개 |
| 삭제됨 | N개 |
| 업데이트됨 | N개 |

### Skills 상세

| 스킬명 | 작업 | 대상 경로 |
|--------|------|-----------|
| `multi-review` | ✅ 동기화됨 | `.agents/skills/`, `.claude/skills/` |
| `agent-sync` | ✅ 추가됨 | `.agents/skills/`, `.claude/skills/` |
| `old-skill` | 🗑️ 삭제됨 | `.agents/skills/`, `.claude/skills/` |

---

## ⚠️ 오류 / 경고

- (없으면 이 섹션 생략)
