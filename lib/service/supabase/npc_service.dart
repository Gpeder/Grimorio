import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/banco_rotas.dart';

// npcs da campanha, so o mestre escreve; os testes usam um falso
abstract class NpcService {
  Future<Npc> criar(Npc npc);

  // so os campos que mudaram
  Future<void> atualizar(String id, Map<String, dynamic> campos);
  Future<void> apagar(String id);
}

class SupabaseNpcService implements NpcService {
  SupabaseNpcService(this._banco);

  final Banco _banco;

  @override
  Future<Npc> criar(Npc npc) => _banco.rodar('criar npc', (db) async {
    final linha = await db
        .from(BancoRotas.npcs)
        .insert({
          BancoRotas.campanhaId: npc.campanhaId,
          'nome': npc.nome,
          'funcao': npc.funcao,
          'imagem': npc.imagem,
          'revelado': npc.revelado,
        })
        .select()
        .single();
    return Npc.fromJson(linha);
  });

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) async {
    if (campos.isEmpty) return;
    await _banco.rodar(
      'atualizar npc ${campos.keys.join(', ')}',
      (db) => db.from(BancoRotas.npcs).update(campos).eq(BancoRotas.id, id),
    );
  }

  @override
  Future<void> apagar(String id) => _banco.rodar(
    'apagar npc',
    (db) => db.from(BancoRotas.npcs).delete().eq(BancoRotas.id, id),
  );
}
