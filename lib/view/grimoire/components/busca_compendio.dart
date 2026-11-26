import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class BuscaCompendio extends StatelessWidget {
  const BuscaCompendio({
    super.key,
    required this.dica,
    required this.onChanged,
  });

  final String dica;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: dica,
        prefixIcon: const Icon(Pixel.search),
      ),
    );
  }
}
