import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/inputs/app_phone_field.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/media/app_file_attachment.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';
import '../cubit/project_form_cubit.dart';

/// Loyiha yaratish/tahrirlash (MOBILE_APP_TZ.md 10.3).
class ProjectFormPage extends StatelessWidget {
  const ProjectFormPage({super.key, this.editing});

  final Project? editing;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectFormCubit(getIt<ProjectsRepository>()),
      child: _View(editing: editing),
    );
  }
}

class _View extends StatefulWidget {
  const _View({this.editing});
  final Project? editing;

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  late final _nameController = TextEditingController(
    text: widget.editing?.projectName,
  );
  late final _ownerController = TextEditingController(
    text: widget.editing?.projectOwner,
  );
  late final _phoneController = TextEditingController(
    text: _normalizePhone(widget.editing?.phone ?? ''),
  );
  late final _addressController = TextEditingController(
    text: widget.editing?.address,
  );
  Map<String, String> _errors = {};
  late List<int> _fileIds =
      widget.editing?.files.map((file) => file.id).toList() ?? [];
  bool _filesUploading = false;

  bool get _isEditing => widget.editing != null;

  static String _normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 12 && digits.startsWith('998')
        ? digits.substring(3)
        : digits;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _clearError(String field) {
    if (_errors.containsKey(field)) setState(() => _errors.remove(field));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _isEditing ? 'Loyihani tahrirlash' : 'Loyiha qo‘shish',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -.4,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<ProjectFormCubit, ProjectFormState>(
          listener: (context, state) {
            if (state is ProjectFormSuccess) {
              AppSnackbar.success(context, 'Saqlandi');
              Navigator.of(context).pop(state.project);
            } else if (state is ProjectFormValidationError) {
              setState(() => _errors = state.fieldErrors);
            } else if (state is ProjectFormLimitReached) {
              _showLimitDialog(context, state.message);
            } else if (state is ProjectFormFailed) {
              AppSnackbar.error(context, state.failure.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is ProjectFormSubmitting;
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
                              ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _nameController,
                                builder: (context, value, _) => Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors.primaryContainer,
                                        Color.alphaBlend(
                                          colors.accentViolet.withValues(
                                            alpha: .08,
                                          ),
                                          colors.surface,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: colors.primary.withValues(
                                            alpha: .12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.work_outline_rounded,
                                          color: colors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              value.text.trim().isEmpty
                                                  ? 'Yangi loyiha'
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
                                                  ? 'Loyiha ma’lumotlarini yangilang'
                                                  : 'Loyiha va buyurtmachi ma’lumotlari',
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
                              const SizedBox(height: 16),
                              AppCard(
                                hasShadow: false,
                                padding: const EdgeInsets.all(14),
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppTextField(
                                      controller: _nameController,
                                      label: 'Loyiha nomi *',
                                      hint: 'Masalan, yangi ofis qurilishi',
                                      prefixIcon: Icon(
                                        Icons.work_outline_rounded,
                                        size: 20,
                                        color: colors.primary,
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      textInputAction: TextInputAction.next,
                                      errorText: _errors['project_name'],
                                      onChanged: (_) =>
                                          _clearError('project_name'),
                                    ),
                                    const SizedBox(height: 18),
                                    Divider(height: 1, color: colors.divider),
                                    const SizedBox(height: 18),
                                    AppTextField(
                                      controller: _ownerController,
                                      label: 'Buyurtmachi *',
                                      hint: 'Ism yoki tashkilot nomi',
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        size: 20,
                                        color: colors.accentViolet,
                                      ),
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      errorText: _errors['project_owner'],
                                      onChanged: (_) =>
                                          _clearError('project_owner'),
                                    ),
                                    const SizedBox(height: 14),
                                    AppPhoneField(
                                      controller: _phoneController,
                                      label: 'Telefon *',
                                      errorText: _errors['phone'],
                                      onChanged: (_) => _clearError('phone'),
                                    ),
                                    const SizedBox(height: 14),
                                    AppTextField(
                                      controller: _addressController,
                                      label: 'Manzil (ixtiyoriy)',
                                      hint:
                                          'Shahar, ko‘cha yoki loyiha manzili',
                                      prefixIcon: Icon(
                                        Icons.location_on_outlined,
                                        size: 20,
                                        color: colors.info,
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Material(
                                color: colors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  side: BorderSide(color: colors.border),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: ExpansionTile(
                                  initiallyExpanded:
                                      widget.editing?.files.isNotEmpty == true,
                                  maintainState: true,
                                  shape: const Border(),
                                  collapsedShape: const Border(),
                                  leading: Icon(
                                    Icons.attach_file_rounded,
                                    color: colors.primary,
                                    size: 21,
                                  ),
                                  title: Text(
                                    'Fayllar va rasmlar',
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
                                      uploadType: 'project',
                                      initialFiles:
                                          widget.editing?.files ?? const [],
                                      onUploadingChanged: (value) {
                                        if (mounted) {
                                          setState(
                                            () => _filesUploading = value,
                                          );
                                        }
                                      },
                                      onFilesChanged: (files) => _fileIds =
                                          files.map((file) => file.id).toList(),
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
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        border: Border(
                          top: BorderSide(color: colors.borderSubtle),
                        ),
                      ),
                      child: AppButton.primary(
                        label: _filesUploading
                            ? 'Fayl yuklanmoqda…'
                            : _isEditing
                            ? 'Saqlash'
                            : 'Loyihani yaratish',
                        icon: Icon(
                          _isEditing ? Icons.check_rounded : Icons.add_rounded,
                          size: 20,
                        ),
                        isLoading: isLoading || _filesUploading,
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

  void _submit(BuildContext context) {
    if (context.read<ProjectFormCubit>().state is ProjectFormSubmitting) return;
    if (_filesUploading) {
      AppSnackbar.error(context, 'Fayl yuklanishini kuting, keyin saqlang.');
      return;
    }
    final nameError = Validators.required(_nameController.text);
    final ownerError = Validators.required(_ownerController.text);
    final phoneError = Validators.phone(_phoneController.text);
    setState(() {
      _errors = {
        if (nameError != null) 'project_name': nameError,
        if (ownerError != null) 'project_owner': ownerError,
        if (phoneError != null) 'phone': phoneError,
      };
    });
    if (_errors.isNotEmpty) return;

    context.read<ProjectFormCubit>().submit(
      id: widget.editing?.id,
      projectName: _nameController.text.trim(),
      projectOwner: _ownerController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      fileIds: _isEditing ? _fileIds : (_fileIds.isEmpty ? null : _fileIds),
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
