import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cards/app_grouped_section.dart';
import '../../data/documents_repository.dart';
import '../cubit/simple_document_cubit.dart';
import 'cost_types_page.dart';
import 'simple_document_list_page.dart';
import 'workers_page.dart';

/// Profil → Ma'lumotnomalar (MOBILE_APP_TZ.md 11-bo'lim).
class DocumentsHomePage extends StatelessWidget {
  const DocumentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = getIt<DocumentsRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ma\'lumotnomalar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xxl),
        children: [
          AppGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              AppGroupedTile(
                icon: Icons.build_outlined,
                label: 'Ish turlari',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => SimpleDocumentListPage(
                    title: 'Ish turlari',
                    entityLabel: 'Ish turi',
                    cubit: SimpleDocumentCubit(
                      fetchAll: repository.getWorkTypes,
                      create: (name, desc) => repository.createWorkType(name: name, description: desc),
                      update: (id, name, desc) => repository.updateWorkType(id, name: name, description: desc),
                      delete: repository.deleteWorkType,
                      restore: repository.restoreWorkType,
                    ),
                  ),
                )),
              ),
              AppGroupedTile(
                icon: Icons.payments_outlined,
                label: 'Xarajat turlari',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CostTypesPage())),
              ),
              AppGroupedTile(
                icon: Icons.badge_outlined,
                label: 'Lavozimlar',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => SimpleDocumentListPage(
                    title: 'Lavozimlar',
                    entityLabel: 'Lavozim',
                    cubit: SimpleDocumentCubit(
                      fetchAll: repository.getPositions,
                      create: (name, desc) => repository.createPosition(name: name, description: desc),
                      update: (id, name, desc) => repository.updatePosition(id, name: name, description: desc),
                      delete: repository.deletePosition,
                      restore: repository.restorePosition,
                    ),
                  ),
                )),
              ),
              AppGroupedTile(
                icon: Icons.engineering_outlined,
                label: 'Ishchilar',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WorkersPage())),
              ),
              AppGroupedTile(
                icon: Icons.currency_exchange_rounded,
                label: 'Valyuta kurslari',
                onTap: () => context.push(RoutePaths.profileCurrency),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
