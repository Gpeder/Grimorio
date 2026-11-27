import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';

// "Codigo enviado para fulano@email.com." com o e-mail em dourado
class TextoEmail extends StatelessWidget {
  const TextoEmail({super.key, required this.antes, required this.email});

  final String antes;
  final String email;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.bodyLarge
        ?.copyWith(color: AppColors.onSurface);

    return Text.rich(
      TextSpan(
        text: antes,
        children: [
          TextSpan(
            text: email,
            style: estilo?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      style: estilo,
    );
  }
}
