import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/service/api/api_rotas.dart';

import 'app_teste.dart';
import 'dio_falso.dart';

// api inteira com as fixtures
DioFalso apiSrd() => DioFalso({
  ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
  ApiRotas.monstros: RespostaFalsa(json: fixture('monstros.json')),
  ApiRotas.itens: RespostaFalsa(json: fixture('itens.json')),
  ApiRotas.itensMagicos: RespostaFalsa(json: fixture('itens_magicos.json')),
  ApiRotas.classes: RespostaFalsa(json: fixture('classes.json')),
  ApiRotas.especies: RespostaFalsa(json: fixture('especies.json')),
  ApiRotas.condicoes: RespostaFalsa(json: fixture('condicoes.json')),
});

Future<void> abrirGrimorio(
  WidgetTester tester,
  DioFalso dio, {
  String rota = Rotas.grimorio,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste(rota, dio: dio));
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}
