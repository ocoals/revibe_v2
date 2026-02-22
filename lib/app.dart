import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/config/theme.dart';
import 'core/router/app_router.dart';

final routerProvider = Provider<GoRouter>((ref) => createRouter(ref));

class ClosetIQApp extends ConsumerWidget {
  const ClosetIQApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ClosetIQ',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
