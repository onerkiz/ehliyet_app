import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/exam_result.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/question_image.dart';

/// Sınav sonrası soru soru açıklamalı inceleme.
class ReviewScreen extends ConsumerWidget {
  final ExamResult result;
  const ReviewScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Soru İnceleme')),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (all) {
          final byId = {for (final q in all) q.id: q};
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: result.answers.length,
            itemBuilder: (context, i) {
              final a = result.answers[i];
              final q = byId[a.questionId];
              if (q == null) return const SizedBox.shrink();
              return _ReviewCard(index: i + 1, question: q, selected: a.selected);
            },
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int index;
  final Question question;
  final int? selected;
  const _ReviewCard({
    required this.index,
    required this.question,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    const red = Color(0xFFDC2626);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index. ${question.text}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (question.hasImage) ...[
              const SizedBox(height: 10),
              QuestionImage(path: question.imageUrl!, height: 140),
            ],
            const SizedBox(height: 10),
            ...List.generate(question.options.length, (i) {
              final isCorrect = i == question.correctAnswer;
              final isSelected = i == selected;
              Color? bg;
              IconData? icon;
              if (isCorrect) {
                bg = green.withValues(alpha: 0.15);
                icon = Icons.check_circle;
              } else if (isSelected) {
                bg = red.withValues(alpha: 0.15);
                icon = Icons.cancel;
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('${String.fromCharCode(65 + i)}) '),
                    Expanded(child: Text(question.options[i])),
                    if (icon != null)
                      Icon(icon,
                          size: 18, color: isCorrect ? green : red),
                  ],
                ),
              );
            }),
            if (selected == null)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text('Boş bıraktın',
                    style: TextStyle(fontStyle: FontStyle.italic)),
              ),
            if (question.explanation != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(question.explanation!)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
