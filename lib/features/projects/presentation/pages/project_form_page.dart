import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
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
  late final _nameController = TextEditingController(text: widget.editing?.projectName);
  late final _ownerController = TextEditingController(text: widget.editing?.projectOwner);
  late final _phoneController = TextEditingController(text: widget.editing?.phone);
  late final _addressController = TextEditingController(text: widget.editing?.address);
  Map<String, String> _errors = {};
  List<int> _fileIds = [];

  bool get _isEditing => widget.editing != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Loyihani tahrirlash' : 'Loyiha qo\'shish')),
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
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(controller: _nameController, label: 'Loyiha nomi', errorText: _errors['project_name']),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(controller: _ownerController, label: 'Buyurtmachi', errorText: _errors['project_owner']),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(controller: _phoneController, label: 'Telefon', errorText: _errors['phone']),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(controller: _addressController, label: 'Manzil (ixtiyoriy)'),
                  const SizedBox(height: AppSpacing.md),
                  Text('Fayllar', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  AppFileAttachment(onFilesChanged: (files) => _fileIds = files.map((f) => f.id).toList()),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton.primary(label: 'Saqlash', isLoading: isLoading, onPressed: () => _submit(context)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final nameError = Validators.required(_nameController.text);
    final ownerError = Validators.required(_ownerController.text);
    final phoneError = Validators.required(_phoneController.text);
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
          fileIds: _fileIds.isEmpty ? null : _fileIds,
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
