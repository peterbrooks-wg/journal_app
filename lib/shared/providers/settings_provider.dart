import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences for app settings.
class AppSettings {
  final bool notificationsEnabled;
  final TimeOfDay reminderTime;
  final bool biometricLockEnabled;

  const AppSettings({
    this.notificationsEnabled = true,
    this.reminderTime = const TimeOfDay(hour: 8, minute: 0),
    this.biometricLockEnabled = false,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    TimeOfDay? reminderTime,
    bool? biometricLockEnabled,
  }) {
    return AppSettings(
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      biometricLockEnabled:
          biometricLockEnabled ?? this.biometricLockEnabled,
    );
  }
}

/// Manages user settings persisted in SharedPreferences.
class SettingsNotifier extends Notifier<AppSettings> {
  static const _notificationsKey = 'notifications_enabled';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';
  static const _biometricKey = 'biometric_lock_enabled';

  @override
  AppSettings build() {
    _loadFromPrefs();
    return const AppSettings();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      reminderTime: TimeOfDay(
        hour: prefs.getInt(_reminderHourKey) ?? 8,
        minute: prefs.getInt(_reminderMinuteKey) ?? 0,
      ),
      biometricLockEnabled: prefs.getBool(_biometricKey) ?? false,
    );
  }

  /// Toggle push notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  /// Set the daily reminder time.
  Future<void> setReminderTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_reminderHourKey, time.hour);
    await prefs.setInt(_reminderMinuteKey, time.minute);
    state = state.copyWith(reminderTime: time);
  }

  /// Toggle biometric lock.
  Future<void> setBiometricLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
    state = state.copyWith(biometricLockEnabled: enabled);
  }
}

/// Global settings provider.
final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
