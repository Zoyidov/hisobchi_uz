import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/cubits/auth_cubit.dart';
import '../core/cubits/connectivity_cubit.dart';
import '../core/cubits/owner_context_cubit.dart';
import '../core/cubits/subscription_cubit.dart';
import '../core/cubits/user_cubit.dart';
import '../core/di/injector.dart';
import '../core/localization/app_localization_extension.dart';
import '../core/localization/gen/app_localizations.dart';
import '../core/localization/locale_cubit.dart';
import '../core/network/auth_session_controller.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_cubit.dart';
import '../features/notifications/presentation/cubit/notification_badge_cubit.dart';

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
        await getIt<AuthCubit>().logout();
        getIt<UserCubit>().clear();
        rootScaffoldMessengerKey.currentState
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(otherDevice ? 'Hisobingizga boshqa qurilmadan kirildi' : 'Sessiya tugadi, qaytadan kiring'),
          ));
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

          return ScreenUtilInit(
            designSize: const Size(360, 800),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp.router(
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
            ),
          );
        },
      ),
    );
  }
}
