import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';

class _Badge {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final int current;
  final int target;
  const _Badge(this.title, this.desc, this.icon, this.color, this.current,
      this.target);

  bool get unlocked => current >= target;
  double get progress => target == 0 ? 1 : (current / target).clamp(0, 1);
}

/// Başarı rozetleri — ehliyet/sürüş temalı, tamamı offline ilerleme verisinden.
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

    // Ders bazında toplam doğru (uzmanlık rozetleri için).
    final catCorrect = <String, int>{};
    for (final r in results) {
      for (final a in r.answers) {
        if (a.isCorrect) {
          catCorrect[a.category] = (catCorrect[a.category] ?? 0) + 1;
        }
      }
    }
    int cc(String k) => catCorrect[k] ?? 0;

    const amber = AppColors.amber;
    const green = AppColors.primary;
    const orange = Color(0xFFEA580C);
    const blue = Color(0xFF2563EB);
    const red = AppColors.error;
    const purple = Color(0xFF7C3AED);

    final badges = <_Badge>[
      // Yolculuk (doğru cevap sayısı)
      _Badge('Kontağı Çevirdin', 'İlk soruyu çöz', Icons.vpn_key, green,
          answered, 1),
      _Badge('Çaylak Sürücü', '50 doğru cevap', Icons.directions_car_filled,
          green, correct, 50),
      _Badge('Yola Çıktın', '250 doğru cevap', Icons.route, blue, correct, 250),
      _Badge('Usta Sürücü', '1000 doğru cevap', Icons.workspace_premium, amber,
          correct, 1000),
      _Badge('Uzun Yol Şoförü', '500 soru çöz', Icons.local_gas_station, blue,
          answered, 500),
      // Sınav
      _Badge('İlk Sınav Heyecanı', '1 deneme sınavı bitir',
          Icons.assignment_turned_in, green, examCount, 1),
      _Badge('Ehliyeti Kaptın!', 'Bir denemeyi geç (35+)', Icons.verified,
          green, passed, 1),
      _Badge('Direksiyon Hakimi', '10 deneme geç', Icons.military_tech, amber,
          passed, 10),
      _Badge('Kusursuz Sürüş', 'Bir denemede 50/50', Icons.star, amber, perfect,
          1),
      _Badge('Az Kaldı', 'Bir denemede 45+ doğru', Icons.trending_up, orange,
          maxCorrect >= 45 ? 1 : 0, 1),
      // Seri (streak)
      _Badge('3 Gün Direksiyonda', '3 gün üst üste çalış',
          Icons.local_fire_department, orange, best, 3),
      _Badge('Haftanın Şoförü', '7 gün üst üste çalış',
          Icons.local_fire_department, orange, best, 7),
      _Badge('Yolun Profesyoneli', '30 gün üst üste çalış',
          Icons.local_fire_department, red, best, 30),
      // Ders uzmanlığı
      _Badge('Trafik Bilgini', 'Trafik\'te 100 doğru', Icons.traffic, blue,
          cc('trafik'), 100),
      _Badge('İlk Yardım Uzmanı', 'İlk Yardım\'da 50 doğru',
          Icons.medical_services, red, cc('ilk_yardim'), 50),
      _Badge('Motor Ustası', 'Motor\'da 40 doğru', Icons.build, orange,
          cc('motor'), 40),
      _Badge('Nazik Sürücü', 'Trafik Adabı\'nda 25 doğru', Icons.handshake,
          purple, cc('trafik_adabi'), 25),
    ];

    final unlocked = badges.where((b) => b.unlocked).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Başarılarım')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(unlocked: unlocked, total: badges.length),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.92,
            ),
            itemCount: badges.length,
            itemBuilder: (context, i) => _BadgeCard(badge: badges[i]),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int unlocked;
  final int total;
  const _SummaryCard({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pct,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation(AppColors.amber),
                ),
                const Icon(Icons.emoji_events,
                    color: AppColors.amber, size: 24),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$unlocked / $total rozet',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  unlocked == total
                      ? 'Hepsini topladın, tam ehliyet! 🎉'
                      : 'Çalıştıkça yeni rozetler aç.',
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

class _BadgeCard extends StatelessWidget {
  final _Badge badge;
  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.unlocked;
    final color = badge.color;
    return AppCard(
      padding: const EdgeInsets.all(14),
      color: unlocked ? color.withValues(alpha: 0.10) : null,
      border: unlocked
          ? Border.all(color: color.withValues(alpha: 0.35))
          : Border.all(color: AppColors.border),
      shadow: unlocked ? null : const [],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? color.withValues(alpha: 0.18)
                      : AppColors.textSecondary.withValues(alpha: 0.10),
                ),
                child: Icon(
                  unlocked ? badge.icon : Icons.lock_outline,
                  size: 28,
                  color: unlocked ? color : AppColors.textSecondary,
                ),
              ),
              if (unlocked)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Icon(Icons.check_circle, size: 18, color: color),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(badge.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(badge.desc,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
          if (!unlocked) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: badge.progress,
                minHeight: 6,
                color: color,
                backgroundColor: AppColors.border,
              ),
            ),
            const SizedBox(height: 4),
            Text('${badge.current.clamp(0, badge.target)}/${badge.target}',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
