import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/app/log/mensagem_erro.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/settings/gerenciador_perfil.dart';
import 'package:grimorio/model/usuario.dart';
import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/service/supabase/perfil_service.dart';

// usuario logado e preferencias, o perfil vem do banco
class UsuarioProvider extends ChangeNotifier {
  UsuarioProvider({Usuario? usuario, this._perfis, this._auth, this.aoEntrar})
    : _usuario = usuario ?? (_auth == null ? usuarioMock : Usuario.vazio) {
    _auth?.addListener(_sincronizar);
    _sincronizar();
  }

  final PerfilService? _perfis;
  final AuthProvider? _auth;

  // ponte do mock: herois e campanhas adotam o id logado
  final void Function(String usuarioId)? aoEntrar;

  static const _gerenciador = GerenciadorPerfil();

  Usuario _usuario;
  String? _idAtual;
  Carregamento _carregamento = Carregamento.inicial;
  String? _mensagemErro;

  Usuario get usuario => _usuario;
  Carregamento get carregamento => _carregamento;
  String? get mensagemErro => _mensagemErro;

  // entrou, saiu ou trocou de conta
  void _sincronizar() {
    final auth = _auth;
    if (auth == null) return;
    final id = auth.usuarioId;
    if (id == _idAtual) return;
    _idAtual = id;

    if (id == null) {
      AppLog.info(TagLog.provider, 'usuario saiu, perfil limpo');
      _usuario = Usuario.vazio;
      _carregamento = Carregamento.inicial;
      _mensagemErro = null;
      notifyListeners();
      return;
    }
    aoEntrar?.call(id);
    unawaited(carregar());
  }

  Future<void> carregar() async {
    final id = _idAtual;
    final perfis = _perfis;
    if (id == null || perfis == null) return;
    final email = _auth?.email ?? '';

    _usuario = _usuario.copyWith(id: id, email: email);
    _carregamento = Carregamento.carregando;
    _mensagemErro = null;
    notifyListeners();

    try {
      final perfil = await perfis.buscar(id);
      // trocou de conta no meio
      if (_idAtual != id) return;
      _usuario = perfil.copyWith(
        id: id,
        email: email,
        vibrar: _usuario.vibrar,
        confirmarApagar: _usuario.confirmarApagar,
        compendioAtualizadoEm: _usuario.compendioAtualizadoEm,
      );
      _carregamento = Carregamento.pronto;
    } catch (e, stack) {
      if (_idAtual != id) return;
      _mensagemErro = mensagemDeErro(
        e,
        stack: stack,
        tag: TagLog.provider,
        onde: 'carregar perfil',
      );
      _carregamento = Carregamento.erro;
    }
    notifyListeners();
  }

  // troca na hora e salva so o que mudou; se falhar volta e relanca
  Future<void> atualizar(Usuario novo) async {
    final anterior = _usuario;
    _usuario = novo;
    notifyListeners();

    final id = _idAtual;
    final perfis = _perfis;
    if (id == null || perfis == null) return;
    final campos = _gerenciador.camposMudados(anterior, novo);
    if (campos.isEmpty) return;

    try {
      await perfis.atualizar(id, campos);
    } catch (e, stack) {
      AppLog.erro(
        TagLog.provider,
        'perfil nao salvou ${campos.keys.join(', ')}',
        erro: e,
        stack: stack,
      );
      _usuario = _gerenciador.voltarCampos(_usuario, anterior, campos.keys);
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _auth?.removeListener(_sincronizar);
    super.dispose();
  }
}
