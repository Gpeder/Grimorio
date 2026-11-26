import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';

// linhas do statblock em pt-br, sem rolar nada
class GerenciadorMonstro {
  const GerenciadorMonstro();

  static final _ataque = RegExp(r'([+-]\d+) to hit');
  static final _dano = RegExp(
    r'\((\d+d\d+(?:\s*[+-]\s*\d+)?)\)\s+([a-z]+) damage',
    caseSensitive: false,
  );
  static final _salvaguarda = RegExp(r'DC (\d+) ([A-Z][a-z]+) saving throw');

  // +4 ou −1, com o menos do statblock
  String sinal(int v) => v < 0 ? '−${-v}' : '+$v';

  // 14 (+2)
  String atributo(int valor) => '$valor (${sinal(modificador(valor))})';

  // Ataque +14, 2d10 + 8 perfurante, Salv. DES CD 21
  List<String> bonus(AcaoSrd acao) {
    final d = acao.descricao;
    return [
      for (final m in _ataque.allMatches(d)) 'Ataque ${m.group(1)}',
      for (final m in _dano.allMatches(d))
        '${_dado(m.group(1) ?? '')} ${TraducaoSrd.tipoDano(m.group(2))}',
      for (final m in _salvaguarda.allMatches(d))
        'Salv. ${TraducaoSrd.siglaAtributo(m.group(2))} CD ${m.group(1)}',
    ];
  }

  // 2d10+8 vira 2d10 + 8
  String _dado(String dado) => dado
      .replaceAll(' ', '')
      .replaceAllMapped(RegExp(r'([+-])'), (m) => ' ${m.group(1)} ');

  // nome com a recarga, ex Fire Breath (Recarga 5–6)
  String nomeAcao(AcaoSrd acao) => switch (acao.recarga) {
    null => acao.nome,
    6 => '${acao.nome} (Recarga 6)',
    final r => '${acao.nome} (Recarga $r–6)',
  };

  // 12 m, voo 24 m
  String deslocamento(MonstroSrd m) {
    final d = m.deslocamento;
    if (d.isEmpty) return TraducaoSrd.vazio;
    return [
      if (d['walk'] case final andar?) TraducaoSrd.metros(andar),
      for (final MapEntry(:key, :value) in d.entries)
        if (key != 'walk' && value > 0)
          '${TraducaoSrd.movimento(key).toLowerCase()} ${TraducaoSrd.metros(value)}',
    ].join(', ');
  }

  // visao no escuro 36 m, percepcao passiva 23
  String sentidos(MonstroSrd m) => [
    for (final MapEntry(:key, :value) in m.sentidos.entries)
      '${TraducaoSrd.sentido(key)} ${TraducaoSrd.metros(value)}',
    if (m.percepcaoPassiva case final p?) 'Percepção passiva $p',
  ].join(', ');

  // DES +6, CON +13
  String salvaguardas(MonstroSrd m) => [
    for (final MapEntry(:key, :value) in m.salvaguardas.entries)
      '${TraducaoSrd.siglaAtributo(key)} ${sinal(value)}',
  ].join(', ');

  // Percepção +13, Furtividade +6
  String pericias(MonstroSrd m) => [
    for (final MapEntry(:key, :value) in m.pericias.entries)
      '${TraducaoSrd.pericia(key)} ${sinal(value)}',
  ].join(', ');

  // fire, poison vira fogo, veneno; o ; da api separa grupos
  String lista(String? texto, String Function(String?) traduzir) {
    if (texto == null || texto.trim().isEmpty) return TraducaoSrd.vazio;
    return texto
        .split(';')
        .map(
          (grupo) => grupo
              .split(RegExp(r',\s*'))
              .where((p) => p.trim().isNotEmpty)
              .map(traduzir)
              .join(', '),
        )
        .join('; ');
  }

  // Dragão Enorme, Caótico e Mau
  String linhaTipo(MonstroSrd m) {
    final tipo =
        '${TraducaoSrd.tipoMonstro(m.tipo)} '
        '${TraducaoSrd.tamanho(m.tamanho)}';
    final alinhamento = m.alinhamento;
    return alinhamento == null || alinhamento.isEmpty
        ? tipo
        : '$tipo, ${TraducaoSrd.alinhamento(alinhamento)}';
  }
}
