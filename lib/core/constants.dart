/// App-wide constants for Reflect.
class AppConstants {
  AppConstants._();

  /// Supabase project URL — replace with actual value.
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// Supabase anon key — replace with actual value.
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Auto-save debounce duration for journal entries.
  static const Duration autoSaveDebounce = Duration(milliseconds: 1500);

  /// Maximum word count displayed before truncation.
  static const int maxPreviewWords = 50;
}
