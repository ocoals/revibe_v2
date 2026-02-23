# Plan: F2 - Look Recreation (룩 재현)

> **Feature:** f2-look-recreation
> **Phase:** Plan
> **Created:** 2026-02-23
> **Status:** Draft
> **Related Docs:** [PRD Section 4.2 F2](../../PRD.md), [TDD Sections 4.5~6](../../기술설계문서-TDD.md), [UI/UX Section 3.2](../../UI-UX-설계문서.md)

---

## 1. Feature Overview

### 1.1 Purpose

인플루언서/레퍼런스 이미지의 코디를 사용자의 옷장 아이템으로 재현하는 기능. ClosetIQ의 **핵심 차별 기능**이자 바이럴 포인트.

### 1.2 User Story

- 사용자가 갤러리에서 레퍼런스 이미지를 선택하면, AI가 이미지 속 패션 아이템을 분석하고, 내 옷장에서 가장 유사한 아이템을 매칭하여 결과를 보여준다.
- 매칭되지 않는 아이템은 갭 분석으로 외부 쇼핑 검색 딥링크를 제공한다.

### 1.3 Scope (MVP)

| In Scope | Out of Scope (Phase 2+) |
|----------|------------------------|
| 갤러리에서 이미지 선택 | Share Extension (외부 앱 공유) |
| Claude Haiku API 1회 호출 → 아이템 분석 | 코디 버전 다양화 (3가지) |
| 매칭 엔진 (카테고리 + 색상 CIEDE2000 + 스타일 + 보너스) | 스타일 벡터 분위기 매칭 |
| 결과 나란히 비교 UI | 아이템 스왑 기능 |
| 갭 아이템 + 딥링크 (무신사/에이블리/지그재그) | 체형/퍼스널 컬러 보정 |
| 월 5회 무료 제한 | CPA 커미션 연동 |
| 재현 히스토리 조회 | 이미지 저장/공유 기능 (Tier 2) |

---

## 2. Technical Analysis

### 2.1 Current State

- **Screens:** 4개 stub UI 존재 (ReferenceInputScreen, AnalyzingScreen, ResultScreen, GapAnalysisSheet) — 로직 없음
- **Routes:** `app_router.dart`에 모든 recreation 경로 등록 완료
- **DB:** `look_recreations`, `usage_counters` 테이블 마이그레이션 완료
- **Missing:** Data model, Repository, Providers, Edge Function, 매칭 엔진

### 2.2 Architecture

```
Flutter Client                    Supabase Edge Function
─────────────                     ─────────────────────
1. 이미지 선택 (image_picker)
2. 사용량 체크 (usage_counters)
3. 이미지 업로드 (R2 → presigned) ──→ 4. reference 이미지 저장
                                      5. Claude Haiku API 호출 (1회)
                                      6. 응답 검증 + 파싱
                                      7. 옷장 아이템 DB 쿼리
                                      8. 매칭 엔진 (점수 계산)
                                      9. look_recreations INSERT
                                   ←── 10. 결과 JSON 반환
11. 결과 화면 렌더링
12. 갭 아이템 → 딥링크 생성
```

### 2.3 Dependencies

| Dependency | Status | Notes |
|-----------|--------|-------|
| `image_picker` | Already in pubspec.yaml | 갤러리 이미지 선택 |
| `supabase_flutter` | Already configured | Auth, DB, Storage |
| Supabase Edge Functions | **Not yet set up** | `supabase/functions/` 디렉터리 필요 |
| Claude Haiku API | **API key needed** | Supabase Secrets에 저장 |
| `look_recreations` table | Migration exists | status 컬럼 포함 |
| `usage_counters` table | Migration exists | recreation_count 관리 |
| Wardrobe items data | Fully built | 매칭 대상 데이터 |

---

## 3. Implementation Plan

### Phase 1: Data Layer (Client)

**Priority: High | Complexity: Low**

| # | Task | Files | Description |
|---|------|-------|-------------|
| 1.1 | LookRecreation model 생성 | `lib/features/recreation/data/models/look_recreation.dart` | freezed + json_serializable, DB 스키마 매핑 |
| 1.2 | ReferenceAnalysis model 생성 | `lib/features/recreation/data/models/reference_analysis.dart` | Claude Haiku 응답 JSON → Dart 모델 |
| 1.3 | MatchedItem / GapItem model 생성 | `lib/features/recreation/data/models/matched_item.dart`, `gap_item.dart` | 매칭 결과 + 갭 아이템 모델 |
| 1.4 | RecreationRepository 생성 | `lib/features/recreation/data/recreation_repository.dart` | Supabase 연동 (이미지 업로드, Edge Function 호출, 히스토리 조회) |

### Phase 2: Edge Function (Server)

**Priority: High | Complexity: High**

| # | Task | Files | Description |
|---|------|-------|-------------|
| 2.1 | Edge Function scaffold | `supabase/functions/recreate-analyze/index.ts` | JWT 검증, 요청 파싱 |
| 2.2 | 사용량 체크 로직 | (2.1 내) | usage_counters 조회, 무료 제한 확인 |
| 2.3 | 이미지 저장 | (2.1 내) | R2에 reference 이미지 저장 |
| 2.4 | Claude Haiku API 호출 | `supabase/functions/_shared/claude-client.ts` | 프롬프트 + 이미지 → JSON 응답 |
| 2.5 | 응답 검증 | (2.1 내) | JSON 파싱, category 허용 목록, HSL 범위 검증 |
| 2.6 | 매칭 엔진 구현 | `supabase/functions/_shared/matching-engine.ts` | CIEDE2000 색상 유사도, 카테고리/스타일/보너스 점수 |
| 2.7 | 색상 유틸리티 | `supabase/functions/_shared/color-utils.ts` | RGB→Lab 변환, CIEDE2000 계산 |
| 2.8 | 딥링크 생성 | `supabase/functions/_shared/deeplink-generator.ts` | 무신사/에이블리/지그재그 검색 URL |
| 2.9 | DB 저장 + 응답 조합 | (2.1 내) | look_recreations INSERT, usage_counters UPDATE |
| 2.10 | 히스토리 API | `supabase/functions/recreate-history/index.ts` | GET 히스토리 (페이지네이션) |

### Phase 3: State Management (Client)

**Priority: High | Complexity: Medium**

| # | Task | Files | Description |
|---|------|-------|-------------|
| 3.1 | Recreation providers | `lib/features/recreation/providers/recreation_provider.dart` | recreationProvider, historyProvider |
| 3.2 | Usage counter provider | `lib/features/recreation/providers/usage_provider.dart` | 잔여 횟수, canRecreate 체크 |
| 3.3 | Recreation process notifier | `lib/features/recreation/providers/recreation_process_provider.dart` | StateNotifier: 이미지 선택 → API 호출 → 결과 상태 관리 |

### Phase 4: UI Integration

**Priority: High | Complexity: Medium**

| # | Task | Files | Description |
|---|------|-------|-------------|
| 4.1 | ReferenceInputScreen 연동 | `lib/features/recreation/presentation/reference_input_screen.dart` | image_picker 연결, 사용량 표시, 월 잔여 횟수 |
| 4.2 | AnalyzingScreen 연동 | `lib/features/recreation/presentation/analyzing_screen.dart` | 실제 API 호출 상태 반영, 단계별 진행 애니메이션 |
| 4.3 | ResultScreen 연동 | `lib/features/recreation/presentation/result_screen.dart` | 나란히 비교 레이아웃, 매칭 아이템 목록, 점수 표시 |
| 4.4 | GapAnalysisSheet 연동 | `lib/features/recreation/presentation/gap_analysis_sheet.dart` | 동적 갭 아이템 + 실제 딥링크 |
| 4.5 | 히스토리 UI | `lib/features/recreation/presentation/widgets/recreation_history_card.dart` | ReferenceInputScreen에 히스토리 카드 목록 |

### Phase 5: Error Handling & Edge Cases

**Priority: Medium | Complexity: Medium**

| # | Task | Description |
|---|------|-------------|
| 5.1 | API 실패 처리 | 타임아웃(10s), 재시도(2회), 최종 실패 UI |
| 5.2 | 패션 아이템 미감지 | NO_FASHION_ITEMS 에러 → 안내 다이얼로그 |
| 5.3 | 사용량 한도 초과 | RECREATION_LIMIT_REACHED → 프리미엄 유도 바텀시트 |
| 5.4 | 전체 갭 (매칭 0개) | "아직 매칭되는 아이템이 없어요" + 옷장 추가 CTA |
| 5.5 | 부분 분석 | 일부 아이템만 분석 → 성공한 것만 매칭 + "일부만 분석됨" 배지 |

---

## 4. Matching Engine Spec

### 4.1 Score Breakdown (Total 100)

| Factor | Points | Calculation |
|--------|--------|-------------|
| Category match | 40 | Same category = 40, else 0 (pre-filter) |
| Color similarity | 30 | CIEDE2000 deltaE → 0~30 scale |
| Style tags overlap | 20 | (matching tags / total tags) * 20 |
| Bonus | 10 | Fit(3) + Pattern(3) + Subcategory(4) match |

### 4.2 Threshold

- **>= 50**: Matched (매칭 성공)
- **< 50**: Gap item (갭 아이템 → 딥링크 제공)

### 4.3 Process

```
for each refItem in referenceAnalysis.items:
  1. Filter wardrobe by same category
  2. Exclude already-matched items (prevent duplicates)
  3. Score each candidate (color + style + bonus)
  4. Select highest scorer
  5. >= 50 → matched_items, < 50 → gap_items + deeplinks
```

---

## 5. API Spec (Edge Function)

### POST /recreate/analyze

**Request:** `multipart/form-data` with `reference_image` (JPEG/PNG, max 10MB)

**Response 200:**
```json
{
  "id": "rec-uuid",
  "overall_score": 78,
  "reference_analysis": {
    "items": [{ "index": 0, "category": "tops", "subcategory": "knit", ... }],
    "overall_style": "casual_minimal",
    "occasion": "daily"
  },
  "matched_items": [
    { "ref_index": 0, "wardrobe_item": {...}, "score": 92, "breakdown": {...}, "match_reasons": [...] }
  ],
  "gap_items": [
    { "ref_index": 2, "category": "shoes", "description": "...", "deeplinks": {...} }
  ]
}
```

**Errors:** 400, 403 (RECREATION_LIMIT_REACHED), 408 (AI_TIMEOUT), 422 (NO_FASHION_ITEMS), 502 (AI_ERROR)

---

## 6. Implementation Order

```
Phase 1: Data Layer     ████░░░░░░  ~1 day
Phase 2: Edge Function  ██████████  ~2-3 days (critical path)
Phase 3: Providers      ████░░░░░░  ~1 day
Phase 4: UI Integration ██████░░░░  ~1-2 days
Phase 5: Error Handling ███░░░░░░░  ~0.5 day
                                    ─────────
                        Total:      ~5-7 days
```

**Critical Path:** Phase 2 (Edge Function) — Claude API 연동 + 매칭 엔진이 가장 복잡.

---

## 7. Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Claude Haiku 응답 정확도 부족 | 매칭 품질 저하 | 프롬프트 반복 튜닝, JSON strict mode 사용 |
| CIEDE2000 구현 복잡도 | 개발 지연 | 검증된 npm 라이브러리 활용 (`delta-e`) |
| Edge Function cold start 지연 | UX 저하 (>5초) | 경량 구현, 불필요한 import 최소화 |
| 무료 한도 5회 소진 후 이탈 | 사용자 유실 | 잔여 횟수 명확 표시, 소진 시 부드러운 프리미엄 유도 |

---

## 8. Success Criteria

| Metric | Target |
|--------|--------|
| 레퍼런스 입력 → 결과 표시 | < 5초 |
| AI 분석 성공률 | > 95% |
| 매칭 결과 만족도 | 3.5/5+ |
| 갭 아이템 딥링크 클릭률 | > 20% |
| 월 무료 5회 중 평균 사용 | > 3회 |

---

## 9. File Structure (Expected)

```
lib/features/recreation/
├── data/
│   ├── models/
│   │   ├── look_recreation.dart          (+ .freezed.dart, .g.dart)
│   │   ├── reference_analysis.dart       (+ .freezed.dart, .g.dart)
│   │   ├── matched_item.dart             (+ .freezed.dart, .g.dart)
│   │   └── gap_item.dart                 (+ .freezed.dart, .g.dart)
│   └── recreation_repository.dart
├── providers/
│   ├── recreation_provider.dart
│   ├── usage_provider.dart
│   └── recreation_process_provider.dart
├── presentation/
│   ├── reference_input_screen.dart       (modify)
│   ├── analyzing_screen.dart             (modify)
│   ├── result_screen.dart                (modify)
│   ├── gap_analysis_sheet.dart           (modify)
│   └── widgets/
│       ├── recreation_history_card.dart
│       ├── matched_item_card.dart
│       └── gap_item_card.dart

supabase/functions/
├── _shared/
│   ├── claude-client.ts
│   ├── matching-engine.ts
│   ├── color-utils.ts
│   └── deeplink-generator.ts
├── recreate-analyze/
│   └── index.ts
└── recreate-history/
    └── index.ts
```
