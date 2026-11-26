import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/app/providers/app_providers.dart';
import 'package:grimorio/app/theme/app_theme.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/widgets/erro_widget_card.dart';
import 'package:grimorio/widgets/estado_erro.dart';
import 'package:grimorio/widgets/estado_vazio.dart';
import 'package:grimorio/widgets/lista_paginada.dart';
import 'package:provider/provider.dart';

import '../helpers/dio_falso.dart';

// tela de teste que le o provider, as do app ainda usam o mock
class _TelaMagias extends StatefulWidget {
  const _TelaMagias();

  @override
  State<_TelaMagias> createState() => _TelaMagiasState();
}

class _TelaMagiasState extends State<_TelaMagias> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CompendioProvider>().carregarMagias(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compendio = context.watch<CompendioProvider>();
    return Scaffold(
      body: ListaPaginada<Magia>(
        estado: compendio.magias,
        itemBuilder: (_, m) => ListTile(title: Text(m.nome)),
        onTentarDeNovo: compendio.carregarMagias,
        onCarregarMais: compendio.carregarMaisMagias,
        vazioTitulo: 'Nenhuma magia encontrada',
      ),
    );
  }
}

Widget _app(DioFalso dio) => AppProviders(
  api: clienteFalso(dio),
  child: MaterialApp(theme: AppTheme.dark, home: const _TelaMagias()),
);

void main() {
  testWidgets('EstadoErro: Tentar de novo chama o callback', (tester) async {
    var vezes = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: EstadoErro(mensagem: 'Falhou', onTentarDeNovo: () => vezes++),
        ),
      ),
    );
    await tester.tap(find.text('Tentar de novo'));
    expect(vezes, 1);
  });

  testWidgets('EstadoVazio mostra título e mensagem', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: EstadoVazio(
            titulo: 'Nenhuma magia encontrada',
            mensagem: 'Tente outro nome',
          ),
        ),
      ),
    );
    expect(find.text('Nenhuma magia encontrada'), findsOneWidget);
    expect(find.text('Tente outro nome'), findsOneWidget);
  });

  testWidgets('card de erro de widget não mostra detalhe técnico', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: const ErroWidgetCard()),
    );
    expect(find.text('Algo deu errado nesta parte'), findsOneWidget);
  });

  testWidgets('sem conexão mostra a mensagem amigável e tentar de novo', (
    tester,
  ) async {
    final dio = DioFalso({
      ApiRotas.magias: const RespostaFalsa.falha(
        DioExceptionType.connectionError,
      ),
    });
    await tester.pumpWidget(_app(dio));
    await tester.pumpAndSettle();

    expect(find.text('Sem conexão. Confira a internet'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('Dio'), findsNothing);

    // volta a rede e tenta de novo
    dio.respostas[ApiRotas.magias] = RespostaFalsa(
      json: fixture('magias.json'),
    );
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('Acid Arrow'), findsOneWidget);
  });

  testWidgets('erro no carregar mais mantém os itens da página 1', (
    tester,
  ) async {
    final dio = DioFalso({
      ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
    });
    await tester.pumpWidget(_app(dio));
    await tester.pumpAndSettle();
    expect(find.text('Acid Arrow'), findsOneWidget);

    dio.respostas[ApiRotas.magias] = const RespostaFalsa.falha(
      DioExceptionType.receiveTimeout,
    );
    await tester.tap(find.text('Carregar mais'));
    await tester.pumpAndSettle();

    expect(find.text('Acid Arrow'), findsOneWidget);
    expect(find.text('O servidor demorou para responder'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
    expect(find.textContaining('Dio'), findsNothing);
  });

  testWidgets('lista pronta e vazia mostra EstadoVazio', (tester) async {
    final dio = DioFalso({
      ApiRotas.magias: const RespostaFalsa(
        json: {'count': 0, 'next': null, 'previous': null, 'results': []},
      ),
    });
    await tester.pumpWidget(_app(dio));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma magia encontrada'), findsOneWidget);
  });
}
