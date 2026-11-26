import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/texto_limpo.dart';

// descricao da api em paragrafos, sem o markdown
class TextoSrd extends StatelessWidget {
  const TextoSrd(this.texto, {super.key, this.estilo});

  final String texto;
  final TextStyle? estilo;

  @override
  Widget build(BuildContext context) {
    final estilo =
        this.estilo ??
        Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: AppColors.onSurface, height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.small,
      children: [for (final p in paragrafos(texto)) Text(p, style: estilo)],
    );
  }
}
