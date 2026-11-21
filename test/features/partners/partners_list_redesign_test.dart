import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi_uz/core/constants/app_permission.dart';
import 'package:hisobchi_uz/core/cubits/user_cubit.dart';
import 'package:hisobchi_uz/core/cubits/owner_context_cubit.dart';
import 'package:hisobchi_uz/core/domain/entities/user_entity.dart';
import 'package:hisobchi_uz/core/domain/repositories/auth_repository.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/events/data_refresh_bus.dart';
import 'package:hisobchi_uz/core/network/api_client.dart';
import 'package:hisobchi_uz/core/router/route_paths.dart';
import 'package:hisobchi_uz/core/storage/secure_storage_service.dart';
import 'package:hisobchi_uz/core/theme/app_theme.dart';
import 'package:hisobchi_uz/features/partners/data/partners_repository.dart';
import 'package:hisobchi_uz/features/partners/presentation/pages/partners_list_page.dart';
import 'package:hisobchi_uz/core/localization/gen/app_localizations.dart';

class _Auth implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User extends UserCubit {
  _User(bool permitted) : super(_Auth()) {
    emit(
      UserLoaded(
        UserEntity.fromJson({
          'user_id': 1,
          'permissions': permitted ? [AppPermission.partnersCreate] : [],
        }),
      ),
    );
  }
}

Future<GoRouter> mount(
  WidgetTester tester,
  List<RequestOptions> requests, {
  bool dark = false,
  bool small = false,
}) async {
  tester.view.physicalSize = Size(small ? 320 : 393, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 90);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        requests.add(options);
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': true,
              'result': {
                'links': {'next': null},
                'data': [
                  {
                    'id': 1,
                    'name': small
                        ? 'Хаётбахром Акамнинг узун исмли ҳамкори'
                        : 'Хаётбахром Ака',
                    'phone': '977332112',
                    'main_currency_type_id': 1,
                    'balance': {
                      'UZS': small ? '-999999999999.75' : '-120000',
                      'USD': 0,
                    },
                  },
                  {
                    'id': 2,
                    'name': 'farrux 3322',
                    'phone': '937373322',
                    'main_currency_type_id': 1,
                    'balance': {'UZS': '7046543.5', 'USD': 0},
                    'installment_remaining': {
                      'UZS': '72000.25',
                      'USD': '50.75',
                    },
                  },
                  {
                    'id': 3,
                    'name': 'Azizbek',
                    'phone': '993155544',
                    'main_currency_type_id': 1,
                    'balance': {'UZS': '4155557', 'USD': 0},
                  },
                  {
                    'id': 4,
                    'name': 'Sherbek',
                    'phone': '930007532',
                    'main_currency_type_id': 2,
                    'balance': {'UZS': 0, 'USD': '-100.5'},
                  },
                  {
                    'id': 5,
                    'name': 'Ali',
                    'phone': '901234567',
                    'main_currency_type_id': 1,
                    'balance': {'UZS': 0, 'USD': 0},
                  },
                ],
              },
            },
          ),
        );
      },
    ),
  );
  getIt.registerSingleton<PartnersRepository>(
    PartnersRepository(ApiClient(dio)),
  );
  getIt.registerSingleton<DataRefreshBus>(
    DataRefreshBus(),
    dispose: (bus) => bus.dispose(),
  );
  addTearDown(getIt.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const PartnersListPage()),
      GoRoute(
        path: '/partners/:id',
        builder: (_, state) => Scaffold(
          appBar: AppBar(title: const Text('Mijoz tafsiloti')),
          body: Text(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: RoutePaths.partnerCreate,
        builder: (_, _) => const Scaffold(body: Text('Yangi mijoz')),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(create: (_) => _User(!small)),
        BlocProvider(create: (_) => OwnerContextCubit(SecureStorageService())),
      ],
      child: MaterialApp.router(
        locale: const Locale('uz'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(small ? 1.5 : 1)),
          child: RepaintBoundary(
            key: const ValueKey('partners-preview'),
            child: child!,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  setUpAll(() async {
    await (FontLoader('packages/solar_icons/SolarIcons')..addFont(
          rootBundle.load('packages/solar_icons/fonts/SolarIcons.ttf'),
        ))
        .load();
    const path = String.fromEnvironment('UI_PREVIEW_FONT');
    if (path.isNotEmpty) {
      await (FontLoader('Roboto')..addFont(
            Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
          ))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      await (FontLoader('CupertinoIcons')..addFont(
            rootBundle.load(
              'packages/cupertino_icons/assets/CupertinoIcons.ttf',
            ),
          ))
          .load();
    }
  });
  for (final dark in [false, true]) {
    testWidgets(
      'compact partner list retains balances, filters, search, sorting and menu (${dark ? 'dark' : 'light'})',
      (tester) async {
        final requests = <RequestOptions>[];
        final router = await mount(tester, requests, dark: dark);
        expect(find.text('+7 046 543,5 UZS'), findsOneWidget);
        expect(find.text('72 000,25 UZS'), findsOneWidget);
        expect(find.text('50,75 USD'), findsOneWidget);
        expect(find.text('Haqdor'), findsWidgets);
        if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
          await expectLater(
            find.byKey(const ValueKey('partners-preview')),
            matchesGoldenFile(
              '/tmp/hisobchi-partners-${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        await tester.drag(find.byType(ChoiceChip).first, const Offset(-220, 0));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Qarzdorlar'));
        await tester.pumpAndSettle();
        expect(requests.last.queryParameters['status_filter'], 'qarzdor');
        await tester.enterText(find.byType(TextField), 'Farrux');
        await tester.pump(const Duration(milliseconds: 450));
        await tester.pumpAndSettle();
        expect(requests.last.queryParameters['search'], 'Farrux');
        await tester.tap(find.byTooltip('Saralash: Oxirgi faollik'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Qarzdor USD'));
        await tester.pumpAndSettle();
        expect(requests.last.queryParameters['sort'], isNotNull);
        await tester.tap(find.byTooltip('Mijoz amallari').first);
        await tester.pumpAndSettle();
        expect(find.text('Qo‘ng‘iroq qilish'), findsOneWidget);
        expect(find.text('SMS yozish'), findsOneWidget);
        await tester.tap(find.text('Tafsilotlarni ochish'));
        await tester.pumpAndSettle();
        expect(find.text('Mijoz tafsiloti'), findsOneWidget);
        router.pop();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'large amounts and type remain visible at 320px, add permission is respected',
    (tester) async {
      await mount(tester, [], dark: true, small: true);
      expect(find.byTooltip('Yangi mijoz qo‘shish'), findsNothing);
      expect(tester.getBottomRight(find.byType(NestedScrollView)).dy, 852);
      expect(find.text('−999 999 999 999,75 UZS'), findsOneWidget);
      await tester.drag(find.byType(NestedScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
