# F7 프리미엄 구독 시스템

> **Feature:** f7-premium-subscription
> **Phase:** Plan
> **Created:** 2026-02-23
> **Status:** Draft
> **Related Docs:** [PRD Section 4.3 F7](../../PRD.md), [TDD](../../기술설계문서-TDD.md)

---

## 1. 목적

수익화 핵심 기능. 무료 사용자에게 한도를 부여하고, 프리미엄 구독을 통해 모든 제한을 해제한다.
Apple IAP / Google Play Billing을 통한 인앱 결제로 월간/연간 구독을 지원한다.

**핵심 가치:**
- 무료 → 프리미엄 전환 유도 (무료 한도 도달 시 자연스러운 업그레이드 프롬프트)
- 구독 상태를 서버사이드(Supabase)에서 관리하여 디바이스 간 동기화
- RevenueCat SDK로 Apple/Google 결제 통합 (서버 영수증 검증 직접 구현 불필요)

**타겟 페르소나:** 세그먼트 B (출근 코디 고민러, 높은 리텐션 사용자)

## 2. 사용자 흐름

### 2.1 자연스러운 전환 유도 (Soft Paywall)

```
무료 사용 중
  │
  ├── 옷장 30벌 한도 도달 시
  │     → "옷장이 꽉 찼어요!" 바텀시트
  │     → [프리미엄 업그레이드] / [아이템 정리하기]
  │
  ├── 룩 재현 월 5회 한도 도달 시
  │     → "이번 달 무료 횟수를 다 사용했어요" 다이얼로그
  │     → [프리미엄으로 무제한 사용] / [다음 달까지 기다리기]
  │
  └── 설정 > 프리미엄 업그레이드 탭
        → 프리미엄 소개 화면으로 이동
```

### 2.2 구독 구매 흐름

```
프리미엄 소개 화면 (S18: Paywall)
  │
  ├── 프리미엄 혜택 목록 표시
  │     · 무제한 옷장
  │     · 무제한 룩 재현
  │     · 코디 버전 3가지 (Tier 3)
  │     · 시즌 리포트 (Tier 4)
  │     · 상세 갭 분석
  │
  ├── 가격 플랜 선택
  │     · 월간: ₩6,900/월
  │     · 연간: ₩59,000/년 (₩4,917/월, 29% 할인)
  │     · 얼리버드: ₩39,000/년 (출시 전 한정)
  │
  └── [구독하기] 버튼
        → RevenueCat purchasePackage()
        → Apple/Google 네이티브 결제 시트
        → 성공: 프리미엄 상태 즉시 반영
        → 실패: 에러 메시지 + 재시도 안내
```

### 2.3 구독 관리

```
설정 > 구독 관리
  │
  ├── 현재 플랜 표시 (무료 / 월간 / 연간)
  ├── 다음 결제일 표시
  ├── [플랜 변경] → 스토어 관리 페이지
  └── [구독 해지] → 스토어 구독 관리 페이지 (앱 외부)
```

## 3. 프리미엄 혜택 & 무료 한도

| 기능 | 무료 | 프리미엄 |
|------|------|----------|
| 옷장 아이템 | 30벌 | 무제한 |
| 룩 재현 | 월 5회 | 무제한 |
| 코디 추천 | O | O |
| 데일리 기록 | O | O |
| 코디 버전 다양화 | X | 3가지 (Tier 3) |
| 시즌 리포트 | X | O (Tier 4) |
| 상세 갭 분석 | X | O |

**MVP에서 실질적 차이:** 옷장 한도 해제 + 룩 재현 무제한

## 4. 기술 요구사항

### 4.1 결제 SDK: RevenueCat

| 항목 | 선택 |
|------|------|
| SDK | `purchases_flutter` (RevenueCat Flutter SDK) |
| 이유 | Apple IAP + Google Billing 통합 관리, 서버 영수증 검증 불필요, Webhook으로 Supabase 연동 가능 |
| 무료 한도 | 월 매출 $2,500까지 무료 (MVP 충분) |
| 대시보드 | RevenueCat 웹에서 매출/이탈/전환율 분석 |

**RevenueCat 선택 이유 (vs 직접 구현):**
- Apple IAP + Google Play Billing을 각각 구현하면 서버 영수증 검증, 갱신 처리, 환불 처리 등 복잡도가 매우 높음
- 1인 개발자에게 RevenueCat은 사실상 표준: 무료 티어 충분, SDK 하나로 양 플랫폼 통합
- Subscription lifecycle (만료, 갱신, Grace period) 자동 관리

### 4.2 RevenueCat 설정 항목

```
RevenueCat 대시보드:
├── Product ID (Apple)
│     · closetiq_monthly    → ₩6,900/월
│     · closetiq_yearly     → ₩59,000/년
│     · closetiq_earlybird  → ₩39,000/년 (출시 전 한정)
│
├── Product ID (Google)
│     · closetiq_monthly    → ₩6,900/월
│     · closetiq_yearly     → ₩59,000/년
│
├── Offering: "default"
│     · Package: monthly → closetiq_monthly
│     · Package: annual  → closetiq_yearly
│
└── Entitlement: "premium"
      → 모든 프리미엄 상품이 이 entitlement 부여
```

### 4.3 DB 변경사항

profiles 테이블에 구독 상태 컬럼 추가:

```sql
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS subscription_status TEXT
    CHECK (subscription_status IN ('free','active','expired','grace_period'))
    DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS subscription_plan TEXT
    CHECK (subscription_plan IN ('monthly','yearly','earlybird'))
    DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMPTZ DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS revenuecat_id TEXT DEFAULT NULL;
```

**참고:** RevenueCat이 subscription lifecycle를 관리하므로, 앱에서는 `CustomerInfo`의 entitlement 상태를 우선 확인하고, DB는 백업/캐시 용도로 활용.

### 4.4 외부 패키지

| 패키지 | 용도 | 상태 |
|--------|------|------|
| `purchases_flutter` | RevenueCat Flutter SDK (IAP 통합) | 신규 추가 |
| `flutter_riverpod` | 상태 관리 | 이미 설치됨 |

### 4.5 기존 코드 수정 포인트

현재 무료 한도가 하드코딩으로 관리되고 있으며, 프리미엄 상태에 따라 분기 필요:

| 기존 파일 | 변경 내용 |
|-----------|-----------|
| `lib/core/config/app_config.dart` | freeWardrobeLimit, freeRecreationMonthlyLimit 유지 (무료 한도) |
| `lib/features/wardrobe/providers/wardrobe_provider.dart` | `canAddItemProvider` → 프리미엄이면 항상 true |
| `lib/features/recreation/providers/usage_provider.dart` | `canRecreateProvider` → 프리미엄이면 항상 true |
| `lib/features/wardrobe/presentation/wardrobe_screen.dart` | 한도 도달 UI → 프리미엄 분기 |
| `lib/features/wardrobe/presentation/item_add_screen.dart` | 한도 체크 → 프리미엄 분기 |
| `lib/features/settings/presentation/settings_screen.dart` | "프리미엄 업그레이드" → 구독 관리 분기 |

## 5. 화면 구성

### S18: 프리미엄 소개 / Paywall (신규)

- 그라데이션 헤더 (purple 계열, AppColors.premium 활용)
- 프리미엄 혜택 아이콘 + 설명 목록
- 가격 플랜 토글 (월간 / 연간)
- 연간 플랜 "29% 할인" 뱃지
- [구독하기] CTA 버튼
- 하단: 이용약관 + 개인정보처리방침 링크
- 하단: "구독은 iTunes/Google Play 계정으로 결제됩니다" 안내 문구

### S19: 구독 관리 화면 (신규)

- 현재 플랜 카드 (플랜명, 다음 결제일, 상태)
- [플랜 변경] → 스토어 구독 관리 페이지 열기
- [구독 해지] → 스토어 구독 관리 페이지 열기
- 구독 상태별 UI:
  - `free`: 프리미엄 소개 카드 표시
  - `active`: 현재 플랜 정보 + 다음 결제일
  - `expired`: "구독이 만료되었습니다" + 재구독 CTA
  - `grace_period`: "결제 문제가 있습니다" 경고

### 한도 도달 바텀시트 (기존 화면에 추가)

- 아이콘 + "옷장이 꽉 찼어요!" / "이번 달 무료 횟수 소진"
- 프리미엄 혜택 간략 소개
- [프리미엄으로 업그레이드] CTA (→ S18)
- [아이템 정리하기] / [다음 달 기다리기] 보조 액션

## 6. 구현 순서

| Step | 내용 | 파일 |
|------|------|------|
| 1 | `purchases_flutter` 패키지 추가 + RevenueCat 초기화 | `pubspec.yaml`, `lib/core/config/revenuecat_config.dart` |
| 2 | Subscription 모델 (구독 상태, 플랜) | `lib/features/subscription/data/models/subscription_status.dart` |
| 3 | SubscriptionService (RevenueCat SDK 래퍼) | `lib/features/subscription/data/subscription_service.dart` |
| 4 | SubscriptionProvider (상태 관리 + isPremium) | `lib/features/subscription/providers/subscription_provider.dart` |
| 5 | Paywall 화면 (S18) | `lib/features/subscription/presentation/paywall_screen.dart` |
| 6 | Subscription 관리 화면 (S19) | `lib/features/subscription/presentation/subscription_manage_screen.dart` |
| 7 | 한도 도달 바텀시트 위젯 | `lib/features/subscription/presentation/widgets/limit_reached_sheet.dart` |
| 8 | 기존 Provider 수정 (canAddItem, canRecreate → 프리미엄 분기) | 기존 provider 파일들 |
| 9 | 기존 UI 수정 (설정 화면, 한도 표시) | 기존 presentation 파일들 |
| 10 | AppRouter에 라우트 추가 | `lib/core/router/app_router.dart` |
| 11 | DB 마이그레이션 (profiles 컬럼 추가) | `supabase/migrations/` |
| 12 | flutter analyze + 검증 | — |

## 7. MVP 범위

### 포함

- RevenueCat SDK 연동 (Apple IAP + Google Billing 통합)
- 월간/연간 구독 상품 2종
- Paywall 화면 (프리미엄 소개 + 결제)
- 구독 상태 Provider (`isPremium`)
- 기존 무료 한도 로직에 프리미엄 분기 추가
- 한도 도달 시 업그레이드 유도 바텀시트
- 설정 화면에서 구독 상태 표시
- 구독 관리 (스토어 페이지 연결)

### 후순위 (Phase 2)

- 얼리버드 가격 플랜 (출시 전 한정)
- RevenueCat Webhook → Supabase 자동 동기화
- 구독 만료 푸시 알림
- 프로모 코드 / 쿠폰 시스템
- A/B 테스트 (가격, Paywall 디자인)
- 구독 분석 대시보드 (LTV, Churn rate)

## 8. 검증 기준

1. `flutter analyze` 에러 없음
2. RevenueCat SDK 초기화 성공 (앱 시작 시)
3. `isPremiumProvider`가 구독 상태를 정확히 반영
4. 무료 사용자: 옷장 30벌 한도, 룩 재현 월 5회 한도 유지
5. 프리미엄 사용자: 모든 한도 해제
6. Paywall 화면에서 가격 플랜 정상 표시 (RevenueCat Offerings)
7. 결제 플로우: 구독 버튼 → 네이티브 결제 시트 → 성공/실패 처리
8. 설정 화면: 구독 상태에 따른 분기 표시
9. 한도 도달 시 업그레이드 바텀시트 표시

## 9. 파일 구조 (Expected)

```
lib/features/subscription/
├── data/
│   ├── models/
│   │   └── subscription_status.dart
│   └── subscription_service.dart
├── providers/
│   └── subscription_provider.dart
└── presentation/
    ├── paywall_screen.dart
    ├── subscription_manage_screen.dart
    └── widgets/
        └── limit_reached_sheet.dart

lib/core/config/
└── revenuecat_config.dart       (신규)

supabase/migrations/
└── 20260224000001_add_subscription_columns.sql  (신규)
```

## 10. 리스크 & 대응

| 리스크 | 영향 | 대응 |
|--------|------|------|
| RevenueCat SDK 초기화 실패 | 구독 상태 확인 불가 | 로컬 캐시 폴백 + "무료" 기본값 |
| Apple 심사 리젝 (구독 관련) | 출시 지연 | Apple 가이드라인 준수 (복원 버튼, 이용약관 링크 필수) |
| 결제 실패 | 구독 미적용 | 에러 메시지 + 재시도 안내 |
| Grace period 상태 | 일시적 결제 실패 | 프리미엄 유지 + "결제 확인 필요" 배너 |
| 오프라인 상태 | RevenueCat 미응답 | 로컬 캐시된 CustomerInfo 활용 (SDK 내장) |
| 환불 처리 | 프리미엄 해제 필요 | RevenueCat 자동 처리 (entitlement 제거) |

## 11. Apple/Google 스토어 요구사항

### Apple App Store (필수)

- 구독 자동갱신 안내 문구 표시
- "구독 복원" 버튼 Paywall에 필수 포함
- 이용약관 + 개인정보처리방침 링크 필수
- 구독 취소 방법 안내

### Google Play Store (필수)

- 구독 가격/기간 명시
- 개인정보처리방침 링크
- Google Play Billing Library 사용 (RevenueCat이 처리)
