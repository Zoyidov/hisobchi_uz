import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters/phone_formatter.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/sheets/app_confirmation_sheet.dart';
import '../../../../core/widgets/states/app_empty_state.dart';
import '../../../../core/widgets/states/app_error_state.dart';
import '../../../../core/widgets/states/app_skeleton.dart';
import '../../data/staff_models.dart';
import '../../data/staff_repository.dart';
import '../cubit/staff_list_cubit.dart';
import 'staff_create_page.dart';
import 'staff_edit_page.dart';

/// Xodimlar ro'yxati — faqat owner (MOBILE_APP_TZ.md 15.2).
class StaffListPage extends StatelessWidget {
  const StaffListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StaffListCubit(getIt<StaffRepository>())..load(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xodimlar')),
      body: BlocBuilder<StaffListCubit, StaffListState>(
        builder: (context, state) {
          return switch (state) {
            StaffListLoading() => const AppSkeletonList(),
            StaffListError(:final failure) =>
              AppErrorState(failure: failure, onRetry: () => context.read<StaffListCubit>().load()),
            StaffListLoaded(:final items) => items.isEmpty
                ? AppEmptyState(
                    title: 'Xodimlar yo\'q',
                    actionLabel: 'Xodim qo\'shish',
                    onAction: () => _openCreate(context),
                  )
                : RefreshIndicator(
                    onRefresh: () => context.read<StaffListCubit>().load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, i) => _StaffTile(staff: items[i]),
                    ),
                  ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('Xodim'),
      ),
    );
  }

  Future<void> _openCreate(BuildContext context) async {
    final cubit = context.read<StaffListCubit>();
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StaffCreatePage()));
    cubit.load();
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({required this.staff});
  final StaffMember staff;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: () async {
        await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => StaffEditPage(staff: staff)));
        if (context.mounted) context.read<StaffListCubit>().load();
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name, style: Theme.of(context).textTheme.titleSmall),
                Text(PhoneFormatter.toDisplay(staff.phone), style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${staff.permissions.length} ta ruxsat', style: TextStyle(color: colors.textTertiary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: staff.isActive,
                onChanged: (_) async {
                  final error = await context.read<StaffListCubit>().toggleActive(staff);
                  if (error != null && context.mounted) AppSnackbar.error(context, error.message);
                },
              ),
              Text(staff.isActive ? 'Faol' : 'Nofaol', style: TextStyle(fontSize: 11, color: colors.textTertiary)),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colors.error),
            onPressed: () async {
              final confirmed = await showAppConfirmationSheet(
                context,
                title: 'Xodim o\'chirilsinmi?',
                description: 'Bu amalni keyin qaytarib bo\'lmaydi.',
              );
              if (confirmed && context.mounted) {
                final error = await context.read<StaffListCubit>().delete(staff.id);
                if (error != null && context.mounted) AppSnackbar.error(context, error.message);
              }
            },
          ),
        ],
      ),
    );
  }
}
