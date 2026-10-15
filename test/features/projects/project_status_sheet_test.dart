import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/errors/failure.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/buttons/app_button.dart';
import 'package:hisobchi_uz/features/projects/data/project_models.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/project_status_sheet.dart';

class _Repository implements ProjectsRepository {
  final requests =
      <({int id, ProjectStatus status, Completer<ApiResult<void>> response})>[];
  @override
  Future<ApiResult<void>> updateStatus(int id, ProjectStatus status) {
    final response = Completer<ApiResult<void>>();
    requests.add((id: id, status: status, response: response));
    return response.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'status selection requires a change, loads and allows retry after failure',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _Repository();
      getIt.registerSingleton<ProjectsRepository>(repository);
      addTearDown(getIt.reset);
      bool? saved;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  saved = await showProjectStatusSheet(
                    context,
                    project: const Project(
                      id: 4,
                      projectName: 'E-Hisob',
                      projectOwner: 'Bobur',
                      phone: '',
                      status: ProjectStatus.inProgress,
                    ),
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
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).onPressed,
        isNull,
      );
      await tester.tap(find.text('Muzlatilgan'));
      await tester.pump();
      await tester.tap(find.text('Holatni saqlash'));
      await tester.pump();
      expect(
        tester.widget<AppButton>(find.byType(AppButton)).isLoading,
        isTrue,
      );
      await tester.tap(find.byType(AppButton));
      expect(repository.requests.length, 1);
      expect(repository.requests.first.id, 4);
      expect(repository.requests.first.status, ProjectStatus.frozen);
      repository.requests.first.response.complete(
        const ApiResult.failure(BusinessFailure('Saqlashda xatolik')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Saqlashda xatolik'), findsOneWidget);
      await tester.tap(find.text('Holatni saqlash'));
      await tester.pump();
      repository.requests.last.response.complete(const ApiResult.success(null));
      await tester.pumpAndSettle();
      expect(saved, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
