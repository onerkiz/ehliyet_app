import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

/// "Dinleyerek Çalış" — soru ve şıkları sesli okur (cihazın TTS motoru, offline).
/// Web'de ve TTS yoksa sessizce no-op olur.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  FlutterTts? _tts;
  bool _initialized = false;
  bool _speaking = false;

  bool get isSpeaking => _speaking;

  Future<void> _ensureInit() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    try {
      final tts = FlutterTts();
      await tts.setLanguage('tr-TR');
      await tts.setSpeechRate(0.45); // sınav çalışması için anlaşılır tempo
      await tts.setPitch(1.0);
      await tts.awaitSpeakCompletion(true);
      tts.setCompletionHandler(() => _speaking = false);
      tts.setCancelHandler(() => _speaking = false);
      tts.setErrorHandler((_) => _speaking = false);
      _tts = tts;
    } catch (_) {
      _tts = null;
    }
  }

  /// Soru + şıkları okunabilir tek metne çevirir.
  static String buildQuestionSpeech(String text, List<String> options) {
    final buffer = StringBuffer(text);
    for (var i = 0; i < options.length; i++) {
      final harf = String.fromCharCode(65 + i); // A, B, C, D
      buffer.write('. $harf şıkkı: ${options[i]}');
    }
    return buffer.toString();
  }

  Future<void> speak(String text) async {
    if (kIsWeb || text.trim().isEmpty) return;
    await _ensureInit();
    final tts = _tts;
    if (tts == null) return;
    try {
      await tts.stop();
      _speaking = true;
      await tts.speak(text);
    } catch (_) {
      _speaking = false;
    }
  }

  Future<void> stop() async {
    _speaking = false;
    try {
      await _tts?.stop();
    } catch (_) {}
  }
}
