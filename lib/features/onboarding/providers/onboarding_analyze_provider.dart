import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/detected_item.dart';
import '../data/onboarding_repository.dart';

enum OnboardingAnalyzeStep {
  idle,
  analyzing,
  completed,
  error,
}

class OnboardingAnalyzeState {
  final OnboardingAnalyzeStep step;
  final Uint8List? imageBytes;
  final List<DetectedItem> items;
  final String? errorCode;
  final String? errorMessage;

  const OnboardingAnalyzeState({
    this.step = OnboardingAnalyzeStep.idle,
    this.imageBytes,
    this.items = const [],
    this.errorCode,
    this.errorMessage,
  });

  OnboardingAnalyzeState copyWith({
    OnboardingAnalyzeStep? step,
    Uint8List? imageBytes,
    List<DetectedItem>? items,
    String? errorCode,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingAnalyzeState(
      step: step ?? this.step,
      imageBytes: imageBytes ?? this.imageBytes,
      items: items ?? this.items,
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<DetectedItem> get selectedItems =>
      items.where((item) => item.isSelected).toList();
}

class OnboardingAnalyzeNotifier extends StateNotifier<OnboardingAnalyzeState> {
  OnboardingAnalyzeNotifier(this._ref)
      : super(const OnboardingAnalyzeState());

  final Ref _ref;

  Future<void> startAnalysis(Uint8List imageBytes) async {
    state = state.copyWith(
      step: OnboardingAnalyzeStep.analyzing,
      imageBytes: imageBytes,
      items: [],
      clearError: true,
    );

    try {
      final repo = _ref.read(onboardingRepositoryProvider);
      final items = await repo.analyzeOutfit(imageBytes);

      if (!mounted) return;
      state = state.copyWith(
        step: OnboardingAnalyzeStep.completed,
        items: items,
      );
    } on OnboardingAnalysisException catch (e) {
      dev.log('OnboardingAnalysisException: ${e.code} - ${e.message}',
          name: 'ONBOARDING');
      if (!mounted) return;
      state = state.copyWith(
        step: OnboardingAnalyzeStep.error,
        errorCode: e.code,
        errorMessage: e.message,
      );
    } catch (e, st) {
      dev.log('UNKNOWN_ERROR: $e\n$st', name: 'ONBOARDING');
      if (!mounted) return;
      state = state.copyWith(
        step: OnboardingAnalyzeStep.error,
        errorCode: 'UNKNOWN_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  void toggleItem(int index) {
    final updatedItems = state.items.map((item) {
      if (item.index == index) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void updateCategory(int index, String category) {
    final updatedItems = state.items.map((item) {
      if (item.index == index) {
        return item.copyWith(category: category);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void reset() {
    state = const OnboardingAnalyzeState();
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository();
});

final onboardingAnalyzeProvider = StateNotifierProvider<
    OnboardingAnalyzeNotifier, OnboardingAnalyzeState>(
  (ref) => OnboardingAnalyzeNotifier(ref),
);
