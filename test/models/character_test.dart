import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/models/character.dart';
import 'package:grimorio/models/character_mock.dart';

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

  group('recuperarEspaco', () {
    test('devolve um espaço e não passa do total', () {
      final p = _personagem(
        espacosDeMagia: const [SpellSlot(circulo: 1, total: 2, usados: 1)],
      );
      final uma = p.recuperarEspaco(1);
      expect(uma.espacosDeMagia.single.livres, 2);
      expect(uma.recuperarEspaco(1).espacosDeMagia.single.livres, 2);
    });
  });

  group('inventário', () {
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

    test('usarItem diminui a quantidade e remove ao chegar a 0', () {
      final p = _personagem().copyWith(inventario: const [pocao]);
      final uma = p.usarItem('pocao');
      expect(uma.inventario.single.quantidade, 1);
      expect(uma.usarItem('pocao').inventario, isEmpty);
    });

    test('equipar e desequipar ajustam o slot e a CA', () {
      final p = _personagem().copyWith(inventario: const [escudo]);
      final equipado = p.equipar('escudo');
      expect(equipado.inventario.single.equipadoEm, EquipSlot.maoSecundaria);
      expect(equipado.ca, 12);

      final solto = equipado.desequipar('escudo');
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
      final p = _personagem().copyWith(inventario: const [outro, escudo]);
      final trocado = p.equipar('escudo');
      expect(trocado.itensEm(EquipSlot.maoSecundaria).single.id, 'escudo');
    });
  });

  test('alternarPreparada liga e desliga', () {
    final p = _personagem().alternarPreparada('bencao');
    expect(p.magiasPreparadas, {'bencao'});
    expect(p.alternarPreparada('bencao').magiasPreparadas, isEmpty);
  });

  test('adicionarNota e removerNota', () {
    final nota = Nota(
      id: 'n1',
      titulo: 'Pista',
      texto: 'A chave está no poço.',
      data: DateTime(2026, 11, 20),
    );
    final p = _personagem().adicionarNota(nota);
    expect(p.notas.single.titulo, 'Pista');
    expect(p.notas.single.data, DateTime(2026, 11, 20));
    expect(p.removerNota('n1').notas, isEmpty);
  });
}
