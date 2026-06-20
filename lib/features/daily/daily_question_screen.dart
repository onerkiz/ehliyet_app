import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/study_question_view.dart';

/// Bugünün epoch-gün indeksi (yerel gün). Her gün +1.
int todayEpochDay() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day).millisecondsSinceEpoch ~/ 86400000;
}

/// Güne göre deterministik soru indeksi (herkes aynı, her gün değişir).
int dailyQuestionIndex(int total) =>
    total == 0 ? 0 : todayEpochDay() % total;

/// Tek soruluk "Günün Sorusu" ekranı.
class DailyQuestionScreen extends ConsumerWidget {
  const DailyQuestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Günün Sorusu')),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (all) {
          if (all.isEmpty) {
            return const Center(child: Text('Soru bulunamadı.'));
          }
          final Question q = all[dailyQuestionIndex(all.length)];
          return StudyQuestionView(
            key: ValueKey('daily-${q.id}'),
            question: q,
            position: 1,
            total: 1,
            onAnswered: (isCorrect) {
              final repo = ref.read(progressRepositoryProvider);
              repo.recordAnswer(q.id, isCorrect);
              repo.setDailyDone(todayEpochDay());
            },
            onNext: () => context.pop(),
          );
        },
      ),
    );
  }
}
