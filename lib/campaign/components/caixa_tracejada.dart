import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

class CaixaTracejada extends StatelessWidget {
  const CaixaTracejada({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  static const _raio = BorderRadius.all(Radius.circular(AppSpacing.radius));

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _Tracejado(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: _raio,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.medium - 2),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Tracejado extends CustomPainter {
  const _Tracejado();

  static const _traco = 6.0;
  static const _vao = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final borda = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          const Radius.circular(AppSpacing.radius),
        ),
      );
    for (final PathMetric m in borda.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += _traco + _vao) {
        canvas.drawPath(m.extractPath(d, d + _traco), pincel);
      }
    }
  }

  @override
  bool shouldRepaint(_Tracejado oldDelegate) => false;
}
