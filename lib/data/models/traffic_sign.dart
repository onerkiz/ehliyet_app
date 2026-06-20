class TrafficSign {
  final String code;
  final String name;
  final String description;
  final String imageUrl;
  final String category; // dict anahtarı: tehlikeUyari, trafikTanzim, ...

  const TrafficSign({
    required this.code,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory TrafficSign.fromJson(Map<String, dynamic> j, String category) =>
      TrafficSign(
        code: (j['code'] as String?) ?? '',
        name: (j['name'] as String?) ?? '',
        description: (j['description'] as String?) ?? '',
        imageUrl: (j['imageUrl'] as String?) ?? '',
        category: category,
      );
}

/// Trafik işareti kategorilerinin Türkçe etiketleri.
const Map<String, String> kSignCategoryLabels = {
  'tehlikeUyari': 'Tehlike Uyarı İşaretleri',
  'trafikTanzim': 'Trafik Tanzim İşaretleri',
  'bilgi': 'Bilgi İşaretleri',
  'duraklamaPark': 'Duraklama ve Park İşaretleri',
  'otoyol': 'Otoyol İşaretleri',
};
