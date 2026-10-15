import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/events/data_refresh_bus.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/features/documents/data/document_models.dart';
import 'package:hisobchi_uz/features/documents/data/documents_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/cost_type_selection_sheet.dart';

class _Repository implements DocumentsRepository {
  int creates = 0;
  bool? workerJoin;
  @override
  Future<ApiResult<List<CostType>>> getCostTypes() async =>
      const ApiResult.success([]);
  @override
  Future<ApiResult<CostType>> createCostType({
    required String name,
    String? description,
    required bool isWorkerJoin,
  }) async {
    creates++;
    workerJoin = isWorkerJoin;
    return ApiResult.success(
      CostType(id: 17, name: name, isWorkerJoin: isWorkerJoin, isSystem: false),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('empty selection can create a cost type and return it selected', (
    tester,
  ) async {
    final repository = _Repository();
    final bus = DataRefreshBus();
    getIt.registerSingleton<DocumentsRepository>(repository);
    getIt.registerSingleton<DataRefreshBus>(bus);
    addTearDown(() async {
      await getIt.reset();
      bus.dispose();
    });
    CostType? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                selected = await showCostTypeSelectionSheet(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Xarajat turlari hali mavjud emas'), findsOneWidget);
    await tester.tap(find.byTooltip('Yangi xarajat turi yaratish'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yaratish va tanlash'));
    await tester.pumpAndSettle();
    expect(repository.creates, 0);
    expect(find.text('Xarajat turi nomini kiriting'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'Asbob-uskunalar');
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();
    await tester.tap(find.text('Yaratish va tanlash'));
    await tester.pumpAndSettle();
    expect(repository.creates, 1);
    expect(repository.workerJoin, isTrue);
    expect(selected?.isWorkerJoin, isTrue);
    expect(selected?.id, 17);
    expect(selected?.name, 'Asbob-uskunalar');
    expect(tester.takeException(), isNull);
  });
}
