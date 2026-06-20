import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/exam_config.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exam_result.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';
import '../exam/exam_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final progress = ref.watch(progressRepositoryProvider);
    final results = progress.allResults();
    final lastResult = results.isNotEmpty ? results.first : null;
    final streak = progress.currentStreak();

    return Scaffold(
      // Minimal: app bar yok (ayarlar Profil sekmesinde). İçerik SafeArea'da.
      body: SafeArea(
        bottom: false,
        child: questions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Veri yüklenemedi: $e')),
        data: (all) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _StreakBanner(streak: streak, best: progress.bestStreak()),
            if (lastResult != null) ...[
              const SizedBox(height: 12),
              _LastResultStrip(result: lastResult),
            ],
            const SizedBox(height: 16),
            _ExamCard(
              onStart: () {
                ref.read(examControllerProvider.notifier).start(all);
                context.push('/exam');
              },
            ),
            const SizedBox(height: 24),
            const SectionHeader('Ders Bazında Çalış'),
            _CategoryGrid(all: all),
            const SizedBox(height: 24),
            const SectionHeader('Araçlar'),
            _ToolsCard(
              tools: [
                _Tool(Icons.headphones, AppColors.primary, 'Dinleyerek Çalış',
                    () => context.push('/listen')),
                _Tool(Icons.style, const Color(0xFF2563EB), 'İşaret Kartları',
                    () => context.push('/flashcards')),
                _Tool(Icons.menu_book_outlined, const Color(0xFF0EA5E9),
                    'Sürücü Rehberi', () => context.push('/guide')),
                _Tool(Icons.history_edu, AppColors.amber, 'Çıkmış Sorular',
                    () => context.push('/years')),
                _Tool(Icons.trending_down, AppColors.error, 'Zayıf Noktalarım',
                    () => context.push('/weak')),
                _Tool(Icons.emoji_events_outlined, AppColors.primary,
                    'Başarılarım', () => context.push('/achievements')),
                _Tool(Icons.highlight_off, AppColors.textSecondary,
                    'Yanlışlarım', () => context.push('/wrong')),
                _Tool(Icons.bookmark_outline, const Color(0xFF7C3AED),
                    'Favorilerim', () => context.push('/favorites')),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Günlük çalışma serisi — beyaz kart + amber dairesel ateş ikonu.
class _StreakBanner extends StatelessWidget {
  final int streak;
  final int best;
  const _StreakBanner({required this.streak, required this.best});

  @override
  Widget build(BuildContext context) {
    final active = streak > 0;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (active ? AppColors.amber : AppColors.textSecondary)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              active
                  ? Icons.local_fire_department
                  : Icons.local_fire_department_outlined,
              color: active ? AppColors.amber : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  active ? '$streak günlük seri 🔥' : 'Seriye başla!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? 'En iyi: $best gün'
                      : 'Bugün bir soru çöz, serini başlat.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Son sınav sonucu şeridi — geçti yeşil / kaldı kırmızı tonlu.
class _LastResultStrip extends StatelessWidget {
  final ExamResult result;
  const _LastResultStrip({required this.result});

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final accent = passed ? AppColors.primary : AppColors.error;
    return AppCard(
      color: passed ? AppColors.greenLight : const Color(0xFFFEF2F2),
      border: Border.all(color: accent.withValues(alpha: 0.3)),
      shadow: const [],
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(passed ? Icons.check : Icons.close,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Son sınav: ${result.correct}/${result.total}',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: accent),
            ),
          ),
          Text(
            passed ? '(Geçti)' : '(Kaldı)',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: accent, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Hero "Deneme Sınavı" kartı — yeşil gradient, beyaz metin.
class _ExamCard extends StatelessWidget {
  final VoidCallback onStart;
  const _ExamCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.directions_car_filled,
              size: 96,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deneme Sınavı',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${ExamConfig.totalQuestions} soru · ${ExamConfig.durationSeconds ~/ 60} dk · '
                'geçme ${ExamConfig.passThreshold} doğru',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Sınavı Başlat'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<Question> all;
  const _CategoryGrid({required this.all});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: kCategories.map((c) {
        final count = all.where((q) => q.category == c.key).length;
        return AppCard(
          padding: const EdgeInsets.all(14),
          onTap: () => context.push('/practice/${c.key}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(c.icon, color: c.color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text('$count soru',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _Tool {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _Tool(this.icon, this.color, this.title, this.onTap);
}

/// Araçlar — tek beyaz kart içinde ayraçlı satırlar.
class _ToolsCard extends StatelessWidget {
  final List<_Tool> tools;
  const _ToolsCard({required this.tools});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < tools.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, indent: 56, endIndent: 16),
            InkWell(
              onTap: tools[i].onTap,
              borderRadius: BorderRadius.vertical(
                top: i == 0 ? const Radius.circular(20) : Radius.zero,
                bottom: i == tools.length - 1
                    ? const Radius.circular(20)
                    : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(tools[i].icon, color: tools[i].color, size: 22),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(tools[i].title,
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
