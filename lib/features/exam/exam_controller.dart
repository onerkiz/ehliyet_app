import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/exam_config.dart';
import '../../data/models/exam_result.dart';
import '../../data/models/question.dart';
import '../../shared/providers/providers.dart';

class ExamState {
  final List<Question> questions;
  final List<int?> answers; // her soru için seçilen şık (null = boş)
  final int index;
  final int remaining; // saniye
  final bool finished;
  final ExamResult? result;

  const ExamState({
    required this.questions,
    required this.answers,
    required this.index,
    required this.remaining,
    required this.finished,
    this.result,
  });

  Question get current => questions[index];
  int get answeredCount => answers.where((a) => a != null).length;

  ExamState copyWith({
    List<int?>? answers,
    int? index,
    int? remaining,
    bool? finished,
    ExamResult? result,
  }) {
    return ExamState(
      questions: questions,
      answers: answers ?? this.answers,
      index: index ?? this.index,
      remaining: remaining ?? this.remaining,
      finished: finished ?? this.finished,
      result: result ?? this.result,
    );
  }
}

class ExamController extends Notifier<ExamState?> {
  Timer? _timer;

  @override
  ExamState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  /// MEB dağılımına göre 50 soruluk karışık deneme başlatır.
  void start(List<Question> all) {
    _timer?.cancel();
    final questions = _buildMixedExam(all);
    state = ExamState(
      questions: questions,
      answers: List<int?>.filled(questions.length, null),
      index: 0,
      remaining: ExamConfig.durationSeconds,
      finished: false,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final s = state;
      if (s == null || s.finished) {
        t.cancel();
        return;
      }
      if (s.remaining <= 1) {
        finish();
      } else {
        state = s.copyWith(remaining: s.remaining - 1);
      }
    });
  }

  void select(int optionIndex) {
    final s = state;
    if (s == null || s.finished) return;
    final updated = [...s.answers];
    updated[s.index] = optionIndex;
    state = s.copyWith(answers: updated);
  }

  void goTo(int i) {
    final s = state;
    if (s == null || i < 0 || i >= s.questions.length) return;
    state = s.copyWith(index: i);
  }

  void next() => goTo((state?.index ?? 0) + 1);
  void prev() => goTo((state?.index ?? 0) - 1);

  void finish() {
    final s = state;
    if (s == null || s.finished) return;
    _timer?.cancel();

    var correct = 0, wrong = 0, blank = 0;
    final items = <AnsweredItem>[];
    for (var i = 0; i < s.questions.length; i++) {
      final q = s.questions[i];
      final sel = s.answers[i];
      final ok = sel != null && sel == q.correctAnswer;
      if (sel == null) {
        blank++;
      } else if (ok) {
        correct++;
      } else {
        wrong++;
      }
      items.add(AnsweredItem(
        questionId: q.id,
        category: q.category,
        selected: sel,
        isCorrect: ok,
      ));
    }

    final result = ExamResult(
      dateEpoch: DateTime.now().millisecondsSinceEpoch,
      category: null,
      total: s.questions.length,
      correct: correct,
      wrong: wrong,
      blank: blank,
      durationSec: ExamConfig.durationSeconds - s.remaining,
      passed: correct >= ExamConfig.passThreshold,
      answers: items,
    );

    ref.read(progressRepositoryProvider).saveExamResult(result);
    state = s.copyWith(finished: true, result: result);
  }

  void abort() {
    _timer?.cancel();
    state = null;
  }

  List<Question> _buildMixedExam(List<Question> all) {
    final rnd = Random();
    final byCat = <String, List<Question>>{};
    for (final q in all) {
      (byCat[q.category] ??= []).add(q);
    }
    final picked = <Question>[];
    ExamConfig.distribution.forEach((cat, count) {
      final pool = [...(byCat[cat] ?? const <Question>[])]..shuffle(rnd);
      picked.addAll(pool.take(count));
    });
    // Havuz yetersizse kalanı diğer sorularla tamamla.
    if (picked.length < ExamConfig.totalQuestions) {
      final pickedIds = picked.map((q) => q.id).toSet();
      final rest = all.where((q) => !pickedIds.contains(q.id)).toList()
        ..shuffle(rnd);
      picked.addAll(rest.take(ExamConfig.totalQuestions - picked.length));
    }
    picked.shuffle(rnd);
    return picked;
  }
}

final examControllerProvider =
    NotifierProvider<ExamController, ExamState?>(ExamController.new);
