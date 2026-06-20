/// Bir sınavdaki tek bir sorunun cevap kaydı.
class AnsweredItem {
  final String questionId;
  final String category;
  final int? selected; // null = boş
  final bool isCorrect;

  const AnsweredItem({
    required this.questionId,
    required this.category,
    required this.selected,
    required this.isCorrect,
  });

  Map<String, dynamic> toMap() => {
        'q': questionId,
        'c': category,
        's': selected,
        'ok': isCorrect,
      };

  factory AnsweredItem.fromMap(Map<String, dynamic> m) => AnsweredItem(
        questionId: m['q'] as String,
        category: (m['c'] as String?) ?? 'trafik',
        selected: (m['s'] as num?)?.toInt(),
        isCorrect: (m['ok'] as bool?) ?? false,
      );
}

/// Tamamlanmış bir sınavın sonucu (Hive'a map olarak yazılır).
class ExamResult {
  final int dateEpoch;
  final String? category; // null = karışık deneme
  final int total;
  final int correct;
  final int wrong;
  final int blank;
  final int durationSec;
  final bool passed;
  final List<AnsweredItem> answers;

  const ExamResult({
    required this.dateEpoch,
    required this.category,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.blank,
    required this.durationSec,
    required this.passed,
    required this.answers,
  });

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateEpoch);
  double get scorePercent => total == 0 ? 0 : correct / total * 100;

  Map<String, dynamic> toMap() => {
        'date': dateEpoch,
        'cat': category,
        'total': total,
        'correct': correct,
        'wrong': wrong,
        'blank': blank,
        'dur': durationSec,
        'passed': passed,
        'answers': answers.map((a) => a.toMap()).toList(),
      };

  factory ExamResult.fromMap(Map<String, dynamic> m) => ExamResult(
        dateEpoch: (m['date'] as num?)?.toInt() ?? 0,
        category: m['cat'] as String?,
        total: (m['total'] as num?)?.toInt() ?? 0,
        correct: (m['correct'] as num?)?.toInt() ?? 0,
        wrong: (m['wrong'] as num?)?.toInt() ?? 0,
        blank: (m['blank'] as num?)?.toInt() ?? 0,
        durationSec: (m['dur'] as num?)?.toInt() ?? 0,
        passed: (m['passed'] as bool?) ?? false,
        answers: ((m['answers'] as List?) ?? const [])
            .map((e) =>
                AnsweredItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
