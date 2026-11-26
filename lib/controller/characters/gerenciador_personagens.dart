import 'package:grimorio/model/character.dart';

class GerenciadorPersonagens {
  const GerenciadorPersonagens();

  List<Character> filtrar(List<Character> personagens, String busca) {
    final b = busca.trim().toLowerCase();
    return [
      for (final p in personagens)
        if (p.nome.toLowerCase().contains(b)) p,
    ];
  }

  // o novo vira o ativo
  List<Character> adicionarNovo(List<Character> personagens, Character novo) =>
      [for (final p in personagens) p.copyWith(ativo: false), novo];

  List<Character> trocar(List<Character> personagens, Character atualizado) => [
    for (final p in personagens) p.id == atualizado.id ? atualizado : p,
  ];
}
