import 'package:flutter/material.dart';
import 'package:grimorio/view/characters/new_hero/components/grade_imagens.dart';
import 'package:grimorio/view/grimoire/classes/classe_detalhe.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/model/hero_options_mock.dart';

class Classes extends StatelessWidget {
  const Classes({super.key});

  @override
  Widget build(BuildContext context) {
    return TelaLista(
      titulo: 'Classes',
      contagem: classesMock.length,
      itens: [
        GradeImagens(
          itens: [
            for (final c in classesMock)
              ItemImagem(
                imagem: c.imagem,
                rotulo: c.nome,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ClasseDetalhe(classe: c),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
