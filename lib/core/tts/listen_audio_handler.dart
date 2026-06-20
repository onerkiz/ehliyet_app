import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import '../../data/models/question.dart';
import '../../data/repositories/progress_repository.dart';
import 'tts_service.dart';

/// main()'de AudioService.init ile kurulur; null = platform desteklemiyor (web vb.).
ListenAudioHandler? gListenHandler;

/// Arka planda (ekran kapalı) çalışan dinleme oynatıcısı.
/// audio_service bildirim/kilit ekranı/kulaklık kontrollerini sağlar;
/// gerçek okumayı [TtsService] (offline cihaz sesi) yapar.
class ListenAudioHandler extends BaseAudioHandler {
  final ProgressRepository repo;
  ListenAudioHandler(this.repo);

  List<Question> _queue = [];
  String _setTitle = 'Dinleme Modu';
  String _resumeKey = 'all';
  int _index = 0;
  int _gen = 0;
  bool _playing = false;
  Timer? _sleepTimer;

  // UI'nin dinlediği durum.
  final ValueNotifier<int> indexN = ValueNotifier<int>(0);
  final ValueNotifier<bool> answerN = ValueNotifier<bool>(false);
  final ValueNotifier<int?> sleepMinN = ValueNotifier<int?>(null);

  // Ayarlar.
  bool readExpl = true;
  int pauseMs = 600;
  bool repeat = false;
  bool shuffle = false;

  void loadQueue(
      List<Question> qs, String title, String resumeKey, int start) {
    // Aynı set zaten yüklüyse dokunma (resume korunur).
    if (_resumeKey == resumeKey && _queue.length == qs.length && _queue.isNotEmpty) {
      return;
    }
    _gen++;
    _playing = false;
    _queue = List.of(qs);
    _setTitle = title;
    _resumeKey = resumeKey;
    _index = qs.isEmpty ? 0 : start.clamp(0, qs.length - 1);
    indexN.value = _index;
    answerN.value = false;
    _updateMedia();
    _emit(false);
  }

  void _updateMedia() {
    if (_queue.isEmpty) return;
    mediaItem.add(MediaItem(
      id: '$_resumeKey-$_index',
      album: 'Ehliyet Sınav',
      title: _setTitle,
      artist: 'Soru ${_index + 1} / ${_queue.length}',
    ));
  }

  void _emit(bool playing) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      processingState: AudioProcessingState.ready,
      playing: playing,
      queueIndex: _index,
    ));
  }

  bool _alive(int g) => _playing && g == _gen && _index < _queue.length;

  String _answerSpeech(Question q) {
    final harf = String.fromCharCode(65 + q.correctAnswer);
    final e = q.explanation;
    return 'Doğru cevap: $harf şıkkı.${(readExpl && e != null) ? ' $e' : ''}';
  }

  @override
  Future<void> play() async {
    if (_playing || _queue.isEmpty) return;
    _playing = true;
    _emit(true);
    final g = ++_gen;

    while (_alive(g)) {
      final q = _queue[_index];
      indexN.value = _index;
      answerN.value = false;
      _updateMedia();
      _emit(true);
      await TtsService.instance
          .speak(TtsService.buildQuestionSpeech(q.text, q.options));
      if (!_alive(g)) break;
      await Future.delayed(const Duration(milliseconds: 400));
      if (!_alive(g)) break;

      answerN.value = true;
      await TtsService.instance.speak(_answerSpeech(q));
      if (!_alive(g)) break;
      await Future.delayed(Duration(milliseconds: pauseMs));
      if (!_alive(g)) break;

      var next = _index + 1;
      if (next >= _queue.length) {
        if (repeat) {
          if (shuffle) _queue.shuffle();
          next = 0;
        } else {
          _index = _queue.length; // bitti
          break;
        }
      }
      _index = next;
      await repo.setListenIndex(_resumeKey, _index);
    }

    _playing = false;
    if (_index >= _queue.length) {
      _index = 0;
      await repo.setListenIndex(_resumeKey, 0);
      indexN.value = 0;
    }
    _emit(false);
  }

  @override
  Future<void> pause() async {
    _playing = false;
    _gen++;
    await TtsService.instance.stop();
    _emit(false);
  }

  @override
  Future<void> stop() async {
    _playing = false;
    _gen++;
    _sleepTimer?.cancel();
    _sleepTimer = null;
    sleepMinN.value = null;
    await TtsService.instance.stop();
    _emit(false);
    await super.stop();
  }

  @override
  Future<void> skipToNext() => _jump(1);

  @override
  Future<void> skipToPrevious() => _jump(-1);

  Future<void> _jump(int d) async {
    if (_queue.isEmpty) return;
    final was = _playing;
    if (was) await pause();
    _index = (_index + d).clamp(0, _queue.length - 1);
    answerN.value = false;
    indexN.value = _index;
    await repo.setListenIndex(_resumeKey, _index);
    _updateMedia();
    if (was) await play();
  }

  // --- Ayar değiştiriciler ---
  void setReadExpl(bool v) => readExpl = v;
  void setPauseMs(int ms) => pauseMs = ms;
  void setRepeat(bool v) => repeat = v;

  Future<void> setShuffle(bool v) async {
    shuffle = v;
    if (v && _queue.isNotEmpty) {
      final was = _playing;
      if (was) await pause();
      _queue.shuffle();
      _index = 0;
      indexN.value = 0;
      answerN.value = false;
      await repo.setListenIndex(_resumeKey, 0);
      _updateMedia();
      if (was) await play();
    }
  }

  /// Uyku zamanlayıcı: [min] dakika sonra duraklat. null = kapat.
  void setSleepMinutes(int? min) {
    _sleepTimer?.cancel();
    if (min == null) {
      sleepMinN.value = null;
      return;
    }
    sleepMinN.value = min;
    _sleepTimer = Timer(Duration(minutes: min), () {
      sleepMinN.value = null;
      pause();
    });
  }
}
