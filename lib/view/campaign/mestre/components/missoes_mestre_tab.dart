import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/view/campaign/components/missao_card.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:pixelarticons/pixel.dart';

class MissoesMestreTab extends StatefulWidget {
  const MissoesMestreTab({
    super.key,
    required this.missoes,
    required this.sessaoAtual,
    required this.onAbrir,
    required this.onNova,
  });

  final List<Missao> missoes;
  final int sessaoAtual;
  final ValueChanged<Missao> onAbrir;
  final VoidCallback onNova;

  @override
  State<MissoesMestreTab> createState() => _MissoesMestreTabState();
}

const rotulosEstado = {
  EstadoMissao.ativa: 'Ativas',
  EstadoMissao.concluida: 'Concluídas',
  EstadoMissao.falhou: 'Falhas',
};

class _MissoesMestreTabState extends State<MissoesMestreTab> {
  var _estado = EstadoMissao.ativa;

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
                  for (final e in EstadoMissao.values)
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
          MissaoCard(
            missao: m,
            papel: PapelCampanha.mestre,
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
