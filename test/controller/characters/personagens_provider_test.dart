import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/characters/gerenciador_hp.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';

import '../../fixtures/personagem_mock.dart';
import '../../fixtures/usuario_mock.dart';
import '../../helpers/banco_falso.dart';

void main() {
  late BancoFalso banco;
  late PersonagensProvider p;

  void criar() {
    banco = BancoFalso();
    p = PersonagensProvider(
      banco.servicos.personagens,
      realtime: banco.realtime,
    );
    addTearDown(p.dispose);
  }

  test('carrega depois do login e limpa no sair', () {
    criar();
    expect(p.carregamento, Carregamento.inicial);
    expect(p.todos, isEmpty);

    p.carregar(usuarioMock.id);
    expect(p.carregamento, Carregamento.pronto);
    expect(p.meus.map((x) => x.id), [personagemAtivoMock.id]);
    expect(p.ativo?.id, personagemAtivoMock.id);
    expect(p.porId(personagemAtivoMock.id)!.notas, hasLength(2));
    expect(banco.realtime.abertas, 1);

    p.limpar();
    expect(p.todos, isEmpty);
    expect(p.carregamento, Carregamento.inicial);
    expect(banco.realtime.abertas, 0);
  });

  test('erro na carga vira mensagem amigável e tentar de novo carrega', () {
    criar();
    banco.proximoErro = const BancoErro(TipoErroBanco.semConexao);
    p.carregar(usuarioMock.id);
    expect(p.carregamento, Carregamento.erro);
    expect(p.mensagemErro, 'Sem conexão. Confira a internet.');

    p.tentarDeNovo();
    expect(p.carregamento, Carregamento.pronto);
  });

  test('5 toques rápidos no HP salvam uma vez, só hp_atual e hp_temp', () {
    fakeAsync((tempo) {
      criar();
      p.carregar(usuarioMock.id);
      const hp = GerenciadorHp();
      final id = personagemAtivoMock.id;

      for (var i = 0; i < 5; i++) {
        p.editar(hp.receberDano(p.porId(id)!, 1));
        tempo.elapse(const Duration(milliseconds: 200));
      }
      expect(p.porId(id)!.hpAtual, personagemAtivoMock.hpAtual - 5);
      expect(banco.vezes('personagens.atualizar'), 0);

      tempo.elapse(PersonagensProvider.esperaToque);
      expect(banco.vezes('personagens.atualizar'), 1);
      final (salvo, campos) = banco.atualizacoes.single;
      expect(salvo, id);
      expect(campos.keys.toSet().difference({'hp_atual', 'hp_temp'}), isEmpty);
      expect(campos['hp_atual'], personagemAtivoMock.hpAtual - 5);
    });
  });

  test('erro ao salvar volta o valor e o futuro termina com o erro', () {
    fakeAsync((tempo) {
      criar();
      p.carregar(usuarioMock.id);
      final id = personagemAtivoMock.id;
      Object? erro;

      p
          .editar(p.porId(id)!.copyWith(hpAtual: 1))
          .catchError((Object e) => erro = e);
      expect(p.porId(id)!.hpAtual, 1);

      banco.proximoErro = const BancoErro(TipoErroBanco.semConexao);
      tempo.elapse(PersonagensProvider.esperaToque);
      tempo.flushMicrotasks();

      expect(p.porId(id)!.hpAtual, personagemAtivoMock.hpAtual);
      expect(erro, isA<BancoErro>());
    });
  });

  test('criar nasce sem campanha e vira o ativo', () async {
    criar();
    p.carregar(usuarioMock.id);
    final novo = await p.criar(kaelMock.copyWith(id: 'x', nome: 'Novo'));

    expect(novo.ativo, isTrue);
    expect(novo.campanhaId, isNull);
    expect(novo.donoId, usuarioMock.id);
    expect(p.ativo?.nome, 'Novo');
    expect(p.meus.where((x) => x.ativo), hasLength(1));
    expect(banco.vezes('personagens.ativar'), 1);
  });

  test('diário salva na tabela de notas', () async {
    criar();
    p.carregar(usuarioMock.id);
    final id = personagemAtivoMock.id;

    await p.adicionarNota(
      id,
      Nota(id: '', titulo: 'Novo', texto: 'x', data: DateTime(2026)),
    );
    expect(p.porId(id)!.notas.map((n) => n.titulo), contains('Novo'));
    expect(banco.notas[id]!.map((n) => n.titulo), contains('Novo'));

    final nota = p.porId(id)!.notas.firstWhere((n) => n.titulo == 'Novo');
    await p.removerNota(id, nota.id);
    expect(p.porId(id)!.notas.map((n) => n.titulo), isNot(contains('Novo')));
  });

  test('evento dos meus heróis recarrega', () {
    fakeAsync((tempo) {
      criar();
      p.carregar(usuarioMock.id);
      final id = personagemAtivoMock.id;
      banco.trocarHerois([banco.personagem(id)!.copyWith(xp: 9999)]);

      banco.realtime.emitirHerois(usuarioMock.id);
      tempo.elapse(const Duration(milliseconds: 300));

      expect(p.porId(id)!.xp, 9999);
    });
  });
}
