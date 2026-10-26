# Hisup icons

- `app_icon.png`: existing light launcher icon.
- `hisup_mark.svg` / `hisup_mark_dark.svg`: light/dark in-app brand vectors.
- `app_icon_dark.png`: dark icon preview with a background.
- `app_icon_dark_transparent.png`: iOS dark appearance; iOS supplies the background.
- `app_icon_foreground_dark.png`: dark adaptive foreground source.

After editing the dark vector, regenerate the PNGs and Android night resources:

```sh
flutter test --no-pub tool/generate_dark_icons.dart
dart run flutter_launcher_icons
```

The generator configuration in `pubspec.yaml` includes the iOS dark variant.
On iOS 18+, Home Screen icon appearance follows the user's Light/Dark/Automatic
icon preference, independently of the theme selected inside the app.
Android night resources follow system appearance when supported by the launcher.
