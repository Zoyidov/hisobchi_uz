import 'package:flutter/material.dart';

import '../../theme/app_spacing.dart';
import '../feedback/offline_banner.dart';
import '../feedback/subscription_banner.dart';

/// SafeArea, background, keyboard, optional AppBar/FAB/bottom CTA — feature
/// widgetlari `Scaffold`ni qayta yaratmaydi (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 12).
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.actions,
    required this.body,
    this.floatingActionButton,
    this.bottomBar,
    this.resizeToAvoidBottomInset = true,
    this.showSubscriptionBanner = true,
    this.showOfflineBanner = true,
    this.centerTitle = false,
    this.leading,
  });

  final String? title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final bool resizeToAvoidBottomInset;
  final bool showSubscriptionBanner;
  final bool showOfflineBanner;
  final bool centerTitle;
  final Widget? leading;

  /// Tablet (600dp+) da markazlashgan, maksimal kenglikdagi content
  /// (MOBILE_APP_TZ.md 3.1, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 127).
  static Widget constrainWidth(BuildContext context, Widget child) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(title: Text(title!), actions: actions, centerTitle: centerTitle, leading: leading)
          : null,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        bottom: bottomBar == null,
        child: Column(
          children: [
            if (showOfflineBanner) const OfflineBanner(),
            if (showSubscriptionBanner)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: SubscriptionBanner(onAction: () {}),
              ),
            Expanded(child: constrainWidth(context, body)),
          ],
        ),
      ),
    );
  }
}
