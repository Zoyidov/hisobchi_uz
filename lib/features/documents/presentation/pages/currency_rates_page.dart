import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/document_models.dart';
import '../../data/documents_repository.dart';

/// Valyuta kurslari (CBU) + konvertor (MOBILE_APP_TZ.md 11-bo'lim).
class CurrencyRatesPage extends StatefulWidget {
  const CurrencyRatesPage({super.key});

  @override
  State<CurrencyRatesPage> createState() => _CurrencyRatesPageState();
}

class _CurrencyRatesPageState extends State<CurrencyRatesPage> {
  List<CurrencyExchangeRate>? _rates;
  String? _error;
  final _amountController = TextEditingController(text: '100');
  CurrencyExchangeRate? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _rates = null;
      _error = null;
    });
    final result = await getIt<DocumentsRepository>().getCurrencyExchangeRates();
    if (!mounted) return;
    result.when(
      success: (rates) => setState(() {
        _rates = rates;
        _selected = rates.isNotEmpty ? rates.first : null;
      }),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  double get _converted {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_selected == null) return 0;
    return amount * _selected!.rate / _selected!.nominal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Valyuta kurslari')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return AppErrorState(title: 'Kurslarni yuklab bo\'lmadi', description: _error, onRetry: _load);
    }
    if (_rates == null) return const AppSkeletonList();
    if (_rates!.isEmpty) return const AppEmptyState(title: 'Kurslar topilmadi', icon: Icons.currency_exchange_rounded);

    final colors = context.colors;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Konvertor', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(labelText: _selected?.code ?? ''),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.arrow_forward_rounded),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${_converted.toStringAsFixed(2)} UZS',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final rate in _rates!)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () => setState(() => _selected = rate),
                selected: _selected?.code == rate.code,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rate.code, style: Theme.of(context).textTheme.titleSmall),
                          Text(rate.nameUz, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(rate.rate.toStringAsFixed(2), style: Theme.of(context).textTheme.titleSmall),
                        Row(
                          children: [
                            Icon(
                              rate.diff >= 0 ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                              color: rate.diff >= 0 ? colors.success : colors.error,
                              size: 18,
                            ),
                            Text(
                              rate.diff.abs().toStringAsFixed(2),
                              style: TextStyle(color: rate.diff >= 0 ? colors.success : colors.error, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
