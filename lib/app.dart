import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/notification_scheduler.dart';
import 'features/sync/auto_backup.dart';

class CycleTrackApp extends ConsumerWidget {
  const CycleTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationSchedulerProvider);
    final router = ref.watch(routerProvider);
    return AutoBackupLifecycle(
      child: MaterialApp.router(
        title: 'CycleTrack',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref.watch(themeModeProvider),
        routerConfig: router,
      ),
    );
  }
}
