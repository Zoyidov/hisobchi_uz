import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/states/app_error_state.dart';

/// Parolni tiklash — OTP yuboriladi va OTP ekraniga o'tiladi (MOBILE_APP_TZ.md 5.7).
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, required this.phone});

  final String phone;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _send());
  }

  Future<void> _send() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await getIt<AuthRepository>().sendOtp(widget.phone);
    if (!mounted) return;
    result.when(
      success: (_) {
        context.pushReplacement(RoutePaths.otp, extra: {'phone': widget.phone, 'mode': 'resetPassword'});
      },
      failure: (f) => setState(() {
        _loading = false;
        _error = f.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : AppErrorState(title: 'Kod yuborilmadi', description: _error, onRetry: _send),
        ),
      ),
    );
  }
}
