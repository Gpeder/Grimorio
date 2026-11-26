import 'package:grimorio/model/json.dart';
import 'package:grimorio/service/api/api_rotas.dart';

// condicao
class CondicaoSrd {
  const CondicaoSrd({
    required this.key,
    required this.nome,
    this.descricao = '',
    this.icone,
  });

  final String key;
  final String nome;
  final String descricao;

  // url completa do svg ou null
  final String? icone;

  factory CondicaoSrd.fromJson(Map<String, dynamic> json) => CondicaoSrd(
    key: json['key'] as String? ?? '',
    nome: json['name'] as String? ?? '—',
    descricao: [
      for (final d in lerLista(json['descriptions']))
        if (d['desc'] case final String texto) texto,
    ].join('\n\n'),
    icone: switch (json['icon']) {
      {'file_url': final String url} => ApiRotas.arquivo(url),
      _ => null,
    },
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'name': nome,
    'descriptions': [
      if (descricao.isNotEmpty) {'desc': descricao},
    ],
    'icon': icone == null ? null : {'file_url': icone},
  };
}
