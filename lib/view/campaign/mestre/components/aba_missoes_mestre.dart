import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/campaign/components/card_missao.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/model/campaign.dart' as dados;
import 'package:pixelarticons/pixel.dart';

class AbaMissoesMestre extends StatefulWidget {
  const AbaMissoesMestre({
    super.key,
    required this.missoes,
    required this.sessaoAtual,
    required this.onAbrir,
    required this.onNova,
  });

  final List<dados.Missao> missoes;
  final int sessaoAtual;
  final ValueChanged<dados.Missao> onAbrir;
  final VoidCallback onNova;

  @override
  State<AbaMissoesMestre> createState() => _AbaMissoesMestreState();
}

const rotulosEstado = {
  dados.EstadoMissao.ativa: 'Ativas',
  dados.EstadoMissao.concluida: 'Concluídas',
  dados.EstadoMissao.falhou: 'Falhas',
};

class _AbaMissoesMestreState extends State<AbaMissoesMestre> {
  var _estado = dados.EstadoMissao.ativa;

  @override
  Widget build(BuildContext context) {
    final lista = [
      for (final m in widget.missoes)
        if (m.estado == _estado) m,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Filtros(
                itens: [
                  for (final e in dados.EstadoMissao.values)
                    Filtro(
                      rotulosEstado[e]!,
                      selecionado: e == _estado,
                      onTap: () => setState(() => _estado = e),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.medium),
        if (lista.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.medium),
            child: Text(
              'Nenhuma missão aqui.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        for (final m in lista) ...[
          CardMissao(
            missao: m,
            papel: dados.PapelCampanha.mestre,
            sessaoAtual: widget.sessaoAtual,
            onTap: () => widget.onAbrir(m),
          ),
          const SizedBox(height: AppSpacing.small),
        ],
        const SizedBox(height: AppSpacing.small),
        OutlinedButton.icon(
          onPressed: widget.onNova,
          icon: const Icon(Pixel.plus),
          label: const Text('Nova missão'),
        ),
      ],
    );
  }
}
