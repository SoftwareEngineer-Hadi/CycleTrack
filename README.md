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

## Optional: Supabase cloud backup

1. Create a [Supabase](https://supabase.com) project (free tier works).
2. Run [`supabase/schema.sql`](supabase/schema.sql) in the SQL editor.
3. Enable **Google** under Authentication → Providers.
4. Add redirect URL: `io.supabase.cycletrack://login-callback/`
5. Run with dart-defines:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Without these defines the app runs fully offline; Backup & Restore shows a “not configured” notice.

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
