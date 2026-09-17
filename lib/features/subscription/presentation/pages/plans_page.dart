import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/subscription_models.dart';
import '../../data/subscription_repository.dart';
import '../widgets/payment_flow_sheet.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(plan.displayName, style: Theme.of(context).textTheme.titleLarge),
                if (plan.currentlySubscribed)
                  Text('Joriy tarifingiz', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
            if (price != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(price.formatted, style: Theme.of(context).textTheme.headlineSmall),
                  if (price.discount != null && price.discount! > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: colors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('-${price.discount}%', style: TextStyle(color: colors.error, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ],
              ),
              if (price.description != null && price.description!.isNotEmpty)
                Text(price.description!, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: 4,
              children: [
                Text('${plan.maxCustomers == -1 ? 'Cheksiz' : plan.maxCustomers} Hamkor'),
                Text('${plan.maxProjects == -1 ? 'Cheksiz' : plan.maxProjects} Loyiha'),
                Text('${plan.maxUsers == -1 ? 'Cheksiz' : plan.maxUsers} Xodim'),
                Text('${plan.smsPerMonth} SMS'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (!plan.canSubscribe) ...[
              for (final warning in plan.downgradeWarnings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(warning, style: TextStyle(color: colors.error, fontSize: 12)),
                ),
            ],
            AppButton.primary(
              label: plan.currentlySubscribed ? 'Joriy tarif' : 'Tanlash',
              onPressed: plan.canSubscribe && !plan.currentlySubscribed ? () => _selectPlan(context, plan) : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectPlan(BuildContext context, PricingPlan plan) async {
    final provider = await showAppBottomSheet<String>(
      context,
      title: 'To\'lov usuli',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Payme'), onTap: () => Navigator.of(context).pop('payme')),
          ListTile(title: const Text('Click'), onTap: () => Navigator.of(context).pop('click')),
        ],
      ),
    );
    if (provider == null || !context.mounted) return;

    final success = await showPaymentFlowSheet(
      context,
      createOrder: () => getIt<SubscriptionRepository>().purchase(
        planId: plan.id,
        billingCycle: _cycle,
        paymentProvider: provider,
        returnUrl: 'ehisob://payment-result',
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
