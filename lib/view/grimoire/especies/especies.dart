import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/view/characters/new_hero/components/grade_imagens.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';

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
                onTap: () => context.pushNamed(
                  Rotas.nomeDetalheCompendio,
                  pathParameters: {
                    Rotas.tipo: TipoCompendio.especies,
                    Rotas.key: e.key,
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
