import 'package:flutter/material.dart';

import '../../shared/providers/providers.dart';
import 'study_list_screen.dart';

class WrongAnswersScreen extends StatelessWidget {
  const WrongAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StudyListScreen(
      title: 'Yanlışlarım',
      emptyMessage:
          'Henüz yanlış yaptığın soru yok.\nPratik veya deneme çözmeye başla!',
      idSelector: (ref) =>
          ref.read(progressRepositoryProvider).wrongQuestionIds(),
    );
  }
}
