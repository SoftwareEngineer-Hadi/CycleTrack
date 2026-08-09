import 'package:supabase_flutter/supabase_flutter.dart';

/// Live Supabase project (CycleTrack production).
///
/// Override at build time for other environments:
/// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
///
/// The anon key is safe in client builds — access is limited by Row Level Security.
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://zwgzzxcchawjwrbjrvhy.supabase.co',
);

const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3Z3p6eGNjaGF3andyYmpydmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYyNjM3MTksImV4cCI6MjEwMTgzOTcxOX0.7qR9PRRdeWUc2yWsxU6VcKfZZvB5eDr1vRmvR0stzJA',
);

bool get supabaseConfigured =>
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

Future<void> initSupabaseIfConfigured() async {
  if (!supabaseConfigured) return;
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}
