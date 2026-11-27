import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

// 6 caixas de um numero; um campo escondido por cima recebe o teclado,
// assim colar o codigo inteiro e apagar para tras funcionam sozinhos
class CampoCodigo extends StatefulWidget {
  const CampoCodigo({
    super.key,
    required this.controller,
    required this.onCompleto,
    this.ajuda,
    this.erro,
    this.onChanged,
  });

  static const tamanho = 6;

  final TextEditingController controller;
  final ValueChanged<String> onCompleto;
  final String? ajuda;
  final String? erro;
  final ValueChanged<String>? onChanged;

  @override
  State<CampoCodigo> createState() => _CampoCodigoState();
}

class _CampoCodigoState extends State<CampoCodigo> {
  final _foco = FocusNode();

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  void _mudou(String valor) {
    widget.onChanged?.call(valor);
    if (valor.length == CampoCodigo.tamanho) {
      _foco.unfocus();
      widget.onCompleto(valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final erro = widget.erro;
    final ajuda = erro ?? widget.ajuda;

    return Column(
      children: [
        Text(
          'Código',
          style: textTheme.labelLarge?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.small + 4),
        SizedBox(
          height: 58,
          child: Stack(
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([widget.controller, _foco]),
                builder: (context, _) => Row(
                  children: [
                    for (var i = 0; i < CampoCodigo.tamanho; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.small),
                      Expanded(child: _caixa(context, i)),
                    ],
                  ],
                ),
              ),
              // campo de verdade, invisivel, por cima das caixas
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _foco,
                    expands: true,
                    maxLines: null,
                    showCursor: false,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(CampoCodigo.tamanho),
                    ],
                    onChanged: _mudou,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (ajuda != null) ...[
          const SizedBox(height: AppSpacing.small),
          Text(
            ajuda,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: erro != null
                  ? AppColors.vida
                  : AppColors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _caixa(BuildContext context, int i) {
    final texto = widget.controller.text;
    final digito = i < texto.length ? texto[i] : '';
    final atual =
        _foco.hasFocus &&
        i == texto.length.clamp(0, CampoCodigo.tamanho - 1).toInt();
    final cor = widget.erro != null
        ? AppColors.vida
        : atual
        ? AppColors.primary
        : Theme.of(context).colorScheme.outline;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: cor, width: atual ? 2 : 1),
      ),
      child: Text(
        digito,
        key: ValueKey('codigo-$i'),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.onSurface,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
