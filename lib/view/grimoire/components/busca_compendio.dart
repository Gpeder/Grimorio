import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class BuscaCompendio extends StatelessWidget {
  const BuscaCompendio({
    super.key,
    required this.dica,
    required this.onChanged,
    this.inicial,
  });

  final String dica;
  final ValueChanged<String> onChanged;

  // texto ao voltar para a tela
  final String? inicial;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: inicial,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: dica,
        prefixIcon: const Icon(Pixel.search),
      ),
    );
  }
}
