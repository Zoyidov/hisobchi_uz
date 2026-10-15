import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/media/app_avatar.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../documents/data/document_models.dart';
import '../../../documents/data/documents_repository.dart';
import '../../data/projects_repository.dart';
import 'worker_selection_sheet.dart';

Future<bool?> showProjectWorkerAssignmentSheet(
  BuildContext context, {
  required int projectId,
}) => showAppBottomSheet<bool>(
  context,
  title: 'Loyihaga xodim biriktirish',
  subtitle: 'Ushbu loyihaga biriktirilmagan ishchilar',
  heightFactor: .85,
  child: _Assignment(projectId: projectId),
);

class _Assignment extends StatefulWidget {
  const _Assignment({required this.projectId});
  final int projectId;
  @override
  State<_Assignment> createState() => _AssignmentState();
}

class _AssignmentState extends State<_Assignment> {
  final _selected = <int>{};
  List<Worker> _items = [];
  String _query = '';
  Failure? _failure;
  bool _loading = true;
  bool _saving = false;
  bool _creating = false;

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
    final result = await getIt<DocumentsRepository>().getWorkers(
      notInProjectId: widget.projectId,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      result.when(
        success: (items) {
          _items = items.where((item) => !item.isDeleted).toList();
          _selected.removeWhere((id) => !_items.any((item) => item.id == id));
        },
        failure: (failure) => _failure = failure,
      );
    });
  }

  Future<void> _create() async {
    if (_creating || _saving) return;
    setState(() => _creating = true);
    final created = await showWorkerCreateSheet(context, initialName: _query);
    if (!mounted) return;
    setState(() => _creating = false);
    if (created != null) {
      await _load();
      if (mounted && _items.any((item) => item.id == created.id)) {
        setState(() => _selected.add(created.id));
      }
    }
  }

  Future<void> _save() async {
    if (_saving || _selected.isEmpty) return;
    setState(() => _saving = true);
    final result = await getIt<ProjectsRepository>().addWorkersToProject(
      widget.projectId,
      _selected.toList(),
    );
    if (!mounted) return;
    result.when(
      success: (_) {
        getIt<DataRefreshBus>().notifyProjectsChanged(
          projectId: widget.projectId,
        );
        Navigator.of(context).pop(true);
      },
      failure: (failure) {
        setState(() => _saving = false);
        AppSnackbar.error(context, failure.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items
        .where(
          (item) => '${item.name} ${item.phone} ${item.positionName ?? ''}'
              .toLowerCase()
              .contains(_query.toLowerCase()),
        )
        .toList();
    return PopScope(
      canPop: !_saving,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: !_saving,
                    onChanged: (value) => setState(() => _query = value.trim()),
                    decoration: const InputDecoration(
                      hintText: 'Ism, telefon yoki lavozim',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Yangi ishchi yaratish',
                  onPressed: _saving || _creating ? null : _create,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
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
                      child: Text(
                        _query.isEmpty
                            ? 'Biriktirish uchun bo‘sh ishchi yo‘q. Yangi ishchi yaratish uchun + tugmasini bosing.'
                            : 'Ishchilar topilmadi',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final worker = items[index];
                      final selected = _selected.contains(worker.id);
                      return Material(
                        color: selected
                            ? context.colors.primaryContainer
                            : context.colors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: selected
                                ? context.colors.primary
                                : context.colors.border,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CheckboxListTile(
                          value: selected,
                          onChanged: _saving
                              ? null
                              : (value) => setState(() {
                                  if (value == true) {
                                    _selected.add(worker.id);
                                  } else {
                                    _selected.remove(worker.id);
                                  }
                                }),
                          secondary: AppAvatar(name: worker.name, size: 38),
                          title: Text(
                            worker.name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            [
                              PhoneFormatter.toDisplay(worker.phone),
                              if (worker.positionName?.isNotEmpty == true)
                                worker.positionName!,
                            ].join('\n'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: AppButton.primary(
              label: _saving
                  ? 'Biriktirilmoqda…'
                  : _selected.isEmpty
                  ? 'Xodimlarni tanlang'
                  : '${_selected.length} ta xodimni biriktirish',
              isLoading: _saving,
              onPressed: _selected.isEmpty || _loading || _creating
                  ? null
                  : _save,
            ),
          ),
        ],
      ),
    );
  }
}
