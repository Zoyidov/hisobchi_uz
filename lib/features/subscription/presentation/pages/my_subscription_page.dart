import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/chips/app_status_chip.dart';
import '../../../../core/widgets/misc/app_progress_bar.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/subscription_models.dart';
import '../../data/subscription_repository.dart';

/// Mening obunam (MOBILE_APP_TZ.md 13.2).
class MySubscriptionPage extends StatefulWidget {
  const MySubscriptionPage({super.key});

  @override
  State<MySubscriptionPage> createState() => _MySubscriptionPageState();
}

class _MySubscriptionPageState extends State<MySubscriptionPage> {
  SubscriptionInfo? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _info = null;
      _error = null;
    });
    final result = await getIt<SubscriptionRepository>().getSubscription();
    if (!mounted) return;
    result.when(
      success: (info) => setState(() => _info = info),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obuna va tariflar')),
      body: _buildBody(context),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: AppButton.primary(
          label: 'Tariflarni ko\'rish',
          onPressed: () => context.push(RoutePaths.subscriptionPlans),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    final info = _info;
    if (info == null) return const AppSkeletonList();
    if (!info.hasSubscription) {
      return const Center(child: Text('Faol obuna topilmadi'));
    }

    final colors = context.colors;
    final tone = switch (info.status) {
      'ACTIVE' => AppStatusChipTone.success,
      'GRACE_PERIOD' => AppStatusChipTone.warning,
      _ => AppStatusChipTone.error,
    };

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(info.planDisplayName ?? '', style: Theme.of(context).textTheme.titleLarge),
                    AppStatusChip(label: info.statusLabel ?? '', tone: tone),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (info.periodStart != null && info.periodEnd != null)
                  Text('${info.periodStart} — ${info.periodEnd}', style: TextStyle(color: colors.textSecondary)),
                if (info.daysUntilDue != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text('${info.daysUntilDue} kun qoldi'),
                  const SizedBox(height: 4),
                  AppProgressBar(value: 1 - (info.daysUntilDue!.clamp(0, 30) / 30)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _usageTile(context, 'Hamkorlar', info.usage.customers),
          _usageTile(context, 'Loyihalar', info.usage.projects),
          _usageTile(context, 'Xodimlar', info.usage.users),
          _usageTile(context, 'SMS', info.usage.sms),
        ],
      ),
    );
  }

  Widget _usageTile(BuildContext context, String label, UsageLimit limit) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                Text(
                  limit.isUnlimited ? 'Cheksiz' : '${limit.current} / ${limit.max}',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
            if (!limit.isUnlimited) ...[
              const SizedBox(height: AppSpacing.sm),
              AppProgressBar(value: limit.percentage),
            ],
          ],
        ),
      ),
    );
  }
}
