# CycleTrack

Privacy-first Flutter period & ovulation tracker. Works fully offline with encrypted local storage. Optional encrypted cloud backup via Supabase + Google sign-in.

## Features

- **Anonymous by default** — no account required
- **Encrypted local database** (SQLCipher via Drift)
- **Cycle predictions** — period, fertile window, ovulation
- **Pregnancy mode** — gestational week & milestones
- **Calendar logging** — flow, symptoms, mood, BBT, weight, intimacy, pills
- **Analytics** — BBT, weight, and cycle history charts
- **Local notifications** — period, fertile window, ovulation, late period, pill reminders
- **App lock** — PIN + biometric unlock
- **CSV export** and **one-tap delete all** (local + cloud)
- **Light / dark theme**

## Requirements

- Flutter 3.41+ / Dart 3.11+
- Android SDK 37 (for build)
- Xcode 15+ (for iOS)

## Run locally

```bash
flutter pub get
dart run build_runner build   # only if you change database.dart
flutter run
```

Cloud backup is **enabled by default** (live Supabase project baked into the build).
To use a different project: `flutter run --dart-define-from-file=dart_defines.json`

## Supabase cloud backup (live)

The app ships with the production Supabase URL + anon key. Backup works after you complete one-time dashboard setup:

1. Run [`supabase/schema.sql`](supabase/schema.sql) in the Supabase SQL editor.
   - **Existing table:** `alter table public.encrypted_backups add column if not exists wrapped_key text;`
2. Enable **Google** under Authentication → Providers (Web OAuth client).
3. Google Cloud redirect URI: `https://zwgzzxcchawjwrbjrvhy.supabase.co/auth/v1/callback`
4. Supabase redirect URL: `io.supabase.cycletrack://login-callback/`

**In the app:** Settings → Backup & restore → Continue with Google → Backup now

Features: manual backup/restore, cross-device restore, auto-backup (every 12+ hours).

## Project structure

```
lib/
  core/           # theme, db, router, notifications, providers
  features/
    cycle/        # prediction engine
    home/         # today dashboard
    calendar/     # month view + day log sheet
    analytics/    # charts
    insights/     # phase tips
    settings/     # privacy, sync, pills
    sync/         # encrypted Supabase backup
    lock/         # PIN / biometric gate
design/           # UI mockups (Figma partial — see design/README.md)
supabase/         # SQL schema for encrypted_backups table
test/             # unit tests (cycle engine)
```

## Tests

```bash
flutter test
flutter analyze
```

## Design

Figma (in progress): https://www.figma.com/design/jveeABpb03aQ8yNUXCyHO2  
Local mockups: [`design/`](design/)

## License

Private — see repository owner for terms.
