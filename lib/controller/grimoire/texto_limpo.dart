// markdown simples da api vira texto corrido, sem pacote

final _negrito = RegExp(r'\*\*|__');
final _italico = RegExp(r'(?<![\w])_(?=\S)|(?<=\S)_(?![\w])');
final _titulo = RegExp(r'^\s{0,3}#{1,6}\s*', multiLine: true);
final _item = RegExp(r'^\s*[*-]\s+', multiLine: true);
final _separadorTabela = RegExp(r'^\s*\|?[\s:|-]+\|[\s:|-]*$');
final _espacos = RegExp(r'[ \t]+');
final _quebras = RegExp(r'\n{3,}');

// tira **, _ e #, lista vira bolinha, tabela vira linha com ·
String textoLimpo(String texto) {
  final linhas = <String>[];
  for (final bruta in texto.replaceAll('\r\n', '\n').split('\n')) {
    if (_separadorTabela.hasMatch(bruta)) continue;
    var l = bruta;
    if (l.trim().startsWith('|')) {
      l = l
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .join(' · ');
    }
    linhas.add(l);
  }
  return linhas
      .join('\n')
      .replaceAll(_negrito, '')
      .replaceAll(_italico, '')
      .replaceAll(_titulo, '')
      .replaceAll(_item, '• ')
      .replaceAll(_espacos, ' ')
      .replaceAll(_quebras, '\n\n')
      .trim();
}

// cada \n\n e um paragrafo
List<String> paragrafos(String texto) => [
  for (final p in textoLimpo(texto).split('\n\n'))
    if (p.trim().isNotEmpty) p.trim(),
];
