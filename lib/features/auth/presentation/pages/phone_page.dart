import '../../../../core/widgets/branding/hisup_logo.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../cubit/phone_cubit.dart';

/// Telefon raqam kiritish — Senior Level Modern FinTech Auth ekrani.
class PhonePage extends StatelessWidget {
  const PhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhoneCubit(getIt<AuthRepository>()),
      child: const _PhoneView(),
    );
  }
}

class _PhoneView extends StatefulWidget {
  const _PhoneView();

  @override
  State<_PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<_PhoneView>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _displayController = TextEditingController();
  final _focusNode = FocusNode();

  final _maskFormatter = MaskTextInputFormatter(
    mask: '(##) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _agreed = true;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _displayController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      PhoneFormatter.isValid(_phoneController.text) && _agreed;

  void _onInputChanged(String _) {
    final unmasked = _maskFormatter.getUnmaskedText();
    _phoneController.text = unmasked;
    setState(() {});
  }

  void _clearInput() {
    _displayController.clear();
    _phoneController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<PhoneCubit, PhoneState>(
        listener: (context, state) {
          if (state is PhoneNeedsOtp) {
            context.push(
              RoutePaths.otp,
              extra: {'phone': state.phone, 'mode': 'register'},
            );
          } else if (state is PhoneNeedsLogin) {
            context.push(RoutePaths.login, extra: {'phone': state.phone});
          } else if (state is PhoneError) {
            if (state.failure is BusinessFailure) {
              _showBlockedDialog(context, state.failure.message);
            } else {
              AppSnackbar.error(context, state.failure.message);
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is PhoneLoading;

          return Stack(
            children: [
              // 1. Ambient Background Glows
              Positioned(
                top: -120,
                right: -90,
                child: IgnorePointer(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.primary.withValues(
                            alpha: isDark ? 0.22 : 0.14,
                          ),
                          colors.primary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -80,
                child: IgnorePointer(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.accentViolet.withValues(
                            alpha: isDark ? 0.15 : 0.08,
                          ),
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
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: AppSpacing.lg),

                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: HisupLogo(
                                      markSize: 68,
                                      fontSize: 28,
                                    ),
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
                                            color: colors.primary.withValues(
                                              alpha: 0.18,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              26,
                                            ),
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
                                                colors.primary.withValues(
                                                  alpha: 0.85,
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.primary
                                                    .withValues(
                                                      alpha: isDark
                                                          ? 0.5
                                                          : 0.32,
                                                    ),
                                                blurRadius: 18,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            size: 34,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xl),

                                  // Headline & Subtitle
                                  Text(
                                    'Keling, boshlaymiz! 👋',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.6,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Hisobingizga kirish yoki yangi biznesingizni ulash uchun telefon raqamingizni kiriting.',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 14.5,
                                      height: 1.45,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  const SizedBox(height: AppSpacing.xxl),

                                  // Modern FinTech Phone Input Card
                                  _buildPhoneInputCard(context),

                                  const SizedBox(height: AppSpacing.md),

                                  // Interactive Terms & Conditions Checkbox
                                  _buildTermsRow(context),

                                  const SizedBox(height: AppSpacing.xl),

                                  // Primary Action Button
                                  _buildSubmitButton(context, isLoading),

                                  const Spacer(flex: 3),

                                  // Trust & Security Bottom Badge
                                  _buildSecurityFooter(context),

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

  /// Modern FinTech Phone Input Container with Country Code Badge & Validation Indicator
  Widget _buildPhoneInputCard(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasValidPhone = PhoneFormatter.isValid(_phoneController.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Telefon raqami',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isFocused ? colors.primary : colors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
              if (hasValidPhone)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: colors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'To\'g\'ri format',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.success,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceSecondary.withValues(alpha: 0.65)
                : colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isFocused
                  ? colors.primary
                  : hasValidPhone
                  ? colors.success.withValues(alpha: 0.6)
                  : colors.border.withValues(alpha: 0.95),
              width: _isFocused ? 1.8 : 1.2,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(
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
              // Country Code & Flag Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary.withValues(
                    alpha: isDark ? 0.7 : 0.9,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.borderSubtle, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇺🇿', style: TextStyle(fontSize: 19)),
                    const SizedBox(width: 7),
                    Text(
                      '+998',
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

              const SizedBox(width: 12),

              // Phone Number Input Field
              Expanded(
                child: TextField(
                  controller: _displayController,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [_maskFormatter],
                  onChanged: _onInputChanged,
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: colors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    hintText: '(00) 000-00-00',
                    hintStyle: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.6,
                      color: colors.textTertiary.withValues(alpha: 0.75),
                      fontFeatures: const [FontFeature.tabularFigures()],
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

              // Action / Status Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: hasValidPhone
                    ? Container(
                        key: const ValueKey('valid_badge'),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: colors.success,
                        ),
                      )
                    : _displayController.text.isNotEmpty
                    ? InkWell(
                        key: const ValueKey('clear_btn'),
                        onTap: _clearInput,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 20,
                            color: colors.textTertiary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_space')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Modern Interactive Terms & Agreement Checkbox with RichText links
  Widget _buildTermsRow(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Sleek Checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _agreed = !_agreed);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 2, right: 10),
              decoration: BoxDecoration(
                color: _agreed ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: _agreed
                      ? colors.primary
                      : colors.textTertiary.withValues(alpha: 0.6),
                  width: 1.8,
                ),
                boxShadow: _agreed
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: _agreed
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,
            ),
          ),

          // RichText with Legal Links
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _agreed = !_agreed),
              child: Text.rich(
                TextSpan(
                  text: 'Men ',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => _showTermsModal(
                          context,
                          'Foydalanish shartlari',
                          'Hisup platformasidan foydalanish orqali siz barcha moliyaviy amaliyotlar shaffofligi, xavfsizlik talablari hamda xizmat ko\'rsatish qoidalariga rozilik bildirasiz.',
                        ),
                        child: Text(
                          'Foydalanish shartlari',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.primary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: ' va '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => _showTermsModal(
                          context,
                          'Maxfiylik siyosati',
                          'Sizning shaxsiy ma\'lumotlaringiz va moliyaviy hisobotlaringiz 256-bitli SSL xavfsizlik protokollari bilan qat\'iy himoyalangan bo\'lib, uchinchi shaxslarga berilmaydi.',
                        ),
                        child: Text(
                          'Maxfiylik siyosati',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.primary.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: 'ga to\'liq roziman'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// High-End CTA Button with tactile feedback & arrow icon
  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    final colors = context.colors;
    final enabled = _canContinue && !isLoading;

    return AppButtonPressable(
      enabled: enabled,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 54,
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    colors.primary,
                    colors.primary.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : colors.disabled.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
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
            onTap: enabled
                ? () {
                    HapticFeedback.mediumImpact();
                    context.read<PhoneCubit>().submit(_phoneController.text);
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
                            'Davom etish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: enabled
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 19,
                            color: enabled
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
    );
  }

  /// Trust & Security Badge at the footer
  Widget _buildSecurityFooter(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary.withValues(alpha: 0.5),
          borderRadius: AppRadius.pillRadius,
          border: Border.all(color: colors.borderSubtle, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 15, color: colors.textTertiary),
            const SizedBox(width: 6),
            Text(
              '256-bit shifrlangan • Ma\'lumotlar to\'liq xavfsiz',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: colors.textTertiary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Informative Bottom Sheet for Terms & Privacy
  void _showTermsModal(BuildContext context, String title, String content) {
    final colors = context.colors;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        color: colors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  label: 'Tushundim',
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Premium Redesigned Blocked Dialog
  void _showBlockedDialog(BuildContext context, String message) {
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colors.surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_person_rounded,
                  color: colors.error,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kirish cheklangan',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                label: 'Tushundim',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
