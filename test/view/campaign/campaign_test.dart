import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/view/campaign/campaign.dart';
import 'package:grimorio/view/campaign/components/campanha_card.dart';
import 'package:grimorio/widgets/etiqueta.dart';

import '../../helpers/app_teste.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1290, 2796);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(telaDeTeste(const Campaign()));
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  Finder card(String nome) => find.widgetWithText(CampanhaCard, nome);

  Future<void> rolarAte(WidgetTester tester, Finder alvo) async {
    await tester.scrollUntilVisible(
      alvo,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> usarCodigo(WidgetTester tester, String codigo) async {
    await tocar(tester, find.text('Entrar com código do Mestre'));
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      codigo,
    );
    await tester.pump();
    await tocar(tester, find.text('Entrar'));
  }

  Future<void> darXpAoKael(WidgetTester tester, int valor) async {
    await tocar(tester, find.byTooltip('Dar XP a Kael'));
    await tester.enterText(find.byKey(const ValueKey('xp-valor')), '$valor');
    await tester.pump();
    await tocar(tester, find.widgetWithText(ElevatedButton, 'Dar XP'));
  }

  testWidgets('lista as 2 campanhas com o papel do usuário', (tester) async {
    await abrir(tester);

    expect(find.text('Sombras de Valfenda'), findsOneWidget);
    expect(find.text('O Trono de Cinzas'), findsOneWidget);
    expect(find.widgetWithText(Etiqueta, 'Herói'), findsOneWidget);
    expect(find.widgetWithText(Etiqueta, 'Mestre'), findsOneWidget);
    expect(find.text('Sessão 8 · em andamento'), findsOneWidget);
  });

  testWidgets('código válido entra, inválido mostra erro', (tester) async {
    await abrir(tester);

    await usarCodigo(tester, 'valf-42');
    expect(find.text('Você entrou em Sombras de Valfenda'), findsOneWidget);

    await usarCodigo(tester, 'XXXX-00');
    expect(find.text('Código não encontrado'), findsOneWidget);
  });

  testWidgets('Valfenda abre na visão do herói, sem botões de mestre', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, card('Sombras de Valfenda'));

    expect(find.text('Sessão 8 em andamento'), findsOneWidget);
    expect(find.text('Mestre: Bruno'), findsOneWidget);
    expect(find.text('Elyndra'), findsOneWidget);
    expect(find.text('O Altar Profanado'), findsNothing);
    expect(find.text('Concluir e distribuir'), findsNothing);
    expect(find.text('Ver como herói'), findsNothing);

    await rolarAte(tester, find.text('O Druida Desaparecido'));
    await tocar(tester, find.text('O Druida Desaparecido'));

    expect(find.text('DIÁRIO DE MISSÕES'), findsOneWidget);
    expect(
      find.text('Descobrir que o culto do Galho Podre levou Halvar.'),
      findsNothing,
    );
    expect(find.text('Concluir e distribuir'), findsNothing);
    expect(find.text('Nova entrada'), findsNothing);
    expect(find.byTooltip('Editar missão'), findsNothing);

    await rolarAte(tester, find.text('Recompensa revelada ao concluir.'));
    expect(find.text('Recompensa revelada ao concluir.'), findsOneWidget);
  });

  testWidgets('mestre dá 300 XP ao Kael e desfaz', (tester) async {
    await abrir(tester);
    await tocar(tester, card('O Trono de Cinzas'));

    expect(find.text('XP 0 / 300'), findsOneWidget);

    await darXpAoKael(tester, 300);
    expect(find.text('XP 300 / 300'), findsOneWidget);
    expect(find.text('pode subir!'), findsOneWidget);

    await rolarAte(tester, find.text('+300 XP para Kael'));
    expect(find.text('+300 XP para Kael'), findsOneWidget);

    await tocar(tester, find.text('Desfazer'));
    expect(find.text('+300 XP para Kael'), findsNothing);
    expect(find.text('Desfeito'), findsOneWidget);

    await rolarAte(tester, find.text('XP 0 / 300'));
    expect(find.text('XP 0 / 300'), findsOneWidget);
  });

  testWidgets('concluir missão de 100 XP soma 100 em todos os heróis', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, card('O Trono de Cinzas'));
    expect(find.text('XP 0 / 300'), findsOneWidget);

    await rolarAte(tester, find.text('A Coroa Partida'));
    await tocar(tester, find.text('A Coroa Partida'));
    await tocar(tester, find.text('Concluir e distribuir'));

    expect(find.text('100 XP para cada herói'), findsOneWidget);
    await tocar(tester, find.text('Confirmar'));

    expect(find.text('Missão concluída!'), findsOneWidget);
    expect(find.text('Concluir e distribuir'), findsNothing);

    await tocar(tester, find.byTooltip('Voltar').first);
    await rolarAte(tester, find.text('XP 100 / 300'));
    expect(find.text('XP 100 / 300'), findsOneWidget);
    await rolarAte(tester, find.text('Missão concluída: A Coroa Partida'));
    expect(find.text('+100 XP para Kael'), findsOneWidget);
  });

  testWidgets('entrada revelada pelo mestre aparece em "Ver como herói"', (
    tester,
  ) async {
    await abrir(tester);
    await tocar(tester, card('O Trono de Cinzas'));

    await rolarAte(tester, find.text('A Coroa Partida'));
    await tocar(tester, find.text('A Coroa Partida'));
    await tocar(tester, find.text('Nova entrada'));
    await tester.enterText(
      find.byKey(const ValueKey('entrada-texto')),
      'O ferreiro fugiu pelos telhados.',
    );
    await tocar(tester, find.text('Adicionar entrada'));
    await tocar(tester, find.byTooltip('Voltar').first);

    await rolarAte(tester, find.text('Ver como herói'));
    await tocar(tester, find.text('Ver como herói'));
    expect(find.text('Prévia: é assim que os heróis veem'), findsOneWidget);
    expect(find.text('O ferreiro fugiu pelos telhados.'), findsNothing);

    await rolarAte(tester, find.text('A Coroa Partida'));
    await tocar(tester, find.text('A Coroa Partida'));
    expect(find.text('O ferreiro fugiu pelos telhados.'), findsOneWidget);
  });
}
