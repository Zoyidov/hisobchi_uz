import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/inputs/app_phone_field.dart';
import 'position_selection_sheet.dart';
import 'project_worker_assignment_sheet.dart';
import '../../data/projects_repository.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../documents/data/document_models.dart';
import '../../../documents/data/documents_repository.dart';

Future<Worker?> showWorkerSelectionSheet(
  BuildContext context, {
  int? selectedId,
  int? projectId,
}) => showAppBottomSheet<Worker>(
  context,
  title: 'Ishchini tanlang',
  heightFactor: .7,
  child: _WorkerSelection(selectedId: selectedId, projectId: projectId),
);

class _WorkerSelection extends StatefulWidget {
  const _WorkerSelection({this.selectedId, this.projectId});
  final int? selectedId;
  final int? projectId;
  @override
  State<_WorkerSelection> createState() => _WorkerSelectionState();
}

class _WorkerSelectionState extends State<_WorkerSelection> {
  List<Worker> _items = [];
  String _query = '';
  bool _loading = true;
  bool _creating = false;
  Failure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    final result = widget.projectId == null
        ? await getIt<DocumentsRepository>().getWorkers()
        : (await getIt<ProjectsRepository>().getProjectWorkers(
            widget.projectId!,
          )).when(
            success: (items) => ApiResult<List<Worker>>.success(
              items
                  .map(
                    (item) => Worker(
                      id: item.id,
                      name: item.name,
                      phone: item.phone ?? '',
                      positionName: item.positionName,
                    ),
                  )
                  .toList(),
            ),
            failure: (failure) => ApiResult<List<Worker>>.failure(failure),
          );
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.when(
        success: (items) =>
            _items = items.where((item) => !item.isDeleted).toList(),
        failure: (failure) => _failure = failure,
      );
    });
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    final created = await showWorkerCreateSheet(context, initialName: _query);
    if (!mounted) return;
    setState(() => _creating = false);
    if (created != null) {
      if (widget.projectId != null) {
        setState(() => _creating = true);
        final result = await getIt<ProjectsRepository>().addWorkersToProject(
          widget.projectId!,
          [created.id],
        );
        if (!mounted) return;
        setState(() => _creating = false);
        if (!result.isSuccess) {
          result.when(
            success: (_) {},
            failure: (failure) => AppSnackbar.error(context, failure.message),
          );
          return;
        }
        getIt<DataRefreshBus>().notifyProjectsChanged(
          projectId: widget.projectId,
        );
      }
      Navigator.of(context).pop(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items
        .where(
          (item) =>
              (item.name.toLowerCase().contains(_query.toLowerCase()) ||
              item.phone.contains(_query)),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _query = value.trim()),
                  decoration: const InputDecoration(
                    hintText: 'Ism yoki telefon orqali qidirish',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Yangi ishchi yaratish',
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _creating ? null : _create,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        if (widget.projectId != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.group_add_outlined, size: 19),
                label: const Text('Loyihaga xodim biriktirish'),
                onPressed: _creating
                    ? null
                    : () async {
                        final assigned = await showProjectWorkerAssignmentSheet(
                          context,
                          projectId: widget.projectId!,
                        );
                        if (assigned == true && mounted) await _load();
                      },
              ),
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _failure != null
              ? AppErrorState(failure: _failure, onRetry: _load)
              : items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 36,
                          color: context.colors.textTertiary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _query.isEmpty
                              ? 'Ishchilar hali mavjud emas'
                              : 'Ishchi topilmadi',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _creating ? null : _create,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Yangi ishchi yaratish'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: context.colors.divider),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(item.name),
                      subtitle: Text(PhoneFormatter.toDisplay(item.phone)),
                      trailing: item.id == widget.selectedId
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: context.colors.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

Future<Worker?> showWorkerCreateSheet(
  BuildContext context, {
  String initialName = '',
}) => showModalBottomSheet<Worker>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.colors.surface,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => _WorkerForm(initialName: initialName),
);

class _WorkerForm extends StatefulWidget {
  const _WorkerForm({required this.initialName});
  final String initialName;
  @override
  State<_WorkerForm> createState() => _WorkerFormState();
}

class _WorkerFormState extends State<_WorkerForm> {
  late final _name = TextEditingController(text: widget.initialName);
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _additionalPhone = TextEditingController();
  SimpleDocument? _position;
  String? _positionError;
  String? _additionalPhoneError;
  String? _descriptionError;
  String? _formError;
  String? _phoneError;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _additionalPhone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _error = _name.text.trim().isEmpty ? 'Ishchi ismini kiriting' : null;
      _phoneError = Validators.phone(_phone.text);
      _additionalPhoneError = _additionalPhone.text.isEmpty
          ? null
          : Validators.phone(_additionalPhone.text);
      _positionError = _position == null ? 'Lavozimni tanlang' : null;
      _formError = null;
      _descriptionError = null;
    });
    if (_error != null ||
        _phoneError != null ||
        _additionalPhoneError != null ||
        _positionError != null) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await getIt<DocumentsRepository>().createWorker(
      name: _name.text.trim(),
      phone: _phone.text,
      additionalPhone: _additionalPhone.text.isEmpty
          ? null
          : _additionalPhone.text,
      positionId: _position!.id,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
    );
    if (!mounted) return;
    result.when(
      success: (item) {
        getIt<DataRefreshBus>().notifyDocumentsChanged();
        Navigator.of(context).pop(item);
      },
      failure: (failure) => setState(() {
        _saving = false;
        if (failure is ValidationFailure) {
          _phoneError = _translateError(failure.fieldErrors['phone']);
          _additionalPhoneError = _translateError(
            failure.fieldErrors['additional_phone'],
          );
          _positionError = _translateError(
            failure.fieldErrors['worker_position_id'],
          );
          _descriptionError = _translateError(
            failure.fieldErrors['description'],
          );
          _error = _translateError(failure.fieldErrors['name']);
          if ([
            _phoneError,
            _additionalPhoneError,
            _positionError,
            _descriptionError,
            _error,
          ].every((error) => error == null)) {
            _formError = failure.message;
          }
        } else {
          _formError = failure.message;
        }
      }),
    );
  }

  String? _translateError(String? message) {
    if (message == null) return null;
    final lower = message.toLowerCase();
    if (lower.contains('already') && lower.contains('taken')) {
      return 'Bu ma’lumot allaqachon ro‘yxatdan o‘tgan';
    }
    if (lower.contains('required')) return 'Bu maydonni to‘ldiring';
    if (lower.contains('invalid')) return 'Kiritilgan ma’lumot noto‘g‘ri';
    return message;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Yangi ishchi',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Yopish',
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              enabled: !_saving,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                labelText: 'Ism *',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: context.colors.primary,
                ),
                hintText: 'Ishchining ismi',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 14),
            AbsorbPointer(
              absorbing: _saving,
              child: AppPhoneField(
                controller: _phone,
                label: 'Telefon *',
                errorText: _phoneError,
                onChanged: (_) => setState(() => _phoneError = null),
              ),
            ),
            const SizedBox(height: 14),
            AbsorbPointer(
              absorbing: _saving,
              child: AppPhoneField(
                controller: _additionalPhone,
                label: 'Qo‘shimcha telefon (ixtiyoriy)',
                errorText: _additionalPhoneError,
                onChanged: (_) => setState(() => _additionalPhoneError = null),
              ),
            ),
            const SizedBox(height: 14),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _saving
                  ? null
                  : () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      final position = await showPositionSelectionSheet(
                        context,
                        selectedId: _position?.id,
                      );
                      if (position != null && mounted) {
                        setState(() {
                          _position = position;
                          _positionError = null;
                        });
                      }
                    },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Lavozim *',
                  errorText: _positionError,
                  prefixIcon: Icon(
                    Icons.work_outline_rounded,
                    color: context.colors.accentViolet,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(_position?.name ?? 'Lavozimni tanlang'),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: context.colors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _description,
              enabled: !_saving,
              minLines: 2,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Izoh (ixtiyoriy)',
                hintText: 'Qo‘shimcha ma’lumot',
                errorText: _descriptionError,
              ),
            ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              Text(
                _formError!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.colors.error),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, size: 20),
              label: Text(_saving ? 'Saqlanmoqda…' : 'Yaratish va tanlash'),
            ),
          ],
        ),
      ),
    ),
  );
}
