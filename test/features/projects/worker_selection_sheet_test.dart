import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/events/data_refresh_bus.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/inputs/app_phone_field.dart';
import 'package:hisobchi_uz/features/documents/data/document_models.dart';
import 'package:hisobchi_uz/features/documents/data/documents_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/worker_selection_sheet.dart';

class _Repository implements DocumentsRepository {
  int creates = 0;
  int? receivedPosition;
  String? receivedAdditionalPhone;
  @override
  Future<ApiResult<List<Worker>>> getWorkers({int? notInProjectId}) async =>
      const ApiResult.success([]);
  @override
  Future<ApiResult<List<SimpleDocument>>> getPositions() async =>
      const ApiResult.success([SimpleDocument(id: 3, name: 'Elektrik')]);

  @override
  Future<ApiResult<Worker>> createWorker({
    required String name,
    required String phone,
    String? additionalPhone,
    int? positionId,
    List<int>? fileIds,
    String? description,
  }) async {
    creates++;
    receivedPosition = positionId;
    receivedAdditionalPhone = additionalPhone;
    return ApiResult.success(Worker(id: 17, name: name, phone: phone));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('empty selection can create a worker and return it selected', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _Repository();
    final bus = DataRefreshBus();
    getIt.registerSingleton<DocumentsRepository>(repository);
    getIt.registerSingleton<DataRefreshBus>(bus);
    addTearDown(() async {
      await getIt.reset();
      bus.dispose();
    });
    Worker? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                selected = await showWorkerSelectionSheet(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Ishchilar hali mavjud emas'), findsOneWidget);
    await tester.tap(find.byTooltip('Yangi ishchi yaratish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yaratish va tanlash'));
    await tester.pumpAndSettle();
    expect(repository.creates, 0);
    expect(find.text('Ishchi ismini kiriting'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'Umidjon');
    await tester.enterText(
      find.descendant(
        of: find.byType(AppPhoneField).first,
        matching: find.byType(TextField),
      ),
      '901234567',
    );
    await tester.enterText(
      find.descendant(
        of: find.byType(AppPhoneField).last,
        matching: find.byType(TextField),
      ),
      '911234567',
    );
    await tester.tap(find.text('Yaratish va tanlash'));
    await tester.pumpAndSettle();
    expect(repository.creates, 0);
    expect(find.text('Lavozimni tanlang'), findsWidgets);
    await tester.tap(find.text('Lavozimni tanlang').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elektrik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yaratish va tanlash'));
    await tester.pumpAndSettle();
    expect(repository.creates, 1);
    expect(selected?.id, 17);
    expect(selected?.name, 'Umidjon');
    expect(selected?.phone, '901234567');
    expect(repository.receivedPosition, 3);
    expect(repository.receivedAdditionalPhone, '911234567');
    expect(tester.takeException(), isNull);
  });
}
