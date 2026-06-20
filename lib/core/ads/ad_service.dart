import 'package:flutter/foundation.dart' show kIsWeb, VoidCallback;
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';

/// Reklam başlatma + geçiş (interstitial) yönetimi.
/// Web'de ve reklam yüklenememesinde tamamen sessizce no-op olur.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  /// Reklamların aktif olduğu platform mu? (sadece mobil)
  bool get enabled => !kIsWeb;

  Future<void> init() async {
    if (!enabled || _initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    _loadInterstitial();
  }

  void _loadInterstitial() {
    if (!enabled || _loadingInterstitial || _interstitial != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (_) {
          _interstitial = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  /// Geçiş reklamı göster. Hazır değilse [onDone] hemen çağrılır (akış bloklanmaz).
  void showInterstitial({VoidCallback? onDone}) {
    final ad = _interstitial;
    if (!enabled || ad == null) {
      onDone?.call();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
        onDone?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        _loadInterstitial();
        onDone?.call();
      },
    );
    _interstitial = null;
    ad.show();
  }
}
