import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/providers.dart';

/// Çıkmış sorular: yıllara göre liste. Yıla dokununca o yılın soruları çözülür.
class YearsScreen extends ConsumerWidget {
  const YearsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Çıkmış Sorular')),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (all) {
          final counts = <int, int>{};
          for (final q in all) {
            if (q.year != null) {
              counts[q.year!] = (counts[q.year!] ?? 0) + 1;
            }
          }
          // Yeterli soru olan yıllar, yeniden eskiye.
          final years = counts.keys.where((y) => counts[y]! >= 10).toList()
            ..sort((a, b) => b.compareTo(a));
          if (years.isEmpty) {
            return const Center(child: Text('Yıl bilgisi bulunamadı.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Geçmiş yıllarda sorulan soruları yıla göre çöz.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...years.map((y) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.history_edu),
                      title: Text('$y Soruları'),
                      subtitle: Text('${counts[y]} soru'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/years/$y'),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}
