import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../core/icons/app_icons.dart';

/// Bottom navigatsiya — `liquid_glass_widgets` orqali iOS 26 uslubidagi
/// suzuvchi "liquid glass" panel, orqa fon to'liq ko'rinib turishi uchun
/// shaffof (clear) rejimda sozlangan.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    GlassTab(
      icon: Icon(AppIcons.home),
      activeIcon: Icon(AppIcons.homeActive),
      label: 'Asosiy',
    ),
    GlassTab(
      icon: Icon(AppIcons.partners),
      activeIcon: Icon(AppIcons.partnersActive),
      label: 'Hamkorlar',
    ),
    GlassTab(
      icon: Icon(AppIcons.project),
      activeIcon: Icon(AppIcons.projectActive),
      label: 'Loyihalar',
    ),
    GlassTab(
      icon: Icon(AppIcons.reports),
      activeIcon: Icon(AppIcons.reportsActive),
      label: 'Hisobotlar',
    ),
    GlassTab(
      icon: Icon(AppIcons.profile),
      activeIcon: Icon(AppIcons.profileActive),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final bottomOffset = bottomInset > 0 ? 14.0 : 8.0;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomOffset),
        child: GlassTabBar.bottom(
          tabs: _tabs,
          selectedIndex: navigationShell.currentIndex,
          onTabSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          verticalPadding: 0,
          horizontalPadding: 16,
          barHeight: 58,
          selectedIconColor: theme.colorScheme.primary,
          selectedLabelColor: theme.colorScheme.primary,
          unselectedIconColor: isDark ? Colors.white : null,
          unselectedLabelColor: isDark ? Colors.white : null,
          adaptiveBrightness: true,
          settings: LiquidGlassSettings(
            thickness: 16,
            blur: 10,
            bodyMode: GlassBodyMode.clear,
            standardOpacityMultiplier: 0.65,
            glassColor: isDark
                ? const Color.fromARGB(35, 255, 255, 255)
                : const Color.fromARGB(45, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
