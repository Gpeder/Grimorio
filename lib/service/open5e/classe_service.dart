import 'package:grimorio/model/srd/classe_srd.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class ClasseService {
  ClasseService(this._api);

  final ApiClient _api;

  // lista paginada
  Future<Paginado<ClasseSrd>> listar({int pagina = 1, String? busca}) =>
      _api.listarSrd(
        ApiRotas.classes,
        ClasseSrd.fromJson,
        pagina: pagina,
        busca: busca,
      );

  // uma classe pela key
  Future<ClasseSrd> buscar(String key) =>
      _api.buscarSrd(ApiRotas.classes, key, ClasseSrd.fromJson);
}
