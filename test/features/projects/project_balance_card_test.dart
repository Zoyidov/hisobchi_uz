import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/features/projects/data/project_models.dart';
import 'package:hisobchi_uz/features/projects/presentation/widgets/project_balance_card.dart';

void main() {
  testWidgets('currency selection displays the matching project account', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ProjectBalanceCard(
              account: ProjectAccounts(
                uzs: ProjectCurrencyAccount(
                  income: Decimal.fromInt(1000),
                  cost: Decimal.fromInt(200),
                  balance: Decimal.fromInt(800),
                ),
                usd: ProjectCurrencyAccount(
                  income: Decimal.fromInt(50),
                  cost: Decimal.fromInt(10),
                  balance: Decimal.fromInt(40),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('O‘zbek so‘mi hisobi'), findsOneWidget);
    await tester.tap(find.text('USD'));
    await tester.pumpAndSettle();
    expect(find.text('AQSH dollari hisobi'), findsOneWidget);
    expect(find.text('O‘zbek so‘mi hisobi'), findsNothing);
    expect(find.text('Kirim'), findsOneWidget);
    expect(find.text('Chiqim'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
