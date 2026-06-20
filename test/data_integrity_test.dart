// Veri bütünlüğü + görsel-varlık testleri.
//
// Asset JSON'ları (questions / traffic_signs) diskten okuyup şema ve görsel
// dosyalarının fiilen var olduğunu doğrular. "Bir resim eksik kalmış" hatasını
// kalıcı olarak yakalar — her `flutter test`'te otomatik kontrol edilir.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('questions.json', () {
    final raw = File('assets/data/questions.json').readAsStringSync();
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();

    test('soru sayısı beklenenden az değil (>= 2300)', () {
      expect(list.length, greaterThanOrEqualTo(2300));
    });

    test('her sorunun şeması geçerli', () {
      for (final q in list) {
        final id = q['id'];
        expect(id, isA<String>(), reason: 'id eksik');
        expect((id as String).isNotEmpty, isTrue, reason: 'id boş');
        expect((q['text'] as String?)?.isNotEmpty ?? false, isTrue,
            reason: '$id: metin boş');
        final options = q['options'] as List?;
        expect(options, isNotNull, reason: '$id: options yok');
        expect(options!.length, 4, reason: '$id: 4 şık olmalı');
        for (final o in options) {
          expect((o as String).isNotEmpty, isTrue, reason: '$id: boş şık');
        }
        final correct = q['correctAnswer'] as int;
        expect(correct, inInclusiveRange(0, 3), reason: '$id: doğru cevap 0-3 dışı');
        expect((q['category'] as String?)?.isNotEmpty ?? false, isTrue,
            reason: '$id: kategori boş');
      }
    });

    test('soru görselleri (imageUrl) diskte mevcut', () {
      final missing = <String>[];
      for (final q in list) {
        final url = q['imageUrl'] as String?;
        if (url == null || url.isEmpty) continue;
        if (!File(url).existsSync()) missing.add('${q['id']} -> $url');
      }
      expect(missing, isEmpty,
          reason: 'Eksik soru görselleri:\n${missing.join('\n')}');
    });
  });

  group('traffic_signs.json', () {
    final raw = File('assets/data/traffic_signs.json').readAsStringSync();
    final map = (json.decode(raw) as Map<String, dynamic>);

    test('5 kategori mevcut', () {
      expect(map.keys.length, 5);
    });

    test('her işaretin şeması geçerli', () {
      for (final entry in map.entries) {
        final signs = (entry.value as List).cast<Map<String, dynamic>>();
        expect(signs, isNotEmpty, reason: '${entry.key}: boş kategori');
        for (final s in signs) {
          expect((s['code'] as String?)?.isNotEmpty ?? false, isTrue,
              reason: '${entry.key}: code boş');
          expect((s['name'] as String?)?.isNotEmpty ?? false, isTrue,
              reason: '${s['code']}: isim boş');
        }
      }
    });

    test('işaret görselleri (imageUrl) diskte mevcut', () {
      final missing = <String>[];
      for (final signs in map.values) {
        for (final s in (signs as List).cast<Map<String, dynamic>>()) {
          final url = s['imageUrl'] as String?;
          if (url == null || url.isEmpty) continue;
          if (!File(url).existsSync()) missing.add('${s['code']} -> $url');
        }
      }
      expect(missing, isEmpty,
          reason: 'Eksik işaret görselleri:\n${missing.join('\n')}');
    });
  });
}
