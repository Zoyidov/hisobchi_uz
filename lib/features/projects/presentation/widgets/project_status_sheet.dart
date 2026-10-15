import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';
import '../../data/project_models.dart';
import '../../data/projects_repository.dart';

Future<bool?> showProjectStatusSheet(
  BuildContext context, {
  required Project project,
}) => showAppBottomSheet<bool>(
  context,
  title: 'Loyiha holati',
  subtitle: project.projectName,
  heightFactor: .75,
  child: _StatusSelection(project: project),
);

class _StatusSelection extends StatefulWidget {
  const _StatusSelection({required this.project});
  final Project project;
  @override
  State<_StatusSelection> createState() => _StatusSelectionState();
}

class _StatusSelectionState extends State<_StatusSelection> {
  late ProjectStatus _selected = widget.project.status;
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_saving || _selected == widget.project.status) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final result = await getIt<ProjectsRepository>().updateStatus(
      widget.project.id,
      _selected,
    );
    if (!mounted) return;
    result.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (failure) => setState(() {
        _saving = false;
        _error = failure.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopScope(
      canPop: !_saving,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Joriy holat: ${widget.project.status.label}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final status in ProjectStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _StatusOption(
                        status: status,
                        selected: status == _selected,
                        current: status == widget.project.status,
                        onTap: _saving
                            ? null
                            : () => setState(() {
                                _selected = status;
                                _error = null;
                              }),
                      ),
                    ),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: colors.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.borderSubtle)),
            ),
            child: AppButton.primary(
              label: _saving ? 'Yangilanmoqda…' : 'Holatni saqlash',
              isLoading: _saving,
              onPressed: _selected == widget.project.status ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.status,
    required this.selected,
    required this.current,
    required this.onTap,
  });
  final ProjectStatus status;
  final bool selected;
  final bool current;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (accent, icon, description) = switch (status) {
      ProjectStatus.inProgress => (
        colors.primary,
        Icons.play_arrow_rounded,
        'Loyiha bo‘yicha ishlar davom etmoqda',
      ),
      ProjectStatus.frozen => (
        colors.warning,
        Icons.pause_rounded,
        'Ishlar vaqtincha to‘xtatilgan',
      ),
      ProjectStatus.completed => (
        colors.success,
        Icons.check_rounded,
        'Loyiha bo‘yicha ishlar yakunlangan',
      ),
    };
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? Color.alphaBlend(accent.withValues(alpha: .07), colors.surface)
            : colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: selected ? accent : colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            status.label,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (current)
                            Text(
                              'Joriy',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(color: accent),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? accent : colors.textTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
