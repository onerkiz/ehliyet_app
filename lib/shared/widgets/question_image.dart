import 'package:flutter/material.dart';

/// Soru/işaret görselini yerel asset'ten gösterir (offline).
class QuestionImage extends StatelessWidget {
  final String path;
  final double? height;
  final BoxFit fit;

  const QuestionImage({
    super.key,
    required this.path,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        path,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stack) => Container(
          height: height ?? 120,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined, size: 40),
        ),
      ),
    );
  }
}
