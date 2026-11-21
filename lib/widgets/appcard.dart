import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final bool innerBorder;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.innerBorder = true,
    this.padding = const EdgeInsets.all(16),
  });

  static const double _outerRadius = 10;
  static const double _gap = 4;
  static const double _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);

    return Container(
      width: double.infinity,
      padding: innerBorder ? const EdgeInsets.all(_gap) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_outerRadius),
        border: Border.all(color: AppColors.secondary, width: _borderWidth),
      ),
      child: innerBorder
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_outerRadius - _gap),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.6),
                  width: _borderWidth,
                ),
              ),
              child: content,
            )
          : content,
    );
  }
}
