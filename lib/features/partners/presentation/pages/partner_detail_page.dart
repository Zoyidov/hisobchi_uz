import 'package:decimal/decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_permission.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/cards/app_balance_card.dart';
import '../../../../core/widgets/chips/app_filter_chip.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
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

/// Hamkor kartochkasi — 3 tabli ekran (MOBILE_APP_TZ.md 8.5).
class PartnerDetailPage extends StatelessWidget {
  const PartnerDetailPage({super.key, required this.partnerId});

  final int partnerId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PartnerDetailCubit(getIt<PartnersRepository>(), partnerId)..load()),
        BlocProvider(create: (_) => WalletListCubit(getIt<WalletRepository>(), partnerId)..load()),
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
            PartnerDetailLoading() => const Scaffold(body: AppSkeletonList()),
            PartnerDetailError(:final failure) => Scaffold(
                appBar: AppBar(),
                body: AppErrorState(failure: failure, onRetry: () => context.read<PartnerDetailCubit>().load()),
              ),
            PartnerDetailLoaded(:final partner, :final account) => _Loaded(partner: partner, account: account),
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(partner.name, style: Theme.of(context).textTheme.titleMedium),
            Text(partner.phone, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
          ],
        ),
        actions: [
          PermissionGuard(
            permission: AppPermission.partnersEdit,
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await context.push(RoutePaths.partnerEdit(partner.id), extra: partner);
                if (context.mounted) {
                  context.read<PartnerDetailCubit>().load();
                }
              },
            ),
          ),
        ],
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Tranzaksiyalar'),
            Tab(text: 'Bo\'lib to\'lash'),
            Tab(text: 'SMS tarixi'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppBalanceCard(
                        currencyLabel: 'UZS',
                        income: account.uzs.debt,
                        expense: account.uzs.credit,
                        balance: account.uzs.balance,
                        installmentRemaining: account.uzs.balanceWithInstallment,
                      ),
                    ),
                  ],
                ),
                if (account.usd.debt != Decimal.zero || account.usd.credit != Decimal.zero) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppBalanceCard(
                    currencyLabel: 'USD',
                    income: account.usd.debt,
                    expense: account.usd.credit,
                    balance: account.usd.balance,
                    installmentRemaining: account.usd.balanceWithInstallment,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _QuickActionsRow(partner: partner),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TransactionsTab(partner: partner),
                PartnerInstallmentsTab(partner: partner),
                PartnerSmsHistoryTab(partner: partner),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 12),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.border.withValues(alpha: 0.6))),
          ),
          child: Row(
            children: [
              Expanded(
                child: PermissionGuard(
                  permission: AppPermission.walletsDebtCreate,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final res = await showWalletFormSheet(context, type: 'debt', partner: partner);
                      if (res != null && context.mounted) {
                        context.read<PartnerDetailCubit>().load();
                        context.read<WalletListCubit>().refresh();
                      }
                    },
                    icon: const Icon(CupertinoIcons.arrow_down_left_circle_fill, size: 18),
                    label: const Text('Kirim', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final res = await showWalletFormSheet(context, type: 'credit', partner: partner);
                      if (res != null && context.mounted) {
                        context.read<PartnerDetailCubit>().load();
                        context.read<WalletListCubit>().refresh();
                      }
                    },
                    icon: const Icon(CupertinoIcons.arrow_up_right_circle_fill, size: 18),
                    label: const Text('Chiqim', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _action(context, Icons.call_rounded, 'Qo\'ng\'iroq', () => launchUrl(Uri.parse('tel:${partner.phone}'))),
        _action(context, Icons.sms_outlined, 'SMS', () => launchUrl(Uri.parse('sms:${partner.phone}'))),
        PermissionGuard(
          permission: AppPermission.reportPartnerView,
          child: _action(
            context,
            Icons.bar_chart_rounded,
            'Hisobot',
            () => context.push(RoutePaths.reportPartnerDetail(partner.id), extra: partner),
          ),
        ),
        _action(
          context,
          Icons.file_download_outlined,
          'Excel',
          () => downloadAndShareExcel(
            context,
            download: () => getIt<PartnersRepository>().exportPartnerWalletsExcel(partner.id),
            fileName: '${partner.name}_tranzaksiyalar.xlsx',
          ),
        ),
        _action(context, Icons.settings_outlined, 'SMS sozlama', () => context.push(RoutePaths.smsSettings(partner.id))),
      ],
    );
  }

  Widget _action(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: colors.primary.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, color: colors.primary, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
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
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final filter in WalletFilterStatus.values)
                        Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.xs),
                          child: AppFilterChip(
                            label: filter.label,
                            selected: cubit.filter == filter,
                            onTap: () => cubit.updateFilter(filter),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: cubit.hasDateFilter ? colors.primary.withValues(alpha: 0.12) : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cubit.hasDateFilter ? colors.primary : Theme.of(context).dividerColor,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 36),
                  icon: Icon(
                    CupertinoIcons.calendar,
                    size: 18,
                    color: cubit.hasDateFilter ? colors.primary : colors.textSecondary,
                  ),
                  onPressed: () => _pickDateRange(context, cubit),
                ),
              ),
            ],
          ),
        ),
        if (cubit.hasDateFilter)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xs),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.calendar, size: 13, color: colors.primary),
                      const SizedBox(width: 5),
                      Text(
                        '${AppDateFormatter.display(cubit.dateFrom!)} — ${AppDateFormatter.display(cubit.dateTo!)}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary),
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
                          child: Icon(Icons.close_rounded, size: 12, color: colors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: BlocConsumer<WalletListCubit, WalletListState>(
            listener: (context, state) {},
            builder: (context, state) {
              return switch (state) {
                WalletListLoading() => const AppSkeletonList(),
                WalletListError(:final failure) => AppErrorState(
                    failure: failure,
                    onRetry: () => context.read<WalletListCubit>().load(),
                  ),
                WalletListLoaded(:final wallets) => wallets.isEmpty
                    ? const AppEmptyState(title: 'Hozircha tranzaksiya yo\'q', icon: Icons.receipt_long_outlined)
                    : RefreshIndicator(
                        onRefresh: () => context.read<WalletListCubit>().refresh(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: wallets.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final wallet = wallets[index];
                            return TransactionTile(
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

  Future<void> _pickDateRange(BuildContext context, WalletListCubit cubit) async {
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
    final user = context.read<UserCubit>().currentUserOrNull;
    final canCancel = wallet.isExpense
        ? PermissionGuard.hasPermission(context, AppPermission.walletsCreditCancel)
        : PermissionGuard.hasPermission(context, AppPermission.walletsDebtCancel);

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
        final reason = await showCancelTransactionSheet(context, wallet: wallet);
        if (reason == null || !context.mounted) return;
        final result = await getIt<WalletRepository>().cancelWallet(wallet.id, reason);
        if (!context.mounted) return;
        result.when(
          success: (_) {
            AppSnackbar.success(context, 'Saqlandi');
            context.read<WalletListCubit>().refresh();
            context.read<PartnerDetailCubit>().load();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
      case ReceiptAction.delete:
        final confirmed = await showDeleteTransactionDialog(context, wallet: wallet);
        if (confirmed != true || !context.mounted) return;
        final result = await getIt<WalletRepository>().deleteWallet(wallet.id);
        if (!context.mounted) return;
        result.when(
          success: (_) {
            AppSnackbar.success(context, 'O\'chirildi');
            context.read<WalletListCubit>().refresh();
            context.read<PartnerDetailCubit>().load();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
    }
  }
}
