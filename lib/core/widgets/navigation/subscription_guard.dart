import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/subscription_cubit.dart';

/// READ_ONLY/ARCHIVED holatda create/edit/delete/payment tugmalarini yashiradi
/// (MOBILE_APP_TZ.md 4.6, E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 78, 110).
class SubscriptionActionGuard extends StatelessWidget {
  const SubscriptionActionGuard({
    super.key,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  final Widget child;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionStatus>(
      builder: (context, status) {
        final canMutate =
            status == SubscriptionStatus.active || status == SubscriptionStatus.gracePeriod;
        return canMutate ? child : fallback;
      },
    );
  }
}
