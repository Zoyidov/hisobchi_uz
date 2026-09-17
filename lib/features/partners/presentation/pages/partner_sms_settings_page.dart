import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/misc/app_segmented_control.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/partners_repository.dart';
import '../../data/sms_models.dart';

/// SMS sozlamalari — hamkor bo'yicha (MOBILE_APP_TZ.md 8.10).
class PartnerSmsSettingsPage extends StatefulWidget {
  const PartnerSmsSettingsPage({super.key, required this.partnerId});

  final int partnerId;

  @override
  State<PartnerSmsSettingsPage> createState() => _PartnerSmsSettingsPageState();
}

class _PartnerSmsSettingsPageState extends State<PartnerSmsSettingsPage> {
  PartnerSmsSettings? _settings;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _settings = null;
      _error = null;
    });
    final result = await getIt<PartnersRepository>().getSmsSettings(widget.partnerId);
    if (!mounted) return;
    result.when(
      success: (s) => setState(() => _settings = s),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  Future<void> _save(PartnerSmsSettings updated) async {
    setState(() {
      _settings = updated;
      _saving = true;
    });
    final result = await getIt<PartnersRepository>().updateSmsSettings(widget.partnerId, updated);
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      success: (_) => AppSnackbar.success(context, 'Saqlandi'),
      failure: (f) => AppSnackbar.error(context, f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SMS sozlamalari')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) return AppErrorState(title: 'Sozlamalarni yuklab bo\'lmadi', description: _error, onRetry: _load);
    final s = _settings;
    if (s == null) return const AppSkeletonList();

    final colors = context.colors;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('SMS xizmati'),
                value: s.enabled,
                onChanged: (v) => _save(s.copyWith(enabled: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Opacity(
          opacity: s.enabled ? 1 : 0.4,
          child: IgnorePointer(
            ignoring: !s.enabled || _saving,
            child: AppCard(
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Kirim qilinganda SMS'),
                    value: s.sendOnKirim,
                    onChanged: (v) => _save(s.copyWith(sendOnKirim: v)),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Chiqim qilinganda SMS'),
                    value: s.sendOnChiqim,
                    onChanged: (v) => _save(s.copyWith(sendOnChiqim: v)),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Muddatdan oldin eslatish', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        AppSegmentedControl<int>(
                          value: s.remindBeforeDays,
                          segments: s.remindBeforeOptions
                              .map((d) => AppSegment(value: d, label: '$d kun'))
                              .toList(),
                          onChanged: (v) => _save(s.copyWith(remindBeforeDays: v)),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Muddat kunida eslatish'),
                    value: s.sendOnDueDate,
                    onChanged: (v) => _save(s.copyWith(sendOnDueDate: v)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Muddatdan keyin', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        AppSegmentedControl<int>(
                          value: s.sendAfterDueDays,
                          segments: s.sendAfterOptions.map((d) => AppSegment(value: d, label: '$d kun')).toList(),
                          onChanged: (v) => _save(s.copyWith(sendAfterDueDays: v)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SMS yuborish vaqti'),
                        Text(s.sendDate, style: TextStyle(color: colors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
