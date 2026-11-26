import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/campaign/components/card_missao.dart';
import 'package:grimorio/campaign/mestre/components/linha_membro.dart';
import 'package:grimorio/campaign/mestre/components/linha_registro.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/models/campaign.dart' as dados;
import 'package:grimorio/models/character.dart';
import 'package:grimorio/widgets/appcard.dart';

class AbaMesa extends StatelessWidget {
  const AbaMesa({
    super.key,
    required this.campanha,
    required this.herois,
    required this.onXp,
    required this.onXpTodos,
    required this.onItem,
    required this.onAbrirMissao,
    required this.onDesfazer,
  });

  final dados.Campaign campanha;
  final List<Character> herois;
  final ValueChanged<Character> onXp;
  final VoidCallback onXpTodos;
  final ValueChanged<Character> onItem;
  final ValueChanged<dados.Missao> onAbrirMissao;
  final ValueChanged<dados.RegistroMesa> onDesfazer;

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
                      LinhaMembro(
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
            CardMissao(
              missao: m,
              papel: dados.PapelCampanha.mestre,
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
                  LinhaRegistro(
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
