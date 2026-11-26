import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/grimoire/components/busca_compendio.dart';
import 'package:grimorio/widgets/lista_paginada.dart';
import 'package:pixelarticons/pixel.dart';

// base das listas do grimorio, recebe tudo por parametro
class TelaLista<T> extends StatefulWidget {
  const TelaLista({
    super.key,
    required this.titulo,
    required this.estado,
    required this.itemBuilder,
    required this.onCarregarMais,
    required this.onTentarDeNovo,
    required this.onAtualizar,
    required this.vazioTitulo,
    this.dicaBusca,
    this.buscaInicial,
    this.onBusca,
    this.filtros = const [],
    this.secaoDe,
  });

  final String titulo;
  final EstadoLista<T> estado;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onCarregarMais;
  final VoidCallback onTentarDeNovo;
  final Future<void> Function() onAtualizar;
  final String vazioTitulo;
  final String? dicaBusca;
  final String? buscaInicial;

  // ja com a espera; null volta para a lista sem busca
  final ValueChanged<String?>? onBusca;
  final List<Widget> filtros;
  final String Function(T item)? secaoDe;

  static const espera = Duration(milliseconds: 400);
  static const minimoBusca = 2;

  // falta isso de scroll para pedir a proxima pagina
  static const faltaParaFim = 300.0;

  @override
  State<TelaLista<T>> createState() => _TelaListaState<T>();
}

class _TelaListaState<T> extends State<TelaLista<T>> {
  final _scroll = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_aoRolar);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _aoRolar() {
    final e = widget.estado;
    if (!_scroll.hasClients) return;
    final perto = _scroll.position.extentAfter < TelaLista.faltaParaFim;
    final livre =
        e.temMais && !e.carregandoMais && e.erroAoCarregarMais == null;
    if (perto && livre) widget.onCarregarMais();
  }

  // espera parar de digitar
  void _digitou(String texto) {
    _timer?.cancel();
    _timer = Timer(TelaLista.espera, () {
      final t = texto.trim();
      widget.onBusca?.call(t.length < TelaLista.minimoBusca ? null : t);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final e = widget.estado;
    final dicaBusca = widget.dicaBusca;
    final busca = e.busca;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoltarHeader(
              titulo: widget.titulo,
              direita: Text(
                e.carregamento == Carregamento.pronto ? '${e.total}' : '',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // busca e filtros ficam em todos os estados
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.medium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.small,
                children: [
                  if (dicaBusca != null && widget.onBusca != null)
                    BuscaCompendio(
                      dica: dicaBusca,
                      inicial: widget.buscaInicial,
                      onChanged: _digitou,
                    ),
                  ...widget.filtros,
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.small),
            Expanded(
              child: ListaPaginada<T>(
                estado: e,
                controller: _scroll,
                itemBuilder: widget.itemBuilder,
                onCarregarMais: widget.onCarregarMais,
                onTentarDeNovo: widget.onTentarDeNovo,
                onAtualizar: widget.onAtualizar,
                vazioTitulo: busca == null
                    ? widget.vazioTitulo
                    : 'Nada encontrado para "$busca"',
                secaoDe: widget.secaoDe,
                secaoBuilder: (_, secao) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.small),
                  child: TituloSecao(secao),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  0,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// topo das telas internas
class VoltarHeader extends StatelessWidget {
  const VoltarHeader({super.key, this.titulo, this.direita});

  final String? titulo;
  final Widget? direita;

  @override
  Widget build(BuildContext context) {
    final titulo = this.titulo;
    final direita = this.direita;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.small,
        AppSpacing.small,
        AppSpacing.medium,
        AppSpacing.small,
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.small),
              child: Icon(
                Pixel.chevronleft,
                color: AppColors.onSurface,
                semanticLabel: 'Voltar',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: titulo == null
                ? const SizedBox.shrink()
                : Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          ?direita,
        ],
      ),
    );
  }
}

// botao fixo no rodapé
class RodapeButton extends StatelessWidget {
  const RodapeButton({super.key, required this.texto, required this.onPressed});

  final String texto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.25)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: ElevatedButton(onPressed: onPressed, child: Text(texto)),
        ),
      ),
    );
  }
}
