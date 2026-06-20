import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ads/ad_service.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/study_question_view.dart';
import '../../shared/widgets/study_complete_view.dart';

/// Belirli bir yılın sorularını çözme ekranı (Çıkmış Sorular).
class YearPracticeScreen extends ConsumerStatefulWidget {
  final int year;
  const YearPracticeScreen({super.key, required this.year});

  @override
  ConsumerState<YearPracticeScreen> createState() => _YearPracticeScreenState();
}

class _YearPracticeScreenState extends ConsumerState<YearPracticeScreen> {
  List<Question>? _pool;
  int _index = 0;
  int _correct = 0;
  int _answered = 0;
  bool _finished = false;

  void _restart(List<Question> source) {
    setState(() {
      _pool = source.toList()..shuffle(Random());
      _index = 0;
      _correct = 0;
      _answered = 0;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.year} Soruları'),
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
          final source = all.where((q) => q.year == widget.year).toList();
          _pool ??= (source.toList()..shuffle(Random()));
          final pool = _pool!;
          if (pool.isEmpty) {
            return const Center(child: Text('Bu yıla ait soru bulunamadı.'));
          }
          if (_finished) {
            return StudyCompleteView(
              correct: _correct,
              total: _answered,
              onRestart: () => _restart(source),
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
