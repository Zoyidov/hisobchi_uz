import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/domain/entities/app_file.dart';
import 'package:hisobchi_uz/core/errors/failure.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/buttons/app_button.dart';
import 'package:hisobchi_uz/core/widgets/inputs/app_phone_field.dart';
import 'package:hisobchi_uz/core/widgets/inputs/app_text_field.dart';
import 'package:hisobchi_uz/features/projects/data/project_models.dart';
import 'package:hisobchi_uz/features/projects/data/projects_repository.dart';
import 'package:hisobchi_uz/features/projects/presentation/pages/project_form_page.dart';

class _Repository implements ProjectsRepository {
  int calls = 0;
  String? phone;
  int? id;
  List<int>? uploadedIds;
  final response = Completer<ApiResult<Project>>();
  @override
  Future<ApiResult<Project>> createProject({
    required String projectName,
    required String projectOwner,
    required String phone,
    String? address,
    String? location,
    List<int>? fileIds,
  }) {
    calls++;
    this.phone = phone;
    uploadedIds = fileIds;
    return response.future;
  }

  @override
  Future<ApiResult<Project>> updateProject(
    int id, {
    required String projectName,
    required String projectOwner,
    required String phone,
    String? address,
    String? location,
    List<int>? fileIds,
  }) {
    calls++;
    this.id = id;
    this.phone = phone;
    uploadedIds = fileIds;
    return response.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final editing in [false, true]) {
    testWidgets(
      '${editing ? 'edit' : 'create'} uses phone mask and submits nine digits',
      (tester) async {
        tester.view.physicalSize = const Size(390, 850);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = _Repository();
        getIt.registerSingleton<ProjectsRepository>(repository);
        addTearDown(getIt.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: const [AppColorsExtension.light]),
            home: ProjectFormPage(
              editing: editing
                  ? const Project(
                      id: 4,
                      projectName: 'E-Hisob',
                      projectOwner: 'Bobur',
                      phone: '998901234567',
                      status: ProjectStatus.inProgress,
                      files: [AppFile(id: 735, url: '', name: 'photo.webp')],
                    )
                  : null,
            ),
          ),
        );
        final phoneField = find.descendant(
          of: find.byType(AppPhoneField),
          matching: find.byType(TextField),
        );
        if (editing) {
          expect(
            tester.widget<TextField>(phoneField).controller!.text,
            '+998 (90) 123-45-67',
          );
        } else {
          await tester.enterText(
            find.descendant(
              of: find.byType(AppTextField).at(0),
              matching: find.byType(TextField),
            ),
            'Yangi ofis',
          );
          await tester.enterText(
            find.descendant(
              of: find.byType(AppTextField).at(1),
              matching: find.byType(TextField),
            ),
            'Bobur',
          );
          await tester.enterText(phoneField, '90123');
          await tester.tap(find.byType(AppButton));
          await tester.pump();
          expect(repository.calls, 0);
          expect(
            find.text('Telefon raqami 9 ta raqamdan iborat bo\'lishi kerak'),
            findsOneWidget,
          );
          await tester.enterText(phoneField, '901234567');
          await tester.pump();
          expect(
            tester.widget<TextField>(phoneField).controller!.text,
            '+998 (90) 123-45-67',
          );
        }
        await tester.tap(find.byType(AppButton));
        await tester.pump();
        expect(repository.phone, '901234567');
        expect(repository.calls, 1);
        expect(repository.id, editing ? 4 : null);
        expect(repository.uploadedIds, editing ? [735] : null);
        expect(
          tester.widget<AppButton>(find.byType(AppButton)).isLoading,
          isTrue,
        );
        repository.response.complete(
          const ApiResult.failure(BusinessFailure('Qayta urinib ko‘ring')),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<AppButton>(find.byType(AppButton)).isLoading,
          isFalse,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
