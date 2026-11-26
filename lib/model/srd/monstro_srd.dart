import 'package:grimorio/model/json.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/service/api/api_rotas.dart';

// acao ou traco do statblock
class AcaoSrd {
  const AcaoSrd({
    required this.nome,
    this.descricao = '',
    this.tipo,
    this.ordem,
    this.recarga,
  });

  final String nome;
  final String descricao;

  // ACTION, BONUS_ACTION, REACTION, LEGENDARY_ACTION; traco nao tem
  final String? tipo;
  final int? ordem;

  // recarga 5 = 5–6 no d6
  final int? recarga;

  static const acao = 'ACTION';
  static const bonus = 'BONUS_ACTION';
  static const reacao = 'REACTION';
  static const lendaria = 'LEGENDARY_ACTION';

  factory AcaoSrd.fromJson(Map<String, dynamic> json) => AcaoSrd(
    nome: json['name'] as String? ?? '—',
    descricao: json['desc'] as String? ?? '',
    tipo: json['action_type'] as String?,
    ordem: lerInteiro(json['order_in_statblock']),
    recarga: switch (json['usage_limits']) {
      {'type': 'RECHARGE_ON_ROLL', 'param': final num p} => p.toInt(),
      _ => null,
    },
  );

  Map<String, dynamic> toJson() => {
    'name': nome,
    'desc': descricao,
    'action_type': tipo,
    'order_in_statblock': ordem,
    'usage_limits': recarga == null
        ? null
        : {'type': 'RECHARGE_ON_ROLL', 'param': recarga},
  };
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
    this.salvaguardas = const {},
    this.pericias = const {},
    this.sentidos = const {},
    this.percepcaoPassiva,
    this.idiomas,
    this.imunidades,
    this.resistencias,
    this.vulnerabilidades,
    this.imunidadesCondicao,
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

  // dexterity: 6, perception: 13
  final Map<String, int> salvaguardas;
  final Map<String, int> pericias;

  // darkvision: 120 em pes
  final Map<String, int> sentidos;
  final int? percepcaoPassiva;

  // texto pronto da api, ex Common, Draconic
  final String? idiomas;

  // fire, poison; texto da api
  final String? imunidades;
  final String? resistencias;
  final String? vulnerabilidades;
  final String? imunidadesCondicao;

  final List<AcaoSrd> tracos;
  final List<AcaoSrd> acoes;

  // url completa ou null
  final String? imagem;

  // acoes por tipo, na ordem do statblock
  List<AcaoSrd> acoesDo(String tipo) =>
      [
        for (final a in acoes)
          if ((a.tipo ?? AcaoSrd.acao) == tipo) a,
      ]..sort((a, b) {
        final o = (a.ordem ?? 0).compareTo(b.ordem ?? 0);
        return o != 0 ? o : a.nome.compareTo(b.nome);
      });

  static const _atributos = {
    'strength': Atributo.forca,
    'dexterity': Atributo.destreza,
    'constitution': Atributo.constituicao,
    'intelligence': Atributo.inteligencia,
    'wisdom': Atributo.sabedoria,
    'charisma': Atributo.carisma,
  };

  static const _sentidos = [
    'darkvision',
    'blindsight',
    'tremorsense',
    'truesight',
  ];

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

  static Map<String, int> _numeros(Object? valor) => {
    if (valor is Map)
      for (final MapEntry(:key, :value) in valor.entries)
        if (key is String && value is num) key: value.toInt(),
  };

  static String? _texto(Object? valor) =>
      valor is String && valor.trim().isNotEmpty ? valor : null;

  factory MonstroSrd.fromJson(Map<String, dynamic> json) {
    final arquivo = switch (json['illustration']) {
      {'file_url': final String url} => ApiRotas.arquivo(url),
      _ => null,
    };
    final defesas = switch (json['resistances_and_immunities']) {
      final Map<String, dynamic> m => m,
      _ => const <String, dynamic>{},
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
      caDetalhe: _texto(json['armor_detail']),
      pv: lerInteiro(json['hit_points']),
      pvDado: json['hit_dice'] as String?,
      deslocamento: _numeros(json['speed']),
      atributos: _lerAtributos(json['ability_scores']),
      salvaguardas: _numeros(json['saving_throws']),
      pericias: _numeros(json['skill_bonuses']),
      sentidos: {
        for (final s in _sentidos)
          if (lerInteiro(json['${s}_range']) case final alcance?
              when alcance > 0)
            s: alcance,
      },
      percepcaoPassiva: lerInteiro(json['passive_perception']),
      idiomas: switch (json['languages']) {
        {'as_string': final String texto} => _texto(texto),
        _ => null,
      },
      imunidades: _texto(defesas['damage_immunities_display']),
      resistencias: _texto(defesas['damage_resistances_display']),
      vulnerabilidades: _texto(defesas['damage_vulnerabilities_display']),
      imunidadesCondicao: _texto(defesas['condition_immunities_display']),
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
      'saving_throws': salvaguardas,
      'skill_bonuses': pericias,
      for (final MapEntry(:key, :value) in sentidos.entries)
        '${key}_range': value,
      'passive_perception': percepcaoPassiva,
      'languages': idiomas == null ? null : {'as_string': idiomas},
      'resistances_and_immunities': {
        'damage_immunities_display': imunidades,
        'damage_resistances_display': resistencias,
        'damage_vulnerabilities_display': vulnerabilidades,
        'condition_immunities_display': imunidadesCondicao,
      },
      'traits': [for (final t in tracos) t.toJson()],
      'actions': [for (final x in acoes) x.toJson()],
      'illustration': imagem == null ? null : {'file_url': imagem},
    };
  }
}
