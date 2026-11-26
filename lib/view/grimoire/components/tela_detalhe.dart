import 'package:flutter/material.dart';
import 'package:grimorio/controller/grimoire/estado_detalhe.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_erro.dart';
import 'package:grimorio/widgets/estado_nao_encontrado.dart';

// escolhe o estado do detalhe; o conteudo so monta com o item
class TelaDetalhe<T> extends StatelessWidget {
  const TelaDetalhe({
    super.key,
    required this.estado,
    required this.onTentarDeNovo,
    required this.builder,
  });

  final EstadoDetalhe<T> estado;
  final VoidCallback onTentarDeNovo;
  final Widget Function(BuildContext context, T item) builder;

  @override
  Widget build(BuildContext context) {
    final e = estado;
    final item = e.item;
    if (e.naoEncontrado) return const EstadoNaoEncontrado();
    if (e.carregamento == Carregamento.pronto) {
      return item == null
          ? const EstadoNaoEncontrado()
          : builder(context, item);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VoltarHeader(),
            Expanded(
              child: e.carregamento == Carregamento.erro
                  ? EstadoErro(
                      mensagem: e.mensagemErro ?? 'Algo deu errado',
                      onTentarDeNovo: onTentarDeNovo,
                    )
                  : const EstadoCarregando(),
            ),
          ],
        ),
      ),
    );
  }
}
