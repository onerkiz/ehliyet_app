class TopicContent {
  final String id;
  final String title;
  final String content;
  final String type; // "text"
  final int order;

  const TopicContent({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.order,
  });

  factory TopicContent.fromJson(Map<String, dynamic> j) => TopicContent(
        id: (j['id'] as String?) ?? '',
        title: (j['title'] as String?) ?? '',
        content: (j['content'] as String?) ?? '',
        type: (j['type'] as String?) ?? 'text',
        order: (j['order'] as num?)?.toInt() ?? 0,
      );
}

class Topic {
  final String id;
  final String title;
  final String description;
  final String category;
  final int order;
  final List<TopicContent> contents;

  const Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.order,
    required this.contents,
  });

  factory Topic.fromJson(Map<String, dynamic> j) => Topic(
        id: (j['id'] as String?) ?? '',
        title: (j['title'] as String?) ?? '',
        description: (j['description'] as String?) ?? '',
        category: (j['category'] as String?) ?? 'trafik',
        order: (j['order'] as num?)?.toInt() ?? 0,
        contents: ((j['contents'] as List?) ?? const [])
            .map((e) => TopicContent.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
