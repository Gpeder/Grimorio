import 'package:flutter/material.dart';
import 'package:grimorio/controller/grimoire/gerenciador_compendio.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/view/grimoire/components/raridade_badge.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/itens/detalhes_item.dart';

const _rotulos = {
  FiltroItem.magicos: 'Mágicos',
  FiltroItem.equipamento: 'Equipamento',
  FiltroItem.armas: 'Armas',
  FiltroItem.armaduras: 'Armaduras',
};

class Itens extends StatefulWidget {
  const Itens({super.key});

  @override
  State<Itens> createState() => _ItensState();
}

class _ItensState extends State<Itens> {
  String _busca = '';
  FiltroItem? _tipo;
  Raridade? _raridade;

  static const _compendio = GerenciadorCompendio();

  @override
  Widget build(BuildContext context) {
    final filtrados = _compendio.filtrarItens(
      itensMock,
      busca: _busca,
      tipo: _tipo,
      raridade: _raridade,
    );

    return TelaLista(
      titulo: 'Itens',
      contagem: itensMock.length,
      dicaBusca: 'Buscar item',
      onBusca: (v) => setState(() => _busca = v),
      filtros: [
        Filtros(
          itens: [
            for (final t in FiltroItem.values)
              Filtro(
                _rotulos[t] ?? '—',
                selecionado: _tipo == t,
                onTap: () => setState(() => _tipo = _tipo == t ? null : t),
              ),
          ],
        ),
        Filtros(
          itens: [
            for (final r in Raridade.values)
              Filtro(
                r.nome,
                selecionado: _raridade == r,
                onTap: () =>
                    setState(() => _raridade = _raridade == r ? null : r),
              ),
          ],
        ),
      ],
      itens: [
        for (final i in filtrados)
          CompendioTile(
            imagem: i.imagem,
            titulo: i.nome,
            subtitulo: [i.categoria, if (i.sintonia) 'sintonia'].join(' · '),
            corBorda: i.raridade.cor,
            lado: 44,
            trailing: RaridadeBadge(i.raridade),
            onTap: () => mostrarItem(context, i),
          ),
      ],
    );
  }
}
