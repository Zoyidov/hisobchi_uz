import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/cubits/user_cubit.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../auth_navigation.dart';
import '../cubit/pincode_setup_cubit.dart';
import '../widgets/pincode_widgets.dart';

/// PIN yaratish — login/register'dan keyingi ixtiyoriy taklif ekrani
/// (MOBILE_APP_TZ.md 5.6, 5.8).
class PincodeSetupPage extends StatelessWidget {
  const PincodeSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PincodeSetupCubit(getIt<AuthRepository>(), getIt<SecureStorageService>()),
      child: const _PincodeSetupView(),
    );
  }
}

class _PincodeSetupView extends StatefulWidget {
  const _PincodeSetupView();

  @override
  State<_PincodeSetupView> createState() => _PincodeSetupViewState();
}

class _PincodeSetupViewState extends State<_PincodeSetupView> {
  String? _firstCode;
  String? _error;
  String _code = '';
  final _capsulesKey = GlobalKey<PincodeCapsulesViewState>();

  void _onDigit(String digit) {
    if (_code.length >= 4) return;
    setState(() {
      _code += digit;
      _error = null;
    });
    if (_code.length == 4) {
      _onCompleted(_code);
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

  void _onCompleted(String code) {
    if (_firstCode == null) {
      setState(() {
        _firstCode = code;
        _code = '';
        _error = null;
      });
      return;
    }
    if (code != _firstCode) {
      setState(() {
        _firstCode = null;
        _code = '';
        _error = 'PIN kodlar mos emas. Qaytadan kiriting';
      });
      _capsulesKey.currentState?.triggerShake();
      return;
    }
    final userId = context.read<UserCubit>().currentUserOrNull?.userId;
    if (userId == null) {
      AuthNavigation.goToNextAfterPincode(context);
      return;
    }
    context.read<PincodeSetupCubit>().save(userId: userId, pincode: code);
  }

  void _onExitOrSkip() {
    if (context.canPop()) {
      context.pop(false);
    } else {
      AuthNavigation.goToNextAfterPincode(context);
    }
  }

  void _onSuccess() {
    if (context.canPop()) {
      context.pop(true);
    } else {
      AuthNavigation.goToNextAfterPincode(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PincodeSetupCubit, PincodeSetupState>(
      listener: (context, state) {
        if (state is PincodeSetupSuccess) {
          _onSuccess();
        }
      },
      child: Builder(
        builder: (context) {
          final user = context.watch<UserCubit>().currentUserOrNull;
          final firstName = user?.name.trim().split(RegExp(r'\s+')).firstOrNull;
          final title = (firstName != null && firstName.isNotEmpty)
              ? 'Hi, $firstName!'
              : 'Hi, Faruxjon!';

          final subtitle = _firstCode == null ? 'Enter new PIN' : 'Confirm your PIN';

          return PincodeScreenLayout(
            topLabel: 'Security check',
            onExit: _onExitOrSkip,
            exitIcon: Icons.close_rounded,
            title: title,
            subtitle: subtitle,
            errorMessage: _error,
            code: _code,
            onDigit: _onDigit,
            onBackspace: _onBackspace,
            onLongPressBackspace: _onLongPressBackspace,
            showBiometrics: false,
            pillButtonLabel: 'Skip for now',
            onPillButtonTap: _onExitOrSkip,
            capsulesKey: _capsulesKey,
            isError: _error != null,
          );
        },
      ),
    );
  }
}
