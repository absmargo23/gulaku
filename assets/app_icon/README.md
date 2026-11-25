# Launcher icon assets

Add these source images before generating platform resources:

- `icon.png`: opaque 1024x1024 image with the white drop on `#0F9D8A`.
- `icon_foreground.png`: transparent 1024x1024 image containing only the white drop, centered with adaptive-icon safe margins.
- `splash_logo.png`: transparent drop logo sized for the light and dark native splash backgrounds.

The configured generation commands are `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
