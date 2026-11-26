import 'ida_e_volta.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/model/personagem.dart';

void main() {
  test('espécies, classes, antecedentes, perícias e magias voltam iguais', () {
    for (final e in especiesMock) {
      confereIdaEVolta(e, (x) => x.toJson(), OpcaoEspecie.fromJson);
      for (final s in e.subespecies) {
        confereIdaEVolta(s, (x) => x.toJson(), OpcaoSubespecie.fromJson);
      }
    }
    for (final c in classesMock) {
      confereIdaEVolta(c, (x) => x.toJson(), OpcaoClasse.fromJson);
      for (final s in c.subclasses) {
        confereIdaEVolta(s, (x) => x.toJson(), OpcaoSubclasse.fromJson);
      }
      for (final e in c.equipamento) {
        confereIdaEVolta(e, (x) => x.toJson(), EscolhaEquipamento.fromJson);
        for (final i in e.opcoes) {
          confereIdaEVolta(i, (x) => x.toJson(), ItemEquipamento.fromJson);
        }
      }
    }
    for (final a in antecedentesMock) {
      confereIdaEVolta(a, (x) => x.toJson(), OpcaoAntecedente.fromJson);
    }
    for (final p in periciasMock) {
      confereIdaEVolta(p, (x) => x.toJson(), OpcaoPericia.fromJson);
    }
    for (final m in magiasMock) {
      confereIdaEVolta(m, (x) => x.toJson(), OpcaoMagia.fromJson);
    }
  });

  test('bônus com atributo inválido é ignorado', () {
    final json = pelaRede(especiesMock.first.toJson())
      ..['bonus'] = {'constituicao': 2, 'sorte': 1}
      ..['nome_f'] = null
      ..['visao_no_escuro_m'] = null;

    final e = OpcaoEspecie.fromJson(json);
    expect(e.bonus, {Atributo.constituicao: 2});
    expect(e.nomeF, isNull);
    expect(e.visaoNoEscuroM, isNull);
  });

  test('item com slot inválido fica sem slot', () {
    const escudo = ItemEquipamento(
      key: 'escudo',
      nome: 'Escudo',
      imagem: '',
      slot: SlotEquipamento.maoSecundaria,
      armadura: TipoArmadura.escudo,
    );
    final json = pelaRede(escudo.toJson())
      ..['slot'] = 'cabeca'
      ..['armadura'] = 'papel';
    final i = ItemEquipamento.fromJson(json);
    expect(i.slot, isNull);
    expect(i.armadura, isNull);
  });
}
