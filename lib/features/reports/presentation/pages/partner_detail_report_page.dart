import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../partners/data/partner_models.dart';
import '../../../partners/data/partners_repository.dart';
import '../../../partners/presentation/widgets/export_excel_helper.dart';
import '../../data/partner_report_models.dart';
import '../../data/reports_repository.dart';
import '../widgets/balance_card.dart';
import '../widgets/balance_line_chart.dart';
import '../widgets/debt_aging_grid.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/partner_installment_report_tab.dart';
import '../widgets/summary_grid.dart';
import 'partner_debt_detail_page.dart';
import 'partner_history_wallets_page.dart';

/// Hamkor bo'yicha to'liq hisobot ekrani (ReportClientShowPage standarti)
/// 2 ta asosiy tab:
/// 1. "Hisob kitob" (UZS/USD dinamikasi, Balans, Kirim/Chiqim, Qarzlar muddati, Grafiklar)
/// 2. "Muddatli to'lov" (Rejalar, Statistika, To'lovlar grafigi, Oylik dinamika)
class PartnerDetailReportPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final Partner? partner;
  final int initialTabIndex;

  const PartnerDetailReportPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partner,
    this.initialTabIndex = 0,
  });

  @override
  State<PartnerDetailReportPage> createState() => _PartnerDetailReportPageState();
}

class _PartnerDetailReportPageState extends State<PartnerDetailReportPage>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _currencyTabController;

  PartnerDetailsResult? _report;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _mainTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) setState(() {});
    });

    _currencyTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    _currencyTabController.addListener(() {
      if (!_currencyTabController.indexIsChanging) {
        HapticFeedback.selectionClick();
        setState(() {});
      }
    });

    _load();
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _currencyTabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result =
        await getIt<ReportsRepository>().getPartnerDetailReport(widget.partnerId);

    if (!mounted) return;

    result.when(
      success: (r) => setState(() {
        _report = r;
        _isLoading = false;
      }),
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  void _exportExcel() {
    downloadAndShareExcel(
      context,
      download: () =>
          getIt<PartnersRepository>().exportPartnerWalletsExcel(widget.partnerId),
      fileName: '${widget.partnerName}_hisobot.xlsx',
    );
  }

  void _handleDebtAgingTap(String title, String currency) {
    final type = switch (title) {
      "Muddati o'tgan" => 'qarz_expired',
      "Bugun" => 'qarz_today',
      "Yaqinlashmoqda" => 'qarz_3_days',
      _ => '',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerDebtDetailPage(
          type: type,
          currencyTypeId: currency == 'UZS' ? 1 : 2,
          title: title,
          partnerId: widget.partnerId,
        ),
      ),
    );
  }

  void _navigateToHistory({required String type, required String currency}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PartnerHistoryWalletsPage(
          partnerId: widget.partnerId,
          partnerName: widget.partnerName,
          partner: widget.partner,
          type: type,
          currencyTypeId: currency == 'UZS' ? 1 : 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          widget.partnerName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        actions: [
          if (_mainTabController.index == 0)
            PopupMenuButton<int>(
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: colors.surface,
              icon: Icon(CupertinoIcons.ellipsis_vertical, color: colors.textPrimary),
              onSelected: (val) {
                if (val == 1) _exportExcel();
              },
              itemBuilder: (context) => [
                PopupMenuItem<int>(
                  value: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 42,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_download_outlined, color: colors.primary, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Excel hisobot',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildMainTabBar(context),
        ),
      ),
      body: TabBarView(
        controller: _mainTabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ── Tab 1: Hisob kitob ──────────────────────────────────────────
          _buildHisobKitobTab(context),

          // ── Tab 2: Muddatli to'lov ──────────────────────────────────────
          PartnerInstallmentReportTab(
            partnerId: widget.partnerId,
            partnerName: widget.partnerName,
            partnerPhone: widget.partner?.phone ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabBar(BuildContext context) {
    final colors = context.colors;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(3),
        child: TabBar(
          controller: _mainTabController,
          indicator: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: colors.textSecondary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'Hisob kitob'),
            Tab(text: 'Muddatli to\'lov'),
          ],
        ),
      ),
    );
  }

  Widget _buildHisobKitobTab(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return const AppSkeletonList();
    }

    if (_error != null && _report == null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _load,
      );
    }

    final report = _report;
    if (report == null) return const SizedBox.shrink();

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            child: Container(
              color: colors.background,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _buildCurrencyTabBar(context),
            ),
            height: 60,
          ),
        ),
      ],
      body: TabBarView(
        controller: _currencyTabController,
        children: [
          _buildDashboardContent('UZS', report.uzs),
          _buildDashboardContent('USD', report.usd),
        ],
      ),
    );
  }

  Widget _buildCurrencyTabBar(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _currencyTabController,
      builder: (context, _) => Container(
        height: 44,
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            _buildCurrencyTabItem('UZS Hisob', 0),
            Container(width: 1, height: 20, color: colors.border),
            _buildCurrencyTabItem('USD Hisob', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTabItem(String label, int index) {
    final colors = context.colors;
    final isSelected = _currencyTabController.index == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _currencyTabController.animateTo(index),
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

  Widget _buildDashboardContent(
    String currency,
    PartnerDetailsCurrencyReport report,
  ) {
    final spots = report.balanceDynamics
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.balanceDouble))
        .toList();
    final labels = report.balanceDynamics.map((e) => e.label).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        key: PageStorageKey<String>(currency),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildAnimatedItem(
                  index: 0,
                  child: BalanceCard(
                    balance: report.balanceAmount,
                    currency: currency,
                    operationsCount: report.operationsCount,
                  ),
                ),
                _buildAnimatedItem(
                  index: 1,
                  child: SummaryGrid(
                    totalIncome: report.incomeAmount,
                    totalExpense: report.expenseAmount,
                    operationsCount: report.operationsCount,
                    currency: currency,
                    onIncomeTap: () =>
                        _navigateToHistory(type: 'debt', currency: currency),
                    onExpenseTap: () =>
                        _navigateToHistory(type: 'credit', currency: currency),
                  ),
                ),
                _buildAnimatedItem(
                  index: 2,
                  child: DebtAgingGrid(
                    overdueCount: report.qarzExpired,
                    todayCount: report.qarzToday,
                    upcomingCount: report.qarz3Days,
                    onOverdueTap: () =>
                        _handleDebtAgingTap("Muddati o'tgan", currency),
                    onTodayTap: () => _handleDebtAgingTap("Bugun", currency),
                    onUpcomingTap: () =>
                        _handleDebtAgingTap("Yaqinlashmoqda", currency),
                  ),
                ),
                if (report.monthlyStatistics.isNotEmpty)
                  _buildAnimatedItem(
                    index: 3,
                    child: MonthlyBarChart(
                      stats: report.monthlyStatistics,
                      currency: currency,
                    ),
                  ),
                if (spots.isNotEmpty)
                  _buildAnimatedItem(
                    index: 4,
                    child: BalanceLineChart(
                      spots: spots,
                      labels: labels,
                      currency: currency,
                    ),
                  ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 350 + (index * 80)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverTabBarDelegate({required this.child, required double height})
      : height = height.roundToDouble();

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      oldDelegate.child != child || oldDelegate.height != height;
}
