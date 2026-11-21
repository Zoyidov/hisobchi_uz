import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/connectivity_cubit.dart';
import '../../icons/app_icons.dart';
import '../../localization/app_localization_extension.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Ilova bo'ylab internet holati ko'rsatkichi (MOBILE_APP_TZ.md 4.11, 71;
/// E_HISOB_FLUTTER_UI_COMPONENTS_TZ.md 107).
///
/// `MaterialApp.builder` ichida butun navigatorni o'raydi, shuning uchun har
/// bir sahifa alohida banner qo'yishi shart emas. Layout'ni surmaydi — status
/// bar ostida suzuvchi "pill" sifatida chiqadi:
/// * internet uzilsa — doimiy "Offline" xabari;
/// * qayta ulansa — 2 soniyalik "Internet tiklandi" xabari, so'ng yo'qoladi.
class ConnectivityOverlay extends StatefulWidget {
  const ConnectivityOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

enum _BannerState { hidden, offline, restored }

class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
  static const _restoredVisibleFor = Duration(seconds: 2);

  _BannerState _state = _BannerState.hidden;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    final isOnline = context.read<ConnectivityCubit>().state;
    if (!isOnline) _state = _BannerState.offline;
  }

  void _onConnectivityChanged(BuildContext context, bool isOnline) {
    _hideTimer?.cancel();
    if (!isOnline) {
      setState(() => _state = _BannerState.offline);
      return;
    }
    // Faqat avval offline bo'lgan bo'lsak "tiklandi" deymiz.
    if (_state != _BannerState.offline) return;
    setState(() => _state = _BannerState.restored);
    _hideTimer = Timer(_restoredVisibleFor, () {
      if (mounted) setState(() => _state = _BannerState.hidden);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, bool>(
      listener: _onConnectivityChanged,
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, -0.6),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: switch (_state) {
                    _BannerState.hidden => const SizedBox.shrink(),
                    _BannerState.offline => const OfflineBanner(
                      key: ValueKey('offline'),
                    ),
                    _BannerState.restored => const OfflineBanner(
                      key: ValueKey('restored'),
                      restored: true,
                    ),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internet holati "pill"i. Odatda [ConnectivityOverlay] orqali ishlatiladi.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.restored = false});

  /// `true` — "Internet tiklandi" (yashil), `false` — offline (teskari fon).
  final bool restored;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final background = restored ? colors.success : colors.inverseSurface;
    final foreground = restored ? colors.onPrimary : colors.onInverseSurface;
    final message = restored
        ? l10n.connectivityRestored
        : l10n.connectivityOffline;

    return Semantics(
      liveRegion: true,
      container: true,
      label: message,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Material(
            color: background,
            elevation: 0,
            shape: const StadiumBorder(),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.pillRadius,
                boxShadow: colors.elevatedShadow,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    restored ? AppIcons.online : AppIcons.offline,
                    size: 16,
                    color: foreground,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: foreground),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
