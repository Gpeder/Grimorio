import 'ida_e_volta.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/compendio_mock.dart';

void main() {
  test('monstros, itens e condições do mock voltam iguais', () {
    for (final m in monstrosMock) {
      confereIdaEVolta(m, (x) => x.toJson(), Monstro.fromJson);
      for (final a in m.acoes) {
        confereIdaEVolta(a, (x) => x.toJson(), AcaoMonstro.fromJson);
      }
    }
    for (final i in itensMock) {
      confereIdaEVolta(i, (x) => x.toJson(), ItemCompendio.fromJson);
    }
    for (final c in condicoesMock) {
      confereIdaEVolta(c, (x) => x.toJson(), CondicaoInfo.fromJson);
    }
  });

  test('opcional null e enum inválido não quebram', () {
    final item = pelaRede(itensMock.first.toJson())..['raridade'] = 'mítico';
    expect(ItemCompendio.fromJson(item).raridade, Raridade.comum);

    final acao = pelaRede(monstrosMock.first.acoes.first.toJson())
      ..['ataque'] = null
      ..['dano'] = null;
    final a = AcaoMonstro.fromJson(acao);
    expect(a.ataque, isNull);
    expect(a.dano, isNull);
  });
}
