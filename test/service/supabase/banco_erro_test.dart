import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';
import 'package:http/http.dart' show ClientException;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  String msg(Object e) => BancoErro.de(e).mensagem;

  PostgrestException rpc(String chave) =>
      PostgrestException(message: chave, code: 'P0001');

  test('cada chave de rpc vira a mensagem certa', () {
    const tabela = {
      'codigo_invalido': 'Código não encontrado.',
      'mestre_nao_joga': 'O mestre não pode ter herói na própria campanha.',
      'ja_tem_heroi': 'Você já tem um herói nessa campanha.',
      'heroi_em_outra_campanha': 'Esse herói já está em outra campanha.',
      'sessao_aberta': 'Já tem uma sessão aberta.',
      'sem_sessao': 'Nenhuma sessão aberta.',
      'missao_fechada': 'Essa missão já terminou.',
      'sem_permissao': 'Você não pode fazer isso.',
      'heroi_fora_da_campanha': 'Você não pode fazer isso.',
      'valor_invalido': 'Você não pode fazer isso.',
    };
    for (final MapEntry(key: chave, value: texto) in tabela.entries) {
      expect(msg(rpc(chave)), texto, reason: chave);
    }
  });

  test('codigos do postgres', () {
    expect(
      msg(const PostgrestException(message: 'rls', code: '42501')),
      'Você não pode fazer isso.',
    );
    expect(
      BancoErro.de(const PostgrestException(message: 'x', code: 'PGRST116'))
          .tipo,
      TipoErroBanco.naoEncontrado,
    );
    expect(
      msg(const PostgrestException(message: 'dup', code: '23505')),
      'Isso já existe.',
    );
    expect(
      msg(const PostgrestException(message: 'x', code: '22P02')),
      'Algo deu errado. Tente de novo.',
    );
  });

  test('sem rede', () {
    for (final e in <Object>[
      const SocketException('sem rede'),
      ClientException('falhou'),
      AuthRetryableFetchException(message: 'x'),
    ]) {
      expect(msg(e), 'Sem conexão. Confira a internet.', reason: '$e');
    }
  });

  test('resto e mensagemDeErro usa o texto amigável', () {
    expect(msg(StateError('x')), 'Algo deu errado. Tente de novo.');
    expect(
      mensagemDeErro(BancoErro.de(rpc('codigo_invalido'))),
      'Código não encontrado.',
    );
  });
}
