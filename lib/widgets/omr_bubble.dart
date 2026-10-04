import 'package:flutter/material.dart';

class OmrBubble extends StatelessWidget {
  final String label; // 'A', 'B', 'C', 'D'
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final bool isReadOnly;
  final bool? isCorrectOption; // for review mode

  const OmrBubble({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.size = 38,
    this.isReadOnly = false,
    this.isCorrectOption,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFF64748B);
    Color fillColor = Colors.transparent;
    Color textColor = const Color(0xFF1E293B);

    if (isCorrectOption != null) {
      // Review mode: show green for correct, red if selected incorrectly
      if (isCorrectOption == true) {
        borderColor = const Color(0xFF10B981);
        fillColor = const Color(0xFF10B981);
        textColor = Colors.white;
      } else if (isSelected) {
        borderColor = const Color(0xFFEF4444);
        fillColor = const Color(0xFFEF4444);
        textColor = Colors.white;
      }
    } else if (isSelected) {
      // Normal OMR selection: Dark ink pencil / deep blue fill
      borderColor = const Color(0xFF1E293B);
      fillColor = const Color(0xFF0F172A);
      textColor = Colors.white;
    }

    return InkWell(
      onTap: isReadOnly ? null : onTap,
      borderRadius: BorderRadius.circular(size),
      splashColor: const Color(0xFF38BDF8).withValues(alpha: 0.3),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.2 : 1.8,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
