import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/widgets/appcard.dart';

class Dado {
  const Dado(this.rotulo, this.valor, {this.detalhe});

  final String rotulo;
  final String valor;
  final String? detalhe;
}

// grade de 2 colunas
class CaixaDados extends StatelessWidget {
  const CaixaDados({super.key, required this.dados});

  final List<Dado> dados;

  @override
  Widget build(BuildContext context) {
    final linhas = (dados.length / 2).ceil();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.medium - 4),
      child: Column(
        spacing: AppSpacing.medium - 4,
        children: [
          for (var l = 0; l < linhas; l++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.medium,
              children: [
                for (var c = 0; c < 2; c++)
                  Expanded(
                    child: l * 2 + c < dados.length
                        ? _Celula(dados[l * 2 + c])
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Celula extends StatelessWidget {
  const _Celula(this.dado);

  final Dado dado;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final detalhe = dado.detalhe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RotuloFicha(dado.rotulo),
        const SizedBox(height: 2),
        Text(
          dado.valor,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (detalhe != null)
          Text(
            detalhe,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }
}
