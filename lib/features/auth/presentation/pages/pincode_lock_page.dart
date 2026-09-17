import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/auth_cubit.dart';
import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../auth_navigation.dart';
import '../cubit/pincode_lock_cubit.dart';
import '../widgets/pincode_widgets.dart';

/// PIN bilan qulflash ekrani — 5 xato urinishdan keyin parolga majburiy
/// o'tkaziladi (MOBILE_APP_TZ.md 5.8).
class PincodeLockPage extends StatelessWidget {
  const PincodeLockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PincodeLockCubit(getIt<SecureStorageService>()),
      child: const _PincodeLockView(),
    );
  }
}

class _PincodeLockView extends StatefulWidget {
  const _PincodeLockView();

  @override
  State<_PincodeLockView> createState() => _PincodeLockViewState();
}

class _PincodeLockViewState extends State<_PincodeLockView> {
  String _code = '';
  final _capsulesKey = GlobalKey<PincodeCapsulesViewState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PincodeLockCubit>().tryBiometrics();
    });
  }

  Future<void> _onUnlocked() async {
    await context.read<UserCubit>().loadMe();
    if (!mounted) return;
    AuthNavigation.goToNextAfterPincode(context);
  }

  void _onDigit(String digit) {
    if (_code.length >= 4) return;
    setState(() {
      _code += digit;
    });
    if (_code.length == 4) {
      context.read<PincodeLockCubit>().verify(_code);
    }
  }

  void _onBackspace() {
    if (_code.isEmpty) return;
    setState(() {
      _code = _code.substring(0, _code.length - 1);
    });
  }

  void _onLongPressBackspace() {
    if (_code.isEmpty) return;
    setState(() {
      _code = '';
    });
  }

  Future<void> _onExitOrForgotPin() async {
    await context.read<AuthCubit>().logout();
    if (mounted) context.go(RoutePaths.phone);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PincodeLockCubit, PincodeLockState>(
      listener: (context, state) {
        if (state is PincodeLockUnlocked) {
          _onUnlocked();
        } else if (state is PincodeLockWrong) {
          setState(() {
            _code = '';
          });
          _capsulesKey.currentState?.triggerShake();
        } else if (state is PincodeLockExhausted) {
          context.read<AuthCubit>().logout().then((_) {
            if (context.mounted) context.go(RoutePaths.phone);
          });
        }
      },
      builder: (context, state) {
        final user = context.watch<UserCubit>().currentUserOrNull;
        final firstName = user?.name.trim().split(RegExp(r'\s+')).firstOrNull;
        final title = (firstName != null && firstName.isNotEmpty)
            ? 'Hi, $firstName!'
            : 'Hi, Faruxjon!';

        String? errorMessage;
        if (state is PincodeLockWrong) {
          errorMessage = 'Noto\'g\'ri PIN. Qolgan urinishlar: ${state.remainingAttempts}';
        }

        return PincodeScreenLayout(
          topLabel: 'Security check',
          onExit: _onExitOrForgotPin,
          exitIcon: Icons.logout_rounded,
          title: title,
          subtitle: 'Enter your PIN',
          errorMessage: errorMessage,
          code: _code,
          onDigit: _onDigit,
          onBackspace: _onBackspace,
          onLongPressBackspace: _onLongPressBackspace,
          onBiometrics: () => context.read<PincodeLockCubit>().tryBiometrics(),
          showBiometrics: true,
          pillButtonLabel: 'Forgot PIN',
          onPillButtonTap: _onExitOrForgotPin,
          capsulesKey: _capsulesKey,
          isError: state is PincodeLockWrong,
        );
      },
    );
  }
}
