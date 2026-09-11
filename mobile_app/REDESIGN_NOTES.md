# Smriti Mitra — UI Redesign Notes

Everything below is a **UI-only** change. No file was renamed, no class/function/variable
was renamed, no route, service, model, or business logic was touched. Every screen still
navigates, saves, and behaves exactly as before.

## New files
- `lib/widgets/ne_background.dart` — the Northeast-India scenic backdrop (layered
  mountains, bamboo & leaf motifs, small floral accents, woven-textile pattern strips).
  Purely decorative; automatically disables itself under the High Contrast palette so
  accessibility is never compromised.
- `lib/widgets/icon_tile.dart` — the colourful rounded icon-tile used for feature grids
  and list rows, matching the reference screenshots.

## Updated design-system files (same file names, same public API)
- `lib/theme/app_colors.dart` — new warm cream + deep forest-teal palette. All existing
  field names kept; a few new *optional-style* decorative accent colors were added
  (rose/violet/sky/peach) purely for the icon tiles. High-contrast palette unchanged in
  spirit, just re-balanced to match.
- `lib/theme/app_theme.dart` — rounded 28px cards with soft shadows, pill-shaped large
  buttons, and a transparent app bar so the new background shows through seamlessly.
- `lib/theme/app_spacing.dart` — added `AppRadii.xl` for the bigger card radius.
- `lib/widgets/ne_pattern_strip.dart` — unchanged code, now reads the new palette.

## Screens
Every screen that owns a `Scaffold` (21 files, including both the Elderly and Caregiver
bottom-nav shells) had its `body:` wrapped with `NeBackground(child: ...)` — a
one-line, additive change per file. Because the two shells wrap the tab `IndexedStack`,
this single change gives the scenic background to *every* tab screen (Home, Games,
Reminders, Progress, Settings, Dashboard, Performance, Alerts, Patient) automatically.

In addition, these screens got hand-styled colourful icon tiles / minor accent polish to
match the reference more closely:
- `elderly_home_screen.dart` — feature grid tiles
- `games_list_screen.dart` — game row icons
- `reminders_screen.dart` — category row + reminder card icons
- `caregiver_dashboard_screen.dart` — shortcut card icons
- `caregiver_alerts_screen.dart` — alert row icon
- `caregiver_patient_screen.dart` — patient header avatar
- `caregiver_performance_screen.dart` — score colour + progress bar styling
- `progress_screen.dart` — session row icon + score colour
- `settings_screen.dart` — profile row icon
- `language_selection_screen.dart` — per-language colour-coded tile
- `user_selection_screen.dart` — large role icon tiles

All other screens (auth login/register/forgot-password, reminder category/add-edit,
game difficulty, memory match/pattern recall/routine order, profile) automatically pick
up the new rounded cards, pill buttons, palette, and scenic background without any
further edits, since they build on the shared `AppCard` / `AppButton` / theme.

## A note on verification
This sandbox does not have the Flutter SDK installed, so the changes could not be
compiled or run here. Every edit was checked by hand (balanced parens/braces across the
whole `lib/` tree, import-completeness checks, and manual review of each modified file),
but please run `flutter analyze` / `flutter run` after unzipping to catch anything that
slipped through.
