import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/sheets/app_bottom_sheet.dart';

/// Senior-darajadagi to'lov provayderini tanlash bottom sheet'i.
/// Foydalanuvchiga Payme va Click tizimlari orqali to'lovni xavfsiz va qulay
/// amalga oshirish imkoniyatini taqdim etadi.
Future<String?> showPaymentProviderSheet(
  BuildContext context, {
  required String itemTitle,
  required String formattedPrice,
  String? itemSubtitle,
}) {
  return showAppBottomSheet<String>(
    context,
    title: 'To\'lov usuli',
    subtitle: 'O\'zingizga qulay to\'lov tizimini tanlang',
    child: _PaymentProviderSheetContent(
      itemTitle: itemTitle,
      formattedPrice: formattedPrice,
      itemSubtitle: itemSubtitle,
    ),
  );
}

class _PaymentProviderSheetContent extends StatelessWidget {
  const _PaymentProviderSheetContent({
    required this.itemTitle,
    required this.formattedPrice,
    this.itemSubtitle,
  });

  final String itemTitle;
  final String formattedPrice;
  final String? itemSubtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xs),

          // Order summary badge / card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (itemSubtitle != null && itemSubtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          itemSubtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Jami',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      formattedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Payme provider card
          _ProviderOptionCard(
            providerId: 'payme',
            name: 'Payme',
            subtitle: 'Uzcard, Humo, Visa, Mastercard',
            brandColor: const Color(0xFF00CCCC),
            logoWidget: _PaymeBadge(),
            onTap: () => Navigator.of(context).pop('payme'),
          ),

          const SizedBox(height: 10),

          // Click provider card
          _ProviderOptionCard(
            providerId: 'click',
            name: 'Click Up',
            subtitle: 'Click hamyon va bank kartalari',
            brandColor: const Color(0xFF0073FF),
            logoWidget: _ClickBadge(),
            onTap: () => Navigator.of(context).pop('click'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Security tag
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: colors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'To\'lov xavfsizligi kafolatlangan (256-bit SSL)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _ProviderOptionCard extends StatelessWidget {
  const _ProviderOptionCard({
    required this.providerId,
    required this.name,
    required this.subtitle,
    required this.brandColor,
    required this.logoWidget,
    required this.onTap,
  });

  final String providerId;
  final String name;
  final String subtitle;
  final Color brandColor;
  final Widget logoWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colors.border.withValues(alpha: 0.8),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: brandColor.withValues(alpha: 0.08),
        highlightColor: brandColor.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              logoWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: brandColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Tezkor',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: brandColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymeBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF00CCCC),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00CCCC).withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'payme',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: -0.4,
          ),
        ),
      ),
    );
  }
}

class _ClickBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFF0073FF),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0073FF).withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'click',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: -0.4,
          ),
        ),
      ),
    );
  }
}
