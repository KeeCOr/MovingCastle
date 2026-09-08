# Land of Magic — Godot Release Guide

**Game:** Land of Magic / Living Mansion
**Engine:** Godot 4.3 (Forward Plus)
**Developer:** Stoicent
**Date prepared:** 2026-09-05

---

## Overview

This guide covers the full release pipeline for Land of Magic: exporting from Godot 4 for Windows (Steam), uploading via SteamCMD, and reference steps for Android and iOS. All export configuration is already present in `export_presets.cfg` at the project root.

---

## Prerequisites

### Godot Export Templates

Before exporting, you must install the official export templates for your Godot version.

1. Open the Godot editor.
2. Go to **Editor > Manage Export Templates**.
3. Download the templates for **Godot 4.3 stable**.
4. Alternatively, download `Godot_v4.3-stable_export_templates.tpz` from [https://godotengine.org/download](https://godotengine.org/download) and install manually.

### Required Tools

| Tool | Purpose | Where to get |
|------|---------|-------------|
| Godot 4.3 stable | Editor + headless export | https://godotengine.org/download |
| SteamCMD | Steam depot upload | https://developer.valvesoftware.com/wiki/SteamCMD |
| Steam SDK (Steamworks) | App build definition | https://partner.steamgames.com |
| Android Studio + SDK | Android export only | https://developer.android.com/studio |
| Xcode (macOS) | iOS export only | App Store (macOS required) |
| Rcedit (optional) | Windows EXE icon injection | https://github.com/electron/rcedit |

---

## Windows Export (Steam)

### Step 1 — Run Export from Command Line

```bat
REM Navigate to your project root
cd C:\Development\26_LandOfMagic

REM Export Windows Desktop release build
"C:\Path\To\Godot_v4.3-stable_win64.exe" --headless --export-release "Windows Desktop" "LivingMansion_v0.1.2_portable.exe"
```

- `--headless` runs Godot without a display (suitable for CI/CD or build servers).
- `--export-release` uses the release export template (no debug symbols, optimized).
- `"Windows Desktop"` must match the preset name in `export_presets.cfg` exactly.
- The output path `LivingMansion_v0.1.2_portable.exe` is already defined in `export_presets.cfg` under `export_path`.

### Step 2 — Verify the Export

```bat
REM Check the exported file exists and is roughly the expected size
dir "LivingMansion_v0.1.2_portable.exe"

REM Run the exported EXE directly to verify it launches
"LivingMansion_v0.1.2_portable.exe"
```

Key things to verify after export:
- Game launches to the main menu (`MainMenu.tscn`)
- Save/load works (SaveData autoload)
- GUT test files are excluded (the export preset already filters `addons/gut/*,tests/*`)
- PCK is embedded (confirmed in `export_presets.cfg`: `binary_format/embed_pck=true`)

### Step 3 — Code Signing (Optional but Recommended for Steam)

Windows may display a SmartScreen warning for unsigned executables. For Steam release, basic code signing via a self-signed or purchased certificate reduces friction:

```bat
REM Sign with signtool (requires Windows SDK + code signing certificate)
signtool sign /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 /f "YourCert.pfx" /p "YourPassword" "LivingMansion_v0.1.2_portable.exe"
```

Steam's own signing and DRM (Steamworks DRM wrapping) can supplement or replace this.

---

## Steam Upload via SteamCMD

### Step 1 — Directory Structure

Create a staging directory for Steam upload:

```
steam_upload/
  content/
    LivingMansion_v0.1.2_portable.exe
  scripts/
    app_build.vdf
    depot_build.vdf
```

Copy your exported EXE into `steam_upload/content/`.

### Step 2 — Depot Build VDF

Create `steam_upload/scripts/depot_build.vdf`:

```vdf
"DepotBuildConfig"
{
  "DepotID"     "YOUR_DEPOT_ID"
  "ContentRoot" "..\content\"
  "FileMapping"
  {
    "LocalPath"  "*"
    "DepotPath"  "."
    "recursive"  "1"
  }
  "FileExclusion" "*.pdb"
  "FileExclusion" "*.ilk"
}
```

Replace `YOUR_DEPOT_ID` with the depot ID from your Steamworks App Admin page.

### Step 3 — App Build VDF

Create `steam_upload/scripts/app_build.vdf`:

```vdf
"AppBuild"
{
  "AppID"        "YOUR_APP_ID"
  "Desc"         "Land of Magic v0.1.2 - Windows Build"
  "BuildOutput"  "..\..\build_output\"
  "SetLive"      ""

  "Depots"
  {
    "YOUR_DEPOT_ID"
    {
      "FileMapping"
      {
        "LocalPath"  "..\content\*"
        "DepotPath"  "."
        "recursive"  "1"
      }
    }
  }
}
```

- Replace `YOUR_APP_ID` with your Steam App ID from Steamworks.
- Replace `YOUR_DEPOT_ID` with your depot ID.
- `"SetLive" ""` means the build uploads to Steam but is NOT set live automatically. Set to `"beta"` or `"default"` to promote automatically.

### Step 4 — Upload with SteamCMD

```bat
REM Log in (first time will prompt for 2FA code)
steamcmd +login YOUR_STEAM_USERNAME +run_app_build "C:\steam_upload\scripts\app_build.vdf" +quit
```

After a successful upload:
1. Log into the Steamworks Partner site.
2. Navigate to **App Admin > SteamPipe > Builds**.
3. Locate the new build (it appears as "Unset" branch).
4. Click **Set Build Live** and select the appropriate branch (default / beta).

---

## Android Export (Reference)

> Android export requires Godot 4 Android export templates and a configured Android SDK.

### Prerequisites

- Android Studio installed with SDK (API level 28+)
- Java JDK 17
- Keystore file for signing (required for Google Play release)
- Add Android export preset in Godot editor: **Project > Export > Add > Android**

### Export Command

```bat
"C:\Path\To\Godot_v4.3-stable_win64.exe" --headless --export-release "Android" "LivingMansion_v0.1.2.apk"
```

For Google Play, export as AAB instead of APK:

```bat
"C:\Path\To\Godot_v4.3-stable_win64.exe" --headless --export-release "Android" "LivingMansion_v0.1.2.aab"
```

### Signing Configuration

In Godot editor: **Project > Export > Android > Keystore**

- Set **Release Keystore** to your `.keystore` file.
- Set **Release User** and **Release Password**.
- These are stored per-machine and not committed to version control.

### Google Play Upload

Upload the signed `.aab` through [Google Play Console](https://play.google.com/console). Use the **Internal Testing** track first before rolling out to production.

---

## iOS Export (Reference)

> iOS export requires macOS with Xcode installed. Cross-compilation from Windows is not currently supported by Godot 4.

### Prerequisites (on macOS)

- macOS with Xcode 14+
- Apple Developer account (paid, for device testing and App Store distribution)
- iOS export templates installed in Godot
- Provisioning profile and signing certificate from Apple Developer portal

### Export Command (macOS)

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --export-release "iOS" "LivingMansion.ipa"
```

### Xcode Archive and Upload

1. Open the exported Xcode project in Xcode.
2. Set the correct signing team and provisioning profile.
3. **Product > Archive** to create an archive.
4. Use **Organizer > Distribute App** to upload to App Store Connect.

---

## Build Checklist — Pre-Release

### Windows / Steam
- [ ] Export templates for Godot 4.3 stable installed
- [ ] `export_presets.cfg` version string updated to match release version
- [ ] `--export-release` used (not `--export-debug`)
- [ ] Exported EXE launches cleanly from a fresh directory
- [ ] GUT / test files confirmed absent from exported build
- [ ] PCK embedded (no separate `.pck` file alongside EXE)
- [ ] `app_build.vdf` has correct App ID and Depot ID
- [ ] SteamCMD upload completed without errors
- [ ] Build visible in Steamworks Builds page
- [ ] Build set live on correct branch after QA

### Android
- [ ] Keystore file backed up securely (loss = unable to update on Play Store)
- [ ] APK or AAB signed with release keystore
- [ ] Target API level meets current Google Play requirements (API 34+ as of 2026)
- [ ] Internal test track verified before production rollout

### iOS
- [ ] Provisioning profile not expired
- [ ] App Store Connect metadata complete before upload
- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`) included if required by Apple

---

## Useful References

| Resource | URL |
|----------|-----|
| Godot 4 Exporting for Desktop | https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_pc.html |
| Godot 4 Exporting for Android | https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html |
| Godot 4 Exporting for iOS | https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html |
| SteamCMD Documentation | https://developer.valvesoftware.com/wiki/SteamCMD |
| Steamworks SDK — App Builds | https://partner.steamgames.com/doc/sdk/uploading |
| Steamworks — Depots | https://partner.steamgames.com/doc/store/application/depots |
