# Play Store assets

Everything you need to publish **CycleTrack** on Google Play.

## Files

```
store/
├── play-store-icon-512.png      # App icon (512×512)
├── feature-graphic-1024x500.png # Store banner (recommended)
├── PLAY_STORE_LISTING.md        # Name, short & long descriptions
└── screenshots/
    ├── phone/                   # 5 × 1080×1920
    ├── tablet-7/                # 2 × 1200×1920
    └── web/                     # Landing page mockup
```

## Privacy policy URL

1. Push `docs/privacy-policy.html` to GitHub.
2. In repo **Settings → Pages**, set source to **Deploy from branch** → `main` → `/docs`.
3. Use this URL in Play Console:

```
https://softwareengineer-hadi.github.io/CycleTrack/privacy-policy.html
```

(Pages may take a few minutes to go live after enabling.)

## Replace screenshots (optional)

The included screenshots are **marketing mockups** aligned with the app design. For pixel-perfect captures from your phone:

```bash
# With app open on the screen you want:
adb exec-out screencap -p > store/screenshots/phone/my-capture.png
sips -z 1920 1080 my-capture.png --out my-capture.png
```

## Play Console upload order

1. **Main store listing** — copy text from `PLAY_STORE_LISTING.md`
2. **App icon** — `play-store-icon-512.png`
3. **Feature graphic** — `feature-graphic-1024x500.png`
4. **Phone screenshots** — all files in `screenshots/phone/`
5. **7-inch tablet** — files in `screenshots/tablet-7/`
6. **Privacy policy** — URL above

## Release build

Signed release AAB (upload this to Play Console):

```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

### Signing (already configured)

- Keystore: `android/app/upload-keystore.jks` (gitignored)
- Credentials: `android/keystore-credentials.txt` (gitignored — **back this up**)
- Config: `android/key.properties` (gitignored)

**Never commit or lose the keystore.** Without it you cannot publish updates for `app.cycletrack.cycletrack` on Play Store.

First-time Play Console upload: enable **Google Play App Signing** when prompted (recommended).
