import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import '../navigation/app_state.dart';

/// Hand-rolled localization for ALL app content (every button, label,
/// and message) — loads assets/i18n/<code>.json, a flat key-value map,
/// fully populated for all five required languages including Assamese
/// and Manipuri.
///
/// Deliberately NOT implemented as a Flutter `LocalizationsDelegate`.
/// Flutter's built-in `GlobalMaterialLocalizations` /
/// `GlobalCupertinoLocalizations` packages do not ship translations for
/// Assamese or Manipuri, and routing our own strings through that same
/// resolution pipeline risks `Localizations.of<MaterialLocalizations>`
/// returning null for those locales, which can crash built-in widgets
/// like the time picker. Instead, AppState loads the JSON directly (see
/// navigation/app_state.dart) and this class just reads it back out via
/// Provider — completely independent of Flutter's own locale
/// resolution. MaterialApp's `locale`/`supportedLocales` in main.dart
/// stay on a conservative, framework-safe set so built-in widget chrome
/// never crashes; see the comment there for how that gracefully falls
/// back for the two unsupported languages — the same pattern used for
/// voice/TTS elsewhere in the app.
///
/// Usage in a widget: `AppLocalizations.of(context).t('games_title')`
class AppLocalizations {
  final Locale locale;
  final Map<String, String> strings;

  const AppLocalizations(this.locale, this.strings);

  static const empty = AppLocalizations(Locale('en'), {});

  /// Translate a key. Falls back to the raw key (visibly, on purpose) if
  /// missing, so untranslated strings are obvious during development
  /// instead of silently blank.
  String t(String key) => strings[key] ?? key;

  /// Reads the current AppLocalizations from AppState. Subscribes via
  /// `context.watch`, so widgets calling this in `build()` rebuild
  /// automatically when the language changes — the same ergonomics as
  /// Flutter's own `Localizations.of(context)` pattern.
  static AppLocalizations of(BuildContext context) {
    return context.watch<AppState>().localizations;
  }
}

/// Loads a language's JSON asset into a flat string map. Called by
/// AppState on init and on every language change.
Future<Map<String, String>> loadLocaleStrings(String languageCode) async {
  final raw = await rootBundle.loadString('assets/i18n/$languageCode.json');
  final Map<String, dynamic> decoded = json.decode(raw) as Map<String, dynamic>;
  return decoded.map((key, value) => MapEntry(key, value.toString()));
}
