import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/traffic_sign.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/question_image.dart';

/// Quizlet tarzı ezber kartları — trafik işaretleri.
/// Ön: işaret görseli → dokun → çevir → ad + anlam. "Biliyorum / Tekrar" ile ayır.
class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flip;
  String _cat = ''; // '' = tümü
  List<TrafficSign> _deck = [];
  int _known = 0;
  int _total = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  void _buildDeck(Map<String, List<TrafficSign>> grouped) {
    final all = <TrafficSign>[
      for (final entry in grouped.entries)
        if (_cat.isEmpty || entry.key == _cat) ...entry.value,
    ]..shuffle(math.Random());
    _deck = all;
    _total = all.length;
    _known = 0;
    _flip.value = 0;
  }

  void _setCat(String cat, Map<String, List<TrafficSign>> grouped) {
    setState(() {
      _cat = cat;
      _buildDeck(grouped);
    });
  }

  void _toggleFlip() {
    if (_flip.isAnimating) return;
    if (_flip.value == 0) {
      _flip.forward();
    } else {
      _flip.reverse();
    }
  }

  void _answer({required bool known}) {
    if (_deck.isEmpty) return;
    setState(() {
      final card = _deck.removeAt(0);
      if (known) {
        _known++;
      } else {
        _deck.add(card); // bilemediğini sona at, tekrar gelsin
      }
      _flip.value = 0; // sonraki kart ön yüzle başlasın
    });
  }

  void _restart(Map<String, List<TrafficSign>> grouped) {
    setState(() => _buildDeck(grouped));
  }

  @override
  Widget build(BuildContext context) {
    final signsAsync = ref.watch(signsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('İşaret Kartları'),
        actions: [
          signsAsync.maybeWhen(
            data: (grouped) => IconButton(
              icon: const Icon(Icons.shuffle),
              tooltip: 'Karıştır / baştan',
              onPressed: () => _restart(grouped),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: signsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (grouped) {
          if (!_initialized) {
            _initialized = true;
            _buildDeck(grouped);
          }
          final cats = grouped.keys.toList();
          return Column(
            children: [
              _CategoryChips(
                cats: cats,
                selected: _cat,
                onSelected: (c) => _setCat(c, grouped),
              ),
              _ProgressBar(known: _known, total: _total),
              Expanded(
                child: _deck.isEmpty
                    ? _DoneView(
                        total: _total, onRestart: () => _restart(grouped))
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: GestureDetector(
                          onTap: _toggleFlip,
                          child: _FlipCard(flip: _flip, sign: _deck.first),
                        ),
                      ),
              ),
              if (_deck.isNotEmpty) _AnswerBar(onAnswer: _answer),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> cats;
  final String selected;
  final ValueChanged<String> onSelected;
  const _CategoryChips(
      {required this.cats, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Tümü'),
              selected: selected.isEmpty,
              onSelected: (_) => onSelected(''),
            ),
          ),
          for (final c in cats)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(kSignCategoryLabels[c] ?? c),
                selected: selected == c,
                onSelected: (_) => onSelected(c),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int known;
  final int total;
  const _ProgressBar({required this.known, required this.total});

  @override
  Widget build(BuildContext context) {
    final remaining = total - known;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text('Bilinen: $known',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Kalan: $remaining',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : known / total,
              minHeight: 6,
              backgroundColor: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

/// 3B çevrilen kart: ön = görsel, arka = ad + anlam.
class _FlipCard extends StatelessWidget {
  final AnimationController flip;
  final TrafficSign sign;
  const _FlipCard({required this.flip, required this.sign});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: flip,
      builder: (context, _) {
        final angle = flip.value * math.pi;
        final showBack = angle > math.pi / 2;
        final content = showBack
            ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(math.pi),
                child: _Back(sign: sign),
              )
            : _Front(sign: sign);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: content,
        );
      },
    );
  }
}

class _Front extends StatelessWidget {
  final TrafficSign sign;
  const _Front({required this.sign});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Center(child: QuestionImage(path: sign.imageUrl))),
            const SizedBox(height: 16),
            Text('Bu işaret ne?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Çevirmek için dokun',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Back extends StatelessWidget {
  final TrafficSign sign;
  const _Back({required this.sign});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.greenLight,
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: 90,
                  child: Center(child: QuestionImage(path: sign.imageUrl))),
              const SizedBox(height: 16),
              Text(sign.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: AppColors.primaryDark)),
              if (sign.description.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(sign.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerBar extends StatelessWidget {
  final void Function({required bool known}) onAnswer;
  const _AnswerBar({required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onAnswer(known: false),
                icon: const Icon(Icons.replay),
                label: const Text('Tekrar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber,
                  side: const BorderSide(color: AppColors.amber, width: 1.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => onAnswer(known: true),
                icon: const Icon(Icons.check),
                label: const Text('Biliyorum'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  final int total;
  final VoidCallback onRestart;
  const _DoneView({required this.total, required this.onRestart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 64, color: AppColors.amber),
            const SizedBox(height: 12),
            Text('Tüm kartları bildin! 🎉',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('$total işaret',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Baştan Başla'),
            ),
          ],
        ),
      ),
    );
  }
}
