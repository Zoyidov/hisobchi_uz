import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../auth_navigation.dart';
import '../cubit/register_cubit.dart';

/// Ro'yxatdan o'tish — Senior Level FinTech Registration ekrani.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key, required this.phone, required this.verifyToken});

  final String phone;
  final String verifyToken;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterCubit(getIt<AuthRepository>(), getIt<DeviceInfoService>()),
      child: _RegisterView(phone: phone, verifyToken: verifyToken),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView({required this.phone, required this.verifyToken});
  final String phone;
  final String verifyToken;

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  Map<String, String> _fieldErrors = {};

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

    _nameFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
    _confirmFocusNode.addListener(() => setState(() {}));

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit() {
    final nameError = Validators.required(_nameController.text);
    final passwordError = Validators.password(_passwordController.text);
    final confirmError = Validators.passwordConfirm(
      _confirmController.text,
      _passwordController.text,
    );

    setState(() {
      _fieldErrors = {
        if (nameError != null) 'name': nameError,
        if (passwordError != null) 'password': passwordError,
        if (confirmError != null) 'confirm': confirmError,
      };
    });

    if (_fieldErrors.isNotEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    context.read<RegisterCubit>().submit(
          name: _nameController.text.trim(),
          phone: widget.phone,
          password: _passwordController.text,
          verifyToken: widget.verifyToken,
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            HapticFeedback.mediumImpact();
            AuthNavigation.completeAuthAndOfferPincode(context, state.token);
          } else if (state is RegisterValidationError) {
            HapticFeedback.heavyImpact();
            setState(() => _fieldErrors = state.fieldErrors);
          } else if (state is RegisterFailed) {
            HapticFeedback.heavyImpact();
            AppSnackbar.error(context, state.failure.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterSubmitting;

          return Stack(
            children: [
              // 1. Ambient Glow Mesh
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

              // 2. Main Scrollable Content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                                  'YANGI PROFIL',
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

                          const SizedBox(height: AppSpacing.xl),

                          // Hero Icon
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
                                    Icons.person_add_rounded,
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
                            'Ro\'yxatdan o\'tish ✨',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hisobchi.uz biznes tizimida shaxsiy profilingizni shakllantiring.',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14.5,
                              height: 1.45,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Verified Phone Badge
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.surfaceSecondary.withValues(
                                  alpha: isDark ? 0.6 : 0.8,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: colors.borderSubtle),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 16, color: colors.success),
                                  const SizedBox(width: 8),
                                  Text(
                                    PhoneFormatter.toDisplay(widget.phone),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: colors.textPrimary,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xl),

                          // 1. Full Name Input Field
                          _buildModernInputField(
                            context: context,
                            label: 'To\'liq ismingiz',
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            icon: Icons.person_outline_rounded,
                            hintText: 'Masalan: Alisher Usmonov',
                            textCapitalization: TextCapitalization.words,
                            errorText: _fieldErrors['name'],
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // 2. Password Input Field
                          _buildModernInputField(
                            context: context,
                            label: 'Yangi parol',
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            icon: Icons.lock_outline_rounded,
                            hintText: 'Kamida 6 ta belgi',
                            obscureText: _obscurePassword,
                            errorText: _fieldErrors['password'],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: colors.textTertiary,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // 3. Confirm Password Input Field
                          _buildModernInputField(
                            context: context,
                            label: 'Parolni tasdiqlang',
                            controller: _confirmController,
                            focusNode: _confirmFocusNode,
                            icon: Icons.lock_reset_rounded,
                            hintText: 'Parolni qayta kiriting',
                            obscureText: _obscureConfirm,
                            errorText: _fieldErrors['confirm'],
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                size: 20,
                                color: colors.textTertiary,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Submit Action Button
                          AppButtonPressable(
                            enabled: !isLoading,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colors.primary,
                                    colors.primary.withValues(alpha: 0.9),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(alpha: 0.38),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: isLoading ? null : _submit,
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
                                              children: const [
                                                Text(
                                                  'Ro\'yxatdan o\'tish',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 19,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Trust Footer
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
                                  Icon(Icons.shield_outlined, size: 15, color: colors.textTertiary),
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

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernInputField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String hintText,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? errorText,
    Widget? suffixIcon,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFocused = focusNode.hasFocus;
    final hasError = errorText != null && errorText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: hasError
                  ? colors.error
                  : isFocused
                      ? colors.primary
                      : colors.textSecondary,
              letterSpacing: 0.1,
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? colors.surfaceSecondary.withValues(alpha: 0.65) : colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasError
                  ? colors.error
                  : isFocused
                      ? colors.primary
                      : colors.border.withValues(alpha: 0.95),
              width: isFocused || hasError ? 1.8 : 1.2,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: (hasError ? colors.error : colors.primary).withValues(
                        alpha: isDark ? 0.3 : 0.14,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : colors.cardShadow,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: hasError
                    ? colors.error
                    : isFocused
                        ? colors.primary
                        : colors.textTertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  obscureText: obscureText,
                  textCapitalization: textCapitalization,
                  onChanged: (_) {
                    if (hasError) {
                      setState(() {
                        _fieldErrors.remove(label);
                      });
                    }
                  },
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 14.5,
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
              if (suffixIcon != null) suffixIcon,
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 6),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, size: 14, color: colors.error),
                const SizedBox(width: 5),
                Text(
                  errorText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
