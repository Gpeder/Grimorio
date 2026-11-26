import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

class PassoRevisao extends StatelessWidget {
  const PassoRevisao({
    super.key,
    required this.personagem,
    required this.linhaEspecieClasse,
    required this.linhaAntecedente,
    required this.explicacaoHp,
    required this.explicacaoCa,
    required this.pericias,
    required this.imagensItens,
    required this.resumoItens,
  });

  final Personagem personagem;

  final String linhaEspecieClasse;

  final String linhaAntecedente;
  final String explicacaoHp;
  final String explicacaoCa;

  final Map<String, int> pericias;
  final List<String> imagensItens;

  final String resumoItens;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = personagem;
    final deslocamento = p.deslocamentoM
        .toStringAsFixed(p.deslocamentoM % 1 == 0 ? 0 : 1)
        .replaceAll('.', ',');
    final destaque = textTheme.bodySmall?.copyWith(
      color: AppColors.alerta,
      fontWeight: FontWeight.bold,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.medium,
        0,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageFrame(
                      imagePath: p.retrato,
                      selected: true,
                      width: 80,
                      height: 96,
                    ),
                    const SizedBox(width: AppSpacing.medium - 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineSmall?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            linhaEspecieClasse,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.alerta,
                            ),
                          ),
                          Text(
                            linhaAntecedente,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    _Stat(
                      icone: Pixel.heart,
                      cor: AppColors.vida,
                      rotulo: 'HP',
                      valor: '${p.hpMax}',
                    ),
                    _Stat(
                      icone: Pixel.shield,
                      cor: AppColors.alerta,
                      rotulo: 'CA',
                      valor: '${p.ca}',
                    ),
                    _Stat(
                      icone: Pixel.zap,
                      cor: AppColors.alerta,
                      rotulo: 'INIC.',
                      valor: sinal(p.iniciativa),
                    ),
                    _Stat(
                      icone: Pixel.human,
                      cor: AppColors.alerta,
                      rotulo: 'DESL.',
                      valor: '${deslocamento}m',
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  spacing: 6,
                  children: [
                    for (final a in Atributo.values)
                      Expanded(
                        child: _Medalhao(
                          sigla: a.sigla,
                          valor: p.atributos.valor(a),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.medium - 4),
          Container(
            padding: const EdgeInsets.all(AppSpacing.medium - 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Text.rich(
              TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.85),
                ),
                children: [
                  TextSpan(text: 'HP do nível 1: ', style: destaque),
                  TextSpan(text: '$explicacaoHp\n'),
                  TextSpan(text: 'CA: ', style: destaque),
                  TextSpan(text: explicacaoCa),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.medium),
          const RotuloSecao('Perícias'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final MapEntry(key: nome, value: bonus) in pericias.entries)
                Etiqueta('$nome ${sinal(bonus)}'),
            ],
          ),
          const SizedBox(height: AppSpacing.medium),
          const RotuloSecao('Equipamento · magias'),
          Row(
            children: [
              for (final img in imagensItens.take(4)) ...[
                ImageFrame(imagePath: img, width: 36),
                const SizedBox(width: 6),
              ],
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  resumoItens,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icone,
    required this.cor,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final Color cor;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 14, color: cor),
              const SizedBox(width: 4),
              Text(
                rotulo,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            valor,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _Medalhao extends StatelessWidget {
  const _Medalhao({required this.sigla, required this.valor});

  final String sigla;
  final int valor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          Text(
            sigla,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              sinal(modificador(valor)),
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$valor',
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
