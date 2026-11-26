import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/estado_lista.dart';
import 'package:grimorio/controller/grimoire/filtros_srd.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/magia.dart';
import 'package:grimorio/view/characters/ficha/components/titulo_secao.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:grimorio/widgets/etiqueta.dart';
import 'package:provider/provider.dart';

// rotulo, nivel exato e nivel minimo
const _circulos = <(String, int?, int?)>[
  ('Todas', null, null),
  ('Truques', 0, null),
  ('1º', 1, null),
  ('2º', 2, null),
  ('3º', 3, null),
  ('4º+', null, 4),
];

const _escolas = [
  'abjuration',
  'conjuration',
  'divination',
  'enchantment',
  'evocation',
  'illusion',
  'necromancy',
  'transmutation',
];

class Magias extends StatefulWidget {
  const Magias({super.key});

  @override
  State<Magias> createState() => _MagiasState();
}

class _MagiasState extends State<Magias> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = context.read<CompendioProvider>();
      c.carregarMagias(busca: c.magias.busca);
    });
  }

  CompendioProvider get _compendio => context.read<CompendioProvider>();

  void _filtrar(FiltroMagia filtro) =>
      _compendio.carregarMagias(busca: _compendio.magias.busca, filtro: filtro);

  // sheet simples de escolha, devolve '' para todas
  Future<String?> _escolher(
    String titulo,
    String? atual,
    Map<String, String> opcoes,
  ) => showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TituloSecao(titulo),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Etiqueta(
                  'Todas',
                  selecionado: atual == null,
                  onTap: () => Navigator.pop(sheet, ''),
                ),
                for (final MapEntry(:key, :value) in opcoes.entries)
                  Etiqueta(
                    value,
                    selecionado: atual == key,
                    onTap: () => Navigator.pop(sheet, key),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  // classes vem da api
  Future<void> _escolherClasse(FiltroMagia f) async {
    final classes = _compendio.classes;
    if (classes.carregamento != Carregamento.pronto) {
      await _compendio.carregarClasses();
    }
    if (!mounted) return;
    final escolha = await _escolher('Classe', f.classeKey, {
      for (final c in _compendio.classes.itens) c.key: c.nome,
    });
    if (escolha == null) return;
    _filtrar(f.copyWith(classeKey: () => escolha.isEmpty ? null : escolha));
  }

  Future<void> _escolherEscola(FiltroMagia f) async {
    final escolha = await _escolher('Escola', f.escolaKey, {
      for (final e in _escolas) e: TraducaoSrd.escola(e),
    });
    if (escolha == null) return;
    _filtrar(f.copyWith(escolaKey: () => escolha.isEmpty ? null : escolha));
  }

  void _abrir(Magia m) => context.pushNamed(
    Rotas.nomeDetalheCompendio,
    pathParameters: {Rotas.tipo: TipoCompendio.magias, Rotas.key: m.key},
  );

  String? _nomeClasse(CompendioProvider c, String? key) {
    for (final x in c.classes.itens) {
      if (x.key == key) return x.nome;
    }
    return key;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CompendioProvider>();
    final f = c.filtroMagias;
    final classe = f.classeKey;
    final escola = f.escolaKey;

    return TelaLista<Magia>(
      titulo: 'Magias',
      estado: c.magias,
      dicaBusca: 'Buscar magia',
      buscaInicial: c.magias.busca,
      onBusca: (b) => _compendio.carregarMagias(busca: b),
      onCarregarMais: () => _compendio.carregarMaisMagias(),
      onTentarDeNovo: () =>
          _compendio.carregarMagias(busca: _compendio.magias.busca),
      onAtualizar: () => _compendio.carregarMagias(
        busca: _compendio.magias.busca,
        forcar: true,
      ),
      vazioTitulo: 'Nenhuma magia encontrada',
      secaoDe: (m) => m.nivel == 0 ? 'Truques' : VisualSrd.nivel(m.nivel),
      filtros: [
        Filtros(
          itens: [
            for (final (rotulo, nivel, minimo) in _circulos)
              Filtro(
                rotulo,
                selecionado: f.nivel == nivel && f.nivelMinimo == minimo,
                onTap: () => _filtrar(
                  f.copyWith(nivel: () => nivel, nivelMinimo: () => minimo),
                ),
              ),
          ],
        ),
        Filtros(
          itens: [
            Filtro(
              classe == null ? 'Classe' : 'Classe: ${_nomeClasse(c, classe)}',
              selecionado: classe != null,
              onTap: () => _escolherClasse(f),
            ),
            Filtro(
              escola == null
                  ? 'Escola'
                  : 'Escola: ${TraducaoSrd.escola(escola)}',
              selecionado: escola != null,
              onTap: () => _escolherEscola(f),
            ),
            Filtro(
              'Concentração',
              selecionado: f.concentracao,
              onTap: () => _filtrar(f.copyWith(concentracao: !f.concentracao)),
            ),
          ],
        ),
      ],
      itemBuilder: (_, m) => CompendioTile(
        imagem: VisualSrd.escola(m.escola),
        titulo: m.nome,
        subtitulo: [
          TraducaoSrd.escola(m.escola),
          TraducaoSrd.tempo(m.tempo),
        ].join(' · '),
        tags: TagsMagia(concentracao: m.concentracao, ritual: m.ritual),
        onTap: () => _abrir(m),
      ),
    );
  }
}

class TagsMagia extends StatelessWidget {
  const TagsMagia({
    super.key,
    required this.concentracao,
    required this.ritual,
  });

  final bool concentracao;
  final bool ritual;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (concentracao)
          const Etiqueta('C', pequena: true, cor: AppColors.mana),
        if (ritual)
          const Etiqueta('R', pequena: true, cor: AppColors.secondary),
      ],
    );
  }
}
