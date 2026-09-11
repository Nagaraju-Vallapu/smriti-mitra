# Smriti Mitra — Flutter Frontend

Frontend-only Flutter/Dart conversion of the elderly cognitive-care companion
app, with a linked caregiver experience. Runs entirely offline on local
storage — no backend required to build, run, or demo.

## ⚠️ Verification status — read this first

This sandbox's network allowlist does **not** include `pub.dev` (Flutter's
package registry) or Flutter's SDK storage host — both returned `403` when
tested. That means I could not run `flutter pub get`, `flutter analyze`,
`flutter test`, or `flutter build` here, unlike the earlier React Native
version where `tsc --noEmit` gave a real, verified compile pass.

What I *did* do to compensate:
- Every `.dart` file has verified balanced braces/parens (scripted check).
- Every relative `import` path was verified to resolve to a real file
  (scripted check).
- Every file using `BuildContext`/`Widget` imports `material.dart`; every
  file using `context.watch`/`context.read` imports `provider`.
- No duplicate top-level class/enum names across files.
- All 5 locale JSON files were validated as syntactically correct JSON
  with **identical key sets** (131 keys each, scripted check).
- I hand-traced every cross-file symbol reference (services, models,
  widgets) rather than relying on an analyzer.
- I raised the Flutter SDK floor to 3.24 specifically because
  `ThemeData.cardTheme` changed type (`CardTheme` → `CardThemeData`)
  around that version, and I wanted zero ambiguity rather than guessing.

What this **doesn't** replace: a real compiler catches things careful
reading can't (typos in method signatures, subtle type mismatches, null
safety violations). **Before you consider this done, run:**

```bash
flutter create .        # generates android/, ios/, web/ platform folders
                         # for YOUR installed Flutter version — I removed
                         # my own hand-attempt at these since getting
                         # Gradle/Xcode project files exactly right by
                         # hand, unverified, would be worse than not
                         # including them at all
flutter pub get
flutter analyze
flutter test
flutter run              # or: flutter build apk
```

If `flutter analyze` surfaces anything, most likely candidates given how
this was built: a Material widget API that shifted between Flutter
versions (I flagged the one I was already unsure about above), or a
`speech_to_text`/`flutter_tts` API surface change (I could not check
their current API against pub.dev either). Everything else — the
architecture, the GamePerformance contract, the localization content,
the game logic — was written and traced by hand with the same care as
the React Native version; it just didn't get a compiler's final say.

## The GamePerformance contract

`lib/models/game_performance.dart` defines exactly the 11 required
fields, snake_case, matching the spec precisely:

```dart
class GamePerformance {
  final String userId;          // user_id
  final String gameId;          // game_id
  final String sessionId;       // session_id
  final String difficultyLevel; // difficulty_level
  final int score;              // score
  final double accuracy;        // accuracy (0–100)
  final int mistakes;           // mistakes
  final int completionTime;     // completion_time (seconds)
  final int attempts;           // attempts
  final bool completed;         // completed
  final String timestamp;       // timestamp (ISO 8601)
}
```

`toJson()`/`fromJson()` use the exact snake_case keys — this is the wire
format for the future backend. A unit test
(`test/game_performance_test.dart`) asserts the JSON key set is exactly
these 11 fields, round-trips correctly, and that `accuracy` is
constrained to 0–100 (via a Dart `assert`, active in debug/test builds).

All three games — Memory Match, Pattern Recall, Routine Order — construct
this same object and submit it through **one** centralized service,
`GamePerformanceService` (`lib/services/game_performance_service.dart`).
Nothing else creates or shapes performance data.

## Data flow / backend integration points

```
Flutter game screen
  → GamePerformance object
  → GamePerformanceService.submit()
  → saved locally (SharedPreferences, offline-first)
  → [TODO(backend)] POST to the real API
  → Database → ML → recommended difficulty
  → [TODO(ml)] surfaced back via getRecommendedDifficulty()
```

Both TODOs are marked with `// TODO(backend)` / `// TODO(ml)` comments in
`game_performance_service.dart`. `getRecommendedDifficulty()` currently
returns a transparent, clearly-labeled local heuristic (recent-accuracy
average) — **not** a real ML model — so the UI has something sensible to
show without pretending it's AI-driven, per the spec's explicit
instruction not to fake AI/ML.

`CaregiverService` (`lib/services/caregiver_service.dart`) reads from the
exact same `GamePerformanceService` records as the elderly Progress
screen — no parallel performance schema exists anywhere in the app.

## Project structure

```
lib/
 ├── main.dart              App entry, theme/locale wiring, routes
 ├── models/                GamePerformance + all other data models
 ├── services/
 │    ├── game_performance_service.dart   ← centralized, all 3 games use it
 │    ├── reminder_service.dart
 │    ├── caregiver_service.dart
 │    ├── accessibility_service.dart
 │    ├── voice_service.dart              TTS + STT, graceful fallback
 │    ├── storage_service.dart            single SharedPreferences wrapper
 │    └── mock/             Caregiver demo data (clearly isolated)
 ├── screens/
 │    ├── language_selection_screen.dart
 │    ├── user_selection_screen.dart
 │    ├── elderly/          Home, Games (3), Reminders, Progress
 │    ├── caregiver/        Dashboard, Performance, Alerts, Patient
 │    └── common/           settings_screen.dart — shared by both roles
 ├── navigation/
 │    └── app_state.dart    Language/role/accessibility state + persistence
 ├── localization/          Custom key-based i18n (see below)
 ├── widgets/                Shared UI: buttons, cards, result view, etc.
 ├── theme/                 Standard + High-Contrast palettes, type scale
 └── utils/                 IDs, dates, route names, shared constants

assets/i18n/{en,hi,te,as,mni}.json   131 keys each, all 5 languages
test/game_performance_test.dart      Contract unit tests
```

## Why localization isn't `flutter gen-l10n`-based

Flutter's official localization workflow generates Dart code from `.arb`
files via `flutter gen-l10n` — a build step I can't run here (no Flutter
SDK). So `lib/localization/` is a small hand-written system instead:
`assets/i18n/<code>.json` is a flat key→string map, loaded by `AppState`
on startup and language change, exposed via
`AppLocalizations.of(context).t('key')`. No code generation involved —
nothing to regenerate, no build_runner step, works identically whether or
not this environment's tooling is available.

**Important nuance:** Flutter's own built-in widgets (date/time pickers,
back-button tooltips) get their strings from
`GlobalMaterialLocalizations`/`GlobalCupertinoLocalizations`, which do
**not** ship Assamese or Manipuri translations — Flutter itself doesn't
support those languages at the framework level. Wiring our own content
through the same resolution pipeline risked crashing those widgets on
those two languages. So `main.dart` deliberately decouples: our own app
content (every screen, button, label) is 100% translated in all 5
languages via `AppState`, independent of Flutter's locale resolution;
Flutter's *own* widget chrome falls back to English for Assamese/Manipuri
specifically (`_materialSafeLocale` in `main.dart`) — the same
"graceful fallback for unsupported platform capability" pattern used for
voice/TTS.

## Voice assistance

`VoiceService` (ChangeNotifier) exposes exactly the five required states
— `idle`, `listening`, `processing`, `speaking`, `error` — backed by
`flutter_tts` (speak) and `speech_to_text` (listen). Both are wrapped in
try/catch; if STT isn't available on a device, or a language has no TTS
locale mapped (Assamese/Manipuri — see `supported_locales.dart`), the
service surfaces `VoiceState.error` instead of throwing. The modal sheet
(`widgets/voice_assistant_sheet.dart`) is opened from a floating mic
button on both the Elderly and Caregiver shells and recognizes the four
required example commands ("open reminders", "open games", "open
progress", "go home") via simple keyword matching in
`VoiceCommandInterpreter`.

## Accessibility

`AccessibilitySettings` persists text size (small/normal/large/extra
large), high contrast, voice assistance on/off, voice speed, and
reminder-notification toggle. Text size drives a real scale factor
applied across the whole type scale in `buildAppTheme()`; High Contrast
swaps the entire color palette (`AppColors.standard` ↔
`AppColors.highContrast`), not a visual filter — both are wired through
Settings and take effect immediately app-wide via `Provider`.

## Offline support

Everything the spec requires to persist offline does, via
`StorageService` (the single `SharedPreferences` wrapper): language,
role, accessibility settings, reminders, and game performance records.
"Clear Offline Data" in Settings wipes reminders + game performance
(with a confirmation dialog) but deliberately leaves language/role
intact — losing your language on top of your data would compound the
disruption for an elderly user.

## What's NOT included (by design, per spec)

- Backend, database, or real ML implementation
- Real authentication (role selection stands in for auth in this
  frontend-only build)
- `android/`, `ios/`, `web/` platform folders — run `flutter create .`
  locally to generate them for your Flutter version (see top of this
  file)
