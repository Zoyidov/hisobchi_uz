import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';

/// Excel eksport — yuklab olish → vaqtinchalik faylga saqlash → OS ulashish
/// oynasi (MOBILE_APP_TZ.md 4.10).
Future<void> downloadAndShareExcel(
  BuildContext context, {
  required Future<ApiResult<List<int>>> Function() download,
  required String fileName,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (dialogContext) {
      final colors = dialogContext.colors;
      return PopScope(
        canPop: false,
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fayl tayyorlanmoqda...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Iltimos, kuting',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  try {
    final result = await download();
    if (navigator.mounted) {
      navigator.pop();
    }

    result.when(
      success: (bytes) async {
        try {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/$fileName');
          await file.writeAsBytes(bytes);
          final box = context.mounted ? (context.findRenderObject() as RenderBox?) : null;
          await Share.shareXFiles(
            [XFile(file.path)],
            sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
          );
        } catch (_) {
          if (context.mounted) {
            AppSnackbar.error(context, 'Faylni ulashishda xatolik yuz berdi');
          }
        }
      },
      failure: (f) {
        if (context.mounted) {
          AppSnackbar.error(context, f.message);
        }
      },
    );
  } catch (e) {
    if (navigator.mounted) {
      navigator.pop();
    }
    if (context.mounted) {
      AppSnackbar.error(context, 'Yuklab olishda xatolik yuz berdi');
    }
  }
}
