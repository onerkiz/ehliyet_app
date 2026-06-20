import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/question.dart';
import '../../data/models/topic.dart';
import '../../data/models/traffic_sign.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/repositories/progress_repository.dart';

final contentRepositoryProvider =
    Provider<ContentRepository>((ref) => ContentRepository());

final progressRepositoryProvider =
    Provider<ProgressRepository>((ref) => ProgressRepository());

final questionsProvider = FutureProvider<List<Question>>(
    (ref) => ref.read(contentRepositoryProvider).loadQuestions());

final topicsProvider = FutureProvider<List<Topic>>(
    (ref) => ref.read(contentRepositoryProvider).loadTopics());

final signsProvider = FutureProvider<Map<String, List<TrafficSign>>>(
    (ref) => ref.read(contentRepositoryProvider).loadSigns());

/// Tema modu (Hive'da kalıcı).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(progressRepositoryProvider).themeMode();

  Future<void> set(ThemeMode mode) async {
    await ref.read(progressRepositoryProvider).setThemeMode(mode);
    state = mode;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// "Dinleyerek Çalış" — yeni soru gelince otomatik sesli okuma (Hive'da kalıcı).
class TtsAutoReadNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(progressRepositoryProvider).ttsAutoRead();

  Future<void> set(bool enabled) async {
    await ref.read(progressRepositoryProvider).setTtsAutoRead(enabled);
    state = enabled;
  }
}

final ttsAutoReadProvider =
    NotifierProvider<TtsAutoReadNotifier, bool>(TtsAutoReadNotifier.new);
