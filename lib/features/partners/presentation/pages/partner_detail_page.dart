import 'package:decimal/decimal.dart';
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
import '../../../../core/widgets/cards/app_balance_card.dart';
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
              onPressed: () => context.push(RoutePaths.partnerEdit(partner.id), extra: partner),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: context.colors.primary),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
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
    return BlocConsumer<WalletListCubit, WalletListState>(
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
    );
  }

  Future<void> _openActions(BuildContext context, Wallet wallet) async {
    final user = context.read<UserCubit>().currentUserOrNull;
    final canCancel = wallet.isExpense
        ? PermissionGuard.hasPermission(context, AppPermission.walletsCreditCancel)
        : PermissionGuard.hasPermission(context, AppPermission.walletsDebtCancel);

    final action = await showTransactionActionSheet(
      context,
      wallet,
      isOwner: user?.isOwner ?? false,
      canCancel: canCancel,
    );
    if (action == null || !context.mounted) return;

    switch (action) {
      case TransactionAction.cancel:
        final reason = await showCancelTransactionSheet(context);
        if (reason == null || !context.mounted) return;
        final result = await getIt<WalletRepository>().cancelWallet(wallet.id, reason);
        if (!context.mounted) return;
        result.when(
          success: (_) {
            AppSnackbar.success(context, 'Saqlandi');
            context.read<WalletListCubit>().refresh();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
      case TransactionAction.delete:
        final result = await getIt<WalletRepository>().deleteWallet(wallet.id);
        if (!context.mounted) return;
        result.when(
          success: (_) {
            AppSnackbar.success(context, 'Saqlandi');
            context.read<WalletListCubit>().refresh();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
      case TransactionAction.edit:
        await showWalletFormSheet(context, type: wallet.type, partner: partner, editingWallet: wallet);
        if (context.mounted) context.read<WalletListCubit>().refresh();
    }
  }
}
