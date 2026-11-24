import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/dialogo_numero.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/progress_bar.dart';
import 'package:pixelarticons/pixel.dart';

 HP (− valor +), CA, Iniciativa e Deslocamento.
class FichaStatus extends StatelessWidget {
  const FichaStatus({
    super.key,
    required this.personagem,
    required this.onDano,
    required this.onCura,
    required this.onHpTemp,
  });

  final Character personagem;
  final ValueChanged<int> onDano;
  final ValueChanged<int> onCura;
  final ValueChanged<int> onHpTemp;

  static String metros(double m) =>
      '${m == m.roundToDouble() ? m.round() : m.toString().replaceAll('.', ',')}m';

  Future<void> _pedir(
    BuildContext context,
    String titulo,
    ValueChanged<int> aoConfirmar, {
    int? inicial,
  }) async {
    final valor = await pedirNumero(context, titulo: titulo, inicial: inicial);
    if (valor != null) aoConfirmar(valor);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = personagem;
    final divisor = VerticalDivider(
      width: AppSpacing.medium,
      color: AppColors.secondary.withValues(alpha: 0.25),
    );

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.medium - 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const RotuloFicha(
                    'HP',
                    icone: Pixel.heart,
                    corIcone: AppColors.vida,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Row(
                    children: [
                      _BotaoHp(
                        icone: Pixel.minus,
                        dica: 'Dano recebido',
                        onPressed: () =>
                            _pedir(context, 'Dano recebido', onDano),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: GestureDetector(
                          onLongPress: () => _pedir(
                            context,
                            'HP temporário',
                            onHpTemp,
                            inicial: p.hpTemp,
                          ),
                          child: ProgressBar(
                            value: p.hpAtual,
                            max: p.hpMax,
                            color: AppColors.vida,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _BotaoHp(
                        icone: Pixel.plus,
                        dica: 'Cura recebida',
                        onPressed: () =>
                            _pedir(context, 'Cura recebida', onCura),
                      ),
                    ],
                  ),
                  if (p.hpTemp > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${p.hpTemp} temp',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.alerta,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            divisor,
            Expanded(
              flex: 3,
              child: _Valor(
                icone: Pixel.shield,
                rotulo: 'CA',
                valor: '${p.ca}',
              ),
            ),
            divisor,
            Expanded(
              flex: 3,
              child: _Valor(
                icone: Pixel.zap,
                rotulo: 'Inic.',
                valor: sinal(p.iniciativa),
              ),
            ),
            divisor,
            Expanded(
              flex: 3,
              child: _Valor(
                icone: Pixel.human,
                rotulo: 'Desl.',
                valor: metros(p.deslocamentoM),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoHp extends StatelessWidget {
  const _BotaoHp({
    required this.icone,
    required this.dica,
    required this.onPressed,
  });

  final IconData icone;
  final String dica;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // Quadrado de 28 px: o IconButton do tema força 48 px e não cabe ao
    // lado da barra de HP em telas de 360.
    final raio = BorderRadius.circular(AppSpacing.radiusSmall);
    return Tooltip(
      message: dica,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: raio,
          side: const BorderSide(color: AppColors.alerta, width: 1.5),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: raio,
          child: SizedBox.square(
            dimension: 28,
            child: Icon(
              icone,
              size: 14,
              color: AppColors.onSurface,
              semanticLabel: dica,
            ),
          ),
        ),
      ),
    );
  }
}

class _Valor extends StatelessWidget {
  const _Valor({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotuloFicha(rotulo, icone: icone),
        const SizedBox(height: AppSpacing.small),
        Text(
          valor,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ],
    );
  }
}
