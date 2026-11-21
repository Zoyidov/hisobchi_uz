import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/cubits/auth_cubit.dart';
import '../core/cubits/connectivity_cubit.dart';
import '../core/cubits/owner_context_cubit.dart';
import '../core/cubits/subscription_cubit.dart';
import '../core/cubits/user_cubit.dart';
import '../core/di/injector.dart';
import '../core/localization/app_localization_extension.dart';
import '../core/localization/locale_cubit.dart';
import '../core/network/auth_session_controller.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/notifications/presentation/cubit/notification_badge_cubit.dart';
import '../core/widgets/feedback/offline_banner.dart';

/// Auth interceptor 401/403 olganda snackbar ko'rsatish uchun — bu paytda
/// mos `BuildContext` navigatsiya daraxtida bo'lmasligi mumkin.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final _router = buildAppRouter(getIt<AuthCubit>());

  @override
  void initState() {
    super.initState();
    getIt<AuthSessionController>().events.listen(_onAuthSessionEvent);
  }

  Future<void> _onAuthSessionEvent(AuthSessionEvent event) async {
    switch (event) {
      case UnauthenticatedEvent(:final otherDevice):
        final authCubit = getIt<AuthCubit>();
        // Bir vaqtda bir nechta so'rov 401 olishi mumkin — faqat birinchisi
        // sessiyani yopadi va xabar ko'rsatadi.
        if (authCubit.state == AuthStatus.unauthenticated) return;
        // logout() holatni `unauthenticated`ga o'tkazadi — router redirect'i
        // (refreshListenable) foydalanuvchini kirish sahifasiga olib boradi.
        await authCubit.logout();
        getIt<UserCubit>().clear();
        // Bu context MaterialApp'dan yuqorida — Localizations yo'q, shuning
        // uchun joriy til AppL10n orqali olinadi.
        final l10n = AppL10n.current;
        rootScaffoldMessengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                otherDevice ? l10n.errorOtherDevice : l10n.errorSessionExpired,
              ),
            ),
          );
      case OwnerContextInvalidEvent():
        await getIt<OwnerContextCubit>().reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthCubit>()),
        BlocProvider.value(value: getIt<UserCubit>()),
        BlocProvider.value(value: getIt<OwnerContextCubit>()),
        BlocProvider.value(value: getIt<SubscriptionCubit>()),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
        BlocProvider.value(value: getIt<ThemeCubit>()),
        BlocProvider.value(value: getIt<LocaleCubit>()),
        BlocProvider.value(value: getIt<NotificationBadgeCubit>()),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeCubit>().state;
          final locale = context.watch<LocaleCubit>().state;

          return MaterialApp.router(
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.l10n.appName,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            locale: locale,
            supportedLocales: LocaleCubit.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            builder: (context, child) =>
                ConnectivityOverlay(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}
