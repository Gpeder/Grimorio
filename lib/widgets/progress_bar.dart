import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio/app/theme/app_colors.dart';

class ProgressBar extends StatelessWidget {
  final num value;
  final num max;
  final Color color;
  final double height;
  final bool showText;

  /// Valores exibidos no texto, quando diferentes dos usados para o
  /// preenchimento da barra.
  final num? textValue;
  final num? textMax;

  const ProgressBar({
    super.key,
    required this.value,
    required this.max,
    this.color = AppColors.exp,
    this.height = 24,
    this.showText = true,
    this.textValue,
    this.textMax,
  });

  @override
  Widget build(BuildContext context) {
    final progress = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0).toDouble();
    final radius = BorderRadius.circular(height * 0.15);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: radius,
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.35)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                heightFactor: 1,
                child: ColoredBox(color: color),
              ),
            ),
            if (showText)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${_format(textValue ?? value)} / ${_format(textMax ?? max)}',
                    style: GoogleFonts.inter(
                      fontSize: height * 0.55,
                      height: 1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 2),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _format(num n) {
    final digits = n.round().abs().toString();
    final buffer = StringBuffer(n < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
