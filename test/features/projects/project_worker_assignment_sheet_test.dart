import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/events/data_refresh_bus.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/buttons/app_button.dart';
import 'package:hisobchi_uz/features/documents/data/document_models.dart';
import 'package:hisobchi_uz/features/documents/data/documents_repository.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/project_worker_assignment_sheet.dart';

class _Documents implements DocumentsRepository {
  int? excludedProject;
  @override
  Future<ApiResult<List<Worker>>> getWorkers({int? notInProjectId}) async {
    excludedProject = notInProjectId;
    return const ApiResult.success([
      Worker(id: 1, name: 'Ali', phone: '901234567'),
      Worker(id: 2, name: 'Vali', phone: '911234567'),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Projects implements ProjectsRepository {
  int calls = 0;
  int? assignedProject;
  List<int>? assignedWorkers;
  final response = Completer<ApiResult<void>>();
  @override
  Future<ApiResult<void>> addWorkersToProject(
    int projectId,
    List<int> workerIds,
  ) {
    calls++;
    assignedProject = projectId;
    assignedWorkers = workerIds;
    return response.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'assigns multiple unassigned workers with loading and duplicate guard',
    (tester) async {
      final documents = _Documents();
      final projects = _Projects();
      final bus = DataRefreshBus();
      getIt.registerSingleton<DocumentsRepository>(documents);
      getIt.registerSingleton<ProjectsRepository>(projects);
      getIt.registerSingleton<DataRefreshBus>(bus);
      addTearDown(() async {
        await getIt.reset();
        bus.dispose();
      });
      bool? assigned;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  assigned = await showProjectWorkerAssignmentSheet(
                    context,
                    projectId: 4,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(documents.excludedProject, 4);
      await tester.tap(find.text('Ali'));
      await tester.tap(find.text('Vali'));
      await tester.pump();
      await tester.tap(find.text('2 ta xodimni biriktirish'));
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isLoading,
        isTrue,
      );
      await tester.tap(find.byType(AppButton));
      expect(projects.calls, 1);
      expect(projects.assignedProject, 4);
      expect(projects.assignedWorkers, [1, 2]);
      projects.response.complete(const ApiResult.success(null));
      await tester.pumpAndSettle();
      expect(assigned, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
