import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/subscription_models.dart';
import '../../data/subscription_repository.dart';
import '../widgets/payment_flow_sheet.dart';

/// SMS paketlari (MOBILE_APP_TZ.md 13.5).
class SmsPackagesPage extends StatefulWidget {
  const SmsPackagesPage({super.key});

  @override
  State<SmsPackagesPage> createState() => _SmsPackagesPageState();
}

class _SmsPackagesPageState extends State<SmsPackagesPage> {
  List<SmsPackage>? _packages;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _packages = null;
      _error = null;
    });
    final result = await getIt<SubscriptionRepository>().getSmsPackages();
    if (!mounted) return;
    result.when(success: (list) => setState(() => _packages = list), failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS paketlari')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Yuklab bo\'lmadi', description: _error, onRetry: _load);
    if (_packages == null) return const AppSkeletonList();

    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final pkg in _packages!)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SMS ${pkg.smsCount}', style: Theme.of(context).textTheme.titleMedium),
                        Text(pkg.formattedPrice, style: TextStyle(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                  AppButton.primary(label: 'Sotib olish', expand: false, onPressed: () => _purchase(context, pkg)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _purchase(BuildContext context, SmsPackage package) async {
    final provider = await showAppBottomSheet<String>(
      context,
      title: 'To\'lov usuli',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Payme'), onTap: () => Navigator.of(context).pop('payme')),
          ListTile(title: const Text('Click'), onTap: () => Navigator.of(context).pop('click')),
        ],
      ),
    );
    if (provider == null || !context.mounted) return;

    final success = await showPaymentFlowSheet(
      context,
      createOrder: () => getIt<SubscriptionRepository>().purchaseSms(
        packageId: package.id,
        paymentProvider: provider,
        returnUrl: 'ehisob://payment-result',
      ),
      checkStatus: (orderNumber) => getIt<SubscriptionRepository>().checkOrderStatus(orderNumber),
    );
    if (!context.mounted) return;
    if (success) AppSnackbar.success(context, 'SMS paketi qo\'shildi');
  }
}
