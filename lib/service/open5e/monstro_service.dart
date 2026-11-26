import 'package:grimorio/model/srd/monstro_srd.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class MonstroService {
  MonstroService(this._api);

  final ApiClient _api;

  // lista paginada por nd e nome
  Future<Paginado<MonstroSrd>> listar({
    int pagina = 1,
    String? busca,
    String? tipo,
    double? ndMinimo,
    double? ndMaximo,
  }) => _api.listarSrd(
    ApiRotas.monstros,
    MonstroSrd.fromJson,
    pagina: pagina,
    busca: busca,
    ordem: ApiRotas.ordemNd,
    filtros: {
      ApiRotas.filtroTipo: tipo,
      ApiRotas.filtroNdMinimo: numeroDaQuery(ndMinimo),
      ApiRotas.filtroNdMaximo: numeroDaQuery(ndMaximo),
    },
  );

  // uma criatura pela key
  Future<MonstroSrd> buscar(String key) =>
      _api.buscarSrd(ApiRotas.monstros, key, MonstroSrd.fromJson);
}
