import 'package:grimorio/model/character.dart';

class GerenciadorCondicoes {
  const GerenciadorCondicoes();

  Character adicionar(Character p, Condition condicao) =>
      p.copyWith(condicoes: [...p.condicoes, condicao]);

  Character remover(Character p, String nome) => p.copyWith(
    condicoes: [
      for (final c in p.condicoes)
        if (c.nome != nome) c,
    ],
  );

  Character alternarInspiracao(Character p) =>
      p.copyWith(inspiracao: !p.inspiracao);
}
