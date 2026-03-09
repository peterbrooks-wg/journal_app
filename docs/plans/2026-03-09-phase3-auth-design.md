# Phase 3: Auth Screens — Design

## Overview

Auth UI screens + onboarding flow + router redirect logic, with mock auth that can be swapped for real Supabase auth later.

## Screens

### Auth Screen
- Clean, minimal. App logo/name + tagline
- Email field with "Send magic link" button
- Divider with "or"
- Apple Sign-In button (dark, iOS-style)
- Google Sign-In button (outlined)
- No password field
- Mock auth: sign-in immediately succeeds

### Onboarding Screen
- 3-page PageView with dots indicator
- Page 1: What Reflect does
- Page 2: Privacy promise
- Page 3: Notification opt-in
- "Get Started" button navigates to home
- Sets onboarding_completed flag

## Auth State Management

- `AuthNotifier` (Riverpod Notifier) managing: authenticated, unauthenticated, onboarding
- Mock implementation stores state in SharedPreferences
- GoRouter redirect: unauthenticated → /auth, needs onboarding → /onboarding, else → /

## Files

```
lib/features/auth/
  auth_screen.dart         — full auth UI
  onboarding_screen.dart   — 3-page onboarding flow
lib/shared/providers/
  auth_provider.dart       — AuthNotifier + authProvider
lib/core/
  router.dart              — add redirect logic
```

## Design Guidelines

- Off-white background (#FAFAF8), dark navy text (#1A1A2E), accent (#7B9EA6)
- Generous whitespace — the auth screen should feel calm and trustworthy
- Subtle fade-in animations
- System font
