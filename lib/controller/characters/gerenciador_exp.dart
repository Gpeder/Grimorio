import 'package:grimorio/model/character.dart';

class GerenciadorExp {
  const GerenciadorExp();

  static const nivelMaximo = 20;

  // valor negativo desfaz
  Character adicionar(Character p, int valor) => p.copyWith(xp: p.xp + valor);

  // nivel pela tabela de xp
  int nivelPorXp(int xp) {
    var nivel = 1;
    while (nivel < nivelMaximo && xp >= xpPorNivel[nivel]) {
      nivel++;
    }
    return nivel;
  }

  int faltaParaProximo(Character p) => p.xpProximoNivel - p.xp;
}
