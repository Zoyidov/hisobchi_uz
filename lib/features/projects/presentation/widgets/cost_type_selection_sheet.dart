import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../documents/data/document_models.dart';
import '../../../documents/data/documents_repository.dart';

Future<CostType?> showCostTypeSelectionSheet(
  BuildContext context, {
  int? selectedId,
}) => showAppBottomSheet<CostType>(
  context,
  title: 'Xarajat turini tanlang',
  heightFactor: .7,
  child: _CostTypeSelection(selectedId: selectedId),
);

class _CostTypeSelection extends StatefulWidget {
  const _CostTypeSelection({this.selectedId});
  final int? selectedId;
  @override
  State<_CostTypeSelection> createState() => _CostTypeSelectionState();
}

class _CostTypeSelectionState extends State<_CostTypeSelection> {
  List<CostType> _items = [];
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
    final result = await getIt<DocumentsRepository>().getCostTypes();
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
    final created = await showModalBottomSheet<CostType>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CostTypeForm(initialName: _query),
    );
    if (!mounted) return;
    setState(() => _creating = false);
    if (created != null) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items
        .where((item) => item.name.toLowerCase().contains(_query.toLowerCase()))
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
                    hintText: 'Xarajat turini qidirish',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Yangi xarajat turi yaratish',
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
                              ? 'Xarajat turlari hali mavjud emas'
                              : 'Xarajat turi topilmadi',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _creating ? null : _create,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Yangi xarajat turi yaratish'),
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
                      subtitle: item.description?.isNotEmpty == true
                          ? Text(item.description!)
                          : null,
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

class _CostTypeForm extends StatefulWidget {
  const _CostTypeForm({required this.initialName});
  final String initialName;
  @override
  State<_CostTypeForm> createState() => _CostTypeFormState();
}

class _CostTypeFormState extends State<_CostTypeForm> {
  late final _name = TextEditingController(text: widget.initialName);
  final _description = TextEditingController();
  bool _saving = false;
  bool _isWorkerJoin = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Xarajat turi nomini kiriting');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await getIt<DocumentsRepository>().createCostType(
      name: _name.text.trim(),
      isWorkerJoin: _isWorkerJoin,
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
        _error = failure is ValidationFailure
            ? failure.fieldErrors['name'] ?? failure.message
            : failure.message;
      }),
    );
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
                    'Yangi xarajat turi',
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
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Xarajat turi nomi',
                hintText: 'Masalan, asbob-uskunalar',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _description,
              enabled: !_saving,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Tavsif (ixtiyoriy)',
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: context.colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: const Text('Ishchiga bog‘lash'),
                subtitle: const Text(
                  'Yoqilsa, xarajat kiritishda ishchi tanlanadi',
                ),
                value: _isWorkerJoin,
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _isWorkerJoin = value),
              ),
            ),
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
