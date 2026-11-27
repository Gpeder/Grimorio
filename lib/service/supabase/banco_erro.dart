import 'dart:async';
import 'dart:io';

import 'package:grimorio/app/log/erro_amigavel.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

enum TipoErroBanco {
  codigoInvalido('Código não encontrado.'),
  mestreNaoJoga('O mestre não pode ter herói na própria campanha.'),
  jaTemHeroi('Você já tem um herói nessa campanha.'),
  heroiEmOutraCampanha('Esse herói já está em outra campanha.'),
  sessaoAberta('Já tem uma sessão aberta.'),
  semSessao('Nenhuma sessão aberta.'),
  missaoFechada('Essa missão já terminou.'),
  semPermissao('Você não pode fazer isso.'),
  naoEncontrado('Não encontrado.'),
  jaExiste('Isso já existe.'),
  semConexao('Sem conexão. Confira a internet.'),
  desconhecido('Algo deu errado. Tente de novo.');

  const TipoErroBanco(this.mensagem);
  final String mensagem;
}

class BancoErro implements Exception, ErroAmigavel {
  const BancoErro(this.tipo, {this.codigo});

  final TipoErroBanco tipo;

  // code original do postgres ou chave da rpc, so para o log
  final String? codigo;

  @override
  String get mensagem => tipo.mensagem;

  // traduz o erro do postgrest ou da rede
  factory BancoErro.de(Object erro) => switch (erro) {
    BancoErro() => erro,
    PostgrestException(code: 'P0001', :final message) => BancoErro(
      tipoDaChave(message),
      codigo: message,
    ),
    PostgrestException(code: '42501' || 'PGRST301') => BancoErro(
      TipoErroBanco.semPermissao,
      codigo: erro.code,
    ),
    PostgrestException(code: 'PGRST116') => BancoErro(
      TipoErroBanco.naoEncontrado,
      codigo: erro.code,
    ),
    PostgrestException(code: '23505') => BancoErro(
      TipoErroBanco.jaExiste,
      codigo: erro.code,
    ),
    PostgrestException(:final code) => BancoErro(
      TipoErroBanco.desconhecido,
      codigo: code,
    ),
    AuthRetryableFetchException() ||
    SocketException() ||
    HttpException() ||
    ClientException() ||
    TimeoutException() => const BancoErro(TipoErroBanco.semConexao),
    _ => const BancoErro(TipoErroBanco.desconhecido),
  };

  // chave do raise exception das rpcs; o resto e falta de permissao
  static TipoErroBanco tipoDaChave(String chave) => switch (chave.trim()) {
    'codigo_invalido' => TipoErroBanco.codigoInvalido,
    'mestre_nao_joga' => TipoErroBanco.mestreNaoJoga,
    'ja_tem_heroi' => TipoErroBanco.jaTemHeroi,
    'heroi_em_outra_campanha' => TipoErroBanco.heroiEmOutraCampanha,
    'sessao_aberta' => TipoErroBanco.sessaoAberta,
    'sem_sessao' => TipoErroBanco.semSessao,
    'missao_fechada' => TipoErroBanco.missaoFechada,
    _ => TipoErroBanco.semPermissao,
  };

  // so para o log, nunca para a tela
  @override
  String toString() => 'BancoErro(${tipo.name}, codigo: $codigo)';
}
