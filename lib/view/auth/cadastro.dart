import 'package:flutter/material.dart';
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

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();
  bool _tentou = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  String? get _erroNome => _tentou ? ValidadorAuth.nome(_nome.text) : null;
  String? get _erroEmail => _tentou ? ValidadorAuth.email(_email.text) : null;
  String? get _erroSenha => _tentou ? ValidadorAuth.senha(_senha.text) : null;
  String? get _erroConfirmar =>
      _tentou ? ValidadorAuth.confirmar(_senha.text, _confirmar.text) : null;

  void _digitou(String _) {
    if (_tentou) setState(() {});
  }

  void _voltar() => context.canPop() ? context.pop() : context.go(Rotas.entrar);

  Future<void> _criar() async {
    final auth = context.read<AuthProvider>();
    if (auth.carregando) return;
    setState(() => _tentou = true);
    final erros = [_erroNome, _erroEmail, _erroSenha, _erroConfirmar];
    if (erros.any((e) => e != null)) return;

    try {
      await auth.cadastrar(_nome.text, _email.text, _senha.text);
      if (mounted) context.pushNamed(Rotas.nomeConfirmarEmail);
    } on AuthErro catch (e, stack) {
      if (mounted) mostrarErro(context, e, stack: stack, onde: 'cadastrar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<AuthProvider>().carregando;

    return AuthLayout(
      header: AuthHeader(
        titulo: 'Criar conta',
        subtitulo: 'Seu grimório começa aqui',
        onVoltar: _voltar,
      ),
      rodape: AuthFooter(
        pergunta: 'Já tem conta?',
        acao: 'Entrar',
        onTap: () => context.go(Rotas.entrar),
      ),
      children: [
        AutofillGroup(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampoAuth(
                  key: const ValueKey('cadastro-nome'),
                  rotulo: 'Nome',
                  controller: _nome,
                  icone: Pixel.user,
                  dica: 'Como a mesa te chama',
                  erro: _erroNome,
                  teclado: TextInputType.name,
                  autofillHints: const [AutofillHints.name],
                  onChanged: _digitou,
                ),
                const SizedBox(height: AppSpacing.medium),
                CampoAuth(
                  key: const ValueKey('cadastro-email'),
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
                  key: const ValueKey('cadastro-senha'),
                  rotulo: 'Senha',
                  controller: _senha,
                  ajuda: 'Mínimo 8 caracteres, com letra e número',
                  erro: _erroSenha,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: _digitou,
                ),
                const SizedBox(height: AppSpacing.medium),
                CampoAuth.senha(
                  key: const ValueKey('cadastro-confirmar'),
                  rotulo: 'Confirmar senha',
                  controller: _confirmar,
                  erro: _erroConfirmar,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onChanged: _digitou,
                  onSubmitted: (_) => _criar(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        BotaoAuth(
          texto: 'Criar conta',
          carregando: carregando,
          onPressed: _criar,
        ),
      ],
    );
  }
}
