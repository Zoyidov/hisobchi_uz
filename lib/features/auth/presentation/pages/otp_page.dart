import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../cubit/otp_cubit.dart';

/// OTP tasdiqlash — Senior Level FinTech 4-xonali avtomatik tasdiqlash ekrani.
class OtpPage extends StatelessWidget {
  const OtpPage({super.key, required this.phone, required this.mode});

  final String phone;
  final OtpMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(getIt<AuthRepository>(), phone: phone, mode: mode),
      child: _OtpView(phone: phone, mode: mode),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView({required this.phone, required this.mode});

  final String phone;
  final OtpMode mode;

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<OtpCubit, OtpState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            HapticFeedback.mediumImpact();
            if (widget.mode == OtpMode.register) {
              context.push(RoutePaths.register, extra: {
                'phone': widget.phone,
                'verifyToken': state.payload,
              });
            } else {
              context.push(RoutePaths.resetPassword, extra: {
                'phone': widget.phone,
                'otpCode': state.payload,
              });
            }
          } else if (state is OtpInvalid) {
            HapticFeedback.heavyImpact();
            _controller.clear();
            AppSnackbar.error(context, state.failure.message);
          }
        },
        builder: (context, state) {
          final isVerifying = state is OtpVerifying;

          return Stack(
            children: [
              // 1. Ambient Glow Elements
              Positioned(
                top: -100,
                right: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.primary.withValues(alpha: isDark ? 0.22 : 0.12),
                          colors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -90,
                left: -70,
                child: IgnorePointer(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.accentViolet.withValues(alpha: isDark ? 0.15 : 0.08),
                          colors.accentViolet.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Main Content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: AppSpacing.md),

                                  // Top Navigation Bar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () => context.pop(),
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: colors.surfaceSecondary.withValues(alpha: 0.8),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: colors.borderSubtle,
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            size: 18,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.primaryContainer.withValues(
                                            alpha: isDark ? 0.4 : 0.8,
                                          ),
                                          borderRadius: AppRadius.pillRadius,
                                          border: Border.all(
                                            color: colors.primary.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          'XAVFSIZLIK QADAMI',
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(flex: 2),

                                  // Hero Visual Icon with Multi-layer Glow
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 76,
                                          height: 76,
                                          decoration: BoxDecoration(
                                            color: colors.primary.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(26),
                                          ),
                                        ),
                                        Container(
                                          width: 68,
                                          height: 68,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                colors.primary,
                                                colors.primary.withValues(alpha: 0.85),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(22),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.primary.withValues(
                                                  alpha: isDark ? 0.5 : 0.32,
                                                ),
                                                blurRadius: 18,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.sms_rounded,
                                            size: 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xl),

                                  // Headings
                                  Text(
                                    'Tasdiqlash kodi 🔐',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Quyidagi telefon raqamiga yuborilgan 4 xonali SMS kodni kiriting:',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 14.5,
                                      height: 1.45,
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.md),

                                  // Phone Number Badge with Edit Option
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceSecondary.withValues(
                                          alpha: isDark ? 0.6 : 0.8,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: colors.borderSubtle,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('🇺🇿', style: TextStyle(fontSize: 17)),
                                          const SizedBox(width: 8),
                                          Text(
                                            PhoneFormatter.toDisplay(widget.phone),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.5,
                                              color: colors.textPrimary,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            onTap: () => context.pop(),
                                            borderRadius: BorderRadius.circular(8),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                'O\'zgartirish',
                                                style: TextStyle(
                                                  color: colors.primary,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xxl),

                                  // FinTech 4-digit PinCode Input
                                  AbsorbPointer(
                                    absorbing: isVerifying,
                                    child: PinCodeTextField(
                                      appContext: context,
                                      length: 4,
                                      controller: _controller,
                                      autoDisposeControllers: false,
                                      autoFocus: true,
                                      keyboardType: TextInputType.number,
                                      animationType: AnimationType.fade,
                                      enableActiveFill: true,
                                      textStyle: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: colors.textPrimary,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                      pinTheme: PinTheme(
                                        shape: PinCodeFieldShape.box,
                                        borderRadius: BorderRadius.circular(18),
                                        fieldHeight: 64,
                                        fieldWidth: 62,
                                        borderWidth: 1.8,
                                        activeColor: colors.primary,
                                        selectedColor: colors.primary,
                                        inactiveColor: colors.border.withValues(alpha: 0.8),
                                        activeFillColor: isDark ? colors.surfaceSecondary : colors.surface,
                                        selectedFillColor: isDark ? colors.surfaceSecondary : colors.surface,
                                        inactiveFillColor: isDark
                                            ? colors.surfaceSecondary.withValues(alpha: 0.5)
                                            : colors.surfaceSecondary.withValues(alpha: 0.6),
                                      ),
                                      onChanged: (_) {},
                                      onCompleted: (code) {
                                        HapticFeedback.selectionClick();
                                        context.read<OtpCubit>().submit(code);
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xl),

                                  // Verification Progress / Resend Section
                                  Center(
                                    child: isVerifying
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2.2,
                                                  valueColor: AlwaysStoppedAnimation(colors.primary),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Kod tekshirilmoqda...',
                                                style: TextStyle(
                                                  color: colors.textSecondary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        : state.secondsRemaining > 0
                                            ? Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colors.surfaceSecondary.withValues(alpha: 0.5),
                                                  borderRadius: AppRadius.pillRadius,
                                                  border: Border.all(
                                                    color: colors.borderSubtle,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.timer_outlined,
                                                      size: 16,
                                                      color: colors.textSecondary,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Kodni qayta yuborish: ',
                                                      style: TextStyle(
                                                        color: colors.textSecondary,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    Text(
                                                      '00:${state.secondsRemaining.toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                        color: colors.primary,
                                                        fontSize: 13.5,
                                                        fontWeight: FontWeight.w700,
                                                        fontFeatures: const [FontFeature.tabularFigures()],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : AppButtonPressable(
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(999),
                                                  onTap: () {
                                                    HapticFeedback.mediumImpact();
                                                    context.read<OtpCubit>().resend();
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 18,
                                                      vertical: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: colors.primaryContainer.withValues(
                                                        alpha: isDark ? 0.4 : 0.8,
                                                      ),
                                                      borderRadius: AppRadius.pillRadius,
                                                      border: Border.all(
                                                        color: colors.primary.withValues(alpha: 0.3),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.replay_rounded,
                                                          size: 16,
                                                          color: colors.primary,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Kodni qayta yuborish',
                                                          style: TextStyle(
                                                            color: colors.primary,
                                                            fontSize: 13.5,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                  ),

                                  const Spacer(flex: 3),

                                  // Trust & Security Footer
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: colors.surfaceSecondary.withValues(alpha: 0.5),
                                        borderRadius: AppRadius.pillRadius,
                                        border: Border.all(color: colors.borderSubtle),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.shield_outlined,
                                            size: 15,
                                            color: colors.textTertiary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'SMS kod hech kimga berilmasin',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: colors.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.md),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
