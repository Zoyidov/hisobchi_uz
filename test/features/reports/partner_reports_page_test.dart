import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/features/reports/data/partner_report_models.dart';
import 'package:hisobchi_uz/features/reports/data/reports_repository.dart';
import 'package:hisobchi_uz/features/reports/presentation/pages/partner_reports_page.dart';

class _Repository implements ReportsRepository {
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
          home: const PartnerReportsPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Umumiy balans'), findsOneWidget);
      expect(find.text('Haqdorlar'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('USD'));
      await tester.pumpAndSettle();
      expect(find.textContaining('11 112 100 USD'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
