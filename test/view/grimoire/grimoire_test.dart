import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_vazio.dart';
import 'package:grimorio/widgets/etiqueta.dart';

import '../../helpers/app_teste.dart';
import '../../helpers/dio_falso.dart';

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

Finder filtro(String rotulo) => find.widgetWithText(Etiqueta, rotulo);

void main() {
  testWidgets('home mostra as 6 categorias sem chamar a api', (tester) async {
    final dio = apiSrd();
    await abrirGrimorio(tester, dio);

    for (final nome in [
      'Classes',
      'Espécies',
      'Magias',
      'Bestiário',
      'Itens',
      'Condições',
    ]) {
      expect(find.text(nome), findsOneWidget);
    }
    expect(dio.pedidos, isEmpty);
  });

  testWidgets('categoria mostra o total da api depois de carregar', (
    tester,
  ) async {
    await abrirGrimorio(tester, apiSrd());
    await tocar(tester, find.text('Magias'));
    await tocar(tester, find.bySemanticsLabel('Voltar'));

    expect(find.text('319 magias'), findsOneWidget);
  });

  testWidgets('Magias: carregando e depois a lista da api', (tester) async {
    final dio = DioFalso({
      ApiRotas.magias: RespostaFalsa(
        json: fixture('magias.json'),
        atraso: const Duration(milliseconds: 50),
      ),
    });
    await tester.pumpWidget(
      appDeTeste('${Rotas.grimorio}/${TipoCompendio.magias}', dio: dio),
    );
    await tester.pump();
    await tester.pump();
    expect(find.byType(EstadoCarregando), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Acid Arrow'), findsOneWidget);
    expect(find.text('319'), findsOneWidget);
    expect(find.text('2º círculo'), findsOneWidget);
  });

  testWidgets('Magias: filtro 4º+ vai como level__gte', (tester) async {
    final dio = apiSrd();
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/magias');

    await tocar(tester, filtro('4º+'));
    expect(dio.ultimo.queryParameters[ApiRotas.filtroNivelMinimo], 4);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroNivel], isNull);

    await tocar(tester, filtro('Concentração'));
    expect(dio.ultimo.queryParameters[ApiRotas.filtroConcentracao], true);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroNivelMinimo], 4);
  });

  testWidgets('Bestiário: ND 2–4 e tipo vão na query', (tester) async {
    final dio = apiSrd();
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/bestiario');
    expect(find.text('Aboleth'), findsOneWidget);
    expect(dio.ultimo.queryParameters[ApiRotas.ordem], ApiRotas.ordemNd);

    await tocar(tester, filtro('ND 2–4'));
    expect(dio.ultimo.queryParameters[ApiRotas.filtroNdMinimo], 2);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroNdMaximo], 4);

    await tocar(tester, filtro('Dragão'));
    expect(dio.ultimo.queryParameters[ApiRotas.filtroTipo], 'dragon');
  });

  testWidgets('Itens: cada aba usa a sua lista', (tester) async {
    final dio = apiSrd();
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/itens');
    expect(dio.ultimo.path, ApiRotas.itensMagicos);
    expect(find.text('Incomum'), findsWidgets);

    await tocar(tester, filtro('Raro'));
    expect(dio.ultimo.queryParameters[ApiRotas.filtroRaridade], 'rare');

    dio.respostas[ApiRotas.itens] = RespostaFalsa(json: fixture('armas.json'));
    await tocar(tester, filtro('Armas'));
    expect(dio.ultimo.path, ApiRotas.itens);
    expect(
      dio.ultimo.queryParameters[ApiRotas.filtroCategoria],
      ApiRotas.categoriasArma,
    );
    expect(find.text('Longsword'), findsOneWidget);
    expect(filtro('Raro'), findsNothing);
  });

  testWidgets('lista vazia mostra EstadoVazio', (tester) async {
    final dio = DioFalso({
      ApiRotas.condicoes: const RespostaFalsa(
        json: {'count': 0, 'next': null, 'results': []},
      ),
    });
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/condicoes');

    expect(find.byType(EstadoVazio), findsOneWidget);
    expect(find.text('Nenhuma condição encontrada'), findsOneWidget);
  });

  testWidgets('Condições: nome traduzido e abre uma por vez', (tester) async {
    final cego = fixture('condicoes.json')['results'][0];
    final dio = DioFalso({
      ApiRotas.condicoes: RespostaFalsa(
        json: {
          'count': 2,
          'next': null,
          'results': [
            {
              'key': 'charmed',
              'name': 'Charmed',
              'descriptions': [
                {'desc': 'A charmed creature cant attack the charmer.'},
              ],
            },
            cego,
          ],
        },
      ),
    });
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/condicoes');

    expect(find.textContaining('Cego'), findsOneWidget);
    expect(find.textContaining('Enfeitiçado'), findsOneWidget);
    final cegoTexto = find.textContaining('blinded creature');
    final enfeiticadoTexto = find.textContaining('charmed creature');
    expect(enfeiticadoTexto, findsNothing);

    await tocar(tester, find.textContaining('Enfeitiçado'));
    expect(enfeiticadoTexto, findsOneWidget);

    await tocar(tester, find.textContaining('Cego'));
    expect(enfeiticadoTexto, findsNothing);
    expect(cegoTexto, findsOneWidget);
  });

  testWidgets('erro de conexão mostra a mensagem amigável', (tester) async {
    final dio = DioFalso({
      ApiRotas.classes: const RespostaFalsa.falha(
        DioExceptionType.connectionError,
      ),
    });
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/classes');

    expect(find.text('Sem conexão. Confira a internet'), findsOneWidget);
    expect(find.textContaining('Dio'), findsNothing);
    expect(find.textContaining('Exception'), findsNothing);
  });
}
