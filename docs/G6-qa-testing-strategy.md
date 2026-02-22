# G6. QA & Testing Strategy

> ClosetIQ · v1.0 · 2026.02.22

---

## 1. 테스트 피라미드

> **1인 개발자 테스트 철학:** "코드를 바꿀 때 기존 기능이 깨지지 않는다는 확신." 100% 커버리지가 아니라 핵심 경로(Critical Path)의 100% 보호가 목표.

| 계층 | 비율 | 개수 | 특징 |
|------|------|------|------|
| 단위 테스트 (Unit) | 70% | 50~80개 | 빠름 · 안정 · 자동 (매칭 엔진, 색상 추출 등) |
| 통합 테스트 (Integration) | 20% | 20~30개 | 중간 · API + DB 연동 |
| E2E 테스트 | 10% | 5~10개 | 느림 · 수동+자동 · 핵심 경로만 |

### 테스트 범위 (MVP)

| 영역 | 단위 | 통합 | E2E | 우선순위 |
|------|------|------|-----|---------|
| 매칭 엔진 (점수 계산) | 20개+ | 5개 | - | P0 |
| 색상 추출 (K-Means) | 10개 | - | - | P0 |
| 색상명 매핑 (HSL→한국어) | 19개 | - | - | P0 |
| API 엔드포인트 (CRUD) | - | 12개 | - | P0 |
| 인증/권한 (RLS) | - | 5개 | - | P0 |
| 사용량 한도 체크 | 4개 | 2개 | - | P1 |
| 이미지 업로드+배경 제거 | - | 3개 | - | P1 |
| 룩 재현 전체 흐름 | - | - | 1개 | P1 |
| 온보딩 전체 흐름 | - | - | 1개 | P1 |
| 구독 결제 흐름 | - | 2개 (mock) | 1개 (수동) | P2 |

### 도구 스택

| 계층 | 도구 | 용도 |
|------|------|------|
| Flutter 단위/위젯 | flutter_test (내장) | Dart 로직 + 위젯 렌더링 |
| Flutter 통합 | integration_test (내장) | 전체 앱 흐름 자동화 |
| Edge Functions 단위 | Deno.test (내장) | TypeScript 서버 로직 |
| API 통합 | Deno.test + Supabase Client | DB 연동 API 검증 |
| E2E (수동) | 체크리스트 기반 | 릴리스 전 수동 검증 |
| CI 실행 | GitHub Actions | push/PR 시 자동 |
| 커버리지 | lcov + Deno coverage | 핵심 모듈 80%+ |

---

## 2. 핵심 테스트 케이스 (27개)

### 단위 테스트 — 매칭 엔진 (7개)

| ID | 테스트 | Input | Expected |
|----|--------|-------|----------|
| U-001 | 동일 카테고리 보너스 40점 | ref: tops/knit, wardrobe: tops/knit | category_score = 40 |
| U-002 | 대분류만 일치 시 25점 | ref: tops/knit, wardrobe: tops/blouse | category_score = 25 |
| U-003 | 색상 ΔE < 15 만점 30점 | ref: #5B7DB1, wardrobe: #6080B5 (ΔE=5) | color_score = 30 |
| U-004 | 색상 ΔE > 50 시 0점 | ref: #FF0000, wardrobe: #0000FF | color_score = 0 |
| U-005 | 스타일 태그 겹침 비율 | ref: [casual, minimal], wardrobe: [casual, street] | style_score = 10 |
| U-006 | overall_score 가중합 | cat:40 + color:25 + style:15 + bonus:5 | overall_score = 85 |
| U-007 | 매칭 없을 때 gap_items | ref: shoes/sneakers, wardrobe: (shoes 없음) | gap_items에 포함 |

### 단위 테스트 — 색상 (4개)

| ID | 테스트 | Input | Expected |
|----|--------|-------|----------|
| U-010 | K-Means 대표색 선택 | 흰 배경 70% + 검정 옷 30% | 대표색 = 검정 |
| U-011 | 무채색 판별 | HSL(0, 5, 90) | 라이트그레이 |
| U-012 | 네이비 판별 | HSL(210, 35, 24) | 네이비 |
| U-013 | 크림 판별 | HSL(40, 50, 93) | 크림 |

### 통합 테스트 — API (10개)

| ID | 테스트 | Expected |
|----|--------|----------|
| I-001 | 아이템 등록 성공 | 201 + item 객체 + R2 URL |
| I-002 | 무료 30벌 한도 초과 | 403 WARDROBE_LIMIT_REACHED |
| I-003 | 이미지 없음 | 400 Bad Request |
| I-004 | 10MB 초과 | 413 Payload Too Large |
| I-005 | 룩 재현 성공 | 200 + matched + gap |
| I-006 | 월 5회 한도 초과 | 403 RECREATION_LIMIT_REACHED |
| I-007 | RLS: 타 유저 접근 불가 | 빈 배열 (0건) |
| I-008 | RLS: 타 유저 삭제 불가 | 404 Not Found |
| I-009 | 페이지네이션 | 5건 + has_more=true |
| I-010 | 계정 삭제 CASCADE | 모든 관련 데이터 삭제 |

### E2E 테스트 (5개)

| ID | 테스트 | 흐름 |
|----|--------|------|
| E-001 | 온보딩 → 첫 아이템 | 카카오 로그인 → 갤러리 선택 → 배경 제거 → 카테고리 확인 → 저장 |
| E-002 | 룩 재현 전체 | 레퍼런스 선택 → AI 분석 → 결과 → 매칭/갭 확인 |
| E-003 | 갭 딥링크 | 갭 아이템 → 무신사 링크 → 외부 브라우저 |
| E-004 | 결과 공유 | 결과 → 공유 → 인스타 스토리 |
| E-005 | Paywall | 30벌 한도 → 31번째 시도 → 프리미엄 바텀시트 |

---

## 3. CI/CD 파이프라인

```
git push / PR 생성
  │
  ▼ GitHub Actions
  ① Lint & Format (30초)
  ② Unit Tests (1~2분)
  ③ Integration Tests (2~3분)
  ④ Coverage Report (핵심 80%+)
  ⑤ Build Check (3~5분)
  │
  ▼ main merge 시
  ⑥ Deploy Edge Functions
  ⑦ DB Migration
  │
  ▼ release 태그 시
  ⑧ App Store 빌드 & TestFlight 업로드
```

### 브랜치 전략

| 브랜치 | 용도 | CI 범위 | 배포 |
|--------|------|---------|------|
| main | 프로덕션 준비 | 전체 | 앱스토어 제출 |
| develop | 개발 통합 | lint + unit + integration | Staging |
| feature/* | 기능 개발 | lint + unit | 없음 |
| hotfix/* | 긴급 수정 | 전체 | main 직접 merge |

---

## 3.5 접근성 테스트 케이스

### VoiceOver (iOS) / TalkBack (Android) 테스트 시나리오

| ID | 테스트 | 화면 | 검증 기준 |
|----|--------|------|----------|
| A-001 | 옷장 그리드 아이템 읽기 | S06 | VoiceOver가 "카키 슬랙스, 하의, 착용 3회"를 읽어야 함 |
| A-002 | 룩 재현 결과 읽기 | S11 | "매칭 78%, 상의 아이보리 니트 92점 매칭 성공" 읽기 |
| A-003 | 갭 아이템 안내 | S12 | "브라운 로퍼, 없는 아이템, 무신사에서 찾기 버튼" |
| A-004 | 카테고리 필터 선택 | S06 | "상의 필터, 선택됨" / "하의 필터, 선택 안 됨" |
| A-005 | 온보딩 촬영 유도 | S03 | "오늘 입은 옷을 찍어보세요, 카메라 촬영 버튼" |
| A-006 | 프리미엄 업그레이드 | S17 | 혜택 목록 + 가격 + CTA 버튼 모두 읽기 가능 |
| A-007 | 바텀 탭 네비게이션 | 전체 | 각 탭 이름 + 현재 선택 상태 읽기 |

### 색상 대비 WCAG AA 검증 체크리스트

| 항목 | 전경색 | 배경색 | 대비 비율 | AA 기준 | 합격 |
|------|--------|--------|----------|--------|------|
| 제목 텍스트 | Slate 800 (#1E293B) | White (#FFFFFF) | 13.5:1 | 4.5:1 | ✅ |
| 본문 텍스트 | Slate 600 (#475569) | White (#FFFFFF) | 7.0:1 | 4.5:1 | ✅ |
| 보조 텍스트 | Slate 400 (#94A3B8) | White (#FFFFFF) | 3.4:1 | 4.5:1 | ⚠️ 확대 텍스트(18px+)에서만 합격 |
| Primary 버튼 텍스트 | White (#FFFFFF) | Indigo 600 (#4F46E5) | 6.9:1 | 4.5:1 | ✅ |
| 매칭 성공 | Emerald 700 (#047857) | Emerald 50 (#ECFDF5) | 5.8:1 | 4.5:1 | ✅ |
| 매칭 실패 | Rose 700 (#BE123C) | Rose 50 (#FFF1F2) | 5.2:1 | 4.5:1 | ✅ |
| 프리미엄 배지 | White (#FFFFFF) | Purple 600 (#9333EA) | 5.1:1 | 4.5:1 | ✅ |

> **주의:** 보조 텍스트(Slate 400)는 14px 이하에서 AA 미달. Caption(12px)에서는 Slate 500(#64748B, 4.7:1)으로 교체 권장.

### Dynamic Type / Scalable Text 테스트 케이스

| ID | 테스트 | 설정 | 검증 기준 |
|----|--------|------|----------|
| DT-001 | 최소 텍스트 크기 | xSmall (시스템 최소) | 모든 텍스트 가독성 유지, 레이아웃 깨짐 없음 |
| DT-002 | 최대 텍스트 크기 | xxxLarge (AX5) | 텍스트 잘림 없음, 스크롤 가능, 버튼 탭 가능 |
| DT-003 | 옷장 그리드 확대 | xxxLarge | 그리드 2열로 전환, 텍스트 표시 유지 |
| DT-004 | 룩 재현 결과 확대 | xxxLarge | 나란히 비교 → 세로 배치 전환, 점수 가독성 유지 |
| DT-005 | 바텀 탭 라벨 확대 | xxxLarge | 탭 라벨 잘림 없음, 최소 44px 터치 타겟 유지 |
| DT-006 | 카테고리 칩 확대 | xxxLarge | 칩 높이 자동 확장, 탭 가능 |

---

## 4. 디바이스 호환성 매트릭스

### iOS

| 디바이스 | OS | 화면 | 필수 |
|---------|-----|------|------|
| iPhone 15 Pro | iOS 18 | 6.1" | ✅ 필수 |
| iPhone 13 | iOS 17 | 6.1" | ✅ 필수 |
| iPhone SE 3 | iOS 16 | 4.7" | ✅ 필수 (최소 화면) |
| iPhone 12 mini | iOS 17 | 5.4" | 권장 |

### Android

| 디바이스 | OS | 화면 | 필수 |
|---------|-----|------|------|
| Galaxy S24 | Android 14 | 6.2" | ✅ 필수 |
| Galaxy A34 | Android 13 | 6.6" | ✅ 필수 (점유율 높음) |
| Pixel 7a | Android 14 | 6.1" | 권장 |

---

## 5. 릴리스 체크리스트

### 앱스토어 제출 전

**🔧 기술:** CI 전체 통과, 크래시율 <1%, AI 성공률 >95%, 응답 <5초, 콜드 스타트 <3초, 메모리 누수 없음, Production 환경변수 확인

**📱 UX:** SE~15 Pro 레이아웃, Galaxy A34/S24 레이아웃, 키보드 가림 없음, 스켈레톤 UI, 에러 상태 UI, 빈 상태 UI, 접근성 44×44pt

**📊 분석:** PostHog 34개 이벤트 발화 확인, 슈퍼 프로퍼티 전송, 대시보드 알림 테스트

**📋 법률:** 개인정보처리방침 링크, 이용약관 동의, Privacy Nutrition Label, 연령 등급 4+

**🚀 배포:** Edge Functions 배포, DB Migration, R2 설정, Sentry/PostHog Production 키

### 핫픽스 프로세스

```
크리티컬 버그 → hotfix 브랜치 → 수정 + 테스트 → main merge → 태그
  ├── Edge Function: 즉시 배포
  └── 앱: Expedited Review 요청 (24시간 이내)
```
