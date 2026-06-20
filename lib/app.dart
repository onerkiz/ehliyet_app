import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class EhliyetApp extends StatelessWidget {
  const EhliyetApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Yalnızca açık tema — dark mode kaldırıldı.
    return MaterialApp.router(
      title: 'Ehliyet Sınav 2026',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
