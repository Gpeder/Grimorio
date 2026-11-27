import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';

// "Ainda nao tem conta? Criar conta"
class AuthFooter extends StatelessWidget {
  const AuthFooter({
    super.key,
    required this.pergunta,
    required this.acao,
    required this.onTap,
  });

  final String pergunta;
  final String acao;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          pergunta,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.7)),
        ),
        TextButton(onPressed: onTap, child: Text(acao)),
      ],
    );
  }
}
