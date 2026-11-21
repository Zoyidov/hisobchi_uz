import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/partner_installment_report_models.dart';
import '../../data/reports_repository.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/localization/app_localization_extension.dart';

class PartnerInstallmentReportTab extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final String partnerPhone;

  const PartnerInstallmentReportTab({
    super.key,
    required this.partnerId,
    required this.partnerName,
    required this.partnerPhone,
  });

  @override
  State<PartnerInstallmentReportTab> createState() =>
      _PartnerInstallmentReportTabState();
}

class _PartnerInstallmentReportTabState
    extends State<PartnerInstallmentReportTab>
    with SingleTickerProviderStateMixin {
  late TabController _currencyTabController;
  PartnerInstallmentReportModel? _reportUzs;
  PartnerInstallmentReportModel? _reportUsd;
  bool _isLoadingUzs = true;
  bool _isLoadingUsd = false;
  String? _errorUzs;
  String? _errorUsd;

  String _selectedItemFilter = 'all'; // all, overdue, pending, paid

  @override
  void initState() {
    super.initState();
    _currencyTabController = TabController(length: 2, vsync: this);
    _currencyTabController.addListener(() {
      if (!_currencyTabController.indexIsChanging) {
        setState(() {});
        if (_currencyTabController.index == 1 &&
            _reportUsd == null &&
            !_isLoadingUsd) {
          _loadUsd();
        }
      }
    });
    _loadUzs();
  }

  @override
  void dispose() {
    _currencyTabController.dispose();
    super.dispose();
  }

  Future<void> _loadUzs() async {
    setState(() {
      _isLoadingUzs = true;
      _errorUzs = null;
    });
    final result = await getIt<ReportsRepository>().getPartnerInstallmentReport(
      widget.partnerId,
      currencyTypeId: 1,
    );
    if (!mounted) return;
    result.when(
      success: (data) => setState(() {
        _reportUzs = data;
        _isLoadingUzs = false;
      }),
      failure: (f) => setState(() {
        _errorUzs = f.message;
        _isLoadingUzs = false;
      }),
    );
  }

  Future<void> _loadUsd() async {
    setState(() {
      _isLoadingUsd = true;
      _errorUsd = null;
    });
    final result = await getIt<ReportsRepository>().getPartnerInstallmentReport(
      widget.partnerId,
      currencyTypeId: 2,
    );
    if (!mounted) return;
    result.when(
      success: (data) => setState(() {
        _reportUsd = data;
        _isLoadingUsd = false;
      }),
      failure: (f) => setState(() {
        _errorUsd = f.message;
        _isLoadingUsd = false;
      }),
    );
  }

  String _formatPrice(String raw) {
    final value = double.tryParse(raw) ?? 0.0;
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // Currency Selector Header
        Container(
          color: colors.surface,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                _buildCurrencyTabItem(context.l10n.reportAccountUzs, 0),
                Container(width: 1, height: 20, color: colors.border),
                _buildCurrencyTabItem(context.l10n.reportAccountUsd, 1),
              ],
            ),
          ),
        ),

        // Body
        Expanded(
          child: TabBarView(
            controller: _currencyTabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildCurrencyBody(
                currencyLabel: 'UZS',
                isLoading: _isLoadingUzs,
                error: _errorUzs,
                report: _reportUzs,
                onRefresh: _loadUzs,
              ),
              _buildCurrencyBody(
                currencyLabel: 'USD',
                isLoading: _isLoadingUsd,
                error: _errorUsd,
                report: _reportUsd,
                onRefresh: _loadUsd,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyTabItem(String label, int index) {
    final colors = context.colors;
    final isSelected = _currencyTabController.index == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _currencyTabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.small),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyBody({
    required String currencyLabel,
    required bool isLoading,
    required String? error,
    required PartnerInstallmentReportModel? report,
    required Future<void> Function() onRefresh,
  }) {
    if (isLoading) {
      return const AppSkeletonList();
    }

    if (error != null) {
      return AppErrorState(
        title: context.l10n.errorLoadShort,
        description: error,
        onRetry: onRefresh,
      );
    }

    if (report == null) {
      return const SizedBox.shrink();
    }

    final stat = report.stats.isNotEmpty ? report.stats.first : null;
    final plans = report.plans;
    final payments = report.payments;
    final items = report.items;

    // Filter items
    final filteredItems = items.where((item) {
      if (_selectedItemFilter == 'all') return true;
      if (_selectedItemFilter == 'overdue') return item.status == 'overdue';
      if (_selectedItemFilter == 'pending') {
        return item.status == 'pending' || item.status == 'near';
      }
      if (_selectedItemFilter == 'paid') {
        return item.status == 'paid' || item.status == 'partial';
      }
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // 1. STATS SECTION
          if (stat != null) ...[
            _buildStatsSection(stat, currencyLabel),
            const SizedBox(height: 14),
          ],

          // 2. PLANS SECTION
          _buildPlansSection(plans, currencyLabel),
          const SizedBox(height: 14),

          // 3. PAYMENTS HISTORY SECTION
          if (payments.isNotEmpty) ...[
            _buildPaymentsSection(payments, currencyLabel),
            const SizedBox(height: 14),
          ],

          // 4. SCHEDULE ITEMS SECTION
          if (items.isNotEmpty) ...[
            _buildScheduleItemsSection(filteredItems, currencyLabel),
            const SizedBox(height: 14),
          ],

          // 5. MONTHLY DYNAMICS
          if (report.monthlyDynamics.isNotEmpty) ...[
            _buildMonthlyDynamicsSection(report.monthlyDynamics, currencyLabel),
          ],
        ],
      ),
    );
  }

  // ---------------- 1. STATS ----------------
  Widget _buildStatsSection(
    PartnerInstallmentStatModel stat,
    String currencyLabel,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  AppIcons.dashboard,
                  size: 16,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.reportOverallStats,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Plan Counts: Faol / Tugallangan / Bekor
          Row(
            children: [
              Expanded(
                child: _buildMetricChip(
                  label: context.l10n.installmentStatusActive,
                  value: '${stat.activePlans}',
                  color: colors.primary,
                  icon: AppIcons.playCircle,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildMetricChip(
                  label: context.l10n.dashboardCompleted,
                  value: '${stat.completedPlans}',
                  color: context.colors.success,
                  icon: AppIcons.success,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _buildMetricChip(
                  label: context.l10n.reportCancelledShort,
                  value: '${stat.cancelledPlans}',
                  color: context.colors.textTertiary,
                  icon: AppIcons.cancel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Berilgan / To'langan
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  label: context.l10n.reportGiven,
                  amount: '${_formatPrice(stat.totalGiven)} $currencyLabel',
                  color: context.colors.accentIndigo,
                  icon: AppIcons.wallet,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAmountCard(
                  label: context.l10n.commonPaid,
                  amount: '${_formatPrice(stat.totalPaid)} $currencyLabel',
                  color: context.colors.success,
                  icon: AppIcons.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Qolgan (Wide card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: context.colors.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      AppIcons.hourglass,
                      color: context.colors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.commonRemaining,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.onWarningContainer,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_formatPrice(stat.totalRemaining)} $currencyLabel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: context.colors.onWarningContainer,
                  ),
                ),
              ],
            ),
          ),

          // Overdue Banner
          if (stat.hasOverdue) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: context.colors.error.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.error, color: context.colors.error, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      context.l10n.reportOverdueAmount(
                        _formatPrice(stat.overdueAmount),
                        currencyLabel,
                      ),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: context.colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard({
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ---------------- 2. PLANS ----------------
  Widget _buildPlansSection(
    List<PartnerInstallmentPlanModel> plans,
    String currencyLabel,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: colors.accentViolet.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  AppIcons.calendar,
                  size: 16,
                  color: colors.accentViolet,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  context.l10n.reportInstallmentPlans,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (plans.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${plans.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.accentViolet,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  context.l10n.reportNoPlans,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ...plans.map((plan) => _buildPlanItem(plan, currencyLabel)),
        ],
      ),
    );
  }

  Widget _buildPlanItem(
    PartnerInstallmentPlanModel plan,
    String currencyLabel,
  ) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: plan.statusColor(context.colors).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.reportDate(plan.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: plan
                      .statusColor(context.colors)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  plan.statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: plan.statusColor(context.colors),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.reportTotalAmount,
                    style: TextStyle(fontSize: 10, color: colors.textTertiary),
                  ),
                  Text(
                    '${_formatPrice(plan.totalAmount)} $currencyLabel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.reportParts,
                    style: TextStyle(fontSize: 10, color: colors.textTertiary),
                  ),
                  Text(
                    context.l10n.commonCountShort(plan.itemsCount),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xxs),
            child: LinearProgressIndicator(
              value: plan.progress,
              backgroundColor: colors.border.withValues(alpha: 0.5),
              color: context.colors.success,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.reportPaidWithCurrency(
                  _formatPrice(plan.paidAmount),
                  currencyLabel,
                ),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: context.colors.success,
                ),
              ),
              Text(
                context.l10n.reportRemainingWithCurrency(
                  _formatPrice(plan.totalRemaining),
                  currencyLabel,
                ),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- 3. PAYMENTS ----------------
  Widget _buildPaymentsSection(
    List<PartnerInstallmentPaymentModel> payments,
    String currencyLabel,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  AppIcons.history,
                  size: 16,
                  color: context.colors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.installmentPaymentHistory,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...payments.take(5).map((pm) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.colors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.check,
                      color: context.colors.success,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatPrice(pm.amount)} $currencyLabel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (pm.note != null && pm.note!.isNotEmpty)
                          Text(
                            pm.note!,
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    pm.createdAt,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------- 4. SCHEDULE ITEMS ----------------
  Widget _buildScheduleItemsSection(
    List<PartnerInstallmentItemModel> items,
    String currencyLabel,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  AppIcons.calendarNote,
                  size: 16,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.reportPartsSchedule,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildItemFilterChip(context.l10n.commonAll, 'all'),
                const SizedBox(width: 6),
                _buildItemFilterChip(
                  context.l10n.dashboardOverdueLabel,
                  'overdue',
                ),
                const SizedBox(width: 6),
                _buildItemFilterChip(context.l10n.reportPending, 'pending'),
                const SizedBox(width: 6),
                _buildItemFilterChip(context.l10n.commonPaid, 'paid'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  context.l10n.dueEmpty,
                  style: TextStyle(color: colors.textSecondary, fontSize: 13),
                ),
              ),
            )
          else
            ...items.take(8).map((it) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: it
                            .statusColor(context.colors)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Center(
                        child: Text(
                          '${it.itemNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: it.statusColor(context.colors),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_formatPrice(it.amount)} $currencyLabel',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            context.l10n.reportDueDate(it.dueDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: it
                            .statusColor(context.colors)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        it.statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: it.statusColor(context.colors),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildItemFilterChip(String label, String value) {
    final colors = context.colors;
    final isSelected = _selectedItemFilter == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedItemFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? context.colors.onPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ---------------- 5. MONTHLY DYNAMICS ----------------
  Widget _buildMonthlyDynamicsSection(
    List<PartnerMonthlyDynamicModel> dynamics,
    String currencyLabel,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: context.colors.accentViolet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  AppIcons.chart,
                  size: 16,
                  color: context.colors.accentViolet,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                context.l10n.reportMonthlyPaymentDynamics,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...dynamics.where((d) => d.hasData).map((d) {
            final double planned = d.plannedAmount;
            final double collected = d.collectedAmount;
            final double max = planned > collected ? planned : collected;
            final double progress = max > 0
                ? (collected / max).clamp(0.0, 1.0)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        d.monthShort(context.l10n),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        context.l10n.reportPlanCollected(
                          _formatPrice(d.planned),
                          _formatPrice(d.collected),
                        ),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xxs),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colors.surfaceSecondary,
                      color: context.colors.accentViolet,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Bo'lib to'lash rejasi holati → semantik rang (UI qatlami; model rangni
/// bilmaydi).
extension _PlanStatusColor on PartnerInstallmentPlanModel {
  Color statusColor(AppColorsExtension colors) => switch (status) {
    'active' => colors.accentIndigo,
    'completed' => colors.success,
    'cancelled' => colors.textTertiary,
    _ => colors.textSecondary,
  };
}

/// To'lov jadvali elementi holati → semantik rang.
extension _ItemStatusColor on PartnerInstallmentItemModel {
  Color statusColor(AppColorsExtension colors) => switch (status) {
    'paid' => colors.success,
    'partial' => colors.primary,
    'near' => colors.warning,
    'overdue' => colors.error,
    _ => colors.textTertiary,
  };
}
