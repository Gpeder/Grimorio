import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/service/api/api_client.dart';
import 'package:grimorio/service/api/api_rotas.dart';
import 'package:grimorio/service/api/paginado.dart';
import 'package:grimorio/service/open5e/consulta_srd.dart';

// itens comuns, magicos, armas e armaduras
class ItemService {
  ItemService(this._api);

  final ApiClient _api;

  Future<Paginado<ItemSrd>> listarItens({int pagina = 1, String? busca}) =>
      _listar(ApiRotas.itens, pagina, busca);

  Future<Paginado<ItemSrd>> listarMagicos({int pagina = 1, String? busca}) =>
      _listar(ApiRotas.itensMagicos, pagina, busca);

  Future<Paginado<ItemSrd>> listarArmas({int pagina = 1, String? busca}) =>
      _listar(ApiRotas.armas, pagina, busca);

  Future<Paginado<ItemSrd>> listarArmaduras({int pagina = 1, String? busca}) =>
      _listar(ApiRotas.armaduras, pagina, busca);

  // item comum pela key
  Future<ItemSrd> buscar(String key) =>
      _api.buscarSrd(ApiRotas.itens, key, ItemSrd.fromJson);

  // item magico pela key
  Future<ItemSrd> buscarMagico(String key) =>
      _api.buscarSrd(ApiRotas.itensMagicos, key, ItemSrd.fromJson);

  Future<Paginado<ItemSrd>> _listar(String rota, int pagina, String? busca) =>
      _api.listarSrd(rota, ItemSrd.fromJson, pagina: pagina, busca: busca);
}
