import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/components/card_personagem.dart';
import 'package:grimorio/models/campaign.dart';
import 'package:grimorio/models/character.dart';

class ListaPersonagens extends StatelessWidget {
  const ListaPersonagens({
    super.key,
    required this.personagens,
    required this.campanhas,
    this.onAbrir,
  });

  final List<Character> personagens;
  final List<Campaign> campanhas;
  final ValueChanged<Character>? onAbrir;

  static const _larguraDoCard = 170.0;

  String? _nomeCampanha(String? id) {
    for (final c in campanhas) {
      if (c.id == id) return c.nome;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (personagens.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.small),
          child: Text(
            'Nenhum herói encontrado.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      );
    }

    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final colunas = (constraints.crossAxisExtent / _larguraDoCard)
            .floor()
            .clamp(2, 6);
        final linhas = (personagens.length / colunas).ceil();

        return SliverList.separated(
          itemCount: linhas,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.small),
          itemBuilder: (context, linha) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.small,
            children: [
              for (var col = 0; col < colunas; col++)
                Expanded(
                  child: switch (linha * colunas + col) {
                    final i when i < personagens.length => CardPersonagem(
                      personagem: personagens[i],
                      nomeCampanha: _nomeCampanha(personagens[i].campanhaId),
                      onTap: onAbrir == null
                          ? null
                          : () => onAbrir!(personagens[i]),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
