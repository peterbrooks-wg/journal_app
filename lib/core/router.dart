import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/journal/home_screen.dart';
import '../features/journal/journal_entry_screen.dart';
import '../features/journal/journal_list_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/summaries/summaries_screen.dart';
import '../shared/providers/auth_provider.dart';

/// Creates the app router with auth-aware redirects.
///
/// Pass a [Ref] so the router can read [authProvider].
GoRouter createRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
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

      // Authenticated — redirect away from auth/onboarding pages.
      if (isOnAuthPage || isOnOnboarding) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingScreen();
        },
      ),
      GoRoute(
        path: '/auth',
        builder: (BuildContext context, GoRouterState state) {
          return const AuthScreen();
        },
      ),
      GoRoute(
        path: '/journal',
        builder: (BuildContext context, GoRouterState state) {
          return const JournalListScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'new',
            builder: (BuildContext context, GoRouterState state) {
              return const JournalEntryScreen();
            },
          ),
          GoRoute(
            path: ':id',
            builder: (BuildContext context, GoRouterState state) {
              final entryId = state.pathParameters['id'];
              return JournalEntryScreen(entryId: entryId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/summaries',
        builder: (BuildContext context, GoRouterState state) {
          return const SummariesScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
    ],
  );
}

/// Riverpod provider for the app router.
final routerProvider = Provider<GoRouter>((ref) {
  return createRouter(ref);
});
