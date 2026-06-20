import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/question.dart';
import '../models/topic.dart';
import '../models/traffic_sign.dart';

/// JSON asset'lerinden statik içeriği yükler ve önbelleğe alır.
class ContentRepository {
  List<Question>? _questions;
  List<Topic>? _topics;
  Map<String, List<TrafficSign>>? _signs;

  Future<List<Question>> loadQuestions() async {
    if (_questions != null) return _questions!;
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final list = jsonDecode(raw) as List;
    _questions = list
        .map((e) => Question.fromJson(e as Map<String, dynamic>))
        .toList();
    return _questions!;
  }

  Future<List<Topic>> loadTopics() async {
    if (_topics != null) return _topics!;
    final raw = await rootBundle.loadString('assets/data/topics.json');
    final list = jsonDecode(raw) as List;
    _topics = list
        .map((e) => Topic.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return _topics!;
  }

  Future<Map<String, List<TrafficSign>>> loadSigns() async {
    if (_signs != null) return _signs!;
    final raw = await rootBundle.loadString('assets/data/traffic_signs.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final result = <String, List<TrafficSign>>{};
    map.forEach((category, value) {
      result[category] = (value as List)
          .map((e) =>
              TrafficSign.fromJson(e as Map<String, dynamic>, category))
          .toList();
    });
    _signs = result;
    return _signs!;
  }
}
