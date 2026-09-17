import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum AppSnackbarType { success, error, warning }

/// Yagona snackbar — Success `✓ Saqlandi`, Error retry bilan
/// (E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 63, 141-142).
abstract final class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackbarType type = AppSnackbarType.success,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = context.colors;
    final color = switch (type) {
      AppSnackbarType.success => colors.success,
      AppSnackbarType.error => colors.error,
      AppSnackbarType.warning => colors.warning,
    };
    final icon = switch (type) {
      AppSnackbarType.success => Icons.check_circle,
      AppSnackbarType.error => Icons.error,
      AppSnackbarType.warning => Icons.warning_amber_rounded,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          duration: Duration(seconds: actionLabel != null ? 5 : 3),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: AppSnackbarType.success);

  static void error(BuildContext context, String message, {VoidCallback? onRetry}) => show(
        context,
        message,
        type: AppSnackbarType.error,
        actionLabel: onRetry != null ? 'Qayta urinish' : null,
        onAction: onRetry,
      );
}
