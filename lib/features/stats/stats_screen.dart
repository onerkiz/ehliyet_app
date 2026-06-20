import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/exam_config.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exam_result.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(progressRepositoryProvider).allResults();

    return Scaffold(
      appBar: AppBar(title: const Text('İstatistiklerim')),
      body: results.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Henüz deneme sınavı çözmedin.\nİlk sınavını çözünce burada istatistiklerin görünecek.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _StatsBody(results: results),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final List<ExamResult> results;
  const _StatsBody({required this.results});

  @override
  Widget build(BuildContext context) {
    final examCount = results.length;
    final passCount = results.where((r) => r.passed).length;
    final avg = results.map((r) => r.correct).reduce((a, b) => a + b) / examCount;
    final best = results.map((r) => r.correct).reduce((a, b) => a > b ? a : b);

    // Ders bazında doğruluk (tüm sınavların cevapları)
    final catCorrect = <String, int>{};
    final catTotal = <String, int>{};
    for (final r in results) {
      for (final a in r.answers) {
        catTotal[a.category] = (catTotal[a.category] ?? 0) + 1;
        if (a.isCorrect) {
          catCorrect[a.category] = (catCorrect[a.category] ?? 0) + 1;
        }
      }
    }

    // Son 10 sınavın skoru (eskiden yeniye)
    final recent = results.take(10).toList().reversed.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _MetricCard(
                label: 'Sınav', value: '$examCount', color: AppColors.primary),
            const SizedBox(width: 10),
            _MetricCard(
                label: 'Geçilen',
                value: '$passCount',
                color: AppColors.primary),
            const SizedBox(width: 10),
            _MetricCard(
                label: 'Ortalama',
                value: avg.toStringAsFixed(0),
                color: AppColors.amber),
            const SizedBox(width: 10),
            _MetricCard(
                label: 'En İyi', value: '$best', color: AppColors.primaryDark),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader('Son Sınavlar (doğru sayısı)'),
        AppCard(
          child: SizedBox(height: 200, child: _ScoreChart(recent: recent)),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Ders Bazında Başarı'),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < kCategories.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                Builder(builder: (context) {
                  final c = kCategories[i];
                  final total = catTotal[c.key] ?? 0;
                  final correct = catCorrect[c.key] ?? 0;
                  final ratio = total == 0 ? 0.0 : correct / total;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(c.icon, color: c.color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(c.label,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium)),
                          Text('%${(ratio * 100).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          color: c.color,
                          backgroundColor: c.color.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Sınav Geçmişi'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < results.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 52, endIndent: 16),
                Builder(builder: (context) {
                  final r = results[i];
                  final color =
                      r.passed ? AppColors.primary : AppColors.error;
                  return InkWell(
                    onTap: () => context.push('/review', extra: r),
                    borderRadius: BorderRadius.vertical(
                      top: i == 0 ? const Radius.circular(20) : Radius.zero,
                      bottom: i == results.length - 1
                          ? const Radius.circular(20)
                          : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            r.passed
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: color,
                            size: 22,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${r.correct}/${r.total} doğru',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge),
                                Text(_formatDate(r.dateEpoch),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall),
                              ],
                            ),
                          ),
                          Text(
                            r.passed ? 'Geçti' : 'Kaldı',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _formatDate(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ScoreChart extends StatelessWidget {
  final List<ExamResult> recent;
  const _ScoreChart({required this.recent});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = [
      for (var i = 0; i < recent.length; i++)
        FlSpot(i.toDouble(), recent[i].correct.toDouble()),
    ];
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: ExamConfig.totalQuestions.toDouble(),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 10),
          ),
        ),
        borderData: FlBorderData(show: false),
        // 35 baraj çizgisi
        extraLinesData: ExtraLinesData(horizontalLines: [
          HorizontalLine(
            y: ExamConfig.passThreshold.toDouble(),
            color: Colors.green.withValues(alpha: 0.6),
            strokeWidth: 1,
            dashArray: [6, 4],
          ),
        ]),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: scheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: scheme.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
