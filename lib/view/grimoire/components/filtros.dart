import 'package:flutter/material.dart';
import 'package:grimorio/widgets/etiqueta.dart';

class Filtro {
  const Filtro(this.rotulo, {required this.selecionado, required this.onTap});

  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;
}

// Fileira rolável de Etiquetas selecionáveis.
class Filtros extends StatelessWidget {
  const Filtros({super.key, required this.itens});

  final List<Filtro> itens;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 6,
        children: [
          for (final f in itens)
            Etiqueta(f.rotulo, selecionado: f.selecionado, onTap: f.onTap),
        ],
      ),
    );
  }
}
