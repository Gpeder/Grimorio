import 'package:grimorio/model/json.dart' as json;
import 'package:grimorio/model/personagem.dart';

class GerenciadorPersonagens {
  const GerenciadorPersonagens();

  // colunas que o dono edita direto; dono e campanha so por rpc
  static const colunas = {
    'ativo',
    'nome',
    'retrato',
    'especie',
    'antecedente',
    'alinhamento',
    'historia',
    'xp',
    'hp_max',
    'hp_atual',
    'hp_temp',
    'ca',
    'deslocamento_m',
    'inspiracao',
    'classes',
    'atributos',
    'salvaguardas',
    'pericias',
    'idiomas',
    'magias',
    'magias_preparadas',
    'espacos_de_magia',
    'inventario',
    'condicoes',
    'moedas',
  };

  // so o que mudou, no formato do banco
  Map<String, dynamic> camposMudados(Personagem antes, Personagem depois) =>
      json.camposMudados(antes.toJson(), depois.toJson(), colunas);

  // desfaz so os campos que falharam, mantendo o que mudou depois
  Personagem voltarCampos(
    Personagem atual,
    Personagem anterior,
    Iterable<String> campos,
  ) {
    final velho = anterior.toJson();
    return Personagem.fromJson({
      ...atual.toJson(),
      for (final c in campos) c: velho[c],
    });
  }

  // sem campanha (copyWith nao zera campo)
  Personagem semCampanha(Personagem p) =>
      Personagem.fromJson({...p.toJson(), 'campanha_id': null});

  List<Personagem> filtrar(List<Personagem> personagens, String busca) {
    final b = busca.trim().toLowerCase();
    return [
      for (final p in personagens)
        if (p.nome.toLowerCase().contains(b)) p,
    ];
  }

  // o novo vira o ativo
  List<Personagem> adicionarNovo(
    List<Personagem> personagens,
    Personagem novo,
  ) => [for (final p in personagens) p.copyWith(ativo: false), novo];

  List<Personagem> trocar(
    List<Personagem> personagens,
    Personagem atualizado,
  ) => [for (final p in personagens) p.id == atualizado.id ? atualizado : p];

  // troca pelo id, quem nao mudou fica
  List<Personagem> trocarTodos(
    List<Personagem> personagens,
    List<Personagem> alterados,
  ) {
    final porId = {for (final h in alterados) h.id: h};
    return [for (final p in personagens) porId[p.id] ?? p];
  }
}
