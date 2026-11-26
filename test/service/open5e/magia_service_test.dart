import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/open5e/magia_service.dart';

import '../../helpers/dio_falso.dart';

void main() {
  test('lista manda o documento do srd e lê o Paginado', () async {
    final dio = DioFalso({
      ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
    });
    final r = await MagiaService(clienteFalso(dio)).listar();

    expect(dio.ultimo.queryParameters, {
      'document__key__in': 'srd-2014',
      'ordering': 'level,name',
    });
    expect(r.total, 319);
    expect(r.temMais, isTrue);
    expect(r.itens.single.nome, 'Acid Arrow');
  });

  test('busca e página vão na query', () async {
    final dio = DioFalso({
      ApiRotas.magias: RespostaFalsa(json: fixture('magias.json')),
    });
    await MagiaService(clienteFalso(dio)).listar(pagina: 3, busca: ' fogo ');

    expect(dio.ultimo.queryParameters, {
      'document__key__in': 'srd-2014',
      'page': 3,
      'name__icontains': 'fogo',
      'ordering': 'level,name',
    });
  });

  test('buscar usa o detalhe pela key', () async {
    final magia = fixture('magias.json')['results'][0];
    final dio = DioFalso({
      '/spells/srd_acid-arrow/': RespostaFalsa(json: magia),
    });
    final m = await MagiaService(clienteFalso(dio)).buscar('srd_acid-arrow');

    expect(m.nivel, 2);
    expect(dio.ultimo.queryParameters['document__key__in'], 'srd-2014');
  });
}
