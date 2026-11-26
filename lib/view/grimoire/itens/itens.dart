import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/grimoire/filtros_srd.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/view/grimoire/components/raridade_badge.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:provider/provider.dart';

// cada aba e uma lista do provider e um tipo no path do detalhe
enum AbaItem {
  magicos('Mágicos', TipoCompendio.itensMagicos),
  equipamento('Equipamento', TipoCompendio.itens),
  armas('Armas', TipoCompendio.armas),
  armaduras('Armaduras', TipoCompendio.armaduras);

  const AbaItem(this.rotulo, this.tipo);
  final String rotulo;
  final String tipo;
}

// keys da api
const _raridades = [
  'common',
  'uncommon',
  'rare',
  'very-rare',
  'legendary',
  'artifact',
];

class Itens extends StatefulWidget {
  const Itens({super.key, this.aba = AbaItem.magicos});

  final AbaItem aba;

  @override
  State<Itens> createState() => _ItensState();
}

class _ItensState extends State<Itens> {
  late AbaItem _aba = widget.aba;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  CompendioProvider get _compendio => context.read<CompendioProvider>();

  EstadoLista<ItemSrd> _estado(CompendioProvider c) => switch (_aba) {
    AbaItem.magicos => c.itensMagicos,
    AbaItem.equipamento => c.itens,
    AbaItem.armas => c.armas,
    AbaItem.armaduras => c.armaduras,
  };

  Future<void> _carregar({
    String? busca,
    bool manter = true,
    bool forcar = false,
  }) {
    final c = _compendio;
    final b = manter ? _estado(c).busca : busca;
    return switch (_aba) {
      AbaItem.magicos => c.carregarItensMagicos(busca: b, forcar: forcar),
      AbaItem.equipamento => c.carregarItens(busca: b, forcar: forcar),
      AbaItem.armas => c.carregarArmas(busca: b, forcar: forcar),
      AbaItem.armaduras => c.carregarArmaduras(busca: b, forcar: forcar),
    };
  }

  Future<void> _carregarMais() => switch (_aba) {
    AbaItem.magicos => _compendio.carregarMaisItensMagicos(),
    AbaItem.equipamento => _compendio.carregarMaisItens(),
    AbaItem.armas => _compendio.carregarMaisArmas(),
    AbaItem.armaduras => _compendio.carregarMaisArmaduras(),
  };

  void _trocarAba(AbaItem aba) {
    if (aba == _aba) return;
    setState(() => _aba = aba);
    _carregar();
  }

  void _filtrarRaridade(String? raridade) => _compendio.carregarItensMagicos(
    busca: _compendio.itensMagicos.busca,
    filtro: FiltroItemMagico(raridade: raridade),
  );

  void _abrir(ItemSrd i) => context.pushNamed(
    Rotas.nomeDetalheCompendio,
    pathParameters: {Rotas.tipo: _aba.tipo, Rotas.key: i.key},
  );

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();
    final estado = _estado(c);
    final raridade = c.filtroItensMagicos.raridade;

    return TelaLista<ItemSrd>(
      // aba nova comeca com a busca e o scroll dela
      key: ValueKey(_aba),
      titulo: 'Itens',
      estado: estado,
      dicaBusca: 'Buscar item',
      buscaInicial: estado.busca,
      onBusca: (b) => _carregar(busca: b, manter: false),
      onCarregarMais: _carregarMais,
      onTentarDeNovo: _carregar,
      onAtualizar: () => _carregar(forcar: true),
      vazioTitulo: 'Nenhum item encontrado',
      filtros: [
        Filtros(
          itens: [
            for (final a in AbaItem.values)
              Filtro(
                a.rotulo,
                selecionado: _aba == a,
                onTap: () => _trocarAba(a),
              ),
          ],
        ),
        if (_aba == AbaItem.magicos)
          Filtros(
            itens: [
              Filtro(
                'Todas',
                selecionado: raridade == null,
                onTap: () => _filtrarRaridade(null),
              ),
              for (final r in _raridades)
                Filtro(
                  TraducaoSrd.raridade(r),
                  selecionado: raridade == r,
                  onTap: () => _filtrarRaridade(raridade == r ? null : r),
                ),
            ],
          ),
      ],
      itemBuilder: (_, i) {
        final r = VisualSrd.raridade(i.raridade);
        return CompendioTile(
          imagem: VisualSrd.item(i),
          titulo: i.nome,
          subtitulo: [
            TraducaoSrd.categoriaItem(i.categoria),
            if (i.dano case final dano?)
              '$dano ${TraducaoSrd.tipoDano(i.tipoDano)}',
            if (i.caTexto case final ca?) 'CA $ca',
            if (i.sintonia) 'sintonia',
          ].join(' · '),
          corBorda: r?.cor,
          lado: 44,
          trailing: r == null ? null : RaridadeBadge(r),
          onTap: () => _abrir(i),
        );
      },
    );
  }
}
