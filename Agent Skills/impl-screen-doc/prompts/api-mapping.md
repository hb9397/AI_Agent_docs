# API 연동 포인트 규칙 (api-mapping)

---

## 화면별 API 매핑 형식

각 화면이 호출하는 API를 아래 형식으로 정리한다.

```markdown
### API 연동

| # | 메서드 | 경로 | 호출 시점 | 요청 | 응답 | 에러 처리 |
|---|--------|------|----------|------|------|----------|
| 1 | GET | /api/inspections | 화면 마운트 + 필터 변경 | query: page, size, status, keyword | { items: [], total: N } | 에러 토스트 + 재시도 |
| 2 | GET | /api/inspections/{id} | 행 클릭 (상세 모달) | path: id | { ...상세 데이터 } | 에러 토스트 |
| 3 | POST | /api/inspections | 등록 폼 제출 | body: { ...필드 } | { id: N } | 유효성 에러 → 필드별 표시 |
| 4 | PUT | /api/inspections/{id} | 수정 폼 제출 | path: id, body: { ...필드 } | { id: N } | 충돌 시 확인 다이얼로그 |
| 5 | DELETE | /api/inspections/{id} | 삭제 버튼 (확인 후) | path: id | 204 | 실패 시 토스트 |
```

---

## API 호출 시점 분류

```
마운트 시: 화면 진입 시 자동 호출 (목록 조회, 초기 데이터)
사용자 액션: 클릭, 폼 제출, 필터 변경 등
자동 갱신: 폴링, WebSocket 이벤트, Focus 복귀 시
조건부: 특정 상태일 때만 호출 (권한 체크 후, 데이터 존재 시)
```

---

## 에러 처리 패턴

| HTTP 상태 | 처리 방식 |
|-----------|----------|
| 400 Bad Request | 유효성 에러 → 필드별 인라인 에러 메시지 |
| 401 Unauthorized | 로그인 페이지로 리다이렉트 |
| 403 Forbidden | "권한이 없습니다" 안내 + 이전 화면으로 |
| 404 Not Found | "데이터를 찾을 수 없습니다" + 목록으로 |
| 409 Conflict | 충돌 안내 다이얼로그 + 재시도 옵션 |
| 500 Server Error | 에러 토스트 + 재시도 버튼 |
| Network Error | 오프라인 안내 + 자동 재시도 |

---

## 요청/응답 상세 표기

복잡한 API는 별도 블록으로 상세를 기술한다:

```markdown
#### API 상세: POST /api/inspections

**요청 Body:**
```json
{
  "facilityId": "string (필수)",
  "inspectionDate": "ISO 8601 (필수)",
  "sensorData": {
    "temperature": "number (선택)",
    "voltage": "number (선택)"
  },
  "memo": "string (선택, 최대 500자)"
}
```

**응답 200:**
```json
{
  "id": "number",
  "status": "PENDING | ANALYZED",
  "createdAt": "ISO 8601"
}
```

**응답 400:**
```json
{
  "errors": [
    { "field": "facilityId", "message": "필수 항목입니다" }
  ]
}
```
```
