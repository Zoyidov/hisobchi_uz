import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/connectivity_cubit.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// "Offline — oxirgi ma'lumotlar ko'rsatilmoqda" (MOBILE_APP_TZ.md 4.11, 71,
/// E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 107).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, bool>(
      builder: (context, isOnline) {
        if (isOnline) return const SizedBox.shrink();
        final colors = context.colors;
        return Container(
          width: double.infinity,
          color: colors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 16, color: colors.background),
              const SizedBox(width: 6),
              Text(
                'Offline — oxirgi ma\'lumotlar ko\'rsatilmoqda',
                style: TextStyle(color: colors.background, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
