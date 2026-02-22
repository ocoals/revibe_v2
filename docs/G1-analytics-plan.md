# G1. Analytics & Measurement Plan

> ClosetIQ · v1.0 · 2026.02.22

---

## 1. 핵심 지표 체계

### North Star Metric: WAU-Core (주간 핵심 활동 사용자 수)

> "최근 7일 내 코디 기록 또는 룩 재현을 1회 이상 수행한 사용자 수"

**선정 근거:** 단순 앱 오픈(DAU)이 아닌 핵심 가치를 경험한 사용자를 측정. 이 지표가 올라가면 리텐션·전환·바이럴이 모두 따라옴.

### 1.1 지표 계층 구조 (Metric Tree)

```
                    ┌─────────────────────────────┐
                    │   North Star: WAU-Core       │
                    │   (주간 핵심 활동 사용자 수)     │
                    └─────────────┬───────────────┘
                                  │
            ┌─────────────────────┼─────────────────────┐
            │                     │                     │
     ┌──────▼──────┐    ┌────────▼────────┐    ┌───────▼──────┐
     │ Acquisition │    │   Engagement    │    │  Monetization│
     │ (사용자 확보) │    │  (참여/활동)    │    │  (수익화)     │
     └──────┬──────┘    └────────┬────────┘    └───────┬──────┘
            │                    │                     │
     - 일간 설치 수       - 인당 등록 아이템 수     - MRR (월 반복 수익)
     - 가입 전환율        - 인당 룩 재현 횟수       - ARPU (인당 수익)
     - 온보딩 완료율      - D1/D7/D30 리텐션       - 전환율 (무료→유료)
     - 채널별 유입 비율    - 세션 빈도/길이         - LTV (생애 가치)
```

### 1.2 Phase별 목표

**Phase 1 (출시 후 1개월):**

| 지표 | 목표 | 비고 |
|------|------|------|
| 얼리버드 대기자 | 200명+ | 랜딩페이지 사전 모집 |
| 온보딩 완료율 | 70%+ | 가입 → 첫 아이템 등록 |
| 첫 룩 재현율 | 50%+ | 온보딩 완료자 중 |
| 룩 재현 만족도 | 3.5/5+ | 인앱 피드백 |
| D7 리텐션 | 30%+ | 코호트 기준 |

**Phase 2 (출시 후 3~6개월):**

| 지표 | 목표 |
|------|------|
| MAU | 5,000명+ |
| WAU-Core 비율 | 40%+ (MAU 대비) |
| D30 리텐션 | 15%+ |
| 프리미엄 전환율 | 2%+ |
| MRR | 35만원+ (BEP) |

---

## 2. 퍼널 정의 (AARRR)

### 2.1 5단계 퍼널

| 단계 | 정의 | 핵심 이벤트 | 목표 전환율 |
|------|------|------------|-----------|
| **Acquisition** | 앱 설치 → 가입 완료 | app_installed → signup_completed | 60%+ |
| **Activation** | 가입 → 온보딩 완료 (첫 아이템 등록) | signup_completed → onboarding_completed | 70%+ (가입 대비) |
| **Retention** | 재방문 | D1/D7/D30 리텐션 | D1 50%, D7 30%, D30 15% |
| **Revenue** | Paywall 노출 → 결제 | paywall_shown → subscription_started | 8%+ (노출 대비) |
| **Referral** | 결과 → 공유 완료 | result_viewed → result_shared | 15%+ |

### 2.2 핵심 전환 경로 (예상 수치)

```
앱 설치     100%
  → 가입     60%
  → 온보딩    42% (가입자의 70%)
  → 첫 룩재현  25% (온보딩의 60%)
  → D7 활성   13%
  → D30 활성   6%
  → 프리미엄    2%
```

---

## 3. 이벤트 택소노미

### 3.1 네이밍 컨벤션

- 형식: `object_action` (스네이크 케이스)
- 예시: `item_registered`, `recreation_completed`, `subscription_started`

### 3.2 슈퍼 프로퍼티 (모든 이벤트에 자동 첨부)

| 프로퍼티 | 타입 | 설명 |
|---------|------|------|
| user_id | string | 사용자 고유 ID |
| timestamp | datetime | 이벤트 발생 시각 |
| app_version | string | 앱 버전 (예: 1.0.0) |
| os | string | ios / android |
| device_model | string | iPhone 15 Pro 등 |
| subscription_tier | string | free / premium |

### 3.3 이벤트 목록 (MVP 26개 + Tier 2 9개 = 총 35개)

**Lifecycle (6개)**

| 이벤트 | 트리거 | 핵심 프로퍼티 | 우선순위 |
|--------|--------|-------------|---------|
| signup_completed | 소셜 로그인 완료 | provider (kakao/apple) | MVP |
| onboarding_completed | 첫 아이템 등록 완료 | items_count, duration_sec | MVP |
| onboarding_skipped | 온보딩 중간 이탈 | last_step, duration_sec | MVP |
| profile_updated | 프로필 수정 | fields_changed | MVP |
| account_deleted | 회원 탈퇴 | reason, items_count | MVP |
| app_opened | 앱 실행 | session_id, is_first_open | MVP |

**Wardrobe (6개)**

| 이벤트 | 트리거 | 핵심 프로퍼티 | 우선순위 |
|--------|--------|-------------|---------|
| item_registered | 아이템 등록 완료 | source (camera/gallery), category, color_name | MVP |
| item_registration_failed | 등록 실패 | error_type (bg_remove/upload) | MVP |
| item_edited | 아이템 수정 | fields_changed | MVP |
| item_deleted | 아이템 삭제 | category, registered_days_ago | MVP |
| wardrobe_viewed | 옷장 목록 조회 | filter_used, items_total | MVP |
| wardrobe_limit_hit | 30벌 한도 도달 | items_count | MVP |

**Recreation (6개)**

| 이벤트 | 트리거 | 핵심 프로퍼티 | 우선순위 |
|--------|--------|-------------|---------|
| recreation_started | 룩 재현 시작 | source (gallery/share) | MVP |
| recreation_completed | 분석 결과 수신 | overall_score, matched_count, gap_count, duration_sec | MVP |
| recreation_failed | AI 분석 실패 | error_type (timeout/api_error/no_items) | MVP |
| recreation_satisfaction | 만족도 제출 | score (1~5), recreation_id | MVP |
| recreation_limit_hit | 월 5회 한도 도달 | current_month_count | MVP |
| result_viewed | 결과 화면 조회 | overall_score, view_duration_sec | MVP |

**Gap & Share (4개)**

| 이벤트 | 트리거 | 핵심 프로퍼티 | 우선순위 |
|--------|--------|-------------|---------|
| gap_deeplink_clicked | 쇼핑 링크 탭 | platform (musinsa/ably), item_category | MVP |
| result_shared | 결과 공유 완료 | channel (instagram/kakao/save), recreation_id | MVP |
| share_image_generated | 공유 이미지 생성 | channel | Tier 2 |
| share_cancelled | 공유 시작 → 취소 | channel | Tier 2 |

**Revenue (4개)**

| 이벤트 | 트리거 | 핵심 프로퍼티 | 우선순위 |
|--------|--------|-------------|---------|
| paywall_shown | Paywall 바텀시트 노출 | trigger (wardrobe_limit/recreation_limit/tab) | MVP |
| paywall_dismissed | Paywall 닫기 | trigger, view_duration_sec | MVP |
| subscription_started | 구독 결제 완료 | plan (monthly/yearly/earlybird), price | MVP |
| subscription_cancelled | 구독 해지 | plan, subscription_duration_days | MVP |

**Outfit & System (6개, Tier 2)**

| 이벤트 | 트리거 | 핵심 프로퍼티 | 우선순위 |
|--------|--------|-------------|---------|
| daily_outfit_logged | 데일리 코디 기록 | items_count | Tier 2 |
| outfit_recommendation_shown | 코디 추천 표시 | recommendation_type | Tier 2 |
| outfit_recommendation_accepted | 추천 수락 | recommendation_id | Tier 2 |
| push_received | 푸시 수신 | push_type, campaign_id | Tier 2 |
| push_opened | 푸시 탭 → 앱 열림 | push_type, campaign_id | Tier 2 |
| error_occurred | 앱 에러 발생 | error_code, screen | Tier 2 |

---

## 4. 대시보드 설계

### 4.1 일간 대시보드 (매일 아침 확인)

| 위젯 | 지표 | 알림 조건 |
|------|------|----------|
| 헤드라인 숫자 | DAU, 신규 가입, 아이템 등록, 룩 재현 | - |
| 실시간 퍼널 | 오늘의 가입 → 온보딩 → 재현 전환율 | - |
| 에러 모니터 | 크래시율, AI 에러율 | 크래시율 >2%, AI 에러율 >5% |

### 4.2 주간 대시보드 (매주 금요일 리뷰)

| 위젯 | 지표 |
|------|------|
| WAU-Core 추이 | 주간 추이 차트 (4주) |
| 퍼널 전환율 | AARRR 각 단계 전환율 주간 변화 |
| 코호트 리텐션 표 | 주간 코호트별 W1~W8 리텐션 |
| 룩 재현 품질 | 평균 매칭 점수, 만족도 분포 |
| 인기 카테고리 TOP 5 | 등록 아이템 카테고리 비율 |
| 공유 채널 비율 | 인스타/카카오/저장 비율 |

### 4.3 월간 대시보드 (월말 경영 리뷰)

| 위젯 | 지표 | 목표 |
|------|------|------|
| MRR | 월 반복 수익 | BEP: 35만원 |
| LTV | 고객 생애 가치 | ₩15,000+ (보수적) |
| CAC | 고객 획득 비용 | ₩5,000 이하 |
| LTV:CAC 비율 | | 3:1 이상 |
| Payback Period | CAC 회수 기간 | 3개월 이내 |
| Net Revenue Retention | 순수익 유지율 | 100%+ |

---

## 5. A/B 테스트 프레임워크

### 5.1 1인 개발자 현실

- 초기 DAU <100이므로 동시 분배 A/B 테스트 통계적 유의성 확보 어려움
- **순차적 테스트:** 1주 A 버전 → 1주 B 버전 → 비교
- 500명+ DAU 달성 후 동시 분배 전환

### 5.2 첫 5개 실험 후보

| ID | 실험 | 변수 | 성공 기준 | 시점 |
|----|------|------|----------|------|
| EXP-001 | 온보딩 촬영 유도 vs 갤러리 선택 유도 | 첫 화면 CTA | 온보딩 완료율 10%p+ 차이 | Month 1 |
| EXP-002 | 룩 재현 점수 표시 vs 비표시 | 결과 화면 UI | 만족도 0.3점+ 차이 | Month 1 |
| EXP-003 | 무료 한도 30벌 vs 20벌 | Paywall 트리거 | 전환율 상승 × 리텐션 유지 | Month 2 |
| EXP-004 | 공유 CTA 위치 (하단 vs 상단) | 결과 화면 레이아웃 | 공유율 5%p+ 차이 | Month 2 |
| EXP-005 | 푸시 시간대 (오전 7시 vs 오후 9시) | 푸시 발송 시간 | 코디 기록률 10%p+ 차이 | Month 3 |

### 5.3 실험 통계 설계 기준

| 항목 | 기준 | 비고 |
|------|------|------|
| 통계적 유의성 | p < 0.05 (양측 검정) | 표준 95% 신뢰수준 |
| 검정력 (Power) | 80% 이상 | β = 0.20 |
| 최소 효과 크기 (MDE) | 실험별 상이 (아래 참조) | 실제 의미 있는 차이 |

#### 실험별 최소 샘플 크기 & 기간

| ID | MDE | 기준 전환율 | 각 그룹 최소 샘플 | 예상 필요 기간 |
|----|-----|-----------|-----------------|-------------|
| EXP-001 | 10%p | 70% (온보딩 완료) | 294명 | 순차: 1주 A + 1주 B (DAU 40~50 기준) |
| EXP-002 | 0.3점 (5점 척도) | 3.5/5 평균 | 175명 | 순차: 1주 A + 1주 B |
| EXP-003 | 1%p | 2% (전환율) | 3,822명 | 동시 분배: DAU 500+ 도달 후 실행 |
| EXP-004 | 5%p | 15% (공유율) | 686명 | 순차: 2주 A + 2주 B |
| EXP-005 | 10%p | 20% (기록률) | 294명 | 순차: 1주 A + 1주 B |

> **순차 테스트 주의사항:** 시간 변수(요일, 계절)의 영향을 줄이기 위해 A/B를 같은 요일 구성으로 배치. 예: 월~일(A) → 월~일(B).

---

## 5.5 퍼널 진단 플레이북

### 단계별 이탈률 임계값 & 대응 액션

| 퍼널 단계 | 건강 기준 | 경고 임계값 | 위험 임계값 | 측정 이벤트 |
|----------|----------|-----------|-----------|-----------|
| 설치 → 가입 | 60%+ | 50~60% | <50% | app_installed → signup_completed |
| 가입 → 온보딩 완료 | 70%+ | 55~70% | <55% | signup_completed → onboarding_completed |
| 온보딩 → 첫 룩 재현 | 60%+ | 40~60% | <40% | onboarding_completed → recreation_completed |
| D1 리텐션 | 50%+ | 35~50% | <35% | D1 재방문 |
| D7 리텐션 | 30%+ | 20~30% | <20% | D7 재방문 |
| D30 리텐션 | 15%+ | 8~15% | <8% | D30 재방문 |
| Paywall → 전환 | 8%+ | 4~8% | <4% | paywall_shown → subscription_started |

### 임계값 초과 시 대응 플레이북

| 이탈 구간 | 가능한 원인 | 1순위 실험/개선 | 2순위 대안 |
|----------|-----------|---------------|-----------|
| **설치 → 가입 <50%** | 로그인 마찰, 가치 불명확 | 웰컴 슬라이드 A/B (가치 강조 vs 기능 강조) | 게스트 모드 도입 검토 |
| **가입 → 온보딩 <55%** | 촬영 거부감, 권한 요청 | 촬영 유도 문구 A/B, 갤러리 선택 우선 배치 | "나중에 하기" 후 홈 진입 허용 |
| **온보딩 → 첫 재현 <40%** | 재현 기능 인지 부족 | 온보딩 완료 후 자동 재현 유도 강화 | 샘플 레퍼런스 이미지 제공 |
| **D1 리텐션 <35%** | 첫 경험 만족도 부족 | 룩 재현 결과 품질 개선 (프롬프트 튜닝) | 푸시 알림 D0+1 발송 |
| **D7 리텐션 <20%** | 재방문 동기 부족 | 데일리 코디 추천 푸시 시간대 실험 | 친구 초대 보상 도입 |
| **D30 리텐션 <8%** | 장기 가치 부족 | 코디 캘린더 + 통계 기능 조기 출시 | 월간 스타일 리포트 이메일 |
| **Paywall 전환 <4%** | 무료 충분 or 가격 저항 | 무료 한도 축소 (30→20벌) 실험 | 7일 무료 체험 강조, 가격 A/B |

---

## 6. 도구 선정 & 구현

### 6.1 분석 도구 비교

| 도구 | 무료 범위 | Flutter 지원 | 퍼널/코호트 | 결정 |
|------|----------|-------------|-----------|------|
| **PostHog** | 100만 이벤트/월 | ✅ posthog_flutter | ✅ 퍼널+코호트+세션리플레이 | ✅ **선택** |
| Mixpanel | 2만 MTU/월 | ✅ | ✅ | 유저 초과 시 비용 급증 |
| Amplitude | 1만 MTU/월 | ❌ Flutter 미지원 | ✅ | Flutter 미지원 |
| Firebase Analytics | 무제한 | ✅ | △ 커스텀 퍼널 한계 | 보조 도구로 사용 |

**결정:** PostHog Cloud Free (월 100만 이벤트) + Firebase Analytics (크래시 리포트, 앱스토어 어트리뷰션)

**비용 추정:** 5,000 MAU × 일 10 이벤트 × 30일 = 150만 이벤트/월 → Free 범위 내

### 6.2 Flutter 구현 가이드

```dart
// pubspec.yaml
dependencies:
  posthog_flutter: ^4.0.0

// lib/services/analytics_service.dart
class AnalyticsService {
  static final _posthog = Posthog();

  static Future<void> init() async {
    await _posthog.setup(
      PosthogConfig('phc_YOUR_KEY')
        ..host = 'https://app.posthog.com'
        ..captureApplicationLifecycleEvents = true,
    );
  }

  static void identify(String userId, {Map<String, dynamic>? properties}) {
    _posthog.identify(userId: userId, userProperties: properties);
  }

  static void track(String event, {Map<String, dynamic>? properties}) {
    _posthog.capture(eventName: event, properties: properties);
  }

  // 래퍼 메서드 예시
  static void signupCompleted(String provider) =>
    track('signup_completed', properties: {'provider': provider});

  static void itemRegistered(String source, String category, String colorName) =>
    track('item_registered', properties: {
      'source': source, 'category': category, 'color_name': colorName,
    });

  static void recreationCompleted(int score, int matched, int gaps, int durationSec) =>
    track('recreation_completed', properties: {
      'overall_score': score, 'matched_count': matched,
      'gap_count': gaps, 'duration_sec': durationSec,
    });
}
```

### 6.3 이벤트 심기 체크리스트 (화면별)

| 화면 | 필수 이벤트 |
|------|-----------|
| S01 스플래시 | app_opened |
| S02 소셜 로그인 | signup_completed |
| S03 프로필 설정 | profile_updated |
| S04 촬영 | - (S05에서 결과 추적) |
| S05 아이템 확인/등록 | item_registered, item_registration_failed |
| S06 온보딩 완료 | onboarding_completed |
| S07 옷장 메인 | wardrobe_viewed, wardrobe_limit_hit |
| S08 아이템 상세 | item_edited, item_deleted |
| S09 레퍼런스 선택 | recreation_started |
| S10 AI 분석 중 | - (S11에서 결과 추적) |
| S11 결과 화면 | recreation_completed, recreation_failed, result_viewed |
| S12 만족도 피드백 | recreation_satisfaction |
| S13 공유 | result_shared |
| S14 갭 상세 | gap_deeplink_clicked |
| S15 Paywall | paywall_shown, paywall_dismissed |
| S16 결제 | subscription_started |
| S17 프리미엄 | subscription_cancelled |

---

*본 문서는 PostHog 무료 범위 내에서 1인 개발자가 실행 가능한 수준으로 설계되었습니다.*
