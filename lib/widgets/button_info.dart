import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimorio/app/theme/app_colors.dart';

class ButtonInfo extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double fontSize;
  const ButtonInfo({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xffb72a42).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.secondary, width: 2),
        ),
        child: Text(
          text,
          style: GoogleFonts.cinzel(
            color: AppColors.alerta,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
