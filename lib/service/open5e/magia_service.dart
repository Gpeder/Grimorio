import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class MagiaService {
  MagiaService(this._api);

  final ApiClient _api;

  // lista paginada
  Future<Paginado<Magia>> listar({int pagina = 1, String? busca}) => _api
      .listarSrd(ApiRotas.magias, Magia.fromJson, pagina: pagina, busca: busca);

  // uma magia pela key
  Future<Magia> buscar(String key) =>
      _api.buscarSrd(ApiRotas.magias, key, Magia.fromJson);
}
