import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/network/paged_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/buttons/app_button.dart';
import 'package:hisobchi_uz/core/widgets/cards/app_card.dart';
import 'package:hisobchi_uz/core/widgets/inputs/app_money_field.dart';
import 'package:hisobchi_uz/features/documents/data/document_models.dart';
import 'package:hisobchi_uz/features/documents/data/documents_repository.dart';
import 'package:hisobchi_uz/features/projects/data/project_models.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/project_incomes_tab.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/project_costs_tab.dart';

final income = ProjectIncome(
  id: 9,
  currencyTypeId: 1,
  currencyTypeName: 'UZS',
  summa: Decimal.fromInt(700000),
  createdAt: DateTime(2026, 3, 4, 11, 44),
);
final cost = ProjectCost(
  id: 15,
  costTypeId: 1,
  costTypeName: 'Ish haqi',
  currencyTypeId: 1,
  currencyTypeName: 'UZS',
  summa: Decimal.fromInt(500000),
  workerName: 'Umidjon',
  createdAt: DateTime(2026, 3, 4, 11, 44),
);

class _Documents implements DocumentsRepository {
  @override
  Future<ApiResult<List<CostType>>> getCostTypes() async =>
      const ApiResult.success([
        CostType(
          id: 2,
          name: 'Transport',
          isWorkerJoin: false,
          isSystem: false,
        ),
      ]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Projects implements ProjectsRepository {
  int calls = 0;
  final incomeResponse = Completer<ApiResult<ProjectIncome>>();
  final costResponse = Completer<ApiResult<ProjectCost>>();
  @override
  Future<ApiResult<SimplePage<ProjectIncome>>> getIncomes(
    int id, {
    int page = 1,
    String? search,
  }) async => ApiResult.success(SimplePage(items: [income], hasNext: false));
  @override
  Future<ApiResult<SimplePage<ProjectCost>>> getCosts(
    int id, {
    int page = 1,
    String? search,
    int? costTypeId,
  }) async => ApiResult.success(SimplePage(items: [cost], hasNext: false));
  @override
  Future<ApiResult<ProjectIncome>> createIncome({
    required int projectId,
    required int currencyTypeId,
    required Decimal summa,
    String? description,
    List<int>? fileIds,
  }) {
    calls++;
    return incomeResponse.future;
  }

  @override
  Future<ApiResult<ProjectCost>> createCost({
    required int projectId,
    required int costTypeId,
    required int currencyTypeId,
    required Decimal summa,
    String? description,
    int? workerId,
    List<int>? fileIds,
  }) {
    calls++;
    return costResponse.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final expense in [false, true]) {
    testWidgets(
      '${expense ? 'cost' : 'income'} opens detail and shows saving without duplicate requests',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = _Projects();
        getIt.registerSingleton<ProjectsRepository>(repository);
        getIt.registerSingleton<DocumentsRepository>(_Documents());
        addTearDown(getIt.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: const [AppColorsExtension.light]),
            home: Scaffold(
              body: expense
                  ? const ProjectCostsTab(projectId: 4)
                  : const ProjectIncomesTab(projectId: 4),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AppCard));
        await tester.pumpAndSettle();
        expect(
          find.text(expense ? 'Xarajat tafsilotlari' : 'Daromad tafsilotlari'),
          findsOneWidget,
        );
        expect(find.text('04.03.2026 11:44'), findsOneWidget);
        expect(find.text('Izoh kiritilmagan'), findsOneWidget);
        if (expense) expect(find.text('Umidjon'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        if (expense) {
          await tester.tap(find.text('Tanlanmagan'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Transport'));
          await tester.pumpAndSettle();
        }
        await tester.enterText(
          find.descendant(
            of: find.byType(AppMoneyField),
            matching: find.byType(TextField),
          ),
          '10000',
        );
        await tester.tap(find.text('Saqlash'));
        await tester.pump();
        expect(repository.calls, 1);
        expect(
          tester.widget<AppButton>(find.byType(AppButton)).isLoading,
          isTrue,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.tap(find.byType(AppButton));
        await tester.pump();
        expect(repository.calls, 1);
        if (expense) {
          repository.costResponse.complete(ApiResult.success(cost));
        } else {
          repository.incomeResponse.complete(ApiResult.success(income));
        }
        await tester.pumpAndSettle();
        expect(find.text('Saqlash'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
