import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

class MagiaService {
  MagiaService(this._api);

  final ApiClient _api;

  // lista paginada por nivel e nome
  Future<Paginado<Magia>> listar({
    int pagina = 1,
    String? busca,
    int? nivel,
    int? nivelMinimo,
    bool? concentracao,
    String? classeKey,
    String? escolaKey,
  }) => _api.listarSrd(
    ApiRotas.magias,
    Magia.fromJson,
    pagina: pagina,
    busca: busca,
    ordem: ApiRotas.ordemNivel,
    filtros: {
      ApiRotas.filtroNivel: nivel,
      ApiRotas.filtroNivelMinimo: nivelMinimo,
      ApiRotas.filtroConcentracao: concentracao,
      ApiRotas.filtroClasse: classeKey,
      ApiRotas.filtroEscola: escolaKey,
    },
  );

  // uma magia pela key
  Future<Magia> buscar(String key) =>
      _api.buscarSrd(ApiRotas.magias, key, Magia.fromJson);
}
