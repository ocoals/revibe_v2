# F5 데일리 코디 기록 — "오늘 뭐 입었어?"

## 1. 목적

일일 리텐션 핵심 기능. 매일 코디를 기록하면서 옷장이 자연스럽게 확장된다.
홈 화면의 "기록" 빠른 액션 버튼(현재 TODO)을 연결하고, 캘린더 뷰로 기록을 시각화한다.

## 2. 사용자 흐름

```
홈 → "기록" 탭
  │
  ├── [지금 촬영] → 전신 사진 → AI 아이템 인식
  │     ├── 기존 옷장 아이템 매칭 → 착용 기록(wear_count, last_worn_at) 업데이트
  │     └── 새 아이템 발견 → "옷장에 추가할까요?" 제안
  │
  └── [옷장에서 선택] → 아이템 그리드 (다중 선택)
        └── 선택 완료 → 코디 기록 저장

  → S15 코디 캘린더: 월간 캘린더 뷰, 기록 일자에 도트 표시
     이번 달 통계: 기록 일수 | 활용 아이템 수 | 미착용 아이템
     날짜 탭 → 해당 일자 코디 상세
```

## 3. 기술 요구사항

### 3.1 DB 테이블 (TDD 기반)

```sql
-- daily_outfits: 날짜별 코디 기록
CREATE TABLE public.daily_outfits (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  outfit_date DATE NOT NULL,
  image_url   TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, outfit_date)
);

-- outfit_items: 코디에 포함된 아이템들 (N:M)
CREATE TABLE public.outfit_items (
  outfit_id UUID NOT NULL REFERENCES daily_outfits(id) ON DELETE CASCADE,
  item_id   UUID NOT NULL REFERENCES wardrobe_items(id) ON DELETE CASCADE,
  position  INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (outfit_id, item_id)
);

-- RLS
ALTER TABLE public.daily_outfits ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own data" ON public.daily_outfits FOR ALL USING (auth.uid() = user_id);
ALTER TABLE public.outfit_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own outfit items" ON public.outfit_items FOR ALL
  USING (outfit_id IN (SELECT id FROM daily_outfits WHERE user_id = auth.uid()));
```

### 3.2 API

- `POST /outfit/daily` — Body: `{ "outfit_date": "2026-02-21", "item_ids": ["uuid",...], "image_url": "...", "notes": "..." }`
- `GET /daily_outfits` — 월별 조회 (user_id + date range 필터)

### 3.3 아이템 착용 기록 업데이트

코디 기록 저장 시, 포함된 wardrobe_items의:
- `wear_count` += 1
- `last_worn_at` = outfit_date

## 4. 입력 경로 2가지

### 경로 A: 사진 촬영

1. image_picker로 카메라/갤러리 선택
2. `onboarding-analyze` Edge Function 재사용 (AI 아이템 감지)
3. 감지된 아이템을 옷장 기존 아이템과 매칭:
   - 같은 카테고리 + 유사 색상 → "이 아이템인가요?" 매칭 제안
   - 매칭 실패 → "새 아이템이에요. 옷장에 추가할까요?" 제안
4. 확인 → 코디 기록 저장

### 경로 B: 옷장에서 선택

1. 옷장 아이템 그리드 표시 (다중 선택 모드)
2. 카테고리 필터 지원
3. 선택 완료 → 코디 기록 저장 (사진 없음)

## 5. 화면 구성

### S14: 데일리 코디 기록 화면
- "오늘 뭐 입었어?" 헤더
- 날짜 선택 (기본: 오늘, 과거 날짜 선택 가능)
- [지금 촬영] + [옷장에서 선택] 버튼
- 선택된 아이템 리스트
- 메모 입력 (선택)
- [기록 저장] CTA

### S15: 코디 캘린더 화면
- 월간 캘린더 (기록 있는 날짜에 도트)
- 이번 달 통계 카드: 기록 일수, 활용 아이템 수
- 날짜 탭 → 해당 일자 코디 상세 바텀시트

## 6. 구현 순서

| Step | 내용 | 파일 |
|------|------|------|
| 1 | DB 마이그레이션 (daily_outfits + outfit_items + RLS) | `supabase/migrations/` |
| 2 | DailyOutfit Freezed 모델 | `lib/features/daily/data/models/` |
| 3 | DailyRepository (CRUD + 착용 기록 업데이트) | `lib/features/daily/data/` |
| 4 | DailyProvider (기록 상태 관리) | `lib/features/daily/providers/` |
| 5 | DailyRecordScreen (S14 — 입력 화면) | `lib/features/daily/presentation/` |
| 6 | WardrobePickerScreen (다중 선택 그리드) | `lib/features/daily/presentation/` |
| 7 | CalendarScreen (S15 — 캘린더 뷰) | `lib/features/daily/presentation/` |
| 8 | 홈 화면 "기록" 버튼 연결 + 라우터 등록 | `lib/features/home/`, `app_router.dart` |
| 9 | flutter analyze + 테스트 | — |

## 7. 외부 패키지

- `table_calendar` (캘린더 UI) — 이미 Flutter 생태계에서 가장 많이 사용

## 8. MVP 범위

### 포함
- 옷장에서 아이템 선택 → 코디 기록 (경로 B)
- 캘린더 뷰 (기록 표시 + 날짜별 상세)
- 착용 기록 업데이트 (wear_count, last_worn_at)
- 홈 "기록" 버튼 연결
- 메모 입력

### 후순위 (Phase 2)
- 사진 촬영 → AI 매칭 (경로 A) — onboarding-analyze 재사용 가능하나 매칭 로직 추가 필요
- 새 아이템 자동 추가 제안
- 이번 달 통계 (활용 아이템 수, 미착용 아이템)
- 코디 사진 첨부 + Storage 업로드

## 9. 검증 기준

1. `flutter analyze` 에러 없음
2. 옷장에서 아이템 선택 → 코디 기록 저장 → 캘린더에 도트 표시
3. 기록 저장 시 wardrobe_items.wear_count 증가 확인
4. 캘린더에서 날짜 탭 → 해당 코디 상세 표시
5. 홈 "기록" 버튼 → DailyRecordScreen 이동
