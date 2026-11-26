import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

const _semAcento = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', //
  'é': 'e', 'ê': 'e', //
  'í': 'i', //
  'ó': 'o', 'ô': 'o', 'õ': 'o', //
  'ú': 'u', 'ü': 'u', //
  'ç': 'c',
};

// Minúsculas e sem acento, para "pocao" achar "Poção".
String normalizar(String texto) =>
    texto.toLowerCase().split('').map((c) => _semAcento[c] ?? c).join().trim();

bool contem(String texto, String busca) =>
    normalizar(texto).contains(normalizar(busca));

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
