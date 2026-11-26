import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_magias.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/character_mock.dart';

import 'personagem_teste.dart';

void main() {
  const magias = GerenciadorMagias();

  group('espaços', () {
    test('gastar usa um espaço', () {
      final p = personagemTeste(
        espacosDeMagia: const [SpellSlot(circulo: 1, total: 2)],
      );
      expect(magias.gastarEspaco(p, 1).espacosDeMagia.single.livres, 1);
    });

    test('gastar não passa do total', () {
      final p = personagemTeste(
        espacosDeMagia: const [SpellSlot(circulo: 1, total: 2, usados: 2)],
      );
      expect(magias.gastarEspaco(p, 1).espacosDeMagia.single.usados, 2);
    });

    test('recuperar devolve um espaço e não passa do total', () {
      final p = personagemTeste(
        espacosDeMagia: const [SpellSlot(circulo: 1, total: 2, usados: 1)],
      );
      final uma = magias.recuperarEspaco(p, 1);
      expect(uma.espacosDeMagia.single.livres, 2);
      expect(magias.recuperarEspaco(uma, 1).espacosDeMagia.single.livres, 2);
    });
  });

  test('alternarPreparada liga e desliga', () {
    final p = magias.alternarPreparada(personagemTeste(), 'bencao');
    expect(p.magiasPreparadas, {'bencao'});
    expect(magias.alternarPreparada(p, 'bencao').magiasPreparadas, isEmpty);
  });

  group('filtrar', () {
    test('ordena por círculo e depois por nome', () {
      final lista = magias.filtrar(personagemAtivoMock);
      final circulos = lista.map((m) => m.circulo).toList();
      expect(circulos, [...circulos]..sort());
    });

    test('só preparadas inclui truques e esconde as não preparadas', () {
      final p = personagemAtivoMock;
      final lista = magias.filtrar(p, soPreparadas: true);
      expect(lista.every((m) => magias.preparada(p, m)), isTrue);
      expect(lista.any((m) => m.circulo == 0), isTrue);
    });

    test('sem magias conhecidas volta vazio', () {
      expect(magias.filtrar(personagemTeste(), circulo: 1), isEmpty);
    });
  });
}
