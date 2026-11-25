# Global Rules

- Stack: Flutter (Dart 3), Riverpod, go_router, Drift (SQLite), fl_chart, flutter_svg, pdf + printing, flutter_local_notifications, local_auth.
- Architecture: Clean Architecture (lib/features/<feature>/{presentation,domain,data}), shared code in lib/core.
- All user-facing text in Indonesian. Code, comments, identifiers in English.
- Units: mg/dL. Glucose status is ALWAYS shown with color + icon + text label (never color alone).
- Default ranges (user-configurable): Rendah <70, Normal 70-180, Waspada 181-250, Tinggi >250.
- NEVER give insulin or medication dosing advice. Only logs, trends, and general education with the disclaimer "Aplikasi ini bukan pengganti saran dokter."
- Design: calm, soft colors, large text (min 16sp body, glucose numbers 48sp+), tap targets min 48dp, dark mode, system font scaling up to 200%.
- Colors: primary #0F9D8A, background #F7FAFA, text #1F2D3D, green #2E9E5B, amber #F5A623, red #D64545. Dark: background #121C26, surface #1A2733, accent #5FD3C0.
- Health data is sensitive: no logging of readings, no analytics SDKs, encrypted sensitive storage, explicit consent before any sharing.
- Unit tests for all domain logic. Use const constructors; no hardcoded colors or strings in widgets (use theme and l10n).
