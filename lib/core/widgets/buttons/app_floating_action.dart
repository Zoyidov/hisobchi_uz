import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// Bottom navigatsiya ustida suzib turadigan zamonaviy iOS uslubidagi harakat tugmasi.
/// Bottom navbar bilan to'qnashmasligi uchun pastdan avtomatik bo'shliqqa ega.
class AppFloatingAction extends StatefulWidget {
  const AppFloatingAction({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon = CupertinoIcons.plus,
    this.heroTag,
    this.bottomOffset = 82.0,
  });

  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Object? heroTag;
  final double bottomOffset;

  @override
  State<AppFloatingAction> createState() => _AppFloatingActionState();
}

class _AppFloatingActionState extends State<AppFloatingAction> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget button = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.primary,
                Color.lerp(colors.primary, const Color(0xFF1D4ED8), 0.3) ?? colors.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.heroTag != null) {
      button = Hero(tag: widget.heroTag!, child: Material(type: MaterialType.transparency, child: button));
    }

    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomOffset),
      child: button,
    );
  }
}
