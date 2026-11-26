import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/campaign/components/caixa_tracejada.dart';
import 'package:grimorio/view/campaign/components/card_missao.dart';
import 'package:grimorio/view/campaign/mestre/components/aba_missoes_mestre.dart'
    show rotulosEstado;
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/model/campaign.dart' as dados;
import 'package:pixelarticons/pixel.dart';

class AbaMissoesHeroi extends StatefulWidget {
  const AbaMissoesHeroi({
    super.key,
    required this.missoes,
    required this.sessaoAtual,
    required this.onAbrir,
  });

  // Já filtradas por `missoesVisiveis`.
  final List<dados.Missao> missoes;
  final int sessaoAtual;
  final ValueChanged<dados.Missao> onAbrir;

  @override
  State<AbaMissoesHeroi> createState() => _AbaMissoesHeroiState();
}

class _AbaMissoesHeroiState extends State<AbaMissoesHeroi> {
  var _estado = dados.EstadoMissao.ativa;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final apagado = AppColors.onSurface.withValues(alpha: 0.55);
    int quantas(dados.EstadoMissao e) =>
        widget.missoes.where((m) => m.estado == e).length;
    final lista = [
      for (final m in widget.missoes)
        if (m.estado == _estado) m,
    ];
    final grupos = [
      (
        'Missão principal',
        [
          for (final m in lista)
            if (m.tipo == dados.TipoMissao.principal) m,
        ],
      ),
      (
        'Secundárias',
        [
          for (final m in lista)
            if (m.tipo == dados.TipoMissao.secundaria) m,
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Filtros(
          itens: [
            for (final e in dados.EstadoMissao.values)
              Filtro(
                '${rotulosEstado[e]} · ${quantas(e)}',
                selecionado: e == _estado,
                onTap: () => setState(() => _estado = e),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        if (lista.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: Text(
              'Nenhuma missão aqui.',
              style: textTheme.bodyMedium?.copyWith(color: apagado),
            ),
          ),
        for (final (titulo, missoes) in grupos)
          if (missoes.isNotEmpty) ...[
            RotuloSecao(titulo),
            for (final m in missoes) ...[
              CardMissao(
                missao: m,
                papel: dados.PapelCampanha.heroi,
                sessaoAtual: widget.sessaoAtual,
                onTap: () => widget.onAbrir(m),
              ),
              const SizedBox(height: AppSpacing.small),
            ],
            const SizedBox(height: AppSpacing.small),
          ],
        CaixaTracejada(
          child: Row(
            children: [
              Icon(Pixel.lock, size: 18, color: apagado),
              const SizedBox(width: AppSpacing.small + 4),
              Expanded(
                child: Text(
                  'Novas missões aparecem quando o Mestre revelar.',
                  style: textTheme.bodyMedium?.copyWith(color: apagado),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
