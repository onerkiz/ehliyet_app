import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/question_image.dart';
import 'exam_controller.dart';

class ExamScreen extends ConsumerWidget {
  const ExamScreen({super.key});

  String _fmt(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examControllerProvider);
    final controller = ref.read(examControllerProvider.notifier);

    // Sınav bitince sonuç ekranına geç.
    ref.listen<ExamState?>(examControllerProvider, (prev, next) {
      if (next != null && next.finished && next.result != null) {
        context.pushReplacement('/result', extra: next.result);
      }
    });

    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final q = state.current;
    final selected = state.answers[state.index];
    final lowTime = state.remaining <= 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmLeave(context);
        if (leave == true && context.mounted) {
          controller.abort();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Soru ${state.index + 1}/${state.questions.length}'),
          actions: [
            _FavoriteButton(questionId: q.id),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (lowTime ? AppColors.error : AppColors.primary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 16,
                          color: lowTime ? AppColors.error : AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        _fmt(state.remaining),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: lowTime ? AppColors.error : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (state.index + 1) / state.questions.length,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (q.hasImage) ...[
                    QuestionImage(path: q.imageUrl!, height: 180),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    q.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(q.options.length, (i) {
                    return _OptionTile(
                      letter: String.fromCharCode(65 + i),
                      text: q.options[i],
                      selected: selected == i,
                      onTap: () => controller.select(i),
                    );
                  }),
                ],
              ),
            ),
            _BottomBar(
              state: state,
              onPrev: controller.prev,
              onNext: controller.next,
              onPalette: () => _showPalette(context, ref),
              onFinish: () async {
                final ok = await _confirmFinish(context, state);
                if (ok == true) controller.finish();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _confirmLeave(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Sınavdan çık'),
          content: const Text('Sınav iptal edilecek. Emin misin?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Vazgeç')),
            FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Çık')),
          ],
        ),
      );

  Future<bool?> _confirmFinish(BuildContext context, ExamState state) {
    final blank = state.answers.where((a) => a == null).length;
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Sınavı bitir'),
        content: Text(blank > 0
            ? '$blank soru boş. Yine de bitirmek istiyor musun?'
            : 'Sınavı bitirip sonucu görmek istiyor musun?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Devam et')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Bitir')),
        ],
      ),
    );
  }

  void _showPalette(BuildContext context, WidgetRef ref) {
    final state = ref.read(examControllerProvider);
    final controller = ref.read(examControllerProvider.notifier);
    if (state == null) return;
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 6,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(state.questions.length, (i) {
            final answered = state.answers[i] != null;
            final isCurrent = i == state.index;
            return InkWell(
              onTap: () {
                controller.goTo(i);
                Navigator.pop(c);
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : answered
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.25)
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                ),
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.onPrimary
                        : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Sınav sırasında soruyu favorile/çıkar (yerel olarak rebuild olur).
class _FavoriteButton extends ConsumerStatefulWidget {
  final String questionId;
  const _FavoriteButton({required this.questionId});

  @override
  ConsumerState<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    final progress = ref.read(progressRepositoryProvider);
    final isFav = progress.isFavorite(widget.questionId);
    return IconButton(
      icon: Icon(isFav ? Icons.star : Icons.star_border,
          color: isFav ? Colors.amber : null),
      tooltip: isFav ? 'Favoriden çıkar' : 'Favorilere ekle',
      onPressed: () async {
        await progress.toggleFavorite(widget.questionId);
        if (mounted) setState(() {});
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : scheme.outline,
              width: selected ? 2 : 1,
            ),
            color: selected ? AppColors.greenLight : scheme.surface,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? AppColors.primary
                      : scheme.surfaceContainerHighest,
                ),
                child: Text(letter,
                    style: TextStyle(
                        color: selected ? Colors.white : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final ExamState state;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPalette;
  final VoidCallback onFinish;
  const _BottomBar({
    required this.state,
    required this.onPrev,
    required this.onNext,
    required this.onPalette,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = state.index == state.questions.length - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: state.index > 0 ? onPrev : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton.filledTonal(
              onPressed: onPalette,
              icon: const Icon(Icons.grid_view),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isLast
                  ? FilledButton(
                      onPressed: onFinish,
                      child: const Text('Sınavı Bitir'),
                    )
                  : FilledButton(
                      onPressed: onNext,
                      child: const Text('Sonraki'),
                    ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 8),
              TextButton(onPressed: onFinish, child: const Text('Bitir')),
            ],
          ],
        ),
      ),
    );
  }
}
