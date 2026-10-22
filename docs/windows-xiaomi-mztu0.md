# Windows / Xiaomi MiTV-MZTU0

## Deployment profile

The live target identifies as MiTV-MZTU0, Android 14 / API 34, user 0. This is not the MiTV-MOSR4 / Android 11 used in the earlier tv-home deployment.

`themes/xiaomi-mztu0/config.json` pins YouTube and Netflix without filling spare dock slots. It enables the app library, tile menu, and direct launcher settings. Casting, USB media, firmware updates, and the remaining installed apps are not disabled by this profile.

## Controls

- Home opens the configured home launcher after the firmware handover is complete.
- Left / Right and OK select and open an app.
- Hold OK on an app for Move, Remove from Home, or App info. Removing a shortcut does not uninstall the app.
- The library button lists apps that can be added to Home.
- The home-shaped settings button opens launcher settings. TV settings remain available inside that page.

## Build

JDK 17 and Android SDK platform 34 / build-tools 34 are needed on the computer, not on the TV. The repository Gradle wrapper downloads the build dependencies.

```powershell
$env:JAVA_HOME = (Resolve-Path ../../_tools/android/jdk17/jdk-17.0.20.1+1).Path
$env:ANDROID_HOME = (Resolve-Path ../../_tools/android/gradle-sdk).Path
Push-Location launcher
./gradlew.bat assembleRelease --console=plain
Pop-Location
```

APK: `launcher/app/build/outputs/apk/release/app-release.apk`.

The 2026-10-22 release build completed successfully and produced a 481,243-byte APK. ADB installation for user 0 returned `Success`. The theme was written through `content://com.gathin.tvhome.theme/config.json` and read back from the provider.

## Handover evidence and current blocker

Setting Home while Google TV's launcher remained enabled did not take over Home: the resolver and resumed activity still selected `com.google.android.apps.tv.launcherx/.home.HomeActivity`.

The original package states and launcher APKs were backed up locally. `com.google.android.tungsten.setupwraith` was disabled first, followed by `com.google.android.apps.tv.launcherx`, both for user 0. No other existing package was disabled, uninstalled, or cleared.

The target then became ADB-offline and unreachable on the network before the final Home command could be confirmed. A successful launch intent and a momentary resumed MainActivity do not prove the launcher rendered: the captured preview still showed Google TV. Home, app launch, and remote interaction therefore remain unverified.

Recover connectivity from the TV's Settings using the remote. Do not factory reset or reboot into an uncertain setup-wizard state. Check the current IP, enable debugging if needed, and authorize the computer if asked. The model-specific upstream warning is in `examples/xiaomi-tv-a-pro-2026/debloat.txt`; do not apply its full debloat list for a launcher-only migration.

## Interactive recovery

The local ignored backup directory contains `restore-state.json`, the original Google TV launcher and setup-wizard APKs, package inventories, and a `Restore-TV.cmd` shortcut.

Double-click `Restore-TV.cmd` after network access returns. It asks before restoring the recorded package enabled states and original Home. It does not uninstall CleanYourTV or clear app data.

Alternatively, from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/restore-home.ps1 -BackupPath "backup/<your-backup-folder>"
```

The PowerShell script was parsed successfully and its interactive cancellation path was exercised without changes. The affirmative recovery path requires a connected TV and has not yet been exercised.

Backup dumps, screenshots, signing material, and APKs stay local and are not included in Git.
