import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/branding/hisup_logo.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../auth_navigation.dart';
import '../cubit/login_cubit.dart';

/// Parol bilan kirish — Senior Level FinTech Login ekrani.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(getIt<AuthRepository>(), getIt<DeviceInfoService>()),
      child: _LoginView(phone: phone),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView({required this.phone});
  final String phone;

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscure = true;
  bool _isFocused = false;

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

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            HapticFeedback.mediumImpact();
            AuthNavigation.completeAuthAndOfferPincode(context, state.token);
          } else if (state is LoginFailed) {
            HapticFeedback.heavyImpact();
            AppSnackbar.error(context, state.failure.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginSubmitting;
          final canSubmit = _passwordController.text.isNotEmpty && !isLoading;

          return Stack(
            children: [
              // 1. Ambient Background Glows
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
                                          'AUTENTIFIKATSIYA',
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

                                  const Center(
                                    child: HisupLogo(
                                      markSize: 104,
                                      fontSize: 36,
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xxl),

                                  // Headings
                                  Text(
                                    'Hisobga kirish 👋',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          fontSize: 27,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Davom etish uchun maxfiy parolingizni kiriting.',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 14.5,
                                      height: 1.45,
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.lg),

                                  // Phone Number Card
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.surfaceSecondary.withValues(
                                        alpha: isDark ? 0.6 : 0.8,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colors.borderSubtle,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: colors.primaryContainer.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.phone_iphone_rounded,
                                            size: 20,
                                            color: colors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Telefon raqamingiz',
                                                style: TextStyle(
                                                  color: colors.textTertiary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                PhoneFormatter.toDisplay(widget.phone),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: colors.textPrimary,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () => context.pop(),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
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

                                  const SizedBox(height: AppSpacing.xl),

                                  // Password Input Card
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                                        child: Text(
                                          'Parol',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _isFocused ? colors.primary : colors.textSecondary,
                                            letterSpacing: 0.1,
                                          ),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 220),
                                        curve: Curves.easeInOut,
                                        padding: const EdgeInsets.symmetric(horizontal: 14),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? colors.surfaceSecondary.withValues(alpha: 0.65)
                                              : colors.surface,
                                          borderRadius: BorderRadius.circular(18),
                                          border: Border.all(
                                            color: _isFocused
                                                ? colors.primary
                                                : colors.border.withValues(alpha: 0.95),
                                            width: _isFocused ? 1.8 : 1.2,
                                          ),
                                          boxShadow: _isFocused
                                              ? [
                                                  BoxShadow(
                                                    color: colors.primary.withValues(alpha: isDark ? 0.3 : 0.14),
                                                    blurRadius: 14,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : colors.cardShadow,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.lock_outline_rounded,
                                              size: 20,
                                              color: _isFocused ? colors.primary : colors.textTertiary,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: TextField(
                                                controller: _passwordController,
                                                focusNode: _focusNode,
                                                onTapOutside: (_) => _focusNode.unfocus(),
                                                autofocus: true,
                                                obscureText: _obscure,
                                                onChanged: (_) => setState(() {}),
                                                onSubmitted: canSubmit
                                                    ? (_) {
                                                        context.read<LoginCubit>().submit(
                                                              phone: widget.phone,
                                                              password: _passwordController.text,
                                                            );
                                                      }
                                                    : null,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: colors.textPrimary,
                                                ),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                                  hintText: 'Parolni kiriting',
                                                  hintStyle: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w400,
                                                    color: colors.textTertiary.withValues(alpha: 0.8),
                                                  ),
                                                  filled: false,
                                                  border: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  focusedErrorBorder: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                _obscure
                                                    ? Icons.visibility_off_rounded
                                                    : Icons.visibility_rounded,
                                                size: 20,
                                                color: colors.textTertiary,
                                              ),
                                              onPressed: () => setState(() => _obscure = !_obscure),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: AppSpacing.sm),

                                  // Forgot Password Link
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: InkWell(
                                      onTap: () => context.push(
                                        RoutePaths.forgotPassword,
                                        extra: {'phone': widget.phone},
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 6,
                                        ),
                                        child: Text(
                                          'Parolni unutdingizmi?',
                                          style: TextStyle(
                                            color: colors.primary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.lg),

                                  // CTA Submit Button
                                  AppButtonPressable(
                                    enabled: canSubmit,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 220),
                                      height: 54,
                                      decoration: BoxDecoration(
                                        gradient: canSubmit
                                            ? LinearGradient(
                                                colors: [
                                                  colors.primary,
                                                  colors.primary.withValues(alpha: 0.9),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        color: canSubmit
                                            ? null
                                            : colors.disabled.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: canSubmit
                                            ? [
                                                BoxShadow(
                                                  color: colors.primary.withValues(alpha: 0.38),
                                                  blurRadius: 18,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: canSubmit
                                              ? () {
                                                  HapticFeedback.mediumImpact();
                                                  context.read<LoginCubit>().submit(
                                                        phone: widget.phone,
                                                        password: _passwordController.text,
                                                      );
                                                }
                                              : null,
                                          child: Center(
                                            child: AnimatedSwitcher(
                                              duration: const Duration(milliseconds: 200),
                                              child: isLoading
                                                  ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.4,
                                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          'Kirish',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w700,
                                                            color: canSubmit
                                                                ? Colors.white
                                                                : Colors.white.withValues(alpha: 0.6),
                                                            letterSpacing: 0.2,
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Icon(
                                                          Icons.arrow_forward_rounded,
                                                          size: 19,
                                                          color: canSubmit
                                                              ? Colors.white
                                                              : Colors.white.withValues(alpha: 0.6),
                                                        ),
                                                      ],
                                                    ),
                                            ),
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
                                            '256-bit shifrlangan • Barcha ma\'lumotlar xavfsiz',
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
