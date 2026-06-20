import 'package:flutter/material.dart';

/// Gerçek MEB e-sınav formatı.
class ExamConfig {
  static const int totalQuestions = 50;
  static const int durationSeconds = 45 * 60; // 45 dakika
  static const int passThreshold = 35; // geçmek için en az 35 doğru

  /// MEB e-sınav ders dağılımı (toplam 50 soru).
  static const Map<String, int> distribution = {
    'trafik': 23,
    'ilk_yardim': 12,
    'motor': 9,
    'trafik_adabi': 6,
  };
}

/// Ders (kategori) meta bilgisi.
class CategoryMeta {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const CategoryMeta(this.key, this.label, this.icon, this.color);
}

const List<CategoryMeta> kCategories = [
  CategoryMeta('trafik', 'Trafik ve Çevre', Icons.traffic, Color(0xFF2563EB)),
  CategoryMeta('ilk_yardim', 'İlk Yardım', Icons.medical_services, Color(0xFFDC2626)),
  CategoryMeta('motor', 'Motor ve Araç Tekniği', Icons.build, Color(0xFFD97706)),
  CategoryMeta('trafik_adabi', 'Trafik Adabı', Icons.handshake, Color(0xFF7C3AED)),
];

CategoryMeta categoryMeta(String key) =>
    kCategories.firstWhere((c) => c.key == key, orElse: () => kCategories.first);
