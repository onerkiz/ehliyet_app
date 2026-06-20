import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/exam_config.dart';
import '../../data/models/topic.dart';

class TopicDetailScreen extends StatelessWidget {
  final Topic topic;
  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final contents = [...topic.contents]
      ..sort((a, b) => a.order.compareTo(b.order));
    final meta = categoryMeta(topic.category);

    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kategori renkli başlık kartı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: meta.color.withValues(alpha: 0.12),
              border: Border.all(color: meta.color.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: meta.color.withValues(alpha: 0.2),
                  child: Icon(meta.icon, color: meta.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meta.label,
                          style: TextStyle(
                              color: meta.color, fontWeight: FontWeight.bold)),
                      if (topic.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(topic.description,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // İçerik kartları
          ...contents.map((c) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (c.title.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: meta.color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(c.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Text(c.content, style: const TextStyle(height: 1.55)),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          // Konuyla ilgili pratik CTA
          FilledButton.icon(
            onPressed: () => context.push('/practice/${topic.category}'),
            icon: const Icon(Icons.quiz_outlined),
            label: Text('${meta.label} sorularını çöz'),
            style: FilledButton.styleFrom(
              backgroundColor: meta.color,
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}
