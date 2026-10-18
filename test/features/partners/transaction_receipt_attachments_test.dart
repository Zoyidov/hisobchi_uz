import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/core/widgets/media/app_file_preview.dart';
import 'package:hisobchi_uz/features/partners/data/partner_models.dart';
import 'package:hisobchi_uz/features/partners/presentation/widgets/transaction_receipt_sheet.dart';

void main() {
  testWidgets('wallet files are parsed and shown in the transaction receipt', (
    tester,
  ) async {
    const url =
        'https://example.com/transaction/photo.webp?X-Amz-Signature=test';
    final wallet = Wallet.fromJson({
      'id': 14443,
      'partner_id': 353,
      'partner_name': 'Farrux',
      'currency_type_id': 1,
      'currency_type_name': 'UZS',
      'summa': '900009.00',
      'type': 'debt',
      'is_cancelled': 0,
      'files': [
        {'id': 733, 'url': url},
        {'id': 734, 'url': url},
      ],
    });
    expect(wallet.files.map((file) => file.id), [733, 734]);
    expect(wallet.files.first.url, url);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showTransactionReceiptSheet(
                context,
                wallet: wallet,
                partner: Partner.placeholder(id: 353, name: 'Farrux'),
                isOwner: false,
                canCancel: false,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(AppFilePreview), findsOneWidget);
    expect(find.text('Biriktirilgan fayllar (2)'), findsOneWidget);
    Map<dynamic, dynamic>? shareArguments;
    const channel = MethodChannel('dev.fluttercommunity.plus/share');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
      call,
    ) async {
      shareArguments = call.arguments as Map<dynamic, dynamic>;
      return 'success';
    });
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.ensureVisible(find.text('Chekni ulashish'));
    await tester.tap(find.text('Chekni ulashish'));
    await tester.pumpAndSettle();
    expect(shareArguments, isNotNull);
    expect(shareArguments!['originWidth'], greaterThan(0));
    expect(shareArguments!['originHeight'], greaterThan(0));
    expect(shareArguments!['originX'], greaterThanOrEqualTo(0));
    expect(shareArguments!['originY'], greaterThanOrEqualTo(0));
    expect(tester.takeException(), isNull);
  });
}
