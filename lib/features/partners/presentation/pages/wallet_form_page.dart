import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/entities/app_file.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
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
      extra: {
        'partner': resolved,
        'type': type,
        'editingWallet': editingWallet,
      },
    );
  }
  return null;
}

class WalletFormPage extends StatelessWidget {
  const WalletFormPage({
    super.key,
    required this.partner,
    this.lockedType,
    this.editingWallet,
  });

  final Partner partner;

  /// `credit` (Chiqim) | `debt` (Kirim) — berilsa segment qulflanadi.
  final String? lockedType;

  /// Berilsa — forma tahrirlash rejimida ochiladi (faqat `credit`, MOBILE_APP_TZ.md 8.8).
  final Wallet? editingWallet;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WalletFormCubit(getIt<WalletRepository>()),
      child: _WalletFormView(
        partner: partner,
        lockedType: lockedType,
        editingWallet: editingWallet,
      ),
    );
  }
}

class _WalletFormView extends StatefulWidget {
  const _WalletFormView({
    required this.partner,
    this.lockedType,
    this.editingWallet,
  });
  final Partner partner;
  final String? lockedType;
  final Wallet? editingWallet;

  @override
  State<_WalletFormView> createState() => _WalletFormViewState();
}

class _WalletFormViewState extends State<_WalletFormView> {
  late String _type =
      widget.editingWallet?.type ?? widget.lockedType ?? 'credit';
  late int _currencyTypeId =
      widget.editingWallet?.currencyTypeId ?? widget.partner.mainCurrencyTypeId;
  late final _amountController = TextEditingController(
    text: widget.editingWallet?.summa.toBigInt().toString(),
  );
  late final _descriptionController = TextEditingController(
    text: widget.editingWallet?.description,
  );
  late DateTime? _returnDate = widget.editingWallet?.returnDate;
  List<AppFile> _files = [];
  bool _filesUploading = false;
  String? _amountError;

  bool get _isEditing => widget.editingWallet != null;

  bool get _isExpense => _type == 'credit';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _smsWillSend =>
      _isExpense ? widget.partner.sendOnChiqim : widget.partner.sendOnKirim;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _isExpense ? colors.error : colors.success;
    final title = _isEditing
        ? 'Chiqimni tahrirlash'
        : (_isExpense ? 'Chiqim' : 'Kirim');
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
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
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: isLoading,
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppCard(
                                hasShadow: false,
                                padding: const EdgeInsets.all(12),
                                borderRadius: BorderRadius.circular(18),
                                child: Row(
                                  children: [
                                    AppAvatar(
                                      name: widget.partner.name,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.partner.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            PhoneFormatter.toDisplay(
                                              widget.partner.phone,
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: colors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.lockedType == null && !_isEditing) ...[
                                const SizedBox(height: 16),
                                AppSegmentedControl<String>(
                                  value: _type,
                                  segments: const [
                                    AppSegment(value: 'debt', label: 'Kirim'),
                                    AppSegment(
                                      value: 'credit',
                                      label: 'Chiqim',
                                    ),
                                  ],
                                  onChanged: (v) => setState(() => _type = v),
                                ),
                              ],
                              const SizedBox(height: 16),
                              AppCard(
                                hasShadow: false,
                                padding: const EdgeInsets.all(16),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: accent.withValues(alpha: .22),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.alphaBlend(
                                      accent.withValues(alpha: .1),
                                      colors.surface,
                                    ),
                                    colors.surface,
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: accent.withValues(
                                              alpha: .12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            _isExpense
                                                ? Icons.north_east_rounded
                                                : Icons.south_west_rounded,
                                            color: accent,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '$_typeLabel summasi',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        for (final c in Currency.defaults.where(
                                          (c) => c.id == 1 || c.id == 2,
                                        ))
                                          ChoiceChip(
                                            label: Text(c.name),
                                            selected: _currencyTypeId == c.id,
                                            showCheckmark: false,
                                            selectedColor: accent.withValues(
                                              alpha: .16,
                                            ),
                                            labelStyle: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: _currencyTypeId == c.id
                                                      ? accent
                                                      : colors.textSecondary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            side: BorderSide(
                                              color: _currencyTypeId == c.id
                                                  ? accent.withValues(
                                                      alpha: .35,
                                                    )
                                                  : colors.border,
                                            ),
                                            onSelected: (_) => setState(
                                              () => _currencyTypeId = c.id,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    AppMoneyField(
                                      controller: _amountController,
                                      currencyLabel: Currency.defaults
                                          .firstWhere(
                                            (c) => c.id == _currencyTypeId,
                                          )
                                          .name,
                                      errorText: _amountError,
                                      autofocus: true,
                                      onChanged: (_) =>
                                          setState(() => _amountError = null),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppCard(
                                hasShadow: false,
                                padding: const EdgeInsets.all(14),
                                borderRadius: BorderRadius.circular(18),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Qo‘shimcha ma’lumot',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _descriptionController,
                                      maxLines: 3,
                                      minLines: 1,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        labelText: 'Izoh',
                                        hintText: 'To‘lov haqida qisqacha',
                                        prefixIcon: const Icon(
                                          Icons.notes_rounded,
                                          size: 20,
                                        ),
                                        filled: true,
                                        fillColor: colors.surfaceSecondary
                                            .withValues(alpha: .5),
                                      ),
                                    ),
                                    if (_isExpense) ...[
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event_outlined,
                                            size: 17,
                                            color: colors.info,
                                          ),
                                          const SizedBox(width: 7),
                                          Expanded(
                                            child: Text(
                                              'Qaytarish sanasi',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelLarge,
                                            ),
                                          ),
                                          if (_returnDate != null)
                                            IconButton(
                                              tooltip: 'Sanani olib tashlash',
                                              visualDensity:
                                                  VisualDensity.compact,
                                              icon: const Icon(
                                                Icons.close_rounded,
                                                size: 18,
                                              ),
                                              onPressed: () => setState(
                                                () => _returnDate = null,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          _dateChip(
                                            '1 hafta',
                                            () => _setReturnDate(
                                              const Duration(days: 7),
                                            ),
                                            selected: _matchesDays(7),
                                          ),
                                          _dateChip(
                                            '2 hafta',
                                            () => _setReturnDate(
                                              const Duration(days: 14),
                                            ),
                                            selected: _matchesDays(14),
                                          ),
                                          _dateChip(
                                            '1 oy',
                                            () => _setReturnDate(
                                              const Duration(days: 30),
                                            ),
                                            selected: _matchesDays(30),
                                          ),
                                          _dateChip(
                                            _returnDate != null
                                                ? AppDateFormatter.display(
                                                    _returnDate!,
                                                  )
                                                : 'Sana tanlash',
                                            () => _pickDate(context),
                                            selected: _returnDate != null,
                                          ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 12),
                                    AppFileAttachment(
                                      onUploadingChanged: (value) =>
                                          _filesUploading = value,
                                      uploadType: 'transaction',
                                      onFilesChanged: (files) => _files = files,
                                    ),
                                  ],
                                ),
                              ),
                              if (_smsWillSend) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sms_outlined,
                                      size: 16,
                                      color: colors.info,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Hamkorga SMS xabar yuboriladi',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.textSecondary,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(
                          top: BorderSide(color: colors.borderSubtle),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: isLoading ? null : () => _submit(context),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            isLoading
                                ? 'Saqlanmoqda…'
                                : (_isEditing
                                      ? 'Saqlash'
                                      : '$_typeLabel'
                                            'ni saqlash'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String get _typeLabel => _isExpense ? 'Chiqim' : 'Kirim';

  bool _matchesDays(int days) {
    if (_returnDate == null) return false;
    final expected = DateTime.now().add(Duration(days: days));
    return _returnDate!.year == expected.year &&
        _returnDate!.month == expected.month &&
        _returnDate!.day == expected.day;
  }

  Widget _dateChip(String label, VoidCallback onTap, {bool selected = false}) {
    final colors = context.colors;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: colors.info.withValues(alpha: .12),
      labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: selected ? colors.info : colors.textSecondary,
      ),
      side: BorderSide(
        color: selected ? colors.info.withValues(alpha: .3) : colors.border,
      ),
      onSelected: (_) => onTap(),
    );
  }

  void _setReturnDate(Duration duration) =>
      setState(() => _returnDate = DateTime.now().add(duration));

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && mounted) setState(() => _returnDate = picked);
  }

  void _submit(BuildContext context) {
    if (_filesUploading) {
      AppSnackbar.error(context, 'Fayl yuklanishini kuting, keyin saqlang.');
      return;
    }
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
