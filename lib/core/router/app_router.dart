import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/insights/presentation/insights_screen.dart';
import '../../features/lock/presentation/lock_screen.dart';
import '../../features/lock/app_lock.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/backup_screen.dart';
import '../../features/settings/presentation/pill_reminders_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../providers.dart';
import 'scaffold_with_nav.dart';

/// Notifies GoRouter when auth-relevant state (onboarding, lock) changes.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(onboardingDoneProvider, (_, _) => notifyListeners());
    ref.listen(appLockProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final onboardingDone = ref.read(onboardingDoneProvider);
      final locked = ref.read(appLockProvider);
      final loc = state.matchedLocation;

      if (onboardingDone == null) {
        return loc == '/splash' ? null : '/splash';
      }
      if (!onboardingDone) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (locked) {
        return loc == '/lock' ? null : '/lock';
      }
      if (loc == '/splash' || loc == '/onboarding' || loc == '/lock') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldWithNav(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/calendar',
              builder: (context, state) => const CalendarScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/insights',
              builder: (context, state) => const InsightsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'pills',
                  builder: (context, state) => const PillRemindersScreen(),
                ),
                GoRoute(
                  path: 'backup',
                  builder: (context, state) => const BackupScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
