import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/service/api/api_erro.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/open5e/condicao_service.dart';
import 'package:grimorio/service/open5e/item_service.dart';
import 'package:grimorio/service/open5e/monstro_service.dart';

import '../../helpers/dio_falso.dart';

void main() {
  test('lista manda o documento do srd e lê o Paginado', () async {
    final dio = DioFalso({
      ApiRotas.monstros: RespostaFalsa(json: fixture('monstros.json')),
    });
    final r = await MonstroService(clienteFalso(dio)).listar();

    expect(dio.ultimo.queryParameters['document__key__in'], 'srd-2014');
    expect(r.total, 325);
    expect(r.temMais, isTrue);
    expect(r.itens.single.nome, 'Aboleth');
  });

  test('key que não existe vira naoEncontrado', () {
    final api = clienteFalso(DioFalso());
    expect(
      MonstroService(api).buscar('srd_nada'),
      throwsA(
        isA<ApiErro>().having((e) => e.tipo, 'tipo', TipoErroApi.naoEncontrado),
      ),
    );
  });

  test('condições usam o documento core', () async {
    final dio = DioFalso({
      ApiRotas.condicoes: RespostaFalsa(json: fixture('condicoes.json')),
    });
    await CondicaoService(clienteFalso(dio)).listar();
    expect(dio.ultimo.queryParameters['document__key__in'], 'core');
  });

  test('itens cobrem as quatro rotas', () async {
    final dio = DioFalso({
      ApiRotas.itens: RespostaFalsa(json: fixture('itens.json')),
      ApiRotas.itensMagicos: RespostaFalsa(json: fixture('itens_magicos.json')),
      ApiRotas.armas: RespostaFalsa(json: fixture('armas.json')),
      ApiRotas.armaduras: RespostaFalsa(json: fixture('armaduras.json')),
    });
    final s = ItemService(clienteFalso(dio));
    expect((await s.listarItens()).itens.single.nome, 'Abacus');
    expect((await s.listarMagicos()).itens.single.raridade, 'Uncommon');
    expect((await s.listarArmas()).itens.single.dano, '1d8');
    expect((await s.listarArmaduras()).itens.single.caBase, 14);
    expect(dio.pedidos.map((p) => p.path), [
      ApiRotas.itens,
      ApiRotas.itensMagicos,
      ApiRotas.armas,
      ApiRotas.armaduras,
    ]);
  });
}
