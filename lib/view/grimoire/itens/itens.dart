import 'package:flutter/material.dart';
import 'package:grimorio/view/grimoire/components/busca_compendio.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/view/grimoire/components/linha_compendio.dart';
import 'package:grimorio/view/grimoire/components/selo_raridade.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/itens/item_detalhe.dart';
import 'package:grimorio/model/grimoire.dart';
import 'package:grimorio/model/grimoire_mock.dart';

enum _Tipo { magicos, equipamento, armas, armaduras }

const _rotulos = {
  _Tipo.magicos: 'Mágicos',
  _Tipo.equipamento: 'Equipamento',
  _Tipo.armas: 'Armas',
  _Tipo.armaduras: 'Armaduras',
};

class Itens extends StatefulWidget {
  const Itens({super.key});

  @override
  State<Itens> createState() => _ItensState();
}

class _ItensState extends State<Itens> {
  String _busca = '';
  _Tipo? _tipo;
  Raridade? _raridade;

  bool _passa(ItemCompendio i) =>
      contem(i.nome, _busca) &&
      switch (_tipo) {
        null => true,
        _Tipo.magicos => i.magico,
        _Tipo.equipamento => !i.magico,
        _Tipo.armas => i.categoria == 'Arma',
        _Tipo.armaduras => i.categoria == 'Armadura' || i.categoria == 'Escudo',
      } &&
      (_raridade == null || i.raridade == _raridade);

  @override
  Widget build(BuildContext context) {
    final filtrados = itensMock.where(_passa).toList();

    return TelaLista(
      titulo: 'Itens',
      contagem: itensMock.length,
      dicaBusca: 'Buscar item',
      onBusca: (v) => setState(() => _busca = v),
      filtros: [
        Filtros(
          itens: [
            for (final t in _Tipo.values)
              Filtro(
                _rotulos[t]!,
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
          LinhaCompendio(
            imagem: i.imagem,
            titulo: i.nome,
            subtitulo: [i.categoria, if (i.sintonia) 'sintonia'].join(' · '),
            corBorda: i.raridade.cor,
            lado: 44,
            trailing: SeloRaridade(i.raridade),
            onTap: () => mostrarItem(context, i),
          ),
      ],
    );
  }
}
