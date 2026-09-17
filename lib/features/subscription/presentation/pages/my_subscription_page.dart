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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Joriy tarif',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            info.planDisplayName ?? '',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    AppStatusChip(label: info.statusLabel ?? '', tone: tone),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: colors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (info.periodStart != null && info.periodEnd != null)
                              ? '${info.periodStart} — ${info.periodEnd}'
                              : 'Muddati belgilanmagan',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (info.daysUntilDue != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (info.daysUntilDue! <= 5 ? colors.error : colors.primary).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${info.daysUntilDue} kun qoldi',
                            style: TextStyle(
                              color: info.daysUntilDue! <= 5 ? colors.error : colors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (info.daysUntilDue != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppProgressBar(value: 1 - (info.daysUntilDue!.clamp(0, 30) / 30)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Limitlar va foydalanish',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _usageTile(context, 'Hamkorlar', Icons.people_outline_rounded, info.usage.customers),
          _usageTile(context, 'Loyihalar', Icons.work_outline_rounded, info.usage.projects),
          _usageTile(context, 'Xodimlar', Icons.badge_outlined, info.usage.users),
          _usageTile(context, 'SMS xabarnomalar', Icons.sms_outlined, info.usage.sms),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _usageTile(BuildContext context, String label, IconData icon, UsageLimit limit) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: colors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Text(
                  limit.isUnlimited ? 'Cheksiz' : '${limit.current} / ${limit.max}',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
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
