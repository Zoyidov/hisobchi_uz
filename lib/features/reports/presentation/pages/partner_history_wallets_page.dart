import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/constants/app_permission.dart';
import '../../../../core/widgets/navigation/permission_guard.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../../partners/data/partner_models.dart';
import '../../../partners/data/wallet_repository.dart';
import '../../../partners/presentation/widgets/transaction_action_sheets.dart';
import '../../../partners/presentation/widgets/transaction_receipt_sheet.dart';
import '../../../partners/presentation/widgets/transaction_tile.dart';

class PartnerHistoryWalletsPage extends StatefulWidget {
  final int partnerId;
  final String partnerName;
  final Partner? partner;
  final String type; // 'debt' (Kirim) or 'credit' (Chiqim)
  final int currencyTypeId; // 1 (UZS) or 2 (USD)

  const PartnerHistoryWalletsPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
    this.partner,
    required this.type,
    required this.currencyTypeId,
  });

  @override
  State<PartnerHistoryWalletsPage> createState() =>
      _PartnerHistoryWalletsPageState();
}

class _PartnerHistoryWalletsPageState extends State<PartnerHistoryWalletsPage> {
  List<Wallet>? _wallets;
  bool _isLoading = true;
  String? _error;

  bool get _isKirim => widget.type == 'debt';
  String get _currencyLabel => widget.currencyTypeId == 2 ? 'USD' : 'UZS';

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await getIt<WalletRepository>().getWallets(
      partnerId: widget.partnerId,
      type: widget.type,
      currencyTypeId: widget.currencyTypeId,
      isCancelled: 0,
    );

    if (!mounted) return;

    result.when(
      success: (data) => setState(() {
        _wallets = data;
        _isLoading = false;
      }),
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  Future<void> _openActions(Wallet wallet) async {
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

    final dummyPartner = widget.partner ??
        Partner.placeholder(
          id: widget.partnerId,
          name: widget.partnerName,
          phone: widget.partner?.phone ?? '',
          mainCurrencyTypeId: widget.currencyTypeId,
          mainCurrencyTypeName: widget.currencyTypeId == 2 ? 'USD' : 'UZS',
        );

    final action = await showTransactionReceiptSheet(
      context,
      wallet: wallet,
      partner: dummyPartner,
      isOwner: user?.isOwner ?? false,
      canCancel: canCancel,
    );
    if (action == null || !mounted) return;

    switch (action) {
      case ReceiptAction.cancel:
        final reason = await showCancelTransactionSheet(
          context,
          wallet: wallet,
        );
        if (reason == null || !mounted) return;
        final res = await getIt<WalletRepository>().cancelWallet(
          wallet.id,
          reason,
        );
        if (!mounted) return;
        res.when(
          success: (_) {
            AppSnackbar.success(context, 'Saqlandi');
            _loadWallets();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
      case ReceiptAction.delete:
        final confirmed = await showDeleteTransactionDialog(
          context,
          wallet: wallet,
        );
        if (confirmed != true || !mounted) return;
        final res = await getIt<WalletRepository>().deleteWallet(wallet.id);
        if (!mounted) return;
        res.when(
          success: (_) {
            AppSnackbar.success(context, 'O\'chirildi');
            _loadWallets();
          },
          failure: (f) => AppSnackbar.error(context, f.message),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = _isKirim ? 'Kirimlar ro\'yxati' : 'Chiqimlar ro\'yxati';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              '${widget.partnerName} • $_currencyLabel',
              style: TextStyle(
                fontSize: 11,
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return const AppSkeletonList();
    }

    if (_error != null) {
      return AppErrorState(
        title: 'Yuklab bo\'lmadi',
        description: _error,
        onRetry: _loadWallets,
      );
    }

    final wallets = _wallets ?? [];
    if (wallets.isEmpty) {
      return const AppEmptyState(
        title: 'Hozircha tranzaksiya yo\'q',
        icon: Icons.receipt_long_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWallets,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: wallets.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          return TransactionTile(
            compact: true,
            wallet: wallet,
            onTap: () => _openActions(wallet),
          );
        },
      ),
    );
  }
}
