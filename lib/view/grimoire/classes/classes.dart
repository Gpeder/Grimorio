import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/classe_srd.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:provider/provider.dart';

class Classes extends StatefulWidget {
  const Classes({super.key});

  @override
  State<Classes> createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _compendio.carregarClasses(),
    );
  }

  CompendioProvider get _compendio => context.read<CompendioProvider>();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaLista<ClasseSrd>(
      titulo: 'Classes',
      estado: c.classes,
      onCarregarMais: () => _compendio.carregarMaisClasses(),
      onTentarDeNovo: () => _compendio.carregarClasses(),
      onAtualizar: () => _compendio.carregarClasses(forcar: true),
      vazioTitulo: 'Nenhuma classe encontrada',
      itemBuilder: (_, classe) => CompendioTile(
        imagem: VisualSrd.classe(classe.key),
        titulo: classe.nome,
        lado: 48,
        subtitulo: [
          if (classe.dadoDeVida case final d?)
            'Dado de vida ${d.toLowerCase()}',
          if (classe.salvaguardas.isNotEmpty)
            classe.salvaguardas.map(TraducaoSrd.siglaAtributo).join(', '),
        ].join(' · '),
        onTap: () => context.pushNamed(
          Rotas.nomeDetalheCompendio,
          pathParameters: {
            Rotas.tipo: TipoCompendio.classes,
            Rotas.key: classe.key,
          },
        ),
      ),
    );
  }
}
