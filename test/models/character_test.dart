import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/models/character.dart';

const _atributos = AbilityScores(
  forca: 10,
  destreza: 10,
  constituicao: 10,
  inteligencia: 10,
  sabedoria: 10,
  carisma: 10,
);

CharacterClass _classe(int nivel, {String nome = 'Guerreiro'}) =>
    CharacterClass(apiKey: 'srd_x', nome: nome, nivel: nivel, dadoDeVida: 10);

Character _personagem({
  List<CharacterClass>? classes,
  int xp = 0,
  int hpMax = 30,
  int hpAtual = 30,
  int hpTemp = 0,
  List<SpellSlot> espacosDeMagia = const [],
}) => Character(
  id: 'teste',
  nome: 'Teste',
  retrato: '',
  especie: 'Humano',
  classes: classes ?? [_classe(1)],
  atributos: _atributos,
  xp: xp,
  hpMax: hpMax,
  hpAtual: hpAtual,
  hpTemp: hpTemp,
  ca: 10,
  deslocamentoM: 9,
  espacosDeMagia: espacosDeMagia,
);

void main() {
  group('nivel', () {
    test('soma os níveis de todas as classes', () {
      final p = _personagem(
        classes: [
          _classe(3),
          _classe(2, nome: 'Mago'),
        ],
      );
      expect(p.nivel, 5);
    });
  });

  group('bonusProficiencia', () {
    test('segue a tabela de 5e', () {
      const esperado = {1: 2, 4: 2, 5: 3, 8: 3, 9: 4, 13: 5, 17: 6, 20: 6};
      esperado.forEach((nivel, bonus) {
        final p = _personagem(classes: [_classe(nivel)]);
        expect(p.bonusProficiencia, bonus, reason: 'nível $nivel');
      });
    });
  });

  group('xpNivelAtual', () {
    test('é o XP mínimo do nível atual', () {
      expect(_personagem(classes: [_classe(1)]).xpNivelAtual, 0);
      expect(_personagem(classes: [_classe(5)]).xpNivelAtual, 6500);
      expect(_personagem(classes: [_classe(20)]).xpNivelAtual, 355000);
    });
  });

  group('xpProximoNivel', () {
    test('é o XP mínimo do próximo nível', () {
      expect(_personagem(classes: [_classe(1)]).xpProximoNivel, 300);
      expect(_personagem(classes: [_classe(5)]).xpProximoNivel, 14000);
    });

    test('no nível 20 fica no último valor da tabela', () {
      expect(_personagem(classes: [_classe(20)]).xpProximoNivel, 355000);
    });
  });

  group('receberDano', () {
    test('o HP temporário absorve o dano primeiro', () {
      final p = _personagem(hpAtual: 30, hpTemp: 5).receberDano(3);
      expect(p.hpTemp, 2);
      expect(p.hpAtual, 30);
    });

    test('o dano que sobra do HP temporário sai do HP atual', () {
      final p = _personagem(hpAtual: 30, hpTemp: 5).receberDano(8);
      expect(p.hpTemp, 0);
      expect(p.hpAtual, 27);
    });

    test('o HP atual não fica negativo', () {
      final p = _personagem(hpAtual: 10, hpTemp: 2).receberDano(50);
      expect(p.hpTemp, 0);
      expect(p.hpAtual, 0);
    });
  });

  group('curar', () {
    test('soma ao HP atual', () {
      expect(_personagem(hpMax: 38, hpAtual: 20).curar(5).hpAtual, 25);
    });

    test('não passa do HP máximo', () {
      expect(_personagem(hpMax: 38, hpAtual: 32).curar(10).hpAtual, 38);
    });
  });

  group('descansoLongo', () {
    test('restaura HP, zera HP temporário e libera os espaços de magia', () {
      final p = _personagem(
        hpMax: 38,
        hpAtual: 12,
        hpTemp: 4,
        espacosDeMagia: const [
          SpellSlot(circulo: 1, total: 4, usados: 3),
          SpellSlot(circulo: 2, total: 2, usados: 2),
        ],
      ).descansoLongo();

      expect(p.hpAtual, 38);
      expect(p.hpTemp, 0);
      expect(p.espacosDeMagia.map((e) => e.usados), everyElement(0));
      expect(p.espacosDeMagia.map((e) => e.total), [4, 2]);
    });
  });
}
