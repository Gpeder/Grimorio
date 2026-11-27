import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:pixelarticons/pixel.dart';

// campo com rotulo em cima e icone a esquerda; senha tem o olho
class CampoAuth extends StatefulWidget {
  const CampoAuth({
    super.key,
    required this.rotulo,
    required this.controller,
    required this.icone,
    this.dica,
    this.erro,
    this.ajuda,
    this.senha = false,
    this.teclado,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  });

  // versao senha, com olho para mostrar
  const CampoAuth.senha({
    super.key,
    required this.rotulo,
    required this.controller,
    this.dica,
    this.erro,
    this.ajuda,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
  }) : icone = Pixel.lock,
       senha = true,
       teclado = TextInputType.visiblePassword;

  final String rotulo;
  final TextEditingController controller;
  final IconData icone;

  // texto apagado dentro do campo
  final String? dica;
  final String? erro;

  // texto fixo embaixo, some quando tem erro
  final String? ajuda;
  final bool senha;
  final TextInputType? teclado;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<CampoAuth> createState() => _CampoAuthState();
}

class _CampoAuthState extends State<CampoAuth> {
  bool _escondido = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.rotulo,
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.teclado,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          obscureText: widget.senha && _escondido,
          autocorrect: !widget.senha,
          enableSuggestions: !widget.senha,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.dica,
            errorText: widget.erro,
            helperText: widget.ajuda,
            helperMaxLines: 2,
            errorMaxLines: 2,
            prefixIcon: Icon(widget.icone, color: AppColors.secondary),
            suffixIcon: widget.senha
                ? Tooltip(
                    message: _escondido ? 'Mostrar senha' : 'Esconder senha',
                    child: InkResponse(
                      radius: 22,
                      onTap: () => setState(() => _escondido = !_escondido),
                      child: Icon(
                        _escondido ? Pixel.eye : Pixel.eyeoff,
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
