import 'package:grimorio/model/personagem.dart';

class GerenciadorCondicoes {
  const GerenciadorCondicoes();

  Personagem adicionar(Personagem p, Condicao condicao) =>
      p.copyWith(condicoes: [...p.condicoes, condicao]);

  Personagem remover(Personagem p, String nome) => p.copyWith(
    condicoes: [
      for (final c in p.condicoes)
        if (c.nome != nome) c,
    ],
  );

  Personagem alternarInspiracao(Personagem p) =>
      p.copyWith(inspiracao: !p.inspiracao);
}
