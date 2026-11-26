import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/characters/new_hero/components/alternador.dart';
import 'package:grimorio/characters/new_hero/components/etiqueta.dart';
import 'package:grimorio/grimoire/components/caixa_dados.dart';
import 'package:grimorio/grimoire/components/tela_lista.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/hero_options.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:pixelarticons/pixel.dart';

String _metros(num m) =>
    '${m == m.roundToDouble() ? m.round() : '$m'.replaceAll('.', ',')} m';

String _bonus(Map<Ability, int> bonus) => [
  for (final MapEntry(:key, :value) in bonus.entries)
    '${sinal(value)} ${key.sigla}',
].join(', ');

class EspecieDetalhe extends StatefulWidget {
  const EspecieDetalhe({super.key, required this.especie});

  final SpeciesOption especie;

  @override
  State<EspecieDetalhe> createState() => _EspecieDetalheState();
}

class _EspecieDetalheState extends State<EspecieDetalhe> {
  bool _feminino = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final e = widget.especie;
    final suave = AppColors.onSurface.withValues(alpha: 0.75);
    final bonus = [
      if (e.bonus.isNotEmpty) _bonus(e.bonus),
      if (e.bonusLivres > 0) '+1 em ${e.bonusLivres} à escolha',
    ].join(', ');

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BarraVoltar(titulo: e.nomePara(feminino: _feminino)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  0,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ImageFrame(
                        imagePath: e.retratoPara(feminino: _feminino),
                        width: 180,
                        height: 210,
                        selected: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.medium - 4),
                    Alternador<bool>(
                      opcoes: const {true: 'Feminino', false: 'Masculino'},
                      valor: _feminino,
                      onChanged: (v) => setState(() => _feminino = v),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      e.descricao,
                      style: textTheme.bodyLarge?.copyWith(color: suave),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CaixaDados(
                      dados: [
                        Dado('Tamanho', e.tamanho),
                        Dado('Deslocamento', _metros(e.deslocamentoM)),
                        Dado(
                          'Visão no escuro',
                          e.visaoNoEscuroM == null
                              ? '—'
                              : _metros(e.visaoNoEscuroM!),
                        ),
                        Dado('Bônus', bonus.isEmpty ? '—' : bonus),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.large),
                    const TituloSecao('Traços'),
                    for (final t in e.tracos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(
                              Pixel.chevronright,
                              size: 14,
                              color: AppColors.alerta,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.medium),
                    const TituloSecao('Idiomas'),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final i in e.idiomas) Etiqueta(i),
                        if (e.idiomasExtras > 0)
                          Etiqueta('+${e.idiomasExtras} à escolha'),
                      ],
                    ),
                    if (e.subespecies.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Sub-espécies'),
                      for (final s in e.subespecies)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: AppCard(
                            padding: const EdgeInsets.all(
                              AppSpacing.medium - 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.nome,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  [
                                    if (s.bonus.isNotEmpty) _bonus(s.bonus),
                                    if (s.hpPorNivel > 0)
                                      '+${s.hpPorNivel} PV por nível',
                                  ].join(' · '),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.alerta,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
