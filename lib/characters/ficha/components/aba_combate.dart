import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

class AbaCombate extends StatelessWidget {
  const AbaCombate({
    super.key,
    required this.personagem,
    required this.onIrInventario,
  });

  final Character personagem;
  final VoidCallback onIrInventario;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = personagem;
    final armas = [
      ...p.itensEm(EquipSlot.maoPrincipal),
      ...p.itensEm(EquipSlot.maoSecundaria),
    ].where((i) => i.arma).toList();
    final escudo = p.bonusCaEquipado;
    final titulo = textTheme.titleMedium?.copyWith(
      color: AppColors.onSurface,
      fontWeight: FontWeight.bold,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TituloSecao('Armas'),
        if (armas.isEmpty) ...[
          Text(
            'Nenhuma arma equipada',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.medium - 4),
          OutlinedButton(
            onPressed: onIrInventario,
            child: const Text('Abrir inventário'),
          ),
        ],
        for (final arma in armas) ...[
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.medium - 4),
            child: Row(
              children: [
                ImageFrame(imagePath: arma.imagem, width: 48, height: 48),
                const SizedBox(width: AppSpacing.medium - 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(arma.nome, style: titulo),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Etiqueta('Ataque ${sinal(p.ataqueArma(arma))}'),
                          Etiqueta(
                            [
                              'Dano ${p.danoArma(arma)}',
                              ?arma.tipoDano,
                            ].join(' '),
                            cor: AppColors.vida,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.small),
        ],
        if (p.atributoMagia case final atributo?) ...[
          const SizedBox(height: AppSpacing.medium),
          const TituloSecao('Magia'),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.medium - 4),
            child: Row(
              children: [
                const Icon(Pixel.sparkles, color: AppColors.mana),
                const SizedBox(width: AppSpacing.medium - 4),
                Expanded(
                  child: Text(
                    'Ataque mágico ${sinal(p.ataqueMagico)} · CD ${p.cdMagia}',
                    style: titulo,
                  ),
                ),
                Text(
                  atributo.sigla,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.large),
        const TituloSecao('Defesa'),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.medium - 4),
          child: Row(
            children: [
              const Icon(Pixel.shield, color: AppColors.alerta),
              const SizedBox(width: AppSpacing.medium - 4),
              Expanded(child: Text('CA ${p.ca}', style: titulo)),
              if (escudo > 0) Etiqueta('Escudo ${sinal(escudo)}'),
            ],
          ),
        ),
      ],
    );
  }
}
