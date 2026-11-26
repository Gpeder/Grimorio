import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/character_mock.dart';

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

  group('magia', () {
    test('ataqueMagico e cdMagia da Elyndra (SAB 18, nível 5)', () {
      expect(personagemAtivoMock.atributoMagia, Ability.sabedoria);
      expect(personagemAtivoMock.ataqueMagico, 7);
      expect(personagemAtivoMock.cdMagia, 15);
    });

    test('classe sem magia não tem atributo de magia', () {
      expect(_personagem().atributoMagia, isNull);
    });
  });

  group('perícias', () {
    test('bonusPericia soma proficiência só quando proficiente', () {
      expect(personagemAtivoMock.bonusPericia('Medicina'), 7);
      expect(personagemAtivoMock.bonusPericia('Atletismo'), 1);
    });

    test('percepcaoPassiva = 10 + Percepção', () {
      expect(personagemAtivoMock.percepcaoPassiva, 14);
    });
  });

  group('danoArma', () {
    const maca = InventoryItem(
      id: 'maca',
      nome: 'Maça',
      imagem: '',
      dano: '1d6',
    );
    AbilityScores comForca(int forca) => AbilityScores(
      forca: forca,
      destreza: 10,
      constituicao: 10,
      inteligencia: 10,
      sabedoria: 10,
      carisma: 10,
    );

    test('mod positivo', () {
      final p = _personagem().copyWith(atributos: comForca(14));
      expect(p.danoArma(maca), '1d6 + 2');
      expect(p.ataqueArma(maca), 4);
    });

    test('mod zero', () {
      expect(_personagem().danoArma(maca), '1d6');
    });

    test('mod negativo', () {
      final p = _personagem().copyWith(atributos: comForca(8));
      expect(p.danoArma(maca), '1d6 − 1');
    });
  });
}
