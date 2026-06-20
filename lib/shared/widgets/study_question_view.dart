import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/question.dart';
import '../providers/providers.dart';
import 'question_image.dart';

/// Tek soruluk çalışma görünümü: şık seç → anında doğru/yanlış + açıklama.
/// Pratik, Yanlışlarım ve Favoriler ekranlarında ortak kullanılır.
class StudyQuestionView extends ConsumerStatefulWidget {
  final Question question;
  final int position;
  final int total;
  final void Function(bool isCorrect) onAnswered;
  final VoidCallback onNext;

  const StudyQuestionView({
    super.key,
    required this.question,
    required this.position,
    required this.total,
    required this.onAnswered,
    required this.onNext,
  });

  @override
  ConsumerState<StudyQuestionView> createState() => _StudyQuestionViewState();
}

class _StudyQuestionViewState extends ConsumerState<StudyQuestionView> {
  int? _selected;
  bool _answered = false;

  void _select(int i) {
    if (_answered) return;
    final correct = i == widget.question.correctAnswer;
    setState(() {
      _selected = i;
      _answered = true;
    });
    // Haptik geri bildirim: doğru → hafif, yanlış → belirgin.
    if (correct) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    widget.onAnswered(correct);
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final progress = ref.read(progressRepositoryProvider);
    final isFav = progress.isFavorite(q.id);
    const green = AppColors.primary;
    const red = AppColors.error;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: widget.position / widget.total,
              minHeight: 6,
              backgroundColor: AppColors.border,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text('Soru ${widget.position}/${widget.total}',
                      style: Theme.of(context).textTheme.bodySmall),
                  const Spacer(),
                  IconButton(
                    icon: Icon(isFav ? Icons.star : Icons.star_border,
                        color: isFav ? Colors.amber : null),
                    onPressed: () async {
                      await progress.toggleFavorite(q.id);
                      setState(() {});
                    },
                  ),
                ],
              ),
              if (q.hasImage) ...[
                QuestionImage(path: q.imageUrl!, height: 180),
                const SizedBox(height: 16),
              ],
              Text(q.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600, height: 1.4)),
              const SizedBox(height: 16),
              ...List.generate(q.options.length, (i) {
                final scheme = Theme.of(context).colorScheme;
                final isCorrect = i == q.correctAnswer;
                final isSelected = i == _selected;
                Color border = scheme.outline;
                Color bg = scheme.surface;
                Color badge = scheme.surfaceContainerHighest;
                Color badgeText = scheme.onSurfaceVariant;
                if (_answered) {
                  if (isCorrect) {
                    border = green;
                    bg = green.withValues(alpha: 0.12);
                    badge = green;
                    badgeText = Colors.white;
                  } else if (isSelected) {
                    border = red;
                    bg = red.withValues(alpha: 0.12);
                    badge = red;
                    badgeText = Colors.white;
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _select(i),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: border,
                            width: _answered && (isCorrect || isSelected)
                                ? 2
                                : 1),
                        color: bg,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: badge),
                            child: Text(String.fromCharCode(65 + i),
                                style: TextStyle(
                                    color: badgeText,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(q.options[i],
                                  style:
                                      Theme.of(context).textTheme.bodyMedium)),
                          if (_answered && isCorrect)
                            const Icon(Icons.check_circle,
                                color: green, size: 20),
                          if (_answered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: red, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (_answered && q.explanation != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(q.explanation!)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton(
              onPressed: _answered ? widget.onNext : null,
              child: Text(widget.position >= widget.total
                  ? 'Bitir'
                  : 'Sonraki Soru'),
            ),
          ),
        ),
      ],
    );
  }
}
