import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hisobchi_uz/core/constants/app_permission.dart';
import 'package:hisobchi_uz/core/cubits/user_cubit.dart';
import 'package:hisobchi_uz/core/cubits/owner_context_cubit.dart';
import 'package:hisobchi_uz/core/cubits/subscription_cubit.dart';
import 'package:hisobchi_uz/core/storage/secure_storage_service.dart';
import 'package:hisobchi_uz/core/domain/entities/user_entity.dart';
import 'package:hisobchi_uz/core/domain/repositories/auth_repository.dart';
import 'package:hisobchi_uz/core/di/injector.dart';
import 'package:hisobchi_uz/core/events/data_refresh_bus.dart';
import 'package:hisobchi_uz/core/network/api_result.dart';
import 'package:hisobchi_uz/core/router/route_paths.dart';
import 'package:hisobchi_uz/core/theme/app_theme.dart';
import 'package:hisobchi_uz/features/dashboard/data/dashboard_models.dart';
import 'package:hisobchi_uz/features/dashboard/data/dashboard_repository.dart';
import 'package:hisobchi_uz/features/dashboard/presentation/dashboard_page.dart';
import 'package:hisobchi_uz/features/notifications/data/notifications_repository.dart';
import 'package:hisobchi_uz/features/notifications/presentation/cubit/notification_badge_cubit.dart';
import 'package:hisobchi_uz/core/localization/gen/app_localizations.dart';

class _Auth implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User extends UserCubit {
  _User({bool permitted = true}) : super(_Auth()) {
    emit(
      UserLoaded(
        UserEntity.fromJson({
          'user_id': 1,
          'name': 'Farrux',
          'permissions': permitted
              ? [
                  AppPermission.walletsDebtCreate,
                  AppPermission.walletsCreditCreate,
                  AppPermission.partnersCreate,
                  AppPermission.projectsCreate,
                ]
              : [],
        }),
      ),
    );
  }
}

class _Dashboard implements DashboardRepository {
  int loads = 0;
  @override
  Future<ApiResult<DashboardSummary>> getSummary() async {
    loads++;
    return const ApiResult.success(
      DashboardSummary(
        partnersCount: 12,
        qarzExpired: 0,
        qarzToday: 0,
        qarz3Days: 1,
        installmentExpired: 0,
        installmentToday: 0,
        installment3Days: 0,
        projectsCount: 2,
        projectsInProgress: 1,
        projectsFrozen: 0,
        projectsCompleted: 1,
      ),
    );
  }

  @override
  Future<ApiResult<List<TutorialItem>>> getTutorials() async =>
      const ApiResult.success([
        TutorialItem(title: 'Hisob-kitobni boshlash', url: ''),
        TutorialItem(title: 'Hamkorlar bilan ishlash', url: ''),
        TutorialItem(title: 'Loyihalarni yuritish', url: ''),
      ]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Notifications implements NotificationsRepository {
  @override
  Future<ApiResult<int>> getUnreadCount() async => const ApiResult.success(3);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<
  ({GoRouter router, _Dashboard repository, ValueNotifier<ThemeMode> theme})
>
mount(
  WidgetTester tester, {
  bool dark = false,
  double width = 393,
  double scale = 1,
  bool permitted = true,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 44, bottom: 24);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
  final repository = _Dashboard();
  final badge = NotificationBadgeCubit(_Notifications());
  getIt.registerSingleton<DashboardRepository>(repository);
  getIt.registerSingleton<DataRefreshBus>(
    DataRefreshBus(),
    dispose: (bus) => bus.dispose(),
  );
  getIt.registerSingleton<NotificationBadgeCubit>(
    badge,
    dispose: (cubit) => cubit.close(),
  );
  addTearDown(getIt.reset);
  final theme = ValueNotifier(dark ? ThemeMode.dark : ThemeMode.light);
  addTearDown(theme.dispose);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const DashboardPage()),
      for (final path in [
        RoutePaths.partners,
        RoutePaths.projects,
        RoutePaths.profile,
        RoutePaths.profileNotifications,
        RoutePaths.partnerCreate,
        RoutePaths.dashboardDueDates,
        RoutePaths.dashboardInstallmentDueDates,
      ])
        GoRoute(
          path: path,
          builder: (_, state) => Scaffold(
            appBar: AppBar(title: Text(path)),
            body: Text('${state.extra}'),
          ),
        ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(create: (_) => _User(permitted: permitted)),
        BlocProvider(create: (_) => OwnerContextCubit(SecureStorageService())),
        BlocProvider(create: (_) => SubscriptionCubit()),
        BlocProvider.value(value: badge),
      ],
      child: ValueListenableBuilder(
        valueListenable: theme,
        builder: (_, value, _) => MaterialApp.router(
          locale: const Locale('uz'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: value,
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: RepaintBoundary(
              key: const ValueKey('dashboard-preview'),
              child: child!,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, repository: repository, theme: theme);
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
    }
  });
  for (final dark in [false, true]) {
    testWidgets(
      'dashboard renders all sections and retains due-date and tutorial actions (${dark ? 'dark' : 'light'})',
      (tester) async {
        final app = await mount(tester, dark: dark);
        expect(find.text('Farrux'), findsOneWidget);
        expect(find.text('Hisob-kitoblar nazoratda'), findsOneWidget);
        for (final label in ['Kirim', 'Chiqim', 'Hamkor', 'Loyiha']) {
          expect(find.text(label), findsOneWidget);
        }
        expect(find.text('Hamkorlar qarzi'), findsOneWidget);
        expect(find.text('Bo‘lib to‘lash'), findsOneWidget);
        final progress = find.byKey(
          const ValueKey('dashboard-project-progress'),
        );
        final segment = find
            .descendant(of: progress, matching: find.byType(ColoredBox))
            .first;
        expect(tester.getSize(segment).height, 8);
        expect(tester.getSize(segment).width, greaterThan(0));
        if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
          await expectLater(
            find.byKey(const ValueKey('dashboard-preview')),
            matchesGoldenFile(
              '/tmp/hisobchi-dashboard-${dark ? 'dark' : 'light'}.png',
            ),
          );
        }
        await tester.tap(find.text('3 kun ichida').first);
        await tester.pumpAndSettle();
        expect(find.text('DueDateType.qarz3Days'), findsOneWidget);
        app.router.pop();
        await tester.pumpAndSettle();
        expect(app.repository.loads, greaterThan(1));
        await tester.scrollUntilVisible(
          find.text('Qo‘llanmalar (3)'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.ensureVisible(find.text('Qo‘llanmalar (3)'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Qo‘llanmalar (3)'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Hisob-kitobni boshlash'));
        await tester.tap(find.text('Hisob-kitobni boshlash'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            'Qo‘llanmani ochib bo‘lmadi. Keyinroq qayta urinib ko‘ring.',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'small screen, large type, permission filtering and live theme switching',
    (tester) async {
      final app = await mount(tester, width: 320, scale: 1.5, permitted: false);
      expect(find.text('Kirim'), findsNothing);
      expect(find.text('Hamkor'), findsNothing);
      app.theme.value = ThemeMode.dark;
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(DashboardPage));
      expect(Theme.of(context).brightness, Brightness.dark);
      await tester.scrollUntilVisible(
        find.text('Qo‘llanmalar (3)'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('2 ta loyiha'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
