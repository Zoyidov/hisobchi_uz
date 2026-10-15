import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/domain/entities/app_file.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/media/app_file_preview.dart';

void main() {
  testWidgets('signed image URL is used unchanged and opens zoomable preview', (
    tester,
  ) async {
    const url = 'https://example.com/photo.webp?X-Amz-Signature=test';
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: AppFilePreview(files: [AppFile(id: 732, url: url)]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Biriktirilgan fayllar (1)'), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as NetworkImage).url, url);
    await tester.tapAt(
      tester.getTopLeft(find.byType(InkWell).first) + const Offset(10, 10),
    );
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    expect(find.text('Rasm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
