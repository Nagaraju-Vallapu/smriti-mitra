import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../localization/supported_locales.dart';

enum VoiceState { idle, listening, processing, speaking, error }

/// Isolates all speech I/O behind one service so screens never touch
/// flutter_tts / speech_to_text directly. Both engines are optional at
/// runtime: if a device or language isn't supported, VoiceState.error is
/// surfaced instead of throwing, and the rest of the app keeps working —
/// per the "gracefully handle unsupported devices" requirement.
class VoiceService extends ChangeNotifier {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  VoiceState _state = VoiceState.idle;
  VoiceState get state => _state;

  bool _sttAvailable = false;
  bool _ttsInitialized = false;
  String _languageCode = 'en';
  double _speechRate = 0.45;

  String _lastRecognizedText = '';
  String get lastRecognizedText => _lastRecognizedText;

  void _setState(VoiceState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> initialize() async {
    try {
      _sttAvailable = await _stt.initialize(
        onError: (_) => _setState(VoiceState.error),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_state == VoiceState.listening) _setState(VoiceState.idle);
          }
        },
      );
    } catch (_) {
      _sttAvailable = false;
    }
    _ttsInitialized = true;
  }

  bool get isListeningSupported => _sttAvailable;

  void setLanguage(String code) {
    _languageCode = code;
  }

  void setSpeechRate(double rate) {
    _speechRate = rate;
  }

  /// Speaks [text]. Falls back to [VoiceState.error] silently (no crash,
  /// no exception surfaced to the caller) if TTS or the requested locale
  /// isn't available on this device — this is the expected path for
  /// Assamese/Manipuri on most devices today.
  Future<void> speak(String text) async {
    if (!_ttsInitialized) await initialize();

    final ttsLocale = languageForCode(_languageCode).ttsLocale;
    if (ttsLocale == null) {
      _setState(VoiceState.error);
      return;
    }

    try {
      _setState(VoiceState.speaking);
      await _tts.setLanguage(ttsLocale);
      await _tts.setSpeechRate(_speechRate);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
      _setState(VoiceState.idle);
    } catch (_) {
      _setState(VoiceState.error);
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {
      // no-op: nothing to stop
    }
    if (_state == VoiceState.speaking) _setState(VoiceState.idle);
  }

  /// Starts listening for a voice command. [onResult] receives the
  /// recognized text once available; the caller is responsible for
  /// interpreting it (see VoiceCommandInterpreter in the widget layer).
  Future<void> startListening({required void Function(String text) onResult}) async {
    if (!_ttsInitialized) await initialize();

    if (!_sttAvailable) {
      _setState(VoiceState.error);
      return;
    }

    try {
      _setState(VoiceState.listening);
      await _stt.listen(
        onResult: (result) {
          _lastRecognizedText = result.recognizedWords;
          if (result.finalResult) {
            _setState(VoiceState.processing);
            onResult(result.recognizedWords);
            _setState(VoiceState.idle);
          }
        },
        listenFor: const Duration(seconds: 8),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (_) {
      _setState(VoiceState.error);
    }
  }

  Future<void> stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {
      // no-op
    }
    if (_state == VoiceState.listening) _setState(VoiceState.idle);
  }
}

/// Very small keyword matcher for the required example commands. Kept
/// separate from VoiceService so the recognition engine and the command
/// vocabulary can evolve independently.
class VoiceCommandInterpreter {
  static const openReminders = 'open_reminders';
  static const openGames = 'open_games';
  static const openProgress = 'open_progress';
  static const goHome = 'go_home';

  static String? interpret(String recognizedText) {
    final text = recognizedText.toLowerCase();
    if (text.contains('reminder')) return openReminders;
    if (text.contains('game')) return openGames;
    if (text.contains('progress')) return openProgress;
    if (text.contains('home')) return goHome;
    return null;
  }
}
