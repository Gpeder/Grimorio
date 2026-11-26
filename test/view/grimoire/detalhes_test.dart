import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/widgets/estado_erro.dart';

import '../../helpers/dio_falso.dart';
import '../../helpers/grimorio_teste.dart';

Map<String, dynamic> primeiro(String arquivo) =>
    (fixture(arquivo)['results'] as List).first as Map<String, dynamic>;

String detalhe(String tipo, String key) => '${Rotas.grimorio}/$tipo/$key';

// imagem de asset com esse caminho
Finder asset(String caminho) => find.byWidgetPredicate(
  (w) =>
      w is Image &&
      w.image is AssetImage &&
      (w.image as AssetImage).assetName == caminho,
);

void main() {
  testWidgets('magia por link direto: nome, nível e escola traduzida', (
    tester,
  ) async {
    final dio = DioFalso({
      '/spells/srd_acid-arrow/': RespostaFalsa(json: primeiro('magias.json')),
    });
    await abrirGrimorio(
      tester,
      dio,
      rota: detalhe(TipoCompendio.magias, 'srd_acid-arrow'),
    );

    expect(find.text('Acid Arrow'), findsOneWidget);
    expect(find.text('2º círculo · Evocação'), findsOneWidget);
    expect(find.text('1 ação'), findsOneWidget);
    expect(find.text('27 m'), findsOneWidget);
    expect(find.text('Instantânea'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
  });

  testWidgets('key que não existe mostra Não encontrado', (tester) async {
    for (final tipo in [
      TipoCompendio.magias,
      TipoCompendio.bestiario,
      TipoCompendio.itens,
      TipoCompendio.classes,
      TipoCompendio.especies,
    ]) {
      await abrirGrimorio(tester, DioFalso(), rota: detalhe(tipo, 'srd_nada'));
      expect(find.text('Não encontrado'), findsOneWidget, reason: tipo);
    }
  });

  testWidgets('erro de conexão no detalhe tem Tentar de novo', (tester) async {
    final dio = DioFalso(
      {},
      (_) => const RespostaFalsa.falha(DioExceptionType.connectionError),
    );
    await abrirGrimorio(
      tester,
      dio,
      rota: detalhe(TipoCompendio.magias, 'srd_acid-arrow'),
    );
    expect(find.byType(EstadoErro), findsOneWidget);
    expect(find.text('Sem conexão. Confira a internet'), findsOneWidget);

    final antes = dio.pedidos.length;
    await tocar(tester, find.text('Tentar de novo'));
    expect(dio.pedidos, hasLength(antes + 1));
  });

  testWidgets('monstro sem imagem: padrão, statblock e bônus sem rolar', (
    tester,
  ) async {
    final aboleth = {...primeiro('monstros.json'), 'illustration': null};
    await abrirGrimorio(
      tester,
      DioFalso({'/creatures/srd_aboleth/': RespostaFalsa(json: aboleth)}),
      rota: detalhe(TipoCompendio.bestiario, 'srd_aboleth'),
    );

    expect(tester.takeException(), isNull);
    expect(asset(AppImages.menuBestiario), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is Image && w.image is NetworkImage),
      findsNothing,
    );

    expect(find.textContaining('Classe de Armadura 17'), findsOneWidget);
    expect(find.textContaining('Pontos de Vida 135'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
    expect(find.text('(+5)'), findsOneWidget);
    expect(find.textContaining('Aberração Grande'), findsOneWidget);
    expect(find.text('Ataque +9'), findsWidgets);
    expect(find.text('3d6 + 5 concussão'), findsOneWidget);
    expect(find.text('Ações lendárias'), findsOneWidget);
    expect(find.textContaining('Rolar'), findsNothing);
  });

  testWidgets('monstro com imagem da api não quebra sem rede', (tester) async {
    await abrirGrimorio(
      tester,
      DioFalso({
        '/creatures/srd_aboleth/': RespostaFalsa(
          json: primeiro('monstros.json'),
        ),
      }),
      rota: detalhe(TipoCompendio.bestiario, 'srd_aboleth'),
    );
    expect(
      find.byWidgetPredicate((w) => w is Image && w.image is NetworkImage),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('voltar do detalhe não recarrega a lista', (tester) async {
    final dio = apiSrd();
    await abrirGrimorio(tester, dio, rota: '${Rotas.grimorio}/bestiario');
    final antes = dio.pedidos.length;

    await tocar(tester, find.text('Aboleth'));
    expect(find.text('Ações lendárias'), findsOneWidget);
    // o item veio da lista, sem chamar a api
    expect(dio.pedidos, hasLength(antes));

    await tocar(tester, find.bySemanticsLabel('Voltar').first);
    expect(find.text('Aboleth'), findsOneWidget);
    expect(dio.pedidos, hasLength(antes));
  });

  testWidgets('arma mostra dano e propriedade traduzidos', (tester) async {
    await abrirGrimorio(
      tester,
      DioFalso({
        '/items/srd_longsword/': RespostaFalsa(json: primeiro('armas.json')),
      }),
      rota: detalhe(TipoCompendio.armas, 'srd_longsword'),
    );
    expect(find.text('Longsword'), findsOneWidget);
    expect(find.text('1d8 cortante'), findsOneWidget);
    expect(find.text('Versátil (1d10)'), findsOneWidget);
    expect(find.text('Arma'), findsOneWidget);
  });

  testWidgets('classe mostra progressão e pede as subclasses', (tester) async {
    final dio = DioFalso(
      {
        '/classes/srd_barbarian/': RespostaFalsa(
          json: primeiro('classes.json'),
        ),
      },
      (p) => p.path == ApiRotas.classes
          ? RespostaFalsa(
              json: {
                'count': 1,
                'next': null,
                'results': [
                  {
                    'key': 'srd_path-of-the-berserker',
                    'name': 'Path of the Berserker',
                    'subclass_of': {'key': 'srd_barbarian'},
                  },
                ],
              },
            )
          : null,
    );
    await abrirGrimorio(
      tester,
      dio,
      rota: detalhe(TipoCompendio.classes, 'srd_barbarian'),
    );

    expect(find.text('Barbarian'), findsOneWidget);
    expect(find.text('d12'), findsOneWidget);
    expect(find.text('CON, FOR'), findsOneWidget);
    expect(find.text('+2'), findsWidgets);
    expect(
      dio.ultimo.queryParameters[ApiRotas.filtroSubclasseDe],
      'srd_barbarian',
    );

    await tocar(tester, find.text('Ver níveis 6 a 20 ›'));
    expect(find.text('20º'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Path of the Berserker'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Path of the Berserker'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('espécie mostra traços do srd', (tester) async {
    await abrirGrimorio(
      tester,
      DioFalso({
        '/species/srd_dragonborn/': RespostaFalsa(
          json: primeiro('especies.json'),
        ),
      }),
      rota: detalhe(TipoCompendio.especies, 'srd_dragonborn'),
    );
    expect(find.text('Dragonborn'), findsOneWidget);
    expect(find.text('Ability Score Increase'), findsOneWidget);
    expect(asset(AppImages.especieDraconatoF), findsOneWidget);

    await tocar(tester, find.text('Masculino'));
    expect(asset(AppImages.especieDraconatoM), findsOneWidget);
  });

  testWidgets('detalhes abrem sem erro de layout em 360 px', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    for (final (tipo, key, arquivo, rota) in [
      (TipoCompendio.magias, 'srd_acid-arrow', 'magias.json', '/spells/'),
      (TipoCompendio.bestiario, 'srd_aboleth', 'monstros.json', '/creatures/'),
      (TipoCompendio.classes, 'srd_barbarian', 'classes.json', '/classes/'),
      (TipoCompendio.especies, 'srd_dragonborn', 'especies.json', '/species/'),
      (
        TipoCompendio.itensMagicos,
        'srd_adamantine-armor-breastplate',
        'itens_magicos.json',
        '/magicitems/',
      ),
      (TipoCompendio.armaduras, 'srd_chain-mail', 'armaduras.json', '/items/'),
    ]) {
      await abrirGrimorio(
        tester,
        DioFalso({'$rota$key/': RespostaFalsa(json: primeiro(arquivo))}),
        rota: detalhe(tipo, key),
      );
      expect(tester.takeException(), isNull, reason: tipo);
      expect(find.text('Não encontrado'), findsNothing, reason: tipo);
    }
  });
}
