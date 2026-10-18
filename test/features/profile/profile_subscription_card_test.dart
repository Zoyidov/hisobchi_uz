import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/theme/app_colors.dart';
import 'package:hisobchi_uz/features/subscription/data/subscription_repository.dart';
import 'package:hisobchi_uz/features/profile/presentation/widgets/profile_subscription_card.dart';

void main() {
  testWidgets('profile shows plan, deadline and expandable actual usage', (
    tester,
  ) async {
    var requests = 0;
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': true,
                'result': {
                  'has_subscription': true,
                  'subscription': {
                    'plan': {'name': 'pro', 'display_name': 'Professional'},
                    'status_label': 'Faol',
                    'days_until_due': 12,
                    'current_period': {'end': '30.10.2026'},
                    'usage': {
                      'customers': {'current': 26, 'max': 100},
                    },
                  },
                },
              },
            ),
          );
        },
      ),
    );
    getIt.registerSingleton<SubscriptionRepository>(
      SubscriptionRepository(ApiClient(dio)),
    );
    addTearDown(getIt.reset);
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey<ProfileSubscriptionCardState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [AppColorsExtension.light]),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ProfileSubscriptionCard(
                key: key,
                showDetails: true,
                showLimits: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Professional'), findsOneWidget);
    expect(find.text('12 kun qoldi'), findsOneWidget);
    await tester.tap(find.text('Limitlar va foydalanish'));
    await tester.pumpAndSettle();
    expect(find.text('26 / 100'), findsOneWidget);
    final refresh = key.currentState!.refresh();
    await tester.pumpAndSettle();
    await refresh;
    expect(requests, 2);
    expect(find.text('Professional'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
