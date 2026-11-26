import 'package:flutter/material.dart';
import 'package:grimorio/app/theme/app_colors.dart';
import 'package:grimorio/app/theme/app_spacing.dart';
import 'package:grimorio/view/characters/ficha/components/aba_combate.dart';
import 'package:grimorio/view/characters/ficha/components/aba_diario.dart';
import 'package:grimorio/view/characters/ficha/components/aba_inventario.dart';
import 'package:grimorio/view/characters/ficha/components/aba_magias.dart';
import 'package:grimorio/view/characters/ficha/components/aba_pericias.dart';
import 'package:grimorio/view/characters/ficha/components/aba_resumo.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_abas.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_cabecalho.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_condicoes.dart';
import 'package:grimorio/view/characters/ficha/components/ficha_status.dart';
import 'package:grimorio/model/character.dart';
import 'package:grimorio/widgets/image_frame.dart';
import 'package:grimorio/widgets/snack_bar.dart';
import 'package:pixelarticons/pixel.dart';

class Ficha extends StatefulWidget {
  const Ficha({super.key, required this.personagem});

  final Character personagem;

  @override
  State<Ficha> createState() => _FichaState();
}

class _FichaState extends State<Ficha> {
  late Character _p = widget.personagem;
  int _aba = 0;

  final _rolagem = ScrollController();
  bool _compacto = false;

  static const _limiteCompacto = 190.0;

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

  void _atualizar(Character Function(Character p) acao) {
    if (!mounted) return;
    setState(() => _p = acao(_p));
  }

  void _sair() => Navigator.pop(context, _p);

  void _usarItem(String id) {
    final item = _p.inventario.where((i) => i.id == id).firstOrNull;
    _atualizar((p) => p.usarItem(id));
    if (item != null) {
      mostrarAviso(context, '${item.nome} usado', tipo: Snackbar.sucesso);
    }
  }

  Widget _conteudo() => switch (_aba) {
    0 => AbaResumo(
      personagem: _p,
      onInspiracao: () => _atualizar((p) => p.alternarInspiracao()),
      onCurar: (v) => _atualizar((p) => p.curar(v)),
      onDescansoLongo: () => _atualizar((p) => p.descansoLongo()),
      onVerPericias: () => setState(() => _aba = 1),
    ),
    1 => AbaPericias(personagem: _p),
    2 => AbaCombate(
      personagem: _p,
      onIrInventario: () => setState(() => _aba = 4),
    ),
    3 => AbaMagias(
      personagem: _p,
      onGastar: (c) => _atualizar((p) => p.gastarEspaco(c)),
      onRecuperar: (c) => _atualizar((p) => p.recuperarEspaco(c)),
      onAlternarPreparada: (k) => _atualizar((p) => p.alternarPreparada(k)),
    ),
    4 => AbaInventario(
      personagem: _p,
      onEquipar: (id) => _atualizar((p) => p.equipar(id)),
      onDesequipar: (id) => _atualizar((p) => p.desequipar(id)),
      onUsar: _usarItem,
      onRemover: (id) => _atualizar((p) => p.removerItem(id)),
      onMoedas: (m) => _atualizar((p) => p.definirMoedas(m)),
    ),
    _ => AbaDiario(
      notas: _p.notas,
      onAdicionar: (n) => _atualizar((p) => p.adicionarNota(n)),
      onRemover: (id) => _atualizar((p) => p.removerNota(id)),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return PopScope<Character>(
      canPop: false,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) _sair();
      },
      child: Scaffold(
        body: CustomScrollView(
          controller: _rolagem,
          slivers: [
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
                    FichaCabecalho(
                      personagem: _p,
                      onSubirNivel: () => mostrarAviso(context, 'Em breve'),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    FichaStatus(
                      personagem: _p,
                      onDano: (v) => _atualizar((p) => p.receberDano(v)),
                      onCura: (v) => _atualizar((p) => p.curar(v)),
                      onHpTemp: (v) => _atualizar((p) => p.definirHpTemp(v)),
                    ),
                    const SizedBox(height: AppSpacing.medium - 4),
                    FichaCondicoes(
                      condicoes: _p.condicoes,
                      onAdicionar: (c) =>
                          _atualizar((p) => p.adicionarCondicao(c)),
                      onRemover: (n) => _atualizar((p) => p.removerCondicao(n)),
                    ),
                  ],
                ),
              ),
            ),
            FichaAbas(aba: _aba, onAba: (i) => setState(() => _aba = i)),
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

  final Character personagem;

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
