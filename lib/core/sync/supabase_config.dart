import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project credentials.
///
/// Pass at build/run time, e.g.:
/// `flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co --dart-define=SUPABASE_ANON_KEY=...`
///
/// When left empty the app runs fully offline and the Backup screen shows a
/// "not configured" notice.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

bool get supabaseConfigured =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

Future<void> initSupabaseIfConfigured() async {
  if (!supabaseConfigured) return;
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );
}
