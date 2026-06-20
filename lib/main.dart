import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/ads/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('results'),
    Hive.openBox('answers'),
    Hive.openBox('favorites'),
    Hive.openBox('settings'),
  ]);
  // Reklam SDK'sını arka planda başlat (web'de no-op; UI'yı bloklamaz).
  AdService.instance.init();
  runApp(const ProviderScope(child: EhliyetApp()));
}
