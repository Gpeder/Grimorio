import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_erro.dart';
import 'package:grimorio/widgets/estado_vazio.dart';

// escolhe o estado e cuida do carregar mais
class ListaPaginada<T> extends StatelessWidget {
  const ListaPaginada({
    super.key,
    required this.estado,
    required this.itemBuilder,
    required this.onTentarDeNovo,
    required this.onCarregarMais,
    this.vazioTitulo = 'Nada por aqui',
    this.vazioMensagem,
    this.controller,
    this.onAtualizar,
    this.secaoDe,
    this.secaoBuilder,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.medium,
      0,
      AppSpacing.medium,
      96,
    ),
  });

  final EstadoLista<T> estado;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onTentarDeNovo;
  final VoidCallback onCarregarMais;
  final String vazioTitulo;
  final String? vazioMensagem;
  final ScrollController? controller;

  // puxar para atualizar
  final Future<void> Function()? onAtualizar;

  // titulo antes do primeiro item de cada secao
  final String Function(T item)? secaoDe;
  final Widget Function(BuildContext context, String secao)? secaoBuilder;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final e = estado;
    switch (e.carregamento) {
      case Carregamento.inicial || Carregamento.carregando:
        return const EstadoCarregando();
      case Carregamento.erro:
        return EstadoErro(
          mensagem: e.mensagemErro ?? 'Algo deu errado',
          onTentarDeNovo: onTentarDeNovo,
        );
      case Carregamento.pronto when e.itens.isEmpty:
        return EstadoVazio(titulo: vazioTitulo, mensagem: vazioMensagem);
      case Carregamento.pronto:
        break;
    }

    final rodape = _rodape(e);
    final lista = ListView.builder(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: e.itens.length + (rodape == null ? 0 : 1),
      itemBuilder: (context, i) =>
          i < e.itens.length ? _item(context, e.itens, i) : rodape!,
    );
    final onAtualizar = this.onAtualizar;
    if (onAtualizar == null) return lista;
    return RefreshIndicator(onRefresh: onAtualizar, child: lista);
  }

  Widget _item(BuildContext context, List<T> itens, int i) {
    final item = itemBuilder(context, itens[i]);
    final secaoDe = this.secaoDe;
    final secaoBuilder = this.secaoBuilder;
    if (secaoDe == null || secaoBuilder == null) return item;
    final secao = secaoDe(itens[i]);
    if (i > 0 && secaoDe(itens[i - 1]) == secao) return item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [secaoBuilder(context, secao), item],
    );
  }

  // erro no fim mantem os itens na tela
  Widget? _rodape(EstadoLista<T> e) {
    if (e.carregandoMais) return const EstadoCarregando(compacto: true);
    if (e.erroAoCarregarMais case final msg?) {
      return EstadoErro(
        mensagem: msg,
        onTentarDeNovo: onCarregarMais,
        compacto: true,
      );
    }
    if (e.temMais) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Center(
          child: OutlinedButton(
            onPressed: onCarregarMais,
            child: const Text('Carregar mais'),
          ),
        ),
      );
    }
    return null;
  }
}
