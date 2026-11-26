import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/personagem.dart';

class GerenciadorInventario {
  const GerenciadorInventario();

  Personagem equipar(Personagem p, String itemId) {
    final item = p.inventario.where((i) => i.id == itemId).firstOrNull;
    final slot = item?.slotEquipavel;
    if (item == null || slot == null || item.equipado) return p;

    // anel tem 2 vagas, o resto 1
    final ocupantes = p.itensEm(slot);
    final limite = slot == SlotEquipamento.anel ? 2 : 1;
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

  Personagem desequipar(Personagem p, String itemId) {
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
  Personagem usar(Personagem p, String itemId) => p.copyWith(
    inventario: [
      for (final i in p.inventario)
        if (i.id != itemId || !i.consumivel)
          i
        else if (i.quantidade > 1)
          i.copyWith(quantidade: i.quantidade - 1),
    ],
  );

  Personagem remover(Personagem p, String itemId) {
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
  Personagem receber(Personagem p, ItemInventario item) {
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

  Personagem removerUmaUnidade(Personagem p, String itemId) {
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

  Personagem definirMoedas(Personagem p, Moedas valor) =>
      p.copyWith(moedas: valor);

  // item do compendio vira item da mochila
  ItemInventario doCompendio(ItemCompendio i) => ItemInventario(
    id: i.key,
    nome: i.nome,
    imagem: i.imagem,
    consumivel: i.categoria == 'Poção',
    descricao: i.descricao,
  );
}
