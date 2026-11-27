import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/service/supabase/banco.dart';
import 'package:grimorio/service/supabase/banco_rotas.dart';

// acoes da mesa, cada uma e uma rpc do banco; os testes usam um falso
abstract class MesaService {
  // devolve o id da campanha
  Future<String> entrarCampanha(String codigo, String personagemId);
  Future<void> sairCampanha(String personagemId);
  Future<void> removerHeroi(String personagemId);
  Future<String> novoCodigo(String campanhaId);

  // devolve o numero da sessao
  Future<int> iniciarSessao(String campanhaId);
  Future<void> encerrarSessao(String campanhaId, String resumo);

  Future<void> darXp(String campanhaId, Set<String> personagemIds, int valor);
  Future<void> darItem(
    String campanhaId,
    String personagemId,
    ItemInventario item, {
    required String itemKey,
    required String nome,
  });
  Future<void> desfazer(String registroId);

  // destinos: item_key -> heroi; itens: item_key -> item da mochila
  Future<void> concluirMissao(
    String missaoId, {
    required Map<String, String> destinos,
    required Map<String, ItemInventario> itens,
  });
  Future<void> falharMissao(String missaoId);

  Future<void> apagarMinhaConta();
}

class SupabaseMesaService implements MesaService {
  SupabaseMesaService(this._banco);

  final Banco _banco;

  Future<T> _rpc<T>(String nome, [Map<String, dynamic>? params]) =>
      _banco.rodar('rpc $nome', (db) => db.rpc<T>(nome, params: params));

  @override
  Future<String> entrarCampanha(String codigo, String personagemId) =>
      _rpc<String>(BancoRotas.entrarCampanha, {
        'codigo': codigo,
        'personagem': personagemId,
      });

  @override
  Future<void> sairCampanha(String personagemId) =>
      _rpc<void>(BancoRotas.sairCampanha, {'personagem': personagemId});

  @override
  Future<void> removerHeroi(String personagemId) =>
      _rpc<void>(BancoRotas.removerHeroi, {'personagem': personagemId});

  @override
  Future<String> novoCodigo(String campanhaId) =>
      _rpc<String>(BancoRotas.novoCodigo, {'campanha': campanhaId});

  @override
  Future<int> iniciarSessao(String campanhaId) =>
      _rpc<int>(BancoRotas.iniciarSessao, {'campanha': campanhaId});

  @override
  Future<void> encerrarSessao(String campanhaId, String resumo) => _rpc<void>(
    BancoRotas.encerrarSessao,
    {'campanha': campanhaId, 'resumo': resumo},
  );

  @override
  Future<void> darXp(String campanhaId, Set<String> personagemIds, int valor) =>
      _rpc<void>(BancoRotas.darXp, {
        'campanha': campanhaId,
        'personagens': personagemIds.toList(),
        'valor': valor,
      });

  @override
  Future<void> darItem(
    String campanhaId,
    String personagemId,
    ItemInventario item, {
    required String itemKey,
    required String nome,
  }) => _rpc<void>(BancoRotas.darItem, {
    'campanha': campanhaId,
    'personagem': personagemId,
    'item': item.toJson(),
    'item_key': itemKey,
    'nome': nome,
  });

  @override
  Future<void> desfazer(String registroId) =>
      _rpc<void>(BancoRotas.desfazerRegistro, {'registro': registroId});

  @override
  Future<void> concluirMissao(
    String missaoId, {
    required Map<String, String> destinos,
    required Map<String, ItemInventario> itens,
  }) => _rpc<void>(BancoRotas.concluirMissao, {
    'missao': missaoId,
    'destinos': destinos,
    'itens': {for (final e in itens.entries) e.key: e.value.toJson()},
  });

  @override
  Future<void> falharMissao(String missaoId) =>
      _rpc<void>(BancoRotas.falharMissao, {'missao': missaoId});

  @override
  Future<void> apagarMinhaConta() => _rpc<void>(BancoRotas.apagarMinhaConta);
}
