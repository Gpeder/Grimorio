import 'package:flutter/material.dart';
import 'package:grimorio/home/components/card_personagem_ativo.dart';
import 'package:grimorio/home/components/home_appbar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          HomeAppbar(),
          CardPersonagemAtivo(),
          SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }
}
