import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../subscription/data/subscription_models.dart';
import '../../../subscription/data/subscription_repository.dart';

class ProfileSubscriptionCard extends StatefulWidget {
  const ProfileSubscriptionCard({
    super.key,
    required this.showDetails,
    required this.showLimits,
    this.ownerId,
  });
  final int? ownerId;
  final bool showDetails;
  final bool showLimits;

  @override
  State<ProfileSubscriptionCard> createState() =>
      ProfileSubscriptionCardState();
}

class ProfileSubscriptionCardState extends State<ProfileSubscriptionCard> {
  SubscriptionInfo? _info;
  String? _error;
  bool _expanded = false;
  int _request = 0;

  Future<void> refresh() => _load();

  @override
  void didUpdateWidget(covariant ProfileSubscriptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _error = null;
      _info = null;
    });
    final result = await getIt<SubscriptionRepository>().getSubscription();
    if (!mounted || request != _request) return;
    result.when(
      success: (info) => setState(() => _info = info),
      failure: (error) => setState(() => _error = error.message),
    );
  }

  Future<void> _openPlans() async {
    await context.push(RoutePaths.profileSubscription);
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final info = _info;
    if (_error != null) {
      return AppCard(
        hasShadow: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tarif ma’lumotlarini yuklab bo‘lmadi',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            IconButton(
              tooltip: 'Qayta urinish',
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      );
    }
    if (info == null) {
      return Column(
        children: [
          AppCard(
            hasShadow: false,
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    AppSkeletonBox(
                      width: 44,
                      height: 44,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeletonBox(width: 74, height: 10),
                          SizedBox(height: 8),
                          AppSkeletonBox(width: 130, height: 22),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    AppSkeletonBox(width: 21, height: 21),
                  ],
                ),
                if (widget.showDetails) ...[
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      AppSkeletonBox(width: 50, height: 24),
                      SizedBox(width: 8),
                      AppSkeletonBox(width: 86, height: 24),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const FractionallySizedBox(
                    widthFactor: .8,
                    child: AppSkeletonBox(height: 12),
                  ),
                ],
              ],
            ),
          ),
          if (widget.showLimits) ...[
            const SizedBox(height: 10),
            const AppSkeletonBox(
              height: 52,
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ],
        ],
      );
    }
    final date = AppDateFormatter.parseFromBackend(info.periodEnd);
    return Column(
      children: [
        AppCard(
          hasShadow: false,
          onTap: _openPlans,
          padding: const EdgeInsets.all(18),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.primary.withValues(alpha: .2)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              Color.lerp(colors.primary, colors.accentViolet, .5)!,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JORIY TARIF',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .75),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          info.hasSubscription
                              ? (info.planDisplayName ??
                                    info.planName ??
                                    'Obuna')
                              : 'Obuna mavjud emas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ],
              ),
              if (widget.showDetails) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (info.statusLabel?.isNotEmpty ?? false)
                      _Tag(text: info.statusLabel!),
                    if (info.isOverdue)
                      const _Tag(text: 'To‘lov muddati o‘tgan')
                    else if (info.daysUntilDue != null)
                      _Tag(
                        text:
                            '${info.daysUntilDue! < 0 ? 0 : info.daysUntilDue} kun qoldi',
                      ),
                  ],
                ),
                if (info.periodEnd != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Amal qilish muddati: ${date == null ? info.periodEnd : AppDateFormatter.display(date)}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        if (widget.showLimits && info.hasSubscription) ...[
          const SizedBox(height: 10),
          AppCard(
            hasShadow: false,
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: ListTile(
                    dense: true,
                    title: const Text('Limitlar va foydalanish'),
                    leading: Icon(
                      Icons.donut_small_rounded,
                      color: colors.primary,
                      size: 21,
                    ),
                    trailing: Icon(
                      _expanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                    onTap: () => setState(() => _expanded = !_expanded),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: !_expanded
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              for (final (label, limit, color) in [
                                (
                                  'Mijozlar',
                                  info.usage.customers,
                                  colors.primary,
                                ),
                                (
                                  'Loyihalar',
                                  info.usage.projects,
                                  colors.success,
                                ),
                                (
                                  'Xodimlar',
                                  info.usage.users,
                                  colors.accentViolet,
                                ),
                                ('SMS', info.usage.sms, colors.warning),
                              ])
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              label,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ),
                                          Text(
                                            '${limit.current} / ${limit.isUnlimited ? 'Cheksiz' : limit.max}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      LinearProgressIndicator(
                                        value: limit.percentage,
                                        minHeight: 5,
                                        borderRadius: BorderRadius.circular(4),
                                        color: color,
                                        backgroundColor: color.withValues(
                                          alpha: .1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
