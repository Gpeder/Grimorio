import 'package:grimorio/model/json.dart';

enum EdicaoRegras {
  srd2014('SRD 5.1 (2014)'),
  srd2024('SRD 5.2 (2024)');

  const EdicaoRegras(this.label);
  final String label;
}

enum SistemaMagia {
  espacos('Espaços de magia'),
  pontos('Pontos de magia');

  const SistemaMagia(this.label);
  final String label;
}

enum SubidaNivel {
  xp('Por XP'),
  marcos('Por marcos');

  const SubidaNivel(this.label);
  final String label;
}

enum PapelMesa {
  jogador('Jogador'),
  mestre('Mestre'),
  ambos('Mestre e Jogador');

  const PapelMesa(this.label);
  final String label;
}

class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.avatar,
    this.papel = PapelMesa.jogador,
    this.edicao = EdicaoRegras.srd2014,
    this.magia = SistemaMagia.espacos,
    this.subida = SubidaNivel.xp,
    this.dicasBonus = true,
    this.vibrar = true,
    this.confirmarApagar = true,
    this.compendioAtualizadoEm,
  });

  final String id;
  final String nome;
  final String email;
  final String? avatar;
  final PapelMesa papel;
  final EdicaoRegras edicao;
  final SistemaMagia magia;
  final SubidaNivel subida;
  final bool dicasBonus;
  final bool vibrar;
  final bool confirmarApagar;
  final DateTime? compendioAtualizadoEm;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as String? ?? '',
    nome: json['nome'] as String? ?? '',
    email: json['email'] as String? ?? '',
    avatar: json['avatar'] as String?,
    papel: lerEnum(PapelMesa.values, json['papel'], PapelMesa.jogador),
    edicao: lerEnum(EdicaoRegras.values, json['edicao'], EdicaoRegras.srd2014),
    magia: lerEnum(SistemaMagia.values, json['magia'], SistemaMagia.espacos),
    subida: lerEnum(SubidaNivel.values, json['subida'], SubidaNivel.xp),
    dicasBonus: json['dicas_bonus'] as bool? ?? true,
    vibrar: json['vibrar'] as bool? ?? true,
    confirmarApagar: json['confirmar_apagar'] as bool? ?? true,
    compendioAtualizadoEm: lerDataOuNulo(json['compendio_atualizado_em']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'email': email,
    'avatar': avatar,
    'papel': papel.name,
    'edicao': edicao.name,
    'magia': magia.name,
    'subida': subida.name,
    'dicas_bonus': dicasBonus,
    'vibrar': vibrar,
    'confirmar_apagar': confirmarApagar,
    'compendio_atualizado_em': compendioAtualizadoEm?.toIso8601String(),
  };

  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? avatar,
    PapelMesa? papel,
    EdicaoRegras? edicao,
    SistemaMagia? magia,
    SubidaNivel? subida,
    bool? dicasBonus,
    bool? vibrar,
    bool? confirmarApagar,
    DateTime? compendioAtualizadoEm,
  }) => Usuario(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    email: email ?? this.email,
    avatar: avatar ?? this.avatar,
    papel: papel ?? this.papel,
    edicao: edicao ?? this.edicao,
    magia: magia ?? this.magia,
    subida: subida ?? this.subida,
    dicasBonus: dicasBonus ?? this.dicasBonus,
    vibrar: vibrar ?? this.vibrar,
    confirmarApagar: confirmarApagar ?? this.confirmarApagar,
    compendioAtualizadoEm: compendioAtualizadoEm ?? this.compendioAtualizadoEm,
  );
}
