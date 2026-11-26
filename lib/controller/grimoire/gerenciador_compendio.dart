import 'package:grimorio/model/compendio.dart';
import 'package:grimorio/model/opcoes_heroi.dart';

enum FiltroItem { magicos, equipamento, armas, armaduras }

const _semAcento = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', //
  'é': 'e', 'ê': 'e', //
  'í': 'i', //
  'ó': 'o', 'ô': 'o', 'õ': 'o', //
  'ú': 'u', 'ü': 'u', //
  'ç': 'c',
};

class GerenciadorCompendio {
  const GerenciadorCompendio();

  // pocao acha poção
  String normalizar(String texto) => texto
      .toLowerCase()
      .split('')
      .map((c) => _semAcento[c] ?? c)
      .join()
      .trim();

  bool contem(String texto, String busca) =>
      normalizar(texto).contains(normalizar(busca));

  // circulo 4 = 4º ou mais
  List<OpcaoMagia> filtrarMagias(
    List<OpcaoMagia> magias, {
    String busca = '',
    int? circulo,
    String? classe,
    bool concentracao = false,
    bool ritual = false,
  }) =>
      [
        for (final m in magias)
          if (contem(m.nome, busca) &&
              switch (circulo) {
                null => true,
                4 => m.circulo >= 4,
                final c => m.circulo == c,
              } &&
              (classe == null || m.classes.contains(classe)) &&
              (!concentracao || m.concentracao) &&
              (!ritual || m.ritual))
            m,
      ]..sort((a, b) {
        final c = a.circulo.compareTo(b.circulo);
        return c != 0 ? c : normalizar(a.nome).compareTo(normalizar(b.nome));
      });

  List<ItemCompendio> filtrarItens(
    List<ItemCompendio> itens, {
    String busca = '',
    FiltroItem? tipo,
    Raridade? raridade,
  }) => [
    for (final i in itens)
      if (contem(i.nome, busca) &&
          switch (tipo) {
            null => true,
            FiltroItem.magicos => i.magico,
            FiltroItem.equipamento => !i.magico,
            FiltroItem.armas => i.categoria == 'Arma',
            FiltroItem.armaduras =>
              i.categoria == 'Armadura' || i.categoria == 'Escudo',
          } &&
          (raridade == null || i.raridade == raridade))
        i,
  ];

  // ordem por nd
  List<Monstro> filtrarMonstros(
    List<Monstro> monstros, {
    String busca = '',
    (double, double)? faixa,
    String? tipo,
  }) => [
    for (final m in monstros)
      if (contem(m.nome, busca) &&
          (faixa == null || (m.ndValor >= faixa.$1 && m.ndValor <= faixa.$2)) &&
          (tipo == null || m.tipo == tipo))
        m,
  ]..sort((a, b) => a.ndValor.compareTo(b.ndValor));
}
