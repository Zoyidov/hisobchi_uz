import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/subscription_models.dart';
import '../../data/subscription_repository.dart';
import '../widgets/payment_flow_sheet.dart';
import '../widgets/payment_provider_sheet.dart';

/// SMS paketlari (MOBILE_APP_TZ.md 13.5).
class SmsPackagesPage extends StatefulWidget {
  const SmsPackagesPage({super.key});

  @override
  State<SmsPackagesPage> createState() => _SmsPackagesPageState();
}

class _SmsPackagesPageState extends State<SmsPackagesPage> {
  List<SmsPackage>? _packages;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _packages = null;
      _error = null;
    });
    final result = await getIt<SubscriptionRepository>().getSmsPackages();
    if (!mounted) return;
    result.when(
      success: (list) => setState(() => _packages = list),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS paketlari'),
        elevation: 0,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _load,
      );
    }
    if (_packages == null) return const AppSkeletonList();

    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: _load,
      color: colors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        children: [
          // Info banner at top
          _buildInfoBanner(context),
          const SizedBox(height: AppSpacing.lg),

          // Packages
          for (final pkg in _packages!) ...[
            _SmsPackageCard(
              package: pkg,
              onPurchase: () => _purchase(context, pkg),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.mark_chat_unread_rounded,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMS xabarnomalar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mijozlaringizga hisob-kitoblar, qarz va to\'lovlar haqida SMS orqali tezkor eslatmalar yuboring.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchase(BuildContext context, SmsPackage package) async {
    final title = package.displayName.isNotEmpty
        ? package.displayName
        : 'SMS ${package.countLabel}';

    final provider = await showPaymentProviderSheet(
      context,
      itemTitle: title,
      formattedPrice: package.formattedPrice,
      itemSubtitle: '${package.countLabel} ta SMS xabarnoma to\'plami',
    );
    if (provider == null || !context.mounted) return;

    final success = await showPaymentFlowSheet(
      context,
      createOrder: () => getIt<SubscriptionRepository>().purchaseSms(
        packageId: package.id,
        paymentProvider: provider,
        returnUrl: 'ehisob://payment-result',
      ),
      checkStatus: (orderNumber) =>
          getIt<SubscriptionRepository>().checkOrderStatus(orderNumber),
    );
    if (!context.mounted) return;
    if (success) {
      AppSnackbar.success(context, 'SMS paketi muvaffaqiyatli qo\'shildi');
      _load();
    }
  }
}

class _SmsPackageCard extends StatelessWidget {
  const _SmsPackageCard({
    required this.package,
    required this.onPurchase,
  });

  final SmsPackage package;
  final VoidCallback onPurchase;

  bool get _isPopular =>
      (package.name?.contains('50') ?? false) || package.smsCount == 50;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final perSmsPrice = package.smsCount > 0
        ? (package.price / package.smsCount).round()
        : null;

    final title = package.displayName.isNotEmpty
        ? package.displayName
        : 'SMS ${package.countLabel}';

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isPopular
              ? colors.primary
              : colors.border.withValues(alpha: 0.8),
          width: _isPopular ? 1.8 : 1.0,
        ),
        boxShadow: _isPopular
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : colors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Popular badge banner if applicable
            if (_isPopular)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary,
                      colors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ENG OMMABOP PAKET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top info row
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isPopular
                              ? colors.primary.withValues(alpha: 0.12)
                              : colors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.sms_rounded,
                          color: _isPopular ? colors.primary : colors.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${package.countLabel} ta',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (package.description != null &&
                                package.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                package.description!,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: colors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),
                  Divider(
                    color: colors.border.withValues(alpha: 0.6),
                    height: 1,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Bottom pricing and CTA row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              package.formattedPrice,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (perSmsPrice != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '1 ta SMS ≈ $perSmsPrice so\'m',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textTertiary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      AppButton.primary(
                        label: 'Sotib olish',
                        size: AppButtonSize.medium,
                        expand: false,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: onPurchase,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
