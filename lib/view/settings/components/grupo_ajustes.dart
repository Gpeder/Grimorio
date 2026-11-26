import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/widgets/appcard.dart';

class GrupoAjustes extends StatelessWidget {
  const GrupoAjustes({super.key, required this.titulo, required this.linhas});

  final String titulo;
  final List<Widget> linhas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSecao(titulo),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium,
            vertical: 4,
          ),
          child: Column(
            children: [
              for (var i = 0; i < linhas.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: AppColors.secondary.withValues(alpha: 0.15),
                  ),
                linhas[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
