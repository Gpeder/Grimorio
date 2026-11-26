import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/open5e/classe_service.dart';
import 'package:grimorio/service/open5e/especie_service.dart';
import 'package:grimorio/service/open5e/item_service.dart';
import 'package:grimorio/service/open5e/magia_service.dart';
import 'package:grimorio/service/open5e/monstro_service.dart';

import '../../helpers/dio_falso.dart';

// toda rota responde a mesma pagina, o teste so olha a query
DioFalso _dio() => DioFalso(
  {},
  (_) => const RespostaFalsa(json: {'count': 0, 'next': null, 'results': []}),
);

void main() {
  test('magias: nivel, nivel minimo, concentracao, classe e escola', () async {
    final dio = _dio();
    await MagiaService(clienteFalso(dio)).listar(
      nivel: 3,
      concentracao: true,
      classeKey: 'srd_wizard',
      escolaKey: 'evocation',
    );
    expect(dio.ultimo.queryParameters, {
      ApiRotas.filtroDocumento: ApiRotas.documentoSrd,
      ApiRotas.ordem: ApiRotas.ordemNivel,
      ApiRotas.filtroNivel: 3,
      ApiRotas.filtroConcentracao: true,
      ApiRotas.filtroClasse: 'srd_wizard',
      ApiRotas.filtroEscola: 'evocation',
    });

    await MagiaService(clienteFalso(dio)).listar(nivelMinimo: 4);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroNivelMinimo], 4);
    expect(
      dio.ultimo.queryParameters.containsKey(ApiRotas.filtroNivel),
      isFalse,
    );
  });

  test('criaturas: tipo e faixa de nd, nd inteiro sem .0', () async {
    final dio = _dio();
    await MonstroService(clienteFalso(dio))
        .listar(tipo: 'dragon', ndMinimo: 11, ndMaximo: 0.5);
    final q = dio.ultimo.queryParameters;
    expect(q[ApiRotas.filtroTipo], 'dragon');
    expect(q[ApiRotas.filtroNdMinimo], 11);
    expect(q[ApiRotas.filtroNdMinimo], isA<int>());
    expect(q[ApiRotas.filtroNdMaximo], 0.5);
    expect(q[ApiRotas.ordem], ApiRotas.ordemNd);
  });

  test('itens magicos: raridade pela key', () async {
    final dio = _dio();
    await ItemService(clienteFalso(dio)).listarMagicos(raridade: 'very-rare');
    expect(dio.ultimo.path, ApiRotas.itensMagicos);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroRaridade], 'very-rare');
  });

  test('armas, armaduras e equipamento pela categoria de /items/', () async {
    final dio = _dio();
    final s = ItemService(clienteFalso(dio));
    await s.listarArmas(busca: 'sword');
    expect(dio.ultimo.path, ApiRotas.itens);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroCategoria], 'weapon');
    expect(dio.ultimo.queryParameters[ApiRotas.filtroBusca], 'sword');

    await s.listarArmaduras();
    expect(
      dio.ultimo.queryParameters[ApiRotas.filtroCategoria],
      'armor,shield',
    );

    await s.listarTodos();
    expect(
      dio.ultimo.queryParameters.containsKey(ApiRotas.filtroCategoria),
      isFalse,
    );
  });

  test('classes base, subclasses e especies base', () async {
    final dio = _dio();
    await ClasseService(clienteFalso(dio)).listar(subclasse: false);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroEhSubclasse], false);

    await ClasseService(clienteFalso(dio)).listar(subclasseDe: 'srd_wizard');
    expect(
      dio.ultimo.queryParameters[ApiRotas.filtroSubclasseDe],
      'srd_wizard',
    );

    await EspecieService(clienteFalso(dio)).listar(subespecie: false);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroSemEspecieMae], true);

    await EspecieService(clienteFalso(dio)).listar(subespecie: true);
    expect(dio.ultimo.queryParameters[ApiRotas.filtroSemEspecieMae], false);
  });

  test('filtro nulo nao vai na query', () async {
    final dio = _dio();
    await MagiaService(clienteFalso(dio)).listar();
    expect(dio.ultimo.queryParameters.keys, [
      ApiRotas.filtroDocumento,
      ApiRotas.ordem,
    ]);
  });
}
