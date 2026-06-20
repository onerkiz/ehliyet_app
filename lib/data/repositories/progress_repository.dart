import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/exam_result.dart';

/// Kullanıcı ilerlemesini Hive'da saklar (sonuçlar, cevaplar, favoriler, ayar).
class ProgressRepository {
  Box get _results => Hive.box('results');
  Box get _answers => Hive.box('answers'); // questionId -> bool (son durum)
  Box get _favorites => Hive.box('favorites'); // questionId -> true
  Box get _settings => Hive.box('settings');

  // --- Sınav sonuçları ---
  Future<void> saveExamResult(ExamResult result) async {
    await _results.add(result.toMap());
    for (final a in result.answers) {
      if (a.selected != null) {
        await recordAnswer(a.questionId, a.isCorrect);
      }
    }
  }

  List<ExamResult> allResults() {
    return _results.values
        .map((e) => ExamResult.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => b.dateEpoch.compareTo(a.dateEpoch));
  }

  // --- Cevap kayıtları (yanlışlarım / zayıf alan) ---
  Future<void> recordAnswer(String questionId, bool isCorrect) async {
    await _answers.put(questionId, isCorrect);
    // Kümülatif sayaçlar (rozetler için) + günlük seri.
    _settings.put('totalAnswered', totalAnswered() + 1);
    if (isCorrect) _settings.put('totalCorrect', totalCorrect() + 1);
    recordStudyToday();
  }

  Set<String> wrongQuestionIds() => _answers
      .toMap()
      .entries
      .where((e) => e.value == false)
      .map((e) => e.key as String)
      .toSet();

  /// Daha önce hiç cevaplanmamış soru kimlikleri (zayıf nokta havuzu için).
  Set<String> answeredIds() => _answers.keys.map((e) => e as String).toSet();

  // --- Kümülatif sayaçlar ---
  int totalAnswered() => _settings.get('totalAnswered', defaultValue: 0) as int;
  int totalCorrect() => _settings.get('totalCorrect', defaultValue: 0) as int;

  // --- Günlük seri (streak) ---
  static int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  /// Bugünü çalışılmış olarak işaretle ve seriyi güncelle.
  void recordStudyToday() {
    final today = _dayKey(DateTime.now());
    final last = _settings.get('lastStudyDay', defaultValue: 0) as int;
    if (last == today) return; // bugün zaten sayıldı
    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final cur = currentStreak();
    final newStreak = (last == yesterday) ? cur + 1 : 1;
    _settings.put('lastStudyDay', today);
    _settings.put('currentStreak', newStreak);
    if (newStreak > bestStreak()) _settings.put('bestStreak', newStreak);
  }

  int currentStreak() {
    final last = _settings.get('lastStudyDay', defaultValue: 0) as int;
    if (last == 0) return 0;
    final today = _dayKey(DateTime.now());
    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    // Bugün veya dün çalışılmadıysa seri kopmuştur.
    if (last != today && last != yesterday) return 0;
    return _settings.get('currentStreak', defaultValue: 0) as int;
  }

  int bestStreak() => _settings.get('bestStreak', defaultValue: 0) as int;

  // --- Mağaza puanı isteme ---
  int bumpCompletedSessions() {
    final n = (_settings.get('completedSessions', defaultValue: 0) as int) + 1;
    _settings.put('completedSessions', n);
    return n;
  }

  bool reviewAsked() =>
      _settings.get('reviewAsked', defaultValue: false) as bool;
  Future<void> setReviewAsked() => _settings.put('reviewAsked', true);

  // --- Günlük hatırlatıcı ayarı ---
  bool reminderEnabled() =>
      _settings.get('reminderEnabled', defaultValue: false) as bool;
  int reminderHour() => _settings.get('reminderHour', defaultValue: 20) as int;
  int reminderMinute() => _settings.get('reminderMinute', defaultValue: 0) as int;
  Future<void> setReminder(bool enabled, int hour, int minute) async {
    await _settings.put('reminderEnabled', enabled);
    await _settings.put('reminderHour', hour);
    await _settings.put('reminderMinute', minute);
  }

  // --- Favoriler ---
  bool isFavorite(String questionId) => _favorites.containsKey(questionId);

  Future<void> toggleFavorite(String questionId) async {
    if (isFavorite(questionId)) {
      await _favorites.delete(questionId);
    } else {
      await _favorites.put(questionId, true);
    }
  }

  Set<String> favoriteIds() =>
      _favorites.keys.map((e) => e as String).toSet();

  // --- Tema ayarı ---
  ThemeMode themeMode() {
    final name = _settings.get('themeMode', defaultValue: 'system') as String;
    return ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _settings.put('themeMode', mode.name);

  // --- "Dinleyerek Çalış" (sesli okuma) ayarı ---
  /// Yeni soru gelince otomatik sesli okunsun mu? (varsayılan kapalı)
  bool ttsAutoRead() =>
      _settings.get('ttsAutoRead', defaultValue: false) as bool;
  Future<void> setTtsAutoRead(bool enabled) =>
      _settings.put('ttsAutoRead', enabled);
}
