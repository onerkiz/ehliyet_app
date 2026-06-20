import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/traffic_sign.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/question_image.dart';

class SignsScreen extends ConsumerStatefulWidget {
  const SignsScreen({super.key});

  @override
  ConsumerState<SignsScreen> createState() => _SignsScreenState();
}

class _SignsScreenState extends ConsumerState<SignsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final signsAsync = ref.watch(signsProvider);
    return signsAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (grouped) {
        final categories = grouped.keys.toList();
        final searching = _query.trim().isNotEmpty;

        final searchField = Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'İşaret ara…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _query = ''),
                    )
                  : null,
              isDense: true,
            ),
          ),
        );

        if (searching) {
          final q = _query.trim().toLowerCase();
          final results = [
            for (final list in grouped.values)
              ...list.where((s) =>
                  s.name.toLowerCase().contains(q) ||
                  s.description.toLowerCase().contains(q)),
          ];
          return Scaffold(
            appBar: AppBar(title: const Text('Trafik İşaretleri')),
            body: Column(
              children: [
                searchField,
                Expanded(
                  child: results.isEmpty
                      ? const Center(child: Text('Sonuç bulunamadı.'))
                      : _SignGrid(signs: results),
                ),
              ],
            ),
          );
        }

        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Trafik İşaretleri'),
              bottom: TabBar(
                isScrollable: true,
                tabs: categories
                    .map((c) => Tab(text: kSignCategoryLabels[c] ?? c))
                    .toList(),
              ),
            ),
            body: Column(
              children: [
                searchField,
                Expanded(
                  child: TabBarView(
                    children: categories
                        .map((c) => _SignGrid(signs: grouped[c]!))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SignGrid extends StatelessWidget {
  final List<TrafficSign> signs;
  const _SignGrid({required this.signs});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: signs.length,
      itemBuilder: (context, i) {
        final s = signs[i];
        return AppCard(
          padding: const EdgeInsets.all(12),
          onTap: () => _showSign(context, s),
          child: Column(
            children: [
              Expanded(child: Center(child: QuestionImage(path: s.imageUrl))),
              const SizedBox(height: 8),
              Text(
                s.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSign(BuildContext context, TrafficSign s) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuestionImage(path: s.imageUrl, height: 120),
            const SizedBox(height: 12),
            Text(s.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(s.description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
