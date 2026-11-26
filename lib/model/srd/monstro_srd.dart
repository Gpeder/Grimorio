import 'package:grimorio/model/json.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/service/api/api_rotas.dart';

// acao ou traco do statblock
class AcaoSrd {
  const AcaoSrd({required this.nome, this.descricao = ''});

  final String nome;
  final String descricao;

  factory AcaoSrd.fromJson(Map<String, dynamic> json) => AcaoSrd(
    nome: json['name'] as String? ?? '—',
    descricao: json['desc'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'name': nome, 'desc': descricao};
}

// criatura vinda de /creatures/
class MonstroSrd {
  const MonstroSrd({
    required this.key,
    required this.nome,
    this.tipo,
    this.tamanho,
    this.alinhamento,
    this.nd,
    this.xp,
    this.ca,
    this.caDetalhe,
    this.pv,
    this.pvDado,
    this.deslocamento = const {},
    this.atributos,
    this.tracos = const [],
    this.acoes = const [],
    this.imagem,
  });

  final String key;
  final String nome;
  final String? tipo;
  final String? tamanho;
  final String? alinhamento;

  // 0.25, 1, 10
  final double? nd;
  final int? xp;
  final int? ca;
  final String? caDetalhe;
  final int? pv;
  final String? pvDado;

  // walk, swim, fly em pes
  final Map<String, int> deslocamento;
  final Atributos? atributos;
  final List<AcaoSrd> tracos;
  final List<AcaoSrd> acoes;

  // url completa ou null
  final String? imagem;

  static const _atributos = {
    'strength': Atributo.forca,
    'dexterity': Atributo.destreza,
    'constitution': Atributo.constituicao,
    'intelligence': Atributo.inteligencia,
    'wisdom': Atributo.sabedoria,
    'charisma': Atributo.carisma,
  };

  static Atributos? _lerAtributos(Object? valor) {
    if (valor is! Map) return null;
    // atributo que falta vale 10
    int v(String chave) => lerInteiro(valor[chave]) ?? 10;
    return Atributos(
      forca: v('strength'),
      destreza: v('dexterity'),
      constituicao: v('constitution'),
      inteligencia: v('intelligence'),
      sabedoria: v('wisdom'),
      carisma: v('charisma'),
    );
  }

  factory MonstroSrd.fromJson(Map<String, dynamic> json) {
    final arquivo = switch (json['illustration']) {
      {'file_url': final String url} => ApiRotas.arquivo(url),
      _ => null,
    };
    return MonstroSrd(
      key: json['key'] as String? ?? '',
      nome: json['name'] as String? ?? '—',
      tipo: lerNome(json['type']),
      tamanho: lerNome(json['size']),
      alinhamento: json['alignment'] as String?,
      nd: lerNumero(json['challenge_rating']),
      xp: lerInteiro(json['experience_points']),
      ca: lerInteiro(json['armor_class']),
      caDetalhe: json['armor_detail'] as String?,
      pv: lerInteiro(json['hit_points']),
      pvDado: json['hit_dice'] as String?,
      deslocamento: {
        if (json['speed'] case final Map velocidade)
          for (final MapEntry(:key, :value) in velocidade.entries)
            if (key is String && value is num) key: value.toInt(),
      },
      atributos: _lerAtributos(json['ability_scores']),
      tracos: [for (final t in lerLista(json['traits'])) AcaoSrd.fromJson(t)],
      acoes: [for (final a in lerLista(json['actions'])) AcaoSrd.fromJson(a)],
      imagem: arquivo,
    );
  }

  Map<String, dynamic> toJson() {
    final a = atributos;
    return {
      'key': key,
      'name': nome,
      'type': tipo == null ? null : {'name': tipo},
      'size': tamanho == null ? null : {'name': tamanho},
      'alignment': alinhamento,
      'challenge_rating': nd,
      'experience_points': xp,
      'armor_class': ca,
      'armor_detail': caDetalhe,
      'hit_points': pv,
      'hit_dice': pvDado,
      'speed': deslocamento,
      'ability_scores': a == null
          ? null
          : {
              for (final MapEntry(key: nome, value: atributo)
                  in _atributos.entries)
                nome: a.valor(atributo),
            },
      'traits': [for (final t in tracos) t.toJson()],
      'actions': [for (final x in acoes) x.toJson()],
      'illustration': imagem == null ? null : {'file_url': imagem},
    };
  }
}
