import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/grimoire.dart';

class GerenciadorInventario {
  const GerenciadorInventario();

  Character equipar(Character p, String itemId) {
    final item = p.inventario.where((i) => i.id == itemId).firstOrNull;
    final slot = item?.slotEquipavel;
    if (item == null || slot == null || item.equipado) return p;

    // anel tem 2 vagas, o resto 1
    final ocupantes = p.itensEm(slot);
    final limite = slot == EquipSlot.anel ? 2 : 1;
    final sai = ocupantes.length >= limite ? ocupantes.first : null;

    return p.copyWith(
      ca: p.ca + item.bonusCa - (sai?.bonusCa ?? 0),
      inventario: [
        for (final i in p.inventario)
          if (i.id == itemId)
            i.copyWith(equipadoEm: slot)
          else if (i.id == sai?.id)
            i.copyWith(desequipar: true)
          else
            i,
      ],
    );
  }

  Character desequipar(Character p, String itemId) {
    final item = p.inventario.where((i) => i.id == itemId).firstOrNull;
    if (item == null || !item.equipado) return p;
    return p.copyWith(
      ca: p.ca - item.bonusCa,
      inventario: [
        for (final i in p.inventario)
          i.id == itemId ? i.copyWith(desequipar: true) : i,
      ],
    );
  }

  // so gasta consumivel
  Character usar(Character p, String itemId) => p.copyWith(
    inventario: [
      for (final i in p.inventario)
        if (i.id != itemId || !i.consumivel)
          i
        else if (i.quantidade > 1)
          i.copyWith(quantidade: i.quantidade - 1),
    ],
  );

  Character remover(Character p, String itemId) {
    final item = p.inventario.where((i) => i.id == itemId).firstOrNull;
    if (item == null) return p;
    return p.copyWith(
      ca: p.ca - (item.equipado ? item.bonusCa : 0),
      inventario: [
        for (final i in p.inventario)
          if (i.id != itemId) i,
      ],
    );
  }

  // repetido soma na quantidade
  Character receber(Character p, InventoryItem item) {
    final existe = p.inventario.any((i) => i.id == item.id);
    if (!existe) return p.copyWith(inventario: [...p.inventario, item]);
    return p.copyWith(
      inventario: [
        for (final i in p.inventario)
          i.id == item.id
              ? i.copyWith(quantidade: i.quantidade + item.quantidade)
              : i,
      ],
    );
  }

  Character removerUmaUnidade(Character p, String itemId) {
    final item = p.inventario.where((i) => i.id == itemId).firstOrNull;
    if (item == null) return p;
    if (item.quantidade <= 1) return remover(p, itemId);
    return p.copyWith(
      inventario: [
        for (final i in p.inventario)
          i.id == itemId ? i.copyWith(quantidade: i.quantidade - 1) : i,
      ],
    );
  }

  Character definirMoedas(Character p, Moedas valor) =>
      p.copyWith(moedas: valor);

  // item do compendio vira item da mochila
  InventoryItem doCompendio(ItemCompendio i) => InventoryItem(
    id: i.key,
    nome: i.nome,
    imagem: i.imagem,
    consumivel: i.categoria == 'Poção',
    descricao: i.descricao,
  );
}
