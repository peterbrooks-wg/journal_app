import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_screen.dart';
import '../features/auth/onboarding_screen.dart';
import '../features/journal/home_screen.dart';
import '../features/journal/journal_entry_screen.dart';
import '../features/journal/journal_list_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/summaries/summaries_screen.dart';

/// App-wide router configuration using GoRouter.
///
/// Defines all Phase 1 routes: home, onboarding, auth, journal
/// (with nested new/edit), summaries, and settings.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
