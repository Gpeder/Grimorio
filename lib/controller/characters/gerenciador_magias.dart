import 'package:grimorio/model/character.dart';
import 'package:grimorio/model/hero_options.dart';
import 'package:grimorio/model/hero_options_mock.dart';

class GerenciadorMagias {
  const GerenciadorMagias();

  Character gastarEspaco(Character p, int circulo) => p.copyWith(
    espacosDeMagia: [
      for (final e in p.espacosDeMagia)
        e.circulo == circulo && e.livres > 0
            ? e.copyWith(usados: e.usados + 1)
            : e,
    ],
  );

  Character recuperarEspaco(Character p, int circulo) => p.copyWith(
    espacosDeMagia: [
      for (final e in p.espacosDeMagia)
        e.circulo == circulo && e.usados > 0
            ? e.copyWith(usados: e.usados - 1)
            : e,
    ],
  );

  Character alternarPreparada(Character p, String key) => p.copyWith(
    magiasPreparadas: p.magiasPreparadas.contains(key)
        ? p.magiasPreparadas.difference({key})
        : {...p.magiasPreparadas, key},
  );

  List<SpellOption> conhecidas(Character p) => [
    for (final k in p.magias) ?magiaPorKey(k),
  ];

  // truque conta como preparado
  bool preparada(Character p, SpellOption m) =>
      m.circulo == 0 || p.magiasPreparadas.contains(m.key);

  // por circulo e depois nome
  List<SpellOption> filtrar(
    Character p, {
    bool soPreparadas = false,
    int? circulo,
  }) => [
    for (final m in conhecidas(p))
      if (soPreparadas
          ? preparada(p, m)
          : circulo == null || m.circulo == circulo)
        m,
  ]..sort(_porCirculoENome);

  static int _porCirculoENome(SpellOption a, SpellOption b) {
    final c = a.circulo.compareTo(b.circulo);
    return c != 0 ? c : a.nome.compareTo(b.nome);
  }
}
