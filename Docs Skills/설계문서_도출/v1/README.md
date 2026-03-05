# 📦 AI 협업 설계 양식 패키지

> 아이디어에서 AI Agent 실행까지, 단계별 템플릿 모음

---

## 파일 구성

```
01_DISCOVERY.md          ← 아이디어 → 설계 인터뷰 양식 (빈 양식)
01_DISCOVERY_example.md  ← 위 양식을 열차 예약 프로젝트로 채운 예시
02_SPEC.md               ← 통합 설계 문서 (Single Source of Truth)
03_BE_CONTEXT.md         ← 백엔드 AI Agent용 Context & Instruction
04_FE_CONTEXT.md         ← 프론트엔드 AI Agent용 Context & Instruction
```

---

## 전체 흐름

```
[내 아이디어]
     ↓
 01_DISCOVERY.md 를 AI에 붙여넣고 인터뷰 시작
     ↓
 대화 완료 → AI가 SECTION F 채워줌
     ↓
 02_SPEC.md 에 결과 구조화 (AI가 초안, 사람이 검토)
     ↓
     ├─ 03_BE_CONTEXT.md 생성 (02_SPEC 기반)
     └─ 04_FE_CONTEXT.md 생성 (02_SPEC 기반)
          ↓
     각각 BE Agent / FE Agent 에게 넘겨서 코드 작성 시작
```

---

## 단계별 사용법

### Step 1 — 인터뷰 (01_DISCOVERY.md)

AI에게 이렇게 말하세요:
```
이 파일을 읽고 나랑 인터뷰해줘.
한 번에 여러 개 묻지 말고, 섹션 순서대로 하나씩 물어봐.
내 답변이 애매하면 반박하거나 더 파고들어.
끝나면 SECTION F를 채워줘.
```

### Step 2 — 설계 문서화 (02_SPEC.md)

인터뷰 완료 후 AI에게:
```
방금 인터뷰 내용을 바탕으로 02_SPEC.md 를 채워줘.
모르는 항목은 비워두고, 열린 결정 사항으로 표시해줘.
```

### Step 3 — Agent Context 생성 (03, 04)

```
02_SPEC.md 를 기반으로 03_BE_CONTEXT.md 를 채워줘.
SECTION 5 (현재 태스크) 는 비워둬 — 내가 직접 채울게.
```

### Step 4 — Agent에게 작업 넘기기

SECTION 5를 직접 채운 뒤:
```
이 파일을 읽고 SECTION 5에 있는 태스크를 구현해줘.
판단이 필요한 것은 [QUESTION] 으로 모아서 마지막에 알려줘.
```

---

## 자주 쓰는 대화 패턴

### 패턴 A — 역방향 인터뷰
> "이게 정말 필요해? 더 단순하게 할 수 있어?"
→ AI가 가정을 뒤집어주면서 불필요한 기능을 걸러냄

### 패턴 B — 반반 검증
> "다른 AI랑 만든 설계야. 뭐가 빠졌어?"
→ 한 AI의 맹점을 다른 AI가 잡아줌

### 패턴 C — 경계 확인
> "이건 BE야 FE야?"
→ 역할 경계가 흐려질 때 SPEC으로 돌아와서 확인

---

## 팁

- **02_SPEC.md는 항상 최신 상태 유지.** Agent가 잘못된 결정을 하면 여기서 바로잡기.
- **SECTION 5는 작게 쪼개기.** 한 번에 너무 많은 태스크를 주면 Agent가 누락함.
- **[QUESTION] 패턴 활용.** Agent가 모르는 걸 코드에 숨기지 않고 표면으로 올리게 강제함.
- **뒤집어진 결정은 꼭 기록.** 나중에 "왜 이렇게 됐지?" 를 방지함.
