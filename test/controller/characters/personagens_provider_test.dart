import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/model/personagem_mock.dart';

import 'personagem_teste.dart';

void main() {
  test('começa com os mocks', () {
    final p = PersonagensProvider();
    expect(p.meus.map((x) => x.id), personagensMock.map((x) => x.id));
    expect(p.todos, hasLength(todosPersonagensMock.length));
  });

  test('adicionar notifica e o novo vira o único ativo', () {
    final p = PersonagensProvider();
    var avisos = 0;
    p.addListener(() => avisos++);

    final novo = personagemTeste().copyWith(id: 'novo', ativo: true);
    p.adicionar(novo);

    expect(avisos, 1);
    expect(p.meus.last.id, 'novo');
    expect(p.meus.where((x) => x.ativo).single.id, 'novo');
    expect(p.porId('novo'), isNotNull);
  });

  test('atualizar troca pelo id', () {
    final p = PersonagensProvider();
    final elyndra = p.porId(personagemAtivoMock.id)!;
    p.atualizar(elyndra.copyWith(xp: 1));
    expect(p.porId(elyndra.id)!.xp, 1);
  });

  test('id que não existe volta null', () {
    expect(PersonagensProvider().porId('nao-existe'), isNull);
  });

  test('adotarMock passa os heróis do mock para o usuário logado', () {
    final p = PersonagensProvider();
    final antes = p.todos.where((x) => x.donoId == usuarioMock.id).length;
    expect(antes, greaterThan(0));

    p.adotarMock('uuid-real');
    expect(p.todos.where((x) => x.donoId == usuarioMock.id), isEmpty);
    expect(p.todos.where((x) => x.donoId == 'uuid-real'), hasLength(antes));

    // outra conta logada herda de novo
    p.adotarMock('outra');
    expect(p.todos.where((x) => x.donoId == 'outra'), hasLength(antes));
  });
}
