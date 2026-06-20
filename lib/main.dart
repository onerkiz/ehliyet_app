import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/ads/ad_service.dart';
import 'core/tts/listen_audio_handler.dart';
import 'data/repositories/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('results'),
    Hive.openBox('answers'),
    Hive.openBox('favorites'),
    Hive.openBox('settings'),
  ]);
  // Arka plan dinleme servisi (mobil). Hata olursa dinleme modu yine
  // ön planda çalışmaya devam eder; uygulamayı bloklamaz.
  if (!kIsWeb) {
    try {
      gListenHandler = await AudioService.init(
        builder: () => ListenAudioHandler(ProgressRepository()),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.ehliyet_sinav.listen',
          androidNotificationChannelName: 'Dinleme Modu',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
        ),
      );
    } catch (_) {
      gListenHandler = null;
    }
  }
  // Reklam SDK'sını arka planda başlat (web'de no-op; UI'yı bloklamaz).
  AdService.instance.init();
  runApp(const ProviderScope(child: EhliyetApp()));
}
