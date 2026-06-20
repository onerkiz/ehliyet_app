import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import 'guide_data.dart';

/// Sürücü Rehberi hub'ı — referans/bilgi ekranlarına giriş.
class GuideHubScreen extends StatelessWidget {
  const GuideHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_GuideItem>[
      _GuideItem('İl Plaka Kodları', '81 ilin plaka kodu', Icons.pin_outlined,
          const Color(0xFF2563EB), const PlatesScreen()),
      _GuideItem('Ehliyet Sınıfları', 'A, B, C, D… sınıf ve şartları',
          Icons.badge_outlined, AppColors.primary, const LicenseClassesScreen()),
      _GuideItem('Ehliyet Alma Süreci', 'Kayıttan belgeye adım adım',
          Icons.timeline, const Color(0xFFD97706), const ExamProcessScreen()),
      _GuideItem('Direksiyon Sınavı', 'Uygulama sınavı ipuçları',
          Icons.directions_car_outlined, const Color(0xFF7C3AED),
          const DrivingTestScreen()),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Sürücü Rehberi')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return AppCard(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => it.screen)),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: it.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(it.icon, color: it.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(it.subtitle,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GuideItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;
  const _GuideItem(
      this.title, this.subtitle, this.icon, this.color, this.screen);
}

/// Üstte küçük "resmi kaynağı esas al" uyarısı.
class _Disclaimer extends StatelessWidget {
  final String text;
  const _Disclaimer(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF92400E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 12, color: Color(0xFF92400E))),
          ),
        ],
      ),
    );
  }
}

/// 81 il plaka kodu — aranabilir.
class PlatesScreen extends StatefulWidget {
  const PlatesScreen({super.key});
  @override
  State<PlatesScreen> createState() => _PlatesScreenState();
}

class _PlatesScreenState extends State<PlatesScreen> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = kPlates.where((p) {
      if (q.isEmpty) return true;
      return p[0].contains(q) || p[1].toLowerCase().contains(q);
    }).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('İl Plaka Kodları')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(
                hintText: 'İl adı veya kod ara…',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = list[i];
                return AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(p[0],
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB))),
                      ),
                      const SizedBox(width: 14),
                      Text(p[1],
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Ehliyet sınıfları ve asgari yaş.
class LicenseClassesScreen extends StatelessWidget {
  const LicenseClassesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ehliyet Sınıfları')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Disclaimer(
              '* A sınıfı için A2\'den 2 yıl sonra (yoksa 24). ** Mesleki '
              'yeterlilik (SRC) ile bazı sınıflarda yaş düşebilir. Güncel resmi '
              'şartları MEB/EGM\'den teyit edin.'),
          for (final c in kLicenseClasses)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(c[0],
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(c[1],
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        Text(c[2],
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 16)),
                        Text('yaş',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ehliyet alma süreci — adım adım zaman çizelgesi.
class ExamProcessScreen extends StatelessWidget {
  const ExamProcessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ehliyet Alma Süreci')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < kExamSteps.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.primary),
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (i < kExamSteps.length - 1)
                        Expanded(
                          child: Container(
                              width: 2, color: AppColors.border),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(kExamSteps[i][0],
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(kExamSteps[i][1],
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Direksiyon (uygulama) sınavı ipuçları.
class DrivingTestScreen extends StatelessWidget {
  const DrivingTestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direksiyon Sınavı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final tip in kDrivingTips)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(tip,
                            style: Theme.of(context).textTheme.bodyLarge)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// NOT: Bağımsız "İlk Yardım Rehberi" (adım adım talimat) ekranı, Google Play
// Health Content politikası kapsamına girmemek için KALDIRILDI. İlk yardım
// içeriği sınav soruları (eğitim) olarak kalıyor.
