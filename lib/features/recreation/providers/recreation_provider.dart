import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/look_recreation.dart';
import '../data/recreation_repository.dart';

/// Repository singleton
final recreationRepositoryProvider = Provider<RecreationRepository>((ref) {
  return RecreationRepository();
});

/// Recreation history list
final recreationHistoryProvider =
    FutureProvider<List<LookRecreation>>((ref) async {
  final repo = ref.watch(recreationRepositoryProvider);
  return repo.fetchHistory();
});

/// Single recreation by ID
final recreationByIdProvider =
    FutureProvider.family<LookRecreation, String>((ref, id) async {
  final repo = ref.watch(recreationRepositoryProvider);
  return repo.fetchById(id);
});
