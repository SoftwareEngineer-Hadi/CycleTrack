/// Supabase OAuth deep link — must match Android manifest, iOS URL scheme,
/// Supabase redirect URLs, and [SyncService.signInWithGoogle] redirectTo.
const supabaseAuthRedirectUrl = 'io.supabase.cycletrack://login-callback/';

/// Returns true when [uri] is the Google OAuth return URL (not an app route).
bool isSupabaseAuthCallback(Uri uri) {
  if (uri.scheme == 'io.supabase.cycletrack') return true;
  if (uri.host == 'login-callback') return true;
  if (uri.pathSegments.contains('login-callback')) return true;
  final raw = uri.toString();
  return raw.contains('io.supabase.cycletrack') &&
      raw.contains('login-callback');
}

/// GoRouter passes some platforms' deep links as an opaque location string.
bool isSupabaseAuthCallbackLocation(String location) {
  return location.contains('login-callback') &&
      (location.contains('io.supabase.cycletrack') ||
          location.contains('supabase.cycletrack'));
}
