import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Yeniden kullanılabilir alt banner. Web'de veya reklam yüklenmezse hiç yer
/// kaplamaz (SizedBox.shrink).
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb && _ad == null) _load();
  }

  Future<void> _load() async {
    // Reklam eklentisi yoksa (test ortamı vb.) sessizce vazgeç.
    try {
      final width = MediaQuery.of(context).size.width.truncate();
      final adaptive = await AdSize.getAnchoredAdaptiveBannerAdSize(
          Orientation.portrait, width);
      final size = adaptive ?? AdSize.banner;
      final ad = BannerAd(
        size: size,
        adUnitId: AdConfig.bannerUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) setState(() => _loaded = true);
          },
          onAdFailedToLoad: (ad, _) => ad.dispose(),
        ),
      );
      _ad = ad;
      await ad.load();
    } catch (_) {
      _ad = null;
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: ad.size.height.toDouble(),
      color: Theme.of(context).colorScheme.surface,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
