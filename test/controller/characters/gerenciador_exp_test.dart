import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_exp.dart';

import 'personagem_teste.dart';

void main() {
  const exp = GerenciadorExp();

  group('adicionar', () {
    test('soma o xp', () {
      expect(exp.adicionar(personagemTeste(xp: 100), 250).xp, 350);
    });

    test('valor negativo desfaz', () {
      expect(exp.adicionar(personagemTeste(xp: 300), -300).xp, 0);
    });
  });

  group('nivelPorXp', () {
    test('sobe de nível no limite certo', () {
      final p = personagemTeste();
      expect(exp.nivelPorXp(exp.adicionar(p, 299).xp), 1);
      expect(exp.nivelPorXp(exp.adicionar(p, 300).xp), 2);
      expect(exp.nivelPorXp(6500), 5);
      expect(exp.nivelPorXp(6499), 4);
    });

    test('o xp que sobra conta para o próximo nível', () {
      final p = exp.adicionar(personagemTeste(xp: 250), 700);
      expect(p.xp, 950);
      expect(exp.nivelPorXp(p.xp), 3);
      expect(exp.nivelPorXp(exp.adicionar(p, 1750).xp), 4);
    });

    test('não passa do nível 20', () {
      expect(exp.nivelPorXp(355000), 20);
      expect(exp.nivelPorXp(9999999), 20);
    });
  });

  group('faltaParaProximo', () {
    test('é o xp do próximo nível menos o atual', () {
      expect(exp.faltaParaProximo(personagemTeste(xp: 120)), 180);
    });

    test('chega a zero quando pode subir', () {
      expect(exp.faltaParaProximo(personagemTeste(xp: 300)), 0);
    });
  });
}
