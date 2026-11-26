import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/view/grimoire/components/caixa_dados.dart';
import 'package:grimorio/view/grimoire/components/raridade_badge.dart';
import 'package:grimorio/view/grimoire/components/tela_detalhe.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/texto_srd.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:provider/provider.dart';

// item comum, magico, arma ou armadura; o tipo diz de onde buscar
class DetalhesItem extends StatefulWidget {
  const DetalhesItem({super.key, required this.tipo, required this.srdKey});

  final TipoSrd tipo;
  final String srdKey;

  @override
  State<DetalhesItem> createState() => _DetalhesItemState();
}

class _DetalhesItemState extends State<DetalhesItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  void _carregar() => context.read<CompendioProvider>().carregarDetalhe(
    widget.tipo,
    widget.srdKey,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaDetalhe<ItemSrd>(
      estado: c.detalhe<ItemSrd>(widget.tipo, widget.srdKey),
      onTentarDeNovo: _carregar,
      builder: (_, i) => _Conteudo(item: i),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.item});

  final ItemSrd item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final i = item;
    final raridade = VisualSrd.raridade(i.raridade);
    final dano = i.dano;
    final forca = i.forcaMinima;
    final dados = [
      if (TraducaoSrd.custo(i.custo) case final c when c != TraducaoSrd.vazio)
        Dado('Custo', c),
      if (TraducaoSrd.quilos(i.pesoLb) case final p when p != TraducaoSrd.vazio)
        Dado('Peso', p),
      if (dano != null)
        Dado('Dano', '$dano ${TraducaoSrd.tipoDano(i.tipoDano)}'),
      if (i.propriedades.isNotEmpty)
        Dado(
          'Propriedades',
          [
            for (final p in i.propriedades)
              [
                TraducaoSrd.propriedadeArma(p.nome),
                if (p.detalhe case final d?) '($d)',
              ].join(' '),
          ].join(', '),
        ),
      if (i.armadura) ...[
        Dado('Classe de Armadura', TraducaoSrd.caArmadura(i.caTexto)),
        Dado(
          'Tipo',
          TraducaoSrd.categoriaItem(i.categoriaArmadura ?? i.categoria),
        ),
        if (forca != null) Dado('Força mínima', '$forca'),
        if (i.desvantagemFurtividade) const Dado('Furtividade', 'Desvantagem'),
      ],
    ];

    return Scaffold(
      bottomNavigationBar: RodapeButton(
        texto: 'Dar a um personagem',
        onPressed: () => mostrarAviso(context, 'Em breve'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VoltarHeader(),
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
                    // nome, categoria e raridade
                    Row(
                      children: [
                        ImageFrame(
                          imagePath: VisualSrd.item(i),
                          width: 96,
                          height: 96,
                          borderColor: raridade?.cor,
                        ),
                        const SizedBox(width: AppSpacing.medium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 6,
                            children: [
                              Text(
                                i.nome,
                                style: textTheme.titleLarge?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                TraducaoSrd.categoriaItem(i.categoria),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurface.withValues(
                                    alpha: 0.65,
                                  ),
                                ),
                              ),
                              ?switch (raridade) {
                                final r? => RaridadeBadge(r),
                                null => null,
                              },
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (i.sintonia) ...[
                      const SizedBox(height: AppSpacing.medium - 4),
                      Text(
                        'Requer sintonia',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.alerta,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (dados.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.medium),
                      CaixaDados(dados: dados),
                    ],
                    const SizedBox(height: AppSpacing.medium),
                    TextoSrd(i.descricao),
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
