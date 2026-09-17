import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Bottom navigatsiya — `liquid_glass_widgets` orqali iOS 26 uslubidagi
/// suzuvchi "liquid glass" panel (foydalanuvchi so'roviga ko'ra).
/// 5 ta tab, har biri o'z navigatsiya holatini saqlaydi
/// (E_HISOB_FLUTTER_UI_UX_TZ.md 18-bo'lim, MOBILE_APP_TZ.md 2.3).
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    GlassTab(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_rounded),
      label: 'Bosh sahifa',
    ),
    GlassTab(
      icon: Icon(Icons.people_outline_rounded),
      activeIcon: Icon(Icons.people_rounded),
      label: 'Hamkorlar',
    ),
    GlassTab(
      icon: Icon(Icons.work_outline_rounded),
      activeIcon: Icon(Icons.work_rounded),
      label: 'Loyihalar',
    ),
    GlassTab(
      icon: Icon(Icons.insert_chart_outlined_rounded),
      activeIcon: Icon(Icons.insert_chart_rounded),
      label: 'Hisobotlar',
    ),
    GlassTab(
      icon: Icon(Icons.account_circle_outlined),
      activeIcon: Icon(Icons.account_circle_rounded),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 8),
        child: GlassTabBar.bottom(
          tabs: _tabs,
          selectedIndex: navigationShell.currentIndex,
          onTabSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          selectedIconColor: theme.colorScheme.primary,
          selectedLabelColor: theme.colorScheme.primary,
          adaptiveBrightness: true,
        ),
      ),
    );
  }
}
