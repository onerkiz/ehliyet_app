import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_tts/flutter_tts.dart';

/// "Dinleyerek Çalış" — soru ve şıkları sesli okur (cihazın TTS motoru, offline).
/// Web'de ve TTS yoksa sessizce no-op olur.
///
/// NOT: Samsung cihazlarda varsayılan motor Türkçe'yi yanlış telaffuz edebiliyor
/// → Google TTS + OFFLINE (-local) Türkçe ses tercih ediyoruz.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  static const _googleEngine = 'com.google.android.tts';

  FlutterTts? _tts;
  bool _initialized = false;
  bool _speaking = false;
  List<Map<String, String>> _trVoices = const [];
  String? _currentVoice;
  double _rate = 0.5; // 1x

  bool get isSpeaking => _speaking;
  List<Map<String, String>> get turkishVoices => _trVoices;
  String? get currentVoice => _currentVoice;

  Future<void> _ensureInit() async {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    try {
      final tts = FlutterTts();

      // Google TTS motorunu seç (Türkçe telaffuzu doğru).
      try {
        final engines = (await tts.getEngines) as List?;
        if (engines != null && engines.contains(_googleEngine)) {
          await tts.setEngine(_googleEngine);
        }
      } catch (e) {
        debugPrint('[TTS] setEngine hata: $e');
      }

      await tts.setLanguage('tr-TR');

      // Offline Türkçe sesleri topla (-local).
      try {
        final voices = (await tts.getVoices) as List?;
        if (voices != null) {
          _trVoices = voices
              .whereType<Map>()
              .where((v) =>
                  (v['locale']?.toString().toLowerCase().startsWith('tr') ??
                      false) &&
                  v['name'].toString().toLowerCase().contains('local'))
              .map((v) => {
                    'name': v['name'].toString(),
                    'locale': v['locale'].toString(),
                  })
              .toList();
        }
        debugPrint('[TTS] offline tr voices=${_trVoices.map((v) => v['name']).toList()}');
      } catch (e) {
        debugPrint('[TTS] getVoices hata: $e');
      }

      _tts = tts;
      await _applyVoice();
      await tts.setPitch(1.0);
      await tts.setSpeechRate(_rate);
      await tts.awaitSpeakCompletion(true);
      tts.setCompletionHandler(() => _speaking = false);
      tts.setCancelHandler(() => _speaking = false);
      tts.setErrorHandler((_) => _speaking = false);
    } catch (e) {
      debugPrint('[TTS] init hata: $e');
      _tts = null;
    }
  }

  Future<void> _applyVoice() async {
    final tts = _tts;
    if (tts == null) return;
    // Seçili ses yoksa ilk offline sesi kullan.
    final name = _currentVoice ??
        (_trVoices.isNotEmpty ? _trVoices.first['name'] : null);
    if (name == null) return;
    final v = _trVoices.firstWhere((e) => e['name'] == name,
        orElse: () => _trVoices.isNotEmpty ? _trVoices.first : {});
    if (v.isEmpty) return;
    try {
      await tts.setVoice({'name': v['name']!, 'locale': v['locale']!});
      _currentVoice = v['name'];
      debugPrint('[TTS] voice=${v['name']}');
    } catch (e) {
      debugPrint('[TTS] setVoice hata: $e');
    }
  }

  /// Picker için: cihazdaki offline Türkçe sesler. (init'i tetikler)
  Future<List<Map<String, String>>> loadTurkishVoices() async {
    await _ensureInit();
    return _trVoices;
  }

  Future<void> setVoiceName(String name) async {
    await _ensureInit();
    _currentVoice = name;
    await _applyVoice();
  }

  /// Hız: 0.0–1.0 (Android'de ~0.5 normal). 1x≈0.5, 1.5x≈0.72, 2x≈0.95.
  Future<void> setRate(double rate) async {
    await _ensureInit();
    _rate = rate;
    try {
      await _tts?.setSpeechRate(rate);
    } catch (_) {}
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

  /// Konuş ve bitene kadar bekle (awaitSpeakCompletion=true sayesinde).
  /// Pause/stop çağrılırsa erken döner.
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
