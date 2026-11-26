import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/model/srd/especie.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:provider/provider.dart';

class Especies extends StatefulWidget {
  const Especies({super.key});

  @override
  State<Especies> createState() => _EspeciesState();
}

class _EspeciesState extends State<Especies> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _compendio.carregarEspecies(),
    );
  }

  CompendioProvider get _compendio => context.read<CompendioProvider>();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();

    return TelaLista<Especie>(
      titulo: 'Espécies',
      estado: c.especies,
      onCarregarMais: () => _compendio.carregarMaisEspecies(),
      onTentarDeNovo: () => _compendio.carregarEspecies(),
      onAtualizar: () => _compendio.carregarEspecies(forcar: true),
      vazioTitulo: 'Nenhuma espécie encontrada',
      itemBuilder: (_, e) => CompendioTile(
        imagem: VisualSrd.especie(e.key),
        titulo: e.nome,
        lado: 48,
        subtitulo: '${e.tracos.length} traços',
        onTap: () => context.pushNamed(
          Rotas.nomeDetalheCompendio,
          pathParameters: {
            Rotas.tipo: TipoCompendio.especies,
            Rotas.key: e.key,
          },
        ),
      ),
    );
  }
}
