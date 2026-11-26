import 'package:grimorio/model/srd/monstro_srd.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class MonstroService {
  MonstroService(this._api);

  final ApiClient _api;

  // lista paginada
  Future<Paginado<MonstroSrd>> listar({int pagina = 1, String? busca}) =>
      _api.listarSrd(
        ApiRotas.monstros,
        MonstroSrd.fromJson,
        pagina: pagina,
        busca: busca,
      );

  // uma criatura pela key
  Future<MonstroSrd> buscar(String key) =>
      _api.buscarSrd(ApiRotas.monstros, key, MonstroSrd.fromJson);
}
