import 'package:grimorio/model/srd/classe_srd.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class ClasseService {
  ClasseService(this._api);

  final ApiClient _api;

  // lista paginada; subclasse false traz so as classes base
  Future<Paginado<ClasseSrd>> listar({
    int pagina = 1,
    String? busca,
    bool? subclasse,
    String? subclasseDe,
  }) => _api.listarSrd(
    ApiRotas.classes,
    ClasseSrd.fromJson,
    pagina: pagina,
    busca: busca,
    ordem: ApiRotas.ordemNome,
    filtros: {
      ApiRotas.filtroEhSubclasse: subclasse,
      ApiRotas.filtroSubclasseDe: subclasseDe,
    },
  );

  // uma classe pela key
  Future<ClasseSrd> buscar(String key) =>
      _api.buscarSrd(ApiRotas.classes, key, ClasseSrd.fromJson);
}
