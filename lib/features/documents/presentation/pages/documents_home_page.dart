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
import '../../../../core/icons/app_icons.dart';
import '../../../../core/localization/app_localization_extension.dart';

/// Profil → Ma'lumotnomalar (MOBILE_APP_TZ.md 11-bo'lim).
class DocumentsHomePage extends StatelessWidget {
  const DocumentsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = getIt<DocumentsRepository>();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.docReferenceBooks)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          AppGroupedSection(
            margin: EdgeInsets.zero,
            children: [
              AppGroupedTile(
                icon: AppIcons.tools,
                label: context.l10n.docWorkTypes,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SimpleDocumentListPage(
                      kind: SimpleDocumentKind.workType,
                      cubit: SimpleDocumentCubit(
                        fetchAll: repository.getWorkTypes,
                        create: (name, desc) => repository.createWorkType(
                          name: name,
                          description: desc,
                        ),
                        update: (id, name, desc) => repository.updateWorkType(
                          id,
                          name: name,
                          description: desc,
                        ),
                        delete: repository.deleteWorkType,
                        restore: repository.restoreWorkType,
                      ),
                    ),
                  ),
                ),
              ),
              AppGroupedTile(
                icon: AppIcons.payments,
                label: context.l10n.docCostTypes,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CostTypesPage(),
                  ),
                ),
              ),
              AppGroupedTile(
                icon: AppIcons.worker,
                label: context.l10n.docPositions,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SimpleDocumentListPage(
                      kind: SimpleDocumentKind.position,
                      cubit: SimpleDocumentCubit(
                        fetchAll: repository.getPositions,
                        create: (name, desc) => repository.createPosition(
                          name: name,
                          description: desc,
                        ),
                        update: (id, name, desc) => repository.updatePosition(
                          id,
                          name: name,
                          description: desc,
                        ),
                        delete: repository.deletePosition,
                        restore: repository.restorePosition,
                      ),
                    ),
                  ),
                ),
              ),
              AppGroupedTile(
                icon: AppIcons.worker,
                label: context.l10n.docWorkers,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const WorkersPage()),
                ),
              ),
              AppGroupedTile(
                icon: AppIcons.exchange,
                label: context.l10n.docCurrencyRates,
                onTap: () => context.push(RoutePaths.profileCurrency),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
