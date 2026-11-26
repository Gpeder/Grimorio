import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/campaign/components/missao_card.dart';
import 'package:grimorio/view/campaign/mestre/components/membro_tile.dart';
import 'package:grimorio/view/campaign/mestre/components/registro_tile.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/widgets/appcard.dart';

class MesaTab extends StatelessWidget {
  const MesaTab({
    super.key,
    required this.campanha,
    required this.herois,
    required this.onXp,
    required this.onXpTodos,
    required this.onItem,
    required this.onAbrirMissao,
    required this.onDesfazer,
  });

  final Campanha campanha;
  final List<Personagem> herois;
  final ValueChanged<Personagem> onXp;
  final VoidCallback onXpTodos;
  final ValueChanged<Personagem> onItem;
  final ValueChanged<Missao> onAbrirMissao;
  final ValueChanged<RegistroMesa> onDesfazer;

  @override
  Widget build(BuildContext context) {
    final ativas = [
      for (final m in campanha.missoes)
        if (m.ativa) m,
    ];
    final registros = campanha.registros.take(10).toList();
    final vazio = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.55));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TituloSecao(
          'Grupo · ${herois.length} ${herois.length == 1 ? 'herói' : 'heróis'}',
          trailing: herois.isEmpty
              ? null
              : TextButton(
                  onPressed: onXpTodos,
                  child: const Text('XP para todos'),
                ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.medium - 4,
            vertical: 4,
          ),
          child: herois.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.small),
                  child: Text(
                    'Ninguém entrou ainda. Passe o código aos jogadores.',
                    style: vazio,
                  ),
                )
              : Column(
                  children: [
                    for (var i = 0; i < herois.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      MembroTile(
                        heroi: herois[i],
                        onXp: () => onXp(herois[i]),
                        onItem: () => onItem(herois[i]),
                      ),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.large),
        const TituloSecao('Missões em andamento'),
        if (ativas.isEmpty)
          Text('Nenhuma missão ativa.', style: vazio)
        else
          for (final m in ativas) ...[
            MissaoCard(
              missao: m,
              papel: PapelCampanha.mestre,
              sessaoAtual: campanha.sessaoAtual,
              onTap: () => onAbrirMissao(m),
            ),
            const SizedBox(height: AppSpacing.small),
          ],
        const SizedBox(height: AppSpacing.large),
        const TituloSecao('Registro da mesa'),
        if (registros.isEmpty)
          Text('Nada aconteceu ainda.', style: vazio)
        else
          AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.medium - 4,
              vertical: 4,
            ),
            child: Column(
              children: [
                for (var i = 0; i < registros.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  RegistroTile(
                    registro: registros[i],
                    onDesfazer: registros[i].podeDesfazer
                        ? () => onDesfazer(registros[i])
                        : null,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
