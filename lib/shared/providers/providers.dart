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
