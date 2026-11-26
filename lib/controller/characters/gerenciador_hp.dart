import 'package:grimorio/model/character.dart';

class GerenciadorHp {
  const GerenciadorHp();

  // hp temporario absorve primeiro
  Character receberDano(Character p, int valor) {
    final absorvido = valor.clamp(0, p.hpTemp);
    final restante = valor - absorvido;
    return p.copyWith(
      hpTemp: p.hpTemp - absorvido,
      hpAtual: (p.hpAtual - restante).clamp(0, p.hpMax),
    );
  }

  Character curar(Character p, int valor) =>
      p.copyWith(hpAtual: (p.hpAtual + valor).clamp(0, p.hpMax));

  Character definirTemp(Character p, int valor) =>
      p.copyWith(hpTemp: valor < 0 ? 0 : valor);

  // enche hp e libera os espacos
  Character descansoLongo(Character p) => p.copyWith(
    hpAtual: p.hpMax,
    hpTemp: 0,
    espacosDeMagia: [for (final e in p.espacosDeMagia) e.copyWith(usados: 0)],
  );
}
