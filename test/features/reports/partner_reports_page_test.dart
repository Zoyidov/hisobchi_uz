import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobchi_uz/core/cubits/user_cubit.dart';
import 'package:hisobchi_uz/core/cubits/owner_context_cubit.dart';
import 'package:hisobchi_uz/core/storage/secure_storage_service.dart';
import 'package:hisobchi_uz/core/domain/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/features/reports/data/partner_report_models.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/partner_reports_page.dart';

class _Auth implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repository implements ReportsRepository {
  @override
  Future<ApiResult<Map<String, PartnerSummaryReport>>>
  getPartnersSummaryReports() async {
    final report = (await getPartnersSummary(1)).dataOrNull!;
    return ApiResult.success({'UZS': report, 'USD': report});
  }

  @override
  Future<ApiResult<PartnerSummaryReport>> getPartnersSummary(
    int currencyTypeId,
  ) async => ApiResult.success(
    PartnerSummaryReport(
      debt: Decimal.fromInt(99940592),
      credit: Decimal.fromInt(88828492),
      balance: Decimal.fromInt(11112100),
      partnersCount: 26,
      operationsCount: 20,
      creditorsCount: 2,
      debtorsCount: 0,
    ),
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'summary fits small screens, large amounts and changes currency',
    (tester) async {
      tester.view.physicalSize = const Size(320, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      getIt.registerSingleton<ReportsRepository>(_Repository());
      addTearDown(getIt.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [AppColorsExtension.light]),
          home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => UserCubit(_Auth())),
              BlocProvider(
                create: (_) => OwnerContextCubit(SecureStorageService()),
              ),
            ],
            child: const PartnerReportsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Qoldiq'), findsOneWidget);
      expect(find.text('Haqdorlar'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('USD Hisob'));
      await tester.pumpAndSettle();
      expect(find.textContaining('−11 112 100 USD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
