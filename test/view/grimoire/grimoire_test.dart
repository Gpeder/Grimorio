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
import '../../helpers/grimorio_teste.dart';

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

  testWidgets('busca espera 400 ms e faz uma chamada só', (tester) async {
    final dio = apiSrd();
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/magias');
    final antes = dio.pedidos.length;

    final campo = find.byType(TextField);
    for (final t in ['f', 'fi', 'fir', 'fire']) {
      await tester.enterText(campo, t);
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(dio.pedidos, hasLength(antes));

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(dio.pedidos, hasLength(antes + 1));
    expect(dio.ultimo.queryParameters[ApiRotas.filtroBusca], 'fire');

    // menos de 2 letras volta para a lista sem busca
    await tester.enterText(campo, 'f');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(
      dio.ultimo.queryParameters.containsKey(ApiRotas.filtroBusca),
      isFalse,
    );
  });

  testWidgets('busca sem resultado mostra o texto buscado', (tester) async {
    final dio = DioFalso(
      {ApiRotas.magias: RespostaFalsa(json: fixture('magias.json'))},
      (p) => p.queryParameters[ApiRotas.filtroBusca] == 'xyz'
          ? const RespostaFalsa(json: {'count': 0, 'next': null, 'results': []})
          : null,
    );
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/magias');

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.byType(EstadoVazio), findsOneWidget);
    expect(find.text('Nada encontrado para "xyz"'), findsOneWidget);
    // busca continua na tela para corrigir
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('erro de conexão: Tentar de novo chama de novo', (tester) async {
    final dio = DioFalso({
      ApiRotas.magias: const RespostaFalsa.falha(
        DioExceptionType.connectionError,
      ),
    });
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/magias');

    expect(find.text('Sem conexão. Confira a internet'), findsOneWidget);
    expect(filtro('Truques'), findsOneWidget);
    final antes = dio.pedidos.length;

    dio.respostas[ApiRotas.magias] = RespostaFalsa(
      json: fixture('magias.json'),
    );
    await tocar(tester, find.text('Tentar de novo'));

    expect(dio.pedidos, hasLength(antes + 1));
    expect(find.text('Acid Arrow'), findsOneWidget);
  });

  testWidgets('rolar até o fim carrega a página 2; erro mantém a 1', (
    tester,
  ) async {
    var pagina2 = const RespostaFalsa(status: 500, json: {});
    final dio = DioFalso(
      {},
      (p) => switch (p.queryParameters[ApiRotas.pagina]) {
        null => RespostaFalsa(json: paginaFalsa('magias.json')),
        2 => pagina2,
        _ => null,
      },
    );
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/magias');
    expect(find.text('Acid Arrow 1.0'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -6000));
    await tester.pumpAndSettle();

    expect(dio.ultimo.queryParameters[ApiRotas.pagina], 2);
    expect(
      find.text('O servidor está com problema. Tente de novo'),
      findsOneWidget,
    );
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.text('Acid Arrow 1.29'), findsOneWidget);

    // tentar de novo soma a pagina 2 aos itens
    pagina2 = RespostaFalsa(
      json: paginaFalsa('magias.json', n: 5, pagina: 2, temMais: false),
    );
    await tocar(tester, find.text('Tentar de novo'));
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('Acid Arrow 2.4'), findsOneWidget);
    expect(dio.pedidos, hasLength(3));
    expect(find.text('Tentar de novo'), findsNothing);
  });

  testWidgets('nenhuma tela mostra erro técnico', (tester) async {
    for (final tipo in [
      TipoCompendio.magias,
      TipoCompendio.bestiario,
      TipoCompendio.itens,
      TipoCompendio.classes,
      TipoCompendio.especies,
      TipoCompendio.condicoes,
    ]) {
      for (final dio in [
        apiSrd(),
        DioFalso({}, (_) => const RespostaFalsa(status: 500, texto: 'x')),
        DioFalso({}, (_) => const RespostaFalsa(json: {'results': 'quebrado'})),
      ]) {
        await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/$tipo');
        for (final tecnico in ['Exception', 'Dio', 'Null', 'null']) {
          expect(find.textContaining(tecnico), findsNothing, reason: tipo);
        }
      }
    }
  });
}
