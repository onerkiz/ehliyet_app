import 'package:flutter/material.dart';

import '../../shared/providers/providers.dart';
import 'study_list_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudyListScreen(
      title: 'Favorilerim',
      emptyMessage:
          'Henüz favori soru yok.\nSoru çözerken yıldıza dokunarak ekleyebilirsin.',
      idSelector: (ref) => ref.read(progressRepositoryProvider).favoriteIds(),
    );
  }
}
