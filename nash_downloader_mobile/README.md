# Nash Downloader — Android

Mobile companion to the desktop Nash Downloader. Same dark UI, same yt-dlp
engine, plus one new trick: share a Reel or YouTube link straight from
Instagram/YouTube and it shows up as a share target.

## How it's built

- **UI**: Flutter (Dart) — matches the desktop app's exact colors
  (`#000000` background, `#1C1C1E` cards, `#0A84FF` accent).
- **Download engine**: [`youtubedl-android`](https://github.com/yausername/youtubedl-android),
  which bundles yt-dlp for Android (same engine as the desktop app's Python
  `yt-dlp`), called from Kotlin via a MethodChannel/EventChannel bridge in
  `android/app/src/main/kotlin/com/nash/downloader/`.
- **Share target**: `receive_sharing_intent` (Dart side) + an `ACTION_SEND`
  intent-filter (Android manifest side) — together these make "Nash
  Downloader" appear in the system share sheet from Instagram/YouTube.

## Building the APK on GitHub (no local setup needed)

Same idea as the desktop app's GitHub Actions build:

1. Create a new GitHub repo (can be private) and push this whole folder to
   it, keeping the structure as-is.
2. Push to `main` — or go to the repo's **Actions** tab and run the
   "Build Android APK" workflow manually (workflow_dispatch).
3. It installs Flutter + JDK 17, runs `flutter pub get` and
   `flutter build apk --release`. Takes ~5-8 minutes.
4. Go to **Actions → (your run) → Artifacts**, download
   `NashDownloader-android`, unzip it — that's `app-release.apk`.
5. Send that file to your phone (email, Drive, cable) and tap it to install.
   You'll need to allow "install unknown apps" for whatever app you use to
   open it — Android will prompt you the first time.

## First-run reality check

This is a from-scratch scaffold, not a battle-tested build — the
`youtubedl-android` library version pinned in
`android/app/build.gradle` (`0.17.1`) may have minor API differences by
the time you build, and `receive_sharing_intent`'s manifest requirements
occasionally change between versions. If the GitHub Actions run fails,
the error log will point at the exact line — most likely fixes are:

- Bumping the `youtubedl-android` version in `android/app/build.gradle`
- Checking `receive_sharing_intent`'s current README for the exact
  manifest snippet if the share sheet doesn't trigger

Paste me the failing step's log and I'll patch the relevant file directly.

## Storage location

Downloads currently save to the app's own storage:
`Android/data/com.nash.downloader/files/NashDownloader/` (visible via any
file manager app, no special permission needed on Android 10+). If you'd
rather have files land in the regular public **Downloads** folder visible
to Google Photos etc., that needs Android's `MediaStore` API instead —
happy to wire that in as a follow-up.

## Google Play

Batch video-downloader apps for Instagram/YouTube are routinely rejected
from the Play Store for ToS reasons. This project is built for sideloading
(the GitHub Actions APK), not Play Store distribution.

## Project layout

```
lib/
  main.dart              entry point
  theme/app_theme.dart    desktop-matched color palette
  models/                 VideoInfo, DownloadItem, quality enum
  services/
    ytdlp_service.dart     Dart <-> native channel wrapper
    share_intent_service.dart  listens for shared links
  widgets/
    share_sheet_modal.dart  the bottom sheet shown on share
  screens/
    root_shell.dart      bottom nav + share listener
    home_screen.dart      Download tab
    history_screen.dart
    settings_screen.dart
    about_screen.dart
android/
  app/src/main/kotlin/com/nash/downloader/
    NashDownloaderApp.kt   inits yt-dlp/ffmpeg at startup
    MainActivity.kt        wires up the channels
    YtDlpChannel.kt         getVideoInfo / startDownload / cancelDownload
  app/src/main/AndroidManifest.xml   share-target intent filter
.github/workflows/build-apk.yml      CI build, same pattern as desktop
```
