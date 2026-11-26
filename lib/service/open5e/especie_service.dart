import 'package:grimorio/model/srd/especie.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class EspecieService {
  EspecieService(this._api);

  final ApiClient _api;

  // lista paginada
  Future<Paginado<Especie>> listar({int pagina = 1, String? busca}) =>
      _api.listarSrd(
        ApiRotas.especies,
        Especie.fromJson,
        pagina: pagina,
        busca: busca,
      );

  // uma especie pela key
  Future<Especie> buscar(String key) =>
      _api.buscarSrd(ApiRotas.especies, key, Especie.fromJson);
}
