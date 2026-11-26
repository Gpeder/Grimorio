import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/characters/ficha/components/titulo_secao.dart';

Future<T?> mostrarSheetOpcoes<T>(
  BuildContext context, {
  required String titulo,
  required List<T> opcoes,
  required String Function(T) rotulo,
  required T selecionado,
  String? nota,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    builder: (context) => SheetOpcoes<T>(
      titulo: titulo,
      opcoes: opcoes,
      rotulo: rotulo,
      selecionado: selecionado,
      nota: nota,
    ),
  );
}

class SheetOpcoes<T> extends StatelessWidget {
  const SheetOpcoes({
    super.key,
    required this.titulo,
    required this.opcoes,
    required this.rotulo,
    required this.selecionado,
    this.nota,
  });

  final String titulo;
  final List<T> opcoes;
  final String Function(T) rotulo;
  final T selecionado;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final nota = this.nota;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          0,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TituloSecao(titulo),
            RadioGroup<T>(
              groupValue: selecionado,
              onChanged: (v) => Navigator.of(context).pop(v),
              child: Column(
                children: [
                  for (final o in opcoes)
                    RadioListTile<T>(
                      value: o,
                      contentPadding: EdgeInsets.zero,
                      title: Text(rotulo(o)),
                    ),
                ],
              ),
            ),
            if (nota != null)
              Text(
                nota,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
