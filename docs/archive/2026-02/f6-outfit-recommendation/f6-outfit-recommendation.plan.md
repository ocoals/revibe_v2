# F6 기본 코디 추천 — "오늘 뭐 입지?"

> **Feature:** f6-outfit-recommendation
> **Phase:** Plan
> **Created:** 2026-02-23
> **Status:** Draft
> **Related Docs:** [PRD Section 4.3 F6](../../PRD.md), [TDD](../../기술설계문서-TDD.md)

---

## 1. 목적

매일 아침 옷 앞에서 고민하는 시간을 줄여주는 코디 추천 기능.
날씨와 착용 이력 기반으로 **상의 + 하의 + (아우터)** 조합 1개를 제안한다.
AI 호출 없이 규칙 기반 로직으로 동작하여 비용 0원.

**타겟 페르소나:** 세그먼트 B (출근 코디 고민러, 20대 후반~30대 초반 직장 여성)

## 2. 사용자 흐름

```
홈 화면
  │
  ├── "오늘의 추천 코디" 카드 (자동 표시)
  │     ├── 날씨 정보 (기온, 날씨 아이콘)
  │     ├── 추천 아이템 조합 (상의 + 하의 + 아우터?)
  │     ├── [이 코디 입을래요] → 데일리 기록에 자동 저장
  │     ├── [다른 추천 보기] → 다음 조합 표시
  │     └── [직접 고를래요] → 데일리 기록 화면 이동
  │
  └── 추천 상세 화면 (카드 탭 시)
        ├── 추천 근거 표시 ("기온 5°C → 아우터 추천", "14일 미착용")
        ├── 아이템별 카드 (이미지 + 이름 + 마지막 착용일)
        └── [기록하기] CTA
```

## 3. 추천 알고리즘 (규칙 기반)

### 3.1 입력 데이터

| 데이터 | 출처 | 용도 |
|--------|------|------|
| 현재 기온 (°C) | 날씨 API | 시즌/아우터 판단 |
| 강수 확률 (%) | 날씨 API | 우천 시 소재 고려 |
| 옷장 아이템 목록 | wardrobe_items | 추천 후보 |
| 착용 이력 | wear_count, last_worn_at | 오래 안 입은 옷 우선 |
| 최근 코디 기록 | daily_outfits (최근 7일) | 중복 회피 |

### 3.2 추천 로직

```
Step 1: 시즌 필터링
  - 기온 기반 시즌 매핑:
    · >= 28°C → summer
    · >= 20°C → spring/fall
    · >= 10°C → fall
    · < 10°C → winter
  - wardrobe_items.season에 해당 시즌 포함하는 아이템만 후보

Step 2: 카테고리별 후보 선정
  - 필수: tops (상의) + bottoms (하의)
  - 조건부: outerwear (기온 < 15°C일 때)
  - 선택: shoes, accessories (Phase 2)

Step 3: 착용 점수 계산 (각 아이템)
  score = freshness_score + variety_score

  freshness_score (0~50):
    - 한 번도 안 입은 아이템: 50
    - days_since_last_worn / 30 * 50 (최대 50)

  variety_score (0~30):
    - 최근 7일 코디에 포함되지 않은 아이템: 30
    - 최근 7일 중 1회 포함: 10
    - 최근 7일 중 2회 이상: 0

  random_bonus (0~20):
    - 매번 같은 추천 방지용 랜덤 보너스

Step 4: 조합 생성
  - tops에서 최고 점수 아이템 선택
  - bottoms에서 최고 점수 아이템 선택
  - outerwear에서 최고 점수 아이템 선택 (해당 시)
  - 색상 충돌 체크: 동일 색상 계열 3개 이상이면 차순위로 교체

Step 5: 대체 조합 (다른 추천)
  - 각 카테고리에서 2~3순위 아이템 보관
  - "다른 추천" 시 차순위 조합 표시
  - 최대 3개 조합 생성
```

### 3.3 기온 → 시즌 매핑 테이블

| 기온 범위 | 시즌 | 아우터 필요 | 참고 |
|-----------|------|:----------:|------|
| >= 28°C | summer | X | 반팔/반바지 추천 |
| 20~27°C | spring, fall | X | 긴팔/얇은 소재 |
| 15~19°C | spring, fall | △ (선택) | 가디건/얇은 자켓 |
| 10~14°C | fall, winter | O | 자켓/코트 |
| 5~9°C | winter | O | 두꺼운 아우터 |
| < 5°C | winter | O | 패딩/헤비 아우터 |

## 4. 기술 요구사항

### 4.1 날씨 API

| 항목 | 선택 |
|------|------|
| API | OpenWeatherMap (Free tier) |
| 엔드포인트 | Current Weather API |
| 무료 한도 | 1,000 calls/day (충분) |
| 필요 데이터 | temp (°C), weather_id (날씨 코드), rain probability |
| 위치 | 기기 위치 또는 사용자 설정 도시 |
| 캐싱 | 30분 캐시 (불필요한 API 호출 방지) |

### 4.2 DB 변경사항

기존 테이블 활용, **새 테이블 불필요**.

- `wardrobe_items`: season, wear_count, last_worn_at 이미 존재
- `daily_outfits` + `outfit_items`: 최근 착용 이력 조회용
- (선택) `user_preferences` 테이블: 사용자 도시 설정 저장

```sql
-- 선택: 사용자 설정 (도시, 추천 선호도)
-- profiles 테이블에 컬럼 추가로 대체 가능
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS preferred_city TEXT DEFAULT 'Seoul',
  ADD COLUMN IF NOT EXISTS preferred_style TEXT DEFAULT 'casual';
```

### 4.3 외부 패키지

| 패키지 | 용도 | 상태 |
|--------|------|------|
| `geolocator` | 기기 위치 정보 | 신규 추가 필요 |
| `http` 또는 `dio` | 날씨 API 호출 | http는 Flutter 기본 / dio 추가 가능 |
| `flutter_riverpod` | 상태 관리 | 이미 설치됨 |

## 5. 화면 구성

### S16: 홈 추천 코디 카드 (홈 화면 삽입)

- 날씨 아이콘 + 기온 + 도시명
- 추천 아이템 가로 배치 (상의 | 하의 | 아우터)
- 각 아이템: 배경 제거 이미지 + 카테고리 라벨
- 추천 근거 뱃지 ("14일 미착용", "오늘 날씨에 딱!")
- CTA 버튼: [이 코디로 기록] / [다른 추천]

### S17: 추천 상세 화면 (선택, Phase 2에서 구현 가능)

- 추천 아이템 상세 카드
- 추천 이유 상세 설명
- 아이템 교체 기능 (Phase 2)

## 6. 구현 순서

| Step | 내용 | 파일 |
|------|------|------|
| 1 | WeatherService (API 연동 + 캐싱) | `lib/core/services/weather_service.dart` |
| 2 | WeatherModel (기온, 날씨 코드, 아이콘) | `lib/core/models/weather.dart` |
| 3 | OutfitRecommendationEngine (규칙 기반 추천 로직) | `lib/features/recommendation/data/recommendation_engine.dart` |
| 4 | RecommendationResult 모델 (추천 조합 + 근거) | `lib/features/recommendation/data/models/recommendation_result.dart` |
| 5 | RecommendationProvider (상태 관리) | `lib/features/recommendation/providers/recommendation_provider.dart` |
| 6 | RecommendedOutfitCard 위젯 (홈 화면 카드) | `lib/features/recommendation/presentation/widgets/recommended_outfit_card.dart` |
| 7 | 홈 화면에 추천 카드 삽입 | `lib/features/home/presentation/home_screen.dart` |
| 8 | "이 코디로 기록" → DailyRepository 연동 | Provider + Repository 연결 |
| 9 | flutter analyze + 검증 | — |

## 7. MVP 범위

### 포함

- 날씨 API 연동 (OpenWeatherMap Free)
- 기온 기반 시즌 필터링
- 착용 이력 기반 추천 점수 계산
- 상의 + 하의 + (아우터) 조합 1개 추천
- 홈 화면 추천 카드 UI
- "이 코디로 기록" → 데일리 기록 자동 저장
- "다른 추천" (최대 3개 조합)

### 후순위 (Phase 2)

- 추천 상세 화면 (S17)
- 아이템 교체 기능 (특정 아이템만 바꾸기)
- 색상 조화 알고리즘 (보색/유사색 매칭)
- 스타일 태그 기반 추천 (캐주얼/포멀/스트릿)
- 날씨별 소재 추천 (비 오는 날 가죽 회피 등)
- 추천 코디 실착률 피드백 루프
- 사용자 선호 스타일 학습

## 8. 검증 기준

1. `flutter analyze` 에러 없음
2. 날씨 API 정상 호출 + 캐싱 동작
3. 옷장 아이템 >= 2개일 때 추천 조합 생성
4. 오래 안 입은 아이템이 우선 추천되는지 확인
5. 기온에 따라 아우터 포함/제외 정상 동작
6. "이 코디로 기록" → daily_outfits에 저장
7. "다른 추천" → 다른 조합 표시
8. 옷장 비어있을 때 빈 상태 UI 표시

## 9. 파일 구조 (Expected)

```
lib/features/recommendation/
├── data/
│   ├── models/
│   │   └── recommendation_result.dart     (+ .freezed.dart, .g.dart)
│   └── recommendation_engine.dart
├── providers/
│   └── recommendation_provider.dart
└── presentation/
    └── widgets/
        └── recommended_outfit_card.dart

lib/core/services/
└── weather_service.dart

lib/core/models/
└── weather.dart
```

## 10. 리스크 & 대응

| 리스크 | 영향 | 대응 |
|--------|------|------|
| 위치 권한 거부 | 날씨 데이터 없음 | 기본 도시(서울) 폴백 |
| 옷장 아이템 부족 (< 2개) | 추천 불가 | "옷장에 아이템을 추가해주세요" 안내 |
| 날씨 API 장애/한도 초과 | 기온 데이터 없음 | 시즌 필터 없이 착용 이력만으로 추천 |
| 추천 다양성 부족 | 매번 같은 조합 | random_bonus로 변화 부여 |
| 색상 부조화 조합 | UX 불만족 | 동일 색상 3개 이상 시 차순위 교체 |
