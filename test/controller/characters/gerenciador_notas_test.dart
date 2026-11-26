import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_notas.dart';
import 'package:grimorio/model/character.dart';

import 'personagem_teste.dart';

void main() {
  const notas = GerenciadorNotas();
  final nota = Nota(
    id: 'n1',
    titulo: 'Pista',
    texto: 'A chave está no poço.',
    data: DateTime(2026, 11, 20),
  );

  test('adicionar e remover nota', () {
    final p = notas.adicionar(personagemTeste(), nota);
    expect(p.notas.single.titulo, 'Pista');
    expect(p.notas.single.data, DateTime(2026, 11, 20));
    expect(notas.remover(p, 'n1').notas, isEmpty);
  });

  test('remover id desconhecido mantém as notas', () {
    final p = notas.adicionar(personagemTeste(), nota);
    expect(notas.remover(p, 'x').notas, hasLength(1));
  });
}
