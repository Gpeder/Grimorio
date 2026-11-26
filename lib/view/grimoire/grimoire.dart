import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/grimoire/filtros_srd.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/item_srd.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/grimoire/components/busca_compendio.dart';
import 'package:grimorio/view/grimoire/components/categoria_card.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/raridade_badge.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:grimorio/view/grimoire/magias/magias.dart';
import 'package:grimorio/widgets/estado_carregando.dart';
import 'package:grimorio/widgets/estado_erro.dart';
import 'package:grimorio/widgets/estado_vazio.dart';
import 'package:provider/provider.dart';

class Grimoire extends StatefulWidget {
  const Grimoire({super.key});

  @override
  State<Grimoire> createState() => _GrimoireState();
}

class _GrimoireState extends State<Grimoire> {
  static const _porGrupo = 5;

  // so busca com 2 letras ou mais
  String? _busca;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _digitou(String texto) {
    _timer?.cancel();
    _timer = Timer(TelaLista.espera, () {
      final t = texto.trim();
      final busca = t.length < TelaLista.minimoBusca ? null : t;
      setState(() => _busca = busca);
      if (busca != null) context.read<CompendioProvider>().buscarTudo(busca);
    });
  }

  void _abrir(String tipo, String key) => context.pushNamed(
    Rotas.nomeDetalheCompendio,
    pathParameters: {Rotas.tipo: tipo, Rotas.key: key},
  );

  void _lista(String tipo) => context.pushNamed(
    Rotas.nomeListaCompendio,
    pathParameters: {Rotas.tipo: tipo},
  );

  // total so quando a lista carregou sem busca nem filtro
  static String _contagem(
    EstadoLista<Object?> e,
    bool semFiltro,
    String nome,
  ) => e.carregamento == Carregamento.pronto && e.busca == null && semFiltro
      ? '${e.total} $nome'
      : 'SRD 5.1';

  List<Widget> _categorias(CompendioProvider c) {
    final cards = [
      CategoriaCard(
        nome: 'Classes',
        contagem: _contagem(c.classes, true, 'classes'),
        imagem: AppImages.menuGrimorio,
        onTap: () => _lista(TipoCompendio.classes),
      ),
      CategoriaCard(
        nome: 'Espécies',
        contagem: _contagem(c.especies, true, 'espécies'),
        imagem: AppImages.especieElfoF,
        onTap: () => _lista(TipoCompendio.especies),
      ),
      CategoriaCard(
        nome: 'Magias',
        contagem: _contagem(
          c.magias,
          c.filtroMagias == const FiltroMagia(),
          'magias',
        ),
        imagem: AppImages.pergMagia,
        onTap: () => _lista(TipoCompendio.magias),
      ),
      CategoriaCard(
        nome: 'Bestiário',
        contagem: _contagem(
          c.monstros,
          c.filtroMonstros == const FiltroMonstro(),
          'criaturas',
        ),
        imagem: AppImages.menuBestiario,
        onTap: () => _lista(TipoCompendio.bestiario),
      ),
      CategoriaCard(
        nome: 'Itens',
        contagem: _contagem(
          c.itensMagicos,
          c.filtroItensMagicos == const FiltroItemMagico(),
          'mágicos',
        ),
        imagem: AppImages.bau,
        onTap: () => _lista(TipoCompendio.itens),
      ),
      CategoriaCard(
        nome: 'Condições',
        contagem: _contagem(c.condicoes, true, 'condições'),
        imagem: AppImages.pocao7,
        onTap: () => _lista(TipoCompendio.condicoes),
      ),
    ];

    return [
      for (var i = 0; i < cards.length; i += 2)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.small),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.small,
              children: [
                Expanded(child: cards[i]),
                Expanded(child: cards[i + 1]),
              ],
            ),
          ),
        ),
    ];
  }

  static String _tipoDoItem(ItemSrd i) => i.arma
      ? TipoCompendio.armas
      : i.armadura
      ? TipoCompendio.armaduras
      : TipoCompendio.itens;

  List<Widget> _resultados(CompendioProvider c, String busca) {
    final estados = [
      c.buscaMagias,
      c.buscaMonstros,
      c.buscaItensMagicos,
      c.buscaItens,
    ];
    if (estados.any((e) => e.carregamento == Carregamento.erro)) {
      final erro = estados.firstWhere(
        (e) => e.carregamento == Carregamento.erro,
      );
      return [
        EstadoErro(
          mensagem: erro.mensagemErro ?? 'Algo deu errado',
          onTentarDeNovo: () =>
              context.read<CompendioProvider>().buscarTudo(busca),
        ),
      ];
    }
    if (estados.any((e) => e.carregamento != Carregamento.pronto)) {
      return [const EstadoCarregando()];
    }

    final grupos = <(String, List<Widget>)>[
      (
        'Magias',
        [
          for (final m in c.buscaMagias.itens.take(_porGrupo))
            CompendioTile(
              imagem: VisualSrd.escola(m.escola),
              titulo: m.nome,
              subtitulo:
                  '${VisualSrd.nivel(m.nivel)} · ${TraducaoSrd.escola(m.escola)}',
              tags: TagsMagia(concentracao: m.concentracao, ritual: m.ritual),
              onTap: () => _abrir(TipoCompendio.magias, m.key),
            ),
        ],
      ),
      (
        'Criaturas',
        [
          for (final m in c.buscaMonstros.itens.take(_porGrupo))
            CompendioTile(
              imagem: VisualSrd.monstro,
              imagemUrl: m.imagem,
              titulo: m.nome,
              subtitulo:
                  '${TraducaoSrd.tipoMonstro(m.tipo)} · ND ${VisualSrd.nd(m.nd)}',
              onTap: () => _abrir(TipoCompendio.bestiario, m.key),
            ),
        ],
      ),
      (
        'Itens mágicos',
        [
          for (final i in c.buscaItensMagicos.itens.take(_porGrupo))
            CompendioTile(
              imagem: VisualSrd.item(i),
              titulo: i.nome,
              subtitulo: TraducaoSrd.categoriaItem(i.categoria),
              corBorda: VisualSrd.raridade(i.raridade)?.cor,
              trailing: switch (VisualSrd.raridade(i.raridade)) {
                final r? => RaridadeBadge(r),
                null => null,
              },
              onTap: () => _abrir(TipoCompendio.itensMagicos, i.key),
            ),
        ],
      ),
      (
        'Itens',
        [
          for (final i in c.buscaItens.itens.take(_porGrupo))
            CompendioTile(
              imagem: VisualSrd.item(i),
              titulo: i.nome,
              subtitulo: TraducaoSrd.categoriaItem(i.categoria),
              onTap: () => _abrir(_tipoDoItem(i), i.key),
            ),
        ],
      ),
    ];

    final comResultado = grupos.where((g) => g.$2.isNotEmpty).toList();
    if (comResultado.isEmpty) {
      return [EstadoVazio(titulo: 'Nada encontrado para "$busca"')];
    }
    return [
      for (final (titulo, linhas) in comResultado) ...[
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.small),
          child: TituloSecao(titulo),
        ),
        ...linhas,
        const SizedBox(height: AppSpacing.medium),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.watch<CompendioProvider>();
    final busca = _busca;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.medium,
            AppSpacing.large,
            AppSpacing.medium,
            96,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Grimório',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.medium),
              BuscaCompendio(
                dica: 'Buscar magias, monstros, itens…',
                onChanged: _digitou,
              ),
              const SizedBox(height: AppSpacing.medium),
              ...busca == null ? _categorias(c) : _resultados(c, busca),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Fonte: SRD 5.1 · Open5e',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
