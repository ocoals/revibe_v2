import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import 'recreation_provider.dart';

/// Monthly recreation usage count
final recreationUsageProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(recreationRepositoryProvider);
  return repo.getMonthlyUsage();
});

/// Remaining free recreations this month
final remainingRecreationsProvider = FutureProvider<int>((ref) async {
  final used = await ref.watch(recreationUsageProvider.future);
  return (AppConfig.freeRecreationMonthlyLimit - used)
      .clamp(0, AppConfig.freeRecreationMonthlyLimit);
});

/// Whether user can perform recreation
final canRecreateProvider = FutureProvider<bool>((ref) async {
  final remaining = await ref.watch(remainingRecreationsProvider.future);
  return remaining > 0;
});
