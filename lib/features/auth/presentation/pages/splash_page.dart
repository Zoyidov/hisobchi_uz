import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/auth_cubit.dart';
import '../../../../core/cubits/owner_context_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Splash — versiya tekshiruvi, token holati, maksimal 3 soniya
/// (MOBILE_APP_TZ.md 5.1–5.2).
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final authRepository = getIt<AuthRepository>();
    final deviceInfo = getIt<DeviceInfoService>();
    final secureStorage = getIt<SecureStorageService>();
    final authCubit = context.read<AuthCubit>();
    final userCubit = context.read<UserCubit>();

    try {
      final appVersion = await deviceInfo.appVersion.timeout(const Duration(seconds: 2));
      final versionResult = await authRepository
          .checkVersion(appVersion: appVersion, platformType: deviceInfo.deviceType)
          .timeout(const Duration(seconds: 2));

      final needsHardUpdate = versionResult.dataOrNull?.updateRequired == true &&
          versionResult.dataOrNull?.updateStatus == 'hard';

      if (!mounted) return;
      if (needsHardUpdate) {
        context.go(RoutePaths.forceUpdate);
        return;
      }
    } catch (_) {
      // Versiya tekshiruvi muvaffaqiyatsiz bo'lsa ham ilova to'xtab qolmaydi.
    }

    await authCubit.bootstrap();
    if (!mounted) return;

    if (authCubit.state != AuthStatus.authenticated) {
      context.go(RoutePaths.phone);
      return;
    }

    final pincode = await secureStorage.readPincode();
    if (!mounted) return;

    if (pincode != null && pincode.isNotEmpty) {
      context.go(RoutePaths.pincodeLock);
      return;
    }

    await userCubit.loadMe();
    if (!mounted) return;

    final user = userCubit.currentUserOrNull;
    if (user == null) {
      context.go(RoutePaths.phone);
      return;
    }

    if (user.hasMultipleContexts) {
      context.go(RoutePaths.accountSelection);
    } else {
      if (user.isStaff && user.worksFor.isNotEmpty) {
        await context.read<OwnerContextCubit>().switchTo(
              OwnerContext(ownerId: user.worksFor.first.ownerId, ownerName: user.worksFor.first.ownerName),
            );
      }
      if (!mounted) return;
      context.go(RoutePaths.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_rounded, size: 48, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 20),
            const Text(
              'E-Hisob',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
