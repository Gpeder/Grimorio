import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';

 Abre o [DialogoNumero] e devolve o número digitado (ou null se cancelar).
Future<int?> pedirNumero(
  BuildContext context, {
  required String titulo,
  String? dica,
  int? inicial,
}) => showDialog<int>(
  context: context,
  builder: (_) => DialogoNumero(titulo: titulo, dica: dica, inicial: inicial),
);

class DialogoNumero extends StatefulWidget {
  const DialogoNumero({
    super.key,
    required this.titulo,
    this.dica,
    this.inicial,
  });

  final String titulo;
  final String? dica;
  final int? inicial;

  @override
  State<DialogoNumero> createState() => _DialogoNumeroState();
}

class _DialogoNumeroState extends State<DialogoNumero> {
  late final _controle = TextEditingController(
    text: widget.inicial?.toString() ?? '',
  );

  int? get _valor => int.tryParse(_controle.text);

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  void _confirmar() {
    final valor = _valor;
    if (valor != null) Navigator.pop(context, valor);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dica = widget.dica;

    return AlertDialog(
      title: Text(widget.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dica != null) ...[
            Text(
              dica,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
          ],
          TextField(
            controller: _controle,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(hintText: '0'),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _confirmar(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppSpacing.small),
        TextButton(
          onPressed: _valor == null ? null : _confirmar,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

 Dialog de sim/não. Devolve true se confirmar.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  String? texto,
  String sim = 'Confirmar',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: texto == null ? null : Text(texto),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: AppSpacing.small),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(sim),
        ),
      ],
    ),
  );
  return ok ?? false;
}
