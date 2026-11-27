import 'package:flutter/material.dart' hide Characters;
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';

import '../../helpers/app_teste.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(appDeTeste(Rotas.herois));
    await tester.pump();
  }

  testWidgets('mostra o personagem ativo com a campanha', (tester) async {
    await abrir(tester);

    expect(find.text('Elyndra'), findsOneWidget);
    expect(find.text('ATIVA'), findsOneWidget);
    expect(find.text('Clériga · Nv 5'), findsOneWidget);
    expect(find.text('Sombras de Valfenda'), findsOneWidget);
  });

  testWidgets('busca filtra pelo nome', (tester) async {
    await abrir(tester);

    await tester.enterText(find.byType(TextField), 'kael');
    await tester.pump();
    expect(find.text('Elyndra'), findsNothing);
    expect(find.text('Nenhum herói encontrado.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ELY');
    await tester.pump();
    expect(find.text('Elyndra'), findsOneWidget);
  });
}
