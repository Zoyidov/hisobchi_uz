import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/events/data_refresh_bus.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/staff_models.dart';
import '../../data/staff_repository.dart';
import '../widgets/permission_group_list.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Xodim ruxsatlarini tahrirlash — saqlashda tokenlari o'chiriladi
/// (MOBILE_APP_TZ.md 15.2: "ogohlantirish ko'rsatiladi").
class StaffEditPage extends StatefulWidget {
  const StaffEditPage({super.key, required this.staff});

  final StaffMember staff;

  @override
  State<StaffEditPage> createState() => _StaffEditPageState();
}

class _StaffEditPageState extends State<StaffEditPage> {
  List<PermissionGroup>? _groups;
  late final Set<String> _selected = Set.of(widget.staff.permissions);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<StaffRepository>().getPermissionGroups();
    if (!mounted) return;
    setState(() => _groups = result.dataOrNull ?? []);
  }

  void _toggle(String key) {
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  void _toggleCategory(PermissionGroup group, bool selectAll) {
    setState(() {
      for (final item in group.items) {
        if (selectAll) {
          _selected.add(item.key);
        } else {
          _selected.remove(item.key);
        }
      }
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      AppSnackbar.error(context, context.l10n.staffMinOnePermission);
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.staffUpdatePermissions),
        content: Text(context.l10n.staffUpdatePermissionsWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.commonContinue),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    final result = await getIt<StaffRepository>().updateStaff(
      widget.staff.id,
      permissions: _selected.toList(),
      isActive: widget.staff.isActive,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      success: (_) {
        getIt<DataRefreshBus>().notifyStaffChanged();
        AppSnackbar.success(context, context.l10n.commonSaved);
        Navigator.of(context).pop();
      },
      failure: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.staff.name)),
      body: _groups == null
          ? const AppSkeletonList()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PermissionGroupList(
                    groups: _groups!,
                    selected: _selected,
                    onToggle: _toggle,
                    onToggleCategory: _toggleCategory,
                  ),
                  AppButton.primary(
                    label: context.l10n.commonSave,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
