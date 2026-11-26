import 'package:grimorio/model/personagem.dart';

class GerenciadorExp {
  const GerenciadorExp();

  static const nivelMaximo = 20;

  // valor negativo desfaz
  Personagem adicionar(Personagem p, int valor) => p.copyWith(xp: p.xp + valor);

  // nivel pela tabela de xp
  int nivelPorXp(int xp) {
    var nivel = 1;
    while (nivel < nivelMaximo && xp >= xpPorNivel[nivel]) {
      nivel++;
    }
    return nivel;
  }

  int faltaParaProximo(Personagem p) => p.xpProximoNivel - p.xp;
}
