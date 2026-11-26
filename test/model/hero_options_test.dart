import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/hero_options.dart';
import 'package:grimorio/model/hero_options_mock.dart';

import 'ida_e_volta.dart';

void main() {
  test('espécies, classes, antecedentes, perícias e magias voltam iguais', () {
    for (final e in especiesMock) {
      confereIdaEVolta(e, (x) => x.toJson(), SpeciesOption.fromJson);
      for (final s in e.subespecies) {
        confereIdaEVolta(s, (x) => x.toJson(), SubspeciesOption.fromJson);
      }
    }
    for (final c in classesMock) {
      confereIdaEVolta(c, (x) => x.toJson(), ClassOption.fromJson);
      for (final s in c.subclasses) {
        confereIdaEVolta(s, (x) => x.toJson(), SubclassOption.fromJson);
      }
      for (final e in c.equipamento) {
        confereIdaEVolta(e, (x) => x.toJson(), EquipmentChoice.fromJson);
        for (final i in e.opcoes) {
          confereIdaEVolta(i, (x) => x.toJson(), EquipmentItem.fromJson);
        }
      }
    }
    for (final a in antecedentesMock) {
      confereIdaEVolta(a, (x) => x.toJson(), BackgroundOption.fromJson);
    }
    for (final p in periciasMock) {
      confereIdaEVolta(p, (x) => x.toJson(), SkillOption.fromJson);
    }
    for (final m in magiasMock) {
      confereIdaEVolta(m, (x) => x.toJson(), SpellOption.fromJson);
    }
  });

  test('bônus com atributo inválido é ignorado', () {
    final json = pelaRede(especiesMock.first.toJson())
      ..['bonus'] = {'constituicao': 2, 'sorte': 1}
      ..['nome_f'] = null
      ..['visao_no_escuro_m'] = null;

    final e = SpeciesOption.fromJson(json);
    expect(e.bonus, {Ability.constituicao: 2});
    expect(e.nomeF, isNull);
    expect(e.visaoNoEscuroM, isNull);
  });

  test('item com slot inválido fica sem slot', () {
    const escudo = EquipmentItem(
      key: 'escudo',
      nome: 'Escudo',
      imagem: '',
      slot: EquipSlot.maoSecundaria,
      armadura: TipoArmadura.escudo,
    );
    final json = pelaRede(escudo.toJson())
      ..['slot'] = 'cabeca'
      ..['armadura'] = 'papel';
    final i = EquipmentItem.fromJson(json);
    expect(i.slot, isNull);
    expect(i.armadura, isNull);
  });
}
