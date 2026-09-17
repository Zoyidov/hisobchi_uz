import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';

/// Excel eksport — yuklab olish → vaqtinchalik faylga saqlash → OS ulashish
/// oynasi (MOBILE_APP_TZ.md 4.10).
Future<void> downloadAndShareExcel(
  BuildContext context, {
  required Future<ApiResult<List<int>>> Function() download,
  required String fileName,
}) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  final result = await download();
  if (!context.mounted) return;
  Navigator.of(context).pop();

  result.when(
    success: (bytes) async {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)]);
    },
    failure: (f) {
      if (context.mounted) AppSnackbar.error(context, f.message);
    },
  );
}
