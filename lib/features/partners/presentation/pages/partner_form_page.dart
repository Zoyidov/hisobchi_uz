import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/entities/app_file.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_phone_field.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/media/app_file_attachment.dart';
import '../../../documents/data/currency.dart';
import '../../../documents/data/documents_repository.dart';
import '../../../documents/presentation/currency_selection_sheet.dart';
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
  late final _nameController = TextEditingController(text: widget.editing?.name);
  late final _phoneController = TextEditingController(text: widget.editing?.phone);
  late final _additionalPhoneController = TextEditingController(text: widget.editing?.additionalPhone);
  late int _currencyTypeId = widget.editing?.mainCurrencyTypeId ?? Currency.uzs.id;
  List<AppFile> _files = [];
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
      appBar: AppBar(title: Text(_isEditing ? 'Hamkorni tahrirlash' : 'Hamkor qo\'shish')),
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Ism',
                    textCapitalization: TextCapitalization.words,
                    errorText: _errors['name'],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppPhoneField(controller: _phoneController, label: 'Telefon', errorText: _errors['phone']),
                  const SizedBox(height: AppSpacing.md),
                  AppPhoneField(controller: _additionalPhoneController, label: 'Qo\'shimcha telefon'),
                  const SizedBox(height: AppSpacing.md),
                  Text('Asosiy valyuta', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final selected = await showCurrencySelectionSheet(
                        context,
                        currencies: _currencies,
                        selectedId: _currencyTypeId,
                      );
                      if (selected != null) setState(() => _currencyTypeId = selected.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border.withValues(alpha: 0.9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currencies.firstWhere((c) => c.id == _currencyTypeId, orElse: () => Currency.uzs).name,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Icon(Icons.unfold_more_rounded, color: colors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Fayllar', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  AppFileAttachment(onFilesChanged: (files) => _files = files),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(
                    label: 'Saqlash',
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

  void _submit(BuildContext context) {
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
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Yopish')),
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
