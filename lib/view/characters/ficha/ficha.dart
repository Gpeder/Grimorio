import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/controller/characters/gerenciador_condicoes.dart';
import 'package:grimorio/controller/characters/gerenciador_hp.dart';
import 'package:grimorio/controller/characters/gerenciador_inventario.dart';
import 'package:grimorio/controller/characters/gerenciador_magias.dart';
import 'package:grimorio/controller/characters/gerenciador_notas.dart';
import 'package:grimorio/controller/characters/personagens_provider.dart';
import 'package:grimorio/model/personagem.dart';
import 'package:grimorio/view/characters/ficha/components/combate_tab.dart';
import 'package:grimorio/view/characters/ficha/components/diario_tab.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_condicoes.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_header.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_status.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_tabs.dart';
import 'package:grimorio/view/characters/ficha/components/inventario_tab.dart';
import 'package:grimorio/view/characters/ficha/components/magias_tab.dart';
import 'package:grimorio/view/characters/ficha/components/pericias_tab.dart';
import 'package:grimorio/view/characters/ficha/components/resumo_tab.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:provider/provider.dart';

class Ficha extends StatefulWidget {
  const Ficha({super.key, required this.personagem});

  final Personagem personagem;

  @override
  State<Ficha> createState() => _FichaState();
}

class _FichaState extends State<Ficha> {
  late Personagem _p = widget.personagem;
  int _aba = 0;

  final _rolagem = ScrollController();
  bool _compacto = false;

  static const _limiteCompacto = 190.0;

  static const _hp = GerenciadorHp();
  static const _magias = GerenciadorMagias();
  static const _inventario = GerenciadorInventario();
  static const _condicoes = GerenciadorCondicoes();
  static const _notas = GerenciadorNotas();

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(() {
      final compacto = _rolagem.offset > _limiteCompacto;
      if (compacto != _compacto) setState(() => _compacto = compacto);
    });
  }

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  void _atualizar(Personagem Function(Personagem p) acao) {
    if (!mounted) return;
    setState(() => _p = acao(_p));
  }

  // salva no provider e volta
  void _sair() {
    context.read<PersonagensProvider>().atualizar(_p);
    context.pop();
  }

  void _usarItem(String id) {
    final item = _p.inventario.where((i) => i.id == id).firstOrNull;
    _atualizar((p) => _inventario.usar(p, id));
    if (item != null) {
      mostrarAviso(context, '${item.nome} usado', tipo: Snackbar.sucesso);
    }
  }

  Widget _conteudo() => switch (_aba) {
    0 => ResumoTab(
      personagem: _p,
      onInspiracao: () => _atualizar((p) => _condicoes.alternarInspiracao(p)),
      onCurar: (v) => _atualizar((p) => _hp.curar(p, v)),
      onDescansoLongo: () => _atualizar((p) => _hp.descansoLongo(p)),
      onVerPericias: () => setState(() => _aba = 1),
    ),
    1 => PericiasTab(personagem: _p),
    2 => CombateTab(
      personagem: _p,
      onIrInventario: () => setState(() => _aba = 4),
    ),
    3 => MagiasTab(
      personagem: _p,
      onGastar: (c) => _atualizar((p) => _magias.gastarEspaco(p, c)),
      onRecuperar: (c) => _atualizar((p) => _magias.recuperarEspaco(p, c)),
      onAlternarPreparada: (k) =>
          _atualizar((p) => _magias.alternarPreparada(p, k)),
    ),
    4 => InventarioTab(
      personagem: _p,
      onEquipar: (id) => _atualizar((p) => _inventario.equipar(p, id)),
      onDesequipar: (id) => _atualizar((p) => _inventario.desequipar(p, id)),
      onUsar: _usarItem,
      onRemover: (id) => _atualizar((p) => _inventario.remover(p, id)),
      onMoedas: (m) => _atualizar((p) => _inventario.definirMoedas(p, m)),
    ),
    _ => DiarioTab(
      notas: _p.notas,
      onAdicionar: (n) => _atualizar((p) => _notas.adicionar(p, n)),
      onRemover: (id) => _atualizar((p) => _notas.remover(p, id)),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _sair();
      },
      child: Scaffold(
        body: CustomScrollView(
          controller: _rolagem,
          slivers: [
            // barra fixa, titulo aparece ao rolar
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              leading: TextButton(
                onPressed: _sair,
                child: const Icon(
                  Pixel.chevronleft,
                  color: AppColors.onSurface,
                  semanticLabel: 'Voltar',
                ),
              ),
              title: AnimatedOpacity(
                opacity: _compacto ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: _TituloCompacto(personagem: _p),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.medium,
                0,
                AppSpacing.medium,
                AppSpacing.medium,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // nome, nivel e xp
                    FichaHeader(
                      personagem: _p,
                      onSubirNivel: () => mostrarAviso(context, 'Em breve'),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    // hp
                    FichaStatus(
                      personagem: _p,
                      onDano: (v) => _atualizar((p) => _hp.receberDano(p, v)),
                      onCura: (v) => _atualizar((p) => _hp.curar(p, v)),
                      onHpTemp: (v) => _atualizar((p) => _hp.definirTemp(p, v)),
                    ),
                    const SizedBox(height: AppSpacing.medium - 4),
                    // condições
                    FichaCondicoes(
                      condicoes: _p.condicoes,
                      onAdicionar: (c) =>
                          _atualizar((p) => _condicoes.adicionar(p, c)),
                      onRemover: (n) =>
                          _atualizar((p) => _condicoes.remover(p, n)),
                    ),
                  ],
                ),
              ),
            ),
            // abas
            FichaTabs(aba: _aba, onAba: (i) => setState(() => _aba = i)),
            SliverSafeArea(
              top: false,
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.medium,
                  AppSpacing.medium,
                  AppSpacing.medium,
                  AppSpacing.large,
                ),
                sliver: SliverToBoxAdapter(
                  // conteudo da aba
                  child: KeyedSubtree(key: ValueKey(_aba), child: _conteudo()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TituloCompacto extends StatelessWidget {
  const _TituloCompacto({required this.personagem});

  final Personagem personagem;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final p = personagem;

    return Row(
      children: [
        ImageFrame(imagePath: p.retrato, width: 40, height: 40),
        const SizedBox(width: AppSpacing.medium - 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                p.nome,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${p.classes.map((c) => c.nome).join(' / ')} · Nv ${p.nivel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: AppColors.alerta),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
