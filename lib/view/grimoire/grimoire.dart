import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_images.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/grimoire/bestiario/bestiario.dart';
import 'package:grimorio/view/grimoire/bestiario/monstro_detalhe.dart';
import 'package:grimorio/view/grimoire/classes/classe_detalhe.dart';
import 'package:grimorio/view/grimoire/classes/classes.dart';
import 'package:grimorio/view/grimoire/components/busca_compendio.dart';
import 'package:grimorio/view/grimoire/components/card_categoria.dart';
import 'package:grimorio/view/grimoire/components/linha_compendio.dart';
import 'package:grimorio/view/grimoire/components/selo_raridade.dart';
import 'package:grimorio/view/grimoire/condicoes/condicoes.dart';
import 'package:grimorio/view/grimoire/especies/especies.dart';
import 'package:grimorio/view/grimoire/itens/item_detalhe.dart';
import 'package:grimorio/view/grimoire/itens/itens.dart';
import 'package:grimorio/view/grimoire/magias/magia_detalhe.dart';
import 'package:grimorio/view/grimoire/magias/magias.dart';
import 'package:grimorio/model/grimoire_mock.dart';
import 'package:grimorio/model/hero_options_mock.dart';

class Grimoire extends StatefulWidget {
  const Grimoire({super.key});

  @override
  State<Grimoire> createState() => _GrimoireState();
}

class _GrimoireState extends State<Grimoire> {
  String _busca = '';

  static const _porGrupo = 5;

  // Telas internas vão no navigator raiz, por cima da barra flutuante.
  void _abrir(Widget tela) => Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute<void>(builder: (_) => tela));

  List<Widget> _categorias() {
    final cards = [
      CardCategoria(
        nome: 'Classes',
        contagem: '${classesMock.length} classes',
        imagem: AppImages.menuGrimorio,
        onTap: () => _abrir(const Classes()),
      ),
      CardCategoria(
        nome: 'Espécies',
        contagem: '${especiesMock.length} espécies',
        imagem: AppImages.especieElfoF,
        onTap: () => _abrir(const Especies()),
      ),
      CardCategoria(
        nome: 'Magias',
        contagem: '${magiasCompendio.length} magias',
        imagem: AppImages.pergMagia,
        onTap: () => _abrir(const Magias()),
      ),
      CardCategoria(
        nome: 'Bestiário',
        contagem: '${monstrosMock.length} criaturas',
        imagem: AppImages.menuBestiario,
        onTap: () => _abrir(const Bestiario()),
      ),
      CardCategoria(
        nome: 'Itens',
        contagem: '${itensMock.length} itens',
        imagem: AppImages.bau,
        onTap: () => _abrir(const Itens()),
      ),
      CardCategoria(
        nome: 'Condições',
        contagem: '${condicoesMock.length} condições',
        imagem: AppImages.pocao7,
        onTap: () => _abrir(const Condicoes()),
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
          for (final m in magiasCompendio.where((m) => contem(m.nome, b)))
            LinhaCompendio(
              imagem: imagemDaEscola(m.escola),
              titulo: m.nome,
              subtitulo: '${nomeDoCirculo(m.circulo)} · ${m.escola}',
              tags: TagsMagia(magia: m),
              onTap: () => _abrir(MagiaDetalhe(magia: m)),
            ),
        ],
      ),
      (
        'Criaturas',
        [
          for (final m in monstrosMock.where((m) => contem(m.nome, b)))
            LinhaCompendio(
              imagem: m.imagem,
              titulo: m.nome,
              subtitulo: '${m.tipo} ${m.tamanho} · ND ${m.nd}',
              onTap: () => _abrir(MonstroDetalhe(monstro: m)),
            ),
        ],
      ),
      (
        'Itens',
        [
          for (final i in itensMock.where((i) => contem(i.nome, b)))
            LinhaCompendio(
              imagem: i.imagem,
              titulo: i.nome,
              subtitulo: i.categoria,
              corBorda: i.raridade.cor,
              trailing: SeloRaridade(i.raridade),
              onTap: () => mostrarItem(context, i),
            ),
        ],
      ),
      (
        'Classes',
        [
          for (final c in classesMock.where((c) => contem(c.nome, b)))
            LinhaCompendio(
              imagem: c.imagem,
              titulo: c.nome,
              subtitulo: papelDaClasse[c.key] ?? '',
              onTap: () => _abrir(ClasseDetalhe(classe: c)),
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
    final buscando = normalizar(_busca).length >= 2;

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
