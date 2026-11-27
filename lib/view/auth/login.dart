import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/auth/validador_auth.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:grimorio/view/auth/components/auth_footer.dart';
import 'package:grimorio/view/auth/components/auth_header.dart';
import 'package:grimorio/view/auth/components/auth_layout.dart';
import 'package:grimorio/view/auth/components/botao_auth.dart';
import 'package:grimorio/view/auth/components/campo_auth.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _email = TextEditingController();
  final _senha = TextEditingController();

  // valida so depois do primeiro toque em Entrar
  bool _tentou = false;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  String? get _erroEmail => _tentou ? ValidadorAuth.email(_email.text) : null;
  String? get _erroSenha =>
      _tentou ? ValidadorAuth.senhaLogin(_senha.text) : null;

  void _digitou(String _) {
    if (_tentou) setState(() {});
  }

  Future<void> _entrar() async {
    final auth = context.read<AuthProvider>();
    if (auth.carregando) return;
    setState(() => _tentou = true);
    if (_erroEmail != null || _erroSenha != null) return;

    try {
      // logou: o router leva para o inicio
      await auth.entrar(_email.text, _senha.text);
      TextInput.finishAutofillContext();
    } on AuthErro catch (e, stack) {
      if (!mounted) return;
      if (e.tipo == TipoErroAuth.emailNaoConfirmado) {
        mostrarAviso(context, 'Confirme seu e-mail. Mandamos um código novo.');
        context.pushNamed(Rotas.nomeConfirmarEmail);
        return;
      }
      mostrarErro(context, e, stack: stack, onde: 'entrar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<AuthProvider>().carregando;

    return AuthLayout(
      header: const AuthHeader(
        titulo: 'Grimório',
        subtitulo: 'Sua mesa, sem papel',
        comLogo: true,
      ),
      rodape: AuthFooter(
        pergunta: 'Ainda não tem conta?',
        acao: 'Criar conta',
        onTap: () => context.pushNamed(Rotas.nomeCadastro),
      ),
      children: [
        AutofillGroup(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoAuth(
                  key: const ValueKey('login-email'),
                  rotulo: 'E-mail',
                  controller: _email,
                  icone: Pixel.mail,
                  dica: 'voce@email.com',
                  erro: _erroEmail,
                  teclado: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  onChanged: _digitou,
                ),
                const SizedBox(height: AppSpacing.medium),
                CampoAuth.senha(
                  key: const ValueKey('login-senha'),
                  rotulo: 'Senha',
                  controller: _senha,
                  dica: 'Sua senha',
                  erro: _erroSenha,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onChanged: _digitou,
                  onSubmitted: (_) => _entrar(),
                ),
                const SizedBox(height: AppSpacing.medium),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.pushNamed(Rotas.nomeRecuperarSenha),
                    child: const Text('Esqueci minha senha'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        BotaoAuth(texto: 'Entrar', carregando: carregando, onPressed: _entrar),
      ],
    );
  }
}
