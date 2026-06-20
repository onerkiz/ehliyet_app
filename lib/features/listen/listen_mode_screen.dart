import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/tts/tts_service.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';

/// "Dinleme Modu" — eller serbest sesli çalışma.
/// Soruyu + şıkları okur → doğru cevabı + açıklamayı okur → otomatik sonraki soru.
/// Ses ve hız seçilebilir; yarım kalırsa kaldığı yerden devam eder.
class ListenModeScreen extends ConsumerStatefulWidget {
  const ListenModeScreen({super.key});

  @override
  ConsumerState<ListenModeScreen> createState() => _ListenModeScreenState();
}

/// Hız çarpanı → flutter_tts rate (Android'de ~0.5 normal).
double _rateFor(double mult) =>
    mult >= 2.0 ? 0.95 : (mult >= 1.5 ? 0.72 : 0.5);

class _ListenModeScreenState extends ConsumerState<ListenModeScreen> {
  List<Question>? _questions;
  int _index = 0;
  bool _playing = false;
  bool _showAnswer = false;
  int _runToken = 0; // çalışan döngüyü iptal etmek için

  List<Map<String, String>> _voices = const [];
  String? _voice;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(progressRepositoryProvider);
    _index = repo.listenIndex();
    _voice = repo.ttsVoice();
    _speed = repo.ttsSpeed();
    _initTts();
  }

  Future<void> _initTts() async {
    final voices = await TtsService.instance.loadTurkishVoices();
    if (_voice != null) await TtsService.instance.setVoiceName(_voice!);
    await TtsService.instance.setRate(_rateFor(_speed));
    if (mounted) {
      setState(() {
        _voices = voices;
        _voice ??= TtsService.instance.currentVoice;
      });
    }
  }

  @override
  void dispose() {
    _runToken++;
    TtsService.instance.stop();
    super.dispose();
  }

  String _answerSpeech(Question q) {
    final harf = String.fromCharCode(65 + q.correctAnswer);
    final expl = q.explanation;
    return 'Doğru cevap: $harf şıkkı.${expl != null ? ' $expl' : ''}';
  }

  Future<void> _play() async {
    final qs = _questions;
    if (qs == null || qs.isEmpty) return;
    if (_index >= qs.length) _index = 0;
    final token = ++_runToken;
    setState(() => _playing = true);

    while (_playing && token == _runToken && _index < qs.length) {
      final q = qs[_index];
      setState(() => _showAnswer = false);
      await TtsService.instance
          .speak(TtsService.buildQuestionSpeech(q.text, q.options));
      if (!_playing || token != _runToken) break;
      await Future.delayed(const Duration(milliseconds: 400));
      if (!_playing || token != _runToken) break;

      setState(() => _showAnswer = true);
      await TtsService.instance.speak(_answerSpeech(q));
      if (!_playing || token != _runToken) break;
      await Future.delayed(const Duration(milliseconds: 700));
      if (!_playing || token != _runToken) break;

      _index++;
      await ref.read(progressRepositoryProvider).setListenIndex(_index);
      if (mounted) setState(() {});
    }

    if (token == _runToken && mounted) {
      if (_index >= qs.length) {
        _index = 0;
        await ref.read(progressRepositoryProvider).setListenIndex(0);
      }
      setState(() => _playing = false);
    }
  }

  void _pause() {
    _runToken++;
    TtsService.instance.stop();
    setState(() => _playing = false);
  }

  Future<void> _jump(int delta) async {
    final qs = _questions;
    if (qs == null || qs.isEmpty) return;
    final wasPlaying = _playing;
    _pause();
    setState(() {
      _index = (_index + delta).clamp(0, qs.length - 1);
      _showAnswer = false;
    });
    await ref.read(progressRepositoryProvider).setListenIndex(_index);
    if (wasPlaying) _play();
  }

  Future<void> _pickVoice(String name) async {
    _pause();
    await TtsService.instance.setVoiceName(name);
    await ref.read(progressRepositoryProvider).setTtsVoice(name);
    setState(() => _voice = name);
    // Önizleme
    await TtsService.instance
        .speak('Ehliyet sınavına dinleyerek hazırlan. Bu ses bu şekilde.');
  }

  Future<void> _setSpeed(double mult) async {
    setState(() => _speed = mult);
    await TtsService.instance.setRate(_rateFor(mult));
    await ref.read(progressRepositoryProvider).setTtsSpeed(mult);
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dinleme Modu')),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (all) {
          _questions ??= all;
          final qs = _questions!;
          if (qs.isEmpty) {
            return const Center(child: Text('Soru bulunamadı.'));
          }
          if (_index >= qs.length) _index = 0;
          final q = qs[_index];
          return Column(
            children: [
              _ControlsBar(
                voices: _voices,
                voice: _voice,
                speed: _speed,
                onVoice: _pickVoice,
                onSpeed: _setSpeed,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Soru ${_index + 1} / ${qs.length}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    AppCard(
                      child: Text(q.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600, height: 1.4)),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(q.options.length, (i) {
                      final isCorrect = i == q.correctAnswer;
                      final highlight = _showAnswer && isCorrect;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: highlight
                                ? AppColors.greenLight
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: highlight
                                  ? AppColors.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: highlight ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: highlight
                                      ? AppColors.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                ),
                                child: Text(String.fromCharCode(65 + i),
                                    style: TextStyle(
                                        color: highlight
                                            ? Colors.white
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(q.options[i],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium)),
                              if (highlight)
                                const Icon(Icons.check_circle,
                                    color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    }),
                    if (_showAnswer && q.explanation != null) ...[
                      const SizedBox(height: 4),
                      AppCard(
                        color: AppColors.greenLight,
                        shadow: const [],
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                size: 18, color: AppColors.primaryDark),
                            const SizedBox(width: 8),
                            Expanded(child: Text(q.explanation!)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _PlaybackBar(
                playing: _playing,
                onPrev: _index > 0 ? () => _jump(-1) : null,
                onNext: _index < qs.length - 1 ? () => _jump(1) : null,
                onToggle: () => _playing ? _pause() : _play(),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Ses + hız kontrolleri (üst bar).
class _ControlsBar extends StatelessWidget {
  final List<Map<String, String>> voices;
  final String? voice;
  final double speed;
  final ValueChanged<String> onVoice;
  final ValueChanged<double> onSpeed;
  const _ControlsBar({
    required this.voices,
    required this.voice,
    required this.speed,
    required this.onVoice,
    required this.onSpeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
            bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.record_voice_over_outlined, size: 18),
              const SizedBox(width: 6),
              const Text('Ses', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              if (voices.isEmpty)
                const Expanded(
                    child: Text('Cihazda Türkçe ses bulunamadı',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)))
              else
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: voices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final v = voices[i]['name']!;
                        final sel = v == voice;
                        return ChoiceChip(
                          label: Text('Ses ${i + 1}'),
                          selected: sel,
                          onSelected: (_) => onVoice(v),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.speed, size: 18),
              const SizedBox(width: 6),
              const Text('Hız', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              for (final s in const [1.0, 1.5, 2.0]) ...[
                ChoiceChip(
                  label: Text(s == 1.0
                      ? '1x'
                      : s == 1.5
                          ? '1.5x'
                          : '2x'),
                  selected: speed == s,
                  onSelected: (_) => onSpeed(s),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Alt oynatma çubuğu (önceki / oynat-duraklat / sonraki).
class _PlaybackBar extends StatelessWidget {
  final bool playing;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onToggle;
  const _PlaybackBar({
    required this.playing,
    required this.onPrev,
    required this.onNext,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              iconSize: 28,
              onPressed: onPrev,
              icon: const Icon(Icons.skip_previous),
            ),
            FloatingActionButton(
              onPressed: onToggle,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              child: Icon(playing ? Icons.pause : Icons.play_arrow, size: 32),
            ),
            IconButton.filledTonal(
              iconSize: 28,
              onPressed: onNext,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
      ),
    );
  }
}
