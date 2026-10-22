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

## Handover evidence

Setting Home while Google TV's launcher remained enabled did not take over Home: the resolver and resumed activity still selected `com.google.android.apps.tv.launcherx/.home.HomeActivity`.

The original package states and launcher APKs were backed up locally. `com.google.android.tungsten.setupwraith` was disabled first, followed by `com.google.android.apps.tv.launcherx`, both for user 0. No other existing package was disabled, uninstalled, or cleared.

The target briefly became ADB-offline and unreachable on the network. After the user confirmed connectivity at the same IP, ADB returned, `set-home-activity` succeeded, and both the resolver and foreground activity selected `com.gathin.tvhome/.MainActivity`. The final screenshot shows the configured YouTube and Netflix dock.

The live remote-key smoke covered:

- Opening Netflix and YouTube from their dock tiles with OK, then returning to CleanYourTV with Home.
- Holding OK to open Replace, Move, Remove from Home, and App info.
- Navigating to Launcher settings and seeing layout controls.
- Opening App library, which listed 22 apps.
- Opening Inputs, which listed PlayStation 4 on HDMI 1, HDMI 2, HDMI 3, AV, and Live TV.

The final disabled-package comparison showed exactly the two launcher packages above newly disabled, with no pre-existing disabled package re-enabled. Streaming playback, casting, USB playback, reboot persistence, and the affirmative restore path were not exercised.

If connectivity is lost during a future handover, recover it through TV Settings with the remote; check the IP and debugging authorization. Do not factory reset or reboot into an uncertain setup-wizard state. The model-specific upstream warning is in `examples/xiaomi-tv-a-pro-2026/debloat.txt`; do not apply its full debloat list for a launcher-only migration.

## Interactive recovery

The local ignored backup directory contains `restore-state.json`, the original Google TV launcher and setup-wizard APKs, package inventories, and a `Restore-TV.cmd` shortcut.

Double-click `Restore-TV.cmd` after network access returns. It asks before restoring the recorded package enabled states and original Home. It does not uninstall CleanYourTV or clear app data.

Alternatively, from the repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/restore-home.ps1 -BackupPath "backup/<your-backup-folder>"
```

The PowerShell script was parsed successfully and its interactive cancellation path was exercised without changes. The affirmative recovery path has not been exercised.

Backup dumps, screenshots, signing material, and APKs stay local and are not included in Git.
