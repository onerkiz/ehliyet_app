import 'package:flutter/foundation.dart' show kReleaseMode;

/// AdMob kimlikleri — TEK değiştirme noktası.
///
/// Şu an Google'ın RESMÎ TEST reklam birimleri kullanılıyor. Geliştirme/teslim
/// sırasında gerçek ID kullanmak AdMob hesabını askıya aldırabilir; bu yüzden
/// test ID'leri default. Gerçek ID'ler gelince [_realBannerAndroid] /
/// [_realInterstitialAndroid] ve AndroidManifest'teki APPLICATION_ID değerlerini
/// doldur — release build otomatik gerçek ID'leri kullanır.
class AdConfig {
  AdConfig._();

  // --- Google resmî TEST birimleri (Android) ---
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // --- Gerçek birimler (AdMob: Ehliyet Sınav ~8200535160) ---
  static const _realBannerAndroid = 'ca-app-pub-5935722595541157/7326960288';
  static const _realInterstitialAndroid =
      'ca-app-pub-5935722595541157/5415407963';
  static const _realRewardedAndroid =
      'ca-app-pub-5935722595541157/2789244621';

  /// Release build'de gerçek ID varsa onu, yoksa test ID'sini kullan.
  static String get bannerUnitId =>
      (kReleaseMode && _realBannerAndroid.isNotEmpty)
          ? _realBannerAndroid
          : _testBanner;

  static String get interstitialUnitId =>
      (kReleaseMode && _realInterstitialAndroid.isNotEmpty)
          ? _realInterstitialAndroid
          : _testInterstitial;

  // Ödüllü birim hazır (ileride "reklamı izle → X" için); şu an ekranda kullanılmıyor.
  static String get rewardedUnitId =>
      (kReleaseMode && _realRewardedAndroid.isNotEmpty)
          ? _realRewardedAndroid
          : _testRewarded;
}
