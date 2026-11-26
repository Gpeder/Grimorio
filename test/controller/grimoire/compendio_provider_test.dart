import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/grimoire/filtros_srd.dart';
import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/service/api/api_erro.dart';
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

  group('detalhe', () {
    test('usa o item da lista sem chamar o service', () async {
      final dio = DioFalso({
        ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
      });
      final p = compendio(dio);
      await p.carregarMagias();
      final pedidos = dio.pedidos.length;

      await p.carregarDetalhe(TipoSrd.magia, 'srd_acid-arrow');

      expect(dio.pedidos, hasLength(pedidos));
      final d = p.detalhe<Magia>(TipoSrd.magia, 'srd_acid-arrow');
      expect(d.carregamento, Carregamento.pronto);
      expect(d.item?.nome, 'Acid Arrow');
    });

    test('sem lista chama o buscar pela key', () async {
      final magia = fixture('magias.json')['results'][0];
      final dio = DioFalso({
        '/spells/srd_acid-arrow/': RespostaFalsa(json: magia),
      });
      final p = compendio(dio);

      await p.carregarDetalhe(TipoSrd.magia, 'srd_acid-arrow');

      expect(dio.pedidos.single.path, '/spells/srd_acid-arrow/');
      expect(p.detalhe<Magia>(TipoSrd.magia, 'srd_acid-arrow').item?.nivel, 2);

      // segunda vez nao chama de novo
      await p.carregarDetalhe(TipoSrd.magia, 'srd_acid-arrow');
      expect(dio.pedidos, hasLength(1));
    });

    test('404 fica em erro com naoEncontrado', () async {
      final p = compendio(DioFalso());

      await p.carregarDetalhe(TipoSrd.monstro, 'srd_nada');

      final d = p.detalhe<Object>(TipoSrd.monstro, 'srd_nada');
      expect(d.carregamento, Carregamento.erro);
      expect(d.tipoErro, TipoErroApi.naoEncontrado);
      expect(d.naoEncontrado, isTrue);
      expect(d.mensagemErro, 'Não encontrado');
    });

    test('arma busca em /items/', () async {
      final arma = fixture('armas.json')['results'][0];
      final dio = DioFalso({
        '/items/srd_longsword/': RespostaFalsa(json: arma),
      });
      final p = compendio(dio);
      await p.carregarDetalhe(TipoSrd.arma, 'srd_longsword');
      expect(dio.ultimo.path, '/items/srd_longsword/');
    });
  });

  group('sem recarregar a toa', () {
    test('mesma busca e filtro nao chamam a api; filtro novo chama', () async {
      final dio = DioFalso({
        ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
      });
      final p = compendio(dio);
      await p.carregarMagias(busca: 'acid');
      expect(dio.pedidos, hasLength(1));

      // voltar para a tela
      await p.carregarMagias(busca: 'acid');
      expect(dio.pedidos, hasLength(1));

      await p.carregarMagias(
        busca: 'acid',
        filtro: const FiltroMagia(nivel: 2),
      );
      expect(dio.pedidos, hasLength(2));
      expect(dio.ultimo.queryParameters[ApiRotas.filtroNivel], 2);
      expect(dio.ultimo.queryParameters.containsKey(ApiRotas.pagina), isFalse);

      // filtro omitido mantem o atual
      await p.carregarMagias(busca: 'acid');
      expect(dio.pedidos, hasLength(2));
      expect(p.filtroMagias, const FiltroMagia(nivel: 2));
    });

    test('forcar recarrega mesmo pronto', () async {
      final dio = DioFalso({
        ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
      });
      final p = compendio(dio);
      await p.carregarMagias();
      await p.carregarMagias(forcar: true);
      expect(dio.pedidos, hasLength(2));
    });

    test('resposta velha de busca nao sobrescreve a nova', () async {
      final lenta = {
        ...fixture('magias.json'),
        'count': 99,
        'results': [
          {'key': 'srd_velha', 'name': 'Velha'},
        ],
      };
      final rapida = {
        ...fixture('magias.json'),
        'count': 7,
        'results': [
          {'key': 'srd_fire-bolt', 'name': 'Fire Bolt'},
        ],
      };
      final dio = DioFalso(
        {},
        (pedido) => switch (pedido.queryParameters[ApiRotas.filtroBusca]) {
          'fi' => RespostaFalsa(
            json: lenta,
            atraso: const Duration(milliseconds: 60),
          ),
          'fire' => RespostaFalsa(json: rapida),
          _ => null,
        },
      );
      final p = compendio(dio);

      final fi = p.carregarMagias(busca: 'fi');
      final fire = p.carregarMagias(busca: 'fire');
      await fire;
      expect(p.magias.itens.single.nome, 'Fire Bolt');

      await fi;
      expect(p.magias.busca, 'fire');
      expect(p.magias.total, 7);
      expect(p.magias.itens.single.nome, 'Fire Bolt');
    });
  });
}
