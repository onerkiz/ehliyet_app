import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/study_question_view.dart';
import '../../shared/widgets/study_complete_view.dart';

/// Bir soru listesini sırayla çalıştıran ortak ekran (Yanlışlarım / Favoriler).
class StudyListScreen extends ConsumerStatefulWidget {
  final String title;
  final String emptyMessage;
  final Set<String> Function(WidgetRef ref) idSelector;

  const StudyListScreen({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.idSelector,
  });

  @override
  ConsumerState<StudyListScreen> createState() => _StudyListScreenState();
}

class _StudyListScreenState extends ConsumerState<StudyListScreen> {
  List<Question>? _pool;
  int _index = 0;
  int _correct = 0;
  int _answered = 0;
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_pool != null && _pool!.isNotEmpty && !_finished)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('$_correct/$_answered',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (all) {
          if (_pool == null) {
            final ids = widget.idSelector(ref);
            _pool = all.where((q) => ids.contains(q.id)).toList();
          }
          final pool = _pool!;
          if (pool.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(widget.emptyMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            );
          }
          if (_finished) {
            return StudyCompleteView(
              correct: _correct,
              total: _answered,
              onRestart: () => setState(() {
                _index = 0;
                _correct = 0;
                _answered = 0;
                _finished = false;
              }),
            );
          }
          final q = pool[_index];
          return StudyQuestionView(
            key: ValueKey(q.id),
            question: q,
            position: _index + 1,
            total: pool.length,
            onAnswered: (isCorrect) {
              setState(() {
                _answered++;
                if (isCorrect) _correct++;
              });
              ref.read(progressRepositoryProvider).recordAnswer(q.id, isCorrect);
            },
            onNext: () {
              if (_index + 1 >= pool.length) {
                setState(() => _finished = true);
              } else {
                setState(() => _index++);
              }
            },
          );
        },
      ),
    );
  }
}
