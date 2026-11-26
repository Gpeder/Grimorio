import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/srd/classe_srd.dart';
import 'package:grimorio/model/srd/condicao_srd.dart';
import 'package:grimorio/model/srd/especie.dart';
import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';

import '../../helpers/dio_falso.dart';

Map<String, dynamic> primeiro(String arquivo) =>
    (fixture(arquivo)['results'] as List).first as Map<String, dynamic>;

void main() {
  group('json real da api', () {
    test('magia', () {
      final m = Magia.fromJson(primeiro('magias.json'));
      expect(m.key, 'srd_acid-arrow');
      expect(m.nivel, 2);
      expect(m.escola, 'Evocation');
      expect(m.alcance, '90 feet');
      expect(m.componentes, 'V, S, M');
      expect(m.classes, contains('Wizard'));
      expect(Magia.fromJson(m.toJson()).toJson(), m.toJson());
    });

    test('monstro com imagem', () {
      final m = MonstroSrd.fromJson(primeiro('monstros.json'));
      expect(m.nome, 'Aboleth');
      expect(m.nd, 10);
      expect(m.ca, 17);
      expect(m.pv, 135);
      expect(m.atributos?.forca, 21);
      expect(m.deslocamento['swim'], 40);
      expect(m.acoes, isNotEmpty);
      expect(m.idiomas, 'Deep Speech, telepathy 120 ft.');
      expect(m.sentidos, {'darkvision': 120});
      expect(m.percepcaoPassiva, 20);
      expect(m.salvaguardas['constitution'], 6);
      expect(m.pericias['history'], 12);
      expect(m.imunidades, isNull);
      expect(
        m.acoesDo(AcaoSrd.lendaria).map((a) => a.nome),
        contains('Tail Swipe'),
      );
      expect(m.acoesDo(AcaoSrd.acao).first.nome, 'Multiattack');
      expect(
        m.imagem,
        startsWith('https://api.open5e.com/static/img/object_illustrations/'),
      );
      expect(MonstroSrd.fromJson(m.toJson()).toJson(), m.toJson());
    });

    test('itens dos quatro tipos', () {
      final comum = ItemSrd.fromJson(primeiro('itens.json'));
      expect(comum.pesoLb, 2);
      expect(comum.categoria, 'Adventuring Gear');
      final magico = ItemSrd.fromJson(primeiro('itens_magicos.json'));
      expect(magico.raridade, 'Uncommon');
      final arma = ItemSrd.fromJson(primeiro('armas.json'));
      expect(arma.tipoDano, 'Slashing');
      final armadura = ItemSrd.fromJson(primeiro('armaduras.json'));
      expect(armadura.caTexto, '16');
      expect(armadura.categoriaArmadura, 'heavy');
      expect(armadura.forcaMinima, 13);
      expect(arma.propriedades.single.nome, 'Versatile');
      for (final i in [comum, magico, arma, armadura]) {
        expect(ItemSrd.fromJson(i.toJson()).toJson(), i.toJson());
      }
    });

    test('classe', () {
      final c = ClasseSrd.fromJson(primeiro('classes.json'));
      expect(c.nome, 'Barbarian');
      expect(c.dadoDeVida, 'D12');
      expect(c.salvaguardas, ['Constitution', 'Strength']);
      expect(c.subclasse, isFalse);
      expect(c.pvPrimeiroNivel, '12 + your Constitution modifier');
      expect(c.proficienciaNoNivel(1), '+2');
      expect(c.proficienciaNoNivel(5), '+3');
      expect(c.noNivel(1), containsAll(['Rage', 'Unarmored Defense']));
      expect(c.temEspacos, isFalse);
      expect(c.textoDo(CaracteristicaSrd.proficiencias), contains('Armor'));
      expect(ClasseSrd.fromJson(c.toJson()).toJson(), c.toJson());
    });

    test('espécie', () {
      final e = Especie.fromJson(primeiro('especies.json'));
      expect(e.nome, 'Dragonborn');
      expect(e.tracos.first.nome, 'Ability Score Increase');
      expect(Especie.fromJson(e.toJson()).toJson(), e.toJson());
    });

    test('condição com ícone', () {
      final c = CondicaoSrd.fromJson(primeiro('condicoes.json'));
      expect(c.nome, 'Blinded');
      expect(c.descricao, contains('blinded creature'));
      // so o texto do srd 2014, sem o de outros documentos
      expect(c.descricao, contains("can't see and automatically fails"));
      expect(c.descricao, isNot(contains('it automatically fails')));
      expect(c.icone, startsWith('https://api.open5e.com/static/'));
      expect(CondicaoSrd.fromJson(c.toJson()).toJson(), c.toJson());
    });
  });

  group('json sem os campos opcionais', () {
    test('nenhum model quebra', () {
      const vazio = <String, dynamic>{'key': 'k'};
      expect(Magia.fromJson(vazio).nome, '—');
      expect(Magia.fromJson(vazio).nivel, 0);
      expect(MonstroSrd.fromJson(vazio).imagem, isNull);
      expect(MonstroSrd.fromJson(vazio).atributos, isNull);
      expect(ItemSrd.fromJson(vazio).pesoLb, isNull);
      expect(ClasseSrd.fromJson(vazio).salvaguardas, isEmpty);
      expect(Especie.fromJson(vazio).tracos, isEmpty);
      expect(CondicaoSrd.fromJson(vazio).icone, isNull);
    });

    test('campo com formato estranho vira padrão', () {
      final m = MonstroSrd.fromJson({
        'key': 'k',
        'name': 'X',
        'type': 'Fera',
        'challenge_rating': '0.5',
        'illustration': null,
        'ability_scores': {'strength': 12},
      });
      expect(m.tipo, 'Fera');
      expect(m.nd, 0.5);
      expect(m.atributos?.forca, 12);
      expect(m.atributos?.destreza, 10);
    });
  });
}
