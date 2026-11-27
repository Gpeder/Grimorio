import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/model/campanha.dart';
import 'package:grimorio/service/supabase/banco_erro.dart';
import 'package:grimorio/view/auth/login.dart';
import 'package:grimorio/view/campaign/mestre/campanha_mestre.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../fixtures/personagem_mock.dart';
import '../fixtures/usuario_mock.dart';
import '../helpers/app_teste.dart';
import '../helpers/banco_falso.dart';

void main() {
  const trono = 'o-trono-de-cinzas';

  Future<void> abrir(
    WidgetTester tester,
    String rota, {
    BancoFalso? banco,
  }) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appDeTeste(rota, banco: banco));
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  // nada de erro tecnico na tela
  void semErroTecnico() {
    for (final termo in ['Postgrest', 'Exception', 'Null', 'BancoErro']) {
      expect(find.textContaining(termo), findsNothing, reason: termo);
    }
  }

  BancoFalso vazio() => BancoFalso(campanhas: const [], personagens: const []);

  group('listas vazias', () {
    testWidgets('heróis: texto e botão de criar', (tester) async {
      await abrir(tester, Rotas.herois, banco: vazio());

      expect(find.text('Nenhum herói ainda'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Criar herói'),
        findsOneWidget,
      );

      await tocar(tester, find.text('Criar herói'));
      expect(find.text('PASSO 1 DE 9'), findsOneWidget);
    });

    testWidgets('campanhas: criar e entrar com código', (tester) async {
      await abrir(tester, Rotas.campanhas, banco: vazio());

      expect(find.text('Nenhuma campanha'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Criar campanha'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, 'Entrar com código'),
        findsOneWidget,
      );
    });
  });

  testWidgets('erro na carga mostra "Tentar de novo" e carrega', (
    tester,
  ) async {
    final banco = BancoFalso()
      ..proximoErro = const BancoErro(TipoErroBanco.semConexao);
    await abrir(tester, Rotas.herois, banco: banco);

    expect(find.text('Sem conexão. Confira a internet.'), findsOneWidget);
    semErroTecnico();

    await tocar(tester, find.text('Tentar de novo'));
    expect(find.text('Elyndra'), findsOneWidget);
  });

  testWidgets('mestre remove herói com confirmação', (tester) async {
    final banco = BancoFalso();
    await abrir(tester, Rotas.campanhas, banco: banco);
    await tocar(tester, find.text('O Trono de Cinzas'));

    await tocar(tester, find.byTooltip('Remover Kael da campanha'));
    expect(find.text('Remover Kael?'), findsOneWidget);
    await tocar(tester, find.text('Cancelar'));
    expect(banco.vezes('mesa.removerHeroi'), 0);

    await tocar(tester, find.byTooltip('Remover Kael da campanha'));
    await tocar(tester, find.text('Remover'));

    expect(banco.vezes('mesa.removerHeroi'), 1);
    expect(find.text('Kael saiu da campanha'), findsOneWidget);
    expect(
      find.text('Ninguém entrou ainda. Passe o código aos jogadores.'),
      findsOneWidget,
    );
  });

  testWidgets('gerar novo código troca o código na tela', (tester) async {
    final banco = BancoFalso();
    await abrir(tester, Rotas.campanhas, banco: banco);
    await tocar(tester, find.text('O Trono de Cinzas'));
    expect(find.text('TRON-0017'), findsOneWidget);

    await tocar(tester, find.byTooltip('Gerar novo código'));
    await tocar(tester, find.text('Gerar'));

    expect(find.text('TRON-0017'), findsNothing);
    expect(find.text(banco.campanha(trono)!.codigoConvite), findsOneWidget);
  });

  testWidgets('erro da rpc vira aviso amigável', (tester) async {
    final banco = BancoFalso();
    await abrir(tester, Rotas.campanhas, banco: banco);
    await tocar(tester, find.text('O Trono de Cinzas'));

    banco.proximoErro = const PostgrestException(
      message: 'boom',
      code: '22P02',
    );
    await tocar(tester, find.text('Iniciar sessão 2'));

    expect(find.text('Algo deu errado. Tente de novo.'), findsOneWidget);
    semErroTecnico();
  });

  testWidgets('evento do realtime recarrega a tela; sair cancela', (
    tester,
  ) async {
    final banco = BancoFalso();
    await abrir(tester, Rotas.campanhas, banco: banco);
    await tocar(tester, find.text('O Trono de Cinzas'));
    expect(find.byType(CampanhaMestre), findsOneWidget);
    expect(banco.realtime.campanhas[trono], hasLength(1));

    // outro aparelho criou uma missao
    final c = banco.campanha(trono)!;
    banco.trocarCampanha(
      c.copyWith(
        missoes: [
          ...c.missoes,
          Missao(
            id: 'nova',
            campanhaId: trono,
            titulo: 'Missão de outro aparelho',
            atualizadaEm: DateTime(2026),
          ),
        ],
      ),
    );
    expect(find.text('Missão de outro aparelho'), findsNothing);

    banco.realtime.emitir(trono);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Missão de outro aparelho'), findsOneWidget);

    await tocar(tester, find.byTooltip('Voltar').first);
    expect(find.byType(CampanhaMestre), findsNothing);
    expect(banco.realtime.campanhas[trono], isEmpty);
  });

  testWidgets('apagar conta pede APAGAR e volta para o login', (tester) async {
    final banco = BancoFalso();
    await abrir(tester, Rotas.ajustes, banco: banco);

    final linha = find.text('Apagar conta');
    await tester.scrollUntilVisible(
      linha,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tocar(tester, linha);

    final apagar = find.widgetWithText(TextButton, 'Apagar');
    expect(tester.widget<TextButton>(apagar).onPressed, isNull);
    await tester.enterText(
      find.byKey(const ValueKey('apagar-conta')),
      'apagar',
    );
    await tester.pump();
    expect(tester.widget<TextButton>(apagar).onPressed, isNotNull);

    await tocar(tester, apagar);

    expect(banco.vezes('mesa.apagarMinhaConta'), 1);
    expect(find.byType(Login), findsOneWidget);
    expect(banco.personagens.where((p) => p.donoId == usuarioMock.id), isEmpty);
    expect(banco.campanha(trono), isNull);
    expect(banco.personagem(kaelMock.id)!.campanhaId, isNull);
  });
}
