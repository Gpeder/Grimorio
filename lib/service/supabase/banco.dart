import 'package:grimorio/app/config/ambiente.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// cliente do supabase e o tratamento de erro comum aos services do banco
class Banco {
  Banco({this._cliente});

  final SupabaseClient? _cliente;

  // sem env.json o supabase nao foi iniciado
  SupabaseClient? get cliente =>
      _cliente ?? (Ambiente.configurado ? Supabase.instance.client : null);

  // todo erro sai como BancoErro, logado com a stack
  Future<T> rodar<T>(
    String onde,
    Future<T> Function(SupabaseClient db) acao,
  ) async {
    final db = cliente;
    if (db == null) {
      AppLog.erro(TagLog.banco, '$onde: supabase nao configurado (env.json)');
      throw const BancoErro(TipoErroBanco.desconhecido);
    }
    try {
      return await acao(db);
    } catch (e, stack) {
      final erro = BancoErro.de(e);
      AppLog.erro(
        TagLog.banco,
        '$onde: ${erro.tipo.name}',
        erro: e,
        stack: stack,
      );
      throw erro;
    }
  }
}
