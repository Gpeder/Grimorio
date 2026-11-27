import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/banco_rotas.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// para de ouvir
typedef CancelarEscuta = Future<void> Function();

// mudancas ao vivo; a rls tambem vale aqui. os testes usam um falso
abstract class RealtimeService {
  // campanha e tudo dela (missoes, entradas, npcs, sessoes, registros, herois)
  CancelarEscuta ouvirCampanha(String campanhaId, void Function() onMudou);

  // herois do usuario, para ver o xp que o mestre deu
  CancelarEscuta ouvirMeusHerois(String usuarioId, void Function() onMudou);
}

class SupabaseRealtimeService implements RealtimeService {
  SupabaseRealtimeService(this._banco);

  final Banco _banco;

  CancelarEscuta _ouvir(
    String canal,
    Map<String, ({String coluna, String valor})> tabelas,
    void Function() onMudou,
  ) {
    final db = _banco.cliente;
    if (db == null) return () async {};

    var c = db.channel(canal);
    for (final MapEntry(key: tabela, value: filtro) in tabelas.entries) {
      c = c.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: tabela,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filtro.coluna,
          value: filtro.valor,
        ),
        callback: (_) => onMudou(),
      );
    }
    c.subscribe((status, erro) {
      if (erro != null) {
        AppLog.erro(TagLog.banco, 'realtime $canal: $status', erro: erro);
      } else {
        AppLog.info(TagLog.banco, 'realtime $canal: ${status.name}');
      }
    });
    return () async {
      await db.removeChannel(c);
    };
  }

  @override
  CancelarEscuta ouvirCampanha(String campanhaId, void Function() onMudou) =>
      _ouvir('campanha:$campanhaId', {
        BancoRotas.campanhas: (coluna: BancoRotas.id, valor: campanhaId),
        for (final t in BancoRotas.tabelasDaMesa)
          t: (coluna: BancoRotas.campanhaId, valor: campanhaId),
      }, onMudou);

  @override
  CancelarEscuta ouvirMeusHerois(String usuarioId, void Function() onMudou) =>
      _ouvir('herois:$usuarioId', {
        BancoRotas.personagens: (coluna: BancoRotas.donoId, valor: usuarioId),
      }, onMudou);
}
