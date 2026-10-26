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
  static Future<void> completeAuthAndOfferPincode(
    BuildContext context,
    String token,
  ) async {
    await context.read<OwnerContextCubit>().reset();
    if (!context.mounted) return;
    context.read<UserCubit>().clear();
    await context.read<AuthCubit>().onLoginSuccess(token);
    if (!context.mounted) return;
    await context.read<UserCubit>().loadMe();
    if (!context.mounted) return;
    context.go(RoutePaths.pincodeSetup);
  }

  /// Pincode ekrani (saqlangan yoki o'tkazib yuborilgan) yakunidan keyin —
  /// hisob tanlash kerakmi yoki to'g'ridan-to'g'ri dashboard (MOBILE_APP_TZ.md 6.2).
  static Future<void> goToNextAfterPincode(BuildContext context) async {
    final user = context.read<UserCubit>().currentUserOrNull;
    if (user == null) {
      context.go(RoutePaths.accountSelection);
      return;
    }
    if (user.requiresAccountSelection) {
      context.go(RoutePaths.accountSelection);
      return;
    }
    await context.read<OwnerContextCubit>().switchTo(OwnerContext.own);
    if (!context.mounted) return;
    context.go(RoutePaths.dashboard);
  }

  /// Saqlangan sessiya: qayta hisob tanlatmay, oxirgi kontekstni tiklaydi.
  /// Ish joyi olib tashlangan bo'lsa, mavjud shaxsiy yoki ish hisobiga o'tadi.
  static Future<void> resumeSession(BuildContext context) async {
    final user = context.read<UserCubit>().currentUserOrNull;
    if (user == null) return;
    final ownerCubit = context.read<OwnerContextCubit>();
    await ownerCubit.restore();
    if (!context.mounted) return;
    final savedOwnerId = ownerCubit.state.ownerId;
    final workplaces = user.worksFor;
    final savedWorkplace = workplaces
        .where((work) => work.ownerId == savedOwnerId)
        .firstOrNull;
    if (savedWorkplace != null) {
      await ownerCubit.switchTo(
        OwnerContext(
          ownerId: savedWorkplace.ownerId,
          ownerName: savedWorkplace.ownerName,
        ),
      );
    } else if (user.isOwner) {
      await ownerCubit.switchTo(OwnerContext.own);
    } else if (workplaces.isNotEmpty) {
      final workplace = workplaces.first;
      await ownerCubit.switchTo(
        OwnerContext(
          ownerId: workplace.ownerId,
          ownerName: workplace.ownerName,
        ),
      );
    } else {
      // Faol hisob qolmagan: yangi login orqali hisobini ochishi mumkin.
      await context.read<AuthCubit>().logout();
      if (context.mounted) context.go(RoutePaths.phone);
      return;
    }
    if (context.mounted) context.go(RoutePaths.dashboard);
  }
}
