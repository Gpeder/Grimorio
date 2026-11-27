import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/usuario.dart';

import '../fixtures/usuario_mock.dart';
import 'ida_e_volta.dart';

void main() {
  test('o usuário do mock volta igual', () {
    confereIdaEVolta(usuarioMock, (x) => x.toJson(), Usuario.fromJson);
  });

  test('opcional null e enum inválido não quebram', () {
    final json = pelaRede(usuarioMock.toJson())
      ..['avatar'] = null
      ..['compendio_atualizado_em'] = null
      ..['papel'] = 'rei'
      ..['magia'] = 7;

    final u = Usuario.fromJson(json);
    expect(u.avatar, isNull);
    expect(u.compendioAtualizadoEm, isNull);
    expect(u.papel, PapelMesa.jogador);
    expect(u.magia, SistemaMagia.espacos);
  });
}
