import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/tts/listen_audio_handler.dart';
import '../../core/tts/tts_service.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';

/// Dinleme oynatıcısı — seçilen soru setini arka planda (ekran kapalı) okur.
/// Bildirim/kilit ekranı kontrolleri audio_service ile gelir.
class ListenPlayerScreen extends ConsumerStatefulWidget {
  final List<Question> questions;
  final String title;
  final String resumeKey;
  const ListenPlayerScreen({
    super.key,
    required this.questions,
    required this.title,
    required this.resumeKey,
  });

  @override
  ConsumerState<ListenPlayerScreen> createState() => _ListenPlayerScreenState();
}

double _rateFor(double mult) =>
    mult >= 2.0 ? 0.95 : (mult >= 1.5 ? 0.72 : 0.5);

class _ListenPlayerScreenState extends ConsumerState<ListenPlayerScreen> {
  ListenAudioHandler? get _h => gListenHandler;

  List<Map<String, String>> _voices = const [];
  String? _voice;
  double _speed = 1.0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    // Arka plan dinleme bildirimi/kilit ekranı için bildirim izni gerekli.
    await NotificationService.instance.requestPermission();
    final repo = ref.read(progressRepositoryProvider);
    _voice = repo.ttsVoice();
    _speed = repo.ttsSpeed();
    final voices = await TtsService.instance.loadTurkishVoices();
    if (_voice != null) await TtsService.instance.setVoiceName(_voice!);
    await TtsService.instance.setRate(_rateFor(_speed));
    final h = _h;
    if (h != null) {
      h.readExpl = repo.ttsReadExplanation();
      h.loadQueue(widget.questions, widget.title, widget.resumeKey,
          repo.listenIndex(widget.resumeKey));
    }
    if (mounted) {
      setState(() {
        _voices = voices;
        _voice ??= TtsService.instance.currentVoice;
        _ready = true;
      });
    }
  }

  // Ekrandan çıkınca DURDURMA — arka planda çalmaya devam etsin (bildirimle).

  Future<void> _pickVoice(String name) async {
    await _h?.pause();
    await TtsService.instance.setVoiceName(name);
    await ref.read(progressRepositoryProvider).setTtsVoice(name);
    setState(() => _voice = name);
    await TtsService.instance
        .speak('Ehliyet sınavına dinleyerek hazırlan. Bu ses bu şekilde.');
  }

  Future<void> _setSpeed(double mult) async {
    setState(() => _speed = mult);
    await TtsService.instance.setRate(_rateFor(mult));
    await ref.read(progressRepositoryProvider).setTtsSpeed(mult);
  }

  void _openOptions() {
    final h = _h;
    if (h == null) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _OptionsSheet(handler: h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = _h;
    if (h == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text('Bu cihazda arka plan dinleme kullanılamıyor.',
                textAlign: TextAlign.center),
          ),
        ),
      );
    }
    if (!_ready) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final qs = widget.questions;
    if (qs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Bu sette soru bulunamadı.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Seçenekler',
            onPressed: _openOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _TopControls(
            voices: _voices,
            voice: _voice,
            speed: _speed,
            onVoice: _pickVoice,
            onSpeed: _setSpeed,
          ),
          if (_voices.isEmpty) const _NoVoiceHint(),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: h.indexN,
              builder: (context, idx, _) {
                final i = idx.clamp(0, qs.length - 1);
                final q = qs[i];
                return ValueListenableBuilder<bool>(
                  valueListenable: h.answerN,
                  builder: (context, showAnswer, __) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text('Soru ${i + 1} / ${qs.length}',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                        AppCard(
                          child: Text(q.text,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      height: 1.4)),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(q.options.length, (oi) {
                          final correct = oi == q.correctAnswer;
                          final hl = showAnswer && correct;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: hl
                                    ? AppColors.greenLight
                                    : Theme.of(context).colorScheme.surface,
                                border: Border.all(
                                  color: hl
                                      ? AppColors.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: hl ? 2 : 1,
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
                                      color: hl
                                          ? AppColors.primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    ),
                                    child: Text(String.fromCharCode(65 + oi),
                                        style: TextStyle(
                                            color: hl
                                                ? Colors.white
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(q.options[oi],
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium)),
                                  if (hl)
                                    const Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (showAnswer && h.readExpl && q.explanation != null) ...[
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
                    );
                  },
                );
              },
            ),
          ),
          _PlaybackBar(handler: h),
        ],
      ),
    );
  }
}

/// Ses + hız (üst). Açıklama ve diğer ayarlar "Seçenekler" sayfasında.
class _TopControls extends StatelessWidget {
  final List<Map<String, String>> voices;
  final String? voice;
  final double speed;
  final ValueChanged<String> onVoice;
  final ValueChanged<double> onSpeed;
  const _TopControls({
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
              if (voices.isNotEmpty)
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: voices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final v = voices[i]['name']!;
                        return ChoiceChip(
                          label: Text('Ses ${i + 1}'),
                          selected: v == voice,
                          onSelected: (_) => onVoice(v),
                        );
                      },
                    ),
                  ),
                )
              else
                const Spacer(),
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
                  label: Text(s == 1.0 ? '1x' : (s == 1.5 ? '1.5x' : '2x')),
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

class _NoVoiceHint extends StatelessWidget {
  const _NoVoiceHint();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.amber.withValues(alpha: 0.12),
      padding: const EdgeInsets.all(12),
      child: const Text(
        'Cihazında çevrimdışı Türkçe ses bulunamadı. Ayarlar → Erişilebilirlik '
        '→ Metin okuma (TTS) → Google → Türkçe sesi indir.',
        style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
      ),
    );
  }
}

/// Alt oynatma çubuğu — handler durumunu dinler (bildirimden de değişebilir).
class _PlaybackBar extends StatelessWidget {
  final ListenAudioHandler handler;
  const _PlaybackBar({required this.handler});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: StreamBuilder<PlaybackState>(
          stream: handler.playbackState,
          builder: (context, snap) {
            final playing = snap.data?.playing ?? false;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  iconSize: 28,
                  onPressed: handler.skipToPrevious,
                  icon: const Icon(Icons.skip_previous),
                ),
                FloatingActionButton(
                  onPressed: () =>
                      playing ? handler.pause() : handler.play(),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  child: Icon(playing ? Icons.pause : Icons.play_arrow,
                      size: 32),
                ),
                IconButton.filledTonal(
                  iconSize: 28,
                  onPressed: handler.skipToNext,
                  icon: const Icon(Icons.skip_next),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Seçenekler: açıklama, soru arası bekleme, tekrar, karışık, uyku zamanlayıcı.
class _OptionsSheet extends StatefulWidget {
  final ListenAudioHandler handler;
  const _OptionsSheet({required this.handler});

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  @override
  Widget build(BuildContext context) {
    final h = widget.handler;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Seçenekler', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notes_outlined),
            title: const Text('Açıklamayı da oku'),
            value: h.readExpl,
            onChanged: (v) => setState(() => h.setReadExpl(v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.repeat),
            title: const Text('Tekrarla (bitince baştan)'),
            value: h.repeat,
            onChanged: (v) => setState(() => h.setRepeat(v)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.shuffle),
            title: const Text('Karışık sırada'),
            value: h.shuffle,
            onChanged: (v) async {
              await h.setShuffle(v);
              setState(() {});
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 20),
              const SizedBox(width: 8),
              const Text('Soru arası bekleme'),
              const Spacer(),
              for (final ms in const [300, 600, 1500, 3000]) ...[
                ChoiceChip(
                  label: Text(ms < 1000 ? '${ms ~/ 100 / 10}s' : '${ms ~/ 1000}s'),
                  selected: h.pauseMs == ms,
                  onSelected: (_) => setState(() => h.setPauseMs(ms)),
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<int?>(
            valueListenable: h.sleepMinN,
            builder: (context, sleep, _) => Row(
              children: [
                const Icon(Icons.bedtime_outlined, size: 20),
                const SizedBox(width: 8),
                const Text('Uyku'),
                const Spacer(),
                for (final m in const [null, 15, 30, 60]) ...[
                  ChoiceChip(
                    label: Text(m == null ? 'Kapalı' : '$m dk'),
                    selected: sleep == m,
                    onSelected: (_) => h.setSleepMinutes(m),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
