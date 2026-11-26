import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/settings/usuario_provider.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';

void main() {
  test('começa com o usuário do mock', () {
    expect(UsuarioProvider().usuario.id, usuarioMock.id);
  });

  test('atualizar troca e notifica', () {
    final u = UsuarioProvider();
    var avisos = 0;
    u.addListener(() => avisos++);
    u.atualizar(u.usuario.copyWith(magia: SistemaMagia.pontos));
    expect(u.usuario.magia, SistemaMagia.pontos);
    expect(avisos, 1);
  });
}
