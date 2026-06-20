import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/exam_config.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';
import 'listen_player_screen.dart';

/// "Dinleme Modu" giriş sayfası — neyi dinleyeceğini LİSTEDEN seç.
/// Tümü + dersler + Yanlışlarım + Zayıf Noktalarım; her biri kaldığın yerden devam.
class ListenModeScreen extends ConsumerWidget {
  const ListenModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    final repo = ref.watch(progressRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dinleme Modu')),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (all) {
          List<Question> byCat(String cat) =>
              cat.isEmpty ? all : all.where((q) => q.category == cat).toList();

          final wrongIds = repo.wrongQuestionIds();
          final seenIds = repo.answeredIds();
          final wrongList =
              all.where((q) => wrongIds.contains(q.id)).toList();
          final weakList = <Question>[
            ...wrongList,
            ...all.where((q) => !seenIds.contains(q.id)),
          ].take(30).toList();

          Widget tile({
            required String resumeKey,
            required String title,
            required IconData icon,
            required Color color,
            required List<Question> questions,
            String? emptyHint,
          }) {
            final total = questions.length;
            final idx = total == 0 ? 0 : repo.listenIndex(resumeKey).clamp(0, total);
            final resumed = idx > 0 && idx < total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: total == 0
                    ? null
                    : () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ListenPlayerScreen(
                            questions: questions,
                            title: title,
                            resumeKey: resumeKey,
                          ),
                        ));
                      },
                child: Opacity(
                  opacity: total == 0 ? 0.5 : 1,
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 2),
                            Text(
                              total == 0
                                  ? (emptyHint ?? 'Şu an yok')
                                  : resumed
                                      ? '$total soru · ${idx + 1}. soruda kaldın'
                                      : '$total soru',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (resumed) ...[
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: idx / total,
                                  minHeight: 4,
                                  backgroundColor: AppColors.border,
                                  color: color,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        total == 0
                            ? Icons.do_not_disturb_on_outlined
                            : Icons.play_circle_fill,
                        color: total == 0
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text('Neyi dinleyerek çalışmak istersin?',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                'Soruyu ve şıkları okur, doğru cevabı söyler, otomatik sonrakine geçer. '
                'Ekran kapalıyken de çalar.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              tile(
                resumeKey: 'all',
                title: 'Tüm Sorular',
                icon: Icons.all_inclusive,
                color: AppColors.primary,
                questions: byCat(''),
              ),
              for (final c in kCategories)
                tile(
                  resumeKey: c.key,
                  title: c.label,
                  icon: c.icon,
                  color: c.color,
                  questions: byCat(c.key),
                ),
              const SizedBox(height: 4),
              tile(
                resumeKey: 'wrong',
                title: 'Yanlışlarım',
                icon: Icons.error_outline,
                color: AppColors.error,
                questions: wrongList,
                emptyHint: 'Henüz yanlış yok',
              ),
              tile(
                resumeKey: 'weak',
                title: 'Zayıf Noktalarım',
                icon: Icons.psychology_outlined,
                color: const Color(0xFF7C3AED),
                questions: weakList,
                emptyHint: 'Şu an zayıf nokta yok',
              ),
            ],
          );
        },
      ),
    );
  }
}
