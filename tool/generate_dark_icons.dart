// Run: flutter test --no-pub tool/generate_dark_icons.dart
// Rasterizes the editable brand vector, preserving the original icon geometry.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> exportIcon(
  ui.Picture mark,
  String path, {
  int size = 1024,
  double markScale = .84,
  bool background = false,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  if (background) {
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      ui.Paint()..color = const ui.Color(0xFF151C2B),
    );
  }
  final padding = size * (1 - markScale) / 2;
  canvas.translate(padding, padding);
  canvas.scale(size * markScale / 512);
  canvas.drawPicture(mark);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
}

void main() {
  testWidgets('export dark brand icons', (tester) async {
    await tester.runAsync(() async {
      final source = await File(
        'assets/icon/hisup_mark_dark.svg',
      ).readAsString();
      final mark = await vg.loadPicture(SvgStringLoader(source), null);
      await exportIcon(
        mark.picture,
        'assets/icon/app_icon_dark.png',
        background: true,
      );
      await exportIcon(
        mark.picture,
        'assets/icon/app_icon_dark_transparent.png',
      );
      await exportIcon(
        mark.picture,
        'assets/icon/app_icon_foreground_dark.png',
        markScale: .664,
      );
      const densities = {
        'mdpi': 1.0,
        'hdpi': 1.5,
        'xhdpi': 2.0,
        'xxhdpi': 3.0,
        'xxxhdpi': 4.0,
      };
      for (final entry in densities.entries) {
        final root = 'android/app/src/main/res';
        await exportIcon(
          mark.picture,
          '$root/drawable-night-${entry.key}/ic_launcher_foreground.png',
          size: (108 * entry.value).round(),
          markScale: .664,
        );
        await exportIcon(
          mark.picture,
          '$root/mipmap-night-${entry.key}/ic_launcher.png',
          size: (48 * entry.value).round(),
          background: true,
        );
      }
      mark.picture.dispose();
    });
  });
}
