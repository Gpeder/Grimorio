import 'package:flutter/material.dart';
import 'package:grimorio/view/characters/new_hero/components/grade_imagens.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/especies/especie_detalhe.dart';
import 'package:grimorio/model/hero_options_mock.dart';

class Especies extends StatelessWidget {
  const Especies({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaLista(
      titulo: 'Espécies',
      contagem: especiesMock.length,
      itens: [
        GradeImagens(
          itens: [
            for (final e in especiesMock)
              ItemImagem(
                imagem: e.retratoF,
                rotulo: e.nome,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EspecieDetalhe(especie: e),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
