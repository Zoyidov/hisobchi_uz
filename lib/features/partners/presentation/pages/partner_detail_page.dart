import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/icons/app_edit_icon.dart';
import '../../../../core/constants/app_permission.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/utils/formatters/money_formatter.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/chips/app_filter_chip.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../widgets/partner_detail_skeleton.dart';
import '../../../installments/presentation/widgets/partner_installments_tab.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../../data/wallet_repository.dart';
import '../cubit/partner_detail_cubit.dart';
import '../cubit/wallet_list_cubit.dart';
import '../widgets/export_excel_helper.dart';
import '../widgets/partner_sms_history_tab.dart';
import '../widgets/transaction_action_sheets.dart';
import '../widgets/transaction_date_filter_sheet.dart';
import '../widgets/transaction_receipt_sheet.dart';
import '../widgets/transaction_tile.dart';
import 'wallet_form_page.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Hamkor kartochkasi — 3 tabli ekran (MOBILE_APP_TZ.md 8.5).
class PartnerDetailPage extends StatelessWidget {
  const PartnerDetailPage({super.key, required this.partnerId});

  final int partnerId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              PartnerDetailCubit(getIt<PartnersRepository>(), partnerId)
                ..load(),
        ),
        BlocProvider(
          create: (_) =>
              WalletListCubit(getIt<WalletRepository>(), partnerId)..load(),
        ),
      ],
      child: _PartnerDetailView(partnerId: partnerId),
    );
  }
}

class _PartnerDetailView extends StatelessWidget {
  const _PartnerDetailView({required this.partnerId});
  final int partnerId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<PartnerDetailCubit, PartnerDetailState>(
        builder: (context, state) {
          return switch (state) {
            PartnerDetailLoading() => const PartnerDetailSkeleton(),
            PartnerDetailError(:final failure) => Scaffold(
              appBar: AppBar(),
              body: AppErrorState(
                failure: failure,
                onRetry: () => context.read<PartnerDetailCubit>().load(),
              ),
            ),
            PartnerDetailLoaded(:final partner, :final account) => _Loaded(
              partner: partner,
              account: account,
            ),
          };
        },
      ),
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.partner, required this.account});
  final Partner partner;
  final PartnerAccount account;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              partner.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -.3,
              ),
            ),
            Text(
              PhoneFormatter.toDisplay(partner.phone),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
        actions: [
          PermissionGuard(
            permission: AppPermission.partnersEdit,
            child: IconButton(
              tooltip: context.l10n.partnersEdit,
              icon: const AppEditIcon(size: 20),
              onPressed: () async {
                await context.push(
                  RoutePaths.partnerEdit(partner.id),
                  extra: partner,
                );
                if (context.mounted) {
                  context.read<PartnerDetailCubit>().load();
                }
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppRadius.medium),
              ),
              child: TabBar(
                dividerHeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                indicator: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                labelColor: context.colors.onPrimary,
                unselectedLabelColor: colors.textSecondary,
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: [
                  Tab(text: context.l10n.partnerDetailTransactionsTab),
                  Tab(text: context.l10n.commonInstallment),
                  Tab(text: context.l10n.partnerDetailSmsTab),
                ],
              ),
            ),
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  _MultiCurrencyAccountCard(account: account, partner: partner),
                  const SizedBox(height: 10),
                  _QuickActionsRow(partner: partner),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          children: [
            _TransactionsTab(partner: partner),
            PartnerInstallmentsTab(partner: partner),
            PartnerSmsHistoryTab(partner: partner),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            8,
            AppSpacing.md,
            12,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(color: colors.border.withValues(alpha: 0.6)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: PermissionGuard(
                  permission: AppPermission.walletsDebtCreate,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.success,
                      foregroundColor: context.colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final res = await showWalletFormSheet(
                        context,
                        type: 'debt',
                        partner: partner,
                      );
                      if (res != null && context.mounted) {
                        context.read<PartnerDetailCubit>().load();
                        context.read<WalletListCubit>().refresh();
                      }
                    },
                    icon: const Icon(AppIcons.income, size: 18),
                    label: Text(
                      context.l10n.commonIncome,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PermissionGuard(
                  permission: AppPermission.walletsCreditCreate,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.error,
                      foregroundColor: context.colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final res = await showWalletFormSheet(
                        context,
                        type: 'credit',
                        partner: partner,
                      );
                      if (res != null && context.mounted) {
                        context.read<PartnerDetailCubit>().load();
                        context.read<WalletListCubit>().refresh();
                      }
                    },
                    icon: const Icon(AppIcons.expense, size: 18),
                    label: Text(
                      context.l10n.commonExpense,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.partner});
  final Partner partner;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _action(
          context,
          AppIcons.call,
          context.l10n.commonCall,
          () => launchUrl(Uri.parse('tel:${partner.phone}')),
        ),
        _action(
          context,
          AppIcons.message,
          'SMS',
          () => launchUrl(Uri.parse('sms:${partner.phone}')),
        ),
        PermissionGuard(
          permission: AppPermission.reportPartnerView,
          child: _action(
            context,
            AppIcons.chart,
            context.l10n.commonReport,
            () => context.push(
              RoutePaths.reportPartnerDetail(partner.id),
              extra: partner,
            ),
          ),
        ),
        _action(
          context,
          AppIcons.download,
          context.l10n.commonExcelShort,
          () => downloadAndShareExcel(
            context,
            download: () => getIt<PartnersRepository>()
                .exportPartnerWalletsExcel(partner.id),
            fileName: '${partner.name}_tranzaksiyalar.xlsx',
          ),
        ),
        _action(
          context,
          AppIcons.settings,
          context.l10n.partnerSmsSettingShort,
          () => context.push(RoutePaths.smsSettings(partner.id)),
        ),
      ],
    );
  }

  Widget _action(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final colors = context.colors;
    final accent = switch (icon) {
      AppIcons.call => colors.success,
      AppIcons.message => colors.info,
      AppIcons.chart => colors.accentViolet,
      AppIcons.download => colors.success,
      _ => colors.warning,
    };
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: .2),
                      accent.withValues(alpha: .08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: accent.withValues(alpha: .22)),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zamonaviy FinTech ko'p valyutali balans kartochkasi.
/// UZS va USD hisoblarini ixcham, o'ta qulay va bir vaqtda ko'rinadigan
/// segmented switcher orqali ko'rsatadi, ekranning vertikal joyini 50% ga tejaydi.
class _MultiCurrencyAccountCard extends StatefulWidget {
  const _MultiCurrencyAccountCard({
    required this.account,
    required this.partner,
  });

  final PartnerAccount account;
  final Partner partner;

  @override
  State<_MultiCurrencyAccountCard> createState() =>
      _MultiCurrencyAccountCardState();
}

class _MultiCurrencyAccountCardState extends State<_MultiCurrencyAccountCard> {
  late String _selectedCurrency;
  int _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.partner.mainCurrencyTypeId == 2 ? 'USD' : 'UZS';
  }

  bool get _hasUsd {
    final usd = widget.account.usd;
    return usd.debt != Decimal.zero ||
        usd.credit != Decimal.zero ||
        usd.balanceWithInstallment != Decimal.zero;
  }

  void _selectCurrency(String currency) {
    if (_selectedCurrency == currency) return;
    HapticFeedback.selectionClick();
    setState(() {
      _slideDirection = currency == 'USD' ? 1 : -1;
      _selectedCurrency = currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUsd = _hasUsd;
    final activeCurrency = hasUsd ? _selectedCurrency : 'UZS';
    final activeAccount = activeCurrency == 'UZS'
        ? widget.account.uzs
        : widget.account.usd;
    final tint = activeCurrency == 'UZS' ? colors.primary : colors.accentViolet;

    return GestureDetector(
      onHorizontalDragEnd: hasUsd
          ? (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -150 && _selectedCurrency == 'UZS') {
                _selectCurrency('USD');
              } else if (velocity > 150 && _selectedCurrency == 'USD') {
                _selectCurrency('UZS');
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: tint.withValues(alpha: 0.22), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: tint.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ikkala valyuta ham mavjud bo'lsa, ixcham zamonaviy sliding segmented tab
            if (hasUsd) ...[
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final tabWidth = (constraints.maxWidth - 6) / 2;
                  final isUzs = _selectedCurrency == 'UZS';

                  return Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colors.border.withValues(alpha: 0.4),
                      ),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Stack(
                      children: [
                        // Silliq siljuvchi oq pill (Sliding selection indicator)
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.fastOutSlowIn,
                          left: isUzs ? 0 : tabWidth,
                          top: 0,
                          bottom: 0,
                          width: tabWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.25 : 0.08,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tab tugmalari
                        Row(
                          children: [
                            _buildSegmentTab(
                              context: context,
                              label: 'UZS',
                              balance: widget.account.uzs.balance,
                              isSelected: isUzs,
                              tint: colors.primary,
                              onTap: () => _selectCurrency('UZS'),
                            ),
                            _buildSegmentTab(
                              context: context,
                              label: 'USD',
                              balance: widget.account.usd.balance,
                              isSelected: !isUzs,
                              tint: colors.accentViolet,
                              onTap: () => _selectCurrency('USD'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],

            // Aktiv valyutadagi ma'lumotlar (yo'naltirilgan silliq slide va fade animatsiya bilan)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.fastOutSlowIn,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                  transitionBuilder: (child, animation) {
                    final isIncoming =
                        child.key == ValueKey<String>(activeCurrency);
                    final inOffset = Tween<Offset>(
                      begin: Offset(_slideDirection * 0.25, 0),
                      end: Offset.zero,
                    ).animate(animation);

                    final outOffset = Tween<Offset>(
                      begin: Offset(-_slideDirection * 0.25, 0),
                      end: Offset.zero,
                    ).animate(animation);

                    return SlideTransition(
                      position: isIncoming ? inOffset : outOffset,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _buildAccountDetails(
                    key: ValueKey<String>(activeCurrency),
                    context: context,
                    account: activeAccount,
                    currency: activeCurrency,
                    tint: tint,
                    showSingleBadge: !hasUsd,
                  ),
                ),
              ),
            ),

            // Silliq nuqta indikatori (faqat ikkala valyuta mavjud bo'lganda)
            if (hasUsd) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(
                    isSelected: _selectedCurrency == 'UZS',
                    color: colors.primary,
                  ),
                  const SizedBox(width: 5),
                  _buildDot(
                    isSelected: _selectedCurrency == 'USD',
                    color: colors.accentViolet,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab({
    required BuildContext context,
    required String label,
    required Decimal balance,
    required bool isSelected,
    required Color tint,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: isSelected ? 0.16 : 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: tint,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: amountColor(context, balance.toDouble()),
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.fontFamily,
                  ),
                  child: Text(
                    MoneyFormatter.formatSigned(balance, currencyLabel: ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isSelected, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.fastOutSlowIn,
      width: isSelected ? 16 : 5,
      height: 4,
      decoration: BoxDecoration(
        color: isSelected ? color : color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.hairline),
      ),
    );
  }

  Widget _buildAccountDetails({
    required Key key,
    required BuildContext context,
    required PartnerCurrencyAccount account,
    required String currency,
    required Color tint,
    required bool showSingleBadge,
  }) {
    final colors = context.colors;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSingleBadge) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  currency,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: tint,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.balanceNet,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currency == 'UZS'
                        ? context.l10n.partnerAccountUzs
                        : context.l10n.partnerAccountUsd,
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                MoneyFormatter.formatSigned(
                  account.balance,
                  currencyLabel: currency,
                ),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: amountColor(context, account.balance.toDouble()),
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: colors.surfaceSecondary.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: _flow(
                  context,
                  context.l10n.commonIncome,
                  account.debt,
                  colors.success,
                  AppIcons.income,
                  currency,
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: colors.border.withValues(alpha: 0.5),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _flow(
                  context,
                  context.l10n.commonExpense,
                  account.credit,
                  colors.error,
                  AppIcons.expense,
                  currency,
                ),
              ),
            ],
          ),
        ),
        if (account.balanceWithInstallment > Decimal.zero) ...[
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.small),
              border: Border.all(color: colors.info.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Icon(AppIcons.calendar, size: 14, color: colors.info),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.balanceInstallmentRemaining,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  MoneyFormatter.format(
                    account.balanceWithInstallment,
                    currencyLabel: currency,
                  ),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colors.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _flow(
    BuildContext context,
    String label,
    Decimal amount,
    Color color,
    IconData icon,
    String currency,
  ) => Row(
    children: [
      Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              MoneyFormatter.format(amount, currencyLabel: currency),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({required this.partner});
  final Partner partner;

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<WalletListCubit>();
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.sm,
            bottom: AppSpacing.xs,
          ),
          child: SizedBox(
            height: MediaQuery.textScalerOf(context).scale(14) + 24,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                for (final filter in WalletFilterStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: AppFilterChip(
                      label: filter.label(context.l10n),
                      selected: cubit.filter == filter,
                      onTap: () => cubit.updateFilter(filter),
                    ),
                  ),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: cubit.hasDateFilter
                        ? colors.primary.withValues(alpha: 0.12)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: cubit.hasDateFilter
                          ? colors.primary
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: IconButton(
                    tooltip: context.l10n.commonFilterByDate,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 38,
                      minHeight: 36,
                    ),
                    icon: Icon(
                      AppIcons.calendar,
                      size: 18,
                      color: cubit.hasDateFilter
                          ? colors.primary
                          : colors.textSecondary,
                    ),
                    onPressed: () => _pickDateRange(context, cubit),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (cubit.hasDateFilter)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.calendar, size: 13, color: colors.primary),
                      const SizedBox(width: 5),
                      Text(
                        '${AppDateFormatter.display(cubit.dateFrom!)} — ${AppDateFormatter.display(cubit.dateTo!)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: cubit.clearDateFilter,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            AppIcons.close,
                            size: 12,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: BlocBuilder<WalletListCubit, WalletListState>(
            builder: (context, state) {
              return switch (state) {
                WalletListLoading() => const TransactionListSkeleton(),
                WalletListError(:final failure) => AppErrorState(
                  failure: failure,
                  onRetry: () => context.read<WalletListCubit>().load(),
                ),
                WalletListLoaded(:final wallets) =>
                  wallets.isEmpty
                      ? AppEmptyState(
                          title: context.l10n.partnerDetailEmptyTransactions,
                          icon: AppIcons.receipt,
                        )
                      : RefreshIndicator(
                          onRefresh: () =>
                              context.read<WalletListCubit>().refresh(),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: wallets.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final wallet = wallets[index];
                              return TransactionTile(
                                compact: true,
                                wallet: wallet,
                                onTap: () => _openActions(context, wallet),
                              );
                            },
                          ),
                        ),
              };
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    WalletListCubit cubit,
  ) async {
    final result = await showTransactionDateFilterSheet(
      context,
      currentFrom: cubit.dateFrom,
      currentTo: cubit.dateTo,
    );
    if (result == null) return;
    if (result.isCleared) {
      cubit.clearDateFilter();
    } else if (result.start != null && result.end != null) {
      cubit.updateDateRange(result.start, result.end);
    }
  }

  Future<void> _openActions(BuildContext context, Wallet wallet) async {
    HapticFeedback.lightImpact();
    final user = context.read<UserCubit>().currentUserOrNull;
    final canCancel = wallet.isExpense
        ? PermissionGuard.hasPermission(
            context,
            AppPermission.walletsCreditCancel,
          )
        : PermissionGuard.hasPermission(
            context,
            AppPermission.walletsDebtCancel,
          );

    final action = await showTransactionReceiptSheet(
      context,
      wallet: wallet,
      partner: partner,
      isOwner: user?.isOwner ?? false,
      canCancel: canCancel,
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case ReceiptAction.cancel:
        final reason = await showCancelTransactionSheet(
          context,
          wallet: wallet,
        );
        if (reason == null || !context.mounted) return;
        final result = await getIt<WalletRepository>().cancelWallet(
          wallet.id,
          reason,
        );
        if (!context.mounted) return;
        result.when(
          success: (_) {
            AppSnackbar.success(context, context.l10n.commonSaved);
            context.read<WalletListCubit>().refresh();
            context.read<PartnerDetailCubit>().load();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
      case ReceiptAction.delete:
        final confirmed = await showDeleteTransactionDialog(
          context,
          wallet: wallet,
        );
        if (confirmed != true || !context.mounted) return;
        final result = await getIt<WalletRepository>().deleteWallet(wallet.id);
        if (!context.mounted) return;
        result.when(
          success: (_) {
            AppSnackbar.success(context, context.l10n.commonDeletedToast);
            context.read<WalletListCubit>().refresh();
            context.read<PartnerDetailCubit>().load();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
    }
  }
}
