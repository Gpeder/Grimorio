import 'package:grimorio/model/personagem.dart';

class GerenciadorHp {
  const GerenciadorHp();

  // hp temporario absorve primeiro
  Personagem receberDano(Personagem p, int valor) {
    final absorvido = valor.clamp(0, p.hpTemp);
    final restante = valor - absorvido;
    return p.copyWith(
      hpTemp: p.hpTemp - absorvido,
      hpAtual: (p.hpAtual - restante).clamp(0, p.hpMax),
    );
  }

  Personagem curar(Personagem p, int valor) =>
      p.copyWith(hpAtual: (p.hpAtual + valor).clamp(0, p.hpMax));

  Personagem definirTemp(Personagem p, int valor) =>
      p.copyWith(hpTemp: valor < 0 ? 0 : valor);

  // enche hp e libera os espacos
  Personagem descansoLongo(Personagem p) => p.copyWith(
    hpAtual: p.hpMax,
    hpTemp: 0,
    espacosDeMagia: [for (final e in p.espacosDeMagia) e.copyWith(usados: 0)],
  );
}
