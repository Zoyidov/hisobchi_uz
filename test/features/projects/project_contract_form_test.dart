import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/inputs/app_money_field.dart';
import 'package:hisobchi_uz/core/widgets/inputs/app_text_field.dart';
import 'package:hisobchi_uz/core/widgets/buttons/app_button.dart';
import 'package:hisobchi_uz/features/documents/data/document_models.dart';
import 'package:hisobchi_uz/features/documents/data/documents_repository.dart';
import 'package:hisobchi_uz/features/projects/data/project_models.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/project_contracts_tab.dart';

class _Documents implements DocumentsRepository {
  @override
  Future<ApiResult<List<SimpleDocument>>> getWorkTypes() async =>
      const ApiResult.success([SimpleDocument(id: 1, name: 'Montaj')]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Projects implements ProjectsRepository {
  int calls = 0;
  String? submittedDescription;
  final response = Completer<ApiResult<ProjectContract>>();
  @override
  Future<ApiResult<List<ProjectContract>>> getContracts(
    int projectId, {
    String? search,
  }) async => const ApiResult.success([]);
  @override
  Future<ApiResult<ProjectContract>> createContract({
    required int projectId,
    required int workTypeId,
    required String description,
    required Decimal summa,
    List<int>? fileIds,
  }) {
    calls++;
    submittedDescription = description;
    return response.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'description is required and saving blocks duplicate submissions',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final projects = _Projects();
      getIt.registerSingleton<ProjectsRepository>(projects);
      getIt.registerSingleton<DocumentsRepository>(_Documents());
      addTearDown(getIt.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: const Scaffold(body: ProjectContractsTab(projectId: 2)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ish turini tanlang'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Montaj'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AppMoneyField),
          matching: find.byType(TextField),
        ),
        '25000',
      );
      await tester.tap(find.text('Saqlash'));
      await tester.pump();
      expect(projects.calls, 0);
      expect(
        find.text('Tavsif majburiy. Bajariladigan ishni yozing.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.descendant(
          of: find.byType(AppTextField),
          matching: find.byType(TextField),
        ),
        'Montaj ishlari',
      );
      await tester.tap(find.text('Saqlash'));
      await tester.pump();
      expect(projects.calls, 1);
      expect(projects.submittedDescription, 'Montaj ishlari');
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isLoading,
        isTrue,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(projects.calls, 1);
      projects.response.complete(
        ApiResult.success(
          ProjectContract(
            id: 1,
            workTypeId: 1,
            workTypeName: 'Montaj',
            description: '',
            summa: Decimal.fromInt(25000),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Shartnoma qo\'shish'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
