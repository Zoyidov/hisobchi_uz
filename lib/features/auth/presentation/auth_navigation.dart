import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/cubits/auth_cubit.dart';
import '../../../core/cubits/owner_context_cubit.dart';
import '../../../core/cubits/user_cubit.dart';
import '../../../core/router/route_paths.dart';

/// Register/Login/ResetPassword muvaffaqiyatidan keyingi umumiy oqim:
/// token saqlash → `me()` → pincode taklifi (MOBILE_APP_TZ.md 5.5–5.6, 5.8).
abstract final class AuthNavigation {
  static Future<void> completeAuthAndOfferPincode(BuildContext context, String token) async {
    await context.read<AuthCubit>().onLoginSuccess(token);
    if (!context.mounted) return;
    await context.read<UserCubit>().loadMe();
    if (!context.mounted) return;
    context.go(RoutePaths.pincodeSetup);
  }

  /// Pincode ekrani (saqlangan yoki o'tkazib yuborilgan) yakunidan keyin —
  /// hisob tanlash kerakmi yoki to'g'ridan-to'g'ri dashboard (MOBILE_APP_TZ.md 6.2).
  static void goToNextAfterPincode(BuildContext context) {
    final user = context.read<UserCubit>().currentUserOrNull;
    if (user == null) {
      context.go(RoutePaths.phone);
      return;
    }
    if (user.hasMultipleContexts) {
      context.go(RoutePaths.accountSelection);
      return;
    }
    if (user.isStaff && user.worksFor.isNotEmpty) {
      context.read<OwnerContextCubit>().switchTo(
            OwnerContext(ownerId: user.worksFor.first.ownerId, ownerName: user.worksFor.first.ownerName),
          );
    }
    context.go(RoutePaths.dashboard);
  }
}
