import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/open5e/classe_service.dart';
import 'package:grimorio/service/open5e/condicao_service.dart';
import 'package:grimorio/service/open5e/especie_service.dart';
import 'package:grimorio/service/open5e/item_service.dart';
import 'package:grimorio/service/open5e/magia_service.dart';
import 'package:grimorio/service/open5e/monstro_service.dart';

import '../../helpers/dio_falso.dart';

CompendioProvider compendio(DioFalso dio) {
  final api = clienteFalso(dio);
  return CompendioProvider(
    magias: MagiaService(api),
    monstros: MonstroService(api),
    itens: ItemService(api),
    classes: ClasseService(api),
    especies: EspecieService(api),
    condicoes: CondicaoService(api),
  );
}

void main() {
  test('carregarMagias passa por carregando e termina em pronto', () async {
    final p = compendio(
      DioFalso({ApiRotas.magias: RespostaFalsa(json: fixture('magias.json'))}),
    );
    final vistos = <Carregamento>[];
    p.addListener(() => vistos.add(p.magias.carregamento));

    expect(p.magias.carregamento, Carregamento.inicial);
    await p.carregarMagias();

    expect(vistos, [Carregamento.carregando, Carregamento.pronto]);
    expect(p.magias.itens.single.nome, 'Acid Arrow');
    expect(p.magias.total, 319);
    expect(p.magias.temMais, isTrue);
  });

  test('service falhando deixa em erro com a mensagem do ApiErro', () async {
    final p = compendio(
      DioFalso({
        ApiRotas.magias: const RespostaFalsa.falha(
          DioExceptionType.connectionError,
        ),
      }),
    );
    await p.carregarMagias();

    expect(p.magias.carregamento, Carregamento.erro);
    expect(p.magias.mensagemErro, 'Sem conexão. Confira a internet');
  });

  test('erro no carregar mais mantém a página 1', () async {
    final dio = DioFalso({
      ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
    });
    final p = compendio(dio);
    await p.carregarMagias();

    dio.respostas[ApiRotas.magias] = const RespostaFalsa(status: 500, json: {});
    await p.carregarMaisMagias();

    expect(p.magias.carregamento, Carregamento.pronto);
    expect(p.magias.itens, hasLength(1));
    expect(
      p.magias.erroAoCarregarMais,
      'O servidor está com problema. Tente de novo',
    );
    expect(dio.ultimo.queryParameters['page'], 2);
  });

  test('carregar mais soma os itens da próxima página', () async {
    final dio = DioFalso({
      ApiRotas.monstros: RespostaFalsa(json: fixture('monstros.json')),
    });
    final p = compendio(dio);
    await p.carregarMonstros();
    await p.carregarMaisMonstros();
    expect(p.monstros.itens, hasLength(2));
    expect(p.monstros.pagina, 2);
  });

  test('busca nova ignora a resposta da busca anterior', () async {
    final p = compendio(
      DioFalso({ApiRotas.magias: RespostaFalsa(json: fixture('magias.json'))}),
    );
    final primeira = p.carregarMagias(busca: 'a');
    final segunda = p.carregarMagias(busca: 'acid');
    await Future.wait([primeira, segunda]);
    expect(p.magias.busca, 'acid');
    expect(p.magias.carregamento, Carregamento.pronto);
  });
}
