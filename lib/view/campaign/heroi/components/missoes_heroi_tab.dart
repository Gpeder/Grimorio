import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/campaign/components/caixa_tracejada.dart';
import 'package:grimorio/view/campaign/components/missao_card.dart';
import 'package:grimorio/view/campaign/mestre/components/missoes_mestre_tab.dart'
    show rotulosEstado;
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:pixelarticons/pixel.dart';

class MissoesHeroiTab extends StatefulWidget {
  const MissoesHeroiTab({
    super.key,
    required this.missoes,
    required this.sessaoAtual,
    required this.onAbrir,
  });

  // Já filtradas por `missoesVisiveis`.
  final List<Missao> missoes;
  final int sessaoAtual;
  final ValueChanged<Missao> onAbrir;

  @override
  State<MissoesHeroiTab> createState() => _MissoesHeroiTabState();
}

class _MissoesHeroiTabState extends State<MissoesHeroiTab> {
  var _estado = EstadoMissao.ativa;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final apagado = AppColors.onSurface.withValues(alpha: 0.55);
    int quantas(EstadoMissao e) =>
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
            if (m.tipo == TipoMissao.principal) m,
        ],
      ),
      (
        'Secundárias',
        [
          for (final m in lista)
            if (m.tipo == TipoMissao.secundaria) m,
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Filtros(
          itens: [
            for (final e in EstadoMissao.values)
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
              MissaoCard(
                missao: m,
                papel: PapelCampanha.heroi,
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
