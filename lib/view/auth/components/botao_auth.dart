import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';

// largura total; carregando trava o toque e mostra o progresso
class BotaoAuth extends StatelessWidget {
  const BotaoAuth({
    super.key,
    required this.texto,
    required this.onPressed,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback onPressed;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        child: carregando
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onSurface,
                  semanticsLabel: texto,
                ),
              )
            : Text(texto),
      ),
    );
  }
}
