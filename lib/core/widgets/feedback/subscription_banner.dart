import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/subscription_cubit.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Global obuna banneri — GRACE (sariq) / READ_ONLY (qizil) / ARCHIVED
/// (MOBILE_APP_TZ.md 4.6, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 65, 175).
class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key, this.onAction});

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionStatus>(
      builder: (context, status) {
        if (status == SubscriptionStatus.active || status == SubscriptionStatus.none) {
          return const SizedBox.shrink();
        }
        final colors = context.colors;
        final (color, icon, text, actionLabel) = switch (status) {
          SubscriptionStatus.gracePeriod => (
              colors.warning,
              Icons.warning_amber_rounded,
              'Obunangiz muddati tugash arafasida',
              'Yangilash',
            ),
          SubscriptionStatus.readOnly => (
              colors.error,
              Icons.lock_outline,
              'Faqat ko\'rish rejimi',
              'Tariflar',
            ),
          SubscriptionStatus.archived => (
              colors.error,
              Icons.lock_outline,
              'Obuna talab qilinadi',
              'Tariflar',
            ),
          _ => (colors.info, Icons.info_outline, '', ''),
        };

        return Container(
          margin: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
