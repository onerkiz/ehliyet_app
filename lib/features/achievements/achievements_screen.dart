import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/providers.dart';

class _Badge {
  final String title;
  final String desc;
  final IconData icon;
  final int current;
  final int target;
  const _Badge(this.title, this.desc, this.icon, this.current, this.target);

  bool get unlocked => current >= target;
  double get progress => target == 0 ? 1 : (current / target).clamp(0, 1);
}

/// Başarı rozetleri — tamamı ilerleme verisinden türetilir (offline).
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressRepositoryProvider);
    final results = progress.allResults();

    final answered = progress.totalAnswered();
    final correct = progress.totalCorrect();
    final best = progress.bestStreak();
    final examCount = results.length;
    final passed = results.where((r) => r.passed).length;
    final perfect =
        results.where((r) => r.total > 0 && r.correct == r.total).length;
    final maxCorrect = results.isEmpty
        ? 0
        : results.map((r) => r.correct).reduce((a, b) => a > b ? a : b);

    final badges = <_Badge>[
      _Badge('İlk Adım', '1 soru çöz', Icons.flag, answered, 1),
      _Badge('Çırak', '50 doğru cevap', Icons.school, correct, 50),
      _Badge('Usta', '250 doğru cevap', Icons.workspace_premium, correct, 250),
      _Badge('Şampiyon', '1000 doğru cevap', Icons.emoji_events, correct, 1000),
      _Badge('Maratoncu', '500 soru çöz', Icons.directions_run, answered, 500),
      _Badge('İlk Deneme', '1 deneme sınavı bitir', Icons.assignment_turned_in,
          examCount, 1),
      _Badge('Geçtim!', 'Bir denemeyi geç (35+)', Icons.verified, passed, 1),
      _Badge('Kusursuz', 'Bir denemede 50/50', Icons.star, perfect, 1),
      _Badge('Hedefe Yakın', 'Bir denemede 45+ doğru', Icons.trending_up,
          maxCorrect >= 45 ? 1 : 0, 1),
      _Badge('3 Gün Seri', '3 gün üst üste çalış', Icons.local_fire_department,
          best, 3),
      _Badge('Haftalık', '7 gün üst üste çalış',
          Icons.local_fire_department, best, 7),
      _Badge('Azimli', '30 gün üst üste çalış',
          Icons.local_fire_department, best, 30),
    ];

    final unlockedCount = badges.where((b) => b.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Başarılarım')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('$unlockedCount / ${badges.length} rozet kazanıldı',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.95,
            ),
            itemCount: badges.length,
            itemBuilder: (context, i) => _BadgeCard(badge: badges[i]),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;
  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unlocked = badge.unlocked;
    final color = unlocked ? const Color(0xFFD97706) : scheme.outline;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: unlocked ? 0.12 : 0.05),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(unlocked ? badge.icon : Icons.lock_outline,
              size: 36, color: color),
          const SizedBox(height: 8),
          Text(badge.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(badge.desc,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall),
          if (!unlocked) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
            const SizedBox(height: 2),
            Text('${badge.current}/${badge.target}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
