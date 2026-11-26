import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/widgets/image_frame.dart';

class SlotEquipamento extends StatelessWidget {
  const SlotEquipamento({
    super.key,
    required this.item,
    this.rotulo,
    this.lado = 56,
    this.onTap,
  });

  final InventoryItem? item;
  final String? rotulo;
  final double lado;
  final ValueChanged<InventoryItem>? onTap;

  @override
  Widget build(BuildContext context) {
    final item = this.item;
    final rotulo = this.rotulo;
    final onTap = this.onTap;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item == null)
          SlotVazio(lado: lado)
        else
          ImageFrame(
            imagePath: item.imagem,
            width: lado,
            height: lado,
            onTap: onTap == null ? null : () => onTap(item),
          ),
        if (rotulo != null) ...[
          const SizedBox(height: 4),
          SizedBox(
            width: lado + AppSpacing.medium,
            child: Text(
              rotulo,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ],
    );
  }
}

class SlotVazio extends StatelessWidget {
  const SlotVazio({super.key, this.lado});

  final double? lado;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: lado,
      height: lado,
      child: CustomPaint(painter: _BordaTracejada()),
    );
  }
}

class _BordaTracejada extends CustomPainter {
  static const _traco = 4.0;
  static const _vao = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(AppSpacing.radius),
        ),
      );
    for (final PathMetric m in caminho.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + _traco), paint);
        d += _traco + _vao;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
