import 'dart:async';

import 'package:flutter/cupertino.dart';
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

/// Premium iOS uslubidagi zamonaviy Splash Screen.
/// Versiya tekshiruvi, token holati, xavfsiz bootstrap jarayoni.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );

    _controller.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final authRepository = getIt<AuthRepository>();
    final deviceInfo = getIt<DeviceInfoService>();
    final secureStorage = getIt<SecureStorageService>();
    final authCubit = context.read<AuthCubit>();
    final userCubit = context.read<UserCubit>();

    // Kamida 1.2 soniya silliq splash animatsiyasi ko'rinishi uchun
    final minSplashWait = Future<void>.delayed(const Duration(milliseconds: 1200));

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
      await minSplashWait;
      if (!mounted) return;
      context.go(RoutePaths.phone);
      return;
    }

    final pincode = await secureStorage.readPincode();
    if (!mounted) return;

    if (pincode != null && pincode.isNotEmpty) {
      await minSplashWait;
      if (!mounted) return;
      context.go(RoutePaths.pincodeLock);
      return;
    }

    await userCubit.loadMe();
    if (!mounted) return;

    final user = userCubit.currentUserOrNull;
    if (user == null) {
      await minSplashWait;
      if (!mounted) return;
      context.go(RoutePaths.phone);
      return;
    }

    await minSplashWait;
    if (!mounted) return;

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
    return Scaffold(
      body: Stack(
        children: [
          // 1. Luxury Midnight-Blue Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF090D16),
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF0A101D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          // 2. Ambient Glow Mesh Spheres
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF2563EB).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Markaziy Brending va Logo
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnim.value,
                  child: Transform.scale(
                    scale: _scaleAnim.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glassmorphic Glowing Logo Card
                  Container(
                    width: 92,
                    height: 92,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2563EB),
                          Color(0xFF1D4ED8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                          blurRadius: 32,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 14,
                          left: 14,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chart_pie_fill,
                          size: 46,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Brand Name
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Hisobchi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          '.uz',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Text(
                    'Biznes va moliya boshqaruvi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Pastki yuklanish indikatori va ishonch nishoni
          Positioned(
            left: 0,
            right: 0,
            bottom: 48,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(
                    radius: 11,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_shield_fill,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Xavfsiz va himoyalangan tizim',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
