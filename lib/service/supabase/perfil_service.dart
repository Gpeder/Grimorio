import 'dart:async';
import 'dart:io';

import 'package:grimorio/app/config/ambiente.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/service/api/api_erro.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// perfil do usuario na tabela perfis, os testes usam um falso
abstract class PerfilService {
  // sem o e-mail, que vem do auth
  Future<Usuario> buscar(String id);

  // so os campos que mudaram, nunca a linha inteira
  Future<void> atualizar(String id, Map<String, dynamic> campos);
}

class SupabasePerfilService implements PerfilService {
  SupabasePerfilService({this._cliente});

  final SupabaseClient? _cliente;

  static const _tabela = 'perfis';

  SupabaseClient? get _db =>
      _cliente ?? (Ambiente.configurado ? Supabase.instance.client : null);

  @override
  Future<Usuario> buscar(String id) => _rodar('buscar', (db) async {
    final linha = await db.from(_tabela).select().eq('id', id).single();
    return Usuario.fromJson(linha);
  });

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) async {
    if (campos.isEmpty) return;
    await _rodar(
      'atualizar ${campos.keys.join(', ')}',
      (db) => db.from(_tabela).update(campos).eq('id', id),
    );
  }

  // todo erro sai como ApiErro, logado com a stack
  Future<T> _rodar<T>(
    String onde,
    Future<T> Function(SupabaseClient db) acao,
  ) async {
    final db = _db;
    if (db == null) {
      AppLog.erro(TagLog.api, 'perfil $onde: supabase nao configurado');
      throw ApiErro(TipoErroApi.desconhecido);
    }
    try {
      return await acao(db);
    } catch (e, stack) {
      AppLog.erro(TagLog.api, 'perfil $onde', erro: e, stack: stack);
      throw _traduzir(e);
    }
  }

  static ApiErro _traduzir(Object e) => switch (e) {
    ApiErro() => e,
    // nenhuma linha no single
    PostgrestException(code: 'PGRST116') => ApiErro(TipoErroApi.naoEncontrado),
    PostgrestException(code: '42501' || 'PGRST301') => ApiErro(
      TipoErroApi.naoAutorizado,
    ),
    PostgrestException() => ApiErro(TipoErroApi.servidor),
    AuthRetryableFetchException() ||
    SocketException() ||
    HttpException() => ApiErro(TipoErroApi.semConexao),
    TimeoutException() => ApiErro(TipoErroApi.tempoEsgotado),
    _ => ApiErro(TipoErroApi.desconhecido),
  };
}
