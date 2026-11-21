import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localization_extension.dart';

/// Bottom navigatsiya — `liquid_glass_widgets` orqali iOS 26 uslubidagi
/// suzuvchi "liquid glass" panel, orqa fon to'liq ko'rinib turishi uchun
/// shaffof (clear) rejimda sozlangan.
class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static List<GlassTab> _tabs(AppLocalizations l10n) => [
    GlassTab(
      icon: Icon(AppIcons.home),
      activeIcon: Icon(AppIcons.homeActive),
      label: l10n.navHome,
    ),
    GlassTab(
      icon: Icon(AppIcons.partners),
      activeIcon: Icon(AppIcons.partnersActive),
      label: l10n.navPartners,
    ),
    GlassTab(
      icon: Icon(AppIcons.project),
      activeIcon: Icon(AppIcons.projectActive),
      label: l10n.navProjects,
    ),
    GlassTab(
      icon: Icon(AppIcons.reports),
      activeIcon: Icon(AppIcons.reportsActive),
      label: l10n.navReports,
    ),
    GlassTab(
      icon: Icon(AppIcons.profile),
      activeIcon: Icon(AppIcons.profileActive),
      label: l10n.navProfile,
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
          tabs: _tabs(context.l10n),
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
          unselectedIconColor: isDark ? context.colors.textPrimary : null,
          unselectedLabelColor: isDark ? context.colors.textPrimary : null,
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
