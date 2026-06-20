import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ads/banner_ad_widget.dart';

/// Alt navigasyon barlı ana kabuk. Sekmeler durumlarını korur.
/// Banner reklam yalnızca burada (4 ana sekme) görünür — sınav/pratik
/// ekranları tam ekran rotalardır, banner taşımazlar.
/// Banner, alt menünün ALTINDA en dipte sabit (orilay app'teki gibi).
class MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const MainShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (i) =>
                shell.goBranch(i, initialLocation: i == shell.currentIndex),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Ana Sayfa',
              ),
              NavigationDestination(
                icon: Icon(Icons.signpost_outlined),
                selectedIcon: Icon(Icons.signpost),
                label: 'İşaretler',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Konular',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'İstatistik',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
          // Banner alt menünün ALTINDA — en dipte sabit (orilay app gibi).
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
