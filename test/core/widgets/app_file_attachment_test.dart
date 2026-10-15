import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/domain/entities/app_file.dart';
import 'package:hisobchi_uz/core/widgets/media/app_file_attachment.dart';

void main() {
  testWidgets('removal detaches the uploaded file from the form', (
    tester,
  ) async {
    List<AppFile>? attached;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Scaffold(
          body: AppFileAttachment(
            uploadType: 'client',
            initialFiles: const [AppFile(id: 42, url: '', name: 'photo.jpg')],
            onFilesChanged: (files) => attached = files,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Delete'));
    await tester.pump();
    expect(attached, isEmpty);
    expect(find.text('photo.jpg'), findsNothing);
  });

  testWidgets(
    'attachment source sheet scrolls on small screens and large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final scale in [1.0, 2.0]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: const [AppColorsExtension.light]),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: Center(child: AppFileAttachment(onFilesChanged: (_) {})),
            ),
          ),
        );
        await tester.tap(find.text('Fayl biriktirish'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final list = find.byType(ListView);
        await tester.drag(list, const Offset(0, -250));
        await tester.pumpAndSettle();
        expect(find.text('Fayl').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
      }
    },
  );
}
