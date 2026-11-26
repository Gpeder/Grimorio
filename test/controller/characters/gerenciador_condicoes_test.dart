import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_condicoes.dart';
import 'package:grimorio/model/character.dart';

import 'personagem_teste.dart';

void main() {
  const condicoes = GerenciadorCondicoes();

  test('adicionar e remover condição', () {
    final p = condicoes.adicionar(
      personagemTeste(),
      const Condition(nome: 'Caído'),
    );
    expect(p.condicoes.single.nome, 'Caído');
    expect(condicoes.remover(p, 'Caído').condicoes, isEmpty);
  });

  test('remover condição que não existe não muda nada', () {
    final p = condicoes.adicionar(
      personagemTeste(),
      const Condition(nome: 'Caído'),
    );
    expect(condicoes.remover(p, 'Cego').condicoes, hasLength(1));
  });

  test('alternarInspiracao liga e desliga', () {
    final p = condicoes.alternarInspiracao(personagemTeste());
    expect(p.inspiracao, isTrue);
    expect(condicoes.alternarInspiracao(p).inspiracao, isFalse);
  });
}
