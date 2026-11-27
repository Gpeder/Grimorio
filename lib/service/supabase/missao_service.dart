import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/banco_rotas.dart';

// missoes e entradas do diario, so o mestre escreve; os testes usam um falso
abstract class MissaoService {
  Future<Missao> criar(Missao m);

  // so os campos que mudaram; estado muda pelas rpcs da mesa
  Future<void> atualizar(String id, Map<String, dynamic> campos);
  Future<void> apagar(String id);

  Future<EntradaMissao> criarEntrada(String missaoId, EntradaMissao e);
  Future<void> atualizarEntrada(String id, Map<String, dynamic> campos);
  Future<void> apagarEntrada(String id);
}

class SupabaseMissaoService implements MissaoService {
  SupabaseMissaoService(this._banco);

  final Banco _banco;

  @override
  Future<Missao> criar(Missao m) => _banco.rodar('criar missao', (db) async {
    final linha = await db
        .from(BancoRotas.missoes)
        .insert({
          BancoRotas.campanhaId: m.campanhaId,
          'titulo': m.titulo,
          'tipo': m.tipo.name,
          'regiao': m.regiao,
          'descricao': m.descricao,
          'revelada': m.revelada,
          'recompensa_xp': m.recompensaXp,
          'recompensa_itens': m.recompensaItens,
          'npc_ids': m.npcIds,
        })
        .select()
        .single();
    return Missao.fromJson(linha);
  });

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) async {
    if (campos.isEmpty) return;
    await _banco.rodar(
      'atualizar missao ${campos.keys.join(', ')}',
      (db) => db.from(BancoRotas.missoes).update(campos).eq(BancoRotas.id, id),
    );
  }

  @override
  Future<void> apagar(String id) => _banco.rodar(
    'apagar missao',
    (db) => db.from(BancoRotas.missoes).delete().eq(BancoRotas.id, id),
  );

  // campanha_id vem da missao pelo trigger do banco
  @override
  Future<EntradaMissao> criarEntrada(String missaoId, EntradaMissao e) =>
      _banco.rodar('criar entrada', (db) async {
        final linha = await db
            .from(BancoRotas.entradas)
            .insert({
              BancoRotas.missaoId: missaoId,
              'texto': e.texto,
              'sessao': e.sessao,
              'objetivo': e.objetivo,
              'concluida': e.concluida,
              'revelada': e.revelada,
            })
            .select()
            .single();
        return EntradaMissao.fromJson(linha);
      });

  @override
  Future<void> atualizarEntrada(String id, Map<String, dynamic> campos) async {
    if (campos.isEmpty) return;
    await _banco.rodar(
      'atualizar entrada ${campos.keys.join(', ')}',
      (db) => db.from(BancoRotas.entradas).update(campos).eq(BancoRotas.id, id),
    );
  }

  @override
  Future<void> apagarEntrada(String id) => _banco.rodar(
    'apagar entrada',
    (db) => db.from(BancoRotas.entradas).delete().eq(BancoRotas.id, id),
  );
}
