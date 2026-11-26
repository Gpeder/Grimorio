import 'package:grimorio/model/personagem.dart';

class GerenciadorPersonagens {
  const GerenciadorPersonagens();

  List<Personagem> filtrar(List<Personagem> personagens, String busca) {
    final b = busca.trim().toLowerCase();
    return [
      for (final p in personagens)
        if (p.nome.toLowerCase().contains(b)) p,
    ];
  }

  // o novo vira o ativo
  List<Personagem> adicionarNovo(
    List<Personagem> personagens,
    Personagem novo,
  ) => [for (final p in personagens) p.copyWith(ativo: false), novo];

  List<Personagem> trocar(
    List<Personagem> personagens,
    Personagem atualizado,
  ) => [for (final p in personagens) p.id == atualizado.id ? atualizado : p];

  // troca pelo id, quem nao mudou fica
  List<Personagem> trocarTodos(
    List<Personagem> personagens,
    List<Personagem> alterados,
  ) {
    final porId = {for (final h in alterados) h.id: h};
    return [for (final p in personagens) porId[p.id] ?? p];
  }
}
