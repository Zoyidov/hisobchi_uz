import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../../../core/widgets/states/app_skeleton.dart';

/// Mirrors the detail page rather than displaying generic full-width blocks.
class PartnerDetailSkeleton extends StatelessWidget {
  const PartnerDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      surfaceTintColor: Colors.transparent,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBox(width: 150, height: 17),
          SizedBox(height: 6),
          AppSkeletonBox(width: 115, height: 12),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
          child: Container(
            height: 44,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: AppSkeletonBox(height: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        AppCard(
          hasShadow: false,
          padding: const EdgeInsets.all(14),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              const Row(
                children: [
                  AppSkeletonBox(width: 38, height: 26),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBox(width: 75, height: 12),
                        SizedBox(height: 5),
                        AppSkeletonBox(width: 105, height: 10),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Flexible(child: AppSkeletonBox(width: 125, height: 24)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSecondary.withValues(alpha: .6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Expanded(child: _FlowSkeleton()),
                    SizedBox(width: 24),
                    Expanded(child: _FlowSkeleton()),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < 5; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      AppSkeletonBox(
                        width: 40,
                        height: 40,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      const SizedBox(height: 5),
                      const AppSkeletonBox(width: 42, height: 10),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const _FilterSkeleton(),
        const SizedBox(height: 12),
        for (var i = 0; i < 5; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: _TransactionSkeleton(),
          ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        color: context.colors.surface,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            for (var i = 0; i < 2; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == 0 ? 8 : 0),
                  child: AppSkeletonBox(
                    height: 44,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class TransactionListSkeleton extends StatelessWidget {
  const TransactionListSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: 6,
    separatorBuilder: (_, _) => const SizedBox(height: 8),
    itemBuilder: (_, _) => const _TransactionSkeleton(),
  );
}

class _TransactionSkeleton extends StatelessWidget {
  const _TransactionSkeleton();

  @override
  Widget build(BuildContext context) => AppCard(
    hasShadow: false,
    padding: const EdgeInsets.all(10),
    borderRadius: BorderRadius.circular(18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeletonBox(
          width: 32,
          height: 32,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppSkeletonBox(width: 46, height: 11),
                  Spacer(),
                  Flexible(child: AppSkeletonBox(width: 68, height: 10)),
                ],
              ),
              SizedBox(height: 6),
              AppSkeletonBox(width: 140, height: 18),
              SizedBox(height: 6),
              AppSkeletonBox(width: 100, height: 11),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FlowSkeleton extends StatelessWidget {
  const _FlowSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSkeletonBox(width: 48, height: 10),
      SizedBox(height: 5),
      AppSkeletonBox(height: 13),
    ],
  );
}

class _FilterSkeleton extends StatelessWidget {
  const _FilterSkeleton();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var i = 0; i < 3; i++)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: AppSkeletonBox(
              height: 32,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      const SizedBox(width: 6),
      AppSkeletonBox(
        width: 36,
        height: 36,
        borderRadius: BorderRadius.circular(12),
      ),
    ],
  );
}
