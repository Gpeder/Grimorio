import 'dart:async';

import 'package:grimorio/model/usuario_mock.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:grimorio/service/supabase/auth_service.dart';

// conta guardada no falso
class ContaFalsa {
  ContaFalsa({
    required this.id,
    required this.senha,
    this.nome = '',
    this.confirmada = true,
  });

  final String id;
  String senha;
  final String nome;
  bool confirmada;
}

// auth em memoria, sem supabase
class AuthServiceFalso implements AuthService {
  AuthServiceFalso({
    bool logado = true,
    this.atraso = Duration.zero,
    this.codigoCerto = '123456',
  }) {
    contas[usuarioMock.email] = ContaFalsa(
      id: usuarioMock.id,
      senha: senhaMock,
      nome: usuarioMock.nome,
    );
    if (logado) _logar(usuarioMock.id, usuarioMock.email);
  }

  static const senhaMock = 'senha123';

  // demora para responder, para testar toque duplo
  final Duration atraso;
  final String codigoCerto;

  final contas = <String, ContaFalsa>{};
  final chamadas = <String, int>{};

  // o proximo metodo chamado falha com esse tipo
  TipoErroAuth? proximoErro;

  String? _usuarioId;
  String? _email;
  final _logado = StreamController<bool>.broadcast();

  int vezes(String metodo) => chamadas[metodo] ?? 0;

  @override
  String? get usuarioId => _usuarioId;

  @override
  String? get email => _email;

  @override
  Stream<bool> get logadoMudou => _logado.stream;

  @override
  Future<void> entrar(String email, String senha) async {
    await _passo('entrar');
    final conta = contas[email];
    if (conta == null || conta.senha != senha) {
      throw const AuthErro(TipoErroAuth.credenciaisInvalidas);
    }
    if (!conta.confirmada) {
      throw const AuthErro(TipoErroAuth.emailNaoConfirmado);
    }
    _logar(conta.id, email);
  }

  @override
  Future<void> cadastrar(String nome, String email, String senha) async {
    await _passo('cadastrar');
    if (contas.containsKey(email)) {
      throw const AuthErro(TipoErroAuth.emailJaUsado);
    }
    contas[email] = ContaFalsa(
      id: 'u_${contas.length}',
      senha: senha,
      nome: nome,
      confirmada: false,
    );
  }

  @override
  Future<void> confirmarCadastro(String email, String codigo) async {
    await _passo('confirmarCadastro');
    final conta = contas[email];
    if (conta == null || codigo != codigoCerto) {
      throw const AuthErro(TipoErroAuth.codigoInvalido);
    }
    conta.confirmada = true;
    _logar(conta.id, email);
  }

  @override
  Future<void> reenviarConfirmacao(String email) =>
      _passo('reenviarConfirmacao');

  @override
  Future<void> pedirCodigoSenha(String email) => _passo('pedirCodigoSenha');

  @override
  Future<void> confirmarCodigoSenha(String email, String codigo) async {
    await _passo('confirmarCodigoSenha');
    final conta = contas[email];
    if (conta == null || codigo != codigoCerto) {
      throw const AuthErro(TipoErroAuth.codigoInvalido);
    }
    _logar(conta.id, email);
  }

  @override
  Future<void> trocarSenha(String novaSenha) async {
    await _passo('trocarSenha');
    final conta = contas[_email];
    if (conta == null) throw const AuthErro(TipoErroAuth.desconhecido);
    if (conta.senha == novaSenha) {
      throw const AuthErro(TipoErroAuth.senhaIgual);
    }
    conta.senha = novaSenha;
  }

  @override
  Future<void> sair() async {
    await _passo('sair');
    _usuarioId = null;
    _email = null;
    _logado.add(false);
  }

  void _logar(String id, String email) {
    _usuarioId = id;
    _email = email;
    _logado.add(true);
  }

  Future<void> _passo(String metodo) async {
    chamadas[metodo] = vezes(metodo) + 1;
    if (atraso > Duration.zero) await Future<void>.delayed(atraso);
    final erro = proximoErro;
    if (erro != null) {
      proximoErro = null;
      throw AuthErro(erro);
    }
  }
}
