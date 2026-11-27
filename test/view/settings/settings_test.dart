import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/model/campanha_mock.dart';
import 'package:grimorio/model/personagem_mock.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/view/settings/components/ajuste_tile.dart';
import 'package:grimorio/view/settings/components/perfil_card.dart';
import 'package:grimorio/view/settings/settings.dart';
import 'package:grimorio/view/auth/login.dart';
import 'package:grimorio/service/api/api_erro.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/perfil_falso.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(appDeTeste(Rotas.ajustes));
    await tester.pump();
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  // lista preguiçosa, rola até a linha existir
  Future<Finder> rolarAte(WidgetTester tester, String titulo) async {
    final alvo = find.widgetWithText(AjusteTile, titulo);
    await tester.scrollUntilVisible(
      alvo,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    return alvo;
  }

  Finder noPerfil(String texto) =>
      find.descendant(of: find.byType(PerfilCard), matching: find.text(texto));

  testWidgets('mostra nome, e-mail e os 3 contadores', (tester) async {
    await abrir(tester);

    expect(noPerfil(usuarioMock.nome), findsOneWidget);
    expect(noPerfil(usuarioMock.email), findsOneWidget);
    expect(noPerfil('Mestre e Jogador'), findsOneWidget);

    expect(noPerfil('HERÓIS'), findsOneWidget);
    expect(noPerfil('CAMPANHAS'), findsOneWidget);
    expect(noPerfil('SESSÕES'), findsOneWidget);
    expect(noPerfil('—'), findsOneWidget);
    expect(noPerfil('${personagensMock.length}'), findsAtLeastNWidgets(1));
    expect(noPerfil('${campanhasMock.length}'), findsAtLeastNWidgets(1));
  });

  testWidgets('escolher "Pontos de magia" muda o valor exibido', (
    tester,
  ) async {
    await abrir(tester);
    final linha = await rolarAte(tester, 'Sistema de magia');

    expect(
      find.descendant(of: linha, matching: find.text('Espaços de magia')),
      findsOneWidget,
    );

    await tocar(tester, linha);
    expect(find.text('Pontos de magia é uma regra opcional'), findsOneWidget);

    await tocar(
      tester,
      find.widgetWithText(RadioListTile<SistemaMagia>, 'Pontos de magia'),
    );

    expect(
      find.descendant(of: linha, matching: find.text('Pontos de magia')),
      findsOneWidget,
    );
    expect(find.text('Espaços de magia'), findsNothing);
  });

  testWidgets('desligar "Vibrar ao tocar" muda o Switch', (tester) async {
    await abrir(tester);

    final chave = find.descendant(
      of: await rolarAte(tester, 'Vibrar ao tocar'),
      matching: find.byType(Switch),
    );
    expect(tester.widget<Switch>(chave).value, isTrue);

    await tocar(tester, chave);
    expect(tester.widget<Switch>(chave).value, isFalse);
  });

  testWidgets('editar perfil valida o nome e salva só o que mudou', (
    tester,
  ) async {
    final perfis = PerfilServiceFalso();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appDeTeste(Rotas.ajustes, perfis: perfis));

    await tocar(tester, find.byTooltip('Editar perfil'));

    // e-mail so leitura
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('perfil-email')),
        matching: find.byType(EditableText),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('perfil-email')), findsOneWidget);

    final nome = find.byKey(const ValueKey('perfil-nome'));
    await tester.enterText(nome, 'A');
    await tocar(tester, find.text('Salvar'));
    expect(find.text('Nome entre 2 e 40 letras.'), findsOneWidget);
    expect(noPerfil('A'), findsNothing);

    await tester.enterText(nome, '  Aragorn ');
    await tocar(tester, find.text('Salvar'));

    expect(noPerfil('Aragorn'), findsOneWidget);
    expect(noPerfil(usuarioMock.email), findsOneWidget);
    expect(find.text('Perfil atualizado'), findsOneWidget);
    expect(perfis.atualizacoes, [
      {'nome': 'Aragorn'},
    ]);
  });

  testWidgets('salvar que falha volta o valor e mostra o erro', (tester) async {
    final perfis = PerfilServiceFalso();
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appDeTeste(Rotas.ajustes, perfis: perfis));

    perfis.proximoErro = ApiErro(TipoErroApi.semConexao);
    final chave = find.descendant(
      of: await rolarAte(tester, 'Mostrar dicas de bônus'),
      matching: find.byType(Switch),
    );
    await tocar(tester, chave);

    expect(tester.widget<Switch>(chave).value, isTrue);
    expect(find.text('Sem conexão. Confira a internet'), findsOneWidget);
  });

  testWidgets('Sair pede confirmação e volta para o login', (tester) async {
    await abrir(tester);
    await tocar(tester, await rolarAte(tester, 'Sair'));

    expect(find.text('Sair da conta?'), findsOneWidget);
    await tocar(tester, find.text('Cancelar'));
    expect(find.byType(Settings), findsOneWidget);

    await tocar(tester, await rolarAte(tester, 'Sair'));
    await tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Sair'),
      ),
    );

    expect(find.byType(Login), findsOneWidget);
    expect(find.byType(Settings), findsNothing);
  });
}
