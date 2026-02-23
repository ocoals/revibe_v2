import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/look_recreation.dart';
import '../data/recreation_repository.dart';
import 'recreation_provider.dart';
import 'usage_provider.dart';

/// Process state enum
enum RecreationStep {
  idle,
  uploading,
  analyzing,
  matching,
  completed,
  error,
}

/// Process state
class RecreationProcessState {
  final RecreationStep step;
  final Uint8List? imageBytes;
  final LookRecreation? result;
  final String? errorCode;
  final String? errorMessage;

  const RecreationProcessState({
    this.step = RecreationStep.idle,
    this.imageBytes,
    this.result,
    this.errorCode,
    this.errorMessage,
  });

  RecreationProcessState copyWith({
    RecreationStep? step,
    Uint8List? imageBytes,
    LookRecreation? result,
    String? errorCode,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return RecreationProcessState(
      step: step ?? this.step,
      imageBytes: imageBytes ?? this.imageBytes,
      result: clearResult ? null : (result ?? this.result),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Process notifier - manages the full recreation flow
class RecreationProcessNotifier extends StateNotifier<RecreationProcessState> {
  RecreationProcessNotifier(this._ref)
      : super(const RecreationProcessState());

  final Ref _ref;

  /// Set selected image and start analysis
  Future<void> startAnalysis(Uint8List imageBytes) async {
    state = state.copyWith(
      step: RecreationStep.uploading,
      imageBytes: imageBytes,
      clearError: true,
      clearResult: true,
    );

    try {
      final repo = _ref.read(recreationRepositoryProvider);

      // Simulate step progression for UX
      state = state.copyWith(step: RecreationStep.analyzing);

      // Call Edge Function (handles upload + AI + matching internally)
      final result = await repo.analyze(imageBytes);

      if (!mounted) return;
      state = state.copyWith(
        step: RecreationStep.completed,
        result: result,
      );

      // Invalidate usage and history providers
      _ref.invalidate(recreationUsageProvider);
      _ref.invalidate(remainingRecreationsProvider);
      _ref.invalidate(canRecreateProvider);
      _ref.invalidate(recreationHistoryProvider);

    } on RecreationException catch (e) {
      dev.log('RecreationException: ${e.code} - ${e.message}', name: 'RECREATION');
      if (!mounted) return;
      state = state.copyWith(
        step: RecreationStep.error,
        errorCode: e.code,
        errorMessage: e.message,
      );
    } catch (e, st) {
      dev.log('UNKNOWN_ERROR: $e\n$st', name: 'RECREATION');
      if (!mounted) return;
      state = state.copyWith(
        step: RecreationStep.error,
        errorCode: 'UNKNOWN_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  /// Reset to idle
  void reset() {
    state = const RecreationProcessState();
  }
}

final recreationProcessProvider = StateNotifierProvider<
    RecreationProcessNotifier, RecreationProcessState>(
  (ref) => RecreationProcessNotifier(ref),
);
