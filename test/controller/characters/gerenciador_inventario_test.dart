import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_inventario.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/grimoire.dart';

import 'personagem_teste.dart';

void main() {
  const inventario = GerenciadorInventario();

  const pocao = InventoryItem(
    id: 'pocao',
    nome: 'Poção',
    imagem: '',
    quantidade: 2,
    consumivel: true,
  );
  const escudo = InventoryItem(
    id: 'escudo',
    nome: 'Escudo',
    imagem: '',
    slot: EquipSlot.maoSecundaria,
    bonusCa: 2,
  );

  test('usar diminui a quantidade e remove ao chegar a 0', () {
    final p = personagemTeste(inventario: const [pocao]);
    final uma = inventario.usar(p, 'pocao');
    expect(uma.inventario.single.quantidade, 1);
    expect(inventario.usar(uma, 'pocao').inventario, isEmpty);
  });

  test('equipar e desequipar ajustam o slot e a CA', () {
    final p = personagemTeste(inventario: const [escudo]);
    final equipado = inventario.equipar(p, 'escudo');
    expect(equipado.inventario.single.equipadoEm, EquipSlot.maoSecundaria);
    expect(equipado.ca, 12);

    final solto = inventario.desequipar(equipado, 'escudo');
    expect(solto.inventario.single.equipado, isFalse);
    expect(solto.ca, 10);
  });

  test('equipar troca o item que estava no mesmo slot', () {
    const outro = InventoryItem(
      id: 'outro',
      nome: 'Adaga',
      imagem: '',
      slot: EquipSlot.maoSecundaria,
      equipadoEm: EquipSlot.maoSecundaria,
    );
    final p = personagemTeste(inventario: const [outro, escudo]);
    final trocado = inventario.equipar(p, 'escudo');
    expect(trocado.itensEm(EquipSlot.maoSecundaria).single.id, 'escudo');
  });

  test('receber item repetido soma na quantidade', () {
    final p = inventario.receber(
      personagemTeste(inventario: const [pocao]),
      pocao,
    );
    expect(p.inventario.single.quantidade, 4);
  });

  test('removerUmaUnidade tira a linha quando sobra 1', () {
    const uma = InventoryItem(id: 'x', nome: 'X', imagem: '');
    final p = personagemTeste(inventario: const [uma]);
    expect(inventario.removerUmaUnidade(p, 'x').inventario, isEmpty);
  });

  test('remover item equipado devolve a CA', () {
    final p = inventario.equipar(
      personagemTeste(inventario: const [escudo]),
      'escudo',
    );
    expect(inventario.remover(p, 'escudo').ca, 10);
  });

  test('doCompendio marca poção como consumível', () {
    const item = ItemCompendio(
      key: 'p',
      nome: 'Poção',
      categoria: 'Poção',
      raridade: Raridade.comum,
      descricao: '',
      imagem: '',
    );
    expect(inventario.doCompendio(item).consumivel, isTrue);
  });
}
