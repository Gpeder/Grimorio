import 'package:grimorio/model/opcoes_heroi.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/model/personagem.dart';

class GerenciadorMagias {
  const GerenciadorMagias();

  Personagem gastarEspaco(Personagem p, int circulo) => p.copyWith(
    espacosDeMagia: [
      for (final e in p.espacosDeMagia)
        e.circulo == circulo && e.livres > 0
            ? e.copyWith(usados: e.usados + 1)
            : e,
    ],
  );

  Personagem recuperarEspaco(Personagem p, int circulo) => p.copyWith(
    espacosDeMagia: [
      for (final e in p.espacosDeMagia)
        e.circulo == circulo && e.usados > 0
            ? e.copyWith(usados: e.usados - 1)
            : e,
    ],
  );

  Personagem alternarPreparada(Personagem p, String key) => p.copyWith(
    magiasPreparadas: p.magiasPreparadas.contains(key)
        ? p.magiasPreparadas.difference({key})
        : {...p.magiasPreparadas, key},
  );

  List<OpcaoMagia> conhecidas(Personagem p) => [
    for (final k in p.magias) ?magiaPorKey(k),
  ];

  // truque conta como preparado
  bool preparada(Personagem p, OpcaoMagia m) =>
      m.circulo == 0 || p.magiasPreparadas.contains(m.key);

  // por circulo e depois nome
  List<OpcaoMagia> filtrar(
    Personagem p, {
    bool soPreparadas = false,
    int? circulo,
  }) => [
    for (final m in conhecidas(p))
      if (soPreparadas
          ? preparada(p, m)
          : circulo == null || m.circulo == circulo)
        m,
  ]..sort(_porCirculoENome);

  static int _porCirculoENome(OpcaoMagia a, OpcaoMagia b) {
    final c = a.circulo.compareTo(b.circulo);
    return c != 0 ? c : a.nome.compareTo(b.nome);
  }
}
