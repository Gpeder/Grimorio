import 'package:grimorio/app/config/ambiente.dart';
import 'package:grimorio/app/log/app_log.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// contrato do login, os testes usam um falso
abstract class AuthService {
  String? get usuarioId;
  String? get email;
  Stream<bool> get logadoMudou;
  Future<void> entrar(String email, String senha);
  Future<void> cadastrar(String nome, String email, String senha);
  Future<void> confirmarCadastro(String email, String codigo);
  Future<void> reenviarConfirmacao(String email);
  Future<void> pedirCodigoSenha(String email);
  Future<void> confirmarCodigoSenha(String email, String codigo);
  Future<void> trocarSenha(String novaSenha);
  Future<void> sair();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService({this._cliente});

  final GoTrueClient? _cliente;

  // sem env.json o supabase nao foi iniciado
  GoTrueClient? get _auth =>
      _cliente ?? (Ambiente.configurado ? Supabase.instance.client.auth : null);

  @override
  String? get usuarioId => _auth?.currentUser?.id;

  @override
  String? get email => _auth?.currentUser?.email;

  @override
  Stream<bool> get logadoMudou =>
      _auth?.onAuthStateChange.map((s) => s.session != null).distinct() ??
      const Stream.empty();

  @override
  Future<void> entrar(String email, String senha) => _rodar(
    'entrar',
    (auth) => auth.signInWithPassword(email: email, password: senha),
  );

  @override
  Future<void> cadastrar(String nome, String email, String senha) =>
      _rodar('cadastrar', (auth) async {
        final r = await auth.signUp(
          email: email,
          password: senha,
          data: {'nome': nome},
        );
        // e-mail com conta volta um usuario falso sem identities
        if (r.user?.identities?.isEmpty ?? false) {
          throw const AuthErro(TipoErroAuth.emailJaUsado);
        }
      });

  @override
  Future<void> confirmarCadastro(String email, String codigo) => _rodar(
    'confirmarCadastro',
    (auth) => auth.verifyOTP(type: OtpType.signup, email: email, token: codigo),
  );

  @override
  Future<void> reenviarConfirmacao(String email) => _rodar(
    'reenviarConfirmacao',
    (auth) => auth.resend(type: OtpType.signup, email: email),
  );

  @override
  Future<void> pedirCodigoSenha(String email) =>
      _rodar('pedirCodigoSenha', (auth) => auth.resetPasswordForEmail(email));

  // o codigo certo ja cria a sessao
  @override
  Future<void> confirmarCodigoSenha(String email, String codigo) => _rodar(
    'confirmarCodigoSenha',
    (auth) =>
        auth.verifyOTP(type: OtpType.recovery, email: email, token: codigo),
  );

  @override
  Future<void> trocarSenha(String novaSenha) => _rodar(
    'trocarSenha',
    (auth) => auth.updateUser(UserAttributes(password: novaSenha)),
  );

  @override
  Future<void> sair() => _rodar('sair', (auth) => auth.signOut());

  // todo erro sai como AuthErro, logado com a stack
  Future<void> _rodar(
    String onde,
    Future<void> Function(GoTrueClient auth) acao,
  ) async {
    final auth = _auth;
    if (auth == null) {
      AppLog.erro(TagLog.auth, '$onde: supabase nao configurado (env.json)');
      throw const AuthErro(TipoErroAuth.semConfiguracao);
    }
    try {
      await acao(auth);
      AppLog.info(TagLog.auth, '$onde ok');
    } catch (e, stack) {
      final erro = AuthErro.de(e);
      AppLog.erro(
        TagLog.auth,
        '$onde: ${erro.tipo.name}',
        erro: e,
        stack: stack,
      );
      throw erro;
    }
  }
}
