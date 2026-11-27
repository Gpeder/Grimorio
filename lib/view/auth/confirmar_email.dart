import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/auth/validador_auth.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:grimorio/view/auth/components/auth_header.dart';
import 'package:grimorio/view/auth/components/auth_layout.dart';
import 'package:grimorio/view/auth/components/botao_auth.dart';
import 'package:grimorio/view/auth/components/campo_codigo.dart';
import 'package:grimorio/view/auth/components/reenviar_button.dart';
import 'package:grimorio/view/auth/components/texto_email.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:provider/provider.dart';

class ConfirmarEmail extends StatefulWidget {
  const ConfirmarEmail({super.key});

  @override
  State<ConfirmarEmail> createState() => _ConfirmarEmailState();
}

class _ConfirmarEmailState extends State<ConfirmarEmail> {
  final _codigo = TextEditingController();
  bool _tentou = false;

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  String? get _erroCodigo =>
      _tentou ? ValidadorAuth.codigo(_codigo.text) : null;

  void _voltar() =>
      context.canPop() ? context.pop() : context.go(Rotas.cadastro);

  Future<void> _confirmar() async {
    final auth = context.read<AuthProvider>();
    if (auth.carregando) return;
    setState(() => _tentou = true);
    if (_erroCodigo != null) return;

    try {
      // confirmou: ja esta logado e o router leva para o inicio
      await auth.confirmarCadastro(_codigo.text);
      if (mounted) {
        mostrarAviso(
          context,
          'Conta criada. Bem-vindo!',
          tipo: Snackbar.sucesso,
        );
      }
    } on AuthErro catch (e, stack) {
      if (!mounted) return;
      _codigo.clear();
      setState(() => _tentou = false);
      mostrarErro(context, e, stack: stack, onde: 'confirmar e-mail');
    }
  }

  Future<bool> _reenviar() async {
    try {
      await context.read<AuthProvider>().reenviarConfirmacao();
      if (mounted) mostrarAviso(context, 'Mandamos um código novo.');
      return true;
    } on AuthErro catch (e, stack) {
      if (mounted) mostrarErro(context, e, stack: stack, onde: 'reenviar');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AuthLayout(
      header: AuthHeader(
        titulo: 'Confirme seu e-mail',
        subtitulo: 'Falta só um passo',
        onVoltar: _voltar,
      ),
      children: [
        TextoEmail(
          antes: 'Mandamos um código de 6 números para ',
          email: auth.emailPendente ?? '',
        ),
        const SizedBox(height: AppSpacing.large),
        AppCard(
          child: CampoCodigo(
            controller: _codigo,
            ajuda: 'O código vence em 1 hora',
            erro: _erroCodigo,
            onChanged: (_) {
              if (_tentou) setState(() {});
            },
            onCompleto: (_) => _confirmar(),
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        BotaoAuth(
          texto: 'Confirmar',
          carregando: auth.carregando,
          onPressed: _confirmar,
        ),
        const SizedBox(height: AppSpacing.large),
        ReenviarButton(onReenviar: _reenviar),
        const SizedBox(height: AppSpacing.medium),
        Center(
          child: TextButton(
            onPressed: () => context.go(Rotas.cadastro),
            child: const Text('Trocar e-mail'),
          ),
        ),
      ],
    );
  }
}
