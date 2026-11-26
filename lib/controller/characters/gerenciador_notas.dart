import 'package:grimorio/model/character.dart';

class GerenciadorNotas {
  const GerenciadorNotas();

  Character adicionar(Character p, Nota nota) =>
      p.copyWith(notas: [...p.notas, nota]);

  Character remover(Character p, String id) => p.copyWith(
    notas: [
      for (final n in p.notas)
        if (n.id != id) n,
    ],
  );
}
