import 'package:flutter/material.dart';

/// Pratik/çalışma seti bitince gösterilen skor özeti.
class StudyCompleteView extends StatelessWidget {
  final int correct;
  final int total;
  final VoidCallback onRestart;

  const StudyCompleteView({
    super.key,
    required this.correct,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (correct * 100 / total).round();
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            Text('Bitirdin! 🎉',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '$correct / $total doğru  ·  %$pct',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh),
              label: const Text('Yeniden Başla'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
