import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_hp.dart';
import 'package:grimorio/model/character.dart';

import 'personagem_teste.dart';

void main() {
  const hp = GerenciadorHp();

  group('receberDano', () {
    test('o HP temporário absorve o dano primeiro', () {
      final p = hp.receberDano(personagemTeste(hpAtual: 30, hpTemp: 5), 3);
      expect(p.hpTemp, 2);
      expect(p.hpAtual, 30);
    });

    test('o dano que sobra do HP temporário sai do HP atual', () {
      final p = hp.receberDano(personagemTeste(hpAtual: 30, hpTemp: 5), 8);
      expect(p.hpTemp, 0);
      expect(p.hpAtual, 27);
    });

    test('o HP atual não fica abaixo de 0', () {
      final p = hp.receberDano(personagemTeste(hpAtual: 10, hpTemp: 2), 50);
      expect(p.hpTemp, 0);
      expect(p.hpAtual, 0);
    });
  });

  group('curar', () {
    test('soma ao HP atual', () {
      expect(hp.curar(personagemTeste(hpMax: 38, hpAtual: 20), 5).hpAtual, 25);
    });

    test('não passa do HP máximo', () {
      expect(hp.curar(personagemTeste(hpMax: 38, hpAtual: 32), 10).hpAtual, 38);
    });
  });

  group('definirTemp', () {
    test('guarda o valor', () {
      expect(hp.definirTemp(personagemTeste(), 6).hpTemp, 6);
    });

    test('negativo vira 0', () {
      expect(hp.definirTemp(personagemTeste(hpTemp: 4), -3).hpTemp, 0);
    });
  });

  test('descansoLongo restaura HP, zera o temporário e libera espaços', () {
    final p = hp.descansoLongo(
      personagemTeste(
        hpMax: 38,
        hpAtual: 12,
        hpTemp: 4,
        espacosDeMagia: const [
          SpellSlot(circulo: 1, total: 4, usados: 3),
          SpellSlot(circulo: 2, total: 2, usados: 2),
        ],
      ),
    );

    expect(p.hpAtual, 38);
    expect(p.hpTemp, 0);
    expect(p.espacosDeMagia.map((e) => e.usados), everyElement(0));
    expect(p.espacosDeMagia.map((e) => e.total), [4, 2]);
  });
}
