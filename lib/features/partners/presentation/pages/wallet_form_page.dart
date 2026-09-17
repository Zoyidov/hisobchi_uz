import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/entities/app_file.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_money_field.dart';
import '../../../../core/widgets/media/app_file_attachment.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../documents/data/currency.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../../data/wallet_repository.dart';
import '../cubit/wallet_form_cubit.dart';
import '../widgets/partner_search_sheet.dart';

/// Dashboard/hamkor kartochkasidan chaqiriladigan kirish nuqtasi — agar
/// `partner` berilmagan bo'lsa, avval qidiruvli tanlov sheeti ochiladi
/// (MOBILE_APP_TZ.md 8.7, "Oldindan to'ldirilgan").
Future<dynamic> showWalletFormSheet(
  BuildContext context, {
  required String type,
  int? partnerId,
  Partner? partner,
  Wallet? editingWallet,
}) async {
  var resolved = partner;
  if (resolved == null && partnerId != null) {
    final res = await getIt<PartnersRepository>().getPartner(partnerId);
    resolved = res.dataOrNull;
  }
  if (!context.mounted) return null;
  if (resolved == null) {
    resolved = await showPartnerSearchSheet(context);
    if (resolved == null || !context.mounted) return null;
  }
  if (context.mounted) {
    return context.push(
      RoutePaths.walletCreate(resolved.id),
      extra: {'partner': resolved, 'type': type, 'editingWallet': editingWallet},
    );
  }
  return null;
}

class WalletFormPage extends StatelessWidget {
  const WalletFormPage({super.key, required this.partner, this.lockedType, this.editingWallet});

  final Partner partner;

  /// `credit` (Chiqim) | `debt` (Kirim) — berilsa segment qulflanadi.
  final String? lockedType;

  /// Berilsa — forma tahrirlash rejimida ochiladi (faqat `credit`, MOBILE_APP_TZ.md 8.8).
  final Wallet? editingWallet;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletFormCubit(getIt<WalletRepository>()),
      child: _WalletFormView(partner: partner, lockedType: lockedType, editingWallet: editingWallet),
    );
  }
}

class _WalletFormView extends StatefulWidget {
  const _WalletFormView({required this.partner, this.lockedType, this.editingWallet});
  final Partner partner;
  final String? lockedType;
  final Wallet? editingWallet;

  @override
  State<_WalletFormView> createState() => _WalletFormViewState();
}

class _WalletFormViewState extends State<_WalletFormView> {
  late String _type = widget.editingWallet?.type ?? widget.lockedType ?? 'credit';
  late int _currencyTypeId = widget.editingWallet?.currencyTypeId ?? widget.partner.mainCurrencyTypeId;
  late final _amountController =
      TextEditingController(text: widget.editingWallet?.summa.toBigInt().toString());
  late final _descriptionController =
      TextEditingController(text: widget.editingWallet?.description);
  late DateTime? _returnDate = widget.editingWallet?.returnDate;
  List<AppFile> _files = [];
  String? _amountError;

  bool get _isEditing => widget.editingWallet != null;

  bool get _isExpense => _type == 'credit';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _smsWillSend => _isExpense ? widget.partner.sendOnChiqim : widget.partner.sendOnKirim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Chiqimni tahrirlash' : (_isExpense ? 'Chiqim' : 'Kirim'))),
      body: SafeArea(
        child: BlocConsumer<WalletFormCubit, WalletFormState>(
          listener: (context, state) {
            if (state is WalletFormSuccess) {
              AppSnackbar.success(context, 'Saqlandi');
              context.pop(state.wallet);
            } else if (state is WalletFormValidationError) {
              setState(() => _amountError = state.fieldErrors['summa']);
            } else if (state is WalletFormFailed) {
              AppSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is WalletFormSubmitting;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border.withValues(alpha: 0.8)),
                      boxShadow: colors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.partner.name.isNotEmpty ? widget.partner.name[0].toUpperCase() : '?',
                            style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.partner.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.partner.phone,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (widget.lockedType == null && !_isEditing)
                    AppSegmentedControl<String>(
                      value: _type,
                      segments: const [
                        AppSegment(value: 'debt', label: 'Kirim'),
                        AppSegment(value: 'credit', label: 'Chiqim'),
                      ],
                      onChanged: (v) => setState(() => _type = v),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  AppSegmentedControl<int>(
                    value: _currencyTypeId,
                    segments: const [
                      AppSegment(value: 1, label: 'UZS'),
                      AppSegment(value: 2, label: 'USD'),
                    ],
                    onChanged: (v) => setState(() => _currencyTypeId = v),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppMoneyField(
                    controller: _amountController,
                    currencyLabel: Currency.defaults.firstWhere((c) => c.id == _currencyTypeId).name,
                    errorText: _amountError,
                    autofocus: true,
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    minLines: 2,
                    decoration: const InputDecoration(labelText: 'Izoh'),
                  ),
                  if (_isExpense) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text('Qaytarish sanasi', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        _dateChip('1 hafta', () => _setReturnDate(const Duration(days: 7))),
                        _dateChip('2 hafta', () => _setReturnDate(const Duration(days: 14))),
                        _dateChip('1 oy', () => _setReturnDate(const Duration(days: 30))),
                        _dateChip(
                          _returnDate != null ? AppDateFormatter.display(_returnDate!) : 'Sana tanlash',
                          () => _pickDate(context),
                          selected: _returnDate != null,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppFileAttachment(onFilesChanged: (files) => _files = files),
                  if (_smsWillSend) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: colors.textTertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Hamkorga SMS xabar yuboriladi',
                            style: TextStyle(color: colors.textTertiary, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    label: _isEditing ? 'Saqlash' : (_isExpense ? 'Chiqimni saqlash' : 'Kirimni saqlash'),
                    isLoading: isLoading,
                    onPressed: () => _submit(context),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dateChip(String label, VoidCallback onTap, {bool selected = false}) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }

  void _setReturnDate(Duration duration) => setState(() => _returnDate = DateTime.now().add(duration));

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _returnDate = picked);
  }

  void _submit(BuildContext context) {
    final digits = _amountController.text;
    if (digits.isEmpty || (int.tryParse(digits) ?? 0) <= 0) {
      setState(() => _amountError = 'Summa 0 dan katta bo\'lishi kerak');
      return;
    }
    context.read<WalletFormCubit>().submit(
          editingWalletId: widget.editingWallet?.id,
          partnerId: widget.partner.id,
          currencyTypeId: _currencyTypeId,
          summa: Decimal.parse(digits),
          type: _type,
          description: _descriptionController.text,
          returnDate: _returnDate,
          fileIds: _files.isEmpty ? null : _files.map((f) => f.id).toList(),
        );
  }
}
