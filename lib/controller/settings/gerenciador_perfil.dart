import 'package:grimorio/model/usuario.dart';

// o que do usuario vai para a tabela perfis
class GerenciadorPerfil {
  const GerenciadorPerfil();

  // vibrar, confirmar_apagar e compendio sao do aparelho
  static const colunas = {
    'nome',
    'avatar',
    'papel',
    'edicao',
    'magia',
    'subida',
    'dicas_bonus',
  };

  // so as colunas que mudaram, no formato do banco
  Map<String, dynamic> camposMudados(Usuario antes, Usuario depois) {
    final a = antes.toJson();
    final d = depois.toJson();
    return {
      for (final c in colunas)
        if (a[c] != d[c]) c: d[c],
    };
  }

  // desfaz so os campos que falharam, mantendo o que mudou depois
  Usuario voltarCampos(
    Usuario atual,
    Usuario anterior,
    Iterable<String> campos,
  ) {
    final velho = anterior.toJson();
    return Usuario.fromJson({
      ...atual.toJson(),
      for (final c in campos) c: velho[c],
    });
  }
}
