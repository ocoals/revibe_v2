# Design: F5 - Daily Outfit Record (데일리 코디 기록)

> **Feature:** f5-daily-record
> **Phase:** Design
> **Created:** 2026-02-23
> **Status:** Draft
> **Plan Reference:** [f5-daily-record.plan.md](../../01-plan/features/f5-daily-record.plan.md)

---

## 1. Data Models (Client - Dart)

All models follow the existing `WardrobeItem` pattern: `@freezed` + `@JsonKey(name:)` for snake_case DB mapping.

### 1.1 DailyOutfit

```dart
// lib/features/daily/data/models/daily_outfit.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_outfit.freezed.dart';
part 'daily_outfit.g.dart';

@freezed
class DailyOutfit with _$DailyOutfit {
  const factory DailyOutfit({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'outfit_date') required DateTime outfitDate,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _DailyOutfit;

  factory DailyOutfit.fromJson(Map<String, dynamic> json) =>
      _$DailyOutfitFromJson(json);
}
```

### 1.2 OutfitItem (Junction)

```dart
// lib/features/daily/data/models/outfit_item.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'outfit_item.freezed.dart';
part 'outfit_item.g.dart';

@freezed
class OutfitItem with _$OutfitItem {
  const factory OutfitItem({
    @JsonKey(name: 'outfit_id') required String outfitId,
    @JsonKey(name: 'item_id') required String itemId,
    @Default(0) int position,
  }) = _OutfitItem;

  factory OutfitItem.fromJson(Map<String, dynamic> json) =>
      _$OutfitItemFromJson(json);
}
```

### 1.3 DailyOutfitWithItems (Joined View)

```dart
// lib/features/daily/data/models/daily_outfit_with_items.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../wardrobe/data/models/wardrobe_item.dart';
import 'daily_outfit.dart';

part 'daily_outfit_with_items.freezed.dart';
part 'daily_outfit_with_items.g.dart';

@freezed
class DailyOutfitWithItems with _$DailyOutfitWithItems {
  const factory DailyOutfitWithItems({
    required DailyOutfit outfit,
    @Default([]) List<WardrobeItem> items,
  }) = _DailyOutfitWithItems;

  factory DailyOutfitWithItems.fromJson(Map<String, dynamic> json) =>
      _$DailyOutfitWithItemsFromJson(json);
}
```

---

## 2. Database Schema

Plan 문서의 3.1절 SQL을 그대로 사용한다.

```sql
-- supabase/migrations/20260223100000_create_daily_outfits.sql

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
CREATE POLICY "Users manage own daily outfits"
  ON public.daily_outfits FOR ALL
  USING (auth.uid() = user_id);

ALTER TABLE public.outfit_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own outfit items"
  ON public.outfit_items FOR ALL
  USING (outfit_id IN (SELECT id FROM daily_outfits WHERE user_id = auth.uid()));

-- Index for calendar queries
CREATE INDEX idx_daily_outfits_user_date
  ON public.daily_outfits (user_id, outfit_date);
```

### Entity Relationships

```
[User] 1 ──── N [DailyOutfit]    (user_id)
                    │
                    └── N:M ──── [WardrobeItem]   (via outfit_items)
```

---

## 3. Repository (Client)

```dart
// lib/features/daily/data/daily_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
import '../../wardrobe/data/models/wardrobe_item.dart';
import 'models/daily_outfit.dart';
import 'models/daily_outfit_with_items.dart';

class DailyRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  static const _outfitTable = 'daily_outfits';
  static const _itemsTable = 'outfit_items';
  static const _wardrobeTable = 'wardrobe_items';

  /// Save a daily outfit record with selected items.
  /// Uses upsert on (user_id, outfit_date) to allow editing same day.
  /// Also increments wear_count and updates last_worn_at for each item.
  Future<DailyOutfit> saveOutfit({
    required DateTime date,
    required List<String> itemIds,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser!.id;
    final dateStr = _formatDate(date);

    // 1. Upsert daily_outfits record
    final outfitData = await _client
        .from(_outfitTable)
        .upsert(
          {
            'user_id': userId,
            'outfit_date': dateStr,
            'notes': notes,
          },
          onConflict: 'user_id,outfit_date',
        )
        .select()
        .single();

    final outfitId = outfitData['id'] as String;

    // 2. Delete existing outfit_items for this outfit (replace all)
    await _client.from(_itemsTable).delete().eq('outfit_id', outfitId);

    // 3. Insert new outfit_items
    if (itemIds.isNotEmpty) {
      final itemRows = itemIds.asMap().entries.map((e) => {
        return {
          'outfit_id': outfitId,
          'item_id': e.value,
          'position': e.key,
        };
      }).toList();
      await _client.from(_itemsTable).insert(itemRows);
    }

    // 4. Update wardrobe_items: wear_count +1, last_worn_at = outfit_date
    for (final itemId in itemIds) {
      await _client.rpc('increment_wear_count', params: {
        'p_item_id': itemId,
        'p_worn_date': dateStr,
      });
    }

    return DailyOutfit.fromJson(outfitData);
  }

  /// Fetch all daily outfits for a given month (for calendar view).
  /// Returns list of DailyOutfit (without joined items, for dots display).
  Future<List<DailyOutfit>> fetchMonthOutfits({
    required int year,
    required int month,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final endDate = month == 12
        ? '${year + 1}-01-01'
        : '$year-${(month + 1).toString().padLeft(2, '0')}-01';

    final data = await _client
        .from(_outfitTable)
        .select()
        .eq('user_id', userId)
        .gte('outfit_date', startDate)
        .lt('outfit_date', endDate)
        .order('outfit_date', ascending: true);

    return data.map((json) => DailyOutfit.fromJson(json)).toList();
  }

  /// Fetch a single outfit with its wardrobe items (for detail view).
  Future<DailyOutfitWithItems?> fetchOutfitWithItems({
    required DateTime date,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final dateStr = _formatDate(date);

    // Fetch outfit
    final outfitData = await _client
        .from(_outfitTable)
        .select()
        .eq('user_id', userId)
        .eq('outfit_date', dateStr)
        .maybeSingle();

    if (outfitData == null) return null;

    final outfit = DailyOutfit.fromJson(outfitData);

    // Fetch joined items
    final itemsData = await _client
        .from(_itemsTable)
        .select('item_id, position, $_wardrobeTable(*)')
        .eq('outfit_id', outfit.id)
        .order('position', ascending: true);

    final items = itemsData
        .map((row) =>
            WardrobeItem.fromJson(row[_wardrobeTable] as Map<String, dynamic>))
        .toList();

    return DailyOutfitWithItems(outfit: outfit, items: items);
  }

  /// Delete a daily outfit record.
  Future<void> deleteOutfit(String outfitId) async {
    await _client.from(_outfitTable).delete().eq('id', outfitId);
    // outfit_items cascade deleted automatically
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

### 3.1 RPC Function for Wear Count

```sql
-- supabase/migrations/20260223100000_create_daily_outfits.sql (append)

-- RPC: increment wear_count and update last_worn_at atomically
CREATE OR REPLACE FUNCTION public.increment_wear_count(
  p_item_id UUID,
  p_worn_date DATE
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.wardrobe_items
  SET
    wear_count = wear_count + 1,
    last_worn_at = GREATEST(last_worn_at, p_worn_date::TIMESTAMPTZ),
    updated_at = now()
  WHERE id = p_item_id
    AND user_id = auth.uid();
END;
$$;
```

---

## 4. Providers (Client - Riverpod)

### 4.1 Daily Repository Provider

```dart
// lib/features/daily/providers/daily_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/daily_repository.dart';
import '../data/models/daily_outfit.dart';
import '../data/models/daily_outfit_with_items.dart';

/// Repository singleton
final dailyRepositoryProvider = Provider<DailyRepository>((ref) {
  return DailyRepository();
});

/// Monthly outfits for calendar (dots display)
/// Parameter: "YYYY-MM" format string
final monthlyOutfitsProvider =
    FutureProvider.family<List<DailyOutfit>, String>((ref, monthKey) async {
  final repo = ref.watch(dailyRepositoryProvider);
  final parts = monthKey.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  return repo.fetchMonthOutfits(year: year, month: month);
});

/// Single outfit with items for a specific date
/// Parameter: "YYYY-MM-DD" format string
final outfitByDateProvider =
    FutureProvider.family<DailyOutfitWithItems?, String>((ref, dateStr) async {
  final repo = ref.watch(dailyRepositoryProvider);
  final date = DateTime.parse(dateStr);
  return repo.fetchOutfitWithItems(date: date);
});
```

### 4.2 Selected Date Provider

```dart
// lib/features/daily/providers/daily_provider.dart (continued)

/// Currently selected date on the calendar
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Currently focused month on the calendar
final focusedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
```

### 4.3 Daily Record Form Provider (State Machine)

```dart
// lib/features/daily/providers/daily_record_form_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wardrobe/data/models/wardrobe_item.dart';
import '../data/daily_repository.dart';
import 'daily_provider.dart';

/// Form state for creating/editing a daily record
class DailyRecordFormState {
  final DateTime date;
  final List<WardrobeItem> selectedItems;
  final String notes;
  final bool isSaving;
  final String? errorMessage;

  const DailyRecordFormState({
    required this.date,
    this.selectedItems = const [],
    this.notes = '',
    this.isSaving = false,
    this.errorMessage,
  });

  DailyRecordFormState copyWith({
    DateTime? date,
    List<WardrobeItem>? selectedItems,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DailyRecordFormState(
      date: date ?? this.date,
      selectedItems: selectedItems ?? this.selectedItems,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class DailyRecordFormNotifier extends StateNotifier<DailyRecordFormState> {
  DailyRecordFormNotifier(this._ref, DateTime initialDate)
      : super(DailyRecordFormState(date: initialDate));

  final Ref _ref;

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void toggleItem(WardrobeItem item) {
    final current = List<WardrobeItem>.from(state.selectedItems);
    final index = current.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(item);
    }
    state = state.copyWith(selectedItems: current);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Load existing record for editing
  void loadExisting(List<WardrobeItem> items, String? notes) {
    state = state.copyWith(
      selectedItems: items,
      notes: notes ?? '',
    );
  }

  /// Save the daily record
  Future<bool> save() async {
    if (state.selectedItems.isEmpty) {
      state = state.copyWith(errorMessage: '아이템을 1개 이상 선택해주세요');
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final repo = _ref.read(dailyRepositoryProvider);
      await repo.saveOutfit(
        date: state.date,
        itemIds: state.selectedItems.map((i) => i.id).toList(),
        notes: state.notes.isEmpty ? null : state.notes,
      );

      // Invalidate calendar and detail providers
      final monthKey =
          '${state.date.year}-${state.date.month.toString().padLeft(2, '0')}';
      final dateKey =
          '${state.date.year}-${state.date.month.toString().padLeft(2, '0')}-${state.date.day.toString().padLeft(2, '0')}';
      _ref.invalidate(monthlyOutfitsProvider(monthKey));
      _ref.invalidate(outfitByDateProvider(dateKey));

      // Also invalidate wardrobe items (wear_count changed)
      // Assumes wardrobeItemsProvider exists in wardrobe feature
      _ref.invalidate(wardrobeItemsProvider);

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: '저장에 실패했어요. 다시 시도해주세요.',
      );
      return false;
    }
  }
}

/// Provider factory - takes initial date as parameter
final dailyRecordFormProvider = StateNotifierProvider.autoDispose
    .family<DailyRecordFormNotifier, DailyRecordFormState, DateTime>(
  (ref, date) => DailyRecordFormNotifier(ref, date),
);
```

---

## 5. UI Design

### 5.1 S14 - DailyRecordScreen (입력 화면)

**Layout:**
```
┌──────────────────────────────┐
│ ← 오늘 뭐 입었어?             │  ← AppBar
├──────────────────────────────┤
│ 📅 2026년 2월 23일 (일)  [변경] │  ← 날짜 선택 (기본: 오늘)
├──────────────────────────────┤
│ 어떻게 기록할까요?             │
│                              │
│ ┌──────────┐ ┌──────────┐   │
│ │ 👕       │ │ 📷       │   │
│ │ 옷장에서  │ │ 지금 촬영 │   │  ← MVP: 옷장만 활성
│ │  선택     │ │ (곧 지원) │   │     Phase 2: 촬영
│ └──────────┘ └──────────┘   │
├──────────────────────────────┤
│ 선택된 아이템 (3)             │  ← 선택 후 표시
│ ┌────┐ ┌────┐ ┌────┐       │
│ │ 🖼 │ │ 🖼 │ │ 🖼 │       │  ← 수평 스크롤
│ │ ✕  │ │ ✕  │ │ ✕  │       │     탭하면 제거
│ └────┘ └────┘ └────┘       │
├──────────────────────────────┤
│ 메모 (선택)                   │
│ ┌────────────────────────┐   │
│ │ 오늘은 캐주얼하게...     │   │  ← TextField, maxLines: 3
│ └────────────────────────┘   │
├──────────────────────────────┤
│ [       기록 저장       ]     │  ← Primary CTA
└──────────────────────────────┘
```

**Key behaviors:**
- `ConsumerWidget` watching `dailyRecordFormProvider(selectedDate)`
- 날짜 변경: `showDatePicker` → 오늘 이전 날짜만 선택 가능
- "옷장에서 선택" 탭 → `context.push('/daily-record/pick-items')` → WardrobePickerScreen
- "지금 촬영" → disabled 상태 + "곧 지원" 텍스트 (Phase 2)
- 선택된 아이템 제거: `formNotifier.toggleItem(item)`
- 저장 성공 → `context.pop()` (캘린더로 복귀)
- 아이템 0개 시 저장 버튼 disabled

### 5.2 WardrobePickerScreen (다중 선택 그리드)

**Layout:**
```
┌──────────────────────────────┐
│ ← 아이템 선택       [완료 (3)] │  ← AppBar
├──────────────────────────────┤
│ [전체] [상의] [하의] [아우터]  │  ← 카테고리 필터 (horizontal chips)
│ [원피스] [신발] [가방] [액세]  │
├──────────────────────────────┤
│ ┌──────┐ ┌──────┐ ┌──────┐ │
│ │ 🖼   │ │ 🖼 ✓│ │ 🖼   │ │  ← GridView.builder (3 columns)
│ │니트   │ │셔츠  │ │자켓  │ │     selected: 체크마크 overlay
│ └──────┘ └──────┘ └──────┘ │     + 파란 테두리
│ ┌──────┐ ┌──────┐ ┌──────┐ │
│ │ 🖼   │ │ 🖼 ✓│ │ 🖼   │ │
│ │팬츠   │ │스커트│ │운동화│ │
│ └──────┘ └──────┘ └──────┘ │
└──────────────────────────────┘
```

**Key behaviors:**
- `ConsumerWidget` watching `wardrobeItemsProvider` (기존 옷장 프로바이더 재사용)
- 카테고리 필터: `StateProvider<String?>` (null = 전체)
- 아이템 탭 → `formNotifier.toggleItem(item)` (toggle selection)
- 이미 선택된 아이템은 체크마크 + primary 색상 테두리
- AppBar "완료" 버튼 → `context.pop()` (DailyRecordScreen으로 복귀)
- 완료 버튼에 선택 개수 표시
- `CachedNetworkImage` 사용 (기존 패턴)

### 5.3 S15 - CalendarScreen (캘린더 뷰)

**Layout:**
```
┌──────────────────────────────┐
│ 코디 기록                     │  ← AppBar (또는 탭 제목)
├──────────────────────────────┤
│      ◀  2026년 2월  ▶        │  ← 월 네비게이션
│ 일  월  화  수  목  금  토    │
│                         1    │
│  2   3   4   5   6   7   8   │
│  9  10  11  12  13  14  15   │
│ 16  17  18  19  20  21• 22•  │  ← 기록 있는 날: • 도트
│ 23• 24  25  26  27  28       │     선택된 날: 파란 원
├──────────────────────────────┤
│ 2월 23일 (일) 코디            │  ← 선택한 날짜의 상세
│ ┌──────────────────────────┐ │
│ │ [🖼] [🖼] [🖼]           │ │  ← 아이템 이미지 가로 스크롤
│ │ 오늘은 캐주얼하게...      │ │  ← 메모
│ │              [수정] [삭제]│ │
│ └──────────────────────────┘ │
│                              │
│ (기록 없는 날 선택 시)         │
│ "이 날의 코디를 기록해보세요"  │
│ [       기록하기       ]      │  ← DailyRecordScreen으로 이동
├──────────────────────────────┤
│ (+) 오늘 기록하기              │  ← FAB (오늘 기록이 없을 때만)
└──────────────────────────────┘
```

**Key behaviors:**
- `ConsumerWidget`
- `table_calendar` 패키지 사용 (월간 뷰)
- `monthlyOutfitsProvider(monthKey)` 로 해당 월의 기록된 날짜 목록 로드
- 기록 있는 날짜에 도트 마커 표시 (CalendarBuilders.markerBuilder)
- 날짜 선택 → `selectedDateProvider` 업데이트 → 하단에 해당 날짜 상세 표시
- 상세 표시: `outfitByDateProvider(dateStr)` 로 아이템 포함 상세 로드
- "기록하기" / "수정" → `context.push('/daily-record/create?date=YYYY-MM-DD')`
- "삭제" → 확인 다이얼로그 → `dailyRepository.deleteOutfit()` → invalidate providers
- FAB "오늘 기록하기" → `context.push('/daily-record/create')`
- 월 변경 시 → `focusedMonthProvider` 업데이트 → monthlyOutfitsProvider 자동 로드

---

## 6. Navigation Flow

```
홈 화면 "기록" 버튼
  │
  ▼
CalendarScreen ('/daily-record')     ← 메인 진입점 (캘린더 뷰)
  │
  ├── 날짜 선택 → 하단 상세 표시 (inline)
  │     ├── [수정] → DailyRecordScreen (with date param)
  │     └── [삭제] → 확인 → 삭제
  │
  ├── [기록하기] 또는 FAB
  │     ▼
  │   DailyRecordScreen ('/daily-record/create?date=2026-02-23')
  │     │
  │     ├── [옷장에서 선택]
  │     │     ▼
  │     │   WardrobePickerScreen ('/daily-record/pick-items')
  │     │     │ [완료]
  │     │     ▼
  │     │   context.pop() → DailyRecordScreen (선택 반영됨)
  │     │
  │     └── [기록 저장]
  │           ▼
  │         saveOutfit() → context.pop() → CalendarScreen (갱신됨)
  │
  └── ◀ ▶ 월 변경 → monthlyOutfitsProvider 리로드
```

### 6.1 Route Registration

```dart
// lib/core/router/app_router.dart (additions)

// Add to AppRoutes class:
static const dailyRecord = '/daily-record';
static const dailyRecordCreate = '/daily-record/create';
static const dailyRecordPickItems = '/daily-record/pick-items';

// Add routes (outside ShellRoute, stack navigation):
GoRoute(
  path: AppRoutes.dailyRecord,
  builder: (context, state) => const CalendarScreen(),
),
GoRoute(
  path: AppRoutes.dailyRecordCreate,
  builder: (context, state) {
    final dateStr = state.uri.queryParameters['date'];
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    return DailyRecordScreen(initialDate: date);
  },
),
GoRoute(
  path: AppRoutes.dailyRecordPickItems,
  builder: (context, state) {
    final date = state.extra as DateTime;
    return WardrobePickerScreen(date: date);
  },
),
```

### 6.2 Home Screen Integration

```dart
// lib/features/home/presentation/home_screen.dart
// Update the "기록" QuickActionButton:
_QuickActionButton(
  icon: Icons.edit_note,
  label: '기록',
  onTap: () {
    context.push(AppRoutes.dailyRecord);
  },
),
```

---

## 7. Error Handling

| Error | Trigger | User Message | UI Action |
|-------|---------|-------------|-----------|
| 아이템 미선택 | 0개로 저장 시도 | "아이템을 1개 이상 선택해주세요" | 스낵바 표시 |
| 네트워크 오류 | 저장/로드 실패 | "저장에 실패했어요. 다시 시도해주세요." | 스낵바 + 재시도 |
| 인증 만료 | 401 응답 | (자동 리다이렉트) | 로그인 화면 |
| 중복 날짜 | upsert 처리 | (기존 기록 덮어쓰기) | 수정 확인 다이얼로그 |

---

## 8. Dependencies

```yaml
# pubspec.yaml additions
dependencies:
  table_calendar: ^3.1.0   # 캘린더 UI
```

`supabase_flutter`, `flutter_riverpod`, `freezed_annotation`, `cached_network_image`, `intl` 은 이미 존재.

---

## 9. Implementation Order (Build Sequence)

```
Step 1: DB 마이그레이션
  └─ daily_outfits + outfit_items + RLS + increment_wear_count RPC
  └─ 파일: supabase/migrations/20260223100000_create_daily_outfits.sql

Step 2: Freezed 모델 (1.1 ~ 1.3)
  └─ daily_outfit.dart, outfit_item.dart, daily_outfit_with_items.dart
  └─ dart run build_runner build

Step 3: Repository (Section 3)
  └─ daily_repository.dart (CRUD + wear_count 업데이트)

Step 4: Providers (Section 4)
  └─ daily_provider.dart + daily_record_form_provider.dart

Step 5: WardrobePickerScreen (5.2)
  └─ 다중 선택 그리드 (wardrobeItemsProvider 재사용)

Step 6: DailyRecordScreen (5.1)
  └─ 입력 폼 화면 (날짜 선택 + 아이템 표시 + 메모 + 저장)

Step 7: CalendarScreen (5.3)
  └─ table_calendar + 월별 로드 + 날짜별 상세

Step 8: 라우터 등록 + 홈 화면 연결 (6.1, 6.2)
  └─ app_router.dart + home_screen.dart 수정

Step 9: table_calendar 패키지 추가 + flutter analyze
```

---

## 10. Key Design Decisions

| Decision | Choice | Rationale |
|---------|--------|-----------|
| Calendar 패키지 | `table_calendar` | Flutter 생태계에서 가장 많이 사용, 커스텀 마커 지원 |
| Wear count 업데이트 | PostgreSQL RPC function | 원자적 업데이트 보장, RLS 적용 |
| 날짜별 코디 제한 | UNIQUE(user_id, outfit_date) | 하루 1코디 정책, upsert로 수정 가능 |
| 아이템 선택 UI | 별도 화면 (WardrobePickerScreen) | 기존 wardrobeItemsProvider 재사용, 필터 기능 포함 |
| Form state | StateNotifierProvider.family | 날짜별 독립 폼 상태, autoDispose로 메모리 관리 |
| 상세 뷰 | CalendarScreen 하단 inline | 별도 화면 없이 캘린더 + 상세를 한 화면에 표시 |
| MVP 범위 | 옷장 선택만 (경로 B) | 사진 촬영 + AI 매칭은 Phase 2로 분리 |
| outfit_items join | select with foreign table | Supabase PostgREST foreign key join 활용 |

---

## 11. Coding Conventions (This Feature)

| Item | Convention |
|------|-----------|
| Feature 폴더 | `lib/features/daily/` (data/models, data/, providers/, presentation/) |
| Model naming | PascalCase Freezed: `DailyOutfit`, `OutfitItem` |
| File naming | snake_case: `daily_outfit.dart`, `daily_repository.dart` |
| Provider naming | camelCase + Provider suffix: `monthlyOutfitsProvider` |
| Screen naming | PascalCase + Screen suffix: `CalendarScreen`, `DailyRecordScreen` |
| DB columns | snake_case: `outfit_date`, `user_id` |
| JsonKey mapping | `@JsonKey(name: 'snake_case')` for all DB fields |
| State management | `StateNotifierProvider` for form, `FutureProvider.family` for data |

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-23 | Initial draft | Claude |
