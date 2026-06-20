// Sınav yapılandırması birim testleri (platform bağımsız, hızlı).
import 'package:flutter_test/flutter_test.dart';
import 'package:ehliyet_sinav_2025/core/constants/exam_config.dart';

void main() {
  test('MEB ders dağılımı toplam 50 soruya eşittir', () {
    final sum = ExamConfig.distribution.values.fold<int>(0, (a, b) => a + b);
    expect(sum, ExamConfig.totalQuestions);
  });

  test('Geçme barajı geçerli aralıkta', () {
    expect(ExamConfig.passThreshold, greaterThan(0));
    expect(ExamConfig.passThreshold, lessThanOrEqualTo(ExamConfig.totalQuestions));
  });

  test('Tüm kategorilerin meta bilgisi bulunur', () {
    for (final key in ExamConfig.distribution.keys) {
      expect(categoryMeta(key).key, key);
    }
  });
}
