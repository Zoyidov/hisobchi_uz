import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/subscription_models.dart';
import '../../data/subscription_repository.dart';
import '../widgets/payment_flow_sheet.dart';
import '../widgets/payment_provider_sheet.dart';

/// Tariflar (MOBILE_APP_TZ.md 13.3).
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  List<PricingPlan>? _plans;
  String? _error;
  var _cycle = BillingCycle.monthly;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _plans = null;
      _error = null;
    });
    final result = await getIt<SubscriptionRepository>().getPricingPlans();
    if (!mounted) return;
    result.when(success: (plans) => setState(() => _plans = plans), failure: (f) => setState(() => _error = f.message));
  }

  PriceOption? _priceFor(PricingPlan plan) => switch (_cycle) {
        BillingCycle.monthly => plan.monthly,
        BillingCycle.semiAnnual => plan.semiAnnual,
        BillingCycle.annual => plan.annual,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tariflar')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    if (_plans == null) return const AppSkeletonList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppSegmentedControl<BillingCycle>(
          value: _cycle,
          segments: BillingCycle.values.map((c) => AppSegment(value: c, label: c.label)).toList(),
          onChanged: (v) => setState(() => _cycle = v),
        ),
        const SizedBox(height: AppSpacing.lg),
        for (final plan in _plans!) _planCard(context, plan),
      ],
    );
  }

  Widget _planCard(BuildContext context, PricingPlan plan) {
    final colors = context.colors;
    final price = _priceFor(plan);
    final isCurrent = plan.currentlySubscribed;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      if (plan.description != null && plan.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          plan.description!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: colors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Joriy tarifingiz',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (price != null) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price.formatted,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                  if (price.discount != null && price.discount! > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${price.discount}%',
                        style: TextStyle(
                          color: colors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                  if (price.description1 != null && price.description1!.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        price.description1!,
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (price.description != null && price.description!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  price.description!,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ],
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                _featureChip(context, Icons.people_outline_rounded, '${plan.customersLabel} Hamkor'),
                _featureChip(context, Icons.work_outline_rounded, '${plan.projectsLabel} Loyiha'),
                _featureChip(context, Icons.badge_outlined, '${plan.usersLabel} Xodim'),
                _featureChip(context, Icons.sms_outlined, '${plan.smsLabel} SMS'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!plan.canSubscribe) ...[
              for (final warning in plan.downgradeWarnings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: colors.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          warning,
                          style: TextStyle(color: colors.error, fontSize: 12, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
            ],
            AppButton.primary(
              label: isCurrent ? 'Joriy tarif' : 'Tanlash',
              onPressed: plan.canSubscribe && !isCurrent ? () => _selectPlan(context, plan) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(BuildContext context, IconData icon, String label) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPlan(BuildContext context, PricingPlan plan) async {
    final priceOpt = _priceFor(plan);
    final cycleLabel = switch (_cycle) {
      BillingCycle.monthly => 'Oylik obuna',
      BillingCycle.semiAnnual => '6 oylik obuna',
      BillingCycle.annual => 'Yillik obuna',
    };

    final provider = await showPaymentProviderSheet(
      context,
      itemTitle: '${plan.displayName} tarifi',
      formattedPrice: priceOpt?.formatted ?? '',
      itemSubtitle: cycleLabel,
    );
    if (provider == null || !context.mounted) return;

    final success = await showPaymentFlowSheet(
      context,
      createOrder: () => getIt<SubscriptionRepository>().purchase(
        planId: plan.id,
        billingCycle: _cycle,
        paymentProvider: provider,
        returnUrl: '',
      ),
      checkStatus: (orderNumber) => getIt<SubscriptionRepository>().checkOrderStatus(orderNumber),
    );
    if (!context.mounted) return;
    if (success) {
      AppSnackbar.success(context, 'Obuna faollashtirildi');
      _load();
    }
  }
}
