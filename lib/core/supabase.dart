import 'package:supabase_flutter/supabase_flutter.dart';

import 'constants.dart';

/// Initialize the Supabase client.
///
/// Call this in `main()` before `runApp()`.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
}

/// Global accessor for the Supabase client.
SupabaseClient get supabase => Supabase.instance.client;
