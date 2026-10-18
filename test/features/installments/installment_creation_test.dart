import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/features/installments/data/installment_models.dart';
import 'package:hisobchi_uz/features/installments/data/installment_scheduler.dart';
import 'package:hisobchi_uz/features/installments/data/installments_repository.dart';
import 'package:hisobchi_uz/features/installments/presentation/cubit/installment_create_cubit.dart';

void main() {
  test(
    'API payload includes advance once and preserves attachment IDs',
    () async {
      final dio = Dio();
      final requests = <Map<String, dynamic>>[];
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(Map<String, dynamic>.from(options.data as Map));
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'status': true,
                  'data': {'id': 1},
                },
              ),
            );
          },
        ),
      );
      final repository = InstallmentsRepository(ApiClient(dio));
      await repository.createEqual(
        partnerId: 7,
        currencyTypeId: 2,
        totalAmount: Decimal.fromInt(100),
        hasAdvance: true,
        advanceAmount: Decimal.fromInt(10),
        startDate: DateTime(2026, 10, 19),
        installmentCount: 3,
        fileIds: [4, 5],
        note: 'Test',
      );
      expect(requests.single['file_ids'], [4, 5]);
      expect(requests.single['partner_id'], 7);
      final equalItems = requests.single['items'] as List;
      expect(equalItems.length, 4);
      expect(equalItems.first['amount'], '10');
      expect(
        equalItems.fold(
          Decimal.zero,
          (sum, i) => sum + Decimal.parse(i['amount'] as String),
        ),
        Decimal.fromInt(100),
      );
      await repository.createCustom(
        partnerId: 7,
        currencyTypeId: 2,
        totalAmount: Decimal.fromInt(100),
        hasAdvance: true,
        advanceAmount: Decimal.fromInt(10),
        items: [
          InstallmentPreviewItem(
            itemNumber: 1,
            amount: Decimal.fromInt(90),
            dueDate: DateTime(2026, 11, 19),
            isAdvance: false,
          ),
        ],
      );
      final customItems = requests.last['items'] as List;
      expect(customItems.length, 2);
      expect(customItems.first['amount'], '10');
      expect(customItems.last['amount'], '90');
    },
  );

  test('equal schedule preserves cents and allocates the exact total', () {
    final items = InstallmentScheduler.generateEqualSchedule(
      totalAmount: Decimal.parse('100.01'),
      hasAdvance: true,
      advanceAmount: Decimal.parse('10'),
      startDate: DateTime(2026, 10, 19),
      installmentCount: 3,
    );
    expect(items.first.isAdvance, isTrue);
    expect(items.first.itemNumber, 0);
    expect(items[1].amount, Decimal.parse('30'));
    expect(items.last.amount, Decimal.parse('30.01'));
    expect(
      items.fold(Decimal.zero, (sum, item) => sum + item.amount),
      Decimal.parse('100.01'),
    );
  });

  test('clearing amount fields clears the actual submission state', () async {
    final cubit = InstallmentCreateCubit(
      InstallmentsRepository(ApiClient(Dio())),
      partnerId: 1,
      currencyTypeId: 1,
    );
    cubit.setTotalAmount(Decimal.fromInt(100));
    cubit.setTotalAmount(null);
    cubit.nextStep();
    expect(cubit.state.totalAmount, isNull);
    expect(cubit.state.step, 0);
    cubit.setAdvanceAmount(Decimal.fromInt(10));
    cubit.setAdvanceAmount(null);
    expect(cubit.state.advanceAmount, isNull);
    await cubit.close();
  });

  test('custom preview includes advance exactly once and keeps cents', () {
    final state = InstallmentCreateState(
      totalAmount: Decimal.parse('100.50'),
      scheduleType: InstallmentScheduleType.custom,
      hasAdvance: true,
      advanceAmount: Decimal.parse('20.25'),
      customItems: [
        InstallmentPreviewItem(
          itemNumber: 1,
          amount: Decimal.parse('80.25'),
          dueDate: DateTime.now().add(const Duration(days: 5)),
          isAdvance: false,
        ),
      ],
    );
    expect(state.step2ValidationError, isNull);
    expect(state.preview.length, 2);
    expect(state.preview.first.isAdvance, isTrue);
    expect(
      state.preview.fold(Decimal.zero, (sum, item) => sum + item.amount),
      state.totalAmount,
    );
    expect(
      state.copyWith(advanceAmount: Decimal.zero).step2ValidationError,
      isNotNull,
    );
  });

  test('custom schedule rejects zero payments and mismatched totals', () {
    final state = InstallmentCreateState(
      totalAmount: Decimal.fromInt(100),
      scheduleType: InstallmentScheduleType.custom,
      customItems: [
        InstallmentPreviewItem(
          itemNumber: 1,
          amount: Decimal.zero,
          dueDate: DateTime.now(),
          isAdvance: false,
        ),
        InstallmentPreviewItem(
          itemNumber: 2,
          amount: Decimal.fromInt(100),
          dueDate: DateTime.now(),
          isAdvance: false,
        ),
      ],
    );
    expect(state.step2ValidationError, isNotNull);
  });
}
