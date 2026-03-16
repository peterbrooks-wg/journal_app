# Phase 8: Settings + Privacy — Design

## Overview

Wire up the settings screen with functional mock implementations: biometric lock toggle, export journal dialog, delete-all confirmation, notification preferences. All persisted to SharedPreferences.

## Features

### Biometric Lock
- Toggle in settings to enable/disable biometric lock
- Mock: stores preference in SharedPreferences
- Real: would use local_auth package to require FaceID/fingerprint on app launch
- Shows "Enable biometric lock" switch

### Export Journal
- Tapping "Export my data" shows a confirmation dialog
- Mock: shows a success snackbar ("Journal exported successfully")
- Real: would generate encrypted JSON and share via share sheet

### Delete All Data
- Tapping "Delete all data" shows a destructive confirmation dialog
- Requires typing "DELETE" to confirm
- Mock: clears all Riverpod providers (entries, summaries, prompts)
- Shows success snackbar, navigates to home

### Notification Preferences
- Toggle for push notifications (on/off)
- Time picker for daily reminder
- Both persisted to SharedPreferences

## Files
```
lib/shared/providers/
  settings_provider.dart           — new (notification + biometric prefs)
lib/features/settings/
  settings_screen.dart             — modify (wire up all actions)
```
