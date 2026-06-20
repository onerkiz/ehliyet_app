class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswer; // 0-3 indeks
  final String? explanation;
  final String category; // trafik | ilk_yardim | motor | trafik_adabi
  final int? year;
  final String? imageUrl;
  final String? videoUrl;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.category,
    this.year,
    this.imageUrl,
    this.videoUrl,
  });

  bool get hasImage => imageUrl != null;

  static String? _clean(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory Question.fromJson(Map<String, dynamic> j) {
    return Question(
      id: j['id'] as String,
      text: (j['text'] as String?) ?? '',
      options: ((j['options'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      correctAnswer: (j['correctAnswer'] as num?)?.toInt() ?? 0,
      explanation: _clean(j['explanation']),
      category: (j['category'] as String?) ?? 'trafik',
      year: (j['year'] as num?)?.toInt(),
      imageUrl: _clean(j['imageUrl']),
      videoUrl: _clean(j['videoUrl']),
    );
  }
}
