import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../wardrobe/data/models/wardrobe_item.dart';
import '../../wardrobe/providers/wardrobe_provider.dart';
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

  void removeItem(String itemId) {
    final current = List<WardrobeItem>.from(state.selectedItems);
    current.removeWhere((i) => i.id == itemId);
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
      final dateKey = DateFormatUtils.formatDateKey(state.date);
      _ref.invalidate(monthlyOutfitsProvider(monthKey));
      _ref.invalidate(outfitByDateProvider(dateKey));

      // Also invalidate wardrobe items (wear_count changed)
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
