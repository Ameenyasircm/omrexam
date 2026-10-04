import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double borderRadius;

  const AppLogo({
    super.key,
    this.size = 40,
    this.showBackground = false,
    this.backgroundColor,
    this.border,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image.asset(
      'assets/MetLogPng.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to aseets/ if assets/ failed
        return Image.asset(
          'aseets/MetLogPng.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, stack) => Icon(
            Icons.school_rounded,
            size: size * 0.8,
            color: const Color(0xFF1E3A8A),
          ),
        );
      },
    );

    if (showBackground) {
      return Container(
        width: size + 12,
        height: size + 12,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
