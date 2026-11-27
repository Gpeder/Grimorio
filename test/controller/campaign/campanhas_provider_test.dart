import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/campaign/campanhas_provider.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';

import '../../fixtures/personagem_mock.dart';
import '../../fixtures/usuario_mock.dart';
import '../../helpers/banco_falso.dart';
import '../../helpers/perfil_falso.dart';

void main() {
  late BancoFalso banco;
  late PersonagensProvider herois;
  late CampanhasProvider c;

  // gustavo: heroi em valfenda (do bruno), mestre do trono
  const valfenda = 'sombras-de-valfenda';
  const trono = 'o-trono-de-cinzas';

  void criar() {
    banco = BancoFalso();
    herois = PersonagensProvider(banco.servicos.personagens);
    c = CampanhasProvider(
      campanhas: banco.servicos.campanhas,
      mesa: banco.servicos.mesa,
      missoes: banco.servicos.missoes,
      npcs: banco.servicos.npcs,
      personagens: herois,
      perfis: PerfilServiceFalso(),
      realtime: banco.realtime,
    );
    addTearDown(() {
      c.dispose();
      herois.dispose();
    });
    herois.carregar(usuarioMock.id);
    c.carregar(usuarioMock.id);
  }

  test('carrega as campanhas e o nome dos mestres; limpa no sair', () {
    criar();
    expect(c.carregamento, Carregamento.pronto);
    expect(c.campanhas.map((x) => x.id), [valfenda, trono]);
    expect(c.nomeDe('u_bruno'), 'Bruno');

    c.limpar();
    expect(c.campanhas, isEmpty);
    expect(c.carregamento, Carregamento.inicial);
  });

  test('erro na carga vira mensagem amigável', () {
    banco = BancoFalso();
    herois = PersonagensProvider(banco.servicos.personagens);
    c = CampanhasProvider(
      campanhas: banco.servicos.campanhas,
      mesa: banco.servicos.mesa,
      missoes: banco.servicos.missoes,
      npcs: banco.servicos.npcs,
      personagens: herois,
    );
    banco.proximoErro = const BancoErro(TipoErroBanco.semConexao);
    c.carregar(usuarioMock.id);
    expect(c.carregamento, Carregamento.erro);
    expect(c.mensagemErro, 'Sem conexão. Confira a internet.');
  });

  test('darXp chama a rpc e nunca atualiza herói de outro direto', () async {
    criar();
    await c.darXp(trono, {kaelMock.id}, 300);

    expect(banco.vezes('mesa.darXp'), 1);
    expect(banco.vezes('personagens.atualizar'), 0);
    expect(herois.porId(kaelMock.id)!.xp, 300);
    expect(c.porId(trono)!.registros.first.texto, '+300 XP para Kael');

    await c.desfazer(trono, c.porId(trono)!.registros.first);
    expect(banco.vezes('mesa.desfazer'), 1);
    expect(herois.porId(kaelMock.id)!.xp, 0);
  });

  test('item e conclusão de missão também vão pela rpc', () async {
    criar();
    final item = itensMock.first;
    await c.darItem(trono, kaelMock.id, item);
    expect(banco.vezes('mesa.darItem'), 1);
    expect(
      herois.porId(kaelMock.id)!.inventario.map((i) => i.id),
      contains(item.key),
    );

    final missao = c.porId(trono)!.missoes.first;
    await c.concluirMissao(
      trono,
      missao.id,
      destinos: const {},
      itens: const [],
    );
    expect(banco.vezes('mesa.concluirMissao'), 1);
    expect(c.porId(trono)!.missoes.first.ativa, isFalse);
    expect(banco.vezes('personagens.atualizar'), 0);
  });

  test('erro da rpc chega como BancoErro amigável', () async {
    criar();
    await expectLater(
      c.darXp(valfenda, {kaelMock.id}, 10),
      throwsA(
        isA<BancoErro>().having(
          (e) => e.mensagem,
          'mensagem',
          'Você não pode fazer isso.',
        ),
      ),
    );
  });

  test('entrar com código traz a campanha e o herói', () async {
    criar();
    final novo = await herois.criar(kaelMock.copyWith(id: 'x', nome: 'Novo'));
    banco.campanhas = [
      ...banco.campanhas,
      banco.campanhas.first.copyWith(
        id: 'outra',
        mestreId: 'u_lia',
        codigoConvite: 'OUTR-1234',
      ),
    ];

    final campanha = await c.entrarComCodigo(' outr-1234 ', novo.id);
    expect(campanha.id, 'outra');
    expect(c.porId('outra'), isNotNull);
    expect(herois.porId(novo.id)!.campanhaId, 'outra');

    await expectLater(
      c.entrarComCodigo('XXXX-0000', novo.id),
      throwsA(
        isA<BancoErro>().having(
          (e) => e.tipo,
          'tipo',
          TipoErroBanco.codigoInvalido,
        ),
      ),
    );
  });

  test('editar missão manda só o que mudou e volta se falhar', () async {
    criar();
    final m = c.porId(trono)!.missoes.first;
    await c.editarMissao(m, m.copyWith(revelada: false));
    expect(banco.vezes('missoes.atualizar'), 1);
    expect(c.porId(trono)!.missoes.first.revelada, isFalse);

    banco.proximoErro = const BancoErro(TipoErroBanco.semConexao);
    final atual = c.porId(trono)!.missoes.first;
    await expectLater(
      c.editarMissao(atual, atual.copyWith(titulo: 'Outro')),
      throwsA(isA<BancoErro>()),
    );
    expect(c.porId(trono)!.missoes.first.titulo, m.titulo);
  });

  test('notas do mestre esperam a digitação parar', () {
    fakeAsync((tempo) {
      criar();
      for (final t in ['a', 'ab', 'abc']) {
        c.editarNotas(trono, t);
        tempo.elapse(const Duration(milliseconds: 100));
      }
      expect(c.porId(trono)!.notasMestre, 'abc');
      expect(banco.vezes('campanhas.editarNotas'), 0);
      tempo.elapse(PersonagensProvider.esperaToque);
      expect(banco.vezes('campanhas.editarNotas'), 1);
      expect(banco.campanha(trono)!.notasMestre, 'abc');
    });
  });

  test('evento do realtime recarrega a campanha; cancelar para de ouvir', () {
    fakeAsync((tempo) {
      criar();
      final parar = c.ouvir(trono);
      expect(banco.realtime.abertas, 1);

      final antes = banco.vezes('campanhas.buscar');
      banco.realtime.emitir(trono);
      banco.realtime.emitir(trono);
      tempo.elapse(const Duration(milliseconds: 300));
      expect(banco.vezes('campanhas.buscar'), antes + 1);

      parar();
      tempo.flushMicrotasks();
      expect(banco.realtime.abertas, 0);
    });
  });
}
