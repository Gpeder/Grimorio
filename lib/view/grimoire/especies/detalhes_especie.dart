import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/model/srd/especie.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/characters/new_hero/components/alternador.dart';
import 'package:grimorio/view/grimoire/components/tela_detalhe.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/texto_srd.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:provider/provider.dart';

class DetalhesEspecie extends StatefulWidget {
  const DetalhesEspecie({super.key, required this.srdKey});

  final String srdKey;

  @override
  State<DetalhesEspecie> createState() => _DetalhesEspecieState();
}

class _DetalhesEspecieState extends State<DetalhesEspecie> {
  bool _feminino = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  void _carregar() {
    final c = context.read<CompendioProvider>();
    c.carregarDetalhe(TipoSrd.especie, widget.srdKey);
    c.carregarSubespecies();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaDetalhe<Especie>(
      estado: c.detalhe<Especie>(TipoSrd.especie, widget.srdKey),
      onTentarDeNovo: _carregar,
      builder: (_, e) => _conteudo(e, c.subespeciesDe(e.key)),
    );
  }

  Widget _conteudo(Especie e, List<Especie> subespecies) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoltarHeader(titulo: e.nome),
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
                    // retrato
                    Center(
                      child: ImageFrame(
                        imagePath: VisualSrd.especie(
                          e.key,
                          feminino: _feminino,
                        ),
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
                    if (e.descricao.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.medium),
                      TextoSrd(
                        e.descricao,
                        estilo: textTheme.bodyLarge?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                    if (e.tracos.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Traços'),
                      for (final t in e.tracos) _Traco(traco: t),
                    ],
                    if (subespecies.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.large),
                      const TituloSecao('Sub-espécies'),
                      for (final s in subespecies)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.small,
                          ),
                          child: AppCard(
                            padding: const EdgeInsets.all(
                              AppSpacing.medium - 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  s.nome,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                for (final t in s.tracos) _Traco(traco: t),
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

class _Traco extends StatelessWidget {
  const _Traco({required this.traco});

  final AcaoSrd traco;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            traco.nome,
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.alerta,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextoSrd(
            traco.descricao,
            estilo: textTheme.bodyMedium?.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
