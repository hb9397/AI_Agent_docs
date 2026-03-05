# 커밋 메시지 예시

## 좋은 예시

```
feat(auth): 소셜 로그인 기능 추가

카카오/네이버 OAuth2 연동. 기존 이메일 로그인과 병행 지원.
```

```
fix(order): 주문 취소 시 재고 미복구 버그 수정

cancelOrder에서 stockService.restore 호출 누락.
동시 취소 시 race condition 방지를 위해 비관적 락 적용.
```

```
refactor(domain): Member 엔티티 Builder 패턴으로 전환

생성자 파라미터 6개 초과로 가독성 저하.
@Builder + 정적 팩토리 메서드 조합으로 변경.
```

```
test(payment): 결제 금액 경계값 테스트 추가

0원, 음수, 최대값(999_999_999) 케이스 검증.
```

## 나쁜 예시

```
# 영어 description (프로젝트 규칙: 한글)
feat(auth): add social login

# scope 누락
feat: 소셜 로그인 추가

# "무엇을"만 (why가 없음)
fix(order): cancelOrder 메서드 수정

# 50자 초과
feat(auth): 카카오와 네이버 소셜 로그인 OAuth2 연동 기능을 추가하고 기존 이메일 로그인과 병행 지원

# 여러 성격 혼합 (분리 필요)
feat(auth): 소셜 로그인 추가 및 기존 로그인 버그 수정
```

## scope 예시

| scope | 용도 |
|-------|------|
| `api` | API 모듈 (Controller, DTO) |
| `domain` | 도메인 모듈 (Entity, Service, UseCase) |
| `infra` | 인프라 모듈 (Repository 구현, 외부 연동) |
| `auth` | 인증/인가 |
| `member` | 회원 도메인 |
| `order` | 주문 도메인 |
| `payment` | 결제 도메인 |
| `config` | 설정 변경 |
| `ci` | CI/CD 파이프라인 |
| `deps` | 의존성 변경 |
