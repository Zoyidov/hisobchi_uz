import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/entities/app_file.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_phone_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/media/app_file_attachment.dart';
import '../../../documents/data/currency.dart';
import '../../../documents/data/documents_repository.dart';
import '../../data/partner_models.dart';
import '../../data/partners_repository.dart';
import '../cubit/partner_form_cubit.dart';

/// Hamkor yaratish/tahrirlash (MOBILE_APP_TZ.md 8.3).
class PartnerFormPage extends StatelessWidget {
  const PartnerFormPage({super.key, this.editing});

  final Partner? editing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PartnerFormCubit(getIt<PartnersRepository>()),
      child: _PartnerFormView(editing: editing),
    );
  }
}

class _PartnerFormView extends StatefulWidget {
  const _PartnerFormView({this.editing});
  final Partner? editing;

  @override
  State<_PartnerFormView> createState() => _PartnerFormViewState();
}

class _PartnerFormViewState extends State<_PartnerFormView> {
  late final _nameController = TextEditingController(
    text: widget.editing?.name,
  );
  late final _phoneController = TextEditingController(
    text: widget.editing?.phone,
  );
  late final _additionalPhoneController = TextEditingController(
    text: widget.editing?.additionalPhone,
  );
  late int _currencyTypeId =
      widget.editing?.mainCurrencyTypeId ?? Currency.uzs.id;
  List<AppFile> _files = [];
  bool _filesUploading = false;
  Map<String, String> _errors = {};
  List<Currency> _currencies = Currency.defaults;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _currencies = getIt<DocumentsRepository>().cachedCurrencies;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _additionalPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEditing ? 'Hamkorni tahrirlash' : 'Hamkor qo‘shish',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -.4,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<PartnerFormCubit, PartnerFormState>(
          listener: (context, state) {
            if (state is PartnerFormSuccess) {
              AppSnackbar.success(context, 'Saqlandi');
              context.pop(state.partner);
            } else if (state is PartnerFormValidationError) {
              setState(() => _errors = state.fieldErrors);
            } else if (state is PartnerFormLimitReached) {
              _showLimitDialog(context, state.message);
            } else if (state is PartnerFormFailed) {
              AppSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is PartnerFormSubmitting;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: isLoading,
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _nameController,
                                builder: (context, value, _) => Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: colors.primary.withValues(
                                        alpha: .1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: colors.surface,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: value.text.trim().isEmpty
                                            ? SizedBox(
                                                width: 44,
                                                height: 44,
                                                child: Icon(
                                                  Icons.person_outline_rounded,
                                                  color: colors.primary,
                                                  size: 28,
                                                ),
                                              )
                                            : AppAvatar(
                                                name: value.text.trim(),
                                                size: 44,
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              value.text.trim().isEmpty
                                                  ? 'Yangi hamkor'
                                                  : value.text.trim(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: -.3,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _isEditing
                                                  ? 'Ma’lumotlarni yangilash'
                                                  : 'Hamkor ma’lumotlarini kiriting',
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
                              ),
                              const SizedBox(height: 24),
                              _fieldLabel(context, 'Ism', required: true),
                              const SizedBox(height: 8),
                              AppTextField(
                                controller: _nameController,
                                hint: 'Hamkorning ismi yoki tashkilot nomi',
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: colors.textTertiary,
                                  size: 20,
                                ),
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                errorText: _errors['name'],
                                onChanged: (_) => _clearError('name'),
                              ),
                              const SizedBox(height: 18),
                              _fieldLabel(context, 'Telefon', required: true),
                              const SizedBox(height: 8),
                              AppPhoneField(
                                controller: _phoneController,
                                errorText: _errors['phone'],
                                onChanged: (_) => _clearError('phone'),
                              ),
                              const SizedBox(height: 18),
                              _fieldLabel(
                                context,
                                'Qo‘shimcha telefon',
                                optional: true,
                              ),
                              const SizedBox(height: 8),
                              AppPhoneField(
                                controller: _additionalPhoneController,
                              ),
                              const SizedBox(height: 24),
                              Divider(height: 1, color: colors.divider),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: _fieldLabel(
                                      context,
                                      'Asosiy valyuta',
                                    ),
                                  ),
                                  Icon(
                                    Icons.payments_outlined,
                                    color: colors.primary,
                                    size: 19,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final currencies = _currencies.isEmpty
                                      ? Currency.defaults
                                      : _currencies;
                                  final columns =
                                      constraints.maxWidth < 280 ||
                                          MediaQuery.textScalerOf(
                                                context,
                                              ).scale(14) >
                                              22
                                      ? 1
                                      : 2;
                                  return Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (final currency in currencies)
                                        SizedBox(
                                          width:
                                              (constraints.maxWidth -
                                                  (columns - 1) * 10) /
                                              columns,
                                          child: Material(
                                            color:
                                                _currencyTypeId == currency.id
                                                ? colors.primaryContainer
                                                : colors.surface,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              side: BorderSide(
                                                color:
                                                    _currencyTypeId ==
                                                        currency.id
                                                    ? colors.primary
                                                    : colors.border,
                                              ),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: InkWell(
                                              onTap: () => setState(
                                                () => _currencyTypeId =
                                                    currency.id,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 14,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        currency.name,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                              color:
                                                                  _currencyTypeId ==
                                                                      currency
                                                                          .id
                                                                  ? colors
                                                                        .primary
                                                                  : colors
                                                                        .textSecondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      _currencyTypeId ==
                                                              currency.id
                                                          ? Icons
                                                                .check_circle_rounded
                                                          : Icons
                                                                .circle_outlined,
                                                      size: 19,
                                                      color:
                                                          _currencyTypeId ==
                                                              currency.id
                                                          ? colors.primary
                                                          : colors.textTertiary,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: colors.border),
                                ),
                                child: ExpansionTile(
                                  maintainState: true,
                                  shape: const Border(),
                                  collapsedShape: const Border(),
                                  leading: Icon(
                                    Icons.attach_file_rounded,
                                    color: colors.primary,
                                    size: 21,
                                  ),
                                  title: Text(
                                    'Fayl biriktirish',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    'Ixtiyoriy',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: colors.textTertiary),
                                  ),
                                  childrenPadding: const EdgeInsets.fromLTRB(
                                    14,
                                    0,
                                    14,
                                    12,
                                  ),
                                  children: [
                                    AppFileAttachment(
                                      onUploadingChanged: (value) =>
                                          _filesUploading = value,
                                      uploadType: 'client',
                                      onFilesChanged: (files) => _files = files,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(
                          top: BorderSide(color: colors.borderSubtle),
                        ),
                      ),
                      child: AppButton.primary(
                        label: _isEditing
                            ? 'O‘zgarishlarni saqlash'
                            : 'Hamkorni qo‘shish',
                        icon: Icon(
                          _isEditing ? Icons.check_rounded : Icons.add_rounded,
                          size: 20,
                        ),
                        isLoading: isLoading,
                        onPressed: () => _submit(context),
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

  void _clearError(String field) {
    if (_errors.containsKey(field)) setState(() => _errors.remove(field));
  }

  Widget _fieldLabel(
    BuildContext context,
    String label, {
    bool required = false,
    bool optional = false,
  }) => Row(
    children: [
      Flexible(
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      if (required) Text(' *', style: TextStyle(color: context.colors.primary)),
      if (optional) ...[
        const SizedBox(width: 8),
        Text(
          'Ixtiyoriy',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.colors.textTertiary),
        ),
      ],
    ],
  );

  void _submit(BuildContext context) {
    if (_filesUploading) {
      AppSnackbar.error(context, 'Fayl yuklanishini kuting, keyin saqlang.');
      return;
    }
    final phoneError = Validators.phone(_phoneController.text);
    final nameError = Validators.required(_nameController.text);
    setState(() {
      _errors = {
        if (nameError != null) 'name': nameError,
        if (phoneError != null) 'phone': phoneError,
      };
    });
    if (_errors.isNotEmpty) return;

    context.read<PartnerFormCubit>().submit(
      id: widget.editing?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text,
      additionalPhone: _additionalPhoneController.text,
      currencyTypeId: _currencyTypeId,
      fileIds: _files.isEmpty ? null : _files.map((f) => f.id).toList(),
    );
  }

  void _showLimitDialog(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limit tugagan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Yopish'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push(RoutePaths.profileSubscription);
            },
            child: const Text('Tariflarni ko\'rish'),
          ),
        ],
      ),
    );
  }
}
