import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/auth/auth_provider.dart';
import 'package:grimorio/controller/auth/validador_auth.dart';
import 'package:grimorio/service/supabase/auth_erro.dart';
import 'package:grimorio/view/auth/components/auth_footer.dart';
import 'package:grimorio/view/auth/components/auth_header.dart';
import 'package:grimorio/view/auth/components/auth_layout.dart';
import 'package:grimorio/view/auth/components/botao_auth.dart';
import 'package:grimorio/view/auth/components/campo_auth.dart';
import 'package:grimorio/view/auth/components/campo_codigo.dart';
import 'package:grimorio/view/auth/components/reenviar_button.dart';
import 'package:grimorio/view/auth/components/texto_email.dart';
import 'package:grimorio/widgets/appcard.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

enum _Passo { email, codigo, senha }

// 3 passos na mesma tela: e-mail, codigo e senha nova
class RecuperarSenha extends StatefulWidget {
  const RecuperarSenha({super.key});

  @override
  State<RecuperarSenha> createState() => _RecuperarSenhaState();
}

class _RecuperarSenhaState extends State<RecuperarSenha> {
  final _email = TextEditingController();
  final _codigo = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();

  _Passo _passo = _Passo.email;

  // cada passo valida so depois do primeiro toque no botao
  bool _tentou = false;

  @override
  void dispose() {
    _email.dispose();
    _codigo.dispose();
    _senha.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  String? get _erroEmail => _tentou ? ValidadorAuth.email(_email.text) : null;
  String? get _erroCodigo =>
      _tentou ? ValidadorAuth.codigo(_codigo.text) : null;
  String? get _erroSenha => _tentou ? ValidadorAuth.senha(_senha.text) : null;
  String? get _erroConfirmar =>
      _tentou ? ValidadorAuth.confirmar(_senha.text, _confirmar.text) : null;

  void _digitou(String _) {
    if (_tentou) setState(() {});
  }

  void _irPara(_Passo passo) => setState(() {
    _passo = passo;
    _tentou = false;
  });

  // voltar anda um passo; depois do codigo a sessao aberta e fechada
  Future<void> _voltar() async {
    switch (_passo) {
      case _Passo.email:
        context.canPop() ? context.pop() : context.go(Rotas.entrar);
      case _Passo.codigo:
        _codigo.clear();
        _irPara(_Passo.email);
      case _Passo.senha:
        _codigo.clear();
        _irPara(_Passo.email);
        try {
          await context.read<AuthProvider>().cancelarRecuperacao();
        } on AuthErro catch (e, stack) {
          if (mounted) mostrarErro(context, e, stack: stack, onde: 'cancelar');
        }
    }
  }

  // passo 1: nao conta se o e-mail tem conta
  Future<void> _enviar() async {
    final auth = context.read<AuthProvider>();
    if (auth.carregando) return;
    setState(() => _tentou = true);
    if (_erroEmail != null) return;

    if (await _pedirCodigo() && mounted) _irPara(_Passo.codigo);
  }

  Future<bool> _pedirCodigo() async {
    try {
      await context.read<AuthProvider>().pedirCodigoSenha(_email.text);
      if (mounted) {
        mostrarAviso(
          context,
          'Se o e-mail tiver conta, o código chega em instantes.',
        );
      }
      return true;
    } on AuthErro catch (e, stack) {
      if (mounted) mostrarErro(context, e, stack: stack, onde: 'pedir codigo');
      return false;
    }
  }

  // passo 2: o codigo certo abre a sessao
  Future<void> _validar() async {
    final auth = context.read<AuthProvider>();
    if (auth.carregando) return;
    setState(() => _tentou = true);
    if (_erroCodigo != null) return;

    try {
      await auth.confirmarCodigoSenha(_email.text, _codigo.text);
      if (mounted) _irPara(_Passo.senha);
    } on AuthErro catch (e, stack) {
      if (!mounted) return;
      _codigo.clear();
      setState(() => _tentou = false);
      mostrarErro(context, e, stack: stack, onde: 'validar codigo');
    }
  }

  // passo 3: salvou, o router leva para o inicio
  Future<void> _salvar() async {
    final auth = context.read<AuthProvider>();
    if (auth.carregando) return;
    setState(() => _tentou = true);
    if (_erroSenha != null || _erroConfirmar != null) return;

    try {
      await auth.trocarSenha(_senha.text);
      if (mounted) {
        mostrarAviso(context, 'Senha trocada', tipo: Snackbar.sucesso);
      }
    } on AuthErro catch (e, stack) {
      if (mounted) mostrarErro(context, e, stack: stack, onde: 'trocar senha');
    }
  }

  @override
  Widget build(BuildContext context) {
    final carregando = context.watch<AuthProvider>().carregando;

    final (titulo, conteudo) = switch (_passo) {
      _Passo.email => ('Recuperar senha', _passoEmail(carregando)),
      _Passo.codigo => ('Digite o código', _passoCodigo(carregando)),
      _Passo.senha => ('Nova senha', _passoSenha(carregando)),
    };

    return PopScope(
      canPop: _passo == _Passo.email,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _voltar();
      },
      child: AuthLayout(
        header: AuthHeader(
          titulo: titulo,
          subtitulo: 'Passo ${_passo.index + 1} de ${_Passo.values.length}',
          onVoltar: _voltar,
        ),
        rodape: _passo == _Passo.email
            ? AuthFooter(
                pergunta: 'Lembrou a senha?',
                acao: 'Entrar',
                onTap: () => context.go(Rotas.entrar),
              )
            : null,
        children: conteudo,
      ),
    );
  }

  List<Widget> _passoEmail(bool carregando) {
    final textTheme = Theme.of(context).textTheme;
    return [
      Text(
        'Digite o e-mail da sua conta. Vamos mandar um código de 6 números.',
        style: textTheme.bodyLarge?.copyWith(color: AppColors.onSurface),
      ),
      const SizedBox(height: AppSpacing.large),
      AppCard(
        child: CampoAuth(
          key: const ValueKey('recuperar-email'),
          rotulo: 'E-mail',
          controller: _email,
          icone: Pixel.mail,
          dica: 'voce@email.com',
          erro: _erroEmail,
          teclado: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onChanged: _digitou,
          onSubmitted: (_) => _enviar(),
        ),
      ),
      const SizedBox(height: AppSpacing.large),
      BotaoAuth(
        texto: 'Enviar código',
        carregando: carregando,
        onPressed: _enviar,
      ),
    ];
  }

  List<Widget> _passoCodigo(bool carregando) => [
    TextoEmail(
      antes: 'Código enviado para ',
      email: ValidadorAuth.limparEmail(_email.text),
    ),
    const SizedBox(height: AppSpacing.large),
    AppCard(
      child: CampoCodigo(
        controller: _codigo,
        ajuda: 'Confere sozinho ao digitar o último número',
        erro: _erroCodigo,
        onChanged: _digitou,
        onCompleto: (_) => _validar(),
      ),
    ),
    const SizedBox(height: AppSpacing.large),
    BotaoAuth(
      texto: 'Validar código',
      carregando: carregando,
      onPressed: _validar,
    ),
    const SizedBox(height: AppSpacing.large),
    ReenviarButton(onReenviar: _pedirCodigo),
    const SizedBox(height: AppSpacing.medium),
    Center(
      child: TextButton(onPressed: _voltar, child: const Text('Trocar e-mail')),
    ),
  ];

  List<Widget> _passoSenha(bool carregando) => [
    const _CodigoConfirmado(),
    const SizedBox(height: AppSpacing.large),
    AutofillGroup(
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CampoAuth.senha(
              key: const ValueKey('recuperar-senha'),
              rotulo: 'Nova senha',
              controller: _senha,
              ajuda: 'Mínimo 8 caracteres, com letra e número',
              erro: _erroSenha,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: _digitou,
            ),
            const SizedBox(height: AppSpacing.medium),
            CampoAuth.senha(
              key: const ValueKey('recuperar-confirmar'),
              rotulo: 'Confirmar nova senha',
              controller: _confirmar,
              erro: _erroConfirmar,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onChanged: _digitou,
              onSubmitted: (_) => _salvar(),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: AppSpacing.large),
    BotaoAuth(
      texto: 'Salvar senha',
      carregando: carregando,
      onPressed: _salvar,
    ),
  ];
}

class _CodigoConfirmado extends StatelessWidget {
  const _CodigoConfirmado();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.sucesso),
      ),
      child: Row(
        children: [
          const Icon(Pixel.check, color: AppColors.sucesso, size: 20),
          const SizedBox(width: AppSpacing.small + 4),
          Expanded(
            child: Text(
              'Código confirmado. Agora escolha a senha nova.',
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: AppColors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
