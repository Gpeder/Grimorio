import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/controller/auth/validador_auth.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:grimorio/service/supabase/auth_service.dart';

// sessao do usuario, as acoes relancam AuthErro para a tela
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _assinatura = _service.logadoMudou.listen(
      (logado) {
        AppLog.info(TagLog.auth, logado ? 'sessao aberta' : 'sessao fechada');
        notifyListeners();
      },
      onError: (Object e, StackTrace stack) =>
          AppLog.erro(TagLog.auth, 'sessao', erro: e, stack: stack),
    );
  }

  final AuthService _service;
  StreamSubscription<bool>? _assinatura;

  bool _carregando = false;
  String? _emailPendente;
  bool _recuperandoSenha = false;

  bool get logado => _service.usuarioId != null;
  String? get usuarioId => _service.usuarioId;
  String? get email => _service.email;
  bool get carregando => _carregando;

  // e-mail esperando o codigo de confirmacao
  String? get emailPendente => _emailPendente;

  // o codigo de recuperacao ja abre a sessao, o router espera a senha nova
  bool get recuperandoSenha => _recuperandoSenha;

  Future<void> entrar(String email, String senha) => _acao('entrar', () async {
    final limpo = ValidadorAuth.limparEmail(email);
    try {
      await _service.entrar(limpo, senha);
      _emailPendente = null;
    } on AuthErro catch (erro) {
      // conta sem confirmar: manda outro codigo e a tela leva para confirmar
      if (erro.tipo == TipoErroAuth.emailNaoConfirmado) {
        _emailPendente = limpo;
        await _reenviarSemFalhar(limpo);
      }
      rethrow;
    }
  });

  Future<void> cadastrar(String nome, String email, String senha) =>
      _acao('cadastrar', () async {
        final limpo = ValidadorAuth.limparEmail(email);
        await _service.cadastrar(ValidadorAuth.limparNome(nome), limpo, senha);
        _emailPendente = limpo;
      });

  Future<void> confirmarCadastro(String codigo) =>
      _acao('confirmarCadastro', () async {
        final email = _emailPendente;
        if (email == null) throw const AuthErro(TipoErroAuth.desconhecido);
        await _service.confirmarCadastro(email, codigo.trim());
        _emailPendente = null;
      });

  Future<void> reenviarConfirmacao() => _acao('reenviarConfirmacao', () async {
    final email = _emailPendente;
    if (email == null) throw const AuthErro(TipoErroAuth.desconhecido);
    await _service.reenviarConfirmacao(email);
  });

  Future<void> pedirCodigoSenha(String email) => _acao(
    'pedirCodigoSenha',
    () => _service.pedirCodigoSenha(ValidadorAuth.limparEmail(email)),
  );

  // liga antes de chamar: a sessao nova chega antes da resposta
  Future<void> confirmarCodigoSenha(String email, String codigo) =>
      _acao('confirmarCodigoSenha', () async {
        _recuperandoSenha = true;
        try {
          await _service.confirmarCodigoSenha(
            ValidadorAuth.limparEmail(email),
            codigo.trim(),
          );
        } catch (_) {
          _recuperandoSenha = false;
          rethrow;
        }
      });

  Future<void> trocarSenha(String novaSenha) => _acao('trocarSenha', () async {
    await _service.trocarSenha(novaSenha);
    _recuperandoSenha = false;
  });

  // desistiu da senha nova depois do codigo: fecha a sessao aberta
  Future<void> cancelarRecuperacao() async {
    if (!_recuperandoSenha) return;
    await _acao('cancelarRecuperacao', _service.sair);
    _recuperandoSenha = false;
    notifyListeners();
  }

  Future<void> sair() => _acao('sair', () async {
    await _service.sair();
    _emailPendente = null;
    _recuperandoSenha = false;
  });

  Future<void> _reenviarSemFalhar(String email) async {
    try {
      await _service.reenviarConfirmacao(email);
    } catch (e, stack) {
      AppLog.erro(TagLog.auth, 'reenvio apos login', erro: e, stack: stack);
    }
  }

  // carregando liga e sempre desliga, erro que nao e AuthErro vira um
  Future<void> _acao(String onde, Future<void> Function() acao) async {
    _carregando = true;
    notifyListeners();
    try {
      await acao();
    } on AuthErro {
      rethrow;
    } catch (e, stack) {
      AppLog.erro(TagLog.auth, onde, erro: e, stack: stack);
      throw const AuthErro(TipoErroAuth.desconhecido);
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    super.dispose();
  }
}
