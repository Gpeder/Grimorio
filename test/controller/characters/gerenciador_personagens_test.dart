import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_personagens.dart';

import 'personagem_teste.dart';

void main() {
  const personagens = GerenciadorPersonagens();
  final a = personagemTeste().copyWith(id: 'a', nome: 'Elyndra', ativo: true);
  final b = personagemTeste().copyWith(id: 'b', nome: 'Thorgar');

  test('filtrar ignora maiúscula e espaço', () {
    expect(personagens.filtrar([a, b], ' ELY ').single.id, 'a');
  });

  test('busca vazia mostra todos', () {
    expect(personagens.filtrar([a, b], ''), hasLength(2));
  });

  test('o novo herói vira o único ativo', () {
    final lista = personagens.adicionarNovo([a], b.copyWith(ativo: true));
    expect(lista.where((p) => p.ativo).single.id, 'b');
  });

  test('trocar substitui pelo id', () {
    final lista = personagens.trocar([a, b], b.copyWith(nome: 'Novo'));
    expect(lista.last.nome, 'Novo');
    expect(lista, hasLength(2));
  });
}
