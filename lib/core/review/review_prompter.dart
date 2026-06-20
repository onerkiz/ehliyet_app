import 'package:in_app_review/in_app_review.dart';

import '../../data/repositories/progress_repository.dart';

/// Uygun anda (en az 2 oturum tamamlanınca, bir kez) mağaza puanı ister.
class ReviewPrompter {
  ReviewPrompter._();

  static Future<void> maybeAsk(ProgressRepository repo) async {
    if (repo.reviewAsked()) return;
    final count = repo.bumpCompletedSessions();
    if (count < 2) return;
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
        await repo.setReviewAsked();
      }
    } catch (_) {
      // Eklenti yoksa (test/web) sessizce geç.
    }
  }
}
