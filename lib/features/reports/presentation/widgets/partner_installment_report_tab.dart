import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/partner_installment_report_models.dart';
import '../../data/reports_repository.dart';

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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildCurrencyTabItem('UZS Hisob', 0),
                Container(width: 1, height: 20, color: colors.border),
                _buildCurrencyTabItem('USD Hisob', 1),
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
            borderRadius: BorderRadius.circular(10),
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
        title: 'Yuklab bo\'lmadi',
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
        borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.dashboard_rounded,
                  size: 16,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Umumiy statistika',
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
                  label: 'Faol',
                  value: '${stat.activePlans}',
                  color: colors.primary,
                  icon: Icons.play_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricChip(
                  label: 'Tugallangan',
                  value: '${stat.completedPlans}',
                  color: const Color(0xFF22C55E),
                  icon: Icons.check_circle_outline_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricChip(
                  label: 'Bekor',
                  value: '${stat.cancelledPlans}',
                  color: const Color(0xFF94A3B8),
                  icon: Icons.cancel_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Berilgan / To'langan
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  label: 'Berilgan',
                  amount: '${_formatPrice(stat.totalGiven)} $currencyLabel',
                  color: const Color(0xFF6366F1),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAmountCard(
                  label: 'To\'langan',
                  amount: '${_formatPrice(stat.totalPaid)} $currencyLabel',
                  color: const Color(0xFF22C55E),
                  icon: Icons.check_circle_outline_rounded,
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
              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.hourglass_bottom_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Qolgan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_formatPrice(stat.totalRemaining)} $currencyLabel',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
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
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Muddati o\'tgan: ${_formatPrice(stat.overdueAmount)} $currencyLabel',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEF4444),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
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
          const SizedBox(height: 4),
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
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 4),
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
        borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: colors.accentViolet,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Muddatli to‘lov rejalari',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (plans.isNotEmpty) ...[
                const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Rejalar mavjud emas',
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: plan.statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sana: ${plan.createdAt}',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: plan.statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: plan.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jami summa',
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
                    'Qismlar',
                    style: TextStyle(fontSize: 10, color: colors.textTertiary),
                  ),
                  Text(
                    '${plan.itemsCount} ta',
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
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: plan.progress,
              backgroundColor: colors.border.withValues(alpha: 0.5),
              color: const Color(0xFF22C55E),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To\'langan: ${_formatPrice(plan.paidAmount)} $currencyLabel',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF22C55E),
                ),
              ),
              Text(
                'Qolgan: ${_formatPrice(plan.totalRemaining)} $currencyLabel',
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
        borderRadius: BorderRadius.circular(20),
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
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'To\'lovlar tarixi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...payments.take(5).map((pm) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF22C55E),
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
        borderRadius: BorderRadius.circular(20),
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
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  size: 16,
                  color: Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'To\'lov qismlari grafigi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildItemFilterChip('Barchasi', 'all'),
                const SizedBox(width: 6),
                _buildItemFilterChip('Muddati o\'tgan', 'overdue'),
                const SizedBox(width: 6),
                _buildItemFilterChip('Kutilmoqda', 'pending'),
                const SizedBox(width: 6),
                _buildItemFilterChip('To\'langan', 'paid'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'Bu bo\'limda ma\'lumot yo\'q',
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: it.statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${it.itemNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: it.statusColor,
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
                            'Muddat: ${it.dueDate}',
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
                        color: it.statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        it.statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: it.statusColor,
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : colors.textSecondary,
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
        borderRadius: BorderRadius.circular(20),
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 16,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Oylik to\'lov dinamikasi',
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
                        d.uzLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Reja: ${_formatPrice(d.planned)} | Yig\'ildi: ${_formatPrice(d.collected)}',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: colors.surfaceSecondary,
                      color: const Color(0xFF8B5CF6),
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
