import 'package:grimorio/model/personagem.dart';

class GerenciadorNotas {
  const GerenciadorNotas();

  Personagem adicionar(Personagem p, Nota nota) =>
      p.copyWith(notas: [...p.notas, nota]);

  Personagem remover(Personagem p, String id) => p.copyWith(
    notas: [
      for (final n in p.notas)
        if (n.id != id) n,
    ],
  );
}
