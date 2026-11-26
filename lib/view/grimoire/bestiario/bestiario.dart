import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/router/rotas.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/controller/grimoire/compendio_provider.dart';
import 'package:grimorio/controller/grimoire/filtros_srd.dart';
import 'package:grimorio/controller/grimoire/traducao_srd.dart';
import 'package:grimorio/model/srd/monstro_srd.dart';
import 'package:grimorio/view/grimoire/components/compendio_tile.dart';
import 'package:grimorio/view/grimoire/components/filtros.dart';
import 'package:grimorio/view/grimoire/components/tela_lista.dart';
import 'package:grimorio/view/grimoire/components/visual_srd.dart';
import 'package:provider/provider.dart';

// rotulo, nd minimo e maximo
const _faixas = <(String, double?, double?)>[
  ('Todos', null, null),
  ('ND 0–1', null, 1),
  ('ND 2–4', 2, 4),
  ('ND 5–10', 5, 10),
  ('ND 11+', 11, null),
];

// keys da api
const _tipos = ['humanoid', 'beast', 'undead', 'giant', 'dragon', 'fiend'];

class Bestiario extends StatefulWidget {
  const Bestiario({super.key});

  @override
  State<Bestiario> createState() => _BestiarioState();
}

class _BestiarioState extends State<Bestiario> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _compendio.carregarMonstros(busca: _compendio.monstros.busca),
    );
  }

  CompendioProvider get _compendio => context.read<CompendioProvider>();

  void _filtrar(FiltroMonstro filtro) => _compendio.carregarMonstros(
    busca: _compendio.monstros.busca,
    filtro: filtro,
  );

  void _abrir(MonstroSrd m) => context.pushNamed(
    Rotas.nomeDetalheCompendio,
    pathParameters: {Rotas.tipo: TipoCompendio.bestiario, Rotas.key: m.key},
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final c = context.watch<CompendioProvider>();
    final f = c.filtroMonstros;

    return TelaLista<MonstroSrd>(
      titulo: 'Bestiário',
      estado: c.monstros,
      dicaBusca: 'Buscar criatura',
      buscaInicial: c.monstros.busca,
      onBusca: (b) => _compendio.carregarMonstros(busca: b),
      onCarregarMais: () => _compendio.carregarMaisMonstros(),
      onTentarDeNovo: () =>
          _compendio.carregarMonstros(busca: _compendio.monstros.busca),
      onAtualizar: () => _compendio.carregarMonstros(
        busca: _compendio.monstros.busca,
        forcar: true,
      ),
      vazioTitulo: 'Nenhuma criatura encontrada',
      filtros: [
        Filtros(
          itens: [
            for (final (rotulo, minimo, maximo) in _faixas)
              Filtro(
                rotulo,
                selecionado: f.ndMinimo == minimo && f.ndMaximo == maximo,
                onTap: () => _filtrar(
                  f.copyWith(ndMinimo: () => minimo, ndMaximo: () => maximo),
                ),
              ),
          ],
        ),
        Filtros(
          itens: [
            Filtro(
              'Tipo: todos',
              selecionado: f.tipo == null,
              onTap: () => _filtrar(f.copyWith(tipo: () => null)),
            ),
            for (final t in _tipos)
              Filtro(
                TraducaoSrd.tipoMonstro(t),
                selecionado: f.tipo == t,
                onTap: () =>
                    _filtrar(f.copyWith(tipo: () => f.tipo == t ? null : t)),
              ),
          ],
        ),
      ],
      itemBuilder: (_, m) => CompendioTile(
        imagem: VisualSrd.monstro,
        imagemUrl: m.imagem,
        titulo: m.nome,
        subtitulo: [
          '${TraducaoSrd.tipoMonstro(m.tipo)} ${TraducaoSrd.tamanho(m.tamanho)}',
          if (m.xp case final xp?) '${VisualSrd.milhar(xp)} XP',
        ].join(' · '),
        onTap: () => _abrir(m),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'ND ${VisualSrd.nd(m.nd)}',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.alerta,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'CA ${m.ca ?? '—'} · PV ${m.pv ?? '—'}',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
