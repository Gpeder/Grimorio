import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/view/grimoire/components/caixa_dados.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';

const _imagemEscola = {
  'Abjuração': AppImages.magoAbjuracao,
  'Adivinhação': AppImages.magoAdivinhacao,
  'Conjuração': AppImages.magoConjuracao,
  'Encantamento': AppImages.magoEncantamento,
  'Evocação': AppImages.magoEvocacao,
  'Ilusão': AppImages.magoIlusao,
  'Necromancia': AppImages.magoNecromancia,
  'Transmutação': AppImages.magoTransmutacao,
};

String imagemDaEscola(String escola) =>
    _imagemEscola[escola] ?? AppImages.pergMagia;

String nomeDoCirculo(int circulo) =>
    circulo == 0 ? 'Truque' : '$circuloº círculo';

class DetalhesMagia extends StatelessWidget {
  const DetalhesMagia({super.key, required this.magia});

  final OpcaoMagia magia;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = magia;

    return Scaffold(
      bottomNavigationBar: RodapeButton(
        texto: 'Adicionar a um personagem',
        onPressed: () => mostrarAviso(context, 'Em breve', tipo: Snackbar.info),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoltarHeader(
              direita: Text(
                'SRD 5.1',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  0,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ImageFrame(
                          imagePath: imagemDaEscola(m.escola),
                          width: 64,
                          height: 64,
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.nome,
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${nomeDoCirculo(m.circulo)} · ${m.escola}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.alerta,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium - 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (m.concentracao)
                          const Etiqueta('Concentração', cor: AppColors.mana),
                        if (m.ritual)
                          const Etiqueta('Ritual', cor: AppColors.secondary),
                        for (final c in m.classes) Etiqueta(c),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    CaixaDados(
                      dados: [
                        Dado('Conjuração', _ou(m.tempo)),
                        Dado('Alcance', _ou(m.alcance)),
                        ..._componentes(m.componentes),
                        Dado('Duração', _ou(m.duracao)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    Text(
                      m.descricao.isEmpty ? m.resumo : m.descricao,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                    if (m.superior.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.medium),
                      AppCard(
                        innerBorder: false,
                        padding: const EdgeInsets.all(AppSpacing.medium - 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Em círculos superiores',
                              style: textTheme.titleSmall?.copyWith(
                                color: AppColors.alerta,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m.superior,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
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

  static String _ou(String v) => v.isEmpty ? '—' : v;

  // "V, S, M (um símbolo sagrado)" → valor "V, S, M" e o material embaixo.
  static List<Dado> _componentes(String texto) {
    final i = texto.indexOf(' (');
    if (i < 0) return [Dado('Componentes', _ou(texto))];
    return [
      Dado(
        'Componentes',
        texto.substring(0, i),
        detalhe: texto.substring(i + 2, texto.length - 1),
      ),
    ];
  }
}
