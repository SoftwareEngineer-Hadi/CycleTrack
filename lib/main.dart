import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/notification_service.dart';
import 'core/sync/supabase_config.dart';
import 'features/lock/app_lock.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.init();
  await initSupabaseIfConfigured();

  final container = ProviderContainer();
  await initAppLock(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CycleTrackApp(),
    ),
  );
}
