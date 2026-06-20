import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ads/ad_service.dart';
import '../../core/constants/exam_config.dart';
import '../../core/review/review_prompter.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exam_result.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/confetti_overlay.dart';
import '../exam/exam_controller.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final ExamResult result;
  const ResultScreen({super.key, required this.result});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Sınav bitti → geçiş reklamı (hazırsa). Sonucun çizilmesini bekle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.instance.showInterstitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final passed = result.passed;
    final color = passed ? AppColors.primary : AppColors.error;

    // Ders bazında dağılım
    final byCat = <String, List<AnsweredItem>>{};
    for (final a in result.answers) {
      (byCat[a.category] ??= []).add(a);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav Sonucu'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                _ScoreRing(
                  correct: result.correct,
                  total: result.total,
                  color: color,
                ),
                const SizedBox(height: 20),
                Text(
                  passed ? 'Geçtin! 🎉' : 'Kaldın',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  passed
                      ? 'Harika gidiyorsun, sınava hazırsın.'
                      : '${result.correct} doğru · geçmek için ${ExamConfig.passThreshold} gerekli',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatBox(
                  label: 'Doğru',
                  value: '${result.correct}',
                  color: AppColors.primary),
              const SizedBox(width: 12),
              _StatBox(
                  label: 'Yanlış',
                  value: '${result.wrong}',
                  color: AppColors.error),
              const SizedBox(width: 12),
              _StatBox(
                  label: 'Boş',
                  value: '${result.blank}',
                  color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                    child: Text('Süre',
                        style: Theme.of(context).textTheme.bodyLarge)),
                Text(
                  '${result.durationSec ~/ 60} dk ${result.durationSec % 60} sn',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Ders Bazında', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < byCat.entries.length; i++) ...[
                  if (i > 0) const Divider(height: 1, indent: 52, endIndent: 16),
                  Builder(builder: (context) {
                    final e = byCat.entries.elementAt(i);
                    final meta = categoryMeta(e.key);
                    final correct =
                        e.value.where((a) => a.isCorrect).length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(meta.icon, color: meta.color, size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Text(meta.label,
                                  style:
                                      Theme.of(context).textTheme.bodyLarge)),
                          Text('$correct/${e.value.length}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/review', extra: result),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Soruları İncele'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              final all = ref.read(questionsProvider).value;
              if (all == null || all.isEmpty) return;
              ref.read(examControllerProvider.notifier).start(all);
              context.pushReplacement('/exam');
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tekrar Dene'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              // Ana sayfaya dönerken uygun anda mağaza puanı iste.
              await ReviewPrompter.maybeAsk(
                  ref.read(progressRepositoryProvider));
              if (context.mounted) context.go('/');
            },
            child: const Text('Ana Sayfa'),
          ),
        ],
          ),
          if (passed)
            const Positioned.fill(child: ConfettiOverlay()),
        ],
      ),
    );
  }
}

/// Daire skor halkası — ortada "38/50", renk geçti/kaldı.
class _ScoreRing extends StatelessWidget {
  final int correct;
  final int total;
  final Color color;
  const _ScoreRing(
      {required this.correct, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : correct / total;
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 170,
            height: 170,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 14,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$correct',
                  style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text('/$total',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.22)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
