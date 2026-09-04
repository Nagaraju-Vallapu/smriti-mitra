import 'package:flutter/material.dart';

class AppLanguage {
  final String code; // ISO-ish code used as the asset filename and Locale
  final String label; // Shown in the language picker, in its own script
  final String? ttsLocale; // BCP-47 tag passed to flutter_tts, if supported

  const AppLanguage({required this.code, required this.label, this.ttsLocale});
}

/// Exactly the five required languages. `ttsLocale` is null for Assamese
/// and Manipuri because on-device TTS/STT engines inconsistently support
/// them — VoiceService checks this and falls back gracefully (see
/// voice_service.dart) instead of assuming every language can be spoken.
const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(code: 'en', label: 'English', ttsLocale: 'en-IN'),
  AppLanguage(code: 'hi', label: 'हिंदी', ttsLocale: 'hi-IN'),
  AppLanguage(code: 'te', label: 'తెలుగు', ttsLocale: 'te-IN'),
  AppLanguage(code: 'as', label: 'অসমীয়া', ttsLocale: null),
  AppLanguage(code: 'mni', label: 'মৈতৈলোন্', ttsLocale: null),
];

const List<Locale> kSupportedLocales = [
  Locale('en'),
  Locale('hi'),
  Locale('te'),
  Locale('as'),
  Locale('mni'),
];

AppLanguage languageForCode(String code) => kSupportedLanguages.firstWhere(
      (l) => l.code == code,
      orElse: () => kSupportedLanguages.first,
    );
