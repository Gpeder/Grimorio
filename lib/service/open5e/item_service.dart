import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

// itens comuns, magicos, armas e armaduras
// armas e armaduras saem de /items/ pela categoria, que aceita busca
class ItemService {
  ItemService(this._api);

  final ApiClient _api;

  Future<Paginado<ItemSrd>> listarItens({int pagina = 1, String? busca}) =>
      _listar(ApiRotas.itens, pagina, busca, {
        ApiRotas.filtroCategoria: ApiRotas.categoriasEquipamento,
      });

  Future<Paginado<ItemSrd>> listarMagicos({
    int pagina = 1,
    String? busca,
    String? raridade,
  }) => _listar(ApiRotas.itensMagicos, pagina, busca, {
    ApiRotas.filtroRaridade: raridade,
  });

  Future<Paginado<ItemSrd>> listarArmas({int pagina = 1, String? busca}) =>
      _listar(ApiRotas.itens, pagina, busca, {
        ApiRotas.filtroCategoria: ApiRotas.categoriasArma,
      });

  Future<Paginado<ItemSrd>> listarArmaduras({int pagina = 1, String? busca}) =>
      _listar(ApiRotas.itens, pagina, busca, {
        ApiRotas.filtroCategoria: ApiRotas.categoriasArmadura,
      });

  // item comum, arma ou armadura pela key
  Future<ItemSrd> buscar(String key) =>
      _api.buscarSrd(ApiRotas.itens, key, ItemSrd.fromJson);

  // item magico pela key
  Future<ItemSrd> buscarMagico(String key) =>
      _api.buscarSrd(ApiRotas.itensMagicos, key, ItemSrd.fromJson);

  Future<Paginado<ItemSrd>> _listar(
    String rota,
    int pagina,
    String? busca,
    Map<String, Object?> filtros,
  ) => _api.listarSrd(
    rota,
    ItemSrd.fromJson,
    pagina: pagina,
    busca: busca,
    ordem: ApiRotas.ordemNome,
    filtros: filtros,
  );
}
