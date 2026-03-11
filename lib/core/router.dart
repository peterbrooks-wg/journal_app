import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/journal/home_screen.dart';
import '../features/journal/journal_entry_screen.dart';
import '../features/journal/journal_list_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/summaries/summaries_list_screen.dart';
import '../features/summaries/summary_detail_screen.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/widgets/scaffold_with_nav_bar.dart';

// Navigator keys for each tab branch.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _journalNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'journal');
final _summariesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'summaries');
final _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Creates the app router with auth-aware redirects.
GoRouter createRouter(Ref ref) {
  // Listen to auth changes and refresh router redirects.
  final authNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = ref.read(authProvider);
      final isOnAuthPage = state.matchedLocation == '/auth';
      final isOnOnboarding = state.matchedLocation == '/onboarding';

      if (authStatus == AuthStatus.unauthenticated) {
        return isOnAuthPage ? null : '/auth';
      }

      if (authStatus == AuthStatus.onboarding) {
        return isOnOnboarding ? null : '/onboarding';
      }

      // Authenticated — redirect away from auth/onboarding.
      if (isOnAuthPage || isOnOnboarding) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      // Auth routes — outside the shell (no nav bar).
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app — shell with bottom navigation.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Tab 1: Journal
          StatefulShellBranch(
            navigatorKey: _journalNavigatorKey,
            routes: [
              GoRoute(
                path: '/journal',
                builder: (context, state) =>
                    const JournalListScreen(),
                routes: [
                  GoRoute(
                    path: 'new',
                    builder: (context, state) =>
                        const JournalEntryScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final entryId = state.pathParameters['id'];
                      return JournalEntryScreen(entryId: entryId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Insights (Summaries)
          StatefulShellBranch(
            navigatorKey: _summariesNavigatorKey,
            routes: [
              GoRoute(
                path: '/summaries',
                builder: (context, state) =>
                    const SummariesListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final summaryId = state.pathParameters['id']!;
                      return SummaryDetailScreen(
                        summaryId: summaryId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 3: Settings
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Riverpod provider for the app router.
final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});

/// Bridges Riverpod auth state changes to GoRouter's refreshListenable.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (_, _) => notifyListeners());
  }
}
