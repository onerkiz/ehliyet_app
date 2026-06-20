import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/exam_config.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';
import 'listen_player_screen.dart';

/// "Dinleme Modu" giriş sayfası — neyi dinleyerek çalışacağını LİSTEDEN seç.
/// Tümü + ders bazında setler; her biri kaldığın yerden devam eder.
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
          int countOf(String cat) =>
              cat.isEmpty ? all.length : all.where((q) => q.category == cat).length;

          Widget tile({
            required String cat,
            required String title,
            required IconData icon,
            required Color color,
          }) {
            final total = countOf(cat);
            final idx = repo.listenIndex(cat).clamp(0, total);
            final resumed = idx > 0 && idx < total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        ListenPlayerScreen(category: cat, title: title),
                  ));
                },
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
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            resumed
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
                    const Icon(Icons.play_circle_fill,
                        color: AppColors.primary, size: 30),
                  ],
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
                'Soruyu ve şıkları okur, doğru cevabı söyler, otomatik sonrakine geçer. Eller serbest.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              tile(
                cat: '',
                title: 'Tüm Sorular',
                icon: Icons.all_inclusive,
                color: AppColors.primary,
              ),
              for (final c in kCategories)
                tile(
                  cat: c.key,
                  title: c.label,
                  icon: c.icon,
                  color: c.color,
                ),
            ],
          );
        },
      ),
    );
  }
}
