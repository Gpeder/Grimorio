import 'package:flutter/foundation.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/service/supabase/perfil_service.dart';

// tabela perfis em memoria, responde na hora
class PerfilServiceFalso implements PerfilService {
  PerfilServiceFalso({List<Usuario>? perfis})
    : perfis = {
        for (final p in perfis ?? [usuarioMock]) p.id: p,
      };

  final Map<String, Usuario> perfis;

  // cada atualizar recebido, para conferir que so vai o que mudou
  final atualizacoes = <Map<String, dynamic>>[];
  int buscas = 0;

  // a proxima chamada falha com esse erro
  Object? proximoErro;

  @override
  Future<Usuario> buscar(String id) {
    buscas++;
    _falhar();
    return SynchronousFuture(
      perfis[id] ?? Usuario(id: id, nome: 'Aventureiro', email: ''),
    );
  }

  @override
  Future<void> atualizar(String id, Map<String, dynamic> campos) {
    _falhar();
    atualizacoes.add(campos);
    final atual = perfis[id];
    if (atual != null) {
      perfis[id] = Usuario.fromJson({...atual.toJson(), ...campos});
    }
    return SynchronousFuture(null);
  }

  // nomes dos perfis guardados e dos outros usuarios do mock
  @override
  Future<Map<String, String>> nomes(Iterable<String> ids) => SynchronousFuture({
    for (final id in ids) id: ?(perfis[id]?.nome ?? nomesUsuariosMock[id]),
  });

  void _falhar() {
    final erro = proximoErro;
    if (erro == null) return;
    proximoErro = null;
    throw erro;
  }
}
