import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_service.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/study_question_view.dart';
import '../../shared/widgets/study_complete_view.dart';

/// Zayıf Noktalarım: yanlış yapılan + hiç çözülmemiş soruları öne alan
/// adaptif çalışma seti (en fazla 30 soru). Tamamen offline.
class WeakPointsScreen extends ConsumerStatefulWidget {
  const WeakPointsScreen({super.key});

  @override
  ConsumerState<WeakPointsScreen> createState() => _WeakPointsScreenState();
}

class _WeakPointsScreenState extends ConsumerState<WeakPointsScreen> {
  static const _maxPool = 30;
  List<Question>? _pool;
  int _index = 0;
  int _correct = 0;
  int _answered = 0;
  bool _finished = false;

  List<Question> _buildPool(List<Question> all) {
    final progress = ref.read(progressRepositoryProvider);
    final wrongIds = progress.wrongQuestionIds();
    final seenIds = progress.answeredIds();
    final rnd = Random();

    final wrong = all.where((q) => wrongIds.contains(q.id)).toList()
      ..shuffle(rnd);
    final unseen = all.where((q) => !seenIds.contains(q.id)).toList()
      ..shuffle(rnd);

    final pool = <Question>[...wrong];
    for (final q in unseen) {
      if (pool.length >= _maxPool) break;
      pool.add(q);
    }
    return pool.take(_maxPool).toList();
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zayıf Noktalarım'),
        actions: [
          if (!_finished && _pool != null && _pool!.isNotEmpty)
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
          _pool ??= _buildPool(all);
          final pool = _pool!;
          if (pool.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Harika! Şu an çalışılacak zayıf nokta yok.\n'
                  'Yeni sorular çözdükçe burada zorlandıkların toplanır.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (_finished) {
            return StudyCompleteView(
              correct: _correct,
              total: _answered,
              onRestart: () => setState(() {
                _pool = _buildPool(all);
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
                AdService.instance.showInterstitial();
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
