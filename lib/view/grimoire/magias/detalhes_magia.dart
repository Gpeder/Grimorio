import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/view/grimoire/components/caixa_dados.dart';
import 'package:grimorio/view/grimoire/components/tela_detalhe.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/texto_srd.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:provider/provider.dart';

class DetalhesMagia extends StatefulWidget {
  const DetalhesMagia({super.key, required this.srdKey});

  final String srdKey;

  @override
  State<DetalhesMagia> createState() => _DetalhesMagiaState();
}

class _DetalhesMagiaState extends State<DetalhesMagia> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  void _carregar() => context.read<CompendioProvider>().carregarDetalhe(
    TipoSrd.magia,
    widget.srdKey,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaDetalhe<Magia>(
      estado: c.detalhe<Magia>(TipoSrd.magia, widget.srdKey),
      onTentarDeNovo: _carregar,
      builder: (_, m) => _Conteudo(magia: m),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.magia});

  final Magia magia;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final m = magia;
    final material = m.materialDetalhe;
    final superior = m.superior ?? '';

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
                    // nome e circulo
                    Row(
                      children: [
                        ImageFrame(
                          imagePath: VisualSrd.escola(m.escola),
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
                                '${VisualSrd.nivel(m.nivel)} · '
                                '${TraducaoSrd.escola(m.escola)}',
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
                        Dado('Conjuração', TraducaoSrd.tempo(m.tempo)),
                        Dado('Alcance', TraducaoSrd.alcance(m.alcance)),
                        Dado(
                          'Componentes',
                          m.componentes.isEmpty
                              ? TraducaoSrd.vazio
                              : m.componentes,
                          detalhe: material == null || material.isEmpty
                              ? null
                              : material,
                        ),
                        Dado('Duração', TraducaoSrd.duracao(m.duracao)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    TextoSrd(m.descricao),
                    if (superior.trim().isNotEmpty) ...[
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
                            TextoSrd(
                              superior,
                              estilo: textTheme.bodyMedium?.copyWith(
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
}
