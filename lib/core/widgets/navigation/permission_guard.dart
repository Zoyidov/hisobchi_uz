import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/owner_context_cubit.dart';
import '../../cubits/user_cubit.dart';

/// Ruxsat yo'q bo'lsa komponent umuman ko'rsatilmaydi (disabled emas) —
/// MOBILE_APP_TZ.md 6.5, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 109, 164.
class PermissionGuard extends StatelessWidget {
  const PermissionGuard({
    super.key,
    required String permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  })  : permission = permission,
        anyOf = null;

  /// Bir nechta ruxsatdan **kamida bittasi** yetarli bo'lganda ishlatiladi.
  const PermissionGuard.any({
    super.key,
    required List<String> permissions,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  })  : permission = null,
        anyOf = permissions;

  final String? permission;
  final List<String>? anyOf;
  final Widget child;
  final Widget fallback;

  static bool hasPermission(BuildContext context, String permission) {
    final user = context.read<UserCubit>().currentUserOrNull;
    if (user == null) return false;
    final ownerContext = context.read<OwnerContextCubit>().state;
    return user.hasPermission(permission, ownerContext);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        return BlocBuilder<OwnerContextCubit, OwnerContext>(
          builder: (context, ownerContext) {
            final user = userState is UserLoaded ? userState.user : null;
            if (user == null) return fallback;

            final allowed = anyOf != null
                ? anyOf!.any((p) => user.hasPermission(p, ownerContext))
                : user.hasPermission(permission!, ownerContext);

            return allowed ? child : fallback;
          },
        );
      },
    );
  }
}
