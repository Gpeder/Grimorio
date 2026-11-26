import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/gerenciador_compendio.dart';
import 'package:grimorio/model/compendio_mock.dart';
import 'package:grimorio/model/opcoes_heroi_mock.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/grimoire/components/busca_compendio.dart';
import 'package:grimorio/view/grimoire/components/categoria_card.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/raridade_badge.dart';
import 'package:grimorio/view/grimoire/itens/detalhes_item.dart';
import 'package:grimorio/view/grimoire/magias/detalhes_magia.dart';
import 'package:grimorio/view/grimoire/magias/magias.dart';

class Grimoire extends StatefulWidget {
  const Grimoire({super.key});

  @override
  State<Grimoire> createState() => _GrimoireState();
}

class _GrimoireState extends State<Grimoire> {
  static const _compendio = GerenciadorCompendio();

  String _busca = '';

  static const _porGrupo = 5;

  List<Widget> _categorias() {
    final cards = [
      CategoriaCard(
        nome: 'Classes',
        contagem: '${classesMock.length} classes',
        imagem: AppImages.menuGrimorio,
        onTap: () => context.pushNamed(
          Rotas.nomeListaCompendio,
          pathParameters: {Rotas.tipo: TipoCompendio.classes},
        ),
      ),
      CategoriaCard(
        nome: 'Espécies',
        contagem: '${especiesMock.length} espécies',
        imagem: AppImages.especieElfoF,
        onTap: () => context.pushNamed(
          Rotas.nomeListaCompendio,
          pathParameters: {Rotas.tipo: TipoCompendio.especies},
        ),
      ),
      CategoriaCard(
        nome: 'Magias',
        contagem: '${magiasCompendio.length} magias',
        imagem: AppImages.pergMagia,
        onTap: () => context.pushNamed(
          Rotas.nomeListaCompendio,
          pathParameters: {Rotas.tipo: TipoCompendio.magias},
        ),
      ),
      CategoriaCard(
        nome: 'Bestiário',
        contagem: '${monstrosMock.length} criaturas',
        imagem: AppImages.menuBestiario,
        onTap: () => context.pushNamed(
          Rotas.nomeListaCompendio,
          pathParameters: {Rotas.tipo: TipoCompendio.bestiario},
        ),
      ),
      CategoriaCard(
        nome: 'Itens',
        contagem: '${itensMock.length} itens',
        imagem: AppImages.bau,
        onTap: () => context.pushNamed(
          Rotas.nomeListaCompendio,
          pathParameters: {Rotas.tipo: TipoCompendio.itens},
        ),
      ),
      CategoriaCard(
        nome: 'Condições',
        contagem: '${condicoesMock.length} condições',
        imagem: AppImages.pocao7,
        onTap: () => context.pushNamed(
          Rotas.nomeListaCompendio,
          pathParameters: {Rotas.tipo: TipoCompendio.condicoes},
        ),
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

  List<Widget> _resultados() {
    final b = _busca;
    final grupos = <(String, List<Widget>)>[
      (
        'Magias',
        [
          for (final m in magiasCompendio.where(
            (m) => _compendio.contem(m.nome, b),
          ))
            CompendioTile(
              imagem: imagemDaEscola(m.escola),
              titulo: m.nome,
              subtitulo: '${nomeDoCirculo(m.circulo)} · ${m.escola}',
              tags: TagsMagia(magia: m),
              onTap: () => context.pushNamed(
                Rotas.nomeDetalheCompendio,
                pathParameters: {
                  Rotas.tipo: TipoCompendio.magias,
                  Rotas.key: m.key,
                },
              ),
            ),
        ],
      ),
      (
        'Criaturas',
        [
          for (final m in monstrosMock.where(
            (m) => _compendio.contem(m.nome, b),
          ))
            CompendioTile(
              imagem: m.imagem,
              titulo: m.nome,
              subtitulo: '${m.tipo} ${m.tamanho} · ND ${m.nd}',
              onTap: () => context.pushNamed(
                Rotas.nomeDetalheCompendio,
                pathParameters: {
                  Rotas.tipo: TipoCompendio.bestiario,
                  Rotas.key: m.key,
                },
              ),
            ),
        ],
      ),
      (
        'Itens',
        [
          for (final i in itensMock.where((i) => _compendio.contem(i.nome, b)))
            CompendioTile(
              imagem: i.imagem,
              titulo: i.nome,
              subtitulo: i.categoria,
              corBorda: i.raridade.cor,
              trailing: RaridadeBadge(i.raridade),
              onTap: () => mostrarItem(context, i),
            ),
        ],
      ),
      (
        'Classes',
        [
          for (final c in classesMock.where(
            (c) => _compendio.contem(c.nome, b),
          ))
            CompendioTile(
              imagem: c.imagem,
              titulo: c.nome,
              subtitulo: papelDaClasse[c.key] ?? '',
              onTap: () => context.pushNamed(
                Rotas.nomeDetalheCompendio,
                pathParameters: {
                  Rotas.tipo: TipoCompendio.classes,
                  Rotas.key: c.key,
                },
              ),
            ),
        ],
      ),
    ];

    final comResultado = grupos.where((g) => g.$2.isNotEmpty).toList();
    if (comResultado.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.large),
          child: Text(
            'Nada encontrado.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: AppColors.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      ];
    }
    return [
      for (final (titulo, linhas) in comResultado) ...[
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.small),
          child: TituloSecao(titulo),
        ),
        ...linhas.take(_porGrupo),
        const SizedBox(height: AppSpacing.medium),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final buscando = _compendio.normalizar(_busca).length >= 2;

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
                onChanged: (v) => setState(() => _busca = v),
              ),
              const SizedBox(height: AppSpacing.medium),
              ...buscando ? _resultados() : _categorias(),
              const SizedBox(height: AppSpacing.medium),
              Text(
                'Fonte: SRD 5.1 · salvo no aparelho',
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
