import 'package:flutter_test/flutter_test.dart';
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
}
