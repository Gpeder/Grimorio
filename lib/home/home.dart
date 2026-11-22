import 'package:flutter/material.dart';
import 'package:grimorio/home/components/card_personagem_ativo.dart';
import 'package:grimorio/home/components/home_appbar.dart';
import 'package:grimorio/home/components/menu_actions.dart';
import 'package:grimorio/models/personagens_mock.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    const personagem = personagemAtivoMock;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppbar(avatarPath: personagem.retrato),
          const CardPersonagemAtivo(personagem: personagem),
          const MenuActions(),
        ],
      ),
    );
  }
}
